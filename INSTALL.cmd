@echo off
title Obsidian AI Memory Installer
powershell.exe -NoProfile -ExecutionPolicy Bypass -File "%~dp0scripts\Install-ObsidianAIMemory.ps1" %*
echo.
pause
