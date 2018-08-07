/****** Object:  View [dbo].[rpt_get_Verification_Type_Code_view]    Script Date: 08/30/2013 16:12:30 ******/
IF  EXISTS (SELECT * FROM sys.views WHERE object_id = OBJECT_ID(N'[dbo].[rpt_get_Verification_Type_Code_view]'))
DROP VIEW [dbo].[rpt_get_Verification_Type_Code_view]
go

Create View rpt_get_Verification_Type_Code_view    
as    
select Datacode    
from gentables    
where tableid = 556    
and qsicode = 3    
GO
GRANT ALL ON rpt_get_Verification_Type_Code_view to PUBLIC
go  