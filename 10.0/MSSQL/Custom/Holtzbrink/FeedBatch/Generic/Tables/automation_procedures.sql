master..sp_configure 'show advanced options', 1;
GO
RECONFIGURE;
GO
master..sp_configure 'Ole Automation Procedures', 1;
GO
RECONFIGURE
GO
print 'RECONFIGURE completed - Ole Automation Procedures installed.'