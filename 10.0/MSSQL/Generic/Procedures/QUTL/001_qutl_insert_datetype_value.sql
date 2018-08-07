
/****** Object:  StoredProcedure [dbo].[qutl_insert_datetype_value]    Script Date: 01/09/2015 11:56:09 ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER OFF
GO

IF EXISTS(SELECT * FROM sys.objects WHERE type = 'p' and name = 'qutl_insert_datetype_value' ) 
drop procedure qutl_insert_datetype_value
go

CREATE PROCEDURE [dbo].[qutl_insert_datetype_value]
 (@i_qsicode              integer,
  @i_description          varchar (40),
  @i_sortorder  		  integer,
  @i_lockbyqsiind		  integer,
  @o_datetypecode         integer output,
  @o_error_code           integer output,
  @o_error_desc			  varchar(2000) output)
AS

/******************************************************************************
**  Name: qutl_insert_datetype_value
**  Desc: This stored procedure searches to see if the date type value sent matches 
**        an existing value on either qsicode or description.  If a match is found, 
**        it is updated and the existing datetypecode is returned.  If it is not found
**        it is inserted and the new datetypecode is returned    
**    Auth: SLB
**    Date: 9 Jul 2015
*******************************************************************************
**    Change History
*******************************************************************************
**    Date:    Author:        Description:
**    --------    --------        -------------------------------------------
**    
*******************************************************************************/

  DECLARE 
    @v_max_code INT,
    @v_max_key  INT,
    @v_error  INT,
    @v_windowid INT,
    @v_windowtitle VARCHAR (80),
    @v_prevdescription VARCHAR (40),
    @v_securitygroupkey INT,
    @v_windowcategoryid INT
     
  SET @o_error_code = 0
  SET @o_error_desc = ''
  SET @v_windowid = 0
  SET @v_prevdescription = ' '
  SET @v_max_code = 0
  SET @v_max_key = 0
    
BEGIN

  SET @o_datetypecode = 0 
  IF @i_qsicode IS NOT NULL and @i_qsicode <>0
      SELECT TOP 1 @o_datetypecode = datetypecode, @v_prevdescription = description FROM datetype
		  WHERE (qsicode = @i_qsicode)
		  
  IF  @o_datetypecode = 0 OR @o_datetypecode is NULL
   	  SELECT TOP 1 @o_datetypecode = datetypecode, @v_prevdescription = description  FROM datetype
       WHERE (LOWER(description) = LOWER (@i_description)) 
       
  IF @o_datetypecode = 0 OR @o_datetypecode is NULL  BEGIN  --Value does not exist already and must be inserted  
    SELECT @v_max_code = MAX(datetypecode)
	  FROM datetype
  
	IF @v_max_code IS NULL
	   SET @v_max_code = 0
	
	SET @o_datetypecode = @v_max_code +1
    
    INSERT INTO datetype
      (tableid, datetypecode, description, printkeydependent, changetitlestatusind, activeind, sortorder, qsicode,
      lastuserid, lastmaintdate, lockbyqsiind, lockbyeloquenceind, showintaqind)
    VALUES
      (323, @o_datetypecode , @i_description, 0, 0, 1, @i_sortorder, @i_qsicode, 'QSIDBA', getdate(), @i_lockbyqsiind, 0, 1)
  
    SELECT @v_error = @@ERROR
    IF @v_error <> 0 BEGIN
      SET @o_error_code = -1
      SET @o_error_desc = 'Insert to date type table had an error' + ', datetypecode=' + cast(@o_datetypecode AS VARCHAR) 
      + ', desc= ' + @i_description
    END    
  END  --Insert datetype Value
  ELSE BEGIN  -- Gentable Value exists already based on description or qsicode so no insert is necessary; update the existing values 
      --Only want to update the qsicode if it does not already exist on the database and it is not null or zero 
      If @i_qsicode IS NOT NULL AND @i_qsicode <> 0 BEGIN 
        UPDATE datetype
	    SET qsicode= @i_qsicode
	    WHERE (datetypecode = @o_datetypecode ) 
	    	    SELECT @v_error = @@ERROR
        IF @v_error <> 0 BEGIN
          SET @o_error_code = -1
          SET @o_error_desc = 'qsicode update to date type table had an error, datetypecode=' 
          + cast(@o_datetypecode AS VARCHAR) + ', desc= ' + @i_description
          RETURN 
        END 
      END  --Update with qsicode
      
    --Only want to update the sortorder if it is a valid sortorder; always update description and lockbyqsi
      If @i_sortorder IS NULL BEGIN
        UPDATE datetype
	    SET description = @i_description, lockbyqsiind = @i_lockbyqsiind
	    WHERE (datetypecode = @o_datetypecode ) 
	  END
	  ELSE  BEGIN
        UPDATE datetype
	    SET description = @i_description, lockbyqsiind = @i_lockbyqsiind, sortorder = @i_sortorder
	    WHERE (datetypecode = @o_datetypecode )
	  END  	  

    SELECT @v_error = @@ERROR
    IF @v_error <> 0 BEGIN
      SET @o_error_code = -1
      SET @o_error_desc = 'update to datetype table had an error, datetypecode=' 
      + cast(@o_datetypecode AS VARCHAR) + ', desc= ' + @i_description
    END 
  END  --Update datetype Value 
   
END  --End Stored Procedure

GO
GRANT EXEC ON qutl_insert_datetype_value TO PUBLIC
GO



