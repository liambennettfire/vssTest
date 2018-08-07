REM Download the Nightly File from 
REM ftp -s:cispubtmm-in-ftp.txt ip address here

REM Call the INIT to truncate table
isql -SPSS5 -dPSS5 -Uqsidba -Pqsidba -i cispubtmm-in-init.sql

REM BCP The Daily File into the UOC Temporary Title In Table
bcp PSS5..feedin_titles in DGMPM_QSI_1_2_22.TXT -SPSS5 -Uqsidba -Pqsidba -c -t"	"


REM Call the Main SQL to prepare and run the Feed In Stored Proc
isql -SPSS5 -dPSS5 -Uqsidba -Pqsidba -i cispubtmm-in-main.sql

REM Cleanup by moving the nightly file to a folder
REM copy filename filebackup\
REM del filename

