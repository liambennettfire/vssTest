 
/****** Object:  UserDefinedFunction [dbo].[rpt_get_contact_primary_address3]    Script Date: 08/06/2015 12:25:31 ******/
IF  EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[rpt_get_contact_primary_address3]') AND type in (N'FN', N'IF', N'TF', N'FS', N'FT'))
DROP FUNCTION [dbo].[rpt_get_contact_primary_address3]
GO
 

/****** Object:  UserDefinedFunction [dbo].[rpt_get_contact_primary_address3]    Script Date: 08/06/2015 12:25:31 ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO

  
CREATE FUNCTION [dbo].[rpt_get_contact_primary_address3] (@i_globalcontactkey INT)  
 RETURNS VARCHAR(255)  
AS  
BEGIN  
 DECLARE @RETURN   VARCHAR(255)  
  
 Select @RETURN =  address3  
   from globalcontactaddress  
  where  primaryind = 1 and
  globalcontactkey = @i_globalcontactkey  
   RETURN @RETURN  
END  
GO

sp_refreshview 'dbo.rpt_contact_view'
