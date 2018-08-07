 /*** Drop all secondary indexes that currently exist on the coretitleinfo table ***/
IF EXISTS (SELECT * FROM dbo.sysindexes WHERE upper(name) LIKE 'CORETITLEINFO_QS_01')
  BEGIN
	DROP INDEX coretitleinfo.coretitleinfo_qs_01
  END
GO

IF EXISTS (SELECT * FROM dbo.sysindexes WHERE upper(name) LIKE 'CORETITLEINFO_QS_02')
  BEGIN
	DROP INDEX coretitleinfo.coretitleinfo_qs_02
  END
GO

IF EXISTS (SELECT * FROM dbo.sysindexes WHERE upper(name) LIKE 'CORETITLEINFO_QS_03')
  BEGIN
	DROP INDEX coretitleinfo.coretitleinfo_qs_03
  END
GO

IF EXISTS (SELECT * FROM dbo.sysindexes WHERE upper(name) LIKE 'CORETITLEINFO_QS_04')
  BEGIN
	DROP INDEX coretitleinfo.coretitleinfo_qs_04
  END
GO

IF EXISTS (SELECT * FROM dbo.sysindexes WHERE upper(name) LIKE 'CORETITLEINFO_QS_05')
  BEGIN
	DROP INDEX coretitleinfo.coretitleinfo_qs_05
  END
GO

IF EXISTS (SELECT * FROM dbo.sysindexes WHERE upper(name) LIKE 'CORETITLEINFO_QS_06')
  BEGIN
	DROP INDEX coretitleinfo.coretitleinfo_qs_06
  END
GO

IF EXISTS (SELECT * FROM dbo.sysindexes WHERE upper(name) LIKE 'CORETITLEINFO_QS_07')
  BEGIN
	DROP INDEX coretitleinfo.coretitleinfo_qs_07
  END
GO

IF EXISTS (SELECT * FROM dbo.sysindexes WHERE upper(name) LIKE 'CORETITLEINFO_QS_08')
  BEGIN
	DROP INDEX coretitleinfo.coretitleinfo_qs_08
  END
GO

IF EXISTS (SELECT * FROM dbo.sysindexes WHERE upper(name) LIKE 'CORETITLEINFO_QS_09')
  BEGIN
	DROP INDEX coretitleinfo.coretitleinfo_qs_09
  END
GO

IF EXISTS (SELECT * FROM dbo.sysindexes WHERE upper(name) LIKE 'CORETITLEINFO_QS_10')
  BEGIN
	DROP INDEX coretitleinfo.coretitleinfo_qs_10
  END
GO

IF EXISTS (SELECT * FROM dbo.sysindexes WHERE upper(name) LIKE 'CORETITLEINFO_QS_11')
  BEGIN
	DROP INDEX coretitleinfo.coretitleinfo_qs_11
  END
GO

IF EXISTS (SELECT * FROM dbo.sysindexes WHERE upper(name) LIKE 'CORETITLEINFO_QS_12')
  BEGIN
	DROP INDEX coretitleinfo.coretitleinfo_qs_12
  END
GO

IF EXISTS (SELECT * FROM dbo.sysindexes WHERE upper(name) LIKE 'CORETITLEINFO_QS_13')
  BEGIN
	DROP INDEX coretitleinfo.coretitleinfo_qs_13
  END
GO

IF EXISTS (SELECT * FROM dbo.sysindexes WHERE upper(name) LIKE 'CORETITLEINFO_QS_14')
  BEGIN
	DROP INDEX coretitleinfo.coretitleinfo_qs_14
  END
GO

IF EXISTS (SELECT * FROM dbo.sysindexes WHERE upper(name) LIKE 'CORETITLEINFO_QS_15')
  BEGIN
	DROP INDEX coretitleinfo.coretitleinfo_qs_15
  END
GO

IF EXISTS (SELECT * FROM dbo.sysindexes WHERE upper(name) LIKE 'CORETITLEINFO_QS_16')
  BEGIN
	DROP INDEX coretitleinfo.coretitleinfo_qs_16
  END
GO

IF EXISTS (SELECT * FROM dbo.sysindexes WHERE upper(name) LIKE 'CORETITLEINFO_QS_17')
  BEGIN
	DROP INDEX coretitleinfo.coretitleinfo_qs_17
  END
GO

IF EXISTS (SELECT * FROM dbo.sysindexes WHERE upper(name) LIKE 'CORETITLEINFO_QS_18')
  BEGIN
	DROP INDEX coretitleinfo.coretitleinfo_qs_18
  END
GO

IF EXISTS (SELECT * FROM dbo.sysindexes WHERE upper(name) LIKE 'CORETITLEINFO_QS_19')
  BEGIN
	DROP INDEX coretitleinfo.coretitleinfo_qs_19
  END
GO

IF EXISTS (SELECT * FROM dbo.sysindexes WHERE upper(name) LIKE 'CORETITLEINFO_QS_20')
  BEGIN
	DROP INDEX coretitleinfo.coretitleinfo_qs_20
  END
GO

IF EXISTS (SELECT * FROM dbo.sysindexes WHERE upper(name) LIKE 'CORETITLEINFO_QS_21')
  BEGIN
	DROP INDEX coretitleinfo.coretitleinfo_qs_21
  END
GO  

IF EXISTS (SELECT * FROM dbo.sysindexes WHERE upper(name) LIKE 'CORETITLEINFO_QS_22')
  BEGIN
	DROP INDEX coretitleinfo.coretitleinfo_qs_22
  END
GO  

IF EXISTS (SELECT * FROM dbo.sysindexes WHERE upper(name) LIKE 'CORETITLEINFO_QS_23')
  BEGIN
	DROP INDEX coretitleinfo.coretitleinfo_qs_23
  END
GO  

IF EXISTS (SELECT * FROM dbo.sysindexes WHERE upper(name) LIKE 'CORETITLEINFO_QS_24')
  BEGIN
	DROP INDEX coretitleinfo.coretitleinfo_qs_24
  END
GO  
