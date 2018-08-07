IF  EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[qutl_get_default_taskview]') AND type in (N'P', N'PC'))
DROP PROCEDURE [dbo].[qutl_get_default_taskview]
GO

SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

/* 
declare @err int
declare @dsc varchar(2000)
exec qutl_get_default_taskview 585251, 5, 2, @err, @dsc
select * from qsiusers where userkey = 585251

*/

CREATE PROCEDURE [dbo].[qutl_get_default_taskview]
 (@i_userId						integer,
  @i_itemtype					integer,
  @i_usageclass				integer,
  @o_error_code				integer output,
  @o_error_desc				varchar(2000) output)
AS

/******************************************************************************
**  Name: qutl_get_default_taskview
**  Desc: This stored procedure returns the default taskviewkey from the
**			qsiusersusageclass table based on the itemtype, userid, and
**			usageclass passed in.
**
**  Auth: Lisa Cormier
**  Date: 16 July 2008
*******************************************************************************
**  Date    Who Change
**  ------- --- -------------------------------------------
**  
*******************************************************************************/

  SET @o_error_code = 0
  SET @o_error_desc = ''
  DECLARE 
    @error_var    INT,
    @rowcount_var INT,
    @v_count      INT

  SELECT @v_count = count(*)
    FROM qsiusersusageclass
   WHERE userkey = @i_userid 
     and itemtypecode = @i_itemtype 
     and usageclasscode = @i_usageclass
 
  SELECT @error_var = @@ERROR, @rowcount_var = @@ROWCOUNT
  IF @error_var <> 0 BEGIN
    SET @o_error_code = -1
    SET @o_error_desc = 'Error accessing qsiusers table from qutl_get_default_taskview stored proc'  
  END 
     
  IF @v_count > 0 BEGIN
    -- itemtype and usageclass
    SELECT ISNULL(summarytaskviewkey,0) as summarytaskviewkey
      FROM qsiusersusageclass
     WHERE userkey = @i_userid 
       and itemtypecode = @i_itemtype 
       and usageclasscode = @i_usageclass
  END
  ELSE BEGIN
    -- just itemtype
    SELECT ISNULL(summarytaskviewkey,0) as summarytaskviewkey
      FROM qsiusersusageclass
     WHERE userkey = @i_userid 
       and itemtypecode = @i_itemtype 
       and COALESCE(usageclasscode,0) = 0
  END

  -- Save the @@ERROR and @@ROWCOUNT values in local 
  -- variables before they are cleared.
  SELECT @error_var = @@ERROR, @rowcount_var = @@ROWCOUNT
  IF @error_var <> 0 BEGIN
    SET @o_error_code = -1
    SET @o_error_desc = 'Error accessing qsiusers table from qutl_get_default_taskview stored proc'  
  END 

GO

GRANT EXEC on qutl_get_default_taskview TO PUBLIC
GO

