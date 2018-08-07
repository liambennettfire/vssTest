 
/****** Object:  View [dbo].[DUP_get_all_shipping_methods]    Script Date: 08/06/2015 13:52:53 ******/
IF  EXISTS (SELECT * FROM sys.views WHERE object_id = OBJECT_ID(N'[dbo].[DUP_get_all_shipping_methods]'))
DROP VIEW [dbo].[DUP_get_all_shipping_methods]
GO
 

/****** Object:  View [dbo].[DUP_get_all_shipping_methods]    Script Date: 08/06/2015 13:52:53 ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO



CREATE VIEW [dbo].[DUP_get_all_shipping_methods] 
	(datadesc, datasubcode)
AS 
select datadesc, datasubcode
from subgentables
where tableid=525
	and datacode=107
union 
select 'All', 0


GO


