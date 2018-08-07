if exists (select * from dbo.sysobjects where id = object_id(N'dbo.qpl_create_prod_qty_specitem') and OBJECTPROPERTY(id, N'IsProcedure') = 1)
  drop procedure dbo.qpl_create_prod_qty_specitem
GO

CREATE PROCEDURE qpl_create_prod_qty_specitem (  
  @i_taqprojectformatkey   INT,
  @i_userid 			VARCHAR(30),
  @o_error_code   INT OUTPUT,
  @o_error_desc   VARCHAR(2000) OUTPUT)
AS

/******************************************************************************************
**  Name: qpl_create_prod_qty_specitem
**  Desc: This stored procedure will create a production quantity spec. item if not already exists
**        for the given version format.
**
**  Auth: Kusum
**  Date: March 14 2012
********************************************************************************************************
**    Change History
**********************************************************************************************************
**    Date:       Author:      Case #:   Description:
**    --------    --------     -------   --------------------------------------
**   01/14/2015   Uday Khisty  31244     Change to allow itemdetailsubcode & itemdetailsub2code to be copied over
**   11/07/2017   Colman       47625     Removed changes from previous version.
**********************************************************************************************************/

DECLARE
  @v_count	INT,
  @v_count2	INT,
  @v_taqprojectkey INT,  
  @v_plstagecode  INT,
  @v_taqversionkey  INT,
  @v_taqversionspecategorykey	INT,
  @v_new_taqversionspecitemkey	INT,
  @v_error  INT,
  @v_summarydatacode      INT,
  @v_summarydatadesc			VARCHAR(40),
  @v_prodqtydatacode        INT
    
BEGIN
  SET @o_error_code = 0
  SET @o_error_desc = ''
    
  IF @i_taqprojectformatkey IS NULL OR @i_taqprojectformatkey <= 0 BEGIN
    SET @o_error_desc = 'Invalid taqprojectformatkey.'
    GOTO RETURN_ERROR
  END

  SELECT @v_count = count(*)
    FROM gentables 
   WHERE tableid = 616 
     AND qsicode = 1
  
  IF @v_count = 0 BEGIN
    SET @o_error_desc = 'Summary Data Code not available from gentables tableid =  616 and qsicode = 1.'
    GOTO RETURN_ERROR
  END  

  SELECT @v_count = count(*)
    FROM subgentables 
   WHERE tableid = 616 
     AND qsicode = 6

  IF @v_count = 0 BEGIN
    SET @o_error_desc = 'Prodqtydatacode is not available for subgentables tableid = 616 and qsicode = 6.'
    GOTO RETURN_ERROR
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

  SELECT @v_count = count(*)
    FROM taqversionspeccategory
   WHERE taqversionformatkey = @i_taqprojectformatkey
     AND itemcategorycode = @v_summarydatacode

  IF @v_count = 0 BEGIN
		SELECT @v_taqprojectkey = taqprojectkey,@v_plstagecode = plstagecode, @v_taqversionkey = taqversionkey
      FROM taqversionformat
     WHERE taqprojectformatkey = @i_taqprojectformatkey

		EXEC get_next_key @i_userid, @v_taqversionspecategorykey OUTPUT

    INSERT INTO taqversionspeccategory
      (taqversionspecategorykey, taqprojectkey, plstagecode, taqversionkey, taqversionformatkey, itemcategorycode, 
       speccategorydescription, scaleprojecttype, vendorcontactkey,lastuserid, lastmaintdate)
     VALUES
       (@v_taqversionspecategorykey, @v_taqprojectkey ,@v_plstagecode, @v_taqversionkey, @i_taqprojectformatkey, @v_summarydatacode,
        @v_summarydatadesc, NULL, NULL, @i_userid, getdate())
         
     SELECT @v_error = @@ERROR
     IF @v_error <> 0 BEGIN
        SET @o_error_desc = 'Could not insert into taqversionspeccategory table (Error ' + cast(@v_error AS VARCHAR) + ').'
        GOTO RETURN_ERROR
     END
  END
  ELSE BEGIN
    SELECT @v_taqversionspecategorykey = taqversionspecategorykey
      FROM taqversionspeccategory
     WHERE taqversionformatkey = @i_taqprojectformatkey
       AND itemcategorycode = @v_summarydatacode

     SELECT @v_error = @@ERROR
     IF @v_error <> 0 BEGIN
        SET @o_error_desc = 'Could not select taqversionspecategorykey from taqversionspeccategory table (Error ' + cast(@v_error AS VARCHAR) + ').'
        GOTO RETURN_ERROR
     END
  END
   
	SELECT @v_count2 = count(*)
    FROM taqversionspecitems
   WHERE taqversionspecategorykey = @v_taqversionspecategorykey
     AND itemcode = @v_prodqtydatacode

  IF @v_count2 = 0 BEGIN
		-- generate new taqversionspecitemkey
    EXEC get_next_key @i_userid,  @v_new_taqversionspecitemkey OUTPUT

		INSERT INTO taqversionspecitems
      (taqversionspecitemkey, taqversionspecategorykey, itemcode, itemdetailcode, itemdetailsubcode, itemdetailsub2code, 
        quantity, validforprtgscode, description, decimalvalue, unitofmeasurecode, lastuserid, lastmaintdate)
    VALUES
      (@v_new_taqversionspecitemkey, @v_taqversionspecategorykey, @v_prodqtydatacode, NULL, NULL, NULL, 
       NULL, 3, NULL, NULL, NULL, @i_userid, getdate())

	  SELECT @v_error = @@ERROR
    IF @v_error <> 0 BEGIN
      SET @o_error_desc = 'Could not insert into taqversionspecitems table (Error ' + cast(@v_error AS VARCHAR) + ').'
      GOTO RETURN_ERROR
    END
  END
  
  RETURN
    
  RETURN_ERROR:
    SET @o_error_code = -1
    RETURN
      
END
GO

GRANT EXEC ON qpl_create_prod_qty_specitem TO PUBLIC
GO