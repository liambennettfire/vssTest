IF EXISTS (SELECT *
             FROM dbo.sysobjects
             WHERE id = object_id(N'dbo.qutl_get_admin_spec_items')
               AND OBJECTPROPERTY(id, N'IsProcedure') = 1)
  DROP PROCEDURE dbo.qutl_get_admin_spec_items
GO

SET QUOTED_IDENTIFIER ON 
GO
SET ANSI_NULLS ON 
GO

CREATE PROCEDURE qutl_get_admin_spec_items
 (@i_datacode       integer,
  @i_culturecode    integer, 
  @o_error_code     integer output,
  @o_error_desc     varchar(2000) output)
AS

/******************************************************************************
**  File: 
**  Name: qutl_get_admin_spec_items
**  Desc: 
**
**    Auth: Jon Hess
**    Date: 
*******************************************************************************
**    Change History
*******************************************************************************
**    Date:			Author:					Description:
**    --------		--------				-------------------------------------------
**    3/7/2012		Dustin Miller			Case 18589. Fixed default scalevaluetype defaulting
**    07/23/2014	Uday Khisty				Case: 28839 Specification Admin Enhancements
**    01/22/2014	Uday Khisty				Case: 31062 Add summary sort order to taqspecadmin
*******************************************************************************/

  SET @o_error_code = 0
  SET @o_error_desc = ''
  DECLARE @v_catcode		INT,
					@v_itemcode		INT,
					@v_scaletype	INT,
					@v_sub2gencnt	INT,
					@v_numdesc		FLOAT,
					@error_var    INT,
					@rowcount_var INT,
					@v_subgen4ind INT

SELECT s.tableid,
       s.datacode,
       s.datasubcode,
       s.datadesc,
       s.deletestatus,
       s.applid,
       s.sortorder,
       s.tablemnemonic,
       s.alldivisionsind,
       s.externalcode,
       s.datadescshort,
       s.numericdesc1,
       s.numericdesc2,
       s.bisacdatacode,
       s.subgen1ind,
       s.subgen2ind,
       s.acceptedbyeloquenceind,
       s.exporteloquenceind,
       s.lockbyqsiind,
       s.lockbyeloquenceind,
       s.eloquencefieldtag,
       s.alternatedesc1,
       s.alternatedesc2,
       s.subgen3ind,
       s.qsicode,
       s.subgen4ind,
       t.itemcategorycode,
       t.itemcode,
       coalesce(t.scalevaluetype, 0) AS scalevaluetype,
       coalesce(t.scalevaluetype, 0) AS scalevaluetypeoriginal,       
       coalesce(t.showqtyind, 0) AS showqtyind,
       t.showqtylabel,
       t.showdecimalind,
       t.showdecimallabel,
       t.showdescind,
       t.showdesclabel,
       t.showvalidprtgsind,
       coalesce(t.defaultvalidforprtgscode, 3) AS defaultvalidforprtgscode,
       t.showunitofmeasureind,
       t.defaultunitofmeasurecode,
       t.showinsummaryind,
       t.culturecode,
       t.itemlabel,
       t.showdesc2ind,
       t.showdesc2label,
       t.summarysortorder
  INTO #temp_results_table
  FROM (SELECT * FROM taqspecadmin WHERE culturecode = @i_culturecode) t
    RIGHT OUTER JOIN subgentables s
      ON t.itemcode = s.datasubcode
      AND t.itemcategorycode = s.datacode
  WHERE tableid = 616
    AND datacode = @i_datacode
    
  DECLARE results_cursor CURSOR FOR
	SELECT datacode, datasubcode, scalevaluetype, subgen4ind
	FROM #temp_results_table
	
	OPEN results_cursor
	
	FETCH results_cursor
	INTO @v_catcode, @v_itemcode, @v_scaletype, @v_subgen4ind
  
  WHILE (@@FETCH_STATUS = 0)
  BEGIN
		IF @v_scaletype IS NULL OR @v_scaletype = 0
		BEGIN
			SET @v_sub2gencnt = 0
			
			SELECT @v_sub2gencnt=count(*)
			FROM sub2gentables
			WHERE tableid=616
				AND datacode=@v_catcode
				AND datasubcode=@v_itemcode
			
			SET @v_numdesc = NULL
			
			SELECT @v_numdesc=numericdesc1
			FROM subgentables
			WHERE tableid=616
				AND datacode=@v_catcode
				AND datasubcode=@v_itemcode
				
			IF @v_subgen4ind = 0 
			BEGIN 
				UPDATE #temp_results_table
				SET scalevaluetype = 1, culturecode = @i_culturecode
				WHERE tableid=616
					AND datacode=@v_catcode
					AND datasubcode=@v_itemcode				
			END				
			ELSE IF @v_sub2gencnt > 0 OR @v_numdesc IS NOT NULL OR @v_numdesc = 0
			BEGIN
				UPDATE #temp_results_table
				SET scalevaluetype = 5, culturecode = @i_culturecode
				WHERE tableid=616
					AND datacode=@v_catcode
					AND datasubcode=@v_itemcode
			END
			ELSE BEGIN
				UPDATE #temp_results_table
				SET scalevaluetype = 1, culturecode = @i_culturecode
				WHERE tableid=616
					AND datacode=@v_catcode
					AND datasubcode=@v_itemcode
			END
		END
		
		FETCH results_cursor
		INTO @v_catcode, @v_itemcode, @v_scaletype, @v_subgen4ind
  END
  
  CLOSE results_cursor
	DEALLOCATE results_cursor

	SELECT * FROM #temp_results_table
	
  -- Save the @@ERROR and @@ROWCOUNT values in local 
  -- variables before they are cleared.
  SELECT @error_var = @@ERROR, @rowcount_var = @@ROWCOUNT
  IF @error_var <> 0 OR @rowcount_var = 0 BEGIN
    SET @o_error_code = 1
    SET @o_error_desc = 'error accessing subgentables/taqspecadmin: datacode = ' + cast(@i_datacode AS VARCHAR)
    RETURN 
  END

GO
GRANT EXEC ON qutl_get_admin_spec_items TO PUBLIC
GO


