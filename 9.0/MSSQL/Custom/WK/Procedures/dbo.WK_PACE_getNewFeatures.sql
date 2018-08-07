if exists (select * from dbo.sysobjects where id = object_id(N'dbo.WK_PACE_getNewFeatures') and OBJECTPROPERTY(id, N'IsProcedure') = 1)
drop procedure dbo.WK_PACE_getNewFeatures
GO
CREATE PROCEDURE dbo.WK_PACE_getNewFeatures
AS
/*
ITEMNUMBER	
TMM_NEWFEATUREID	
DISPLAYSEQUENCE	
FEATURE TEXT
   

SELECT * FROM WK_ORA.WKDBA.NEW_FEATURE

Select * FROM bookcomments
WHERE commenttypecode = 3 and commenttypesubcode = 58
and commenttext is not null and LEN(Cast(commenttext as varchar(max))) > 0


*/
BEGIN
SELECT
dbo.WK_get_itemnumber_withdashes(bookkey) as ITEMNUMBER,
Cast(bookkey as varchar(20)) + Cast(commenttypesubcode as varchar(2)) as TMM_NEWFEATUREID,
1 as DISPLAYSEQUENCE,
commenttext as NEWFEATURE_TEXT
FROM bookcomments
WHERE commenttypecode = 3 and commenttypesubcode = 58
and commenttext is not null and LEN(Cast(commenttext as varchar(max))) > 0
and dbo.WK_get_itemnumber_withdashes(bookkey) <> ''

END 
