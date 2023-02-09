@echo off
set MATERIAL_BIN_TOOL_PATH="D:\program\MaterialBinTool-0.7.1-all.jar"
set TARGET_PATH="D:\MCLauncher\Minecraft-1.19.60.3\data\renderer\materials"

echo ------compiling------
java -jar %MATERIAL_BIN_TOOL_PATH% -s D:\program\shaderc.exe -c RenderChunk.json
echo ------compile completed------
replace "RenderChunk.material.bin" %TARGET_PATH%
echo ------replace completed------