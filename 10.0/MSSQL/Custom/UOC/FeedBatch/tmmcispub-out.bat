REM Call the Main SQL to prepare and run the Feed Out Stored Proc
osql -SPSS5 -dPSS5 -Uqsidba -Pqsidba -i tmmcispub-out-main.sql

del tmmtocispub_title*.txt
del tmmtocispub_auth*.txt
del tmmtocispub_subj*.txt


REM BCP The Daily File out of the UOC Temporary Title now has datetime stamp
REM run in this SQL instead
osql -SPSS5 -dPSS5 -Uqsidba -Pqsidba -i tmmcispub-out-bcp.sql

REM ftp to qsolution.com as a test
ftp -s:tmmcispub-out-ftp.txt ftp.qsolution.com




