@echo off
set textfile=include\defines.sh

echo. > "%textfile%"
call packing.bat NoChunkBorders

echo. > "%textfile%"
(
echo #define NIGHT_VISION
echo #define LIGHT_OVERLAY
echo #define CHUNK_BORDERS
) > "%textfile%"
call packing.bat NightVision-LightOnly

echo. > "%textfile%"
(
echo #define LIGHT_OVERLAY
echo #define CHUNK_BORDERS
) > "%textfile%"
call packing.bat LightOnly

echo. > "%textfile%"
(
echo #define NIGHT_VISION
echo #define CHUNK_BORDERS
) > "%textfile%"
call packing.bat NightVision

echo. > "%textfile%"
(
echo #define CHUNK_BORDERS
) > "%textfile%"
call packing.bat default