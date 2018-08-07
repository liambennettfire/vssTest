/******************************************************************************
**  Name: imp_300012007001
**  Desc: IKE Add/Replace Full Author Display Name
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

if exists (select * from dbo.sysobjects where id = object_id(N'[dbo].[imp_300012007001]') and OBJECTPROPERTY(id, N'IsProcedure') = 1)
drop procedure [dbo].[imp_300012007001]
GO

CREATE PROCEDURE dbo.imp_300012007001 
  
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

/* Add/Replace Full Author Display Name */

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
	@v_bookkey 		INT,
	@v_new_displayname	VARCHAR(255),
	@v_cur_displayname	VARCHAR(255)
	
BEGIN
	
	SET @o_writehistoryind = 0
	SET @v_errcode = 1
	SET @v_errmsg = 'Full Author Display Name updated'
	SET @v_bookkey = dbo.resolve_keyset(@i_titlekeyset,1)

/*  GET IMPORTED FULL AUTHOR DISPLAY NAME 			*/
	SELECT @v_elementval =  LTRIM(RTRIM(originalvalue)),
		@v_elementkey = b.elementkey
	FROM imp_batch_detail b , imp_DML_elements d
	WHERE b.batchkey = @i_batch
      				AND b.row_id = @i_row
				AND b.elementseq = @i_elementseq
				AND d.dmlkey = @i_dmlkey
				AND d.elementkey = b.elementkey

	IF LEN(@v_elementval) < 256
		BEGIN
			SET @v_new_displayname = COALESCE(@v_elementval,'')

/* GET CURRENT CURRENT DISPLAY NAME VALUE		*/
			SELECT @v_cur_displayname = COALESCE(fullauthordisplayname,'')
			FROM bookdetail
		    	WHERE bookkey=@v_bookkey 

/* IF VALUE HAS CHANGED - UPDATE BOOKDETAIL AND SET WRITE HISTORY INDICATOR	*/
			IF @v_new_displayname <> @v_cur_displayname
				BEGIN
					UPDATE bookdetail
					SET fullauthordisplayname = @v_new_displayname,
						lastuserid = @i_userid,
						lastmaintdate = GETDATE()
					WHERE bookkey = @v_bookkey
	
					SET @o_writehistoryind = 1
				END
		END
	ELSE			
		BEGIN
			SET @v_errcode = 2
			SET @v_errmsg = 'Full Author Display Name has a length greater then 255.  The field was not updated'
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

GRANT EXECUTE ON dbo.[imp_300012007001] to PUBLIC 
GO
