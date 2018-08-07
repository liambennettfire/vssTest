IF  EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[BIC_to_BISAC_conversion]') AND type in (N'P', N'PC'))
DROP PROCEDURE [dbo].[BIC_to_BISAC_conversion]

SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

CREATE PROCEDURE [dbo].[BIC_to_BISAC_conversion] 
  @i_BIC_code varchar(20),
  @o_BISAC_code_1 varchar(20) output,
  @o_BISAC_desc_1 varchar(255) output,
  @o_BISAC_code_2 varchar(20) output,
  @o_BISAC_desc_2 varchar(255) output,
  @o_BISAC_code_3 varchar(20) output,
  @o_BISAC_desc_3 varchar(255) output
    
AS

DECLARE
  @v_count int,
  @v_Multiple_Headings varchar(20)

BEGIN
  SELECT @v_count=count(*)
    from BIC_BISAC_MAPPING
    where BIC_code=@i_BIC_code
    
  if @v_count=1
    begin
    
      SELECT 
          @o_BISAC_code_1=BISAC1_CODE,
          @o_BISAC_desc_1=BISAC1_LITERAL,
          @o_BISAC_code_2=BISAC2_CODE,
          @o_BISAC_desc_2=BISAC2_LITERAL,
          @o_BISAC_code_3=BISAC3_CODE,
          @o_BISAC_desc_3=BISAC3_LITERAL,
          @v_Multiple_Headings=@v_Multiple_Headings
        from BIC_BISAC_MAPPING
        where BIC_code=@i_BIC_code
        
      if @v_Multiple_Headings='E/O'
        begin
          set @o_BISAC_code_2=null
          set @o_BISAC_desc_2=null
          set @o_BISAC_code_3=null
          set @o_BISAC_desc_3=null
        end
        
    end
      
END
GO

/****** Object:  Table [dbo].[BIC_BISAC_MAPPING]    Script Date: 11/01/2011 16:54:24 ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO

SET ANSI_PADDING ON
GO

