IF EXISTS (SELECT * FROM sysobjects WHERE type = 'P' AND name = 'qcontact_update_globalcontacthistory')
  DROP  Procedure  qcontact_update_globalcontacthistory
GO

CREATE PROCEDURE qcontact_update_globalcontacthistory
 (@i_tablename          varchar(100),
  @i_columnname         varchar(100),
  @i_globalcontactkey   integer,
  @i_currentstringvalue varchar(255),
  @i_transtype          varchar(25),
  @i_userid             varchar(30),
  @i_fielddescdetail    varchar(120), --not used right now but may be in the future
  @o_error_code         integer output,
  @o_error_desc         varchar(250) output)
AS

/******************************************************************************
**  Name: qcontact_update_globalcontacthistory
**  Desc: 
**              
**    Parameters:
**    Input              
**    ----------         
**    tablename - Name of table where columnname is located - Required
**    columnname - Name of Column to get data to write to history  - Required
**    globalcontactkey - globalcontactkey of contact writing to history - Required
**    currentstringvalue - string version of data to be written to history - Required
**                        (NOTE:  all datacode-like data should be translated prior to the call to this
**                         procedure and the description passed instead)
**    transtype - String that tells us what type of trasaction caused the call to this procedure
**                (insert,update,delete) - Required
**    userid - Userid of user causing write to history - Required
**    
**    Output
**    -----------
**    error_code - error code
**    error_desc - error message - empty if No Error
**
**    Auth: Kusum Basra
**    Date: 10/26/05
*******************************************************************************
**  Change History
*******************************************************************************
**  Date:     Author:   Description:
**  --------  -------   ------------
**  9/5/13    Kate      Rewritten - this procedure was not used before.
*******************************************************************************/

DECLARE
  @v_columndesc VARCHAR(100),
  @v_columnkey  INT,
  @v_currentstringvalue VARCHAR(255),
  @v_exporteloind TINYINT,
  @v_error  INT,
  @v_fielddesc  VARCHAR(80),
  @v_newkey INT,
  @v_rowcount INT

BEGIN

  -- verify tablename and columnname are filled in
  IF @i_tablename IS NULL OR ltrim(rtrim(@i_tablename)) = '' BEGIN
    SET @o_error_code = -1
    SET @o_error_desc = 'Unable to update globalcontacthistory: tablename is empty.'
    RETURN
  END 

  IF @i_columnname IS NULL OR ltrim(rtrim(@i_columnname)) = '' BEGIN
    SET @o_error_code = -1
    SET @o_error_desc = 'Unable to update globalcontacthistory: columnname is empty.'
    RETURN
  END 

  SET @o_error_code = 0
  SET @o_error_desc = ''

  SELECT @v_columnkey = columnkey, @v_columndesc = columndescription, @v_exporteloind = exporteloquenceind
    FROM globalcontacthistorycolumns
   WHERE tablename = @i_tablename AND 
         columnname = @i_columnname AND 
         activeind = 1 

  SELECT @v_error = @@ERROR, @v_rowcount = @@ROWCOUNT
  IF @v_error <> 0 BEGIN
    SET @o_error_code = -1
    SET @o_error_desc = 'Unable to update globalcontacthistory for table ' + @i_tablename + ' column ' + @i_columnname + ' (' + cast(@v_error AS VARCHAR) + ').'
    RETURN
  END 
  IF @v_rowcount <= 0 BEGIN
    -- Not a history column - just return with no error
    SET @o_error_code = 0
    SET @o_error_desc = ''
    RETURN
  END 

  -- History is kept for this column
  -- verify that all other required values are filled in
  IF @i_userid IS NULL OR ltrim(rtrim(@i_userid)) = '' BEGIN
    SET @o_error_code = -1
    SET @o_error_desc = 'Unable to update globalcontacthistory: userid is empty.'
    RETURN
  END 

  IF @i_globalcontactkey IS NULL OR @i_globalcontactkey = 0 BEGIN
    SET @o_error_code = -1
    SET @o_error_desc = 'Unable to update globalcontacthistory: globalcontactkey is empty.'
    RETURN
  END 

  IF @i_transtype IS NULL OR ltrim(rtrim(@i_transtype)) = '' BEGIN
    SET @o_error_code = -1
    SET @o_error_desc = 'Unable to update globalcontacthistory: transtype is empty.'
    RETURN
  END 
 
  BEGIN
    -- Global Contact History
    -- set field desc
    SET @v_fielddesc = @v_columndesc
       
    SET @v_currentstringvalue = ''
    IF @i_currentstringvalue IS NULL OR ltrim(rtrim(@i_currentstringvalue)) = ''
    BEGIN
      IF lower(ltrim(rtrim(@i_transtype))) = 'delete'
        SET @v_currentstringvalue = '(DELETED)'
      ELSE
        SET @v_currentstringvalue = '(Not Present)'   
    END
    ELSE
      IF @i_columnname = 'individualind' BEGIN
        IF @i_currentstringvalue = '1' BEGIN
           SET @v_currentstringvalue = 'N'
        END
        ELSE BEGIN
          SET @v_currentstringvalue = 'Y'
        END
      END
      ELSE BEGIN
        SET @v_currentstringvalue = @i_currentstringvalue
      END
    
    --PRINT 'key=' + CONVERT(VARCHAR, @v_newkey)
    --PRINT 'globalcontactkey=' + CONVERT(VARCHAR, @i_globalcontactkey)
    --PRINT 'columnkey=' + CONVERT(VARCHAR, @v_columnkey)
    --PRINT 'fielddesc=' + @v_fielddesc
    --PRINT 'currstingvalue=' + @v_currentstringvalue
    --PRINT 'exporteloind=' + convert(varchar, @v_exporteloind)

    EXEC next_generic_key @i_userid, @v_newkey OUTPUT, @o_error_code OUTPUT, @o_error_desc OUTPUT
    
    INSERT INTO globalcontacthistory 
      (globalcontacthistorykey, globalcontactkey, columnkey, lastmaintdate, lastuserid,
      currentstringvalue, stringvalue, fielddesc)
    VALUES 
      (@v_newkey, @i_globalcontactkey, @v_columnkey, getdate(), @i_userid,
      @v_currentstringvalue, '', @v_fielddesc)

    SELECT @v_error = @@ERROR, @v_rowcount = @@ROWCOUNT
    IF @v_error <> 0 OR @v_rowcount <= 0 BEGIN
      SET @o_error_code = -1
      SET @o_error_desc = 'Unable to insert into globalcontacthistory (' + cast(@v_error AS VARCHAR) + ').'
      RETURN
    END 
  END
  
  IF @v_exporteloind = 1
  BEGIN
    EXEC qcontact_resend_titles_to_eloquence @i_globalcontactkey, @i_userid, @o_error_code OUTPUT, @o_error_desc OUTPUT 
  END

END
GO

GRANT EXEC ON qcontact_update_globalcontacthistory TO PUBLIC
GO
