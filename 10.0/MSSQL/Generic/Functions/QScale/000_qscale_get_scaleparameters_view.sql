if exists (select * from dbo.sysobjects where id = object_id(N'[dbo].qscale_get_scaleparameters_view') and xtype in (N'FN', N'IF', N'TF'))
drop function [dbo].qscale_get_scaleparameters_view
GO

SET QUOTED_IDENTIFIER OFF 
GO
SET ANSI_NULLS OFF 
GO

CREATE FUNCTION [dbo].qscale_get_scaleparameters_view(@i_taqprojectkey int)

/******************************************************************************
**  Name: qscale_get_scaleparameters_view
**  Desc: Moved code from qscale_get_scaleparameters procedure
**
**	Auth: Colman
**	Date: November 8, 2017
*******************************************************************************
**  Change History
*******************************************************************************
**  Date:     Author:   Description:
**  --------  -------   -------------------------------------------
**  
*******************************************************************************/

RETURNS @scaleparameters_results TABLE(
		scaleadminspeckey	int,
		scaletypecode	int,
		itemcategorycode int,
		itemcode	int,
		parametervaluecode int,
		taqscaleparameterkey int,
		value1	int,
		value2	int
  )

AS
BEGIN
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
		
		INSERT INTO @scaleparameters_results
		VALUES (@v_scaleadminspeckey, @v_scaletypecode, @v_itemcategorycode, @v_itemcode, @v_parametervaluecode,
			@v_taqscaleparameterkey, @v_value1, @v_value2)
		
		FETCH results_cursor
		INTO @v_scaleadminspeckey, @v_scaletypecode, @v_itemcategorycode, @v_itemcode, @v_parametervaluecode
  END
  CLOSE results_cursor
	DEALLOCATE results_cursor

  RETURN	
	--SELECT *
	--FROM #scaleparemeters_results
END
GO
