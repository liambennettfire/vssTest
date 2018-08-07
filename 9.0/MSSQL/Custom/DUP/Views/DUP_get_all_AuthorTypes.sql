
/****** Object:  View [dbo].[DUP_get_all_AuthorTypes]    Script Date: 10/09/2015 10:32:22 ******/
IF  EXISTS (SELECT * FROM sys.views WHERE object_id = OBJECT_ID(N'[dbo].[DUP_get_all_AuthorTypes]'))
DROP VIEW [dbo].[DUP_get_all_AuthorTypes]
GO


/****** Object:  View [dbo].[DUP_get_all_AuthorTypes]    Script Date: 10/09/2015 10:32:22 ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO

  
  
CREATE VIEW [dbo].[DUP_get_all_AuthorTypes]   
 (datadesc, datasubcode)  
AS   
select datadesc, datacode  
from gentables  
where tableid=134  and ISNULL(deletestatus,'N') = 'N'
-- select * from gentables where tableid=134
union   
select 'All', 0  


GO


