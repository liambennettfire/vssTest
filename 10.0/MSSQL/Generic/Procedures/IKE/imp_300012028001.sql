/******************************************************************************
**  Name: imp_300012028001
**  Desc: IKE Title Prefix
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

if exists (select * from dbo.sysobjects where id = object_id(N'[dbo].[imp_300012028001]') and OBJECTPROPERTY(id, N'IsProcedure') = 1)
drop procedure [dbo].[imp_300012028001]
GO

CREATE PROCEDURE dbo.imp_300012028001 
  
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

/* Update Title Prefix */

BEGIN 

DECLARE @v_elementval 		VARCHAR(4000),
	@v_errcode 		INT,
	@v_errmsg 		VARCHAR(4000),
	@v_elementdesc 		VARCHAR(4000),
	@v_lobcheck 		VARCHAR(20),
	@v_lobkey 		INT,
	@v_bookkey 		INT,
	@v_titleprefix		CHAR(3),
	@v_elementkey		BIGINT

BEGIN
	SET @o_writehistoryind = 0
	SET @v_errcode = 1
	SET @v_errmsg = 'Title prefix updated'
	SET @v_bookkey = dbo.resolve_keyset(@i_titlekeyset,1)

	SELECT @v_elementval =  originalvalue,
		@v_elementkey = b.elementkey
	FROM imp_batch_detail b , imp_DML_elements d
	WHERE b.batchkey = @i_batch
      				AND b.row_id = @i_row
				AND b.elementseq = @i_elementseq
				AND b.elementkey = d.elementkey
				AND d.DMLkey = @i_dmlkey

	SELECT @v_titleprefix = titleprefix
	FROM bookdetail
	WHERE bookkey  = @v_bookkey
	
	IF (@v_titleprefix is not null and @v_elementval is null) or (COALESCE(@v_titleprefix,'') <> COALESCE(@v_elementval,''))
	
		BEGIN
			UPDATE bookdetail
      			SET titleprefix = @v_elementval
      			WHERE bookkey = @v_bookkey

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

GRANT EXECUTE ON dbo.[imp_300012028001] to PUBLIC 
GO


