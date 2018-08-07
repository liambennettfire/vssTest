/******************************************************************************
**  Name: imp_300021029001
**  Desc: IKE Add/Replace Custom Float
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

if exists (select * from dbo.sysobjects where id = object_id(N'[dbo].[imp_300021029001]') and OBJECTPROPERTY(id, N'IsProcedure') = 1)
drop procedure [dbo].[imp_300021029001]
GO

CREATE PROCEDURE dbo.imp_300021029001 
  
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

/* Add/Replace Custom Float 09 */

BEGIN 

DECLARE @v_elementval			VARCHAR(4000),
	@v_elementdesc			VARCHAR(4000),
	@v_elementkey			INT,
	@v_errcode			INT,
  	@v_errmsg 			VARCHAR(4000),
	@v_bookkey 			INT,
	@v_new_customfloat		FLOAT,
	@v_curr_customfloat		FLOAT,
	@v_rowcount			INT
	
BEGIN
	SET @v_rowcount = 0
	SET @v_new_customfloat = 0
	SET @v_curr_customfloat = 0
	SET @o_writehistoryind = 0
	SET @v_errcode = 1
	SET @v_errmsg = 'Custom Float 09 Updated'
	SET @v_bookkey = dbo.resolve_keyset(@i_titlekeyset,1)

/*  GET IMPORTED CUSTOM FLOAT 09 			*/
	SELECT @v_elementval =  originalvalue,
		@v_elementkey = b.elementkey
	FROM imp_batch_detail b , imp_DML_elements d
	WHERE b.batchkey = @i_batch
      				AND b.row_id = @i_row
				AND b.elementseq = @i_elementseq
				AND d.dmlkey = @i_dmlkey
				AND d.elementkey = b.elementkey

	SELECT @v_elementdesc = COALESCE(customfieldlabel,'Custom Float 09')
	FROM customfieldsetup
	WHERE customfieldname = 'customfloat09'


/* FIND IMPORT CUSTOM FLOAT 09 		*/	

	SELECT @v_new_customfloat = CONVERT(FLOAT,@v_elementval)

	SELECT @v_rowcount = COUNT(*)
	FROM bookcustom
	WHERE bookkey = @v_bookkey

	IF @v_rowcount = 0
		BEGIN
			INSERT INTO bookcustom(bookkey,customfloat09,lastuserid,lastmaintdate)
			VALUES(@v_bookkey,@v_new_customfloat,@i_userid,GETDATE())
		
			SET @o_writehistoryind = 1
		END
	ELSE  
		BEGIN	
/* GET CURRENT CURRENT productline VALUE		*/
			SELECT @v_curr_customfloat = COALESCE(customfloat09,-1)--mk20130606>Case 23834 IKE import fails to import non-empty 
			FROM bookcustom
    			WHERE bookkey=@v_bookkey 

			IF @v_new_customfloat <> @v_curr_customfloat
				BEGIN
					UPDATE bookcustom
					SET customfloat09 = @v_new_customfloat,
						lastuserid = @i_userid,
						lastmaintdate = GETDATE()
					WHERE bookkey = @v_bookkey
	
					SET @o_writehistoryind = 1
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

GRANT EXECUTE ON dbo.[imp_300021029001] to PUBLIC 
GO
