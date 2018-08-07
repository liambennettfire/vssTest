if exists (select * from dbo.sysobjects where id = object_id(N'dbo.[wk_isPrepub]') and OBJECTPROPERTY(id, N'IsScalarFunction') = 1)
drop function dbo.[wk_isPrepub]
GO
CREATE FUNCTION [dbo].[wk_isPrepub]
    ( @bookkey as int
    ) 
    
RETURNS char(1)


BEGIN 
  DECLARE @RETURN char(1)

--Excluded IP Status as per the conversation with Senthil and Angela on 4/15/2010
Select @RETURN = (Case WHEN [dbo].[rpt_get_gentables_field](314, bd.bisacstatuscode, 'E') IN ('ED', 'PR') AND 
[dbo].[rpt_get_best_pub_date](bd.bookkey, 1) <> '' 
AND DateDiff(month, getdate(), [dbo].[rpt_get_best_pub_date](bd.bookkey, 1)) <= 14
AND dbo.qweb_get_BookSubjects(bd.bookkey, 5,0,'D',1) NOT LIKE 'sub%'
THEN  'Y'
ELSE 'N' END)
FROM bookdetail bd
where bd.bookkey = @bookkey

    
  RETURN @RETURN

END

