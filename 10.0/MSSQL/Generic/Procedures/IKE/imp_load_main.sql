SET QUOTED_IDENTIFIER ON
GO

/******************************************************************************
**  Name: imp_load_main
**  Desc: IKE main loader routine
**  Auth: Bennett     
**  Date: 5/9/2016
*******************************************************************************
**  Change History
*******************************************************************************
**  Date:        Author:     Description:
*   --------     --------    -------------------------------------------
**  5/9/2016     Bennett     original
**  5/26/2016    Bennett     adjustment to support XML source as a variable
** 5/01/2017     Donovan     Extra paramter being passed into imp_load_excel -- @i_SourceXML, needed to be removed
*******************************************************************************/

SET ANSI_NULLS ON
GO

IF EXISTS (
		SELECT *
		FROM dbo.sysobjects
		WHERE id = object_id(N'[dbo].[imp_load_main]')
			AND OBJECTPROPERTY(id, N'IsProcedure') = 1
		)
	DROP PROCEDURE [dbo].[imp_load_main]
GO

CREATE PROCEDURE [dbo].[imp_load_main] @i_sourcetype VARCHAR(50)
	,@i_sourcedirectory VARCHAR(250)
	,@i_sourcename VARCHAR(250)
	,@i_sourcename_ext VARCHAR(500)
	,@i_batch_number INT
	,@i_templatekey INT
	,@i_userid VARCHAR(50)
	,@o_errcode INT OUTPUT
	,@o_errmsg VARCHAR(500) OUTPUT
	,@i_ReProcessBatchKey INT = 0
	,@i_ReProcessBatchType VARCHAR(50) = ''
	,@i_SourceXML XML = NULL
AS
DECLARE @v_rowcnt INT
	,@v_tablename VARCHAR(50)
	,@v_tab VARCHAR(50)
	,@v_exists INT
	,@v_source_dir_name VARCHAR(500)
	,@v_serverity INT

