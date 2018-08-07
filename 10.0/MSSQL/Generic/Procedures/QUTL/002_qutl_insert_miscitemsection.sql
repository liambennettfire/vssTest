
/****** Object:  StoredProcedure [dbo].[qutl_insert_miscitemsection]    Script Date: 01/09/2015 11:56:09 ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER OFF
GO

IF EXISTS(SELECT * FROM sys.objects WHERE type = 'p' and name = 'qutl_insert_miscitemsection' ) 
     DROP PROCEDURE qutl_insert_miscitemsection 
go

CREATE PROCEDURE [dbo].[qutl_insert_miscitemsection]
 (@i_miscqsicode		integer,
  @i_firedistkey        integer,
  @i_miscname           varchar (50),  
  @i_classqsicode		integer,
  @i_miscsectionlabel	varchar (100),
  @i_sectionposition    integer, 
  @i_columnnumber		integer,
  @i_itemposition		integer,
  @i_updateind			integer,
  @o_error_code         integer output,
  @o_error_desc			varchar(2000) output)
AS

/********************************************************************************************
**  Name: qutl_insert_miscitemsection  
**  Desc: This stored procedure searches to see if a miscitemsection exists based on qsicode, 
**        firedistkey or miscname for item and item type qsicode and defaultlabeldesc for   
**        qsiconfigject.  If no existing value is found, it is inserted; else l.
**        If it is found, it will be updated with position, column number and updateind    
**    Auth: SLB
**    Date: 11 Jan 2015
**********************************************************************************************
**    Change History
**********************************************************************************************
**    Date:    Author:        Description:
**    --------    --------        --------------------------------------------------------
**    
**********************************************************************************************/

  DECLARE 

  @v_itemtypecode		integer,
  @v_itemtypedesc		varchar(40),
  @v_classcode			integer,
  @v_misckey            integer,
  @v_configobjectkey    integer,
  @v_count  INT    
  
  SET @o_error_code = 0
  SET @o_error_desc = ''
    
    
BEGIN

    IF @i_miscqsicode IS NOT NULL AND @i_miscqsicode <>0
      SELECT TOP 1 @v_misckey= misckey FROM bookmiscitems
		  WHERE (qsicode = @i_miscqsicode)
 	  
  IF  (@v_misckey = 0 OR @v_misckey is NULL)AND @i_firedistkey IS NOT NULL AND @i_firedistkey <>0
   	  SELECT TOP 1 @v_misckey= misckey FROM bookmiscitems
		  WHERE (firedistkey = @i_firedistkey)		  
 	    
  IF  @v_misckey = 0 OR @v_misckey is NULL
   	  SELECT TOP 1 @v_misckey= misckey FROM bookmiscitems
		  WHERE (LOWER(miscname) = LOWER(@i_miscname)) 

  IF @v_misckey = 0 OR @v_misckey is NULL BEGIN     
    --no bookmiscitems row exists for the qsicode, firedistkey or miscname   
	SET @o_error_code = -1
	SET @o_error_desc = 'No misc item exists for '+ @i_miscname
	RETURN
  END	
  ELSE  
    -- Get Item Type and class codes from the class qsicode
	IF @i_classqsicode = 0  BEGIN
		 --HOME page
      SET @v_itemtypecode = 0
      SET @v_classcode = 0
      SET @v_itemtypedesc = 'HOME'
    END
    ELSE  BEGIN
     exec qutl_get_item_class_datacodes_from_qsicodes NULL, @i_classqsicode,  @v_itemtypecode output, @v_classcode output,
         @o_error_code output,@o_error_desc output
	IF @o_error_code <> 0 BEGIN
	  RETURN
	END 
    END   
  
    --Find section; If it doesn't exist, insert it.  If it exists updaet it.  Put section on default window view if not already there
    exec qutl_insert_misc_section     @i_miscsectionlabel, @i_classqsicode, @i_sectionposition,  @v_configobjectkey OUTPUT,
	  @o_error_code OUTPUT, @o_error_desc OUTPUT
	If @o_error_code <> 0 RETURN

	
	SELECT @v_count = count(*) FROM miscitemsection 
	WHERE misckey = @v_misckey AND configobjectkey = @v_configobjectkey AND usageclasscode = @v_classcode AND itemtypecode = @v_itemtypecode 
	
	IF @v_count = 0	
      INSERT INTO miscitemsection
      (misckey, configobjectkey, usageclasscode, itemtypecode, columnnumber, itemposition, updateind, lastuserid, lastmaintdate)
      VALUES (@v_misckey, @v_configobjectkey, @v_classcode, @v_itemtypecode, @i_columnnumber, @i_itemposition,
       @i_updateind, 'QSIDBA', getdate())    
 
  	  SELECT @o_error_code = @@ERROR
	  IF @o_error_code <> 0 BEGIN
	    SET @o_error_code = -1
	    SET @o_error_desc = 'insert to miscitemsection had an error: misckey=' + cast(@v_misckey AS VARCHAR)+ 'miscname ='+ @i_miscname 
		  + 'miscsection = ' + @i_miscsectionlabel
	  END 
	ELSE BEGIN
	  UPDATE miscitemsection 
	  SET columnnumber = @i_columnnumber, itemposition = @i_itemposition, updateind = @i_updateind, 
	   lastuserid = 'QSIDBA', lastmaintdate=getdate() 
	  WHERE misckey = @v_misckey AND configobjectkey = @v_configobjectkey AND usageclasscode = @v_classcode
	    AND itemtypecode = @v_itemtypecode 
 
  	  SELECT @o_error_code = @@ERROR
	  IF @o_error_code <> 0 BEGIN
	    SET @o_error_code = -1
	    SET @o_error_desc = 'insert to miscitemsection had an error: misckey=' + cast(@v_misckey AS VARCHAR)+ 'miscname ='+ @i_miscname 
		  + 'miscsection = ' + @i_miscsectionlabel	
	  END
	END  	
END

GO