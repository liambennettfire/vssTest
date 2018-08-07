IF  EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[imp_200018001002]') AND type in (N'P', N'PC'))
DROP PROCEDURE [dbo].[imp_200018001002]
GO

SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO


CREATE PROCEDURE [dbo].[imp_200018001002] 
  @i_batch int,
  @i_row int,
  @i_elementkey int,
  @i_elementseq int,
  @i_templatekey int,
  @i_rulekey bigint,
  @i_rpt int
AS

/**********************************************************************************
**  Name: imp_200018001002
**  Desc: This stored procedure validates Subject Category and Subject Sub Category
**        
**    Auth: Kusum
**    Date: 04/08/2016
**
***********************************************************************************/

/* Check for more than one match at the subgentable level for Subject Category when 
   trying to match elementdesc on existing subgentable rows
   because the elementdesc does not match datadesc for category gentable level */

BEGIN 


SET NOCOUNT ON	
DECLARE	
    @v_elementval 	VARCHAR(4000),
	@v_errcode 		INT,
	@v_errlevel 	INT,
	@v_count        INT,
	@v_errmsg 		VARCHAR(4000),
	@v_elementdesc 	VARCHAR(4000),
	@v_row_count	INT,
	@v_tableid      INT,
    @v_datacode		INT,
    @v_datasubcode  INT,
    @v_destinationcolumn VARCHAR(100),
    @v_datadesc     VARCHAR(40),
    @v_tabledesclong VARCHAR(40),
    @v_categorycode INT,
    @v_categorysubcode INT,
    @v_count2 INT
    
	BEGIN
		SET @v_errlevel = 0
		SET @v_row_count = 0
		SET @v_count = 0
		SET @v_count2 = 0
		

		SELECT @v_elementdesc = elementdesc, @v_tableid = tableid, @v_destinationcolumn = destinationcolumn
		  FROM imp_element_defs WHERE elementkey =  @i_elementkey

		SELECT @v_elementval = COALESCE(originalvalue,'')
		  FROM imp_batch_detail 
		 WHERE batchkey = @i_batch AND row_id = @i_row AND elementkey =  @i_elementkey AND elementseq =  @i_elementseq
		 
		IF @v_destinationcolumn = 'externalcode' BEGIN
		  SELECT @v_count = COUNT(*) FROM gentables WHERE tableid = @v_tableid AND externalcode = @v_elementval
		  
		  IF @v_count = 0 BEGIN
			  SELECT @v_count2 = COUNT(*) FROM subgentables	WHERE tableid = @v_tableid AND externalcode = @v_elementval
				
			  IF @v_count2 > 1 BEGIN
				  SELECT @v_tabledesclong = tabledesclong FROM gentablesdesc WHERE tableid = @v_tableid 
				  
				  SET @v_errlevel = 2
				  
				  SET @v_errmsg = '('+@v_elementval+') value does not exist at gentable level but exists on multiple categories at subgentable table level on User Table:' 
				    + CAST(@v_tableid AS VARCHAR) + ' for ' + @v_tabledesclong + '. Could not determine the Subject Category/subcategory to be updated.'
			  END
			  ELSE IF @v_count2 = 1 BEGIN
				SET @v_errmsg = 'Information: Subject Category with externalcode of: ' + @v_elementval + ' ' + CAST(@v_tableid AS VARCHAR) + ' OK'
				SET @v_errlevel = 1
			  END
			  ELSE IF @v_count2 = 0 BEGIN
				SET @v_errmsg = 'Information: Subject Category with externalcode of: ' + @v_elementval + ' does not exist at gentable or subgentable level for tableid: ' 
				    + CAST(@v_tableid AS VARCHAR)
				SET @v_errlevel = 1
			  END
		  END
		END
		
		SET @v_count = 0
		SET @v_count2 = 0
		
		IF @v_destinationcolumn = 'datadesc' BEGIN
		  SELECT @v_count = COUNT(*) FROM gentables WHERE tableid = @v_tableid AND datadesc = @v_elementval  
		  IF @v_count = 0 BEGIN
			  SELECT @v_count2 = COUNT(*) FROM subgentables	WHERE tableid = @v_tableid AND datadesc = @v_elementval
				
			  IF @v_count2 > 1 BEGIN
				  SELECT @v_tabledesclong = tabledesclong FROM gentablesdesc WHERE tableid = @v_tableid 
				  
				  SET @v_errlevel = 2
				  
				  SET @v_errmsg = '('+@v_elementval+') value does not exist at gentable level but exists on multiple categories at subgentable table level on User Table:' 
				  + CAST(@v_tableid AS VARCHAR) + ' for ' + @v_tabledesclong + ' .  Could not determine the Subject Category/subcategory.'
			  END
			  ELSE IF @v_count2 = 1 BEGIN
				SET @v_errmsg = 'Information: Subject Category with externalcode of: ' + @v_elementval + ' ' + CAST(@v_tableid AS VARCHAR) + ' OK'
				SET @v_errlevel = 1
			  END
			  ELSE IF @v_count2 = 0 BEGIN
				SET @v_errmsg = 'Information: Subject Category with datdesc of: ' + @v_elementval + ' does not exist at gentable or subgentable level for tableid: ' 
				    + CAST(@v_tableid AS VARCHAR)
				SET @v_errlevel = 1
			  END
		   END
		END
	

		IF @v_errlevel >= @i_rpt BEGIN
		  EXECUTE imp_write_feedback @i_batch, @i_row, @i_elementkey, @i_elementseq, @i_rulekey , @v_errmsg, @v_errlevel, 2
		END
	END
END
GO