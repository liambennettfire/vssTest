if exists (select * from dbo.sysobjects where id = object_id(N'dbo.qcontact_resend_titles_to_eloquence') and OBJECTPROPERTY(id, N'IsProcedure') = 1)
drop procedure dbo.qcontact_resend_titles_to_eloquence
GO

SET QUOTED_IDENTIFIER ON 
GO
SET ANSI_NULLS ON 
GO


CREATE PROCEDURE qcontact_resend_titles_to_eloquence
 (@i_globalcontactkey  integer,
  @i_userid 	varchar(30),
  @o_error_code  integer output,
  @o_error_desc  varchar(2000) output)
AS
BEGIN

/******************************************************************************
**  Name: qcontact_resend_titles_to_eloquence
**  Desc: This retrieves all titles records for the given globalcontactkey
**       
**                       
**  Auth: Kusum Basra
**  Date: 17 January 2012
**  
**  Modified: October 31 2013 Case 25989
**
*******************************************************************************/
 DECLARE
	@i_bookkey	int,
  @v_count	int,
  @v_elo_in_cloud int

  SET @o_error_code = 0
  SET @o_error_desc = ''

  -- check to see if client is using elo in cloud
  SET @v_elo_in_cloud = 0
  
  SELECT @v_elo_in_cloud = coalesce(optionvalue,0)
    FROM clientoptions
   WHERE optionid = 111

  DECLARE bookauthor_cur CURSOR FOR
   SELECT bookauthor.bookkey
		 FROM bookauthor  
		WHERE bookauthor.authorkey = @i_globalcontactkey 
		
   UNION
    SELECT bc.bookkey 
		FROM bookcontact bc
		WHERE bc.globalcontactkey = @i_globalcontactkey 
              
  OPEN bookauthor_cur      	
  FETCH NEXT FROM bookauthor_cur INTO @i_bookkey	
		
  WHILE (@@FETCH_STATUS = 0) BEGIN /*LOOP*/
    IF @v_elo_in_cloud = 1 BEGIN  --Only CS outbox information should be updated
       -- ELO in the cloud - update bookdetail
       EXECUTE qtitle_update_bookdetail_csmetadatastatuscode @i_bookkey, @i_userid, @o_error_code OUTPUT, @o_error_desc OUTPUT
       IF @o_error_code < 0 BEGIN
          -- Error
          SET @o_error_code = -1
          SET @o_error_desc = 'Unable to update csmetadatastatuscode on bookdetail(' + cast(@o_error_desc AS VARCHAR) + ').'
          goto finished
       END      
    END
    ELSE BEGIN
      -- KB 10/31/13 CS outbox information and PB outbox needs to be updated
       EXECUTE qtitle_update_bookdetail_csmetadatastatuscode @i_bookkey, @i_userid, @o_error_code OUTPUT, @o_error_desc OUTPUT
       IF @o_error_code < 0 BEGIN
          -- Error
          SET @o_error_code = -1
          SET @o_error_desc = 'Unable to update csmetadatastatuscode on bookdetail(' + cast(@o_error_desc AS VARCHAR) + ').'
          goto finished
       END 
 
      -- using original eloquence process
      SET @v_count = 0
      
      SELECT @v_count = COUNT(*)
        FROM bookedipartner
       WHERE bookkey = @i_bookkey	
      
      -- previously been sent to eloquence
      IF @v_count > 0 BEGIN
		    EXECUTE qtitle_update_bookedistatus @i_bookkey, 1, @i_userid, @o_error_code OUTPUT, @o_error_desc OUTPUT
		    IF @o_error_code < 0 BEGIN
			    -- Error
			    SET @o_error_code = -1
			    SET @o_error_desc = 'Unable to update bookedistatus.'
			    goto finished
			  END
      END
    END
    
    FETCH NEXT FROM bookauthor_cur INTO @i_bookkey	
 END
	
 finished:
  CLOSE bookauthor_cur 
  DEALLOCATE bookauthor_cur
  RETURN

END
go

GRANT EXEC ON qcontact_resend_titles_to_eloquence TO PUBLIC
GO