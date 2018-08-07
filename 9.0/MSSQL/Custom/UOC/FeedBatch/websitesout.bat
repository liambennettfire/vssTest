REM 4-29-04  RUN WEB SITE EXPORTS

REM THIS FILE SHOULD BE RUN USING 
REM websitesout_monthly.bat TO CREATE LOG FILE


REM create html bookcommenthtml table from scratch
isql -SPSS5 -dPSS5 -Uqsidba -Pqsidba -i bookcommenthtml.sql


REM CREATE TITLE.SGM FILE
isql -SPSS5 -dPSS5 -Uqsidba -Pqsidba -i web_title.sql

REM BCP out of the PSS5 Temporary Web Title out Table
bcp "select feedtext from PSS5..webbookxmlfeed order by seqnum" queryout title.sgm -SPSS5 -Uqsidba -Pqsidba -c

REM ftp to qsolution.com as a test
ftp -s:webtitle-ftp.txt ftp.qsolution.com

REM  

REM CREATE SERIES FILE
isql -SPSS5 -dPSS5 -Uqsidba -Pqsidba -i web_series.sql

REM BCP The Daily File out of the PSS5 Temporary Title out Table
bcp "select feedtext from PSS5..webseriesidxfeed order by seqnum" queryout SERIES.IDX -SPSS5 -Uqsidba -Pqsidba -c

REM BCP The Daily File out of the PSS5 Temporary Title out Table
bcp "select feedtext from PSS5..webserieshtmfeed order by seqnum" queryout SER.HTM -SPSS5 -Uqsidba -Pqsidba -c

REM  these files will already be on the sever directory so just need to ftp
REM BCP The Daily File out of the PSS5 Temporary Title out Table
REM bcp "select feedtext from PSS5..webseriesfeed order by seqnum" queryout SER2.HTM -SPSS5 -Uqsidba -Pqsidba -c

REM ftp to qsolution.com as a test
ftp -s:webseries-ftp.txt ftp.qsolution.com

REM DELETE all htm files -- so have room for subjects next
del *.htm
del series.idx

REM

REM CREATE SUBJECT FILE
isql -SPSS5 -dPSS5 -Uqsidba -Pqsidba -i web_subject.sql

REM BCP The Daily File out of the PSS5 Temporary Title out Table
bcp "select feedtext from PSS5..websubjectidxfeed order by seqnum" queryout SUBJECT.IDX -SPSS5 -Uqsidba -Pqsidba -c

REM BCP The Daily File out of the PSS5 Temporary Title out Table
bcp "select feedtext from PSS5..websubjecthtmfeed order by seqnum" queryout SUBJECT.HTM -SPSS5 -Uqsidba -Pqsidba -c

REM  these files will already be on the sever directory so just need to ftp
REM BCP The Daily File out of the PSS5 Temporary Title out Table
REM bcp "select feedtext from PSS5..websubjectfeed order by seqnum" queryout SUBJECT2.HTM -SPSS5 -Uqsidba -Pqsidba -c

REM ftp to qsolution.com as a test
ftp -s:websubjects-ftp.txt ftp.qsolution.com

REM DELETE all htm files -- so have room for catalogs next
del *.htm
del subject.idx

REM

REM CREATE SUBJECT FILE
isql -SPSS5 -dPSS5 -Uqsidba -Pqsidba -i web_catalog.sql

REM  these files will already be on the sever directory so just need to ftp
REM BCP The Daily File out of the PSS5 Temporary Title out Table
REM bcp "select feedtext from PSS5..webvirtcatfeed order by seqnum" queryout CATALOGS.HTML -SPSS5 -Uqsidba -Pqsidba -c

REM ftp to qsolution.com as a test
ftp -s:webcatalog-ftp.txt ftp.qsolution.com

REM DELETE all html files -- cleanup
del *.html
del title.sgm

exit