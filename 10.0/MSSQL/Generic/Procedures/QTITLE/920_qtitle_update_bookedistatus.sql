IF EXISTS (SELECT * FROM sysobjects WHERE type = 'P' AND name = 'qtitle_update_bookedistatus')
  BEGIN
    PRINT 'Dropping Procedure qtitle_update_bookedistatus'
    DROP  Procedure  qtitle_update_bookedistatus
  END

GO

PRINT 'Creating Procedure qtitle_update_bookedistatus'
GO

CREATE PROCEDURE qtitle_update_bookedistatus
 (@i_bookkey            integer,
  @i_printingkey        integer,
  @i_userid             varchar(30),
  @o_error_code         integer output,
  @o_error_desc         varchar(2000) output)
AS

/******************************************************************************
**  File: 
**  Name: qtitle_update_bookedistatus
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
**    printingkey - printingkey of title (First Printing will be assumed if 0) - Required
**    userid - Userid of user causing write to bookedistatus - Required
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
    SET @o_error_desc = 'Unable to update bookedistatus: userid is empty.'
    RETURN
  END 

  IF @i_bookkey IS NULL OR @i_bookkey = 0 BEGIN
    SET @o_error_code = -1
    SET @o_error_desc = 'Unable to update bookedistatus: bookkey is empty.'
    RETURN
  END 

  IF @i_printingkey IS NULL OR @i_printingkey = 0 BEGIN
    -- assume first printing if printingkey is not passed in
    SET @i_printingkey = 1
  END 

  SET @o_error_code = 0
  SET @o_error_desc = ''
  DECLARE @error_var    INT,
          @rowcount_var INT,
          @edistatuscode_var INT,
          @prevedistatus_var TINYINT,
          @resend_var TINYINT,
          @donotsend_var TINYINT,
          @neversend_var TINYINT,
          @sendtoeloq_var TINYINT,
          @edipartnerkey_var INT,
          @updatebookedipartner_var TINYINT

  SET @prevedistatus_var = 0
  SET @resend_var = 3
  SET @donotsend_var = 7
  SET @neversend_var = 8
  SET @sendtoeloq_var = 1
  SET @updatebookedipartner_var = 0

  DECLARE edipartner_cur CURSOR FOR
   SELECT edipartnerkey
     FROM bookedipartner
    WHERE bookkey = @i_bookkey AND
          printingkey = @i_printingkey

  OPEN edipartner_cur 	
  FETCH NEXT FROM edipartner_cur INTO @edipartnerkey_var 

  WHILE (@@FETCH_STATUS = 0)  BEGIN
    SELECT @edistatuscode_var=edistatuscode
      FROM bookedistatus
     WHERE bookkey = @i_bookkey AND
           printingkey = @i_printingkey AND
           edipartnerkey = @edipartnerkey_var 

    SELECT @error_var = @@ERROR, @rowcount_var = @@ROWCOUNT
    IF @error_var <> 0 BEGIN
      SET @o_error_code = -1
      SET @o_error_desc = 'Unable to access bookedistatus (' + cast(@error_var AS VARCHAR) + ').'
      GOTO finished
    END 

    IF @edistatuscode_var IS NULL BEGIN
      SET @edistatuscode_var = 0
    END

    IF @rowcount_var <= 0 BEGIN
      -- Insert to bookedistatus
      INSERT INTO bookedistatus (edipartnerkey,bookkey,printingkey,edistatuscode,
                                 lastuserid,lastmaintdate,previousedistatuscode)
           VALUES (@edipartnerkey_var,@i_bookkey,@i_printingkey,@sendtoeloq_var,
                   @i_userid,getdate(),@prevedistatus_var)

      SELECT @error_var = @@ERROR, @rowcount_var = @@ROWCOUNT
      IF @error_var <> 0 OR @rowcount_var <= 0 BEGIN
        SET @o_error_code = -1
        SET @o_error_desc = 'Unable to insert into bookedistatus (' + cast(@error_var AS VARCHAR) + ').'
        GOTO finished
      END 
      SET @updatebookedipartner_var = 1
    END 
    ELSE BEGIN
      IF @edistatuscode_var <> @sendtoeloq_var AND @edistatuscode_var <> @donotsend_var AND 
         @edistatuscode_var <> @neversend_var AND @edistatuscode_var <> 0 BEGIN
        -- Row already exists - Update bookedistatus
        UPDATE bookedistatus
           SET edistatuscode = @resend_var, lastuserid = @i_userid, lastmaintdate = getdate()
         WHERE bookkey = @i_bookkey AND
               printingkey = @i_printingkey AND
               edipartnerkey = @edipartnerkey_var 

        SELECT @error_var = @@ERROR, @rowcount_var = @@ROWCOUNT
        IF @error_var <> 0 OR @rowcount_var <= 0 BEGIN
          SET @o_error_code = -1
          SET @o_error_desc = 'Unable to update bookedistatus (' + cast(@error_var AS VARCHAR) + ').'
         GOTO finished
        END 
        SET @updatebookedipartner_var = 1
     END
    END
  
    IF @updatebookedipartner_var = 1 BEGIN
      -- update bookedipartner
      UPDATE bookedipartner
         SET sendtoeloquenceind = @sendtoeloq_var, lastuserid = @i_userid, lastmaintdate = getdate()
       WHERE bookkey = @i_bookkey AND
             printingkey = @i_printingkey AND
             edipartnerkey = @edipartnerkey_var

      SELECT @error_var = @@ERROR, @rowcount_var = @@ROWCOUNT
      IF @error_var <> 0 OR @rowcount_var <= 0 BEGIN
        SET @o_error_code = -1
        SET @o_error_desc = 'Unable to update bookedipartner (' + cast(@error_var AS VARCHAR) + ').'
        GOTO finished
      END     
    END

    FETCH NEXT FROM edipartner_cur INTO @edipartnerkey_var 
  END  /*LOOP edipartner_cur */

  finished:
  CLOSE edipartner_cur 
  DEALLOCATE edipartner_cur 

  RETURN 
GO

GRANT EXEC ON qtitle_update_bookedistatus TO PUBLIC
GO




















