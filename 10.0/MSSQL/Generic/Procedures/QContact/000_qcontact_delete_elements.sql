if exists (select * from dbo.sysobjects where id = object_id(N'dbo.qcontact_delete_elements') and OBJECTPROPERTY(id, N'IsProcedure') = 1)
  drop procedure dbo.qcontact_delete_elements
GO

SET QUOTED_IDENTIFIER ON 
GO
SET ANSI_NULLS ON 
GO


CREATE PROCEDURE qcontact_delete_elements
  (@i_bookkey  integer,
  @i_printingkey integer,
  @i_bookcontactkey  integer,
  @i_projectkey integer,
  @i_projectcontactkey integer,
  @i_globalcontactkey integer,  
  @i_userid varchar(30),
  @i_deleterecords smallint,
  @o_error_code integer output,
  @o_error_desc varchar(2000) output)
AS

/******************************************************************************
**  Name: qcontact_delete_elements
**  Desc: This stored procedure deletes all taqprojectelement records OR 
**        clears the globalcontactkey based on user preference.
**
**    Auth: Lisa
**    Date: 10/01/08
**
*******************************************************************************/

DECLARE
  @v_taskviewkey  INT,
  @v_userkey INT,
  @v_globalcontactkey INT,
  @v_error  INT,
  @v_rowcount INT,
  @v_elementkey INT       
  
