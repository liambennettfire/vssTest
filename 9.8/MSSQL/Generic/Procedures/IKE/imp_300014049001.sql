/******************************************************************************
**  Name: imp_300014049001
**  Desc: IKE Add/Replace Volume
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

if exists (select * from dbo.sysobjects where id = object_id(N'[dbo].[imp_300014049001]') and OBJECTPROPERTY(id, N'IsProcedure') = 1)
drop procedure [dbo].[imp_300014049001]
GO

CREATE PROCEDURE dbo.imp_300014049001 
  
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

/* Add/Replace Volume */

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
DECLARE @v_volumenumber		INT,
	@v_volume		INT,
	@v_hit			INT
	
BEGIN
	SET @v_hit = 0
	SET @v_volumenumber = 0
	SET @v_volume = 0
	SET @o_writehistoryind = 0
	SET @v_errcode = 1
	SET @v_errmsg = 'Volume Number updated'
	SET @v_bookkey = dbo.resolve_keyset(@i_titlekeyset,1)

/*  GET IMPORTED Territories 			*/
	SELECT @v_elementval =  LTRIM(RTRIM(originalvalue)),
		@v_elementkey = b.elementkey
	FROM imp_batch_detail b , imp_DML_elements d
	WHERE b.batchkey = @i_batch
      				AND b.row_id = @i_row
				AND b.elementseq = @i_elementseq
				AND d.dmlkey = @i_dmlkey
				AND d.elementkey = b.elementkey
	

	IF IsNumeric(@v_elementval) = 1
		BEGIN
			SET @v_volume = CONVERT(INT,@v_elementval)

/* GET CURRENT CURRENT VOLUME NUMBER VALUE		*/
			SELECT @v_volumenumber = COALESCE(volumenumber,0)
			FROM bookdetail
		    	WHERE bookkey=@v_bookkey 

/* IF VALUE HAS CHANGED - UPDATE BOOKDETAIL AND SET WRITE HISTORY INDICATOR	*/
			IF @v_volume <> @v_volumenumber
				BEGIN
					UPDATE bookdetail
					SET volumenumber = @v_volume,
							lastuserid = @i_userid,
							lastmaintdate = GETDATE()
					WHERE bookkey = @v_bookkey
	
					SET @o_writehistoryind = 1
				END
		END
	ELSE
		BEGIN
			SET @v_errcode = 2
			SET @v_errmsg = 'WARNING: imported volume is not a nueric value - volume was not updated'
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

GRANT EXECUTE ON dbo.[imp_300014049001] to PUBLIC 
GO
