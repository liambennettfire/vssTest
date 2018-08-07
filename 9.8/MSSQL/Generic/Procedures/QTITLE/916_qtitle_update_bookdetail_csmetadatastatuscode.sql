IF EXISTS (SELECT * FROM sysobjects WHERE type = 'P' AND name = 'qtitle_update_bookdetail_csmetadatastatuscode')
  BEGIN
    PRINT 'Dropping Procedure qtitle_update_bookdetail_csmetadatastatuscode'
    DROP  Procedure  qtitle_update_bookdetail_csmetadatastatuscode
  END

GO

PRINT 'Creating Procedure qtitle_update_bookdetail_csmetadatastatuscode'
GO

CREATE PROCEDURE qtitle_update_bookdetail_csmetadatastatuscode
 (@i_bookkey            integer,
  @i_userid             varchar(30),
  @o_error_code         integer output,
  @o_error_desc         varchar(2000) output)
AS

/******************************************************************************
**  File: 
**  Name: qtitle_update_bookdetail_csmetadatastatuscode
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
**    userid - Userid of user causing write to bookdetail - Required
**    
**    Output
**    -----------
**    error_code - error code
**    error_desc - error message - empty if No Error
**
**    Auth: Kusum Basra
**    Date: 10/15/201
*******************************************************************************
**    Change History
*******************************************************************************
**    Date:     Author:         Description:
**    --------  --------        -------------------------------------------
**    10/25/12 Kusum            Update status for metadata asset and metadata
**                              asset partners
*******************************************************************************/

  -- verify that all required values are filled in
  IF @i_userid IS NULL OR ltrim(rtrim(@i_userid)) = '' BEGIN
    SET @o_error_code = -1
    SET @o_error_desc = 'Unable to update bookdetail: userid is empty.'
    RETURN
  END 

  IF @i_bookkey IS NULL OR @i_bookkey = 0 BEGIN
    SET @o_error_code = -1
    SET @o_error_desc = 'Unable to update bookdetail: bookkey is empty.'
    RETURN
  END 

  SET @o_error_code = 0
  SET @o_error_desc = ''

 
  DECLARE @error_var    INT,
          @rowcount_var INT,
          @v_csmetadatastatuscode INT,
          @v_elempartresendcount	INT,
          @v_assetkey INT,
          @v_count  INT

  SELECT @v_count = COUNT(*)
    FROM bookdetail
   WHERE bookkey = @i_bookkey

  IF @v_count = 0 BEGIN
     RETURN
  END

  
   
  SELECT @v_csmetadatastatuscode = csmetadatastatuscode
    FROM bookdetail
   WHERE bookkey = @i_bookkey

  IF @v_csmetadatastatuscode IS NULL
     SET @v_csmetadatastatuscode = 0
     
  SELECT @v_elempartresendcount = COUNT(*)
	FROM taqprojectelementpartner
	WHERE bookkey = @i_bookkey
		AND resendind = 1

  --- csmetadatastatuscode = 3 - Sent to CS\EOD for all selected partners
  ---                      = 4 - Sent to all selected partners
  ---                      = 5 - Not up to date at all selected partners

  IF @v_elempartresendcount > 0 BEGIN
    UPDATE bookdetail
       SET csmetadatastatuscode = 5,
           csmetadatalastupdate = getdate(), 
           lastuserid = @i_userid, lastmaintdate = getdate()
     WHERE bookkey = @i_bookkey 
  END
  ELSE BEGIN
    UPDATE bookdetail
       SET csmetadatalastupdate = getdate(), 
           lastuserid = @i_userid, lastmaintdate = getdate()
     WHERE bookkey = @i_bookkey 
  END

  SELECT @error_var = @@ERROR, @rowcount_var = @@ROWCOUNT
  IF @error_var <> 0 OR @rowcount_var <= 0 BEGIN
     SET @o_error_code = -1
     SET @o_error_desc = 'Unable to update bookdetail (' + cast(@error_var AS VARCHAR) + ').'
     RETURN
  END

  --Metadata element
  IF @v_elempartresendcount > 0 BEGIN
    SELECT @v_count = 0
   
    SELECT @v_count = count(*)
      FROM taqprojectelement 
     WHERE bookkey = @i_bookkey 
       AND taqelementtypecode = (SELECT datacode FROM gentables WHERE tableid = 287 AND qsicode = 3)

    IF @v_count > 0 BEGIN
      SELECT @v_assetkey = taqelementkey
        FROM taqprojectelement 
       WHERE bookkey = @i_bookkey AND taqelementtypecode = (SELECT datacode FROM gentables WHERE tableid = 287 AND qsicode = 3)

      UPDATE taqprojectelement
         SET cspartnerstatuscode = 5,
             lastuserid = @i_userid, lastmaintdate = getdate()
       WHERE taqelementkey = @v_assetkey
         AND bookkey = @i_bookkey
         AND taqelementtypecode = (SELECT datacode FROM gentables WHERE tableid = 287 AND qsicode = 3)

      SELECT @error_var = @@ERROR, @rowcount_var = @@ROWCOUNT
      IF @error_var <> 0 OR @rowcount_var <= 0 BEGIN
         SET @o_error_code = -1
         SET @o_error_desc = 'Unable to update taqprojectelement (' + cast(@error_var AS VARCHAR) + ').'
         RETURN
      END
    END
   END

  --Update all partners for the metadata element
  IF @v_assetkey > 0 BEGIN

    SELECT @v_count = 0
     
    SELECT @v_count = count(*)
      FROM taqprojectelementpartner 
     WHERE bookkey = @i_bookkey 
       AND assetkey = @v_assetkey

    IF @v_count > 0 BEGIN
      UPDATE taqprojectelementpartner
         SET cspartnerstatuscode = 5,
             lastuserid = @i_userid, lastmaintdate = getdate()
       WHERE bookkey = @i_bookkey 
         AND assetkey = @v_assetkey

      SELECT @error_var = @@ERROR, @rowcount_var = @@ROWCOUNT
      IF @error_var <> 0 OR @rowcount_var <= 0 BEGIN
         SET @o_error_code = -1
         SET @o_error_desc = 'Unable to update taqprojectelementpartner (' + cast(@error_var AS VARCHAR) + ').'
         RETURN
      END
    END
	END

  RETURN 
GO

GRANT EXEC ON qtitle_update_bookdetail_csmetadatastatuscode TO PUBLIC
GO




















