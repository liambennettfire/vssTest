if exists (select * from dbo.sysobjects where id = object_id(N'dbo.qcs_get_outbox_titles') and OBJECTPROPERTY(id, N'IsProcedure') = 1)
drop procedure dbo.qcs_get_outbox_titles
GO

SET QUOTED_IDENTIFIER ON 
GO
SET ANSI_NULLS ON 
GO


CREATE PROCEDURE qcs_get_outbox_titles
 (@o_error_code     integer output,
  @o_error_desc     varchar(2000) output)
AS


/******************************************************************************
**  File: 
**  Name: qcs_get_outbox_titles
**  Desc: This stored procedure returns all approved Content Services titles
**        that were sent from the outbox to eloquence. 
**
**
**    Auth: Alan Katzen
**    Date: 13 December 2010
*******************************************************************************
**    Change History
*******************************************************************************
**    Date:       Author:         Description:
**    --------    --------        -------------------------------------------
**    
*******************************************************************************/

  SET @o_error_code = 0
  SET @o_error_desc = ''
  DECLARE @error_var    INT,
          @rowcount_var INT,
          @v_outboxtitlesupdated  datetime

  SELECT @v_outboxtitlesupdated = outboxtitlesupdated
    FROM csupdatetracker
   
  SELECT @error_var = @@ERROR, @rowcount_var = @@ROWCOUNT
  IF @error_var <> 0 or @rowcount_var = 0 BEGIN
    SET @o_error_code = -1
    SET @o_error_desc = 'Unable to get outboxtitlesupdated from csupdatetracker'
    return
  END  
   
  IF @v_outboxtitlesupdated is not null BEGIN
    SELECT distinct bd.bookkey, i.cloudproductid, b.elocustomerkey customerkey
      FROM bookedistatus bes, bookdetail bd, isbn i, book b
     WHERE bd.bookkey = i.bookkey
       AND bd.bookkey = b.bookkey
       AND bd.bookkey = bes.bookkey
       AND bes.printingkey = 1
       AND bes.edistatuscode = 4   -- Send Complete
       AND bes.lastmaintdate > @v_outboxtitlesupdated  -- titles that were sent since the last time the service ran
       AND ([dbo].qcs_get_csapproved(bd.bookkey) = 1)   -- Approved for Content Services
       AND i.cloudproductid is not null  -- Product Info was previously sent to Content Services

    -- Save the @@ERROR and @@ROWCOUNT values in local 
    -- variables before they are cleared.
    SELECT @error_var = @@ERROR, @rowcount_var = @@ROWCOUNT
    IF @error_var <> 0 BEGIN
      SET @o_error_code = -1
      SET @o_error_desc = 'Error retrieving titles that were sent from the outbox'
      return   
    END 
  END
GO
GRANT EXEC ON qcs_get_outbox_titles TO PUBLIC
GO


