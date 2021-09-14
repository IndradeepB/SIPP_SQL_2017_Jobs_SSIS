: ====================================
: Variables used in script
: ====================================
: Note: RTIXMLENC requires the caret (^) symbol before brackets to 'escape' them
:
: Removes spacing from the hour segment of the current time, replaces with 0

set "RTIHR="
set "RTIHR=%time:~0,2%"
set "RTIHR=%RTIHR: =0%"

: Date and time formats used in extract
set "RTIDATE=%date:~-4,4%%date:~3,2%%date:~-10,2%"
set "RTIDATETIME=%date:~-4,4%-%date:~3,2%-%date:~-10,2%-%RTIHR%-%time:~3,2%-%time:~6,2%"

: Server details
set "RTISERVER=ormndb198"
set "RTISUBMISSIONSRV=ariesprod02"

: Server paths
set "RTIPATH=\\%RTISERVER%\PROD\RTI"
set "RTISUBPATH=\\%RTISUBMISSIONSRV%\ftpstore$\RTI"

: XML details
: XML filename
set "RTIXMLOUTPUT=%RTIPATH%\LV_FPS_SIPP\LV_FPS_SIPP_%RTIDATETIME%.xml"

: XML version and encoding
set "RTIXMLENC=^<?xml version="1.0" encoding="UTF-8" ?^>"


: ====================================
: SCRIPT EXECUTION
: ====================================

: Remove the previous XML file
del /q %RTIPATH%\FPS.xml

: Execute stored procedure
bcp "exec SIPHAdmin.dbo.usp_RTI_FPS '%RTIDATE% 00:00:01', '%RTIDATE% 23:59:59'" queryout "%RTIPATH%\FPS.xml" -T -w -r -t -S%RTISERVER% || (SET "ErrorLine=BCP" && goto :error)

: Prepend XML encoding declaration to the XML output
echo %RTIXMLENC% > %RTIPATH%\xmlencoding.txt || (SET "ErrorLine=XMLENC" && goto :error)
type %RTIPATH%\xmlencoding.txt %RTIPATH%\FPS.xml > %RTIXMLOUTPUT% || (SET "ErrorLine=CONCAT" && goto :error)

: Copy XML file to submission service
copy %RTIXMLOUTPUT% %RTISUBPATH% || (SET "ErrorLine=COPY" && goto :error)

goto :EOF

:error
echo Failed with error #%errorlevel%. On line %ErrorLine%.
exit /b %errorlevel%

