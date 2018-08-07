if exists (select * from dbo.sysobjects where id = object_id(N'dbo.wk_isEligibleforLWW') and OBJECTPROPERTY(id, N'IsScalarFunction') = 1)
drop function dbo.wk_isEligibleforLWW
GO
CREATE FUNCTION dbo.wk_isEligibleforLWW
    ( @bookkey as int
    ) 
    
RETURNS char(1)


BEGIN 
  DECLARE @RETURN char(1)


Select @RETURN = (Case WHEN publishtowebind = 1 AND [dbo].[rpt_get_gentables_field](314, bd.bisacstatuscode, 'E') NOT IN ('OP', 'CA', 'DS', 'RO') THEN  'Y'
ELSE 'N' END)
FROM bookdetail bd
where bd.bookkey = @bookkey
   
RETURN @RETURN

END

