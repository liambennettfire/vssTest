/******************************************************************************
**  Name: imp_300012053001
**  Desc: IKE  booksimon set FormatChildCode
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

if exists (select * from dbo.sysobjects where id = object_id(N'[dbo].[imp_300012053001]') and OBJECTPROPERTY(id, N'IsProcedure') = 1)
drop procedure [dbo].[imp_300012053001]
GO

CREATE PROCEDURE dbo.imp_300012053001 
  
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

DECLARE @v_elementval		VARCHAR(4000),
	@v_errcode		INT,
  	@v_errmsg 		VARCHAR(4000),
	@v_elementdesc		VARCHAR(4000),
	@v_elementkey		INT,
	@v_FormatChildCode 		VARCHAR(100),
	@v_FormatChildCodeCode		INT,
	@v_new_FormatChildCode		INT,
	@v_cur_FormatChildCode		INT,
	@v_hit			INT,
	@v_bookkey 		INT
	
BEGIN
	SET @v_hit = 0
	SET @v_FormatChildCode = 0
	SET @v_FormatChildCodeCode = 0
	SET @v_errcode = 1
	SET @v_errmsg = 'FormatChildCode updated'
	SET @v_bookkey = dbo.resolve_keyset(@i_titlekeyset,1)

	/*GET IMPORTED FormatChildCode VALUE*/
	SELECT @v_FormatChildCode =  originalvalue
	FROM imp_batch_detail 
	WHERE batchkey = @i_batch
      			AND row_id = @i_row
			AND elementseq = @i_elementseq
			AND elementkey = 100012053

	/* GET CURRENT FormatChildCode VALUE */
	SELECT @v_cur_FormatChildCode = COALESCE(FormatChildCode,-1)
	FROM booksimon
    	WHERE bookkey=@v_bookkey 

	select @v_new_FormatChildCode = gt.datacode
	from
		gentables gt
		inner join gentables_ext gte on gt.tableid=gte.tableid and gt.datacode=gte.datacode
	where 
		gt.tableid=300 
		and gt.deletestatus='N'
		and gte.onixcode = @v_FormatChildCode
		
	if @v_cur_FormatChildCode <> @v_new_FormatChildCode  
		begin
			update booksimon set FormatChildCode = @v_new_FormatChildCode  where bookkey = @v_bookkey
			SET @o_writehistoryind = 1
		end

	EXECUTE imp_write_feedback @i_batch, @i_row,100012053 , @i_elementseq ,@i_dmlkey , @v_errmsg, @v_errcode, 3

END

GO
SET QUOTED_IDENTIFIER OFF 
GO
SET ANSI_NULLS ON 
GO

GRANT EXECUTE ON dbo.[imp_300012053001] to PUBLIC 
GO
