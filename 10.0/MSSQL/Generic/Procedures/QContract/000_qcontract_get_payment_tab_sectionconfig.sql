if exists (select * from dbo.sysobjects where id = object_id(N'dbo.qcontract_get_payment_tab_sectionconfig') and OBJECTPROPERTY(id, N'IsProcedure') = 1)
  drop procedure dbo.qcontract_get_payment_tab_sectionconfig
GO

SET QUOTED_IDENTIFIER ON 
GO
SET ANSI_NULLS ON 
GO

CREATE PROCEDURE qcontract_get_payment_tab_sectionconfig
 (@i_tabcode        integer,
  @i_tabsubcode     integer,
  @i_itemtypecode   integer,
  @i_usageclasscode integer,
  @o_error_code     integer output,
  @o_error_desc     varchar(2000) output)
AS

/************************************************************************************
**  Name: qcontract_get_payment_tab_sectionconfig
**  Desc: This stored procedure returns the section configuration details for payment tabs
**
**  Auth: Dustin Miller
**  Date: 7/17/12
*************************************************************************************
**    Change History
*************************************************************************************
**    Date:        Author:    Description:
**    --------     --------   -------------------------------------------------------
**    07/25/2017   Colman     Case 45421 add payment method column to payment tabs 
**    11/03/2017   Colman     Case 48152 Override text1 label for Payments tab is not working
**    01/19/2018   Colman     Case 49136 Payment type is not displaying as a column on the payment tabs 
*************************************************************************************/

BEGIN

  DECLARE
    @v_gentable1  INT,
    @v_gentable2  INT

  SET @v_gentable1 = NULL
  SET @v_gentable2 = NULL
  SET @o_error_code = 0
  SET @o_error_desc = ''
  
  SELECT @v_gentable1 = Gentable1id, @v_gentable2 = Gentable2id
  FROM gentablesrelationships
  WHERE gentablesrelationshipkey = 24
  
  IF @@ERROR != 0 OR @@ROWCOUNT = 0 BEGIN
    SET @o_error_code = 1
    SET @o_error_desc = 'Could not get web tab/section config from gentablesrelationshipdetail.'
    RETURN
  END

  -- Start with the columns defined for this tab in the gentablesrelationshipdetail
  SELECT s.tableid, s.datacode, s.datasubcode, s.datadesc, 
    CASE WHEN d.sortorder IS NULL THEN s.sortorder ELSE d.sortorder END sortorder, 
    NULL relateddatacode, NULL indicator1
	INTO #gentablesitemtypeinfo	  
  FROM subgentables s
  INNER JOIN gentablesrelationshipdetail d
    ON (d.gentablesrelationshipkey = 24 
        AND d.code1 = @i_tabcode
        AND d.subcode1 = @i_tabsubcode
        AND s.datacode = d.code2
        AND s.datasubcode = d.subcode2)
  WHERE s.tableid = @v_gentable2

  -- Update with values filtered for all classes of this item type (if any)
  ;WITH CTE_columns
  AS  
  (  
    SELECT gi.tableid, gi.datacode, gi.datasubcode, gi.text1, gi.sortorder, gi.relateddatacode, gi.indicator1
      FROM gentablesitemtype gi, subgentables s
      WHERE gi.tableid = s.tableid AND
        gi.datacode = s.datacode AND
        gi.datasubcode = s.datasubcode AND
        gi.tableid = s.tableid AND
        gi.itemtypecode = @i_itemtypecode AND
        gi.itemtypesubcode = 0
  )  
  UPDATE gti SET 
    gti.datadesc = CASE WHEN ISNULL(cte.text1, '') != '' THEN cte.text1 ELSE gti.datadesc END,
    gti.sortorder = CASE WHEN cte.sortorder IS NOT NULL THEN cte.sortorder ELSE gti.sortorder END,
    gti.relateddatacode = CASE WHEN cte.relateddatacode IS NOT NULL THEN cte.relateddatacode ELSE gti.relateddatacode END,
    gti.indicator1 = CASE WHEN cte.indicator1 IS NOT NULL THEN cte.indicator1 ELSE gti.indicator1 END
  FROM #gentablesitemtypeinfo gti
    INNER JOIN CTE_columns cte 
      ON  cte.tableid = gti.tableid
      AND cte.datacode = gti.datacode
      AND cte.datasubcode = gti.datasubcode

  IF ISNULL(@i_usageclasscode, 0) > 0
  BEGIN
    -- Update with values specific to this usage class (if any)
    ;WITH CTE_columns
    AS  
    (  
      SELECT gi.tableid, gi.datacode, gi.datasubcode, gi.text1, gi.sortorder, gi.relateddatacode, gi.indicator1
        FROM gentablesitemtype gi, subgentables s
        WHERE gi.tableid = s.tableid AND
          gi.datacode = s.datacode AND
          gi.datasubcode = s.datasubcode AND
          gi.tableid = s.tableid AND
          gi.itemtypecode = @i_itemtypecode AND
          gi.itemtypesubcode = @i_usageclasscode
    )  
    UPDATE gti SET 
      gti.datadesc = CASE WHEN ISNULL(cte.text1, '') != '' THEN cte.text1 ELSE gti.datadesc END,
      gti.sortorder = CASE WHEN cte.sortorder IS NOT NULL THEN cte.sortorder ELSE gti.sortorder END,
      gti.relateddatacode = CASE WHEN cte.relateddatacode IS NOT NULL THEN cte.relateddatacode ELSE gti.relateddatacode END,
      gti.indicator1 = CASE WHEN cte.indicator1 IS NOT NULL THEN cte.indicator1 ELSE gti.indicator1 END
    FROM #gentablesitemtypeinfo gti
      INNER JOIN CTE_columns cte
        ON  cte.tableid = gti.tableid
        AND cte.datacode = gti.datacode
        AND cte.datasubcode = gti.datasubcode
  END
        
  -- Finally restore any sortorders from the gentablesrelationshipdetail so that each tab can have its own layout
  -- This will override item type filtered sort orders
  ;WITH CTE_columns
  AS  
  (  
    SELECT s.tableid, s.datacode, s.datasubcode, d.sortorder
    FROM subgentables s
    INNER JOIN gentablesrelationshipdetail d
      ON (d.gentablesrelationshipkey = 24 
          AND d.code1 = @i_tabcode
          AND d.subcode1 = @i_tabsubcode
          AND s.datacode = d.code2
          AND s.datasubcode = d.subcode2)
    WHERE s.tableid = @v_gentable2
  )  
  UPDATE gti SET 
    gti.sortorder = CASE WHEN cte.sortorder IS NOT NULL THEN cte.sortorder ELSE gti.sortorder END
  FROM #gentablesitemtypeinfo gti
    INNER JOIN CTE_columns cte 
      ON  cte.tableid = gti.tableid
      AND cte.datacode = gti.datacode
      AND cte.datasubcode = gti.datasubcode

  IF @@ERROR != 0 BEGIN
    SET @o_error_code = 1
    SET @o_error_desc = 'Error accessing gentablesitemtype table (tableid=' + CONVERT(VARCHAR, @v_gentable2) + ').'
    RETURN
  END

  SELECT * FROM #gentablesitemtypeinfo ORDER BY datasubcode

END
GO

GRANT EXEC ON qcontract_get_payment_tab_sectionconfig TO PUBLIC
GO
