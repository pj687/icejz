# -*- coding: utf-8 -*-
"""Dump icejz_boot and scrub secrets from the SQL file."""
from __future__ import annotations

import re
import subprocess
from pathlib import Path

OUT = Path(__file__).resolve().parent / "icejz.sql"
DB = "icejz_boot"
MYSQL_USER = "root"
MYSQL_PASS = "123456"
MYSQLDUMP = r"D:\MySQL\MySQL Server 8.0\bin\mysqldump.exe"

# table -> columns to blank in INSERT statements
SECRET_COLUMNS = {
    "sys_ai_model": ["api_key"],
    "sys_sms_config": ["access_key", "secret_key"],
    "sys_mail_config": ["access_key", "secret_key", "mail_pass"],
    "sys_third_login_config": ["client_secret"],
    "sys_captcha_config": ["turnstile_secret_key"],
    "gen_datasource": ["password"],
    "iot_device": ["secret"],
}

# sys_params.param_key whose param_value must be cleared
SECRET_PARAM_KEYS = {
    "TURNSTILE_SECRET_KEY",
    "SMS_ACCESS_KEY",
    "SMS_SECRET_KEY",
    "MAIL_ACCESS_KEY",
    "MAIL_SECRET_KEY",
    "DEEPSEEK_API_KEY",
    "OPENAI_API_KEY",
}

# drop data for ephemeral auth tokens
DROP_DATA_TABLES = {"sys_user_token"}


def dump_database() -> str:
    cmd = [
        MYSQLDUMP,
        f"-u{MYSQL_USER}",
        f"-p{MYSQL_PASS}",
        "--default-character-set=utf8mb4",
        "--single-transaction",
        "--routines",
        "--triggers",
        "--set-gtid-purged=OFF",
        "--complete-insert",
        DB,
    ]
    proc = subprocess.run(cmd, capture_output=True, check=False)
    if proc.returncode != 0:
        err = proc.stderr.decode("utf-8", errors="replace")
        raise RuntimeError(f"mysqldump failed: {err}")
    raw = proc.stdout
    for enc in ("utf-8", "gbk", "latin1"):
        try:
            return raw.decode(enc)
        except UnicodeDecodeError:
            continue
    return raw.decode("utf-8", errors="replace")


def split_sql_values(values_blob: str) -> list[str]:
    """Split INSERT values list into row tuples, respecting quotes."""
    rows: list[str] = []
    buf: list[str] = []
    depth = 0
    in_str = False
    escape = False
    for ch in values_blob:
        if in_str:
            buf.append(ch)
            if escape:
                escape = False
            elif ch == "\\":
                escape = True
            elif ch == "'":
                in_str = False
            continue
        if ch == "'":
            in_str = True
            buf.append(ch)
            continue
        if ch == "(":
            depth += 1
            buf.append(ch)
            continue
        if ch == ")":
            depth -= 1
            buf.append(ch)
            if depth == 0:
                rows.append("".join(buf).strip().strip(","))
                buf = []
            continue
        if depth == 0 and ch in (",", " ", "\n", "\r", "\t"):
            continue
        buf.append(ch)
    return [r for r in rows if r]


def split_row_fields(row: str) -> list[str]:
    """Split a single `(...)` row into field SQL literals."""
    assert row.startswith("(") and row.endswith(")")
    body = row[1:-1]
    fields: list[str] = []
    buf: list[str] = []
    in_str = False
    escape = False
    depth = 0
    for ch in body:
        if in_str:
            buf.append(ch)
            if escape:
                escape = False
            elif ch == "\\":
                escape = True
            elif ch == "'":
                in_str = False
            continue
        if ch == "'":
            in_str = True
            buf.append(ch)
            continue
        if ch in "([{":
            depth += 1
            buf.append(ch)
            continue
        if ch in ")]}":
            depth -= 1
            buf.append(ch)
            continue
        if ch == "," and depth == 0:
            fields.append("".join(buf).strip())
            buf = []
            continue
        buf.append(ch)
    if buf:
        fields.append("".join(buf).strip())
    return fields


