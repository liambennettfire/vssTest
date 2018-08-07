if exists (select * from dbo.sysobjects where id = object_id(N'dbo.qproject_create_dwo') and OBJECTPROPERTY(id, N'IsProcedure') = 1)
  drop procedure dbo.qproject_create_dwo
GO

SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

CREATE PROCEDURE qproject_create_dwo (  
  @i_request_projectkey integer,
  @i_new_projectkey integer,
  @i_userid     varchar(30),
  @o_error_code integer output,
  @o_error_desc varchar(2000) output)
AS

/******************************************************************************************
**  Name: qproject_create_dwo
**  Desc: This stored procedure completes creation of DWO project.
**        It copies all contacts and related titles from the request project that have 
**        not already been copied from the template, and merges all contact roles.
**        Called from a request project after copying from template.
**
**  Auth: Kate
**  Date: February 23 2009
*******************************************************************************************/

BEGIN

  DECLARE
    @v_bookkey  int,
    @v_count  int,
    @v_error	int,
    @v_globalcontactkey int,
    @v_newkey  int,
    @v_printingkey  int,
    @v_relationship_dwo int,
    @v_relationship_request int,
    @v_rolecode int,
    @v_sortorder  int,
    @v_statuscode int,
    @v_taqprojectcontactkey int
    
  SET @o_error_code = 0
  SET @o_error_desc = ''
  
  -- Copy all participants from the request project - merge contacts and roles from originating request and template
  DECLARE participants_cur CURSOR FOR
    SELECT globalcontactkey, sortorder
    FROM taqprojectcontact
    WHERE taqprojectkey = @i_request_projectkey 
  
  OPEN participants_cur

  FETCH NEXT FROM participants_cur INTO @v_globalcontactkey, @v_sortorder

  WHILE (@@FETCH_STATUS = 0)  /*LOOP*/
  BEGIN
  
    SELECT @v_count = COUNT(*)
    FROM taqprojectcontact
    WHERE taqprojectkey = @i_new_projectkey AND
      globalcontactkey = @v_globalcontactkey AND
      sortorder = @v_sortorder
    
    IF @v_count > 0 --this contact already exists (copied from template)
      BEGIN
        -- Get the taqprojectcontactkey corresponding to this globalcontactkey
        SELECT @v_taqprojectcontactkey = taqprojectcontactkey
        FROM taqprojectcontact
        WHERE taqprojectkey = @i_new_projectkey AND
          globalcontactkey = @v_globalcontactkey AND
          sortorder = @v_sortorder
      END
    ELSE  --copy this contact from the originating request project
      BEGIN    
        EXEC get_next_key @i_userid, @v_taqprojectcontactkey OUTPUT
        
        INSERT INTO taqprojectcontact
          (taqprojectcontactkey, taqprojectkey, globalcontactkey, participantnote, 
          keyind, sortorder, lastuserid, lastmaintdate)
        SELECT @v_taqprojectcontactkey, @i_new_projectkey, globalcontactkey, participantnote, 
          keyind, sortorder, @i_userid, getdate()
        FROM taqprojectcontact
        WHERE taqprojectkey = @i_request_projectkey AND
          globalcontactkey = @v_globalcontactkey AND
          sortorder = @v_sortorder
            
        SELECT @v_error = @@ERROR
        IF @v_error <> 0 BEGIN
          SET @o_error_code = -1
          SET @o_error_desc = 'Copy into taqprojectcontact from request project failed (' + cast(@v_error AS VARCHAR) + '): globalcontactkey=' + cast(@v_globalcontactkey AS VARCHAR)   
          RETURN
        END
      END
    
    -- Merge roles - from request project and template
    DECLARE roles_cur CURSOR FOR
      SELECT r.rolecode
      FROM taqprojectcontactrole r, taqprojectcontact c
      WHERE r.taqprojectcontactkey = c.taqprojectcontactkey AND 
        r.taqprojectkey = @i_request_projectkey AND
        globalcontactkey = @v_globalcontactkey AND
        sortorder = @v_sortorder
          
    OPEN roles_cur

    FETCH NEXT FROM roles_cur INTO @v_rolecode

    WHILE (@@FETCH_STATUS = 0)  /*LOOP*/
    BEGIN
      SELECT @v_count = COUNT(*)
      FROM taqprojectcontactrole r, taqprojectcontact c
      WHERE r.taqprojectcontactkey = c.taqprojectcontactkey AND 
        r.taqprojectkey = @i_new_projectkey AND
        globalcontactkey = @v_globalcontactkey AND
        rolecode = @v_rolecode
      
      IF @v_count = 0
      BEGIN
        EXEC get_next_key @i_userid, @v_newkey OUTPUT
        
        INSERT INTO taqprojectcontactrole
          (taqprojectcontactrolekey, taqprojectcontactkey, taqprojectkey, rolecode, activeind,
          authortypecode, primaryind, workrate, ratetypecode, lastuserid, lastmaintdate)
        SELECT
          @v_newkey, @v_taqprojectcontactkey, @i_new_projectkey, r.rolecode, r.activeind,
          r.authortypecode, r.primaryind, r.workrate, r.ratetypecode, @i_userid, getdate()
        FROM taqprojectcontactrole r, taqprojectcontact c
        WHERE r.taqprojectcontactkey = c.taqprojectcontactkey AND
          r.taqprojectkey = @i_request_projectkey AND
          c.globalcontactkey = @v_globalcontactkey AND
          r.rolecode = @v_rolecode        
            
        SELECT @v_error = @@ERROR
        IF @v_error <> 0 BEGIN
          SET @o_error_code = -1
          SET @o_error_desc = 'Copy into taqprojectcontactrole from request project failed (' + cast(@v_error AS VARCHAR) + '): globalcontactkey=' + cast(@v_globalcontactkey AS VARCHAR) + ', rolecode=' + cast(@v_rolecode AS VARCHAR)
          RETURN
        END
      END
      
      FETCH NEXT FROM roles_cur INTO @v_rolecode
    END
    
    CLOSE roles_cur
    DEALLOCATE roles_cur
      
    FETCH NEXT FROM participants_cur INTO @v_globalcontactkey, @v_sortorder
  
  END	/* @@FETCH_STATUS=0 */
  
  CLOSE participants_cur 
  DEALLOCATE participants_cur
  
  
  -- Copy related titles from the request project
  DECLARE relatedtitles_cur CURSOR FOR
    SELECT bookkey, printingkey
    FROM taqprojecttitle
    WHERE taqprojectkey = @i_request_projectkey 
  
  OPEN relatedtitles_cur

  FETCH NEXT FROM relatedtitles_cur INTO @v_bookkey, @v_printingkey

  WHILE (@@FETCH_STATUS = 0)  /*LOOP*/
  BEGIN
  
    SELECT @v_count = COUNT(*)
    FROM taqprojecttitle
    WHERE taqprojectkey = @i_new_projectkey AND
      bookkey = @v_bookkey AND
      printingkey = @v_printingkey
        
    IF @v_count = 0 BEGIN
      EXEC get_next_key @i_userid, @v_newkey OUTPUT
      
      INSERT INTO taqprojecttitle
        (taqprojectformatkey, taqprojectkey, seasoncode, seasonfirmind, mediatypecode, mediatypesubcode,
        discountcode, price, initialrun, projectdollars, marketingplancode, primaryformatind,
        isbn, isbn10, ean, ean13, gtin, gtin14, bookkey, taqprojectformatdesc, isbnprefixcode,
        lastuserid, lastmaintdate, lccn, dsmarc, itemnumber, upc, eanprefixcode, printingkey,
        projectrolecode, titlerolecode, keyind, sortorder, indicator1, indicator2,
        quantity1, quantity2, relateditem2name, relateditem2status, relateditem2participants, decimal1, decimal2)
      SELECT @v_newkey, @i_new_projectkey, seasoncode, seasonfirmind, mediatypecode, mediatypesubcode,
        discountcode, price, initialrun, projectdollars, marketingplancode, primaryformatind,
        isbn, isbn10, ean, ean13, gtin, gtin14, bookkey, taqprojectformatdesc, isbnprefixcode,
        @i_userid, getdate(), lccn, dsmarc, itemnumber, upc, eanprefixcode, printingkey,
        projectrolecode, titlerolecode, keyind, sortorder, indicator1, indicator2,
        quantity1, quantity2, relateditem2name, relateditem2status, relateditem2participants, decimal1, decimal2
      FROM taqprojecttitle
      WHERE taqprojectkey = @i_request_projectkey AND
        bookkey = @v_bookkey AND
        printingkey = @v_printingkey

      SELECT @v_error = @@ERROR
      IF @v_error <> 0 BEGIN
        SET @o_error_code = -1
        SET @o_error_desc = 'Copy into taqprojecttitle from request project failed (' + cast(@v_error AS VARCHAR) + '): bookkey=' + cast(@v_bookkey AS VARCHAR) + ', printingkey=' + cast(@v_printingkey AS VARCHAR)
        RETURN
      END
    END
    
    FETCH NEXT FROM relatedtitles_cur INTO @v_bookkey, @v_printingkey
  END
  
  CLOSE relatedtitles_cur
  DEALLOCATE relatedtitles_cur
  

  -- Add project relationship between the newly created DWO project and the original request project
  SELECT @v_relationship_dwo = datacode
  FROM gentables 
  WHERE tableid = 582 AND qsicode = 13
  
  SELECT @v_relationship_request = datacode
  FROM gentables 
  WHERE tableid = 582 AND qsicode = 12
  
  IF @v_relationship_dwo > 0 AND @v_relationship_request > 0
  BEGIN
    EXEC dbo.get_next_key 'QSIDBA', @v_newkey OUT
    
    INSERT INTO taqprojectrelationship
      (taqprojectrelationshipkey, taqprojectkey1, taqprojectkey2, relationshipcode1, relationshipcode2,
      keyind, lastuserid, lastmaintdate)
    VALUES
      (@v_newkey, @i_request_projectkey, @i_new_projectkey, @v_relationship_request, @v_relationship_dwo,
      1, @i_userid, getdate())
      
    SELECT @v_error = @@ERROR
    IF @v_error <> 0 BEGIN
      SET @o_error_code = -1
      SET @o_error_desc = 'Insert into taqprojectrelationship failed (' + cast(@v_error AS VARCHAR) + '): taqprojectkey1=' + cast(@i_request_projectkey AS VARCHAR) + ', taqprojectkey2=' + cast(@i_new_projectkey AS VARCHAR)
      RETURN
    END
  END
  
  -- Change the Project Status on the original request project to 'DWO Created'
  SELECT @v_count = COUNT(*)
  FROM gentables
  WHERE tableid = 522 and qsicode = 5
  
  IF @v_count > 0
  BEGIN
    SELECT @v_statuscode = datacode
    FROM gentables
    WHERE tableid = 522 and qsicode = 5
    
    IF @v_statuscode > 0
    BEGIN
      UPDATE taqproject
      SET taqprojectstatuscode = @v_statuscode
      WHERE taqprojectkey = @i_request_projectkey
      
      SELECT @v_error = @@ERROR
      IF @v_error <> 0 BEGIN
        SET @o_error_code = -1
        SET @o_error_desc = 'Could not update Project Status on request project.'
        RETURN
      END
    END
  END
  
END
GO

GRANT EXEC ON qproject_create_dwo TO PUBLIC
GO
