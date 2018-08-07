IF  EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[DUP_Get_IndivContact_Groupname]') AND type in (N'FN', N'IF', N'TF', N'FS', N'FT'))
DROP FUNCTION [dbo].DUP_Get_IndivContact_Groupname
GO


SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO



CREATE FUNCTION [dbo].[DUP_Get_IndivContact_Groupname]
	( @i_globalcontactkey int)
RETURNS VARCHAR(8000)

AS  BEGIN
	DECLARE @RETURN       		VARCHAR(8000)
	
select @RETURN=gc.groupname 
from globalcontactrelationship gcr 
inner join globalcontact gc on gc.globalcontactkey=gcr.globalcontactkey2
where gcr.globalcontactkey1 =@i_globalcontactkey
	and gcr.contactrelationshipcode1=20
 
 RETURN @RETURN

END


GO