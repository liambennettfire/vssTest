/******************************************************************************
**  Name: imp_100100050010
**  Desc: IKE Adjust the DateSeed sequence to process after the task templates
**  Auth: Bennett     
**  Date: 5/9/2016
*******************************************************************************
**  Change History
*******************************************************************************
**  Date:        Author:     Description:
*   --------     --------    -------------------------------------------
**  5/9/2016     Bennett     original
*******************************************************************************/
SET QUOTED_IDENTIFIER ON 
GO
SET ANSI_NULLS ON 
GO

if exists (select * from dbo.sysobjects where id = object_id(N'[dbo].[imp_100100050010]') and OBJECTPROPERTY(id, N'IsProcedure') = 1)
drop procedure [dbo].[imp_100100050010]
GO

CREATE PROCEDURE dbo.imp_100100050010 
  @i_batchkey int,
  @i_row int,
--  @i_elementkey int,
  @i_elementseq int,
  @i_templatekey int,
  @i_rulekey bigint,
  @i_level int,
  @i_userid varchar(50)
AS


BEGIN 

DECLARE @DEBUG AS INT,
  @v_errcode INT,
  @v_elementkey int,
  @v_errlevel INT,
  @v_msg VARCHAR(4000),
  @v_errseverity AS INT
  
	SET @DEBUG = 1
	IF @DEBUG <> 0 PRINT 'dbo.imp_100100050010'
	
	SET @v_errseverity=1
	SET @v_msg='Adjust the DateSeed sequence to process after the task templates have been inserted'
	  
	BEGIN TRY
		--push the processing of this element to the highest sequence to be sure that all sequences of templates have been inserted into taqprojecttasks
		UPDATE	imp_batch_detail
		SET		elementseq = (
					SELECT max(elementseq) + 1
					FROM imp_batch_detail
					WHERE batchkey = @i_batchkey
						AND row_id = @i_row
					)
		WHERE	batchkey = @i_batchkey
				AND row_id = @i_row
				AND elementkey = 100050010	

	END TRY
	BEGIN CATCH
			set @v_errcode=@@ERROR
			set @v_msg=ERROR_MESSAGE () 
			set @v_errseverity=3
			IF @DEBUG <> 0 PRINT @v_errcode
			IF @DEBUG <> 0 PRINT @v_msg					
	END CATCH
		
	IF @DEBUG <> 0 PRINT @v_msg
	EXECUTE imp_write_feedback @i_batchkey, @i_row, @v_elementkey, @i_elementseq, @i_rulekey , @v_msg, @v_errseverity, 1

end

GO
SET QUOTED_IDENTIFIER OFF 
GO
SET ANSI_NULLS ON 
GO

GRANT EXECUTE ON dbo.[imp_100100050010] to PUBLIC 
GO
