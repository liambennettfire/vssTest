if exists (select * from dbo.sysobjects where id = object_id(N'dbo.rpt_Get_Summary_Spec_Item') and xtype in (N'FN', N'IF', N'TF'))
  drop function dbo.rpt_Get_Summary_Spec_Item
GO

CREATE FUNCTION [dbo].[rpt_Get_Summary_Spec_Item](@i_Taqprojectkey int, @i_item_Category_Code int,@i_Item_Code int)
Returns int
AS
BEGIN
Declare @Return int
Declare @i_itemDetailCode int
Select @i_itemDetailCode=itemdetailcode from qproject_get_specitems_by_printing(0)
where taqprojectkey=@i_Taqprojectkey and itemcategorycode=@i_item_Category_Code and itemcode=@i_Item_Code
Select @Return=@i_itemDetailCode
Return @Return
END
go

Grant execute on dbo.rpt_Get_Summary_Spec_Item to Public
go