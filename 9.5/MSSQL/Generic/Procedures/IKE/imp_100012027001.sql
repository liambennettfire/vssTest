/******************************************************************************
**  Name: imp_100012027001
**  Desc: IKE Parse Prefix from Title
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

if exists (select * from dbo.sysobjects where id = object_id(N'[dbo].[imp_100012027001]') and OBJECTPROPERTY(id, N'IsProcedure') = 1)
drop procedure [dbo].[imp_100012027001]
GO

CREATE PROCEDURE dbo.imp_100012027001 
  
  @i_batchkey int,
  @i_row int,
--  @i_elementkey int,
  @i_elementseq int,
  @i_templatekey int,
  @i_rulekey bigint,
  @i_level int,
  @i_userid varchar(50)
AS

/* Parse Prefix from Title */

BEGIN 

DECLARE @v_elementval		VARCHAR(4000),
	@v_title 		VARCHAR(4000),
	@v_prefix 		VARCHAR(4000),
  	@v_errlevel 		INT,
  	@v_msg 			VARCHAR(4000),
	@count			INT

BEGIN
	SET @v_errlevel = 0
	SET @v_prefix = NULL
	SET @v_title = NULL
	SET @count = 0	
	SET @v_msg = 'Parse Title Prefix'
	
	SELECT @v_elementval = originalvalue
	FROM imp_batch_detail
	WHERE batchkey=@i_batchkey
			AND row_id = @i_row
			AND elementseq = @i_elementseq
			AND elementkey = 100012027
/* CHECK TO SEE IF PREFIX ROW EXIST IN BATCH DETAILS	*/
	SELECT @count = count(*)
	FROM imp_batch_detail
	WHERE row_id = @i_row
		AND batchkey = @i_batchkey
		AND elementkey = 100012027

	IF @count < 1
		BEGIN

	IF SUBSTRING(@v_elementval,1,2) = 'A '
		BEGIN
			SET @v_prefix = 'A'
			SET @v_title = substring(@v_elementval,3,len(@v_title ))
		END

	IF SUBSTRING(@v_elementval,1,3) = 'An '
		BEGIN
			SET @v_prefix = 'An'
			SET @v_title = substring(@v_elementval,4,len(@v_title ))
		END

	IF SUBSTRING(@v_elementval,1,4) = 'The '
		BEGIN
			SET @v_prefix = 'The'
			SET @v_title = substring(@v_elementval,5,len(@v_title ))
		END

	IF @v_prefix IS NOT NULL AND @v_title IS NOT NULL
		BEGIN
			INSERT INTO imp_batch_detail(batchkey,row_id,elementkey,elementseq,originalvalue,lobkey,lastuserid,lastmaintdate)
			VALUES (@i_batchkey,@i_row,100012028,@i_elementseq,@v_prefix,NULL,'imp_load_master',getdate())

			UPDATE imp_batch_detail
			SET originalvalue = @v_title
			WHERE batchkey = @i_batchkey
					AND row_id = @i_row
					AND elementseq = @i_elementseq
					AND elementkey = 100012027

			SET @v_msg = 'Parsed Title Prefix ('+@v_prefix+') from Title'
			SET @v_errlevel = 1
		END

IF @v_errlevel >= @i_level 
		BEGIN
			EXECUTE imp_write_feedback @i_batchkey, @i_row, 100012027, @i_elementseq, 100012027001 , @v_msg, @v_errlevel, 1
		END
	END				
				

END

end

GO
SET QUOTED_IDENTIFIER OFF 
GO
SET ANSI_NULLS ON 
GO

GRANT EXECUTE ON dbo.[imp_100012027001] to PUBLIC 
GO