-- sources: text,excel,preloaded,table
-- process level: 1=audit,2=w/warnings,3=w/errors,4=perfect
BEGIN
	SET @o_errcode = 0
	SET @v_tablename = NULL
	SET @v_source_dir_name = replace(@i_sourcedirectory + '\' + @i_sourcename, '\\', '\')

	IF upper(@i_sourcetype) = 'XML'
	BEGIN
		EXEC master..xp_fileexist @v_source_dir_name
			,@v_exists OUTPUT

		IF @v_exists = 0
		BEGIN
			SET @o_errcode = - 1
			SET @o_errmsg = 'missing files: ' + @i_sourcetype

			EXECUTE imp_write_feedback @i_batch_number,NULL,NULL,NULL,NULL,@o_errmsg,3,1
		END
		ELSE
		BEGIN
			EXEC imp_load_xml @i_batch_number
				,@v_source_dir_name
				,@i_sourcename_ext
				,@i_templatekey
				,@i_userid
				,@o_errcode OUTPUT
				,@o_errmsg OUTPUT
		END
	END

	IF upper(@i_sourcetype) in ('XMLexplicit','XMLexplicitVariable')
	BEGIN
		EXEC master..xp_fileexist @v_source_dir_name
			,@v_exists OUTPUT

		IF @v_exists = 0 AND @i_SourceXML IS NULL
		BEGIN
			SET @o_errcode = - 1
			SET @o_errmsg = 'missing files: ' + @i_sourcetype

			EXECUTE imp_write_feedback @i_batch_number,NULL,NULL,NULL,NULL,@o_errmsg,3,1
		END
		ELSE
		BEGIN
			EXEC imp_load_xml_explicit @i_batch_number
				,@v_source_dir_name
				,@i_sourcename_ext
				,@i_templatekey
				,@i_userid
				,@o_errcode OUTPUT
				,@o_errmsg OUTPUT
				,@i_SourceXML
		END
	END

	IF upper(@i_sourcetype) = 'EXCEL'
	BEGIN
		EXEC master..xp_fileexist @v_source_dir_name
			,@v_exists OUTPUT

		IF @v_exists = 0 AND @i_SourceXML IS NULL
		BEGIN
			SET @o_errcode = - 1
			SET @o_errmsg = 'missing files: ' + @i_sourcetype

			EXECUTE imp_write_feedback @i_batch_number,NULL,NULL,NULL,NULL,@o_errmsg,3,1
		END
		ELSE
		BEGIN
			SET @v_tablename = '##ike_excel_' + cast(@i_batch_number AS VARCHAR(20))
			SET @v_tab = @i_sourcename_ext + '$'

			EXEC imp_load_excel @i_batch_number
				,@v_source_dir_name
				,@v_tab
				,@v_tablename
				,@o_errcode OUTPUT
				,@o_errmsg OUTPUT
				
		END
	END

	IF upper(@i_sourcetype) = 'TEXT'
	BEGIN
		EXEC master..xp_fileexist @i_sourcetype
			,@v_exists OUTPUT

		IF @v_exists = 0
		BEGIN
			SET @o_errcode = - 1
			SET @o_errmsg = 'missing files: ' + @i_sourcetype
		END
		ELSE
		BEGIN
			SET @v_tablename = '#ike_text_' + cast(@i_batch_number AS VARCHAR(20))
				-- call load text
		END
	END

	IF upper(@i_sourcetype) = 'TABLE'
	BEGIN
		SET @v_tablename = @i_sourcename
			--@v_source_dir_name 
			-- verf table
			-- set v_tablename
	END

	IF upper(@i_sourcetype) = 'PRELOADED'
	BEGIN
		SELECT @v_rowcnt = count(*)
		FROM imp_batch_master
		WHERE batchkey = @i_batch_number

		IF @v_rowcnt <> 1
		BEGIN
			SET @o_errcode = - 1
			SET @o_errmsg = 'no batch created for number ' + cast(@i_batch_number AS VARCHAR(20))

			EXECUTE imp_write_feedback @i_batch_number,NULL,NULL,NULL,NULL,@o_errmsg,3,1
		END

		SELECT @v_rowcnt = count(*)
		FROM imp_batch_detail
		WHERE batchkey = @i_batch_number

		IF @v_rowcnt = 0
		BEGIN
			SET @o_errcode = - 1
			SET @o_errmsg = 'no data to import for batch number ' + cast(@i_batch_number AS VARCHAR(20))

			EXECUTE imp_write_feedback @i_batch_number,NULL,NULL,NULL,NULL,@o_errmsg,3,1
		END
	END

	IF @v_tablename IS NOT NULL
	BEGIN
		-- geneterate batch
		EXEC imp_tbl_to_batch @v_tablename
			,@i_batch_number
			,@i_templatekey
			,@i_userid
	END
	
	--ReProcess an exsiting batchkey
	IF @i_ReProcessBatchKey > 0
	BEGIN
		SET @o_errmsg='ReProcessing BatchKey: ' + cast(@i_ReProcessBatchKey as varchar(max))
		EXECUTE imp_write_feedback @i_batch_number,NULL,NULL,NULL,NULL,@o_errmsg,1,1	
		SET @o_errmsg='ReProcess BatchType: ' + cast(@i_ReProcessBatchType as varchar(max))
		EXECUTE imp_write_feedback @i_batch_number,NULL,NULL,NULL,NULL,@o_errmsg,1,1	
		
		--mk2012.11.15> TASK: IKE reprocess batch error
		IF @i_ReProcessBatchKey = @i_batch_number
		BEGIN
			SET @o_errmsg='The BatchKey to be Reprocessed (' + cast(@i_ReProcessBatchKey as varchar(max))+') is the same as the current Job''s Batchkey.  This job will be processed in its entirety'
			EXECUTE imp_write_feedback @i_batch_number,NULL,NULL,NULL,NULL,@o_errmsg,2,1
		END ELSE BEGIN
			IF isnumeric(@i_ReProcessBatchType)>0 SET @v_serverity=CAST(@i_ReProcessBatchType as int)
			IF @v_serverity>0
			BEGIN
				
				/*GET A LIST OF ROWS FOR A GIVEN BATCHKEY THAT FAILED THE LAST IMPORT AND REMOVE ALL ROWS OTHER THAN THE EXCEPTION ROWS*/
				DELETE FROM imp_batch_detail
				WHERE	row_id NOT IN (
							SELECT DISTINCT	row_id
							FROM	imp_feedback
							WHERE	serverity >= @v_serverity
									AND batchkey = @i_ReProcessBatchKey
									AND row_id IS NOT NULL
						)
						AND batchkey = @i_batch_number

				DELETE FROM imp_feedback
				WHERE	row_id NOT IN (
							SELECT DISTINCT	row_id
							FROM	imp_feedback
							WHERE	serverity >= @v_serverity
									AND batchkey = @i_ReProcessBatchKey
									AND row_id IS NOT NULL
						)
						AND batchkey = @i_batch_number
						AND row_id is not null
												
			END ELSE BEGIN
				SET @o_errmsg='Unkown ReProcessBatchType (' + cast(@i_ReProcessBatchType as varchar(max)) + '). This job will be processed in its entirety'
				EXECUTE imp_write_feedback @i_batch_number,NULL,NULL,NULL,NULL,@o_errmsg,2,1
			END
		END
	END
	
	SELECT @v_rowcnt = count(*)
	FROM imp_batch_detail
	WHERE batchkey = @i_batch_number

	IF @v_rowcnt = 0
	BEGIN
		SET @o_errcode = - 1
		SET @o_errmsg = 'no data to import for batch number ' + cast(@i_batch_number AS VARCHAR(20))

		EXECUTE imp_write_feedback @i_batch_number,NULL,NULL,NULL,NULL,@o_errmsg,3,1
	END
END

