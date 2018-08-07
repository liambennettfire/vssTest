/******************************************************************************
**  Name: imp_300012024001
**  Desc: IKE Add/Replace Short Title
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

if exists (select * from dbo.sysobjects where id = object_id(N'[dbo].[imp_300012024001]') and OBJECTPROPERTY(id, N'IsProcedure') = 1)
drop procedure [dbo].[imp_300012024001]
GO

CREATE PROCEDURE dbo.imp_300012024001 
  
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

/* Add/Replace Short Title */

BEGIN 

SET NOCOUNT ON
/* DEFINE BATCH VARIABLES		*/
DECLARE @v_elementval		VARCHAR(4000),
	@v_errcode		INT,
  	@v_errmsg 		VARCHAR(4000),
	@v_elementdesc		VARCHAR(4000),
	@v_elementkey		BIGINT,
	@v_lobcheck 		VARCHAR(20),
	@v_lobkey 		INT,
	@v_bookkey 		INT
/*  DEFINE LOCAL VARIABLES		*/
DECLARE @v_cur_shorttitle	VARCHAR(50),
	@v_new_shorttitle	VARCHAR(50),
	@i_length		INT


BEGIN
	SET @o_writehistoryind = 0
	SET @v_errcode = 1
	SET @v_errmsg = 'Short title updated'
	SET @v_bookkey = dbo.resolve_keyset(@i_titlekeyset,1)

	SELECT @v_elementval =  COALESCE(originalvalue,''),
		@v_elementkey = b.elementkey
	FROM imp_batch_detail b , imp_DML_elements d
	WHERE b.batchkey = @i_batch
      				AND b.row_id = @i_row
				AND b.elementseq = @i_elementseq
				AND b.elementkey = d.elementkey
				AND d.DMLkey = @i_dmlkey

/* GET CURRENT SHORT TITLE 		*/
	SELECT @v_cur_shorttitle = COALESCE(shorttitle,'')
	FROM book
    	WHERE bookkey=@v_bookkey 


/*  IF IMPORT SHORT TITLE EXISTS USE THAT OTHERWIZE GENERATE FROM TITLE		*/

	IF LEN(@v_elementval) > 0
		BEGIN
			SET @v_new_shorttitle = @v_elementval
		END
	ELSE
		BEGIN
/* GET SHORT TITLE LENGTH - CONFIGURATION OPTION FROM DEFAULTS		*/

			SELECT @i_length = shorttitlelength
			FROM defaults

			SELECT @v_new_shorttitle = SUBSTRING(title,1,@i_length)
			FROM book
			WHERE bookkey = @v_bookkey
		END

/* UPDATE SHORT TITLE		*/
	set @v_new_shorttitle = SUBSTRING(@v_new_shorttitle,1,50)
	IF @v_new_shorttitle <> @v_cur_shorttitle
		BEGIN
			UPDATE book
			SET shorttitle = @v_new_shorttitle
    			WHERE bookkey=@v_bookkey 

			SET @o_writehistoryind = 1
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

GRANT EXECUTE ON dbo.[imp_300012024001] to PUBLIC 
GO
