if exists (select * from dbo.sysobjects where id = object_id(N'[dbo].qweb_ecf_get_Category_ID') and xtype in (N'FN', N'IF', N'TF'))
drop function [dbo].qweb_ecf_get_Category_ID
GO


create function qweb_ecf_get_Category_ID (@CatName varchar(50))

RETURNS int
as

begin

DECLARE @RETURN int


Select @RETURN = Categoryid
from category
where Name = @CatName


RETURN @RETURN
end