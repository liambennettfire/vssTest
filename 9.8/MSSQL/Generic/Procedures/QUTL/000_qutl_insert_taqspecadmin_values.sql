SET QUOTED_IDENTIFIER ON 
GO
SET ANSI_NULLS ON 
GO

IF EXISTS (SELECT * FROM sysobjects WHERE type = 'P' AND name = 'qutl_insert_taqspecadmin_value')
  DROP  Procedure  qutl_insert_taqspecadmin_value
GO

CREATE PROCEDURE qutl_insert_taqspecadmin_value 
(@i_culturecode	INTEGER,
@i_itemcategorycode INTEGER,
@i_itemcode INTEGER,
@i_scalevaluetype INTEGER,
@i_showqtyind INTEGER,
@i_showqtylabel VARCHAR (255),
@i_showdecimalind INTEGER,
@i_showdecimallabel VARCHAR (255),
@i_showdescind	INTEGER,
@i_showdesclabel VARCHAR (255),
@i_defaultvalidforprtgscode INTEGER,
@i_showunitofmeasureind INTEGER,
@i_defaultunitofmeasurecode INTEGER,
@i_showinsummaryind INTEGER,
@i_usefunctionforqtyind INTEGER,
@i_showdesc2ind INTEGER,
@i_showdesc2label VARCHAR (255),
@i_summarysortorder  INTEGER,
@o_error_code INTEGER OUTPUT,
@o_error_desc VARCHAR(2000) OUTPUT)

AS

/******************************************************************************
**  Name: qutl_insert_taqspecadmin_value
**              
**    Parameters:
**    Input              
**    ----------         
**    culturecode, itemcategorycode, itemcode, scalevaluetype, showqtyind, showqtylabel, showdecimalind, 
**	  showdecimallabel, showdescind, showdesclabel, defaultvalidforprtgscode, showunitofmeasureind, defaultunitofmeasurecode, 
**	  showinsummaryind, usefunctionforqtyind, showdesc2ind, showdesc2label
**    
**    Output
**    -----------
**    error code, error description
**
**  Auth: Joshua Robinson
**  Date: 07/27/2015
*******************************************************************************
**  Change History
*******************************************************************************
**  Date:     Author:   Description:
**  --------  -------   ------------
**  
*******************************************************************************/

DECLARE
@v_error  INT,
@v_count INT,
@v_datadesc VARCHAR(40)

BEGIN

SET @v_count = 0	
SET @o_error_code = 0
SET @o_error_desc = ''

IF @i_culturecode IS NULL OR @i_culturecode = 0 BEGIN
     SELECT @i_culturecode = clientdefaultvalue
     FROM clientdefaults
     WHERE clientdefaultid = 78
     IF @i_culturecode IS NULL OR @i_culturecode = 0 BEGIN
	SELECT @i_culturecode = datacode 
	FROM gentables 
	WHERE tableid = 670 AND qsicode = 1
        IF @i_culturecode IS NULL OR @i_culturecode = 0 BEGIN
	     SET @o_error_code = -1
	     SET @o_error_desc = 'Culture was NULL or zero, does not exist in client defaults and there is no US Culture on table (qsicode 1)'
	     RETURN
	     END
	END
END

	
/*check to see if the subgentables value exists*/
SELECT @v_count = COUNT (*) 
FROM subgentables
WHERE tableid = 616 AND datacode = @i_itemcategorycode AND datasubcode = @i_itemcode

IF @v_count = 0 BEGIN
     SET @o_error_code = -1
     SET @i_itemcategorycode = COALESCE (@i_itemcategorycode, 0)
     SET @i_itemcode = COALESCE (@i_itemcode, 0)
     SET @o_error_desc = 'Value does not exist on subgentables for tableid 616, datacode=' + CAST(@i_itemcategorycode AS VARCHAR) + 
						' AND datasubcode=' + CAST(@i_itemcode AS VARCHAR) 
     RETURN
     END

SET @v_count = 0
	
/*check to see if the taqspecadmin record exists*/
SELECT @v_count = COUNT(*) FROM taqspecadmin WHERE culturecode = @i_culturecode AND itemcategorycode = @i_itemcategorycode AND itemcode = @i_itemcode

IF @v_count > 0 
	UPDATE taqspecadmin
	SET scalevaluetype = @i_scalevaluetype, showqtyind = @i_showqtyind, showqtylabel = @i_showqtylabel,
		showdecimalind = @i_showdecimalind, showdecimallabel = @i_showdecimallabel, showdescind = @i_showdescind,
		showdesclabel = @i_showdesclabel, defaultvalidforprtgscode = @i_defaultvalidforprtgscode, showunitofmeasureind = @i_showunitofmeasureind, 
	    defaultunitofmeasurecode = @i_defaultunitofmeasurecode,showinsummaryind = @i_showinsummaryind, usefunctionforqtyind = @i_usefunctionforqtyind, 
	    showdesc2ind = @i_showdesc2ind, showdesc2label = @i_showdesc2label, summarysortorder = @i_summarysortorder
	WHERE culturecode = @i_culturecode AND itemcategorycode = @i_itemcategorycode AND itemcode = @i_itemcode
ELSE 
	INSERT INTO taqspecadmin (culturecode, itemcategorycode, itemcode, scalevaluetype, showqtyind, 
				showqtylabel, showdecimalind, showdecimallabel, showdescind, showdesclabel, defaultvalidforprtgscode, showunitofmeasureind, 
				defaultunitofmeasurecode, showinsummaryind, lastuserid, lastmaintdate, usefunctionforqtyind, showdesc2ind, showdesc2label,
				summarysortorder)
	VALUES (@i_culturecode, @i_itemcategorycode, @i_itemcode, @i_scalevaluetype,@i_showqtyind, @i_showqtylabel, @i_showdecimalind,
			@i_showdecimallabel, @i_showdescind, @i_showdesclabel, @i_defaultvalidforprtgscode, @i_showunitofmeasureind,
			@i_defaultunitofmeasurecode, @i_showinsummaryind, 'qsiadmin', GETDATE(), @i_usefunctionforqtyind, @i_showdesc2ind, 
			@i_showdesc2label, @i_summarysortorder)


SELECT @v_error = @@ERROR
IF @v_error <> 0 BEGIN
     SET @i_itemcategorycode = COALESCE (@i_itemcategorycode, 0)
     SET @i_itemcode = COALESCE (@i_itemcode, 0)
     SET @o_error_desc = 'Value does not exist on subgentables for tableid 616, datacode=' + CAST(@i_itemcategorycode AS VARCHAR) + 
						' AND datasubcode=' + CAST(@i_itemcode AS VARCHAR) 
     RETURN
     END   
END

GO
GRANT EXEC ON qutl_insert_taqspecadmin_value TO PUBLIC
GO