def find_insert_end(sql: str, start: int) -> int:
    """Return index just past the terminating ';' of an INSERT, respecting quotes."""
    in_str = False
    escape = False
    i = start
    while i < len(sql):
        ch = sql[i]
        if in_str:
            if escape:
                escape = False
            elif ch == "\\":
                escape = True
            elif ch == "'":
                in_str = False
        else:
            if ch == "'":
                in_str = True
            elif ch == ";":
                return i + 1
        i += 1
    return len(sql)


def iter_inserts(sql: str):
    """Yield (start, end, table, cols, vals) for each INSERT statement."""
    marker = "INSERT INTO `"
    pos = 0
    while True:
        start = sql.find(marker, pos)
        if start < 0:
            break
        table_start = start + len(marker)
        table_end = sql.find("`", table_start)
        if table_end < 0:
            break
        table = sql[table_start:table_end]
        cols_open = sql.find("(", table_end)
        cols_close = sql.find(")", cols_open)
        if cols_open < 0 or cols_close < 0:
            break
        cols = sql[cols_open + 1 : cols_close]
        values_kw = sql.find("VALUES", cols_close)
        if values_kw < 0:
            break
        vals_start = values_kw + len("VALUES")
        end = find_insert_end(sql, vals_start)
        vals = sql[vals_start:end].lstrip()
        if vals.endswith(";"):
            vals = vals[:-1].strip()
        yield start, end, table, cols, vals
        pos = end


def blank_insert_secrets(sql: str) -> str:
    pieces: list[str] = []
    cursor = 0
    for start, end, table, cols_raw, vals in iter_inserts(sql):
        pieces.append(sql[cursor:start])
        if table in DROP_DATA_TABLES:
            pieces.append(f"-- sanitized: skipped data for `{table}`\n")
            cursor = end
            continue

        cols = [c.strip().strip("`") for c in cols_raw.split(",")]
        secret_cols = SECRET_COLUMNS.get(table, [])
        indexes = [cols.index(c) for c in secret_cols if c in cols]
        key_idx = cols.index("param_key") if table == "sys_params" and "param_key" in cols else -1
        val_idx = cols.index("param_value") if table == "sys_params" and "param_value" in cols else -1
        needs_work = bool(indexes) or table == "sys_params"

        if not needs_work:
            pieces.append(sql[start:end])
            cursor = end
            continue

        rows = split_sql_values(vals)
        new_rows: list[str] = []
        changed = False
        for row in rows:
            fields = split_row_fields(row)
            for idx in indexes:
                if idx < len(fields) and fields[idx] not in ("''", "NULL", "null"):
                    fields[idx] = "''"
                    changed = True
            if key_idx >= 0 and val_idx >= 0 and key_idx < len(fields) and val_idx < len(fields):
                key_lit = fields[key_idx].strip("'")
                if key_lit in SECRET_PARAM_KEYS and fields[val_idx] not in ("''", "NULL", "null"):
                    fields[val_idx] = "''"
                    changed = True
            new_rows.append("(" + ", ".join(fields) + ")")

        if not changed:
            pieces.append(sql[start:end])
        else:
            pieces.append(
                f"INSERT INTO `{table}` ({cols_raw}) VALUES\n"
                + ",\n".join(new_rows)
                + ";\n"
            )
        cursor = end

    pieces.append(sql[cursor:])
    return "".join(pieces)


def add_header(sql: str) -> str:
    header = """-- ICEJZ Boot MySQL dump (sanitized)
-- Database: icejz_boot
-- Notes:
--   1. AI / SMS / Mail / Third-login / Captcha / IoT / Generator secrets are cleared.
--   2. sys_user_token data is omitted.
--   3. Fill API keys again in 「系统管理 · AI助手」 after import if needed.
--   4. Default demo passwords remain SM3 hashes; every seed user password is 123456.

SET NAMES utf8mb4;
SET FOREIGN_KEY_CHECKS = 0;

"""
    return header + sql + "\nSET FOREIGN_KEY_CHECKS = 1;\n"


def main() -> None:
    print("Dumping database...")
    sql = dump_database()
    print("Sanitizing secrets...")
    sql = blank_insert_secrets(sql)
    # belt-and-suspenders: never leave sk- API keys in file
    sql = re.sub(r"'sk-[A-Za-z0-9_\\-]+'", "''", sql)
    sql = add_header(sql)
    OUT.write_text(sql, encoding="utf-8")
    print(f"Wrote {OUT} ({OUT.stat().st_size} bytes)")


if __name__ == "__main__":
    main()
