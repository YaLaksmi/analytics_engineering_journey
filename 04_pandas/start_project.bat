@echo off
echo ========================================
echo   Запуск окружения для проекта Pandas
echo ========================================
echo.

REM Переход в нужную папку
F:
cd "F:\РАБОТА 2026\git_analytics_engineering_journey\04_pandas"

REM Активация виртуального окружения
call .venv\Scripts\activate.bat

echo.
echo ✅ Виртуальное окружение активировано!
echo 📍 Текущая папка: %cd%
echo.

REM Запуск VS Code
code .

echo.
echo 🚀 VS Code открыт. Приятной работы!
pause