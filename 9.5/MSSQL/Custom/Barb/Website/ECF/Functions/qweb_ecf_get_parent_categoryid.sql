SET QUOTED_IDENTIFIER ON 
GO
SET ANSI_NULLS ON 
GO

if exists (select * from dbo.sysobjects where id = object_id(N'[dbo].[qweb_ecf_get_parent_categoryid]') and xtype in (N'FN', N'IF', N'TF'))
drop function [dbo].[qweb_ecf_get_parent_categoryid]
GO




CREATE FUNCTION dbo.qweb_ecf_get_parent_categoryid
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




GO
SET QUOTED_IDENTIFIER OFF 
GO
SET ANSI_NULLS ON 
GO

