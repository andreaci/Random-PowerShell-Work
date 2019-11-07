@ECHO OFF

REM --------------------------Start of getting superuser permissions--------------------------------------------

REM Check If the script has admin rights
openfiles.exe 1>nul 2>&1

REM If error flag set, we do not have admin.
if '%errorlevel%' NEQ '0' (
	echo Requesting administrative privileges...
	goto UACPrompt
	) else ( goto gotAdmin )

REM Now we create temp visual basic scrit which will run this script again with UAC
:UACPrompt
	echo Set UAC = CreateObject^("Shell.Application"^) > "%temp%\getadmin.vbs"
	set params=%*
	echo UAC.ShellExecute "cmd.exe", "/c %~s0 %params%", "", "runas", 1 >> "%temp%\getadmin.vbs"

REM Run getadmin.vbs which will run AvgSetup.bat with UAC
	"%temp%\getadmin.vbs"
REM Delete getadmin.vbs and exit
	del "%temp%\getadmin.vbs"
	exit /B

:gotAdmin

REM --------------------------End of getting superuser permissions--------------------------------------------


reg delete HKEY_LOCAL_MACHINE\SOFTWARE\Policies\Microsoft\Windows\WindowsUpdate\ /f /va

net stop wuauserv

del c:\WINDOWS\SoftwareDistribution\*.* /s /q

net start wuauserv

wuauclt /detectnow /register /reportnow

pause