/******************************************************************************
**  Name: imp_300021058001
**  Desc: IKE Add/Replace CustomCode08
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

if exists (select * from dbo.sysobjects where id = object_id(N'[dbo].[imp_300021058001]') and OBJECTPROPERTY(id, N'IsProcedure') = 1)
drop procedure [dbo].[imp_300021058001]
GO

CREATE PROCEDURE dbo.imp_300021058001 
  
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

/* Add/Replace CustomCode08 */

BEGIN 

DECLARE @v_elementval		VARCHAR(4000),
	@v_elementdesc		VARCHAR(4000),
	@v_elementkey		INT,
	@v_errcode		INT,
  	@v_errmsg 		VARCHAR(4000),
	@v_bookkey 		INT,
	@v_customcode08		INT,
	@v_customcode08code	INT,
	@v_hit			INT,
	@v_rowcount		INT
	
BEGIN
	SET @v_hit = 0
	SET @v_rowcount = 0
	SET @v_customcode08 = 0
	SET @v_customcode08code = 0
	SET @o_writehistoryind = 0
	SET @v_errcode = 1
	SET @v_errmsg = 'Custom Code 08 Updated'
	SET @v_bookkey = dbo.resolve_keyset(@i_titlekeyset,1)

/*  GET IMPORTED CUSTOM CODE 08			*/
	SELECT @v_elementval =  originalvalue,
		@v_elementkey = b.elementkey
	FROM imp_batch_detail b , imp_DML_elements d
	WHERE b.batchkey = @i_batch
      				AND b.row_id = @i_row
				AND b.elementseq = @i_elementseq
				AND d.dmlkey = @i_dmlkey
				AND d.elementkey = b.elementkey

	SELECT @v_elementdesc = COALESCE(customfieldlabel,'Custom Code 08')
	FROM customfieldsetup
	WHERE customfieldname = 'customcode08'

/* FIND IMPORT CUSTOM CODE 08 ON GENTABLES 		*/	

	SELECT @v_hit = COUNT(*)
	FROM gentables
	WHERE tableid = 424 AND datadesc = @v_elementval

	IF @v_hit = 1
		BEGIN
			SELECT @v_customCode08code = datacode
			FROM gentables
			WHERE tableid = 424  AND datadesc = @v_elementval

			SELECT @v_rowcount = COUNT(*)
			FROM bookcustom
			WHERE bookkey = @v_bookkey

			IF @v_rowcount = 0
				BEGIN
					INSERT INTO bookcustom(bookkey,customCode08,lastuserid,lastmaintdate)
					VALUES(@v_bookkey,@v_customcode08code,@i_userid,GETDATE())

					SET @o_writehistoryind = 1
				END
/* GET CURRENT CURRENT CUSTOM CODE 08 VALUE		*/
			ELSE
				BEGIN	

					SELECT @v_customCode08 = COALESCE(customCode08,-1)--mk20130606>Case 23834 IKE import fails to import non-empty 
					FROM bookcustom
    					WHERE bookkey=@v_bookkey 

					IF @v_customCode08code <> @v_customCode08
						BEGIN
							UPDATE bookcustom
							SET customCode08 = @v_customCode08code,
								lastuserid = @i_userid,
								lastmaintdate = GETDATE()
							WHERE bookkey = @v_bookkey

							SET @o_writehistoryind = 1	
						END
				END	
		END	
			
	IF @v_errcode >= @i_level
		BEGIN
			EXECUTE imp_write_feedback @i_batch, @i_row,@v_elementkey , @i_elementseq ,@i_dmlkey , @v_errmsg, @v_errcode, 3
    		END


END

end

GO
SET QUOTED_IDENTIFIER OFF 
GO
SET ANSI_NULLS ON 
GO

GRANT EXECUTE ON dbo.[imp_300021058001] to PUBLIC 
GO
