/****** Object:  UserDefinedFunction [dbo].[rpt_taq_pl_advance_by_year]    Script Date: 06/08/2012 10:32:38 ******/
IF  EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[rpt_taq_pl_advance_by_year]') AND type in (N'FN', N'IF', N'TF', N'FS', N'FT'))
DROP FUNCTION [dbo].[rpt_taq_pl_advance_by_year]
GO



/****** Object:  UserDefinedFunction [dbo].[rpt_taq_pl_advance_by_year]    Script Date: 06/08/2012 10:32:38 ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO

Create FUNCTION [dbo].[rpt_taq_pl_advance_by_year]  
   (@i_taqprojectkey int, @i_plstage int, @i_taqversionkey int, @i_yearcode int)  
      
RETURNS FLOAT  
  
BEGIN   
  
DECLARE @v_royalty_advance float  
    
  SELECT @v_royalty_advance = SUM(amount)   
  FROM taqversionroyaltyadvance   
  WHERE taqprojectkey = @i_taqprojectkey AND  
    plstagecode = @i_plstage AND  
    taqversionkey = @i_taqversionkey AND  
    yearcode = @i_yearcode  
   
RETURN @v_royalty_advance  
    
END  
  
  


GO

GRANT ALL ON rpt_taq_pl_advance_by_year TO PUBLIC


