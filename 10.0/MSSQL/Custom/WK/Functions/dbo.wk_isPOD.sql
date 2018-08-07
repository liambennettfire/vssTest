if exists (select * from dbo.sysobjects where id = object_id(N'dbo.[wk_isPOD]') and OBJECTPROPERTY(id, N'IsScalarFunction') = 1)
drop function dbo.[wk_isPOD]
GO
CREATE FUNCTION [dbo].[wk_isPOD]
    ( @bookkey as int
    ) 
    
RETURNS char(1)


BEGIN 
  DECLARE @RETURN char(1)


Select @RETURN = (CASE WHEN [dbo].[rpt_get_carton_qty](@bookkey, 1) = 'OD' THEN 'Y' ELSE 'N' END)
FROM bookdetail bd
where bd.bookkey = @bookkey

    
RETURN @RETURN

END

