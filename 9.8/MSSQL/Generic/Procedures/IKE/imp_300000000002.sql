/******************************************************************************
**  Name: imp_300000000002
**  Desc: IKE Insert New Gentables Entry
**  Auth: Bennett     
**  Date: 5/9/2016
*******************************************************************************
**  Change History
*******************************************************************************
**  Date:        Author:     Description:
*   --------     --------    -------------------------------------------
**  5/9/2016     Bennett     original
*******************************************************************************/
IF EXISTS (
		SELECT *
		FROM sys.objects
		WHERE object_id = OBJECT_ID(N'[dbo].[imp_300000000002]')
			AND type IN (N'P', N'PC')
		)
	DROP PROCEDURE [dbo].[imp_300000000002]
GO

SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO

CREATE PROCEDURE [dbo].[imp_300000000002] @i_batch INT
	,@i_row INT
	,@i_dmlkey BIGINT
	,@i_titlekeyset VARCHAR(500)
	,@i_contactkeyset VARCHAR(500)
	,@i_templatekey INT
	,@i_elementseq INT
	,@i_level INT
	,@i_userid VARCHAR(50)
	,@i_newtitleind INT
	,@i_newcontactind INT
	,@o_writehistoryind INT OUTPUT

AS
/* Insert New Gentables Entry */
BEGIN
DECLARE @v_elementval VARCHAR(4000)
	,@v_errcode INT
	,@v_errmsg VARCHAR(4000)
	,@v_elementdesc VARCHAR(4000)
	,@v_elementkey BIGINT
	,@v_desc VARCHAR(40)
	,@v_code VARCHAR(30)
	,@i_datacode INT
	,@i_newcodeind INT
	,@v_filterlevel INT
	,@i_orgkey INT
	,@v_tableid INT
	,@v_msg VARCHAR(4000)
	,@v_bookkey INT


	BEGIN
		SET @v_tableid = 0
		SET @i_datacode = 0
		SET @i_newcodeind = 0
		SET @v_filterlevel = 0
		SET @o_writehistoryind = 0
		SET @v_errcode = 1
		SET @v_bookkey = dbo.resolve_keyset(@i_titlekeyset, 1)

		/*  GET IMPORTED VALUE, KEY, AND TABLEID			*/
		BEGIN
			SELECT @v_elementval = b.originalvalue, @v_elementkey = b.elementkey, @v_tableid = e.tableid
			FROM imp_batch_detail b, imp_DML_elements d, imp_element_defs e
			WHERE b.batchkey = @i_batch
				AND b.row_id = @i_row
				AND b.elementseq = @i_elementseq
				AND d.dmlkey = @i_dmlkey
				AND d.elementkey = b.elementkey
				AND d.elementkey = e.elementkey

			SELECT @v_elementdesc = COALESCE(elementdesc, '')
			FROM imp_element_defs
			WHERE elementkey = @v_elementkey

			SELECT @v_errmsg = @v_elementdesc + ' Updated'

			/* FIND DESCRIPTION ON GENTABLES - IF NOT PRESENT, INSERT GENTABLES AND GENTABLESORGLEVEL ENTRIES	*/
			SELECT @i_datacode = COALESCE(datacode, 0)
			FROM gentables
			WHERE tableid = @v_tableid
				AND datadesc = @v_elementval
			IF @i_datacode = 0
			BEGIN
				SELECT @i_datacode = COALESCE(datacode, 0)
				FROM gentables
				WHERE tableid = @v_tableid
					AND alternatedesc1 = @v_elementval
				IF @i_datacode = 0
					AND LEN(@v_elementval) > 0
				BEGIN
					EXECUTE imp_gentables @v_tableid, NULL, @v_elementval, '1', 'Y', @i_datacode out, @i_newcodeind out

					IF @i_newcodeind = 1
					BEGIN
						SET @v_msg = ''
						SET @v_msg = 'Added New ' + @v_elementdesc + ' with a description of ' + @v_elementval

						EXECUTE imp_write_feedback @i_batch, @i_row, @v_elementkey, @i_elementseq, @i_dmlkey, @v_msg, @v_errcode, 3

						SELECT @v_filterlevel = dbo.get_GentableFilterkey(@v_tableid)

						SELECT @i_orgkey = orgentrykey
						FROM bookorgentry
						WHERE bookkey = @v_bookkey
							AND orglevelkey = @v_filterlevel

						IF @v_filterlevel > 0
						BEGIN
							EXECUTE imp_gentables_filter @v_tableid, @i_datacode, @i_orgkey, @i_userid

							SET @v_msg = ''
							SET @v_msg = 'Added Group Level Filter ' + @v_elementval + ' at level ' + CONVERT(VARCHAR(10), @v_filterlevel) + ' for Group Entry Key ' + CONVERT(VARCHAR(10), @i_orgkey)

							EXECUTE imp_write_feedback @i_batch, @i_row, @v_elementkey, @i_elementseq, @i_dmlkey, @v_msg, @v_errcode, 3
						END
					END
				END
			END
		END

		IF @v_errcode < 2
		BEGIN
			EXECUTE imp_write_feedback @i_batch, @i_row, @v_elementkey, @i_elementseq, @i_dmlkey, @v_errmsg, @v_errcode, 3
		END
	END
END
GO

SET QUOTED_IDENTIFIER OFF 
GO
SET ANSI_NULLS ON 
GO

GRANT EXECUTE ON dbo.[imp_300000000002] to PUBLIC 
GO