if exists (select * from dbo.sysobjects where id = object_id(N'[dbo].[v_BuiltInFunctions]') and OBJECTPROPERTY(id, N'IsView') = 1)
  drop view [dbo].[v_BuiltInFunctions]
GO

CREATE VIEW v_BuiltInFunctions As
	SELECT GetUTCDate() as GMTTime, GetDate() as LocalTime, TimeDiff = DateDiff(minute, GetUTCDate(), GetDate())
