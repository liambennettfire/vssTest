call set_connection.bat


echo creating and loading temp table with all 2006 bisac codes and descriptions 

osql -U%userid% -P%password% -S%server% -d%database% -itemp_sgt_bisaccodes_2006_mss.sql -otemp_sgt_bisaccodes_2006_mss.txt
osql -U%userid% -P%password% -S%server% -d%database% -itemp_inactivecodes_2006_mss.sql -otemp_inactivecodes_2006_mss.txt
rem osql -U%userid% -P%password% -S%server% -d%database% -itemp_sgt_bisaccodes_2006_nocodes_mss.sql -otemp_sgt_bisaccodes_2006_nocodes_mss.txt

echo updating data descriptions in user tables

osql -U%userid% -P%password% -S%server% -d%database% -iupdexisting_2006_mss.sql -oupdexisting_2006_mss.txt

echo inserting new\missing values

osql -U%userid% -P%password% -S%server% -d%database% -iinsertmissing_sgt_2006_mss.sql -oinsertmissing_sgt_2006_mss.txt
rem osql -U%userid% -P%password% -S%server% -d%database% -iinsertmissing_sgt_2006_nocodes_mss.sql -oinsertmissing_sgt_2006_nocodes_mss.txt

echo cleaning up descriptions

osql -U%userid% -P%password% -S%server% -d%database% -icode_update_2006_mss.sql -ocode_update_2006_mss.txt

echo deactivating codes

osql -U%userid% -P%password% -S%server% -d%database% -isetinactive_2006_mss.sql -osetinactive_2006_mss.txt

echo deleting codes

osql -U%userid% -P%password% -S%server% -d%database% -idelete_sgt_2006_mss.sql -odelete_sgt_2006_mss.txt

echo done



