SET QUOTED_IDENTIFIER ON
GO

SET ANSI_NULLS ON
GO

/******************************************************************************
**  Name: imp_main
**  Desc: IKE main routine that runs the actual import
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
		FROM dbo.sysobjects
		WHERE id = object_id(N'[dbo].[imp_main]')
			AND OBJECTPROPERTY(id, N'IsProcedure') = 1
		)
	DROP PROCEDURE [dbo].[imp_main]
GO

CREATE PROCEDURE imp_main @i_sourcetype VARCHAR(20)
	,@i_sourcedirectory VARCHAR(400)
	,@i_sourcename VARCHAR(400)
	,@i_sourcename_ext VARCHAR(400)
	,@io_batch_number INT OUTPUT
	,@i_process_level INT
	,@i_templatekey INT
	,@i_userid VARCHAR(50)
	,@i_orgkeyset VARCHAR(400)
	,@o_error_code INT OUTPUT
	,@o_error_desc VARCHAR(2000) OUTPUT
	,@i_ReProcessBatchKey INT = 0
	,@i_ReProcessBatchType VARCHAR(50) = ''
	,@i_SourceXML XML = NULL
AS
DECLARE @v_end_processing INT
	,@v_tablename VARCHAR(50)
	,@v_errcode INT
	,@v_errmsg VARCHAR(500)
	,@v_rowcnt INT
	,@v_batchdesc VARCHAR(500)
	,@v_batchsourcedesc VARCHAR(500)

-- sources: text,excel,preloaded,table
-- process level: 0=stage,1=audit,2=w/warnings,3=w/errors,4=perfect
BEGIN
	SET @v_errcode = 0
	SET @v_errmsg = ''

	IF @io_batch_number IS NULL
	BEGIN
		SELECT @io_batch_number = coalesce(max(batchkey) + 1, 1)
		FROM imp_batch_master
	END

	IF @i_sourcetype NOT IN (
			'preloaded'
			,'prevalidated'
			)
	BEGIN
		EXEC imp_remove_batch @io_batch_number

		SET @v_batchdesc = coalesce(@i_sourcetype, 'n/a') + ' import on ' + cast(getdate() AS VARCHAR(40))
		SET @v_batchsourcedesc = coalesce(@i_sourcetype, 'n/a') + ' - ' + coalesce(@i_sourcename_ext, 'n/a')

		INSERT INTO imp_batch_master (
			batchkey
			,batchdesc
			,sourcedesc
			,clientid
			,importstatus
			,templatekey
			,processtype
			,rptlevel
			,latsuserid
			,lastmaintdate
			)
		VALUES (
			@io_batch_number
			,@v_batchdesc
			,@v_batchsourcedesc
			,NULL
			,NULL
			,@i_templatekey
			,@i_process_level
			,1
			,@i_userid
			,getdate()
			)
	END
	ELSE
	BEGIN
		IF @io_batch_number IS NULL
		BEGIN
			SET @v_errmsg = 'batch number required for PRELOOADED or PREVALIDATED run'

			EXECUTE imp_write_feedback @io_batch_number,NULL,NULL,NULL,NULL,@v_errmsg,3,1

			RETURN
		END
	END

	IF @i_sourcetype <> 'prevalidated'
	BEGIN
		EXEC imp_load_main @i_sourcetype
			,@i_sourcedirectory
			,@i_sourcename
			,@i_sourcename_ext
			,@io_batch_number
			,@i_templatekey
			,@i_userid
			,@v_errcode OUTPUT
			,@v_errmsg OUTPUT
			,@i_ReProcessBatchKey
			,@i_ReProcessBatchType			
			,@i_SourceXML 

		IF @v_errcode <> - 1 AND @i_process_level > 0
		BEGIN
			EXEC imp_validation_main @io_batch_number
				,@i_templatekey
				,@i_userid
		END
	END

	IF @v_errcode <> - 1 AND @i_process_level > 1
	BEGIN
		EXEC imp_dml_main @io_batch_number
			,@i_templatekey
			,@i_userid
			,@v_errcode OUTPUT
			,@v_errmsg OUTPUT
	END
END
GO

SET QUOTED_IDENTIFIER OFF
GO

SET ANSI_NULLS ON
GO

GRANT EXECUTE
	ON imp_main
	TO PUBLIC
GO

