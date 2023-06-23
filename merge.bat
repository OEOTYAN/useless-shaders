@echo off
setlocal
cd %~dp0
call setup_build_environment.bat

for /d %%m in (materials\*) do (
    %MBT% -m %DATA_DIR%\Android\%%~nxm\%%~nxm.json %DATA_DIR%\Windows\%%~nxm\%%~nxm.json %DATA_DIR%\iOS\%%~nxm\%%~nxm.json -o %DATA_DIR%\Merged\%%~nxm
)