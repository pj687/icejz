@echo off
cd /d %~dp0..
D:\php\php.exe -S 0.0.0.0:8080 -t public public/index.php
