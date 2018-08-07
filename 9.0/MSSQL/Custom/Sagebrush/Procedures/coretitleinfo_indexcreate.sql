/*** Create all necessary secondary indexes on the coretitleinfo table ***/
IF NOT EXISTS (SELECT * FROM dbo.sysindexes WHERE upper(name) LIKE 'CORETITLEINFO_QS_01')
  BEGIN
	CREATE INDEX coretitleinfo_qs_01 ON coretitleinfo (title)
  END
GO

IF NOT EXISTS (SELECT * FROM dbo.sysindexes WHERE upper(name) LIKE 'CORETITLEINFO_QS_02')
  BEGIN
	CREATE INDEX coretitleinfo_qs_02 ON coretitleinfo (productnumberx)
  END
GO

IF NOT EXISTS (SELECT * FROM dbo.sysindexes WHERE upper(name) LIKE 'CORETITLEINFO_QS_03')
  BEGIN
	CREATE INDEX coretitleinfo_qs_03 ON coretitleinfo (workkey)
  END
GO

IF NOT EXISTS (SELECT * FROM dbo.sysindexes WHERE upper(name) LIKE 'CORETITLEINFO_QS_04')
  BEGIN
	CREATE INDEX coretitleinfo_qs_04 ON coretitleinfo (bisacstatuscode)
  END
GO

IF NOT EXISTS (SELECT * FROM dbo.sysindexes WHERE upper(name) LIKE 'CORETITLEINFO_QS_05')
  BEGIN
	CREATE INDEX coretitleinfo_qs_05 ON coretitleinfo (titlestatuscode)
  END
GO

IF NOT EXISTS (SELECT * FROM dbo.sysindexes WHERE upper(name) LIKE 'CORETITLEINFO_QS_06')
  BEGIN
	CREATE INDEX coretitleinfo_qs_06 ON coretitleinfo (titletypecode)
  END
GO

IF NOT EXISTS (SELECT * FROM dbo.sysindexes WHERE upper(name) LIKE 'CORETITLEINFO_QS_07')
  BEGIN
	CREATE INDEX coretitleinfo_qs_07 ON coretitleinfo (seriescode)
  END
GO

IF NOT EXISTS (SELECT * FROM dbo.sysindexes WHERE upper(name) LIKE 'CORETITLEINFO_QS_08')
  BEGIN
	CREATE INDEX coretitleinfo_qs_08 ON coretitleinfo (mediatypecode)
  END
GO

IF NOT EXISTS (SELECT * FROM dbo.sysindexes WHERE upper(name) LIKE 'CORETITLEINFO_QS_09')
  BEGIN
	CREATE INDEX coretitleinfo_qs_09 ON coretitleinfo (mediatypecode, mediatypesubcode)
  END
GO

IF NOT EXISTS (SELECT * FROM dbo.sysindexes WHERE upper(name) LIKE 'CORETITLEINFO_QS_10')
  BEGIN
	CREATE INDEX coretitleinfo_qs_10 ON coretitleinfo (formatchildcode)
  END
GO

IF NOT EXISTS (SELECT * FROM dbo.sysindexes WHERE upper(name) LIKE 'CORETITLEINFO_QS_11')
  BEGIN
	CREATE INDEX coretitleinfo_qs_11 ON coretitleinfo (seasonkey)
  END
GO

IF NOT EXISTS (SELECT * FROM dbo.sysindexes WHERE upper(name) LIKE 'CORETITLEINFO_QS_12')
  BEGIN
	CREATE INDEX coretitleinfo_qs_12 ON coretitleinfo (estseasonkey)
  END
GO

IF NOT EXISTS (SELECT * FROM dbo.sysindexes WHERE upper(name) LIKE 'CORETITLEINFO_QS_13')
  BEGIN
	CREATE INDEX coretitleinfo_qs_13 ON coretitleinfo (bestseasonkey)
  END
GO
