@echo off
set MATERIAL_BIN_TOOL_PATH="D:\program\MaterialBinTool-0.5.1-all.jar"
set TARGET_PATH="D:\MCLauncher\Minecraft-1.19.22.1\data\renderer\materials"

echo ------compiling android------
java -jar %MATERIAL_BIN_TOOL_PATH% -s D:\program\shaderc.exe RenderChunk\RenderChunk.json -c
@REM java -jar D:\program\MaterialBinTool-0.5.1-all.jar -s D:\program\shaderc.exe RenderChunk_ios\RenderChunk.json -c
echo ------compiling windows------
java -jar %MATERIAL_BIN_TOOL_PATH% -s D:\program\shaderc.exe RenderChunk_dxil2spirv2hlsl\RenderChunk.json -c
echo ------compile completed------
replace "RenderChunk_dxil2spirv2hlsl\RenderChunk.material.bin" %TARGET_PATH%
echo ------replace completed------