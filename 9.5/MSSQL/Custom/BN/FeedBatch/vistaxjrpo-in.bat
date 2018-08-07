REM Download the Nightly File from New Jersey  this file goes to intel2
REM ftp -s:vistaxjrpop-in-ftp.txt 192.168.100.10
REM  GET FROM QSOLUTION FOR NOW 7-1-04
REM 8-10-04 bn move files to m:\..\feeds\nj_ftp
REM ftp -s:vistaxjrpop-in-ftp-qsi.txt ftp.qsolution.com
REM
copy m:\publishing\pss5\feeds\nj_ftp\xjrpop.prn
del m:\publishing\pss5\feeds\nj_ftp\xjrpop.prn
REM 
REM Call the Initial SQL to prepare for the BCP
isql -SWBCOSPDB -dPSS5 -Uqsidba -Pqsidba -i vistaxjrpop-in-init.sql
REM
REM
REM BCP The Daily File into the Sterling Temporary Title In Table
bcp PSS5..feedin_xjrpop in xjrpop.prn -SWBCOSPDB -Uqsidba -Pqsidba -c -t"|"
REM
REM Call the Main SQL to prepare and run the Feed In Stored Proc 
isql -SWBCOSPDB -dPSS5 -Uqsidba -Pqsidba -i vistaxjrpop-in-main.sql
REM
REM Cleanup by moving the nightly file to a folder
copy xjrpop.prn filebackup\xjrpop.prn
REM del xjrpop.prn



