@echo off
set TARGET_PATH="D:\LeviLauncher\minecraft\Minecraft-1.21.93.1\data\renderer\materials"
echo ------compiling------
cd materials
lazurite build ./ -o ../build/bin -m Actor ActorBanner ActorGlint ItemInHandColor ItemInHandColorGlint ItemInHandTextured Particle RenderChunk RenderChunkPrepass Sky
cd ..
echo ------compile completed------
7z a build\%1.7z build\bin\*.material.bin
echo ------compress completed------
@REM replace build\bin\*.material.bin %TARGET_PATH%
@REM echo ------replace completed------