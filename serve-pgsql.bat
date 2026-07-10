@echo off
cd /d "%~dp0"
call "%~dp0php-pgsql.bat" artisan config:clear
call "%~dp0php-pgsql.bat" artisan serve --host=0.0.0.0 --port=8000
