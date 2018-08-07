call set_connection.bat

SQLCMD -U%userid% -P%password% -S%server% -d%database% -i99_RUN_INCR_IMPORT.sql >>import.log