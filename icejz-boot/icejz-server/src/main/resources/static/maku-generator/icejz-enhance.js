/**
 * ICEJZ generator shell: embed top-nav + light UX polish.
 * Runs after the Vite SPA mounts.
 */
(function () {
  const NAV = [
    { path: "/gen/generator", title: "代码生成", desc: "表结构与代码产出" },
    { path: "/gen/datasource", title: "数据源", desc: "连接与库表导入" },
    { path: "/gen/field-type", title: "字段映射", desc: "类型转换规则" },
    { path: "/gen/base-class", title: "基类管理", desc: "实体继承基类" },
    { path: "/gen/project", title: "项目变更", desc: "包名与工程替换" },
    { path: "/gen/config", title: "全局配置", desc: "作者与模板参数" }
  ];

  const isEmbed = () => document.documentElement.classList.contains("icejz-embed");

  function getRouter() {
    const app = document.querySelector("#app")?.__vue_app__;
    return app?.config?.globalProperties?.$router || null;
  }

  function currentPath(router) {
    if (router?.currentRoute?.value?.path) {
      return router.currentRoute.value.path;
    }
    const hash = location.hash || "";
    return hash.replace(/^#/, "") || "/gen/generator";
  }

  function ensureShell() {
    if (document.getElementById("icejz-gen-shell")) {
      return document.getElementById("icejz-gen-shell");
    }
    const shell = document.createElement("div");
    shell.id = "icejz-gen-shell";
    shell.className = "icejz-shell";
    shell.innerHTML = `
      <div class="icejz-shell__bar">
        <div class="icejz-shell__brand">
          <span class="icejz-shell__mark">
            <img class="icejz-shell__logo" src="./logo.png" alt="ICEJZ" />
            <span class="icejz-shell__shine" aria-hidden="true"></span>
          </span>
          <div class="icejz-shell__titles">
            <strong>ICEJZ 代码生成器</strong>
            <em>本地后端 · 一站式 CRUD 产出</em>
          </div>
        </div>
        <nav class="icejz-shell__nav" aria-label="生成器功能"></nav>
      </div>
      <div class="icejz-shell__hint" id="icejz-gen-hint"></div>
    `;
    document.body.prepend(shell);
    return shell;
  }

  function renderNav(router) {
    const shell = ensureShell();
    const nav = shell.querySelector(".icejz-shell__nav");
    const hint = shell.querySelector("#icejz-gen-hint");
    const path = currentPath(router);
    nav.innerHTML = "";

    NAV.forEach((item) => {
      const btn = document.createElement("button");
      btn.type = "button";
      btn.className = "icejz-shell__tab" + (path.startsWith(item.path) ? " is-active" : "");
      btn.innerHTML = `<span>${item.title}</span>`;
      btn.title = item.desc;
      btn.addEventListener("click", () => {
        if (router) {
          router.push(item.path);
        } else {
          location.hash = "#" + item.path;
        }
      });
      nav.appendChild(btn);
    });

    const active = NAV.find((n) => path.startsWith(n.path)) || NAV[0];
    hint.textContent = active.desc;
    document.documentElement.classList.add("icejz-shell-on");
    if (isEmbed()) {
      document.documentElement.classList.add("icejz-shell-embed");
    }
  }

  function bindRouter(router) {
    renderNav(router);
    polishDom();
    if (router && !router.__icejzBound) {
      router.__icejzBound = true;
      router.afterEach(() => {
        renderNav(router);
        setTimeout(polishDom, 50);
        setTimeout(polishDom, 300);
      });
    }
  }

  function polishDom() {
    document.querySelectorAll(".layout-sidebar .el-sub-menu").forEach((el) => {
      el.classList.add("is-opened");
    });

    if (document.title.includes("Maku") || !document.title.includes("ICEJZ")) {
      document.title = "ICEJZ 代码生成器";
    }

    document.querySelectorAll(".layout-card .el-form--inline, .el-card .el-form--inline").forEach((form) => {
      form.classList.add("icejz-toolbar");
    });

    // Empty-state tip under tables
    document.querySelectorAll(".el-table__empty-block").forEach((block) => {
      if (block.querySelector(".icejz-empty-tip")) return;
      const tip = document.createElement("div");
      tip.className = "icejz-empty-tip";
      const path = currentPath(getRouter());
      if (path.includes("datasource")) {
        tip.textContent = "暂无数据源。点击「新增」配置数据库连接后，即可在「代码生成」中导入表。";
      } else if (path.includes("generator")) {
        tip.textContent = "暂无生成表。请先到「数据源」配置连接，再点「导入」拉取表结构。";
      } else {
        tip.textContent = "暂无数据，可通过上方按钮新增。";
      }
      block.appendChild(tip);
    });
  }

  function applyDark(dark) {
    document.documentElement.classList.toggle("dark", !!dark);
  }

  function syncDarkFromParent() {
    try {
      const parentDark = window.parent?.document?.documentElement?.classList?.contains("dark");
      if (typeof parentDark === "boolean") {
        applyDark(parentDark);
        return;
      }
    } catch (e) {
      // cross-origin
    }
    try {
      const saved = localStorage.getItem("icejz-theme-dark");
      if (saved != null) applyDark(saved === "1");
    } catch (e) {}
  }

  function boot() {
    const router = getRouter();
    if (!router && !document.querySelector(".layout-container")) {
      return false;
    }
    bindRouter(router);
    polishDom();
    syncDarkFromParent();
    return true;
  }

  let tries = 0;
  const timer = setInterval(() => {
    tries += 1;
    if (boot() || tries > 80) {
      clearInterval(timer);
    }
  }, 100);

  window.addEventListener("hashchange", () => {
    bindRouter(getRouter());
  });

  window.addEventListener("message", (event) => {
    const data = event?.data;
    if (!data || data.type !== "icejz-theme") return;
    applyDark(!!data.dark);
  });

  syncDarkFromParent();
  try {
    const parentHtml = window.parent?.document?.documentElement;
    if (parentHtml && window.MutationObserver) {
      const mo = new MutationObserver(() => syncDarkFromParent());
      mo.observe(parentHtml, { attributes: true, attributeFilter: ["class"] });
    }
  } catch (e) {}
})();
