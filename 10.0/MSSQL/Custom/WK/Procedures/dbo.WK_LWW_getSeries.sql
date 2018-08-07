if exists (select * from dbo.sysobjects where id = object_id(N'dbo.WK_LWW_getSeries') and OBJECTPROPERTY(id, N'IsProcedure') = 1)
  drop procedure dbo.WK_LWW_getSeries
GO
CREATE PROCEDURE dbo.WK_LWW_getSeries

AS
/*

  Column	DataType
  SERIES_ID	NUMBER(15) NOT NULL
  SERIES_TITLE	VARCHAR2(250 BYTE)
  SERIES_SUBTITLE	VARCHAR2(225 BYTE)
  LEAD_AUTHOR_LINE	VARCHAR2(1000 BYTE)
  SERIES_DESCRIPTION	VARCHAR2(3500 BYTE)


select SERIES_ID, SERIES_TITLE, SERIES_SUBTITLE, LEAD_AUTHOR_LINE, LEN(SERIES_DESCRIPTION)
from wk_ora.wkdba.series;

Select * FROM wk_series
ORDER BY Series_ID
GO
Select * FROM wk_ora.wkdba.Series
ORDER By Series_ID

*/

BEGIN

Select 
datacode as SERIES_ID,
alternatedesc1 SERIES_TITLE,
s.SERIES_SUBTITLE as SERIES_SUBTITLE,
s.LEAD_AUTHOR_LINE as LEAD_AUTHOR_LINE,
s.SERIES_DESCRIPTION as SERIES_DESCRIPTION
FROM gentables g
JOIN dbo.WK_Series s
ON g.alternatedesc1 = s.SERIES_TITLE
where g.tableid = 327

END

