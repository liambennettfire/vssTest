/******************************************************************************
**  Name: imp_100012167002
**  Desc: IKE Sort AudienceRange into Age or Grade values
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
		WHERE id = object_id(N'[dbo].[imp_100012167002]')
			AND OBJECTPROPERTY(id, N'IsProcedure') = 1
		)
	DROP PROCEDURE [dbo].[imp_100012167002]
GO

CREATE PROCEDURE dbo.imp_100012167002 @i_batchkey INT
	,@i_row INT
	,@i_elementseq INT
	,@i_templatekey INT
	,@i_rulekey BIGINT
	,@i_level INT
	,@i_userid VARCHAR(50)
AS
/* Sort AudienceRange into Age or Grade values */
BEGIN
	DECLARE @v_errcode INT
		,@v_errlevel INT
		,@v_msg VARCHAR(500)
		,@v_qualifier VARCHAR(4000)
		,@v_precision1 VARCHAR(4000)
		,@v_precision2 VARCHAR(4000)
		,@v_value1 VARCHAR(4000)
		,@v_value2 VARCHAR(4000)
		,@v_upInd1 INT
		,@v_upInd2 INT
		,@Debug INT

	BEGIN
		SET @Debug = 0
		SET @v_errlevel = 1
		SET @v_errcode = 1
		SET @v_msg = 'Sort AudienceRange into Age or Grade values'

		IF @Debug <> 0 PRINT '/* Sort AudienceRange into Age or Grade values */'

		SELECT @v_qualifier = originalvalue
		FROM imp_batch_detail
		WHERE batchkey = @i_batchkey
			AND row_id = @i_row
			AND elementkey = 100012167
			AND elementseq = @i_elementseq
		
		IF @v_qualifier IS NULL GOTO FINISH

		SELECT @v_precision1 = coalesce(originalvalue,'')
		FROM imp_batch_detail
		WHERE batchkey = @i_batchkey
			AND row_id = @i_row
			AND elementkey = 100012168
			AND elementseq = @i_elementseq
			AND COALESCE(elementseqOrdinal,0)=0

		SELECT @v_value1 = coalesce(originalvalue,'')
		FROM imp_batch_detail
		WHERE batchkey = @i_batchkey
			AND row_id = @i_row
			AND elementkey = 100012169
			AND elementseq = @i_elementseq
			AND COALESCE(elementseqOrdinal,0)=0

		SELECT @v_precision2 = coalesce(originalvalue,'')
		FROM imp_batch_detail
		WHERE batchkey = @i_batchkey
			AND row_id = @i_row
			AND elementkey = 100012168
			AND elementseq = @i_elementseq
			AND COALESCE(elementseqOrdinal,0)=1

		SELECT @v_value2 = coalesce(originalvalue,'')
		FROM imp_batch_detail
		WHERE batchkey = @i_batchkey
			AND row_id = @i_row
			AND elementkey = 100012169
			AND elementseq = @i_elementseq
			AND COALESCE(elementseqOrdinal,0)=1
			
		--mk20130926> adding code so that this sproc can work in table as well as xml explicit mode
		-- ... the issue is that a table wouldn't have elementOrdinals within a sequence

		IF @v_value2 IS NULL
		BEGIN
			SELECT @v_value2 = coalesce(originalvalue,'')
			FROM imp_batch_detail
			WHERE batchkey = @i_batchkey
				AND row_id = @i_row
				AND elementkey = 100012171
				AND elementseq = @i_elementseq
		END

		-- .. also the logic is different
		--AudienceRangeQualifier
		--	17 = GRADE
		--	11 = AGE
		--	NULL = there is no AudienceRange composite
		--AudienceRangeValueLOW
		--	NUMERIC VALUE
		--	NULL
		--AudienceRangeValueHIGH
		--	NUMERIC VALUE
		--	NULL
		-- IF AudienceRangeQualifier IS NULL THEN AudienceRangeValueLOW and AudienceRangeValueHIGH are ignored
		-- ELSE
		-- IF AudienceRangeValueLOW IS NULL and AudienceRangeValueHIGH IS NOT NULL THEN the range is "up to" the high value
		-- IF AudienceRangeValueHIGH IS NULL and AudienceRangeValueLOW IS NOT NULL THEN the range is  the low value "and up"
		-- IF neither are null THEN the range is the low value to the high value.
		-- IF both are null THEN why was AudienceRangeQualifier NOT NULL?		
						
		IF @Debug <> 0 PRINT '@v_qualifier = ' + @v_qualifier
		IF @Debug <> 0 PRINT '@v_precision1 = ' + @v_precision1
		IF @Debug <> 0 PRINT '@v_value1 = ' + @v_value1
		IF @Debug <> 0 PRINT '@v_precision2 = ' + @v_precision2
		IF @Debug <> 0 PRINT '@v_value2 = ' + @v_value2
		
		set @v_upInd1=null
		set @v_upInd2=null		
		
		-- check for "and up" or "up to" indicators
		if @v_value1='up'
		begin
			set @v_upInd1=1
			set @v_value1=NULL
		end
		if @v_value2='up'
		begin
			set @v_upInd2=1
			set @v_value2=NULL
		end		
		
		IF isnumeric (@v_value1) = 0 set @v_value1 = NULL
		IF isnumeric (@v_value2) = 0 set @v_value2 = NULL
		IF @v_value1 IS NULL and @v_value2 IS NOT NULL set @v_upInd1=1
		IF @v_value2 IS NULL and @v_value1 IS NOT NULL set @v_upInd2=1
		IF @v_precision1 IS NULL set @v_precision1='01'
		IF @v_precision2 IS NULL set @v_precision2='01'
		
		IF @v_qualifier = '11' --grade
		BEGIN
			IF @Debug <> 0 PRINT 'GRADE'
			IF @v_precision1 = '01' OR @v_precision1 = '03' --exact or from
			BEGIN
				IF @Debug <> 0 PRINT 'exact or from'
				INSERT INTO imp_batch_detail (batchkey,row_id,elementkey,elementseq,originalvalue,lastuserid,lastmaintdate)
				VALUES (@i_batchkey,@i_row,100012071,@i_elementseq,@v_value1,'loader_rule_100012167002',getdate())

				INSERT INTO imp_batch_detail (batchkey,row_id,elementkey,elementseq,originalvalue,lastuserid,lastmaintdate)
				VALUES (@i_batchkey,@i_row,100012072,@i_elementseq,@v_value2,'loader_rule_100012167002',getdate())

				INSERT INTO imp_batch_detail (batchkey,row_id,elementkey,elementseq,originalvalue,lastuserid,lastmaintdate)
				VALUES (@i_batchkey,@i_row,100012073,@i_elementseq,@v_upInd1,'loader_rule_100012167002',getdate())										

				INSERT INTO imp_batch_detail (batchkey,row_id,elementkey,elementseq,originalvalue,lastuserid,lastmaintdate)
				VALUES (@i_batchkey,@i_row,100012074,@i_elementseq,@v_upInd2,'loader_rule_100012167002',getdate())		
			END

			IF @v_precision1 = '04' --exact or to
			BEGIN
				IF @Debug <> 0 PRINT 'exact or to'
				INSERT INTO imp_batch_detail (batchkey,row_id,elementkey,elementseq,originalvalue,lastuserid,lastmaintdate)
				VALUES (@i_batchkey,@i_row,100012071,@i_elementseq,@v_value2,'loader_rule_100012167002',getdate())

				INSERT INTO imp_batch_detail (batchkey,row_id,elementkey,elementseq,originalvalue,lastuserid,lastmaintdate)
				VALUES (@i_batchkey,@i_row,100012072,@i_elementseq,@v_value1,'loader_rule_100012167002',getdate())
				
				INSERT INTO imp_batch_detail (batchkey,row_id,elementkey,elementseq,originalvalue,lastuserid,lastmaintdate)
				VALUES (@i_batchkey,@i_row,100012073,@i_elementseq,@v_upInd2,'loader_rule_100012167002',getdate())										

				INSERT INTO imp_batch_detail (batchkey,row_id,elementkey,elementseq,originalvalue,lastuserid,lastmaintdate)
				VALUES (@i_batchkey,@i_row,100012074,@i_elementseq,@v_upInd1,'loader_rule_100012167002',getdate())										
			END
		END

		IF @v_qualifier in ('18','17') -- age
		BEGIN
			IF @Debug <> 0 PRINT 'AGE'
			--Make sure that @v_value1 and @v_value2 are integers

			IF @v_precision1 = '01' OR @v_precision1 = '03' --exact or from
			BEGIN
				IF @Debug <> 0 PRINT 'exact or from'
				INSERT INTO imp_batch_detail (batchkey,row_id,elementkey,elementseq,originalvalue,lastuserid,lastmaintdate)
				VALUES (@i_batchkey,@i_row,100012063,@i_elementseq,@v_value1,'loader_rule_100012167002',getdate())

				INSERT INTO imp_batch_detail (batchkey,row_id,elementkey,elementseq,originalvalue,lastuserid,lastmaintdate)				
				VALUES (@i_batchkey,@i_row,100012064,@i_elementseq,@v_value2,'loader_rule_100012167002',getdate())

				INSERT INTO imp_batch_detail (batchkey,row_id,elementkey,elementseq,originalvalue,lastuserid,lastmaintdate)
				VALUES (@i_batchkey,@i_row,100012065,@i_elementseq,@v_upInd1,'loader_rule_100012167002',getdate())										

				INSERT INTO imp_batch_detail (batchkey,row_id,elementkey,elementseq,originalvalue,lastuserid,lastmaintdate)
				VALUES (@i_batchkey,@i_row,100012066,@i_elementseq,@v_upInd2,'loader_rule_100012167002',getdate())										
			END

			IF @v_precision1 = '04' --exact or to
			BEGIN
				IF @Debug <> 0 PRINT 'exact or to'
				INSERT INTO imp_batch_detail (batchkey,row_id,elementkey,elementseq,originalvalue,lastuserid,lastmaintdate)
				VALUES (@i_batchkey,@i_row,100012063,@i_elementseq,@v_value2,'loader_rule_100012167002',getdate())

				INSERT INTO imp_batch_detail (batchkey,row_id,elementkey,elementseq,originalvalue,lastuserid,lastmaintdate)				
				VALUES (@i_batchkey,@i_row,100012064,@i_elementseq,@v_value1,'loader_rule_100012167002',getdate())

				INSERT INTO imp_batch_detail (batchkey,row_id,elementkey,elementseq,originalvalue,lastuserid,lastmaintdate)
				VALUES (@i_batchkey,@i_row,100012065,@i_elementseq,@v_upInd2,'loader_rule_100012167002',getdate())										

				INSERT INTO imp_batch_detail (batchkey,row_id,elementkey,elementseq,originalvalue,lastuserid,lastmaintdate)
				VALUES (@i_batchkey,@i_row,100012066,@i_elementseq,@v_upInd1,'loader_rule_100012167002',getdate())										
			END
		END
	END
FINISH:	
END
GO

SET QUOTED_IDENTIFIER OFF
GO

SET ANSI_NULLS ON
GO

GRANT EXECUTE
	ON dbo.[imp_100012167002]
	TO PUBLIC
GO

