/******************************************************************************
**  Name: imp_300012004001
**  Desc: IKE Add/Replace Carton Quantity
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

if exists (select * from dbo.sysobjects where id = object_id(N'[dbo].[imp_300012004001]') and OBJECTPROPERTY(id, N'IsProcedure') = 1)
drop procedure [dbo].[imp_300012004001]
GO

CREATE PROCEDURE dbo.imp_300012004001 
  
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

/* Add/Replace Carton Quantity */

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
	@v_cartonqty		INT,
	@v_count                INT


BEGIN
	SET @o_writehistoryind = 0
	SET @v_errcode = 1
	SET @v_errmsg = 'Carton Quantity Updated'
	SET @v_bookkey = dbo.resolve_keyset(@i_titlekeyset,1)
	SET @v_cartonqty = 0
	SET @v_count = 0

	SELECT @v_elementval =  COALESCE(originalvalue,0),
		@v_elementkey = b.elementkey
	FROM imp_batch_detail b , imp_DML_elements d
	WHERE b.batchkey = @i_batch
      				AND b.row_id = @i_row
				AND b.elementseq = @i_elementseq
				AND b.elementkey = d.elementkey
				AND d.DMLkey = @i_dmlkey



/* IF @elementval <> EXISTING CARTON QUANTITY THEN UPDATE BINDING SPECS */

	SELECT @v_count = COUNT(*)
        FROM bindingspecs
        WHERE bookkey = @v_bookkey

       	IF @v_count > 0
                BEGIN
			SELECT @v_cartonqty = COALESCE(cartonqty1,0)
			FROM 	bindingspecs
			WHERE	bookkey = @v_bookkey
			AND printingkey = 1

			IF @v_cartonqty <> @v_elementval
				BEGIN
					UPDATE bindingspecs
					SET cartonqty1 = @v_elementval,
					lastuserid = @i_userid,
					lastmaintdate = GETDATE()
					WHERE bookkey = @v_bookkey
					AND printingkey = 1
			
					SET @o_writehistoryind = 1
				END
		END
	ELSE
		BEGIN
			INSERT INTO bindingspecs(bookkey,printingkey,cartonqty1,lastuserid,lastmaintdate)
                        VALUES(@v_bookkey,1,@v_elementval,@i_userid,GETDATE())

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

GRANT EXECUTE ON dbo.[imp_300012004001] to PUBLIC 
GO
