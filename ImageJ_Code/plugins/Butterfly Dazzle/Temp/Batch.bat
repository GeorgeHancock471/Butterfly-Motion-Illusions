@echo off
REM Set the path to Blender executable
set BLENDER_PATH="C:\Program Files\Blender Foundation\Blender 4.0\blender.exe"
REM Set the path to the Python script you want to run
set SCRIPT_PATH="D:\Organised_Butterfly_Dazzle_George\ButterflyEvo_ImageJ_windows\plugins\Butterfly Dazzle\Temp\butterflyRender.py"
REM Run Blender in background mode and execute the Python script

%BLENDER_PATH% --python %SCRIPT_PATH%

CALL exit
