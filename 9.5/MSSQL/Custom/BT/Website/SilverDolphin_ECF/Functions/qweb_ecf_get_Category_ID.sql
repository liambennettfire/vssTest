USE [BT_SD_ECF]
GO
/****** Object:  UserDefinedFunction [dbo].[qweb_ecf_get_Category_ID]    Script Date: 01/27/2010 16:29:53 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER OFF
GO


ALTER function [dbo].[qweb_ecf_get_Category_ID] (@CatName varchar(50))

RETURNS int
as

begin

DECLARE @RETURN int


Select @RETURN = COALESCE(Categoryid,0)
from category
where Name = @CatName


RETURN @RETURN
end
