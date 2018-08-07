/******************************************************************************
**  Name: imp_300017001001
**  Desc: IKE Add/Replace BISAC Subjects
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

if exists (select * from dbo.sysobjects where id = object_id(N'[dbo].[imp_300017001001]') and OBJECTPROPERTY(id, N'IsProcedure') = 1)
drop procedure [dbo].[imp_300017001001]
GO

CREATE PROCEDURE [dbo].[imp_300017001001] @i_batch INT
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
	,@o_writehistoryind INT
OUTPUT AS

/* Add/Replace BISAC Subjects */
BEGIN
	SET NOCOUNT ON

	/* DEFINE BATCH VARIABLES		*/
	DECLARE @v_elementval VARCHAR(4000)
		,@v_errcode INT
		,@v_errmsg VARCHAR(4000)
		,@v_elementdesc VARCHAR(4000)
		,@v_elementkey BIGINT
		,@v_lobcheck VARCHAR(20)
		,@v_lobkey INT
		,@v_bookkey INT
		,@v_printingkey INT
		,@v_hit INT
		,@v_sortorder INT
		,@v_rowcount INT
		,@v_MainSubjectInd VARCHAR(10)
		,@v_bisaccategorycode INT
		,@v_bisaccategorysubcode INT
		,@v_NEW_sortorder INT
		,@v_sortdata INT
		,@v_DEBUG INT
		,@v_subjectcode INT
		,@v_subjectsubcode INT
		,@v_datadesc varchar(40)
	BEGIN
		SET @v_DEBUG = 0
		SET @v_sortdata = 0
		SET @v_hit = 0
		SET @v_sortorder = 1
		SET @v_rowcount = 0
		SET @o_writehistoryind = 0
		SET @v_errcode = 1
		SET @v_errmsg = 'BISAC Subjects updated'
		SET @v_bookkey = dbo.resolve_keyset(@i_titlekeyset, 1)
		SET @v_printingkey = dbo.resolve_keyset(@i_titlekeyset,2)

		/*  GET IMPORTED BISAC SUBJECTS 			*/
		SELECT @v_elementval = LTRIM(RTRIM(originalvalue))
			,@v_elementkey = b.elementkey
		FROM imp_batch_detail b
			,imp_DML_elements d
		WHERE b.batchkey = @i_batch
			AND b.row_id = @i_row
			AND b.elementseq = @i_elementseq
			AND d.dmlkey = @i_dmlkey
			AND d.elementkey = b.elementkey

		-- see if this came from the <MainSubject> composite ... this makes it the primary (sortorder=1) BisacCode
		SELECT @v_hit = COUNT(*)
		FROM imp_batch_detail
		WHERE batchkey = @i_batch
			AND row_id = @i_row
			AND elementseq = @i_elementseq
			AND elementkey = 100017002

		IF @v_hit > 0
			BEGIN
				SELECT @v_MainSubjectInd = originalvalue
				FROM imp_batch_detail
				WHERE batchkey = @i_batch
					AND row_id = @i_row
					AND elementseq = @i_elementseq
					AND elementkey = 100017002
			END

		/* FIND IMPORT BISAC SUBJECTS ON GENTABLES 		*/
		
		--NEW Feature ... the @v_elementval may be a semi-colon delimited string in which case we'll need to loop on each value
		DECLARE @DistinctElementVal varchar(max)

		DECLARE DistinctElementValCursor CURSOR FOR 
		SELECT part
		FROM dbo.udf_SplitString(@v_elementval, ';')

		OPEN DistinctElementValCursor

		FETCH NEXT FROM DistinctElementValCursor 
		INTO @DistinctElementVal

		WHILE @@FETCH_STATUS = 0
		BEGIN
			--PRINT @DistinctElementVal
			SET @v_elementval=@DistinctElementVal
			SET @v_subjectcode = NULL
			SET @v_subjectsubcode = NULL
		
			exec find_subgentables_mixed @v_elementval,339,@v_subjectcode output,@v_subjectsubcode output,@v_datadesc output
			
			IF @v_DEBUG <> 0 PRINT '---------------------------------'
			IF @v_DEBUG <> 0 PRINT 'PROCEDURE [dbo].[imp_300017001001] '
			IF @v_DEBUG <> 0 PRINT '@v_elementval = ' + @v_elementval
			IF @v_DEBUG <> 0 PRINT '@v_MainSubjectInd = ' + coalesce(@v_MainSubjectInd,'FALSE')
			IF @v_DEBUG <> 0 PRINT '@v_bookkey = ' + cast (@v_bookkey as varchar(max))

			IF @v_subjectcode is not null and  @v_subjectsubcode is not null
			BEGIN
				IF @v_DEBUG <> 0 print '@v_subjectcode = ' + cast (@v_subjectcode as varchar(max))
				IF @v_DEBUG <> 0 print '@v_subjectsubcode = ' + cast (@v_subjectsubcode as varchar(max))

				-- use those codes to see if the bisac category is already assoced to this book
				SELECT @v_rowcount = COUNT(*)
				FROM bookbisaccategory
				WHERE bookkey = @v_bookkey
					AND bisaccategorycode = @v_subjectcode
					AND bisaccategorysubcode = @v_subjectsubcode
				
				IF @v_DEBUG <> 0 print 'Row Count for ' + @v_elementval + ': ' + cast (@v_rowcount as varchar(max))
					
				IF @v_rowcount <> 0 
					BEGIN
						IF @v_MainSubjectInd IS NOT NULL
							BEGIN
								IF @v_DEBUG <> 0 print 'this PRIMARY bisacdatacode [' + @v_elementval + '] is already in use'
								SELECT @v_sortorder = sortorder
								FROM bookbisaccategory
								WHERE bookkey = @v_bookkey
									AND bisaccategorycode = @v_subjectcode
									AND bisaccategorysubcode = @v_subjectsubcode

								IF @v_sortorder <> 1
									BEGIN
										IF @v_DEBUG <> 0 print 'This record is being updated to PRIMARY  (sort Order=1)'
										UPDATE bookbisaccategory
										SET sortorder = 1
										WHERE bookkey = @v_bookkey
											AND bisaccategorycode = @v_subjectcode
											AND bisaccategorysubcode = @v_subjectsubcode

										IF @v_DEBUG <> 0 print ' ... update the sort orders of the rest of the categories sequentially'
										SET @v_sortdata = 1
									END
								ELSE
									BEGIN
										IF @v_DEBUG <> 0 print 'This record is already PRIMARY (sort Order=1)'
									END
							END
						ELSE
							BEGIN
								IF @v_DEBUG <> 0 print 'this NON-PRIMARY bisacdatacode [' + @v_elementval + '] is already in use'
							END
					END
				ELSE
					BEGIN
						IF @v_MainSubjectInd IS NOT NULL
							BEGIN
								IF @v_DEBUG <> 0 print 'This is a new BISAC category for this book and it IS primary (sort order #1) ... insert new record with the sort order = 1'
								INSERT INTO bookbisaccategory 
									(bookkey,printingkey,bisaccategorycode,bisaccategorysubcode,sortorder,lastuserid,lastmaintdate)
								VALUES 
									(@v_bookkey,1,@v_subjectcode,@v_subjectsubcode,1,@i_userid,GETDATE())

								SET @v_sortdata = 1
								SET @o_writehistoryind = 1
							END
						ELSE
							BEGIN
								IF @v_DEBUG <> 0 print 'This is a new BISAC category for this book and it is NOT primary (sort order #1) ... insert new record with the max sort order'
								SELECT @v_sortorder = COALESCE(MAX(sortorder), 0)
								FROM bookbisaccategory
								WHERE bookkey = @v_bookkey

								SET @v_sortorder = @v_sortorder + 1

								INSERT INTO bookbisaccategory 
									(bookkey,printingkey,bisaccategorycode,bisaccategorysubcode,sortorder,lastuserid,lastmaintdate)
								VALUES 
									(@v_bookkey,1,@v_subjectcode,@v_subjectsubcode,@v_sortorder,@i_userid,GETDATE())

								SET @o_writehistoryind = 1
							END
					END

				IF @v_sortdata <> 0
					BEGIN
						IF @v_DEBUG <> 0 print 'Process the NON-PRIMARY sort orders'
						SELECT @v_rowcount = count(*)
						FROM bookbisaccategory
						WHERE bookkey = @v_bookkey
							AND printingkey = 1
						
						IF @v_DEBUG <> 0 print 'Number of TOTAL rows = ' + cast (@v_rowcount as varchar(max))
						DECLARE cur_bookbisaccategory CURSOR FOR
							SELECT bisaccategorycode
								,bisaccategorysubcode
								,sortorder
							FROM bookbisaccategory
							WHERE bookkey = @v_bookkey
								AND printingkey = 1
								AND (CAST(bisaccategorycode as varchar(max))+'/'+CAST(bisaccategorysubcode as varchar(max))) <> 
									(CAST(@v_subjectcode as varchar(max))+'/'+CAST(@v_subjectsubcode as varchar(max)))
								--AND bisaccategorycode <> @v_subjectcode
								--AND bisaccategorysubcode <> @v_subjectsubcode
							ORDER BY sortorder DESC

						OPEN cur_bookbisaccategory

						FETCH cur_bookbisaccategory INTO @v_bisaccategorycode
														,@v_bisaccategorysubcode
														,@v_sortorder

						WHILE @@fetch_status = 0
							BEGIN
								SET @v_NEW_sortorder = @v_rowcount
								SET @v_rowcount = @v_rowcount - 1

								IF @v_DEBUG <> 0 print 'Current Sort Order for code ' + cast (@v_bisaccategorycode as varchar(max)) + ',' + cast (@v_bisaccategorysubcode as varchar(max)) + ' is ' + cast (@v_sortorder as varchar(max))
								IF @v_DEBUG <> 0 print 'NEW Sort Order for code ' + cast (@v_bisaccategorycode as varchar(max)) + ',' + cast (@v_bisaccategorysubcode as varchar(max)) + ' is ' + cast (@v_NEW_sortorder as varchar(max))

								UPDATE bookbisaccategory
								SET sortorder = @v_NEW_sortorder
								WHERE bookkey = @v_bookkey
									AND printingkey = 1
									AND bisaccategorycode = @v_bisaccategorycode
									AND bisaccategorysubcode = @v_bisaccategorysubcode

								FETCH cur_bookbisaccategory
								INTO @v_bisaccategorycode
									,@v_bisaccategorysubcode
									,@v_sortorder
							END

						CLOSE cur_bookbisaccategory

						DEALLOCATE cur_bookbisaccategory
					END
			END

			IF @v_errcode < 2
				BEGIN
					EXECUTE imp_write_feedback @i_batch,@i_row,@v_elementkey,@i_elementseq,@i_dmlkey,@v_errmsg,@i_level,3
				END
			FETCH NEXT FROM DistinctElementValCursor 
			INTO @DistinctElementVal
		END 
		CLOSE DistinctElementValCursor;
		DEALLOCATE DistinctElementValCursor;

	END
END

GO
SET QUOTED_IDENTIFIER OFF 
GO
SET ANSI_NULLS ON 
GO

GRANT EXECUTE ON dbo.[imp_300017001001] to PUBLIC 
GO
