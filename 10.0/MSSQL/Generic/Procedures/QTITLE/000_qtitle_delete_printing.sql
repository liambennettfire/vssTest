IF OBJECT_ID('qtitle_delete_printing ') IS NOT NULL
BEGIN
  DROP PROCEDURE qtitle_delete_printing
END 
GO

/**************************************************************************************************************************
**  Name: qtitle_delete_printing
**        Based on deletetitle_delete_printing which is called from the desktop application and should no longer be used
**
**  Desc: Deletes from printing and printingkey related tables based on bookkey
**
**       @i_optionflags is a bit mask. current options are:
**          0x01 - Verify only
**          0x02 - Force delete
**
**  Auth: Colman
**  Date: 08/18/2017
***************************************************************************************************************************
**    Change History
***************************************************************************************************************************
**  Date:       Author:   Case:    Description:
**  --------    -------   -------  ----------------------------------------------------------------------------------------
** 07/11/2018	JH		  TM-574   Forced tighter restriction on deletes when Cloud assets belong to this product. 
***************************************************************************************************************************/

CREATE PROCEDURE qtitle_delete_printing
  @i_bookkey     INT,
  @i_printingkey INT,
  @i_userid      VARCHAR(30),
  @i_optionflags INT,
  @o_error_code  INT OUTPUT,
  @o_error_desc  VARCHAR(2000) OUTPUT
AS

BEGIN
  DECLARE
    @v_error_code           INT,
    @v_error_desc           VARCHAR(255),
    @v_count                INT,
    @v_transaction          TINYINT,
    @v_printing_projectkey  INT,
    @v_flag_verifyonly      INT,
    @v_flag_forcedelete     INT

  SET @v_count = 0
  SET @v_error_code = 0
  SET @v_error_desc = ''
  SET @o_error_code = 0
  SET @o_error_desc = ''
  SET @v_transaction = 0
  SET @v_printing_projectkey = 0

  -- Option flag values
  SET @v_flag_verifyonly    = 0x01
  SET @v_flag_forcedelete   = 0x80
  
  -- Check force deletion flag  
  IF (@i_optionflags & @v_flag_forcedelete) > 0
    GOTO BEGIN_DELETE
    
  --------------------- BEGIN VALIDATION ---------------------------

  IF @i_printingkey = 1 AND (@i_optionflags & @v_flag_verifyonly) = 0 BEGIN
    SELECT @v_error_desc = 'Printing #1 can not be deleted. The Title must be deleted instead.'
    GOTO ERROR_OUT
  END 
  
  IF EXISTS
     (SELECT 1
      FROM taqprojectelement, coretitleinfo, gentables  
      WHERE taqprojectelement.bookkey = coretitleinfo.bookkey   
        AND taqprojectelement.elementstatus = gentables.datacode  
        AND taqprojectelement.printingkey = coretitleinfo.printingkey  
        AND taqprojectelement.bookkey = @i_bookkey   
        AND taqprojectelement.printingkey = @i_printingkey   )
  BEGIN
    SELECT @v_error_desc = 'This Printing can not be deleted because assets have been uploaded for it.'
    GOTO ERROR_OUT
  END 

  -- Get the printing taqprojectkey
  SELECT @v_printing_projectkey = ISNULL(tl.taqprojectkey, 0)
    FROM taqproject tp, taqprojecttitle tl
   WHERE tp.taqprojectkey = tl.taqprojectkey
     AND tp.searchitemcode = 14 
     AND tp.usageclasscode = 1
     AND tl.bookkey = @i_bookkey
     AND tl.printingkey = @i_printingkey

  -- Check for related Purchase Orders
  IF EXISTS 
   (SELECT 1  
      FROM projectrelationshipview
     WHERE relatedprojectkey =  @v_printing_projectkey
       AND relationshipcode = (SELECT datacode FROM gentables WHERE tableid = 582 AND qsicode = 25)) -- Printing (for Purchase Orders)
  BEGIN
    SELECT @v_error_desc = 'This Printing can not be deleted because it is associated with a Purchase Order.'
    GOTO ERROR_OUT
  END

  -- Check for related Contracts
  IF EXISTS 
    (SELECT 1
       FROM projectrelationshipview
      WHERE relatedprojectkey = @v_printing_projectkey
        AND relationshipcode = 42) -- Printing (for Contract)
  BEGIN 
    SELECT @v_error_desc = 'This Printing can not be deleted because it is associated with a Contract.'
    GOTO ERROR_OUT
  END
  
  IF (@i_optionflags & @v_flag_verifyonly) > 0
    RETURN
  
  ------------------  BEGIN DELETION --------------------
  
