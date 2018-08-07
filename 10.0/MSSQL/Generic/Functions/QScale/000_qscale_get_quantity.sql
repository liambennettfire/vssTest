if exists (select * from dbo.sysobjects where id = object_id(N'dbo.get_quantity') and xtype in (N'FN', N'IF', N'TF'))
drop function dbo.get_quantity
GO

CREATE FUNCTION get_quantity
    (@i_taqversionformatyearkey as integer, @i_qsicode as integer) 

RETURNS INT

/**************************************************************************************************
**  Name: get_quantity
**  Desc: This function returns the quantity
**
**    Auth: Kusum Basra
**    Date: 26 March 2012
****************************************************************************************************
**    Change History
*****************************************************************************************************
**    Date:       Author:         Description:
**    --------    --------        -------------------------------------------
**    03/16/17		Dustin					Support for qsicode 8, Case 42876
**    05/04/17      Susan			Updated qsicode 8 for to get project key in more efficient manner
**    05/16/17      Uday            Case 45123
******************************************************************************************************/

BEGIN 
  DECLARE @v_quantity   INT,
          @v_relatedformatkey INT,
					@v_projectkey INT

  SET @v_quantity = 0

  IF @i_qsicode = 6 BEGIN
    SELECT @v_quantity = quantity 
     FROM taqversionformatyear
     WHERE taqversionformatyearkey = @i_taqversionformatyearkey

     IF coalesce(@v_quantity,0) = 0 BEGIN
       -- try to get the quantity from the related finshed good component
       SELECT @v_relatedformatkey = relatedformatkey
         FROM taqversionrelatedcomponents_view
        WHERE firstprtg_taqversionformatyearkey = @i_taqversionformatyearkey
          and relatedfinishedgoodind = 1

       IF @v_relatedformatkey > 0 BEGIN
         SELECT @v_quantity = quantity 
           FROM taqversionformatyear
          WHERE taqprojectformatkey = @v_relatedformatkey
       END 
     END
  END
	ELSE IF @i_qsicode = 8 BEGIN
		SELECT @v_projectkey = taqprojectkey
		FROM taqversionformatyear
		WHERE taqversionformatyearkey = @i_taqversionformatyearkey

		SELECT @v_quantity = tpr.productionqty
		FROM taqprojectrights tpr
		JOIN taqproject tp
		ON tp.taqprojectkey = tpr.taqprojectkey
		WHERE tpr.taqprojectprintingkey = @v_projectkey
		  AND tp.searchitemcode = (SELECT datacode FROM gentables WHERE tableid = 550 AND qsicode = 10)
	END
  else
  begin
    select @v_quantity = dbo.get_quantity_custom(@i_taqversionformatyearkey, @i_qsicode)
  end
	  
  RETURN @v_quantity
 
END
GO

GRANT EXEC ON dbo.get_quantity TO public
GO
