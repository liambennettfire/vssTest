if exists (select * from dbo.sysobjects where id = object_id(N'dbo.qscale_get_scaleparameters') and OBJECTPROPERTY(id, N'IsProcedure') = 1)
drop procedure dbo.qscale_get_scaleparameters
GO

SET QUOTED_IDENTIFIER ON 
GO
SET ANSI_NULLS ON 
GO

CREATE PROCEDURE qscale_get_scaleparameters
 (@i_taqprojectkey				integer,
  @o_error_code           integer output,
  @o_error_desc           varchar(2000) output)
AS

/******************************************************************************
**  Name: qscale_get_scaleparameters
**  Desc: This procedure returns rows for the Scale Parameters section
**
**	Auth: Dustin Miller
**	Date: February 21 2012
*******************************************************************************/

  DECLARE @v_scaleadminspeckey INT,
					@v_scaletypecode INT,
					@v_itemcategorycode INT,
					@v_itemcode	INT,
					@v_parametervaluecode INT,
					@v_taqscaleparameterkey INT,
					@v_value1	INT,
					@v_value2 INT,
					@v_error	INT,
          @v_rowcount INT

  SET @o_error_code = 0
  SET @o_error_desc = ''
  
  CREATE TABLE #scaleparemeters_results
  (
		scaleadminspeckey	int,
		scaletypecode	int,
		itemcategorycode int,
		itemcode	int,
		parametervaluecode int,
		taqscaleparameterkey int,
		value1	int,
		value2	int
  )
  
  DECLARE results_cursor CURSOR FOR
	SELECT scaleadminspeckey, scaletypecode, itemcategorycode, itemcode, parametervaluecode 
  FROM taqscaleadminspecitem 
  WHERE parametertypecode=1
  AND scaletypecode IN 
  (SELECT taqprojecttype FROM taqproject WHERE taqprojectkey=@i_taqprojectkey)
	
	OPEN results_cursor
	
	FETCH results_cursor
	INTO @v_scaleadminspeckey, @v_scaletypecode, @v_itemcategorycode, @v_itemcode, @v_parametervaluecode
  
  WHILE (@@FETCH_STATUS = 0)
	BEGIN
		SET @v_taqscaleparameterkey = NULL
		SET @v_value1 = NULL
		SET @v_value2 = NULL
		
		SELECT @v_taqscaleparameterkey=taqscaleparameterkey, @v_value1=value1, @v_value2=value2 
		FROM taqprojectscaleparameters WHERE taqprojectkey=@i_taqprojectkey 
			AND itemcategorycode=@v_itemcategorycode AND itemcode=@v_itemcode
		
		INSERT INTO #scaleparemeters_results
		VALUES (@v_scaleadminspeckey, @v_scaletypecode, @v_itemcategorycode, @v_itemcode, @v_parametervaluecode,
			@v_taqscaleparameterkey, @v_value1, @v_value2)
		
		FETCH results_cursor
		INTO @v_scaleadminspeckey, @v_scaletypecode, @v_itemcategorycode, @v_itemcode, @v_parametervaluecode
  END
  CLOSE results_cursor
	DEALLOCATE results_cursor
	
	SELECT *
	FROM #scaleparemeters_results

  SELECT @v_error = @@ERROR, @v_rowcount = @@ROWCOUNT
  IF @v_error <> 0 BEGIN
    SET @o_error_code = -1
    SET @o_error_desc = 'Error returning scale parameters information (taqprojectkey=' + cast(@i_taqprojectkey as varchar) + ')'
    RETURN  
  END 
  
GO

GRANT EXEC ON qscale_get_scaleparameters TO PUBLIC
GO