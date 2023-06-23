@echo off
set TARGET_PATH="D:\MCLauncher\Minecraft-1.20.0.1\data\renderer\materials"
echo ------compiling------
call build.bat -t 8 -p Merged -m Actor ActorBanner ActorGlint ItemInHandColor ItemInHandColorGlint ItemInHandTextured Particle RenderChunk
echo ------compile completed------
7z a build\%1.7z build\Merged\*.material.bin
echo ------compress completed------
replace build\Merged\*.material.bin %TARGET_PATH%
echo ------replace completed------