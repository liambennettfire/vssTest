/******************************************************************************
**  Name: imp_300014055001
**  Desc: IKE Add/Replace Edition
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

if exists (select * from dbo.sysobjects where id = object_id(N'[dbo].[imp_300014055001]') and OBJECTPROPERTY(id, N'IsProcedure') = 1)
drop procedure [dbo].[imp_300014055001]
GO

CREATE PROCEDURE dbo.imp_300014055001 
  
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

/* Add/Replace Edition */

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
DECLARE @v_edition		INT,
	@v_editioncode		INT,
	@v_hit			INT
	
BEGIN
	SET @v_hit = 0
	SET @v_edition = 0
	SET @v_editioncode = 0
	SET @o_writehistoryind = 0
	SET @v_errcode = 1
	SET @v_errmsg = 'edition updated'
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


/* GET CURRENT CURRENT edition VALUE		*/
	SELECT @v_edition = COALESCE(editioncode,0)
	FROM bookdetail
    	WHERE bookkey=@v_bookkey 

/* FIND IMPORT edition ON GENTABLES 		*/	

	--SELECT @v_hit = COUNT(*)
	--FROM gentables
	--WHERE tableid = 200  AND datadesc = @v_elementval
	
	declare @v_datadesc as varchar(max)
	EXEC dbo.find_gentables_mixed @v_elementval,200,@v_editioncode output,@v_datadesc output
	SET @v_editioncode=COALESCE(@v_editioncode,0)
	
	--print '@v_elementval'
	--print @v_elementval
	--print '@v_editioncode'
	--print @v_editioncode
	

	--IF @v_hit = 1
	IF @v_editioncode>0
		BEGIN
			--SELECT @v_editioncode = datacode
			--FROM gentables
			--WHERE tableid = 200  AND datadesc = @v_elementval

	/* IF VALUE HAS CHANGED - UPDATE BOOKDETAIL AND SET WRITE HISTORY INDICATOR	*/
			IF @v_editioncode <> @v_edition
				BEGIN
				--print 'UPDATE bookdetail'
					UPDATE bookdetail
					SET editioncode = @v_editioncode,
						lastuserid = @i_userid,
						lastmaintdate = GETDATE()
					WHERE bookkey = @v_bookkey
	
					SET @o_writehistoryind = 1
				END
			END
	ELSE			
		BEGIN
			SET @v_errcode = 2
			SET @v_errmsg = 'Can not find ('+@v_elementval+') value on gentables.  Edition was not updated'
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

GRANT EXECUTE ON dbo.[imp_300014055001] to PUBLIC 
GO
