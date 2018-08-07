/******************************************************************************
**  Name: imp_300014052001
**  Desc: IKE Add/Replace CDC Discount
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

if exists (select * from dbo.sysobjects where id = object_id(N'[dbo].[imp_300014052001]') and OBJECTPROPERTY(id, N'IsProcedure') = 1)
drop procedure [dbo].[imp_300014052001]
GO

CREATE PROCEDURE dbo.imp_300014052001 
  
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

/* Add/Replace CDC Discount */

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
DECLARE @v_discount		INT,
	@v_discountcode		INT,
	@v_hit			INT
	
BEGIN
	SET @v_hit = 0
	SET @v_discount = 0
	SET @v_discountcode = 0
	SET @o_writehistoryind = 0
	SET @v_errcode = 1
	SET @v_errmsg = 'Discount updated'
	SET @v_bookkey = dbo.resolve_keyset(@i_titlekeyset,1)

/*  GET IMPORTED DISCOUNT 			*/
	SELECT @v_elementval =  LTRIM(RTRIM(originalvalue)),
		@v_elementkey = b.elementkey
	FROM imp_batch_detail b , imp_DML_elements d
	WHERE b.batchkey = @i_batch
      				AND b.row_id = @i_row
				AND b.elementseq = @i_elementseq
				AND d.dmlkey = @i_dmlkey
				AND d.elementkey = b.elementkey


/* GET CURRENT CURRENT DISCOUNT VALUE		*/
	SELECT @v_discount = COALESCE(discountcode,0)
	FROM bookdetail
    	WHERE bookkey=@v_bookkey 

/* FIND IMPORT DISCOUNT ON GENTABLES 		*/	

	SELECT @v_hit = COUNT(*)
	FROM gentables
	WHERE tableid = 459  AND datadesc = @v_elementval

	IF @v_hit = 1
		BEGIN
			SELECT @v_discountcode = datacode
			FROM gentables
			WHERE tableid = 459  AND datadesc = @v_elementval

	/* IF VALUE HAS CHANGED - UPDATE BOOKDETAIL AND SET WRITE HISTORY INDICATOR	*/
			IF @v_discountcode <> @v_discount
				BEGIN
					UPDATE bookdetail
					SET discountcode = @v_discountcode,
						lastuserid = @i_userid,
						lastmaintdate = GETDATE()
					WHERE bookkey = @v_bookkey
	
					SET @o_writehistoryind = 1
				END
			END
	ELSE			
		BEGIN
			SET @v_errmsg = 'Can not find discount on gentables'
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

GRANT EXECUTE ON dbo.[imp_300014052001] to PUBLIC 
GO
