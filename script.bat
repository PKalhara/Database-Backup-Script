@echo off & setLocal EnableDelayedExpansion
::Folder Paths
SET mysqlFilePath= C:\xampp\mysql\bin
SET localFilePath= C:\Backups\local
SET reomteFilePath= C:\Backups\reomte

::File Names
SET mySqlOriginalBackup=mySql.sql
SET localBackupFileName=testLocal
SET remoteBackupFileName=testRemote
SET hashFileNameLocal=hashCodeFile.txt
SET hashFileNameRemote=hashCodeFileRemote.txt
SET tempRemoteBackupFileName=tempRemote.sql

::My sql Server Data
SET userName= root
SET passward="123"
SEt hostName= 127.0.0.1
SET dbName= teller_rpa

::Other Vars
SET isRemoteBackupDelete=false


set str="%date:/=-%-%time::=-%"

for /f "tokens=1-3 delims= " %%a in ("!str!") do (
set var=%%a%%b%%c
)

::Set Current Date Time
set da=%var%

CD %mysqlFilePath%
ECHO "my sql dump initiated..."


ECHO "coping into the local repository..."
mysqldump.exe -u%userName% -p%passward% -h%hostName% %dbName% > %localFilePath%\%mySqlOriginalBackup%
ECHO "successfully copied to the local repository"

CD %localFilePath%



for /r %localFilePath% %%x in (%localBackupFileName%*.sql) do ren "%%x" %localBackupFileName%



powershell -c "(Get-FileHash -a MD5 '%localBackupFileName%').Hash">%hashFileNameLocal%



CD /d %reomteFilePath%
ECHO "moving to the remote location...%reomteFilePath%"

set /p hashCodeLocalBackup=<%localFilePath%\%hashFileNameLocal%

ECHO "coping into the remote repository..."
:fileLost
copy %localFilePath%\%localBackupFileName% %reomteFilePath%\%tempRemoteBackupFileName%

ECHO "successfully copied into the remote repository."
powershell -c "(Get-FileHash -a MD5 '%tempRemoteBackupFileName%').Hash">%hashFileNameRemote%

set /p hashCodeCopiedBackup=<%hashFileNameRemote%

if "%isRemoteBackupDelete%" EQU "true" (

if "%hashCodeLocalBackup%" EQU "%hashCodeCopiedBackup%" (
ECHO "file verified successfully"


for /r %reomteFilePath% %%x in (%remoteBackupFileName%*.sql) do ren "%%x" %remoteBackupFileName%

del /f %remoteBackupFileName%
REN "%tempRemoteBackupFileName%" "%remoteBackupFileName%-%da%.sql"


CD %localFilePath%
ECHO "move to the local repository"

del /f %localBackupFileName%
ECHO "local dump deleted successfully"


REN "%mySqlOriginalBackup%" "%localBackupFileName%-%da%.sql"

) else if "%hashCodeLocalBackup%" NEQ "%hashCodeCopiedBackup%" (GOTO :fileLost)


) else if "%isRemoteBackupDelete%" NEQ "true" (

if "%hashCodeLocalBackup%" EQU "%hashCodeCopiedBackup%" ( 

ECHO "file verified successfully"
setLocal EnableDelayedExpansion
set strDate="%date:/=-%-%time::=-%"


for /f "tokens=1-3 delims= " %%a in ("!strDate!") do (
set varDate=%%a%%b%%c
)


REN "%tempRemoteBackupFileName%" "%remoteBackupFileName%-!varDate!.sql"

CD /d %localFilePath%
ECHO "move to the local repository"

del /f %localBackupFileName%
ECHO "local dump deleted successfully"

REN "%mySqlOriginalBackup%" "%localBackupFileName%-%da%.sql"
echo !varDate!))



