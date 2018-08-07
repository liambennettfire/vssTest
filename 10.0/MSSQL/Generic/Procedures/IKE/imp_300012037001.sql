/******************************************************************************
**  Name: imp_300012037001
**  Desc: IKE Add/Replace Page Count
**  Auth: Bennett     
**  Date: 5/9/2016
*******************************************************************************
**  Change History
*******************************************************************************
**  Date:        Author:     Description:
*   --------     --------    -------------------------------------------
**  5/9/2016     Bennett     original
**  6/22/2016    Kusum       Case 38710
*******************************************************************************/
SET QUOTED_IDENTIFIER ON
GO

SET ANSI_NULLS ON
GO

IF EXISTS (SELECT * FROM dbo.sysobjects WHERE id = object_id(N'[dbo].[imp_300012037001]') AND OBJECTPROPERTY(id, N'IsProcedure') = 1)
	DROP PROCEDURE [dbo].[imp_300012037001]
GO

CREATE PROCEDURE dbo.imp_300012037001 @i_batch INT
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
/* Add/Replace Page Count */
BEGIN
	DECLARE @v_elementvalVC VARCHAR(4000)
		,@v_elementval SMALLINT
		,@v_errcode INT
		,@v_errmsg VARCHAR(4000)
		,@v_elementdesc VARCHAR(4000)
		,@v_elementkey BIGINT
		,@v_lobcheck VARCHAR(20)
		,@v_lobkey INT
		,@v_bookkey INT
	DECLARE @i_pagecount INT
		,@i_options INT

	BEGIN
		SET @o_writehistoryind = 0
		SET @v_errcode = 1
		SET @v_bookkey = dbo.resolve_keyset(@i_titlekeyset, 1)
		SET @i_pagecount = 0

		SELECT @v_elementvalVC = originalvalue,@v_elementkey = b.elementkey
		  FROM imp_batch_detail b,imp_DML_elements d
		 WHERE b.batchkey = @i_batch
		   AND b.row_id = @i_row
		   AND b.elementseq = @i_elementseq
		   AND b.elementkey = d.elementkey
		   AND d.DMLkey = @i_dmlkey

		IF @v_elementvalVC IS NULL BEGIN
			SET @v_elementval = 0
			SET @v_errmsg='The Page Count was null for this title .... update skipped'
			SET @i_level=2
		END 
		ELSE BEGIN
			SET @v_elementvalVC = REPLACE(@v_elementvalVC, CHAR(10), '')
			SET @v_elementvalVC = REPLACE(@v_elementvalVC, CHAR(13), '')
			SET @v_elementvalVC = REPLACE(@v_elementvalVC, CHAR(32), '')
			
			begin try
				SET @v_elementval = CAST(@v_elementvalVC AS SMALLINT)
			end try
			begin catch
				SET @v_elementval = 0
				SET @v_errmsg='The Page Count was not a SMALLINT for this title .... update skipped'
				SET @i_level=2				
			end catch
		END
	
		/* GET CLIENT OPTIONS TO DETERMINE WHERE THE PAGE COUNT IS STORED */
		SELECT @i_options = optionvalue FROM clientoptions 	WHERE optionid = 4

		IF COALESCE(@i_options, 0) = 0
			SELECT @i_pagecount = COALESCE(pagecount, 0) FROM printing WHERE bookkey = @v_bookkey AND printingkey = 1
		ELSE
			SELECT @i_pagecount = COALESCE(tmmpagecount, 0) FROM printing WHERE bookkey = @v_bookkey AND printingkey = 1

		/* IF @elementval <> EXISTING PAGE COUNT THEN UPDATE PRINTING SPECS */
		IF @i_pagecount <> @v_elementval AND @v_elementval>0 BEGIN
			IF COALESCE(@i_options, 0) = 0 BEGIN
				UPDATE printing
				--mk20140225> as per email from Paul for BPC
				--SET pagecount = @v_elementval
				  SET tentativepagecount = @v_elementval
				      ,pagecount = @v_elementval
					 ,lastuserid = @i_userid
					  ,lastmaintdate = getdate()
				WHERE bookkey = @v_bookkey AND printingkey = 1

				SET @o_writehistoryind = 1
				--mk20140225> as per email from Paul for BPC
				SET @v_errmsg = 'Actual Page Count (pagecount) Updated'
				--SET @v_errmsg = 'Estimated Page Count (tentativepagecount) Updated'
			END
			ELSE BEGIN
				UPDATE printing
				  SET tmmpagecount = @v_elementval
					  ,lastuserid = @i_userid
					  ,lastmaintdate = getdate()
				WHERE bookkey = @v_bookkey AND printingkey = 1

				SET @o_writehistoryind = 1
				SET @v_errmsg = 'Actual Page Count (tmmpagecount) Updated'
			END
		END

		IF @v_errmsg IS NOT NULL BEGIN
			EXECUTE imp_write_feedback @i_batch,@i_row,@v_elementkey,@i_elementseq,@i_dmlkey,@v_errmsg,@i_level,3
		END
	END
END
GO

SET QUOTED_IDENTIFIER OFF
GO

SET ANSI_NULLS ON
GO

GRANT EXECUTE ON dbo.[imp_300012037001] TO PUBLIC
GO


