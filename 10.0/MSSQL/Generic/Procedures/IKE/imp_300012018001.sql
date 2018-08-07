/******************************************************************************
**  Name: imp_300012018001
**  Desc: IKE Add/Replace Pub Month Year
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

if exists (select * from dbo.sysobjects where id = object_id(N'[dbo].[imp_300012018001]') and OBJECTPROPERTY(id, N'IsProcedure') = 1)
drop procedure [dbo].[imp_300012018001]
GO

CREATE PROCEDURE dbo.imp_300012018001 
  
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

/* Add/Replace Pub Month Year */

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
DECLARE @v_pubmonth		INT,
	@v_pubmonthcode		INT,
	@v_new_pubyear		DATETIME,
	@v_cur_pubyear		DATETIME

BEGIN
	SET @o_writehistoryind = 0
	SET @v_errcode = 1
	SET @v_errmsg = 'Pub Month Year Updated'
	SET @v_bookkey = dbo.resolve_keyset(@i_titlekeyset,1)
	SET @v_pubmonth = 0
	SET @v_pubmonthcode = 0

	SELECT @v_elementval =  COALESCE(originalvalue,''),
		@v_elementkey = b.elementkey
	FROM imp_batch_detail b , imp_DML_elements d
	WHERE b.batchkey = @i_batch
      				AND b.row_id = @i_row
				AND b.elementseq = @i_elementseq
				AND b.elementkey = d.elementkey
				AND d.DMLkey = @i_dmlkey
/*  VERIFY IMPORT VALUE IS A INTEGER		*/
	IF IsNumeric(@v_elementval) = 1
		BEGIN

/*  GET CURRENT PUB MONTH CODE AND PUBMONTH 	*/

			SELECT @v_pubmonth = COALESCE(pubmonthcode,0),
				@v_cur_pubyear = COALESCE(pubmonth,'')
			FROM printing 
			WHERE bookkey = @v_bookkey
					AND printingkey = 1
	
/*  GET EXISTING PUB MONTH YEAR 	*/

			IF @v_pubmonth > 0
				BEGIN
					SET @v_new_pubyear = CONVERT(CHAR(2),@v_pubmonth)+'/01/'+@v_elementval


/* IF @v_new_pubyear <> EXISTING Pub MONTH THEN UPDATE PRINTING  */
	
					IF CONVERT(VARCHAR(10),@v_new_pubyear,101) <> CONVERT(VARCHAR(10),@v_cur_pubyear,101)
						BEGIN
							UPDATE printing
							SET pubmonth = @v_new_pubyear,
								lastuserid = @i_userid,
								lastmaintdate = getdate()
							WHERE bookkey = @v_bookkey
								AND printingkey = 1

							SET @o_writehistoryind = 1
						END
 				END
		END
	ELSE
		BEGIN
			SET @v_errcode = 2
			SET @v_errmsg = 'WARNING: Invalid entry - Pub Month Year was not updated'
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

GRANT EXECUTE ON dbo.[imp_300012018001] to PUBLIC 
GO
