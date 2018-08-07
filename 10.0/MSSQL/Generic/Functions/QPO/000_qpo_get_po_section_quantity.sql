IF exists (select * from dbo.sysobjects where id = object_id(N'dbo.qpo_get_po_section_quantity') )
DROP FUNCTION dbo.qpo_get_po_section_quantity
GO

SET QUOTED_IDENTIFIER ON 
GO
SET ANSI_NULLS ON 
GO

CREATE FUNCTION dbo.qpo_get_po_section_quantity 
	(
		@i_po_formatkey as integer
	)
RETURNS integer

/*******************************************************************************************************
**  Name: [qpo_get_po_section_quantity]
**  Desc: This function returns the section quantity for a po section
**
**  Auth: Colman
**  Date: February 10, 2017
*******************************************************************************************************/

BEGIN 
  DECLARE
    @v_quantity INT,
    @v_count    INT
    
  SET @v_quantity = NULL
  
  -- Check how many components for the current related project on this PO have quantity filled in
  SELECT @v_count = COUNT(*)
  FROM taqversionrelatedcomponents_view v, taqversionspeccategory c
  WHERE v.relatedcategorykey = c.taqversionspecategorykey
    AND v.taqversionformatkey = @i_po_formatkey
    AND c.quantity > 0 
               
  IF @v_count = 1 --only one component has quantity filled in - use that quantity
    SELECT @v_quantity = c.quantity
    FROM taqversionrelatedcomponents_view v, taqversionspeccategory c
    WHERE v.relatedcategorykey = c.taqversionspecategorykey
    AND v.taqversionformatkey = @i_po_formatkey
    AND c.quantity > 0 				  
  ELSE IF @v_count > 1 -- multiple components/quantities
  BEGIN
    -- Check if all components have the same quantity
    SELECT @v_count = COUNT(DISTINCT c.quantity)
    FROM taqversionrelatedcomponents_view v, taqversionspeccategory c
    WHERE v.relatedcategorykey = c.taqversionspecategorykey
    AND v.taqversionformatkey = @i_po_formatkey
    AND c.quantity > 0
         
    IF @v_count = 1 -- all components have the same quantity - get first row's quantity
    SELECT TOP 1 @v_quantity = c.quantity
    FROM taqversionrelatedcomponents_view v, taqversionspeccategory c
    WHERE v.relatedcategorykey = c.taqversionspecategorykey
      AND v.taqversionformatkey = @i_po_formatkey
      AND c.quantity > 0
    ELSE IF @v_count > 1  --multiple components with different quantities - get the Finished Good quantity
    SELECT TOP 1 @v_quantity = c.quantity
    FROM taqversionrelatedcomponents_view v, taqversionspeccategory c
    WHERE v.relatedcategorykey = c.taqversionspecategorykey
      AND v.taqversionformatkey = @i_po_formatkey
      AND c.quantity > 0
      AND c.finishedgoodind = 1
    ELSE
    SET @v_quantity = NULL
  END

  RETURN @v_quantity
  
END
GO

GRANT EXEC ON dbo.qpo_get_po_section_quantity TO PUBLIC
GO