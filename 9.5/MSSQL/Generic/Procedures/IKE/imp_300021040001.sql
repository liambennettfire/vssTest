/******************************************************************************
**  Name: imp_300021040001
**  Desc: IKE Add/Replace Custom Indicator 10
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

if exists (select * from dbo.sysobjects where id = object_id(N'[dbo].[imp_300021040001]') and OBJECTPROPERTY(id, N'IsProcedure') = 1)
drop procedure [dbo].[imp_300021040001]
GO

CREATE PROCEDURE dbo.imp_300021040001 
  
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

/* Add/Replace Custom Indicator 10 */

BEGIN 

DECLARE @v_elementval			VARCHAR(4000),
	@v_elementdesc			VARCHAR(4000),
	@v_elementkey			INT,
	@v_errcode			INT,
  	@v_errmsg 			VARCHAR(4000),
	@v_bookkey 			INT,
	@v_new_customind		INT,
	@v_curr_customind		INT,
	@v_rowcount			INT
	
BEGIN
	SET @v_rowcount = 0
	SET @v_new_customind = 0
	SET @v_curr_customind = 0
	SET @o_writehistoryind = 0
	SET @v_errcode = 1
	SET @v_errmsg = 'Custom Intdicator 10 Updated'
	SET @v_bookkey = dbo.resolve_keyset(@i_titlekeyset,1)

/*  GET IMPORTED CUSTOM Indicator 10 			*/
	SELECT @v_elementval =  originalvalue,
		@v_elementkey = b.elementkey
	FROM imp_batch_detail b , imp_DML_elements d
	WHERE b.batchkey = @i_batch
      				AND b.row_id = @i_row
				AND b.elementseq = @i_elementseq
				AND d.dmlkey = @i_dmlkey
				AND d.elementkey = b.elementkey

	SELECT @v_new_customind = CASE
						WHEN UPPER(@v_elementval) IN ('Y','YES')  THEN 1
						WHEN UPPER(@v_elementval) IN ('N','NO')  THEN 0
					  ELSE
						0
				   END

	SELECT @v_elementdesc = COALESCE(customfieldlabel,'Custom Indicator 10')
	FROM customfieldsetup
	WHERE customfieldname = 'customind10'

	SELECT @v_rowcount = COUNT(*)
	FROM bookcustom
	WHERE bookkey = @v_bookkey

	IF @v_rowcount = 0
		BEGIN
			INSERT INTO bookcustom(bookkey,customind10,lastuserid,lastmaintdate)
			VALUES(@v_bookkey,@v_new_customind,@i_userid,GETDATE())

			SET @o_writehistoryind = 1
		END
	ELSE
		BEGIN	
/* GET CURRENT CURRENT  CUSTOM Indicator 10 VALUE		*/
			SELECT @v_curr_customind = COALESCE(customind10,-1)--mk20130606>Case 23834 IKE import fails to import non-empty 
			FROM bookcustom
    			WHERE bookkey=@v_bookkey 

			IF @v_new_customind <> @v_curr_customind
				BEGIN
					UPDATE bookcustom
					SET customind10 = @v_new_customind,
						lastuserid = @i_userid,
						lastmaintdate = GETDATE()
					WHERE bookkey = @v_bookkey
	
					SET @o_writehistoryind = 1
				END
			END

	IF @v_errcode >= @i_level
		BEGIN
			EXECUTE imp_write_feedback @i_batch, @i_row,@v_elementkey , @i_elementseq ,@i_dmlkey , @v_errmsg, @v_errcode, 3
    		END

END

end

GO
SET QUOTED_IDENTIFIER OFF 
GO
SET ANSI_NULLS ON 
GO

GRANT EXECUTE ON dbo.[imp_300021040001] to PUBLIC 
GO
