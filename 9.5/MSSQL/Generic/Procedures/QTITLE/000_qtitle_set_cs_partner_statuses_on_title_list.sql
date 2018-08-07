IF EXISTS (SELECT * FROM sysobjects WHERE type = 'P' AND name = 'qtitle_set_cspartnerstatuses_on_title_list')
  BEGIN
    PRINT 'Dropping Procedure qtitle_set_cspartnerstatuses_on_title_list'
    DROP  Procedure  qtitle_set_cspartnerstatuses_on_title_list
  END

GO

PRINT 'Creating Procedure qtitle_set_cspartnerstatuses_on_title_list'
GO

CREATE PROCEDURE qtitle_set_cspartnerstatuses_on_title_list
 (@i_listkey            integer,
  @i_userid             varchar(30),
  @o_error_code         integer output,
  @o_error_desc         varchar(2000) output)
AS

/******************************************************************************
**  File: 
**  Name: qtitle_set_cspartnerstatuses_on_title_list
**  Desc: 
**              
**    Parameters:
**    Input              
**    ----------         
**    listkey - listkey of title search - Required
**    userid - Userid of user causing write to bookdetail - Required   
**    Output
**    -----------
**    error_code - error code
**    error_desc - error message - empty if No Error
**
**    Auth: CO'C
**    Date: 11/5/2015
*******************************************************************************/

 -- verify that all required values are filled in
  IF @i_userid IS NULL OR ltrim(rtrim(@i_userid)) = '' BEGIN
     SET @o_error_code = -1
     SET @o_error_desc = 'Unable to update bookdetail: userid is empty.'
     RETURN
  END   

  IF @i_listkey IS NULL OR @i_listkey = 0 BEGIN
    SET @o_error_code = -1
    SET @o_error_desc = 'Unable to update bookdetail: listkey is empty.'
    RETURN
  END 

  SET @o_error_code = 0
  SET @o_error_desc = ''

  DECLARE @v_bookkey  INT

  DECLARE qse_searchresults_cur CURSOR FOR
    SELECT key1
    FROM qse_searchresults
    WHERE listkey = @i_listkey
        
  OPEN qse_searchresults_cur

  FETCH NEXT FROM qse_searchresults_cur INTO @v_bookkey
  
  WHILE (@@FETCH_STATUS = 0) 
  BEGIN
    EXEC qtitle_set_cspartnerstatuses_on_title @v_bookkey,@i_userid,@o_error_code OUTPUT,@o_error_desc OUTPUT

    IF @o_error_code = -1 BEGIN
      RETURN
    END

    FETCH NEXT FROM qse_searchresults_cur INTO @v_bookkey
  END	
	
	CLOSE qse_searchresults_cur 
  DEALLOCATE qse_searchresults_cur
  RETURN 
GO 

GRANT EXEC ON qtitle_set_cspartnerstatuses_on_title_list TO PUBLIC
GO