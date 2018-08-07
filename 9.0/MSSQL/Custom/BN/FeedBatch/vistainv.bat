REM Download and FTP the Daily Investment Books File - 
REM ftp -s:inv-in-ftp.txt 192.168.100.10
REM  7-1-04 now get from qsloution.com 
REM 8-10-04 bn move files to m:\..\feeds\nj_ftp
REM ftp -s:inv-in-ftp-qsi.txt ftp.qsolution.com
REM
copy m:\publishing\pss5\feeds\nj_ftp\YTMUPD1.PRN
del m:\publishing\pss5\feeds\nj_ftp\YTMUPD1.PRN
REM 
REM Now Ftp the file to Investment
ftp -s:inv-out-ftp.txt ftp.fantasticshopping.com

REM Cleanup by moving the nightly files to a folder
copy YTMUPD1.PRN filebackup\YTMUPD1.PRN
REM 9-7-04 keep copy here so in case holiday or whatever it reruns
REM  previous file
REM del YTMUPD1.PRN
