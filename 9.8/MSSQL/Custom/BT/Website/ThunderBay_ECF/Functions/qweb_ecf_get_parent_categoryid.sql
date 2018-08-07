USE [BT_TB_ECF]
GO
/****** Object:  UserDefinedFunction [dbo].[qweb_ecf_get_parent_categoryid]    Script Date: 01/27/2010 16:53:48 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO




ALTER FUNCTION [dbo].[qweb_ecf_get_parent_categoryid]
		(@i_categoryid	INT)

RETURNS int

AS

begin

  DECLARE @RETURN int


  Select @RETURN = COALESCE(parentcategoryid,0)
  from category
  where categoryid = @i_categoryid


  RETURN @RETURN


END