BEGIN_DELETE:
  BEGIN TRANSACTION
  
  SET @v_transaction = 1
  
  -- Remove Printing from any Voided Purchase Orders
  DELETE FROM taqprojectrelationship 
  WHERE taqprojectrelationshipkey IN (
    SELECT taqprojectrelationshipkey
      FROM projectrelationshipview v, taqproject p  
     WHERE v.relatedprojectkey = p.taqprojectkey
       AND v.taqprojectkey = @v_printing_projectkey
       AND v.relationshipcode =  (SELECT datacode FROM gentables WHERE tableid = 582 AND qsicode = 26)
       AND p.taqprojectstatuscode = (SELECT datacode FROM gentables WHERE tableid = 522 AND qsicode = 10)) -- Only Voided POs
  
  -- Delete from printing-level tables   
  -- Delete from bisaccategory  
  DELETE FROM bookbisaccategory WHERE bookkey = @i_bookkey AND printingkey = @i_printingkey 
  IF @@ERROR != 0 BEGIN
    SELECT @v_error_desc = 'Error deleting from bookbisaccategory. bookkey=' + CONVERT(CHAR(10), @i_bookkey) 
        + ' printingkey=' + CONVERT(CHAR(10), @i_printingkey)
    GOTO ERROR_OUT
  END 

  -- Delete from bookcomments 
  DELETE FROM bookcomments WHERE bookkey = @i_bookkey AND printingkey = @i_printingkey  
  IF @@ERROR != 0 BEGIN
    SELECT @v_error_desc = 'Error deleting from bookcomments. bookkey=' + CONVERT(CHAR(10), @i_bookkey) 
        + ' printingkey=' + CONVERT(CHAR(10), @i_printingkey)
    GOTO ERROR_OUT
  END 

  -- Delete from bookcommentrtf  
  DELETE FROM bookcommentrtf WHERE bookkey = @i_bookkey AND printingkey = @i_printingkey 
  IF @@ERROR != 0 BEGIN
    SELECT @v_error_desc = 'Error deleting from bookcommentrtf. bookkey=' + CONVERT(CHAR(10), @i_bookkey) 
        + ' printingkey=' + CONVERT(CHAR(10), @i_printingkey)
    GOTO ERROR_OUT
  END 

  -- Delete from bookedipartner  
  DELETE FROM bookedipartner WHERE bookkey = @i_bookkey AND printingkey = @i_printingkey 
  IF @@ERROR != 0 BEGIN
    SELECT @v_error_desc = 'Error deleting from bookedipartner. bookkey=' + CONVERT(CHAR(10), @i_bookkey) 
        + ' printingkey=' + CONVERT(CHAR(10), @i_printingkey)
    GOTO ERROR_OUT
  END 

  -- Delete from bookedistatus  
  DELETE FROM bookedistatus WHERE bookkey = @i_bookkey AND printingkey = @i_printingkey 
  IF @@ERROR != 0 BEGIN
    SELECT @v_error_desc = 'Error deleting from bookedistatus. bookkey=' + CONVERT(CHAR(10), @i_bookkey) 
        + ' printingkey=' + CONVERT(CHAR(10), @i_printingkey)
    GOTO ERROR_OUT
  END
    
  -- Delete from bookdates  
  DELETE FROM bookdates WHERE bookkey = @i_bookkey AND printingkey = @i_printingkey 
  IF @@ERROR != 0 BEGIN
    SELECT @v_error_desc = 'Error deleting from bookdates. bookkey=' + CONVERT(CHAR(10), @i_bookkey) 
        + ' printingkey=' + CONVERT(CHAR(10), @i_printingkey)
    GOTO ERROR_OUT
  END 

  -- Delete from bookfile  
  DELETE FROM bookfile WHERE bookkey = @i_bookkey AND printingkey = @i_printingkey 
  IF @@ERROR != 0 BEGIN
    SELECT @v_error_desc = 'Error deleting from bookfile. bookkey=' + CONVERT(CHAR(10), @i_bookkey) 
        + ' printingkey=' + CONVERT(CHAR(10), @i_printingkey)
    GOTO ERROR_OUT
  END 

  -- Delete from datehistory  
  DELETE FROM datehistory WHERE bookkey = @i_bookkey AND printingkey = @i_printingkey 
  IF @@ERROR != 0 BEGIN
    SELECT @v_error_desc = 'Error deleting from datehistory for bookkey ' + CONVERT(CHAR(10), @i_bookkey) 
        + ' printingkey=' + CONVERT(CHAR(10), @i_printingkey)
    GOTO ERROR_OUT
  END 

  -- delete any associated printings (taqprojects on web) for the title being deleted 
  EXEC delete_title_associatedprintings @i_bookkey, @i_printingkey, @v_error_code OUTPUT, @v_error_desc OUTPUT
  IF @v_error_code != 0 BEGIN
    --SELECT @v_error_desc = @v_error_desc + ' Error executing delete_title_associatedprintings proc for bookkey ' + CONVERT(CHAR(10), @i_bookkey) 
    GOTO ERROR_OUT
  END

  --delete or UPDATE rows(by nulling out bookkey/printingkey) on taqprojecttask AND related tables
  EXEC delete_title_taqprojecttask @i_bookkey, @i_printingkey, @v_error_code OUTPUT, @v_error_desc OUTPUT
  IF @v_error_code != 0 BEGIN 
    SELECT @v_error_desc = 'Error executing delete_title_taqprojecttask proc for bookkey ' + CONVERT(CHAR(10), @i_bookkey) 
       + ' printingkey=' + CONVERT(CHAR(10), @i_printingkey)
    GOTO ERROR_OUT
  END

  --delete or UPDATE rows(by nulling out bookkey/printingkey) on taqprojecttitle table
  EXEC delete_title_taqprojecttitle @i_bookkey, @i_printingkey, @i_userid, @v_error_code OUTPUT, @v_error_desc OUTPUT
  IF @v_error_code != 0 BEGIN
    SELECT @v_error_desc = 'Error executing delete_title_taqprojecttitle proc. bookkey=' + CONVERT(CHAR(10), @i_bookkey) 
        + ' printingkey=' + CONVERT(CHAR(10), @i_printingkey)
    GOTO ERROR_OUT
  END

   -- #17692  - Deleting titles creates orphaned rows on the taqprojectelement table
  IF EXISTS (SELECT 1 FROM taqprojectelement WHERE bookkey = @i_bookkey AND printingkey = @i_printingkey)
  BEGIN
    SET @v_printing_projectkey = 0
    SELECT @v_printing_projectkey = ISNULL(taqprojectkey, 0)
    FROM taqprojectelement 
    WHERE bookkey = @i_bookkey
      AND printingkey = @i_printingkey

    IF @v_printing_projectkey = 0
    BEGIN
      -- Delete taqprojectelement row  
      DELETE FROM taqprojectelement 
      WHERE bookkey = @i_bookkey 
        AND printingkey = @i_printingkey  
        AND (taqprojectkey = 0 OR taqprojectkey IS NULL)
      
      IF @@ERROR != 0 BEGIN
        SELECT @v_error_desc = 'Error deleting from taqprojectelement. bookkey=' + CONVERT(CHAR(10), @i_bookkey) 
          + ' printingkey=0' 
        GOTO ERROR_OUT
      END 
    END
    ELSE BEGIN
      UPDATE taqprojectelement
      SET bookkey = NULL,
          printingkey = NULL
      WHERE taqprojectkey = @v_printing_projectkey 
        AND bookkey = @i_bookkey
        AND printingkey = @i_printingkey;
    END
  END

  -- Delete from titlehistory  
  DELETE FROM titlehistory WHERE bookkey = @i_bookkey AND printingkey = @i_printingkey 
  IF @@ERROR != 0 BEGIN
    SELECT @v_error_desc = 'Error deleting from titlehistory. bookkey=' + CONVERT(CHAR(10), @i_bookkey) 
        + ' printingkey=' + CONVERT(CHAR(10), @i_printingkey)
    GOTO ERROR_OUT
  END 

  -- Delete from printing  
  DELETE FROM printing WHERE bookkey = @i_bookkey AND printingkey = @i_printingkey  
  IF @@ERROR != 0 BEGIN
    SELECT @v_error_desc = 'Error deleting from printing. bookkey=' + CONVERT(CHAR(10), @i_bookkey) 
        + ' printingkey=' + CONVERT(CHAR(10), @i_printingkey)
    GOTO ERROR_OUT
  END

  -- Delete from booklock  
  DELETE FROM booklock WHERE bookkey = @i_bookkey AND printingkey = @i_printingkey 
  IF @@ERROR != 0 BEGIN
    SELECT @v_error_desc = 'Error deleting from booklock. bookkey=' + CONVERT(CHAR(10), @i_bookkey) 
        + ' printingkey=' + CONVERT(CHAR(10), @i_printingkey)
    GOTO ERROR_OUT
  END 

  -- Delete all rows on bookelement and element related table
  EXEC deletetitle_bookelement @i_bookkey, @i_printingkey, @v_error_code OUTPUT, @v_error_desc OUTPUT
  IF @v_error_code != 0  BEGIN
    SELECT @v_error_desc = 'Error executing deletetitle_bookelement proc. bookkey=' + CONVERT(CHAR(10), @i_bookkey) 
        + ' printingkey=' + CONVERT(CHAR(10), @i_printingkey)
    GOTO ERROR_OUT
  END   


  -- Delete from bookcontact/bookcontactrole tables  
  EXEC deletetitle_bookcontact @i_bookkey, @i_printingkey, @v_error_code OUTPUT, @v_error_desc OUTPUT
  IF @v_error_code != 0 BEGIN
    SELECT @v_error_desc = 'Error executing deletetitle_bookcontact proc. bookkey=' + CONVERT(CHAR(10), @i_bookkey) 
        + ' printingkey=' + CONVERT(CHAR(10), @i_printingkey)
    GOTO ERROR_OUT
  END


  -- Delete from catalog-related tables   
  -- Delete from bookcatalog 
  DELETE FROM bookcatalog WHERE bookkey = @i_bookkey AND printingkey = @i_printingkey 
  IF @@ERROR != 0 BEGIN
    SELECT @v_error_desc = 'Error deleting from bookcatalog. bookkey=' + CONVERT(CHAR(10), @i_bookkey) 
        + ' printingkey=' + CONVERT(CHAR(10), @i_printingkey)
    GOTO ERROR_OUT
  END 

  -- Delete from catalogbookexp  
  DELETE FROM catalogbookexp WHERE bookkey = @i_bookkey AND printingkey = @i_printingkey 
  IF @@ERROR != 0 BEGIN
    SELECT @v_error_desc = 'Error deleting from catalogbookexp. bookkey=' + CONVERT(CHAR(10), @i_bookkey) 
        + ' printingkey=' + CONVERT(CHAR(10), @i_printingkey)
    GOTO ERROR_OUT
  END 

  -- Delete from catalogexpformtext  
  DELETE FROM catalogexpformtext WHERE bookkey = @i_bookkey AND printingkey = @i_printingkey  
  IF @@ERROR != 0 BEGIN
    SELECT @v_error_desc = 'Error deleting from catalogexpformtext. bookkey=' + CONVERT(CHAR(10), @i_bookkey) 
        + ' printingkey=' + CONVERT(CHAR(10), @i_printingkey)
    GOTO ERROR_OUT
  END 

  -- Delete from catalogexpunformtext  
  DELETE FROM catalogexpunformtext WHERE bookkey = @i_bookkey AND printingkey = @i_printingkey 
  IF @@ERROR != 0 BEGIN
    SELECT @v_error_desc = 'Error deleting from catalogexpunformtext. bookkey=' + CONVERT(CHAR(10), @i_bookkey) 
        + ' printingkey=' + CONVERT(CHAR(10), @i_printingkey)
    GOTO ERROR_OUT
  END 
    
  -- Delete from production spec tables  
  DELETE FROM bindingspecs WHERE bookkey = @i_bookkey AND printingkey = @i_printingkey 
  IF @@ERROR != 0 BEGIN
    SELECT @v_error_desc = 'Error deleting from bindingspecs. bookkey=' + CONVERT(CHAR(10), @i_bookkey) 
        + ' printingkey=' + CONVERT(CHAR(10), @i_printingkey)
    GOTO ERROR_OUT
  END

  DELETE FROM bindcolor WHERE bookkey = @i_bookkey AND printingkey = @i_printingkey 
  IF @@ERROR != 0 BEGIN
    SELECT @v_error_desc = 'Error deleting from bindcolor. bookkey=' + CONVERT(CHAR(10), @i_bookkey) 
        + ' printingkey=' + CONVERT(CHAR(10), @i_printingkey)
    GOTO ERROR_OUT
  END   

  DELETE FROM bookillus WHERE bookkey = @i_bookkey AND printingkey = @i_printingkey 
  IF @@ERROR != 0 BEGIN
    SELECT @v_error_desc = 'Error deleting from bookillus. bookkey=' + CONVERT(CHAR(10), @i_bookkey) 
        + ' printingkey=' + CONVERT(CHAR(10), @i_printingkey)
    GOTO ERROR_OUT
  END 

  DELETE FROM coverspecs WHERE bookkey = @i_bookkey AND printingkey = @i_printingkey 
  IF @@ERROR != 0 BEGIN
    SELECT @v_error_desc = 'Error deleting from coverspecs. bookkey=' + CONVERT(CHAR(10), @i_bookkey) 
        + ' printingkey=' + CONVERT(CHAR(10), @i_printingkey)
    GOTO ERROR_OUT
  END 

  DELETE FROM jacketspecs WHERE bookkey = @i_bookkey AND printingkey = @i_printingkey 
  IF @@ERROR != 0 BEGIN
    SELECT @v_error_desc = 'Error deleting from jacketspecs. bookkey=' + CONVERT(CHAR(10), @i_bookkey) 
        + ' printingkey=' + CONVERT(CHAR(10), @i_printingkey)
    GOTO ERROR_OUT
  END 

  DELETE FROM jackcolor WHERE bookkey = @i_bookkey AND printingkey = @i_printingkey  
  IF @@ERROR != 0 BEGIN
    SELECT @v_error_desc = 'Error deleting from jackcolor. bookkey=' + CONVERT(CHAR(10), @i_bookkey) 
        + ' printingkey=' + CONVERT(CHAR(10), @i_printingkey)
    GOTO ERROR_OUT
  END 

  DELETE FROM jacketfoilcolors WHERE bookkey = @i_bookkey AND printingkey = @i_printingkey 
  IF @@ERROR != 0 BEGIN
    SELECT @v_error_desc = 'Error deleting from jacketfoilcolors. bookkey=' + CONVERT(CHAR(10), @i_bookkey) 
        + ' printingkey=' + CONVERT(CHAR(10), @i_printingkey)
    GOTO ERROR_OUT
  END 

  DELETE FROM textspecs WHERE bookkey = @i_bookkey AND printingkey = @i_printingkey 
  IF @@ERROR != 0 BEGIN
    SELECT @v_error_desc = 'Error deleting from textspecs. bookkey=' + CONVERT(CHAR(10), @i_bookkey) 
        + ' printingkey=' + CONVERT(CHAR(10), @i_printingkey)
    GOTO ERROR_OUT
  END 

  DELETE FROM textcolor WHERE bookkey = @i_bookkey AND printingkey = @i_printingkey 
  IF @@ERROR != 0 BEGIN
    SELECT @v_error_desc = 'Error deleting from textcolor. bookkey=' + CONVERT(CHAR(10), @i_bookkey) 
        + ' printingkey=' + CONVERT(CHAR(10), @i_printingkey)
    GOTO ERROR_OUT
  END 

  DELETE FROM illus WHERE bookkey = @i_bookkey AND printingkey = @i_printingkey 
  IF @@ERROR != 0 BEGIN
    SELECT @v_error_desc = 'Error deleting from illus. bookkey=' + CONVERT(CHAR(10), @i_bookkey) 
        + ' printingkey=' + CONVERT(CHAR(10), @i_printingkey)
    GOTO ERROR_OUT
  END 

  DELETE FROM note WHERE bookkey = @i_bookkey AND printingkey = @i_printingkey 
  IF @@ERROR != 0 BEGIN
    SELECT @v_error_desc = 'Error deleting from note. bookkey=' + CONVERT(CHAR(10), @i_bookkey) 
        + ' printingkey=' + CONVERT(CHAR(10), @i_printingkey)
    GOTO ERROR_OUT
  END 

  DELETE FROM casespecs WHERE bookkey = @i_bookkey AND printingkey = @i_printingkey 
  IF @@ERROR != 0 BEGIN
    SELECT @v_error_desc = 'Error deleting from casespecs. bookkey=' + CONVERT(CHAR(10), @i_bookkey) 
        + ' printingkey=' + CONVERT(CHAR(10), @i_printingkey)
    GOTO ERROR_OUT
  END 

  DELETE FROM assemblyspecs WHERE bookkey = @i_bookkey AND printingkey = @i_printingkey 
  IF @@ERROR != 0 BEGIN
    SELECT @v_error_desc = 'Error deleting from assemblyspecs. bookkey=' + CONVERT(CHAR(10), @i_bookkey) 
        + ' printingkey=' + CONVERT(CHAR(10), @i_printingkey)
    GOTO ERROR_OUT
  END 

  DELETE FROM audiocassettespecs WHERE bookkey = @i_bookkey AND printingkey = @i_printingkey 
  IF @@ERROR != 0 BEGIN
    SELECT @v_error_desc = 'Error deleting from audiocassettespecs. bookkey=' + CONVERT(CHAR(10), @i_bookkey) 
        + ' printingkey=' + CONVERT(CHAR(10), @i_printingkey)
    GOTO ERROR_OUT
  END 

  DELETE FROM audiotapes WHERE bookkey = @i_bookkey AND printingkey = @i_printingkey 
  IF @@ERROR != 0 BEGIN
    SELECT @v_error_desc = 'Error deleting from audiotapes. bookkey=' + CONVERT(CHAR(10), @i_bookkey) 
        + ' printingkey=' + CONVERT(CHAR(10), @i_printingkey)
    GOTO ERROR_OUT
  END 

  DELETE FROM bundlespecs WHERE bookkey = @i_bookkey AND printingkey = @i_printingkey 
  IF @@ERROR != 0 BEGIN
    SELECT @v_error_desc = 'Error deleting from bundlespecs. bookkey=' + CONVERT(CHAR(10), @i_bookkey) 
        + ' printingkey=' + CONVERT(CHAR(10), @i_printingkey)
    GOTO ERROR_OUT
  END 

  DELETE FROM cameraspec WHERE bookkey = @i_bookkey AND printingkey = @i_printingkey 
  IF @@ERROR != 0 BEGIN
    SELECT @v_error_desc = 'Error deleting from cameraspec. bookkey=' + CONVERT(CHAR(10), @i_bookkey) 
        + ' printingkey=' + CONVERT(CHAR(10), @i_printingkey)
    GOTO ERROR_OUT
  END 

  DELETE FROM cardspecs WHERE bookkey = @i_bookkey AND printingkey = @i_printingkey 
  IF @@ERROR != 0 BEGIN
    SELECT @v_error_desc = 'Error deleting from cardspecs. bookkey=' + CONVERT(CHAR(10), @i_bookkey) 
        + ' printingkey=' + CONVERT(CHAR(10), @i_printingkey)
    GOTO ERROR_OUT
  END 

  DELETE FROM cdromspecs WHERE bookkey = @i_bookkey AND printingkey = @i_printingkey 
  IF @@ERROR != 0 BEGIN
    SELECT @v_error_desc = 'Error deleting from cdromspecs. bookkey=' + CONVERT(CHAR(10), @i_bookkey) 
        + ' printingkey=' + CONVERT(CHAR(10), @i_printingkey)
    GOTO ERROR_OUT
  END 

  DELETE FROM cdromcds WHERE bookkey = @i_bookkey AND printingkey = @i_printingkey 
  IF @@ERROR != 0 BEGIN
    SELECT @v_error_desc = 'Error deleting FROM cdromcds. bookkey=' + CONVERT(CHAR(10), @i_bookkey) 
        + ' printingkey=' + CONVERT(CHAR(10), @i_printingkey)
    GOTO ERROR_OUT
  END 

  DELETE FROM diskettespecs WHERE bookkey = @i_bookkey AND printingkey = @i_printingkey 
  IF @@ERROR != 0 BEGIN
    SELECT @v_error_desc = 'Error deleting FROM diskettespecs. bookkey=' + CONVERT(CHAR(10), @i_bookkey) 
        + ' printingkey=' + CONVERT(CHAR(10), @i_printingkey)
    GOTO ERROR_OUT
  END 


  DELETE FROM documentationspecs WHERE bookkey = @i_bookkey AND printingkey = @i_printingkey 
  IF @@ERROR != 0 BEGIN
    SELECT @v_error_desc = 'Error deleting FROM documentationspecs. bookkey=' + CONVERT(CHAR(10), @i_bookkey) 
        + ' printingkey=' + CONVERT(CHAR(10), @i_printingkey)
    GOTO ERROR_OUT
  END 

  DELETE FROM electpackagingspecs WHERE bookkey = @i_bookkey AND printingkey = @i_printingkey 
  IF @@ERROR != 0 BEGIN
    SELECT @v_error_desc = 'Error deleting FROM electpackagingspecs. bookkey=' + CONVERT(CHAR(10), @i_bookkey) 
        + ' printingkey=' + CONVERT(CHAR(10), @i_printingkey)
    GOTO ERROR_OUT
  END 

  DELETE FROM errataspecs WHERE bookkey = @i_bookkey AND printingkey = @i_printingkey 
  IF @@ERROR != 0 BEGIN
    SELECT @v_error_desc = 'Error deleting FROM errataspecs. bookkey=' + CONVERT(CHAR(10), @i_bookkey) 
        + ' printingkey=' + CONVERT(CHAR(10), @i_printingkey)
    GOTO ERROR_OUT
  END 

  DELETE FROM kitspecs WHERE bookkey = @i_bookkey AND printingkey = @i_printingkey 
  IF @@ERROR != 0 BEGIN
    SELECT @v_error_desc = 'Error deleting FROM kitspecs. bookkey=' + CONVERT(CHAR(10), @i_bookkey) 
        + ' printingkey=' + CONVERT(CHAR(10), @i_printingkey)
    GOTO ERROR_OUT
  END 

  DELETE FROM labelspecs WHERE bookkey = @i_bookkey AND printingkey = @i_printingkey 
  IF @@ERROR != 0 BEGIN
    SELECT @v_error_desc = 'Error deleting FROM labelspecs. bookkey=' + CONVERT(CHAR(10), @i_bookkey) 
        + ' printingkey=' + CONVERT(CHAR(10), @i_printingkey)
    GOTO ERROR_OUT
  END 

  DELETE FROM laserdiscspecs WHERE bookkey = @i_bookkey AND printingkey = @i_printingkey 
  IF @@ERROR != 0 BEGIN
    SELECT @v_error_desc = 'Error deleting FROM laserdiscspecs. bookkey=' + CONVERT(CHAR(10), @i_bookkey) 
        + ' printingkey=' + CONVERT(CHAR(10), @i_printingkey)
    GOTO ERROR_OUT
  END 

  DELETE FROM mediainsertspecs WHERE bookkey = @i_bookkey AND printingkey = @i_printingkey 
  IF @@ERROR != 0 BEGIN
    SELECT @v_error_desc = 'Error deleting FROM mediainsertspecs. bookkey=' + CONVERT(CHAR(10), @i_bookkey) 
        + ' printingkey=' + CONVERT(CHAR(10), @i_printingkey)
    GOTO ERROR_OUT
  END 

  DELETE FROM packageoptions WHERE bookkey = @i_bookkey AND printingkey = @i_printingkey 
  IF @@ERROR != 0 BEGIN
    SELECT @v_error_desc = 'Error deleting FROM packageoptions. bookkey=' + CONVERT(CHAR(10), @i_bookkey) 
        + ' printingkey=' + CONVERT(CHAR(10), @i_printingkey)
    GOTO ERROR_OUT
  END 

  DELETE FROM posterspecs WHERE bookkey = @i_bookkey AND printingkey = @i_printingkey 
  IF @@ERROR != 0 BEGIN
    SELECT @v_error_desc = 'Error deleting FROM posterspecs. bookkey=' + CONVERT(CHAR(10), @i_bookkey) 
        + ' printingkey=' + CONVERT(CHAR(10), @i_printingkey)
    GOTO ERROR_OUT
  END 

  DELETE FROM printpackagingspecs WHERE bookkey = @i_bookkey AND printingkey = @i_printingkey 
  IF @@ERROR != 0 BEGIN
    SELECT @v_error_desc = 'Error deleting FROM printpackagingspecs. bookkey=' + CONVERT(CHAR(10), @i_bookkey) 
        + ' printingkey=' + CONVERT(CHAR(10), @i_printingkey)
    GOTO ERROR_OUT
  END 

  DELETE FROM transparencyspecs WHERE bookkey = @i_bookkey AND printingkey = @i_printingkey 
  IF @@ERROR != 0 BEGIN
    SELECT @v_error_desc = 'Error deleting FROM trnsparencyspecs. bookkey=' + CONVERT(CHAR(10), @i_bookkey) 
        + ' printingkey=' + CONVERT(CHAR(10), @i_printingkey)
    GOTO ERROR_OUT
  END 

  DELETE FROM videocassettespecs WHERE bookkey = @i_bookkey AND printingkey = @i_printingkey 
  IF @@ERROR != 0 BEGIN
    SELECT @v_error_desc = 'Error deleting FROM videocassettespecs. bookkey=' + CONVERT(CHAR(10), @i_bookkey) 
        + ' printingkey=' + CONVERT(CHAR(10), @i_printingkey)
    GOTO ERROR_OUT
  END  

  DELETE FROM secondcoverspecs WHERE bookkey = @i_bookkey AND printingkey = @i_printingkey 
  IF @@ERROR != 0 BEGIN
    SELECT @v_error_desc = 'Error deleting FROM secondcoverspecs. bookkey=' + CONVERT(CHAR(10), @i_bookkey) 
        + ' printingkey=' + CONVERT(CHAR(10), @i_printingkey)
    GOTO ERROR_OUT
  END 

  DELETE FROM coverinsertspecs WHERE bookkey = @i_bookkey AND printingkey = @i_printingkey 
  IF @@ERROR != 0 BEGIN
    SELECT @v_error_desc = 'Error deleting FROM coverinsertspecs. bookkey=' + CONVERT(CHAR(10), @i_bookkey) 
        + ' printingkey=' + CONVERT(CHAR(10), @i_printingkey)
    GOTO ERROR_OUT
  END 

  DELETE FROM covinsertcolor WHERE bookkey = @i_bookkey AND printingkey = @i_printingkey 
  IF @@ERROR != 0 BEGIN
    SELECT @v_error_desc = 'Error deleting FROM coverinsertcolor. bookkey=' + CONVERT(CHAR(10), @i_bookkey) 
        + ' printingkey=' + CONVERT(CHAR(10), @i_printingkey)
    GOTO ERROR_OUT
  END

  DELETE FROM covercolor WHERE bookkey = @i_bookkey AND printingkey = @i_printingkey 
  IF @@ERROR != 0 BEGIN
    SELECT @v_error_desc = 'Error deleting FROM covercolor. bookkey=' + CONVERT(CHAR(10), @i_bookkey) 
        + ' printingkey=' + CONVERT(CHAR(10), @i_printingkey)
    GOTO ERROR_OUT
  END  

  DELETE FROM secondcovcolor WHERE bookkey = @i_bookkey AND printingkey = @i_printingkey 
  IF @@ERROR != 0 BEGIN
    SELECT @v_error_desc = 'Error deleting FROM secondcovcolor. bookkey=' + CONVERT(CHAR(10), @i_bookkey) 
        + ' printingkey=' + CONVERT(CHAR(10), @i_printingkey)
    GOTO ERROR_OUT
  END 

  DELETE FROM misccompspecs WHERE bookkey = @i_bookkey AND printingkey = @i_printingkey 
  IF @@ERROR != 0 BEGIN
    SELECT @v_error_desc = 'Error deleting FROM misccompspecs. bookkey=' + CONVERT(CHAR(10), @i_bookkey) 
        + ' printingkey=' + CONVERT(CHAR(10), @i_printingkey)
    GOTO ERROR_OUT
  END 

  DELETE FROM endpapers WHERE bookkey = @i_bookkey AND printingkey = @i_printingkey 
  IF @@ERROR != 0 BEGIN
    SELECT @v_error_desc = 'Error deleting FROM endpapers. bookkey=' + CONVERT(CHAR(10), @i_bookkey) 
        + ' printingkey=' + CONVERT(CHAR(10), @i_printingkey)
    GOTO ERROR_OUT
  END 

  DELETE FROM endpcolor WHERE bookkey = @i_bookkey AND printingkey = @i_printingkey 
  IF @@ERROR != 0 BEGIN
    SELECT @v_error_desc = 'Error deleting FROM endpcolor. bookkey=' + CONVERT(CHAR(10), @i_bookkey) 
        + ' printingkey=' + CONVERT(CHAR(10), @i_printingkey)
    GOTO ERROR_OUT
  END 

  --delete all rows on estbook AND estkey-related table
  EXEC deletetitle_estbook @i_bookkey, @i_printingkey, @v_error_code OUTPUT, @v_error_desc OUTPUT 
  IF @v_error_code != 0 BEGIN
    SELECT @v_error_desc = 'Error executing deletetitle_estbook proc. bookkey=' + CONVERT(CHAR(10), @i_bookkey) 
        + ' printingkey=' + CONVERT(CHAR(10), @i_printingkey)
    GOTO ERROR_OUT
  END   

  --delete all rows on gpo and gpokey-related table
  EXEC deletetitle_gposection @i_bookkey, @i_printingkey, @v_error_code OUTPUT, @v_error_desc OUTPUT
  IF @v_error_code != 0 BEGIN
    SELECT @v_error_desc = 'Error executing deletetitle_gposection proc. bookkey=' + CONVERT(CHAR(10), @i_bookkey) 
        + ' printingkey=' + CONVERT(CHAR(10), @i_printingkey)
    GOTO ERROR_OUT
   END   

  EXEC deletetitle_gposubsection @i_bookkey, @i_printingkey, @v_error_code OUTPUT, @v_error_desc OUTPUT
  IF @v_error_code != 0 BEGIN
    SELECT @v_error_desc = 'Error executing deletetitle_gposubsection proc. bookkey=' + CONVERT(CHAR(10), @i_bookkey) 
        + ' printingkey=' + CONVERT(CHAR(10), @i_printingkey)
    GOTO ERROR_OUT
  END   

  -- Delete from cover combo tables 
  DELETE FROM combobatchtitles WHERE bookkey = @i_bookkey AND printingkey = @i_printingkey 
  IF @@ERROR != 0 BEGIN
    SELECT @v_error_desc = 'Error deleting FROM combobatchtitles. bookkey=' + CONVERT(CHAR(10), @i_bookkey) 
        + ' printingkey=' + CONVERT(CHAR(10), @i_printingkey)
    GOTO ERROR_OUT
  END 

  DELETE FROM combotitle   WHERE bookkey = @i_bookkey AND printingkey = @i_printingkey 
  IF @@ERROR != 0 BEGIN
    SELECT @v_error_desc = 'Error deleting FROM combotitle. bookkey=' + CONVERT(CHAR(10), @i_bookkey) 
        + ' printingkey=' + CONVERT(CHAR(10), @i_printingkey)
    GOTO ERROR_OUT
  END 

  -- Delete from commonforms tables 
  DELETE FROM combobatchtitles WHERE bookkey = @i_bookkey AND printingkey = @i_printingkey 
  IF @@ERROR != 0 BEGIN
    SELECT @v_error_desc = 'Error deleting FROM combobatchtitles. bookkey=' + CONVERT(CHAR(10), @i_bookkey) 
        + ' printingkey=' + CONVERT(CHAR(10), @i_printingkey)
    GOTO ERROR_OUT
  END 

  DELETE FROM commonformsgrouptitles WHERE bookkey = @i_bookkey AND printingkey = @i_printingkey 
  IF @@ERROR != 0 BEGIN
    SELECT @v_error_desc = 'Error deleting FROM commonformsgrouptitles. bookkey=' + CONVERT(CHAR(10), @i_bookkey) 
        + ' printingkey=' + CONVERT(CHAR(10), @i_printingkey)
    GOTO ERROR_OUT
  END 

  -- Delete from commonformstitles  
  DELETE FROM commonformstitles WHERE bookkey = @i_bookkey AND printingkey = @i_printingkey 
  IF @@ERROR != 0 BEGIN
    SELECT @v_error_desc = 'Error deleting FROM commonformstitles. bookkey=' + CONVERT(CHAR(10), @i_bookkey) 
        + ' printingkey=' + CONVERT(CHAR(10), @i_printingkey)
    GOTO ERROR_OUT
  END 

  -- Delete from compspec  
  DELETE FROM compspec WHERE bookkey = @i_bookkey AND printingkey = @i_printingkey 
  IF @@ERROR != 0 BEGIN
    SELECT @v_error_desc = 'Error deleting FROM compspec. bookkey=' + CONVERT(CHAR(10), @i_bookkey) 
        + ' printingkey=' + CONVERT(CHAR(10), @i_printingkey)
    GOTO ERROR_OUT
  END 

  -- Delete from component  
  DELETE FROM component WHERE bookkey = @i_bookkey AND printingkey = @i_printingkey 
  IF @@ERROR != 0 BEGIN
    SELECT @v_error_desc = 'Error deleting FROM component. bookkey=' + CONVERT(CHAR(10), @i_bookkey) 
        + ' printingkey=' + CONVERT(CHAR(10), @i_printingkey)
    GOTO ERROR_OUT
  END 

  DELETE FROM sidestamp WHERE bookkey = @i_bookkey AND printingkey = @i_printingkey
  IF @@ERROR != 0 BEGIN
    SELECT @v_error_desc = 'Error deleting FROM sidestamp. bookkey=' + CONVERT(CHAR(10), @i_bookkey) 
        + ' printingkey=' + CONVERT(CHAR(10), @i_printingkey)
    GOTO ERROR_OUT
  END 

  DELETE FROM spinestamp WHERE bookkey = @i_bookkey AND printingkey = @i_printingkey
  IF @@ERROR != 0 BEGIN
    SELECT @v_error_desc = 'Error deleting FROM spinestamp. bookkey=' + CONVERT(CHAR(10), @i_bookkey) 
        + ' printingkey=' + CONVERT(CHAR(10), @i_printingkey)
    GOTO ERROR_OUT
  END 

  -- Delete FROM booksets 
  DELETE FROM booksets WHERE bookkey = @i_bookkey AND printingkey = @i_printingkey 
  IF @@ERROR != 0 BEGIN
    SELECT @v_error_desc = 'Error deleting FROM booksets. bookkey=' + CONVERT(CHAR(10), @i_bookkey) 
        + ' printingkey=' + CONVERT(CHAR(10), @i_printingkey)
    GOTO ERROR_OUT
  END 

  -- Delete FROM nonbookspecs 
  DELETE FROM nonbookspecs WHERE bookkey = @i_bookkey AND printingkey = @i_printingkey 
  IF @@ERROR != 0 BEGIN
    SELECT @v_error_desc = 'Error deleting FROM nonbookspecs. bookkey=' + CONVERT(CHAR(10), @i_bookkey) 
        + ' printingkey=' + CONVERT(CHAR(10), @i_printingkey)
    GOTO ERROR_OUT
  END 

  -- Delete FROM coretitleinfo 
  DELETE FROM coretitleinfo WHERE bookkey = @i_bookkey AND printingkey = @i_printingkey 
  IF @@ERROR != 0 BEGIN
    SELECT @v_error_desc = 'Error deleting FROM coretitleinfo. bookkey=' + CONVERT(CHAR(10), @i_bookkey) 
        + ' printingkey=' + CONVERT(CHAR(10), @i_printingkey)
    GOTO ERROR_OUT
  END 

  -- Delete from Title Lists  
  DELETE FROM qse_searchresults
   WHERE key1 = @i_bookkey
     AND key2 = @i_printingkey 
     AND listkey IN(SELECT listkey FROM qse_searchlist WHERE searchitemcode = 1)

  IF @@ERROR != 0 BEGIN
    SELECT @v_error_desc = 'Error deleting FROM qse_searchresults. bookkey=' + CONVERT(CHAR(10), @i_bookkey) 
        + ' printingkey=' + CONVERT(CHAR(10), @i_printingkey)
    GOTO ERROR_OUT
  END 

  -- SET NULL to propagatefrombookkey to all titles that are propagated         
  UPDATE book SET propagatefrombookkey = NULL WHERE propagatefrombookkey = @i_bookkey  
  IF @@ERROR != 0 BEGIN
    SELECT @v_error_desc = 'Error removing propagatefrombookkey for bookkey ' + CONVERT(CHAR(10), @i_bookkey) 
    GOTO ERROR_OUT
  END 

  -- Delete any row of printingkey= 0 that might have been created during the delete process - CRM# 5139 
  IF EXISTS (SELECT 1 FROM coretitleinfo WHERE bookkey = @i_bookkey AND printingkey = 0)
  BEGIN
    -- Delete coretitleinfo row with 0 printingkey 
    DELETE FROM coretitleinfo WHERE bookkey = @i_bookkey AND printingkey = 0 ;
    IF @@ERROR != 0 BEGIN
      SELECT @v_error_desc = 'Error deleting FROM coretitleinfo. bookkey=' + CONVERT(CHAR(10), @i_bookkey) 
        + ' printingkey=0' 
      GOTO ERROR_OUT
    END 
  END

  SUCCESS:
    IF @v_transaction = 1
      COMMIT
    RETURN

  ERROR_OUT:
    SELECT @o_error_code = -1
    SELECT @o_error_desc = @v_error_desc 
    PRINT @v_error_desc
    IF @v_transaction = 1
      ROLLBACK
    RETURN

END
GO

GRANT EXEC ON qtitle_delete_printing TO PUBLIC
GO

SET QUOTED_IDENTIFIER OFF 
GO
SET ANSI_NULLS ON 
GO