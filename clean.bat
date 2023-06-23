@echo off
for %%p in (Windows Android iOS Merged) do (
    if exist build\%%p\*.material.bin (
        del build\%%p\*.material.bin
    )
)
