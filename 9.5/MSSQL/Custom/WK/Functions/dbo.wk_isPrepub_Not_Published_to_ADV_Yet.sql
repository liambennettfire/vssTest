if exists (select * from dbo.sysobjects where id = object_id(N'dbo.[wk_isPrepub_Not_Published_to_ADV_Yet]') and OBJECTPROPERTY(id, N'IsScalarFunction') = 1)
drop function dbo.[wk_isPrepub_Not_Published_to_ADV_Yet]
GO
CREATE FUNCTION [dbo].[wk_isPrepub_Not_Published_to_ADV_Yet]
    ( @bookkey as int
    ) 
    
RETURNS char(1)


BEGIN 
  DECLARE @RETURN char(1)

--Excluded IP status as per the conversation with Angela on 4/15
Select @RETURN = (Case WHEN [dbo].[rpt_get_gentables_field](314, bd.bisacstatuscode, 'E') IN ('ED', 'PR') AND 
[dbo].[rpt_get_best_pub_date](bd.bookkey, 1) <> '' 
AND DateDiff(month, getdate(), [dbo].[rpt_get_best_pub_date](bd.bookkey, 1)) <= 14
AND DateDiff(month, getdate(), [dbo].[rpt_get_best_pub_date](bd.bookkey, 1)) > 0
AND dbo.qweb_get_BookSubjects(bd.bookkey, 5,0,'D',1) NOT LIKE 'sub%'
THEN  'Y'
ELSE 'N' END)
FROM bookdetail bd
where bd.bookkey = @bookkey
--Added on 7/09, if CSI Request Id (ADV/SLX) has not been assigned  then
--this title has not been sent to Advantage yet
AND ([dbo].[rpt_get_misc_value](bd.bookkey, 29, 'long') IS NULL 
OR [dbo].[rpt_get_misc_value](bd.bookkey, 29, 'long') = '')

    
  RETURN @RETURN

END

