/******************************************************************************
**  Name: imp_300020001001
**  Desc: IKE Add/Replace Dates
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
		WHERE id = object_id(N'[dbo].[imp_300020001001]')
			AND OBJECTPROPERTY(id, N'IsProcedure') = 1
		)
	DROP PROCEDURE [dbo].imp_300020001001
GO

CREATE PROCEDURE dbo.imp_300020001001 @i_batch INT
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
/* Add/Replace Dates */
BEGIN
	SET NOCOUNT ON

	DECLARE @v_elementval VARCHAR(4000)
		,@v_errcode INT
		,@v_errmsg VARCHAR(4000)
		,@v_elementdesc VARCHAR(4000)
		,@v_elementkey BIGINT
		,@v_lobcheck VARCHAR(20)
		,@v_lobkey INT
		,@v_taskkey INT
		,@v_bookkey INT
		,@v_printingkey INT
		,@v_hit INT
		,@v_webschedind INT
		,@v_actualind INT
		,@v_sortorder INT
		,@v_new_date DATETIME
		,@v_curr_date DATETIME
		,@v_original_date DATETIME
		,@v_destinationcolumn VARCHAR(50)
		,@v_datetypecode INT
		,@v_datetype VARCHAR(50)
		,@DEBUG INT

	BEGIN
		SET @DEBUG = 0
		SET @v_hit = 0
		SET @v_new_date = NULL
		SET @v_sortorder = 0
		SET @o_writehistoryind = 0
		SET @v_errcode = 1
		SET @v_bookkey = dbo.resolve_keyset(@i_titlekeyset, 1)
		SET @v_printingkey = dbo.resolve_keyset(@i_titlekeyset, 2)

		SELECT @v_elementval = LTRIM(RTRIM(b.originalvalue))
			,@v_elementkey = b.elementkey
			,@v_datetypecode = e.datetypecode
			,@v_destinationcolumn = e.destinationcolumn
		FROM imp_batch_detail b
			,imp_DML_elements d
			,imp_element_defs e
		WHERE b.batchkey = @i_batch
			AND b.row_id = @i_row
			AND b.elementseq = @i_elementseq
			AND d.dmlkey = @i_dmlkey
			AND d.elementkey = b.elementkey
			AND d.elementkey = e.elementkey

		SELECT @v_elementdesc = elementdesc
		FROM imp_element_defs
		WHERE elementkey = @v_elementkey

		SET @v_errmsg = @v_elementdesc + ' Updated'
		SET @v_new_date = dbo.resolve_date(@v_elementval)

		SELECT @v_webschedind = coalesce(optionvalue, 0)
		FROM clientoptions
		WHERE optionid = 72

		IF @DEBUG <> 0 PRINT '/* Add/Replace Dates */'
		IF @DEBUG <> 0 PRINT '@v_new_date = ' + cast(@v_new_date AS VARCHAR(max))
		IF @DEBUG <> 0 PRINT '@v_webschedind = ' + cast(@v_webschedind AS VARCHAR(max))
		IF @DEBUG <> 0 PRINT '@v_datetypecode = ' + cast(@v_datetypecode AS VARCHAR(max))
		IF @DEBUG <> 0 PRINT '@v_bookkey = ' + cast(@v_bookkey AS VARCHAR(max))
		IF @DEBUG <> 0 PRINT '@v_elementval = ' + cast(@v_elementval AS VARCHAR(max))
		
		--PRE-PROCESS @v_datetypecode
		IF @v_datetypecode=20034
		BEGIN
			IF EXISTS (SELECT * FROM bookdates WHERE bookkey = @v_bookkey AND datetypecode = 20034)
			BEGIN
				--this is a "CreatedTime" for DAB IKE imports ... this only happens once
				IF @DEBUG <> 0 PRINT 'SKIP "CreatedTime" for DAB IKE imports ... this only happens once'
				RETURN 
			END ELSE BEGIN
				IF @DEBUG <> 0 PRINT 'PROCESS "CreatedTime" for DAB IKE imports ... this only happens once'
				SET @v_elementval = GETDATE()
				SET @v_new_date = dbo.resolve_date(@v_elementval)
				IF @DEBUG <> 0 PRINT '@v_elementval = ' + cast(@v_elementval AS VARCHAR(max))
				IF @DEBUG <> 0 PRINT '@v_new_date = ' + cast(@v_new_date AS VARCHAR(max))
			END
		END		

		IF @v_datetypecode=422
		BEGIN
			--this is a "LastUpdateTime" for DAB IKE imports ... this only happens every Import
			IF @DEBUG <> 0 PRINT 'PROCESS "LastUpdateTime" for DAB IKE imports ... this happens every Import'
			DELETE FROM bookdates WHERE bookkey = @v_bookkey AND datetypecode = 422
			SET @v_elementval = GETDATE()
			SET @v_new_date = dbo.resolve_date(@v_elementval)
			IF @DEBUG <> 0 PRINT '@v_elementval = ' + cast(@v_elementval AS VARCHAR(max))
			IF @DEBUG <> 0 PRINT '@v_new_date = ' + cast(@v_new_date AS VARCHAR(max))
		END
				
		IF @v_new_date IS NOT NULL AND @v_webschedind = 0
		BEGIN
			SELECT @v_hit = COUNT(*)
			FROM bookdates
			WHERE bookkey = @v_bookkey
				AND datetypecode = @v_datetypecode
				AND printingkey = @v_printingkey

			IF @v_hit = 0
			BEGIN
				SELECT @v_sortorder = COALESCE(MAX(sortorder), 0) + 1
				FROM bookdates
				WHERE bookkey = @v_bookkey

				IF @v_destinationcolumn = 'activedate'
				BEGIN
					INSERT INTO bookdates (
						bookkey
						,printingkey
						,datetypecode
						,activedate
						,lastuserid
						,lastmaintdate
						,sortorder
						,bestdate
						)
					VALUES (
						@v_bookkey
						,1
						,@v_datetypecode
						,@v_new_date
						,@i_userid
						,GETDATE()
						,@v_sortorder
						,@v_new_date
						)
				END

				IF @v_destinationcolumn = 'estdate'
				BEGIN
					INSERT INTO bookdates (
						bookkey
						,printingkey
						,datetypecode
						,estdate
						,lastuserid
						,lastmaintdate
						,sortorder
						,bestdate
						)
					VALUES (
						@v_bookkey
						,1
						,@v_datetypecode
						,@v_new_date
						,@i_userid
						,GETDATE()
						,@v_sortorder
						,@v_new_date
						)
				END
			END

			IF @v_hit = 1
			BEGIN
				IF @v_destinationcolumn = 'activedate'
				BEGIN
					SELECT @v_curr_date = activedate
					FROM bookdates
					WHERE bookkey = @v_bookkey
						AND printingkey = @v_printingkey
						AND datetypecode = @v_datetypecode

					IF CONVERT(VARCHAR(20), @v_new_date, 101) <> CONVERT(VARCHAR(20), @v_curr_date, 101)
						OR @v_curr_date IS NULL
					BEGIN
						UPDATE bookdates
						SET activedate = @v_new_date
							,lastuserid = @i_userid
							,lastmaintdate = GETDATE()
							,bestdate = @v_new_date
						WHERE bookkey = @v_bookkey
							AND printingkey = @v_printingkey
							AND datetypecode = @v_datetypecode

						SET @o_writehistoryind = 1
					END
				END

				IF @v_destinationcolumn = 'estdate'
				BEGIN
					SELECT @v_curr_date = activedate
					FROM bookdates
					WHERE bookkey = @v_bookkey
						AND printingkey = @v_printingkey
						AND datetypecode = @v_datetypecode

					IF CONVERT(VARCHAR(20), @v_new_date, 101) <> CONVERT(VARCHAR(20), @v_curr_date, 101)
						OR @v_curr_date IS NULL
					BEGIN
						UPDATE bookdates
						SET estdate = @v_new_date
							,lastuserid = @i_userid
							,lastmaintdate = GETDATE()
							,bestdate = @v_new_date
						WHERE bookkey = @v_bookkey
							AND printingkey = @v_printingkey
							AND datetypecode = @v_datetypecode

						SET @o_writehistoryind = 1
					END
				END
			END
		END

		IF @v_new_date IS NOT NULL
			AND @v_webschedind = 1
		BEGIN
			IF @DEBUG <> 0 PRINT '@v_new_date is NOT NULL and @v_webschedind=1'
			IF @DEBUG <> 0 PRINT '@v_destinationcolumn = ' + cast(@v_destinationcolumn AS VARCHAR(max))

			IF @v_destinationcolumn = 'estdate'
			BEGIN
				SET @v_actualind = 0
			END
			ELSE --default to active
			BEGIN
				IF @DEBUG <> 0 PRINT 'default to active'

				SET @v_actualind = 1
			END

			SELECT @v_hit = COUNT(*)
			FROM taqprojecttask
			WHERE bookkey = @v_bookkey
				AND datetypecode = @v_datetypecode
				AND printingkey = @v_printingkey

			IF @DEBUG <> 0 PRINT '@v_hit = ' + cast(@v_hit AS VARCHAR(max))

			IF @v_hit = 1
			BEGIN
				SELECT @v_curr_date = activedate
					,@v_original_date = originaldate
				FROM taqprojecttask
				WHERE bookkey = @v_bookkey
					AND printingkey = @v_printingkey
					AND datetypecode = @v_datetypecode

				IF @DEBUG <> 0 PRINT '@v_new_date = ' + cast(@v_new_date AS VARCHAR(max))
				IF @DEBUG <> 0 PRINT '@v_curr_date = ' + coalesce(cast(@v_curr_date AS VARCHAR(max)), '*NULL*')

				IF coalesce(@v_new_date, '') <> coalesce(@v_curr_date, '')
				BEGIN
					IF @DEBUG <> 0 PRINT '@v_new_date<>@v_curr_date '
					IF @DEBUG <> 0 PRINT ' ... update taqprojecttask'

					UPDATE taqprojecttask
					SET activedate = @v_new_date
						,originaldate = coalesce(@v_original_date, @v_new_date)
						,lastuserid = @i_userid
						,lastmaintdate = getdate()
						,keyind = 1
					WHERE bookkey = @v_bookkey
						AND printingkey = @v_printingkey
						AND datetypecode = @v_datetypecode
				END

				IF @DEBUG <> 0
					PRINT 'after update'
			END
			ELSE
			BEGIN
				UPDATE keys
				SET generickey = generickey + 1

				SELECT @v_taskkey = generickey
				FROM keys

				IF @DEBUG <> 0
					PRINT 'insert into taqprojecttask'

				INSERT INTO taqprojecttask (
					taqtaskkey
					,bookkey
					,printingkey
					,activedate
					,originaldate
					,actualind
					,datetypecode
					,lastmaintdate
					,lastuserid
					,keyind
					)
				VALUES (
					@v_taskkey
					,@v_bookkey
					,@v_printingkey
					,@v_new_date
					,@v_new_date
					,@v_actualind
					,@v_datetypecode
					,getdate()
					,@i_userid
					,1
					)
			END
		END

		SET @v_errmsg = coalesce(@v_errmsg, 'n/a')

		EXECUTE imp_write_feedback @i_batch
			,@i_row
			,@v_elementkey
			,@i_elementseq
			,@i_dmlkey
			,@v_errmsg
			,@i_level
			,3
	END
END
