REM Download the Nightly File from New Jersey
REM ftp -s:vista-in-ftp.txt 192.168.100.10
REM  get from qsolution for now 7-1-04
REM 8-10-04 bn move files to m:\..\feeds\nj_ftp
REM ftp -s:vista-in-ftp-qsi.txt ftp.qsolution.com
REM
copy m:\publishing\pss5\feeds\nj_ftp\ytmupd.prn
del m:\publishing\pss5\feeds\nj_ftp\ytmupd.prn
REM
REM Call the Initial SQL to prepare for the BCP
isql -SWBCOSPDB -dPSS5 -Uqsidba -Pqsidba -i vista-in-init.sql
REM
REM
REM BCP The Daily File into the Sterling Temporary Title In Table
bcp PSS5..feedin_titles in ytmupd.prn -SWBCOSPDB -Uqsidba -Pqsidba -c -t"|"
REM
REM Call the Main SQL to prepare and run the Feed In Stored Proc
isql -SWBCOSPDB -dPSS5 -Uqsidba -Pqsidba -i vista-in-main.sql
REM Cleanup by moving the nightly file to a folder
copy ytmupd.prn filebackup\ytmupd.prn
del ytmupd.prn