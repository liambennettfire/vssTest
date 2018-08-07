if exists (select * from dbo.sysobjects where id = object_id(N'dbo.qcs_verify_content_services_approved') and OBJECTPROPERTY(id, N'IsProcedure') = 1)
  drop procedure dbo.qcs_verify_content_services_approved
GO

SET QUOTED_IDENTIFIER ON 
GO
SET ANSI_NULLS ON 
GO

CREATE PROCEDURE qcs_verify_content_services_approved
 (@i_bookkey              integer,
  @i_listkey              integer,
  @i_all_ISBNs_for_work   integer,
  @o_error_code           integer output,
  @o_error_desc           varchar(2000) output)
AS

/*************************************************************************************************************
**  Name: qcs_verify_content_services_approved
**  Desc: This stored procedure determines if a title or list of titles is approved for distribution.
**        o_error_code values:  0 - All titles are approved for distribution                         
**                             -1 - Error occurred
**								otherwise, the number of titles NOT approved for distribution is returned.
** 
**  Auth: Kate Wiewiora
**  Date: 4 August 2011
**  Last Updated: 12 February 2016 by Dustin Miller
*************************************************************************************************************/

DECLARE
  @v_count INT,
  @v_error  INT,
  @v_rowcount INT,
  @v_elo2ind INT

BEGIN
  SET @o_error_code = 0
  SET @o_error_desc = ''
                  
  IF (IsNull(@i_bookkey,0) = 0 AND IsNull(@i_listkey,0) = 0) BEGIN
    SET @o_error_code = -1
    SET @o_error_desc = 'Error verifying Content Services approval for distribution - invalid bookkey/listkey.' 
    RETURN 
  END

  SELECT @v_elo2ind = COALESCE(optionvalue,0) FROM clientoptions WHERE optionid=111
  
  IF @i_listkey > 0 BEGIN
    SELECT @v_count = COUNT(*) 
    FROM qse_searchresults r, bookdetail b
    WHERE r.key1 = b.bookkey AND
      r.listkey = @i_listkey AND
      [dbo].qcs_get_csapproved(b.bookkey) <> 1

    SELECT @v_error = @@ERROR, @v_rowcount = @@ROWCOUNT
    IF @v_error <> 0 BEGIN
      SET @o_error_code = -1
      SET @o_error_desc = 'Error accessing bookdetail table for Content Services approval verification: listkey=' + cast(isnull(@i_listkey,0) AS VARCHAR)
      RETURN
    END       
  END
  ELSE BEGIN
    IF @i_all_ISBNs_for_work = 1 BEGIN
      SELECT @v_count = COUNT(*) 
      FROM bookdetail bd, book b
      WHERE b.bookkey = bd.bookkey
        AND b.workkey in (select workkey from book where bookkey = @i_bookkey)   
        AND [dbo].qcs_get_csapproved(bd.bookkey) <> 1
    END
    ELSE BEGIN
      SELECT @v_count = COUNT(*) 
      FROM bookdetail bd
      WHERE bd.bookkey = @i_bookkey   
        AND [dbo].qcs_get_csapproved(bd.bookkey) <> 1
    END
    
    SELECT @v_error = @@ERROR, @v_rowcount = @@ROWCOUNT
    IF @v_error <> 0 BEGIN
      SET @o_error_code = -1
      SET @o_error_desc = 'Error accessing bookdetail table for Content Services approval verification: bookkey=' + cast(isnull(@i_bookkey,0) AS VARCHAR)
      RETURN 
    END 
  END
  
  IF @v_count > 0
    SET @o_error_code = @v_count
    
END 
GO

GRANT EXEC ON qcs_verify_content_services_approved TO PUBLIC
GO
