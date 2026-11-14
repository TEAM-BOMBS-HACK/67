@echo off
setlocal EnableExtensions
color 0A
title Xeno - Build

where cmake >nul 2>nul
if errorlevel 1 (
  echo [خطأ] CMake غير مثبت أو غير موجود في PATH.
  echo ثبّت Visual Studio 2022 مع Desktop development with C++ وCMake.
  pause
  exit /b 1
)

where git >nul 2>nul
if errorlevel 1 (
  echo [خطأ] Git غير مثبت أو غير موجود في PATH.
  echo ثبّت Git for Windows ثم شغّل الملف مرة ثانية.
  pause
  exit /b 1
)

set "ZIP=%~dp067.zip"
if not exist "%ZIP%" (
  echo [خطأ] لم أجد 67.zip بجانب هذا الملف.
  echo ضع build_xeno.bat و67.zip في نفس المجلد.
  pause
  exit /b 1
)

set "WORK=%TEMP%\xeno-build-source"
set "OUT=%USERPROFILE%\Desktop\xeno-build"
if exist "%WORK%" rmdir /s /q "%WORK%"
mkdir "%WORK%"

echo فك ضغط المشروع...
powershell -NoProfile -ExecutionPolicy Bypass -Command "Expand-Archive -LiteralPath '%ZIP%' -DestinationPath '%WORK%' -Force"
if errorlevel 1 goto fail

set "SRC=%WORK%\xeno-executor-main"
if not exist "%SRC%\CMakeLists.txt" (
  echo [خطأ] لم يتم العثور على ملفات المشروع.
  goto fail
)

cd /d "%SRC%"
echo تجهيز CMake وتنزيل المكتبات...
cmake --preset msvc-x64
if errorlevel 1 goto fail

echo بناء نسخة Release...
cmake --build --preset release
if errorlevel 1 goto fail

if exist "%OUT%" rmdir /s /q "%OUT%"
mkdir "%OUT%"
copy /y "%SRC%\build\src\dll\Release\xeno.dll" "%OUT%\" >nul
copy /y "%SRC%\build\src\injector\Release\xeno_injector.exe" "%OUT%\" >nul

echo.
echo تم البناء بنجاح.
echo الملفات موجودة في: %OUT%
explorer "%OUT%"
pause
exit /b 0

:fail
echo.
echo فشل البناء. اقرأ رسالة الخطأ الظاهرة فوق.
pause
exit /b 1
