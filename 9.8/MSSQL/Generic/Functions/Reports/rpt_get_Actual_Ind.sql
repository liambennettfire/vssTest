
GO

/****** Object:  UserDefinedFunction [dbo].[rpt_get_Actual_Ind]    Script Date: 08/26/2015 10:09:03 ******/
IF  EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[rpt_get_Actual_Ind]') AND type in (N'FN', N'IF', N'TF', N'FS', N'FT'))
DROP FUNCTION [dbo].[rpt_get_Actual_Ind]
GO


GO

/****** Object:  UserDefinedFunction [dbo].[rpt_get_Actual_Ind]    Script Date: 08/26/2015 10:09:03 ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO

CREATE FUNCTION [dbo].[rpt_get_Actual_Ind](@i_bookkey int,@i_Date_type_Code int)    
Returns int    
AS    
BEGIN    
Declare @Return int    
Declare @i_Actual_ind int    
 Select @i_Actual_ind= ISNULL(Actualind,0) from taqprojecttask where bookkey=@i_bookkey and datetypecode= @i_Date_Type_Code    
 Select @Return=@i_Actual_ind     
 Return @Return    
END 

GO


Grant all on rpt_get_Actual_Ind to public