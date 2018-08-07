if exists (select * from dbo.sysobjects where id = object_id(N'dbo.WK_PACE_getFrontMatters') and OBJECTPROPERTY(id, N'IsProcedure') = 1)
drop procedure dbo.WK_PACE_getFrontMatters
GO
CREATE PROCEDURE dbo.WK_PACE_getFrontMatters
AS
/*
ITEMNUMBER	
TMM_FRONTMATTERID	
FRONTMATTER_TYPE	  
FRONTMATTER_TEXT   

*/
BEGIN
Select 
dbo.WK_get_itemnumber_withdashes(bookkey) as ITEMNUMBER,
Cast(bookkey as varchar(20)) + Cast(commenttypesubcode as varchar(2)) as TMM_FRONTMATTERID,
(Case WHEN commenttypesubcode = 52 THEN 'com.lww.pace.domain.frontmatter.TableOfContents'
     WHEN commenttypesubcode = 59 THEN 'com.lww.pace.domain.frontmatter.Foreword'
     WHEN commenttypesubcode = 60 THEN 'com.lww.pace.domain.frontmatter.Contributors'
     WHEN commenttypesubcode = 61 THEN 'com.lww.pace.domain.frontmatter.Preface'
	 END) as FRONTMATTER_TYPE,
commenttext as FRONTMATTER_TEXT
FROM bookcomments
where commenttypecode = 3
and commenttypesubcode in (52,59,60,61)
and commenttext is not null and LEN(Cast(commenttext as varchar(max))) > 0
and dbo.WK_get_itemnumber_withdashes(bookkey) <> ''
END  
