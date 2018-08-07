/******************************************************************************
**  Name: imp_300012017001
**  Desc: IKE Add/Replace Pub Month
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

if exists (select * from dbo.sysobjects where id = object_id(N'[dbo].[imp_300012017001]') and OBJECTPROPERTY(id, N'IsProcedure') = 1)
drop procedure [dbo].[imp_300012017001]
GO

CREATE PROCEDURE dbo.imp_300012017001 
  
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

/* Add/Replace Pub Month */

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
	@v_pubmonthcode		INT

BEGIN
	SET @o_writehistoryind = 0
	SET @v_errcode = 1
	SET @v_errmsg = 'Pub Month Updated'
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
/*  GET IMPORTED PUBMONTH 	*/

	SELECT @v_pubmonth = CASE
				WHEN @v_elementval ='January' THEN 1
				WHEN @v_elementval ='Jan' THEN 1
				WHEN @v_elementval ='February' THEN 2
				WHEN @v_elementval ='Feb' THEN 2
				WHEN @v_elementval ='March' THEN 3
				WHEN @v_elementval ='Mar' THEN 3
				WHEN @v_elementval ='April' THEN 4
				WHEN @v_elementval ='Apr' THEN 4
				WHEN @v_elementval ='May' THEN 5
				WHEN @v_elementval ='June' THEN 6
				WHEN @v_elementval ='Jun' THEN 6
				WHEN @v_elementval ='July' THEN 7
				WHEN @v_elementval ='Jul' THEN 7
				WHEN @v_elementval ='August' THEN 8
				WHEN @v_elementval ='Aug' THEN 8
				WHEN @v_elementval ='September' THEN 9
				WHEN @v_elementval ='Sep' THEN 9
				WHEN @v_elementval ='October' THEN 10
				WHEN @v_elementval ='Oct' THEN 10
				WHEN @v_elementval ='November' THEN 11
				WHEN @v_elementval ='Nov' THEN 11
				WHEN @v_elementval ='December' THEN 12
				WHEN @v_elementval ='Dec' THEN 12
			ELSE
				0
		END
	
/*  GET EXISTING PUB MONTH CODE		*/
	SELECT @v_pubmonthcode = COALESCE(pubmonthcode,0)
	FROM printing
	WHERE bookkey = @v_bookkey
			AND printingkey = 1

/* IF @elementval <> EXISTING Pub MONTH THEN UPDATE PRINTING  */
	
	IF @v_pubmonth <> @v_pubmonthcode
		BEGIN
			UPDATE printing
			SET pubmonthcode = @v_pubmonth,
					lastuserid = @i_userid,
					lastmaintdate = getdate()
			WHERE bookkey = @v_bookkey
					AND printingkey = 1

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

GRANT EXECUTE ON dbo.[imp_300012017001] to PUBLIC 
GO
