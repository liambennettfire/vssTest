if exists (select * from dbo.sysobjects where id = object_id(N'dbo.qpl_create_prod_qty_specitem_conversion') and OBJECTPROPERTY(id, N'IsProcedure') = 1)
  drop procedure dbo.qpl_create_prod_qty_specitem_conversion
GO

CREATE PROCEDURE qpl_create_prod_qty_specitem_conversion 
AS

/************************************************************************************************
**  Name: qpl_create_prod_qty_specitem_conversion
**  Desc: This stored procedure will create a production quantity spec. item if not already exists
**        for every version format that currently exists.
**
**  Auth: Kusum
**  Date: April 3 2012
*************************************************************************************************/

DECLARE
  @v_count	INT,
  @v_count2 INT,
  @v_count3 INT,
  @v_taqprojectformatkey INT,
  @v_taqprojectkey INT,  
  @v_plstagecode  INT,
  @v_taqversionkey  INT,
  @v_taqversionspecategorykey	INT,
  @v_error  INT,
  @v_summarydatacode  INT,
  @v_summarydatadesc			VARCHAR(40),
  @v_prodqtydatacode        INT,
  @v_taqversiontype   INT,
  @v_error_code   INT,
  @v_error_desc   VARCHAR(2000)
    
BEGIN
   
  SELECT @v_count = count(*)
    FROM gentables 
   WHERE tableid = 616 
     AND qsicode = 1
  
  IF @v_count = 0 BEGIN
    print 'Summary Data Code not available from gentables tableid =  616 and qsicode = 1.'
    RETURN
  END  

  SELECT @v_count = count(*)
    FROM subgentables 
   WHERE tableid = 616 
     AND qsicode = 6

  IF @v_count = 0 BEGIN
    print 'Prodqtydatacode is not available for subgentables tableid = 616 and qsicode = 6.'
    RETURN
  END  

  SELECT @v_summarydatacode = datacode
    FROM gentables 
   WHERE tableid = 616 
     AND qsicode = 1
     
  SELECT @v_summarydatadesc = datadesc 
		FROM gentables 
	 WHERE tableid = 616 
		 AND datacode = @v_summarydatacode

  SELECT @v_prodqtydatacode = datasubcode
    FROM subgentables 
   WHERE tableid = 616 
     AND qsicode = 6

  DECLARE taqversionformat_cur CURSOR FOR
    SELECT taqprojectformatkey,taqprojectkey,plstagecode,taqversionkey
      FROM taqversionformat

  OPEN taqversionformat_cur

  FETCH taqversionformat_cur INTO @v_taqprojectformatkey,@v_taqprojectkey,@v_plstagecode,@v_taqversionkey

  WHILE (@@FETCH_STATUS=0)
	BEGIN
    SELECT @v_count2 = 0
    SELECT @v_count3 = 0

    SELECT @v_taqversiontype = taqversiontype
      FROM taqversion
     WHERE taqprojectkey = @v_taqprojectkey
       AND plstagecode = @v_plstagecode
       AND taqversionkey = @v_taqversionkey
   
    IF @v_taqversiontype = 1 BEGIN
      SELECT @v_count3 = count(*)
        FROM taqversionspeccategory
       WHERE taqversionformatkey = @v_taqprojectformatkey
         AND itemcategorycode = @v_summarydatacode

      IF @v_count3 = 0 BEGIN
         EXEC qpl_create_prod_qty_specitem @v_taqprojectformatkey,'QSIADMIN',@v_error_code OUTPUT, @v_error_desc OUTPUT
         IF @v_error_code = -1 BEGIN
          print @v_error_desc + ' for ' + CAST(@v_taqprojectformatkey AS VARCHAR)
         END
         ELSE BEGIN
          print 'Production Qty spec item added for taqprojectformatkey: ' + CAST(@v_taqprojectformatkey AS VARCHAR)
         END
      END
      ELSE BEGIN
        SELECT @v_taqversionspecategorykey = taqversionspecategorykey
          FROM taqversionspeccategory
         WHERE taqversionformatkey = @v_taqprojectformatkey
           AND itemcategorycode = @v_summarydatacode

       SELECT @v_count2 = count(*)
         FROM taqversionspecitems
        WHERE taqversionspecategorykey = @v_taqversionspecategorykey
          AND itemcode = @v_prodqtydatacode
        
        IF @v_count2 = 0 BEGIN
          EXEC qpl_create_prod_qty_specitem @v_taqprojectformatkey,'QSIADMIN',@v_error_code OUTPUT, @v_error_desc OUTPUT
          IF @v_error_code = -1 BEGIN
            print @v_error_desc + ' for ' + CAST(@v_taqprojectformatkey AS VARCHAR)
          END
           ELSE BEGIN
            print 'Production Qty spec item added for taqprojectformatkey: ' + CAST(@v_taqprojectformatkey AS VARCHAR)
           END
        END
       END
    END
    FETCH taqversionformat_cur INTO @v_taqprojectformatkey,@v_taqprojectkey,@v_plstagecode,@v_taqversionkey
  END

  CLOSE taqversionformat_cur
	DEALLOCATE taqversionformat_cur
END
GO

GRANT EXEC ON qpl_create_prod_qty_specitem_conversion TO PUBLIC
GO