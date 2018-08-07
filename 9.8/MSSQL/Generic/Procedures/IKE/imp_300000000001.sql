/******************************************************************************
**  Name: imp_300000000001
**  Desc: IKE Remove unwanted characters
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

if exists (select * from dbo.sysobjects where id = object_id(N'[dbo].[imp_300000000001]') and OBJECTPROPERTY(id, N'IsProcedure') = 1)
drop procedure [dbo].[imp_300000000001]
GO

CREATE PROCEDURE dbo.imp_300000000001 
  
  @i_batch int, 
  @i_row int , 
  @i_dmlkey bigint, 
  @i_titlekeyset varchar(500),
  @i_contactkeyset varchar(500),
  @i_templatekey int,
  @i_elementseq int,
  @i_level int,
  @i_userid varchar(50),
  @i_newtitleind int,
  @i_newcontactind int,
  @o_writehistoryind int output
AS

/* Remove unwanted characters */

BEGIN 

/* REMOVE UNWANTED CHARACTERS  */
DECLARE	@v_elementval		VARCHAR(4000),
  	@v_elementkey		INT,
  	@v_errcode 		INT,
  	@v_errmsg 		VARCHAR(4000),
  	@v_elementdesc 		VARCHAR(4000),
	@v_contactkey 		INT,
	@v_bookkey		INT,
	@v_new_elementval	VARCHAR(4000)

BEGIN
	SET @o_writehistoryind = 0
	SET @v_errcode = 1

	SELECT @v_elementval =  originalvalue,
		@v_elementkey = b.elementkey
	FROM imp_batch_detail b , imp_DML_elements d
	WHERE b.batchkey = @i_batch
      			AND b.row_id = @i_row
			AND b.elementseq = @i_elementseq
			AND b.elementkey = d.elementkey
			AND d.DMLkey = @i_dmlkey

	SELECT @v_elementdesc = elementdesc
	FROM imp_element_defs
	WHERE elementkey = @v_elementkey

	IF SUBSTRING(@v_elementval,1,1) = '$' 
		BEGIN
			SELECT @v_new_elementval = REPLACE(@v_elementval,'$','')

			UPDATE imp_batch_detail
			SET originalvalue = @v_new_elementval,
				lastuserid = 'DML_Update',
				lastmaintdate = GETDATE()
			WHERE batchkey = @i_batch
      					AND row_id = @i_row
					AND elementseq = @i_elementseq
					AND elementkey = @v_elementkey
					
			SET @v_errmsg = 'Imported value for '+ @v_elementdesc+' was changed on Batch Details from ('
					+ @v_elementval+') to ('+@v_new_elementval+')'
			SET @v_errcode = 1
			
		

		END
	ELSE
		BEGIN
			SET @v_errcode = 2
			SET @v_errmsg = 'WARNING: General Rule to remove characters did not make any changes'
		END


  	IF @v_errcode >= @i_level
    		BEGIN
      			EXECUTE imp_write_feedback @i_batch, @i_row, @v_elementkey, @i_elementseq ,@i_dmlkey , @v_errmsg, @v_errcode, 3
    		END

END

end

GO
SET QUOTED_IDENTIFIER OFF 
GO
SET ANSI_NULLS ON 
GO

GRANT EXECUTE ON dbo.[imp_300000000001] to PUBLIC 
GO
