@echo off
setlocal
cd %~dp0
call setup_build_environment.bat

set MBT_THREADS=1
set MBT_DEBUG=0
set TARGET_PLATFORM=
set MATERIALS=

set prevArg=
:parse_args
	set arg=%1
	if "%arg%"=="" goto :end

    if "%arg%"=="--threads" (
        set prevArg=threads
        goto :continue
    )
    if "%arg%"=="-t" (
        set prevArg=threads
        goto :continue
    )
    if "%arg%"=="--platform" (
        set prevArg=platform
        goto :continue
    )
    if "%arg%"=="-p" (
        set prevArg=platform
        goto :continue
    )
    if "%arg%"=="--material" (
        set prevArg=material
        goto :continue
    )
    if "%arg%"=="-m" (
        set prevArg=material
        goto :continue
    )
    if "%arg%"=="--debug" (
        set MBT_DEBUG=1
        goto :continue
    )

    if "%prevArg%"=="threads" (
        set prevArg=
        set MBT_THREADS=%arg%
        goto :continue
    )
    if "%prevArg%"=="platform" (
        set TARGET_PLATFORM=%TARGET_PLATFORM% %arg%
        goto :continue
    )
    if "%prevArg%"=="material" (
        set MATERIALS=%MATERIALS% %arg%
        goto :continue
    )

    set TARGET_PLATFORM=%TARGET_PLATFORM% %arg%
:continue
	shift
	goto :parse_args
:end

set MBT_ARGS=--compile --shaderc %SHADERC% --include include --threads %MBT_THREADS%
if %MBT_DEBUG%==1 (
    set MBT_ARGS=%MBT_ARGS% --debug
)

set ALL_PLATFORM=0
if "%TARGET_PLATFORM%"=="" (
    set TARGET_PLATFORM=Windows Android iOS
    set ALL_PLATFORM=1
)
for %%p in (%TARGET_PLATFORM%) do (
    echo Building materials for %%p
    if "%MATERIALS%"=="" (
        for /d %%m in (materials\*) do (
            echo Building %%~nxm
            call :build %%p %%~nxm
        )
    ) else (
        for %%m in (%MATERIALS%) do (
            echo Building %%m
            call :build %%p %%m
        )
    )
    echo.
)
goto :end

@REM %1 platform
@REM %2 material
:build
    if exist materials\%2\data\%1 (
        %MBT% %MBT_ARGS% --output build\%1 --data %DATA_DIR%\%1\%2 materials\%2
    ) else (
        if exist %DATA_DIR%\%1 (
            %MBT% %MBT_ARGS% --output build\%1 --data %DATA_DIR%\%1\%2 materials\%2
        ) else (
            @REM if %ALL_PLATFORM%==0 (
            @REM     echo No data found for material %2 on platform %1
            @REM )
            echo No data found for material %2 on platform %1
        )
    )
    goto :EOF

:end
endlocal
