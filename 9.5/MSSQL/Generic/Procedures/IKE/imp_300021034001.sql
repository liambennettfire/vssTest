/******************************************************************************
**  Name: imp_300021034001
**  Desc: IKE Add/Replace Custom Indicator 04
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

if exists (select * from dbo.sysobjects where id = object_id(N'[dbo].[imp_300021034001]') and OBJECTPROPERTY(id, N'IsProcedure') = 1)
drop procedure [dbo].[imp_300021034001]
GO

CREATE PROCEDURE dbo.imp_300021034001 
  
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

/* Add/Replace Custom Indicator 04(Price on Book) */

BEGIN 

SET NOCOUNT ON
/* DEFINE BATCH VARIABLES		*/
DECLARE @v_elementval			VARCHAR(4000),
	@v_errcode			INT,
  	@v_errmsg 			VARCHAR(4000),
	@v_elementdesc			VARCHAR(4000),
	@v_elementkey			BIGINT,
	@v_lobcheck 			VARCHAR(20),
	@v_lobkey 			INT,
	@v_bookkey 			INT
/*  DEFINE LOCAL VARIABLES		*/
DECLARE @v_new_customind		INT,
	@v_curr_customind		INT,
	@v_rowcount			INT
	
BEGIN
	SET @v_rowcount = 0
	SET @v_new_customind = 0
	SET @v_curr_customind = 0
	SET @o_writehistoryind = 0
	SET @v_errcode = 1
	SET @v_errmsg = 'Custom Indicator 04 Update'
	SET @v_bookkey = dbo.resolve_keyset(@i_titlekeyset,1)

/*  GET IMPORTED CUSTOM Indicator 04 			*/
	SELECT @v_elementval =  LTRIM(RTRIM(originalvalue)),
		@v_elementkey = b.elementkey
	FROM imp_batch_detail b , imp_DML_elements d
	WHERE b.batchkey = @i_batch
      				AND b.row_id = @i_row
				AND b.elementseq = @i_elementseq
				AND d.dmlkey = @i_dmlkey
				AND d.elementkey = b.elementkey

	SELECT @v_new_customind = CASE
						WHEN @v_elementval='Y'  THEN 1
						WHEN @v_elementval='N'  THEN 0
					  ELSE
						0
				   END

	SELECT @v_rowcount = COUNT(*)
	FROM bookcustom
	WHERE bookkey = @v_bookkey

	IF @v_rowcount = 0
		BEGIN
			INSERT INTO bookcustom(bookkey,customind04,lastuserid,lastmaintdate)
			VALUES(@v_bookkey,@v_new_customind,@i_userid,GETDATE())
		END
	ELSE
		BEGIN	
/* GET CURRENT CURRENT  CUSTOM Indicator 04 VALUE		*/
			
			SELECT @v_curr_customind = COALESCE(customind04,-1)--mk20130606>Case 23834 IKE import fails to import non-empty value into null bookcustom
			FROM bookcustom
    			WHERE bookkey=@v_bookkey 

			IF @v_new_customind <> @v_curr_customind
				BEGIN
					UPDATE bookcustom
					SET customind04 = @v_new_customind,
						lastuserid = @i_userid,
						lastmaintdate = GETDATE()
					WHERE bookkey = @v_bookkey
	
					SET @o_writehistoryind = 1
				END
			END
	IF @v_rowcount > 1		
		BEGIN
			SET @v_errmsg = 'Did not update Custom Indicator 04 '
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

GRANT EXECUTE ON dbo.[imp_300021034001] to PUBLIC 
GO
