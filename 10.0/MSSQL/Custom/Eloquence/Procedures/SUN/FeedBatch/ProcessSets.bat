

call set_connection.bat

osql -U%userid% -P%password% -S%server% -d%database%  -iprocesssetproc.sql

ConvertXLS.EXE /JC:\temp\convert_sets_to_xls.SII

pause