if exists (select * from dbo.sysobjects where id = object_id(N'dbo.rpt_Get_Production_Spec_Quantity') and xtype in (N'FN', N'IF', N'TF'))
  drop function dbo.rpt_Get_Production_Spec_Quantity
GO

CREATE FUNCTION [dbo].[rpt_Get_Production_Spec_Quantity](@i_Taqprojectkey int, @i_item_Category_Code int,@i_Item_Code int,@i_plstagecode int, @i_versionkey int)  
Returns varchar(50)  
AS  
BEGIN  
Declare @Return varchar(50)  
Declare @_Quantity varchar (50)
Select @_Quantity=quantity from qproject_get_specitems_by_printing(0)  
where taqprojectkey=@i_Taqprojectkey and itemcategorycode=@i_item_Category_Code and itemcode=@i_Item_Code and plstagecode= @i_plstagecode and taqversionkey=@i_versionkey
Select @Return=@_Quantity  
Return @Return  
END  
go

Grant execute on dbo.rpt_Get_Production_Spec_Quantity to Public
go