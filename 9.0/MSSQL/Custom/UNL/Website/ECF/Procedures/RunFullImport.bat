call set_connection.bat

SQLCMD -U%userid% -P%password% -S%server% -d%database% -i99_RUN_FULL_IMPORT.sql >>import.log