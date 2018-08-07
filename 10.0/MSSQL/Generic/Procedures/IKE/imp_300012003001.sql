/******************************************************************************
**  Name: imp_300012003001
**  Desc: IKE Add/Replace Canadian Restrictions
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

if exists (select * from dbo.sysobjects where id = object_id(N'[dbo].[imp_300012003001]') and OBJECTPROPERTY(id, N'IsProcedure') = 1)
drop procedure [dbo].[imp_300012003001]
GO

CREATE PROCEDURE dbo.imp_300012003001 
  
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

/* Add/Replace Canadian Restrictions */

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
DECLARE @v_canrestriction	INT,
	@v_canrestrictioncode	INT,
	@v_datadesc  		VARCHAR(max),
	@v_hit			INT
	
BEGIN
	SET @v_hit = 0
	SET @v_canrestriction = 0
	SET @v_canrestrictioncode = 0
	SET @o_writehistoryind = 0
	SET @v_errcode = 1
	SET @v_errmsg = 'Canadian Restriction updated'
	SET @v_bookkey = dbo.resolve_keyset(@i_titlekeyset,1)

/*  GET IMPORTED edition 			*/
	SELECT @v_elementval =  LTRIM(RTRIM(originalvalue)),
		@v_elementkey = b.elementkey
	FROM imp_batch_detail b , imp_DML_elements d
	WHERE b.batchkey = @i_batch
      				AND b.row_id = @i_row
				AND b.elementseq = @i_elementseq
				AND d.dmlkey = @i_dmlkey
				AND d.elementkey = b.elementkey


/* GET CURRENT CURRENT CANADIAN RESTRICTION VALUE		*/
	SELECT @v_canrestriction = COALESCE(canadianrestrictioncode,0)
	FROM bookdetail
    	WHERE bookkey=@v_bookkey 

/* FIND IMPORT edition ON GENTABLES 		*/	

	--SELECT @v_hit = COUNT(*)
	--FROM gentables
	--WHERE tableid = 428  AND datadesc = @v_elementval
	
	exec find_gentables_mixed @v_elementval,428,@v_canrestrictioncode output,@v_datadesc output

	IF @v_canrestrictioncode > 0
		BEGIN
			--SELECT @v_canrestrictioncode = datacode
			--FROM gentables
			--WHERE tableid = 428  AND datadesc = @v_elementval

	/* IF VALUE HAS CHANGED - UPDATE BOOKDETAIL AND SET WRITE HISTORY INDICATOR	*/
			IF @v_canrestrictioncode <> @v_canrestriction
				BEGIN
					UPDATE bookdetail
					SET canadianrestrictioncode = @v_canrestrictioncode,
						lastuserid = @i_userid,
						lastmaintdate = GETDATE()
					WHERE bookkey = @v_bookkey
	
					SET @o_writehistoryind = 1
				END
			END
	ELSE			
		BEGIN
			SET @v_errmsg = 'Did not update Canadian Restriction'
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

GRANT EXECUTE ON dbo.[imp_300012003001] to PUBLIC 
GO
