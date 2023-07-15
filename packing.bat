@echo off
set TARGET_PATH="D:\MCLauncher\Minecraft-1.20.1.2\data\renderer\materials"
echo ------compiling------
call build.bat -t 8 -p Merged -m Actor ActorBanner ActorGlint ItemInHandColor ItemInHandColorGlint ItemInHandTextured Particle RenderChunk Sky
echo ------compile completed------
7z a build\%1.7z build\Merged\*.material.bin
echo ------compress completed------
replace build\Merged\*.material.bin %TARGET_PATH%
echo ------replace completed------