cd /d "%~dp0server-data"
start "" "%~dp0server\FXServer.exe" +exec server.cfg +set sv_enforceGameBuild 3258 +set onesync on +set onesync_enableInfinity 1 +set onesync_enableBeyond 1 +set onesync_population true
exit
