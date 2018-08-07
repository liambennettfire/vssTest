
GO

/****** Object:  UserDefinedFunction [dbo].[rpt_get_taq_comment]    Script Date: 08/25/2015 14:47:59 ******/
IF  EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[rpt_get_taq_comment]') AND type in (N'FN', N'IF', N'TF', N'FS', N'FT'))
DROP FUNCTION [dbo].[rpt_get_taq_comment]
GO


GO

/****** Object:  UserDefinedFunction [dbo].[rpt_get_taq_comment]    Script Date: 08/25/2015 14:47:59 ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO

  
CREATE FUNCTION [dbo].[rpt_get_taq_comment]         
             (@i_projectkey  INT,        
    @v_commenttypecode INT,         
    @v_commenttypesubcode INT,         
             @v_type INT)        
          
         
/* The rpt_get_project_comment function is used to retrieve the comment from the taqprojectcomments table.  The @v_type is used to distinquish        
 between the different comment formats to return.          
        The parameters are for the book key, comment type code, comment type subcode, and comment format type.          
   @v_commenttypecode & @v_commenttypesubcode - tableid 284 on gentables and subgentables        
  @v_commenttypecode        
   1 - Marketing        
   3 - Editorial        
   4 - Title        
   5 - Publicity        
   6 - Project        
  @v_commenttypesubcode - main ones        
   1 - 4 - Book Summary        
   1 - 28 - Series Summary        
   3 - 7 - Brief Description        
   3 - 10 - Author Bio        
   3 - 45 - Series Description        
   3 - 49 - CIP Summary        
   4 - 1 - Editorial Notes        
   4 - 2 - Production Notes        
   4 - 8 - Comments        
   4 - 13 - Word Count        
   4 - 23 - Development House        
   4 - 39 - Archive Code         
 @v_type        
  1 = Plain Text        
  2 = HTML        
  3 = HTML Lite        
*/        
RETURNS VARCHAR(8000)        
AS          
BEGIN         
         
 DECLARE @v_text  VARCHAR(8000)        
 DECLARE @RETURN         VARCHAR(8000)        
         
/*  GET comment formats   */        
 IF @v_type = 1        
  BEGIN        
   SELECT @v_text = LTRIM(RTRIM(REPLACE(CAST(q.commenttext AS VARCHAR(8000)), char(13) + char(10), ' ')))        
     FROM taqprojectcomments t, qsicomments q         
   WHERE taqprojectkey = @i_projectkey        
    AND t.commenttypecode = @v_commenttypecode        
    AND t.commenttypesubcode = @v_commenttypesubcode          
    AND t.commentkey=q.commentkey        
  END        
 IF @v_type = 2        
  BEGIN        
   SELECT @v_text = CAST(q.commenthtml AS VARCHAR(8000))        
     FROM taqprojectcomments t, qsicomments q         
   WHERE taqprojectkey = @i_projectkey        
    AND t.commenttypecode = @v_commenttypecode        
    AND t.commenttypesubcode = @v_commenttypesubcode        
    AND t.commentkey=q.commentkey        
  END        
 IF @v_type = 3        
  BEGIN        
   SELECT @v_text = CAST(q.commenthtmllite AS VARCHAR(8000))        
     FROM taqprojectcomments t , qsicomments q         
   WHERE taqprojectkey = @i_projectkey        
    AND t.commenttypecode = @v_commenttypecode        
    AND t.commenttypesubcode = @v_commenttypesubcode        
    AND t.commentkey=q.commentkey        
  END        
 IF @v_text is NOT NULL        
  BEGIN        
   SELECT @RETURN = REPLACE(LTRIM(RTRIM(@v_text)),'<BR />','<BR>')        
  END        
 ELSE        
  BEGIN        
   SELECT @RETURN = ''         
  END        
RETURN @RETURN        
END 
GO


Grant all on rpt_get_taq_comment to public