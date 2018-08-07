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
