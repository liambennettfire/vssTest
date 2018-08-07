IF EXISTS (SELECT * FROM sysobjects WHERE type = 'P' AND name = 'qtitle_update_bookwhupdate')
  BEGIN
    PRINT 'Dropping Procedure qtitle_update_bookwhupdate'
    DROP  Procedure  qtitle_update_bookwhupdate
  END

GO

PRINT 'Creating Procedure qtitle_update_bookwhupdate'
GO

CREATE PROCEDURE qtitle_update_bookwhupdate
 (@i_bookkey            integer,
  @i_userid             varchar(30),
  @o_error_code         integer output,
  @o_error_desc         varchar(2000) output)
AS

/******************************************************************************
**  File: 
**  Name: qtitle_update_bookwhupdate
**  Desc: 
**
**              
**    Return values: 
**
**    Called by:   
**              
**    Parameters:
**    Input              
**    ----------         
**    bookkey - bookkey of title - Required
**    userid - Userid of user causing write to bookwhupdate - Required
**    
**    Output
**    -----------
**    error_code - error code
**    error_desc - error message - empty if No Error
**
**    Auth: Alan Katzen
**    Date: 4/27/04
*******************************************************************************
**    Change History
*******************************************************************************
**    Date:     Author:         Description:
**    --------  --------        -------------------------------------------
**    
*******************************************************************************/

  -- verify that all required values are filled in
  IF @i_userid IS NULL OR ltrim(rtrim(@i_userid)) = '' BEGIN
    SET @o_error_code = -1
    SET @o_error_desc = 'Unable to update bookwhupdate: userid is empty.'
    RETURN
  END 

  IF @i_bookkey IS NULL OR @i_bookkey = 0 BEGIN
    SET @o_error_code = -1
    SET @o_error_desc = 'Unable to update bookwhupdate: bookkey is empty.'
    RETURN
  END 

  SET @o_error_code = 0
  SET @o_error_desc = ''
  DECLARE @error_var    INT,
          @rowcount_var INT,
          @userid_var VARCHAR(30)

  SELECT @userid_var=lastuserid  
    FROM bookwhupdate
   WHERE bookkey = @i_bookkey 

  SELECT @error_var = @@ERROR, @rowcount_var = @@ROWCOUNT
  IF @error_var <> 0 BEGIN
    SET @o_error_code = -1
    SET @o_error_desc = 'Unable to update bookwhupdate (' + cast(@error_var AS VARCHAR) + ').'
    RETURN
  END 
  IF @rowcount_var <= 0 BEGIN
    -- Insert to bookwhupdate
    INSERT INTO bookwhupdate (bookkey,lastuserid,lastmaintdate)
         VALUES (@i_bookkey,@i_userid,getdate())

    SELECT @error_var = @@ERROR, @rowcount_var = @@ROWCOUNT
    IF @error_var <> 0 OR @rowcount_var <= 0 BEGIN
      SET @o_error_code = -1
      SET @o_error_desc = 'Unable to insert into bookwhupdate (' + cast(@error_var AS VARCHAR) + ').'
      RETURN
    END 
  END 
  ELSE BEGIN
    -- Row already exists - Update userid and lastmaintdate
    UPDATE bookwhupdate
       SET lastuserid = @i_userid, lastmaintdate = getdate()
     WHERE bookkey = @i_bookkey

    SELECT @error_var = @@ERROR, @rowcount_var = @@ROWCOUNT
    IF @error_var <> 0 OR @rowcount_var <= 0 BEGIN
      SET @o_error_code = -1
      SET @o_error_desc = 'Unable to update bookwhupdate (' + cast(@error_var AS VARCHAR) + ').'
      RETURN
    END 
  END
  
  RETURN 
GO

GRANT EXEC ON qtitle_update_bookwhupdate TO PUBLIC
GO




















