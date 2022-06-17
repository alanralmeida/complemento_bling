CALL "C:\Program Files (x86)\Embarcadero\Studio\18.0\bin\BRCC32" RELATORIO
IF ERRORLEVEL 1 PAUSE
CALL "C:\Program Files (x86)\Embarcadero\Studio\18.0\bin\DCC32" RelComplBlinq
IF ERRORLEVEL 1 PAUSE

IF ERRORLEVEL 1 PAUSE

copy RelComplBlinq.dll ..\Exec\