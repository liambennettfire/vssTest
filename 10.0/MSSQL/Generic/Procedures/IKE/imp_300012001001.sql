/******************************************************************************
**  Name: imp_300012001001
**  Desc: IKE Add/Replace Announced 1st Printing
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

if exists (select * from dbo.sysobjects where id = object_id(N'[dbo].[imp_300012001001]') and OBJECTPROPERTY(id, N'IsProcedure') = 1)
drop procedure [dbo].[imp_300012001001]
GO

CREATE PROCEDURE dbo.imp_300012001001 
  
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

/* Add/Replace Announced 1st Printing */

BEGIN 

/* RULE TO UPDDATE/REPLACE BOTH ACT or EST ANNOUNCED 1ST PRINT	*/
DECLARE @v_elementval			VARCHAR(4000),
	@v_errcode			INT,
  	@v_errmsg 			VARCHAR(4000),
	@v_elementdesc			VARCHAR(4000),
	@v_elementkey			BIGINT,
	@v_lobcheck 			VARCHAR(20),
	@v_lobkey 			INT,
	@v_bookkey 			INT,
	@v_new_announced1stprint	INT,
	@v_cur_announced1stprint	INT,
	@v_destinationcolumn		VARCHAR(100)

BEGIN
	SET @v_new_announced1stprint = 0
	SET @v_cur_announced1stprint = 0
	SET @o_writehistoryind = 0
	SET @v_errcode = 1
	SET @v_bookkey = dbo.resolve_keyset(@i_titlekeyset,1)

	SELECT @v_elementval =  LTRIM(RTRIM(b.originalvalue)),
		@v_elementkey = b.elementkey,
		@v_destinationcolumn = e.destinationcolumn
	FROM imp_batch_detail b , imp_DML_elements d, imp_element_defs e
	WHERE b.batchkey = @i_batch
      				AND b.row_id = @i_row
				AND b.elementseq = @i_elementseq
				AND d.dmlkey = @i_dmlkey
				AND d.elementkey = b.elementkey
				AND d.elementkey = e.elementkey


	SELECT @v_errmsg = elementdesc+' Updated'
	FROM imp_element_defs
	WHERE elementkey = @v_elementkey

	SELECT @v_new_announced1stprint = CONVERT(INT,@v_elementval)


/* IF NEW ANNOUNCED 1ST PRINT <> CURRENT ANNOUNCED 1ST PRINT THEN UPDATE PRINTING SPECS */
	
	IF @v_destinationcolumn = 'announcedfirstprint'
		BEGIN
			SELECT @v_cur_announced1stprint = COALESCE(announcedfirstprint,0)
			FROM printing
			WHERE bookkey = @v_bookkey
					AND printingkey = 1

			IF @v_new_announced1stprint <> @v_cur_announced1stprint
				BEGIN
					UPDATE printing
					SET announcedfirstprint = @v_new_announced1stprint,
							lastuserid = @i_userid,
							lastmaintdate = getdate()
					WHERE bookkey = @v_bookkey
							AND printingkey = 1

					SET @o_writehistoryind = 1
				END

		END
	ELSE IF @v_destinationcolumn = 'estannouncedfirstprint'
		BEGIN
			SELECT @v_cur_announced1stprint = COALESCE(estannouncedfirstprint,0)
			FROM printing
			WHERE bookkey = @v_bookkey
					AND printingkey = 1

			IF @v_new_announced1stprint <> @v_cur_announced1stprint
				BEGIN
					UPDATE printing
					SET estannouncedfirstprint = @v_new_announced1stprint,
								lastuserid = @i_userid,
								lastmaintdate = getdate()
					WHERE bookkey = @v_bookkey
							AND printingkey = 1

					SET @o_writehistoryind = 1
				END
		END
	ELSE
		BEGIN
			SET @v_errmsg = 'ERROR:  Destination Column is not defined on IMP_ELEMENT_DEFS'
		END

 
  	IF @v_errcode < 2
    		BEGIN
			EXECUTE imp_write_feedback @i_batch, @i_row, @v_elementkey, @i_elementseq ,@i_dmlkey , @v_errmsg, @i_level, 3     
    		END
END

end

GO
SET QUOTED_IDENTIFIER OFF 
GO
SET ANSI_NULLS ON 
GO

GRANT EXECUTE ON dbo.[imp_300012001001] to PUBLIC 
GO
