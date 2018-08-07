if exists (select * from dbo.sysobjects where id = object_id(N'dbo.qcs_verify_content_services_customer') and OBJECTPROPERTY(id, N'IsProcedure') = 1)
drop procedure dbo.qcs_verify_content_services_customer
GO

SET QUOTED_IDENTIFIER ON 
GO
SET ANSI_NULLS ON 
GO

CREATE PROCEDURE qcs_verify_content_services_customer
 (@i_bookkey                         integer,
  @i_listkey                         integer,
  @i_all_ISBNs_for_work              integer,
  @o_is_contentservices_customer     integer output,
  @o_error_code                      integer output,
  @o_error_desc                      varchar(2000) output)
AS

/*****************************************************************************************************************
**  Name: qcs_verify_content_services_customer
**  Desc: This stored procedure determines if a title or list of titles is set up to use Content Services.
** 
**        @o_is_contentservices_customer will be 
**              1 if Content Services is set up for the title or list
**              0 if Content Services is not allowed for the title or list
**             -1 error
**             99 if Content Services is set up for the list, but titles for multiple customers exist in the list
**
**    Auth: Alan Katzen
**    Date: 24 September 2010
*******************************************************************************************************************/

  SET @o_error_code = 0
  SET @o_error_desc = ''
  DECLARE @error_var    INT,
          @rowcount_var INT,
          @v_count INT
          
  -- default to Content Services is not allowed        
  SET @o_is_contentservices_customer = 0
  
  SELECT @v_count = count(*)
    FROM customer
   WHERE COALESCE(cloudaccesskey,'') <> ''
     AND COALESCE(cloudaccesssecret,'') <> ''
 
  SELECT @error_var = @@ERROR, @rowcount_var = @@ROWCOUNT
  IF @error_var <> 0 BEGIN
    SET @o_error_code = -1
    SET @o_error_desc = 'error accessing customer table'  
    SET @o_is_contentservices_customer = -1
    return
  END 
    
  IF @v_count = 0 BEGIN
    -- no customers on the database are setup for Content Services
    SET @o_is_contentservices_customer = 0
    return 
  END
         
  IF (isnull(@i_bookkey,0) = 0 AND isnull(@i_listkey,0) = 0) BEGIN
    SET @o_error_code = -1
    SET @o_error_desc = 'error verifying Content Services - invalid bookkey and listkey' 
    SET @o_is_contentservices_customer = -1
    return 
  END
        
  IF @i_listkey > 0 BEGIN      
    SELECT @v_count = count(*) 
      FROM qse_searchresults sr, book b, customer c
     WHERE sr.key1 = b.bookkey
       AND b.elocustomerkey = c.customerkey
       AND sr.listkey = @i_listkey
       AND COALESCE(c.cloudaccesskey,'') <> ''
       AND COALESCE(c.cloudaccesssecret,'') <> ''        
       
    -- Save the @@ERROR and @@ROWCOUNT values in local 
    -- variables before they are cleared.
    SELECT @error_var = @@ERROR, @rowcount_var = @@ROWCOUNT
    IF @error_var <> 0 BEGIN
      SET @o_error_code = -1
      SET @o_error_desc = 'error accessing customer table for Content Services verification: listkey = ' + cast(isnull(@i_listkey,0) AS VARCHAR)  
      SET @o_is_contentservices_customer = -1
      RETURN
    END       
  END
  ELSE BEGIN
    IF @i_all_ISBNs_for_work = 1 BEGIN
      SELECT @v_count = count(*) 
        FROM book b, customer c
       WHERE b.elocustomerkey = c.customerkey
         AND b.workkey in (select workkey from book where bookkey = @i_bookkey)       
         AND COALESCE(c.cloudaccesskey,'') <> ''
         AND COALESCE(c.cloudaccesssecret,'') <> ''        
    END
    ELSE BEGIN
      SELECT @v_count = count(*) 
        FROM book b, customer c
       WHERE b.elocustomerkey = c.customerkey
         AND b.bookkey = @i_bookkey       
         AND COALESCE(c.cloudaccesskey,'') <> ''
         AND COALESCE(c.cloudaccesssecret,'') <> ''        
    END

    -- Save the @@ERROR and @@ROWCOUNT values in local 
    -- variables before they are cleared.
    SELECT @error_var = @@ERROR, @rowcount_var = @@ROWCOUNT
    IF @error_var <> 0 BEGIN
      SET @o_error_code = -1
      SET @o_error_desc = 'error accessing customer table for Content Services verification: bookkey = ' + cast(isnull(@i_bookkey,0) AS VARCHAR)  
      SET @o_is_contentservices_customer = -1
      RETURN
    END 
  END
  
  SET @o_is_contentservices_customer = 0
  IF @v_count > 0 BEGIN
    IF @i_listkey > 0 BEGIN      
      SELECT @v_count = COUNT(DISTINCT c.customerkey)
      FROM qse_searchresults sr, book b, customer c
      WHERE sr.key1 = b.bookkey
        AND b.elocustomerkey = c.customerkey
        AND sr.listkey = @i_listkey
        AND COALESCE(c.cloudaccesskey,'') <> ''
        AND COALESCE(c.cloudaccesssecret,'') <> ''

      SELECT @error_var = @@ERROR, @rowcount_var = @@ROWCOUNT
      IF @error_var <> 0 BEGIN
        SET @o_error_code = -1
        SET @o_error_desc = 'error accessing customer table for Content Services verification: bookkey = ' + cast(isnull(@i_bookkey,0) AS VARCHAR)  
        SET @o_is_contentservices_customer = -1
        RETURN
      END 
    END
    ELSE BEGIN
      IF @i_all_ISBNs_for_work = 1 BEGIN
        SELECT @v_count = COUNT(DISTINCT c.customerkey)
          FROM book b, customer c
         WHERE b.elocustomerkey = c.customerkey
           AND b.workkey in (select workkey from book where bookkey = @i_bookkey)       
           AND COALESCE(c.cloudaccesskey,'') <> ''
           AND COALESCE(c.cloudaccesssecret,'') <> ''        
      
        -- Save the @@ERROR and @@ROWCOUNT values in local 
        -- variables before they are cleared.
        SELECT @error_var = @@ERROR, @rowcount_var = @@ROWCOUNT
        IF @error_var <> 0 BEGIN
          SET @o_error_code = -1
          SET @o_error_desc = 'error accessing customer table for Content Services verification: bookkey = ' + cast(isnull(@i_bookkey,0) AS VARCHAR)  
          SET @o_is_contentservices_customer = -1
          RETURN
        END 
      END
    END

    IF @v_count > 1
      SET @o_is_contentservices_customer = 99
    ELSE
      SET @o_is_contentservices_customer = 1
  END
  
  return  
GO

GRANT EXEC ON qcs_verify_content_services_customer TO PUBLIC
GO