BEGIN

  SET @o_error_code = 0
  SET @o_error_desc = ''  
  
  /** Get userkey for the given userid passed **/
  SELECT @v_userkey = userkey
  FROM qsiusers
  WHERE Upper(userid) = Upper(@i_userid)
  
  SELECT @v_error = @@ERROR, @v_rowcount = @@ROWCOUNT
  IF @v_error <> 0 OR @v_rowcount = 0 BEGIN
    SET @o_error_desc = 'Error getting userkey for userid ' + CAST(@i_userid AS VARCHAR) + '.'
    GOTO RETURN_ERROR
  END  
  
  /***********************************************************************************
  ************************************************************************************
  **
  **    Processing Book/Title contact
  **
  ************************************************************************************
  ************************************************************************************/
  IF ( isNull(@i_bookkey,0) > 0 and isNull(@i_printingkey,0) > 0 )
  BEGIN
    IF (@i_globalcontactkey > 0) BEGIN
		SET @v_globalcontactkey = @i_globalcontactkey
    END
    ELSE BEGIN
		-- Get GlobalContactKey
		SELECT @v_globalcontactkey = ( SELECT globalcontactkey 
										 FROM bookcontact 
										WHERE bookkey = @i_bookkey 
										  AND printingkey = @i_printingkey 
										  AND bookcontactkey = @i_bookcontactkey )  
	                           
		SELECT @v_error = @@ERROR, @v_rowcount = @@ROWCOUNT
		IF @v_error <> 0 OR @v_rowcount = 0 BEGIN
			SET @o_error_desc = 'Error getting globalcontactkey for bookcontactkey ' + CAST(@i_bookcontactkey AS VARCHAR) + '.'
			GOTO RETURN_ERROR
		END
    END  

    -- If the user asked to delete the records, do that first ONLY if there is 1 contact on the record                                   
    IF ( isNull(@i_deleterecords,0) = 1 and @v_globalcontactkey > 0 )
    BEGIN
       /** Delete ELEMENTS for Bookkey on globalcontactkey column **/
       -- check globalcontactkey                                                        
	  DECLARE deletetitleelement_cur1 CURSOR FOR
		  SELECT taqelementkey FROM taqprojectelement WHERE bookkey = @i_bookkey 
                                                        AND printingkey = @i_printingkey
                                                        AND globalcontactkey = @v_globalcontactkey
                                                        AND isNull(globalcontactkey2,0) <= 0 
	  
		OPEN deletetitleelement_cur1
		FETCH NEXT FROM deletetitleelement_cur1 INTO @v_elementkey
		WHILE (@@FETCH_STATUS <> -1) BEGIN

		EXECUTE qelement_delete_element @v_elementkey, @v_userkey, @o_error_code OUTPUT, @o_error_desc OUTPUT
	    
		IF @o_error_code < 0 BEGIN
		  -- Error
		  PRINT @o_error_desc
		  SET @o_error_code = -1
		  CLOSE deletetitleelement_cur1
		  DEALLOCATE deletetitleelement_cur1
		  GOTO RETURN_ERROR
		END
		FETCH NEXT FROM deletetitleelement_cur1 INTO @v_elementkey
	  END
	  
	  CLOSE deletetitleelement_cur1
	  DEALLOCATE deletetitleelement_cur1                                                            
            
       /** Delete ELEMENTS for Bookkey on globalcontactkey2 column **/                                                        
	  DECLARE deletetitleelement_cur2 CURSOR FOR
		SELECT taqelementkey FROM taqprojectelement WHERE bookkey = @i_bookkey 
                                                        AND printingkey = @i_printingkey
                                                        AND globalcontactkey2 = @v_globalcontactkey
                                                        AND isNull(globalcontactkey,0) <= 0
	  
	    OPEN deletetitleelement_cur2
	    FETCH NEXT FROM deletetitleelement_cur2 INTO @v_elementkey
	    WHILE (@@FETCH_STATUS <> -1) BEGIN

		  EXECUTE qelement_delete_element @v_elementkey, @v_userkey, @o_error_code OUTPUT, @o_error_desc OUTPUT
	    
		  IF @o_error_code < 0 BEGIN
			-- Error
			 PRINT @o_error_desc
			 SET @o_error_code = -1
			 CLOSE deletetitleelement_cur2
			 DEALLOCATE deletetitleelement_cur2
			 GOTO RETURN_ERROR
		  END
		FETCH NEXT FROM deletetitleelement_cur2 INTO @v_elementkey
	  END
	  
	  CLOSE deletetitleelement_cur2
	  DEALLOCATE deletetitleelement_cur2                                                                    
    END -- IF ( @i_deleterecords = 1 )
                                                                                                                   
    -- If user chose the delete option, records deleted above had only 1 contact associated.
    -- The only records left would have multiple contacts associated or we just fell through 
    -- because the user chose not to delete.  Update all the associated globalcontact and 
    -- globalcontact2 columns.
    
    /** Clearing Element globalcontact columns **/
    UPDATE taqprojectelement SET globalcontactkey = NULL
     WHERE taqelementkey in ( SELECT taqelementkey 
                                FROM taqprojectelement WHERE bookkey = @i_bookkey 
                                                         AND printingkey = @i_printingkey
                                                         AND globalcontactkey = @v_globalcontactkey )

    UPDATE taqprojectelement SET globalcontactkey2 = NULL
     WHERE taqelementkey in ( SELECT taqelementkey 
                                FROM taqprojectelement WHERE bookkey = @i_bookkey 
                                                         AND printingkey = @i_printingkey
                                                         AND globalcontactkey2 = @v_globalcontactkey )

   END

  /***********************************************************************************
  ************************************************************************************
  **
  **    Processing Project contact
  **
  ************************************************************************************
  ************************************************************************************/

  ELSE IF ( isNull(@i_projectkey,0) > 0 )
  BEGIN
  
    IF (@i_globalcontactkey > 0) BEGIN
		SET @v_globalcontactkey = @i_globalcontactkey
    END
    ELSE BEGIN  
		  -- Get GlobalContactKey
		SELECT @v_globalcontactkey = ( SELECT globalcontactkey 
										 FROM taqprojectcontact 
										WHERE taqprojectkey = @i_projectkey
										  AND taqprojectcontactkey = @i_projectcontactkey ) 

		SELECT @v_error = @@ERROR, @v_rowcount = @@ROWCOUNT
		IF @v_error <> 0 OR @v_rowcount = 0 BEGIN
			SET @o_error_desc = 'Error getting globalcontactkey for projectkey ' + CAST(@i_projectkey AS VARCHAR) + '.'
			GOTO RETURN_ERROR
		END  
    END

    -- If the user asked to delete the records, do that first ONLY if there is 1 contact on the record                                   
    IF ( isNull(@i_deleterecords,0) = 1 and @v_globalcontactkey > 0 )
    BEGIN
       /** Delete ELEMENTS for projectkey on globalcontactkey column **/
       -- check globalcontactkey                                                        
	  DECLARE deleteprojectelement_cur1 CURSOR FOR
		SELECT taqelementkey FROM taqprojectelement WHERE taqprojectkey = @i_projectkey 
                                                        AND globalcontactkey = @v_globalcontactkey
                                                        AND isNull(globalcontactkey2,0) <= 0
	  
		OPEN deleteprojectelement_cur1
		FETCH NEXT FROM deleteprojectelement_cur1 INTO @v_elementkey
		WHILE (@@FETCH_STATUS <> -1) BEGIN

		EXECUTE qelement_delete_element @v_elementkey, @v_userkey, @o_error_code OUTPUT, @o_error_desc OUTPUT
	    
		IF @o_error_code < 0 BEGIN
		  -- Error
		  PRINT @o_error_desc
		  SET @o_error_code = -1
		  CLOSE deleteprojectelement_cur1
		  DEALLOCATE deleteprojectelement_cur1
          GOTO RETURN_ERROR
		END
		FETCH NEXT FROM deleteprojectelement_cur1 INTO @v_elementkey
	  END
	  
	  CLOSE deleteprojectelement_cur1
	  DEALLOCATE deleteprojectelement_cur1                                                           
              
         
       /** Delete ELEMENTS for Bookkey on globalcontactkey2 column **/                                                        
	  DECLARE deleteprojectelement_cur2 CURSOR FOR
		SELECT taqelementkey FROM taqprojectelement WHERE taqprojectkey = @i_projectkey
                                                        AND globalcontactkey2 = @v_globalcontactkey
                                                        AND isNull(globalcontactkey,0) <= 0 
	  
		OPEN deleteprojectelement_cur2
		FETCH NEXT FROM deleteprojectelement_cur2 INTO @v_elementkey
		WHILE (@@FETCH_STATUS <> -1) BEGIN

		EXECUTE qelement_delete_element @v_elementkey, @v_userkey, @o_error_code OUTPUT, @o_error_desc OUTPUT
	    
		IF @o_error_code < 0 BEGIN
		  -- Error
		  PRINT @o_error_desc
		  SET @o_error_code = -1
		  CLOSE deleteprojectelement_cur2
		  DEALLOCATE deleteprojectelement_cur2
          GOTO RETURN_ERROR
		END
		FETCH NEXT FROM deleteprojectelement_cur2 INTO @v_elementkey
	  END
	  
	  CLOSE deleteprojectelement_cur2
	  DEALLOCATE deleteprojectelement_cur2                                                                                                                  
    END
                                                                                                                   
    -- If user chose the delete option, records deleted above had only 1 contact associated.
    -- The only records left would have multiple contacts associated or we just fell through 
    -- because the user chose not to delete.  Update all the associated globalcontact and 
    -- globalcontact2 columns.

    /** Clearing Element globalcontact columns **/
    UPDATE taqprojectelement SET globalcontactkey = NULL
     WHERE taqelementkey in ( SELECT taqelementkey 
                                FROM taqprojectelement WHERE taqprojectkey = @i_projectkey
                                                         AND globalcontactkey = @v_globalcontactkey )

    UPDATE taqprojectelement SET globalcontactkey2 = NULL
     WHERE taqelementkey in ( SELECT taqelementkey 
                                FROM taqprojectelement WHERE taqprojectkey = @i_projectkey
                                                         AND globalcontactkey2 = @v_globalcontactkey )
  END
  
  /***********************************************************************************
  ************************************************************************************
  **
  **    fall through to error...
  **
  ************************************************************************************
  ************************************************************************************/

  ELSE -- error, no bookkey or projectkey
  BEGIN
    SET @o_error_desc = 'Error no valid key was passed to qcontact_delete_elements() '
    GOTO RETURN_ERROR
  END
  
  RETURN
  
RETURN_ERROR:  
  SET @o_error_code = -1
  RETURN

END
GO

GRANT EXEC ON qcontact_delete_elements TO PUBLIC
GO


