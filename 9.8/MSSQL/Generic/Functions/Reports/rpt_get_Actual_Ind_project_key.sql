if exists (select * from dbo.sysobjects where id = object_id(N'rpt_get_Actual_Ind_project_key') and OBJECTPROPERTY(id, N'IsScalarFunction') = 1)
drop function dbo.rpt_get_Actual_Ind_project_key 
GO
CREATE FUNCTION [dbo].[rpt_get_Actual_Ind_project_key](@i_taqprojectkey int,@i_Date_type_Code int)    
Returns int    
AS    
BEGIN    
Declare @Return int    
Declare @i_Actual_ind int    
 Select @i_Actual_ind= ISNULL(Actualind,0) from taqprojecttask where taqprojectkey=@i_taqprojectkey and datetypecode= @i_Date_Type_Code    
 Select @Return=@i_Actual_ind     
 Return @Return    
END 
GO
GRANT EXECUTE ON dbo.rpt_get_Actual_Ind_project_key TO PUBLIC
GO