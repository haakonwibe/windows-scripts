@echo off
cd /d C:\Tools\iCloudDownloader

:menu
cls
echo --------------------------------------
echo   iCloud Photo Downloader Menu
echo --------------------------------------
echo [1] Download iCloud Photos
echo [2] Download Shared Library
echo [3] Download Both
echo [4] Exit
echo.
set /p choice="Enter your choice: "

if "%choice%"=="1" goto photos
if "%choice%"=="2" goto shared
if "%choice%"=="3" goto both
if "%choice%"=="4" goto :eof
goto menu

:photos
icloudpd.exe --username your@email.com --directory D:\iCloudPhotos\
pause
goto :eof

:shared
icloudpd.exe --username your@email.com --library YourLibraryID --directory D:\iCloudShared\
pause
goto :eof

:both
call :photos
call :shared
pause
goto menu
