IF  EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[rpt_get_min_work_projectkey]') AND type in (N'FN', N'IF', N'TF', N'FS', N'FT'))
DROP FUNCTION [dbo].[rpt_get_min_work_projectkey]
GO


Create function [dbo].[rpt_get_min_work_projectkey](@i_Contractprojectkey int)  
Returns int  
as  
BEGIN  
Declare @return int  
Declare @_min_work_projectkey int  
Select @_min_work_projectkey=Min(taqprojectkey) from taqprojecttitle where taqprojectkey   
in(Select workprojectkey from dbo.qcontract_contractstitlesinfo(@i_Contractprojectkey))  
and primaryformatind=1  
Select @return=@_min_work_projectkey  
Return @return  
  
END  
Go
Grant all on rpt_get_min_work_projectkey to public  