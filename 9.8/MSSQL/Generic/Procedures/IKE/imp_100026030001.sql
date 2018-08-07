/******************************************************************************
**  Name: imp_100026030001
**  Desc: IKE  Corporate Name to author last name and corporate indicator
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

IF EXISTS (
		SELECT *
		FROM dbo.sysobjects
		WHERE id = object_id(N'[dbo].[imp_100026030001]')
			AND OBJECTPROPERTY(id, N'IsProcedure') = 1
		)
	DROP PROCEDURE [dbo].[imp_100026030001]
GO

CREATE PROCEDURE dbo.imp_100026030001 @i_batchkey INT, @i_row INT,
	--  @i_elementkey int,
	@i_elementseq INT, @i_templatekey INT, @i_rulekey BIGINT, @i_level INT, @i_userid VARCHAR(50)
AS
/* Corporate Name to author last name and corporate indicator */
BEGIN
	DECLARE @v_errcode INT, @v_new_value VARCHAR(4000), @v_errlevel INT, @v_msg VARCHAR(4000),@v_Existing100026000 VARCHAR(4000)

	BEGIN
		SET @v_errcode = 0
		SET @v_errlevel = 0
		SET @v_msg = 'Corporate indicator added'

		SELECT @v_new_value = originalvalue
		FROM imp_batch_detail
		WHERE batchkey = @i_batchkey
			AND row_id = @i_row
			AND elementseq = @i_elementseq
			AND elementkey = 100026030

		BEGIN TRY
			INSERT INTO imp_batch_detail (batchkey, row_id, elementkey, elementseq, originalvalue, lastuserid, lastmaintdate)
			VALUES (@i_batchkey, @i_row, 100026000, @i_elementseq, @v_new_value, @i_userid, getdate())
		END TRY

		BEGIN CATCH
			SET @v_msg='KeyNames was not added because it already exisited in imp_batch_deatail'
			EXECUTE imp_write_feedback @i_batchkey, @i_row, NULL, @i_elementseq, @i_rulekey, @v_msg, 2, 1
			
			SELECT @v_Existing100026000=originalvalue
			FROM imp_batch_detail
			WHERE batchkey=@i_batchkey
				AND row_id=@i_row
				AND elementkey=100026000
				AND elementseq=@i_elementseq
				
			IF @v_Existing100026000<>@v_new_value AND LEN(COALESCE(@v_new_value,''))>0
			BEGIN
				UPDATE imp_batch_detail
				SET originalvalue=@v_new_value
				WHERE batchkey=@i_batchkey
					AND row_id=@i_row
					AND elementkey=100026000
					AND elementseq=@i_elementseq
				SET @v_msg='KeyNames was Updated to: ' + COALESCE(@v_new_value,'*NULL*')
				EXECUTE imp_write_feedback @i_batchkey, @i_row, NULL, @i_elementseq, @i_rulekey, @v_msg, 2, 1
			END 

		END CATCH

		BEGIN TRY
			INSERT INTO imp_batch_detail (batchkey, row_id, elementkey, elementseq, originalvalue, lastuserid, lastmaintdate)
			VALUES (@i_batchkey, @i_row, 100026004, @i_elementseq, 1, @i_userid, getdate())
		END TRY

		BEGIN CATCH
			SET @v_msg='Corporate indicator was not added because it already exisited in imp_batch_deatail'
			EXECUTE imp_write_feedback @i_batchkey, @i_row, NULL, @i_elementseq, @i_rulekey, @v_msg, 2, 1
		END CATCH

		IF @v_errlevel >= @i_level
		BEGIN
			EXECUTE imp_write_feedback @i_batchkey, @i_row, NULL, @i_elementseq, @i_rulekey, @v_msg, @v_errlevel, 1
		END
	END
END
GO

SET QUOTED_IDENTIFIER OFF
GO

SET ANSI_NULLS ON
GO

GRANT EXECUTE
	ON dbo.[imp_100026030001]
	TO PUBLIC
GO


