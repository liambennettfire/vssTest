IF EXISTS (SELECT * FROM sysobjects WHERE type = 'P' AND name = 'qutl_get_datetypes_by_itemtype')
  DROP PROCEDURE  qutl_get_datetypes_by_itemtype
GO

CREATE PROCEDURE qutl_get_datetypes_by_itemtype
(
  @i_userkey  integer,
  @i_windowname varchar(100),
  @i_bookkey integer,
  @i_printingkey integer,
  @i_itemtype	integer,
  @i_usageclass	integer,
  @o_error_code			INT OUT,
  @o_error_desc			VARCHAR(2000) OUT 
)
AS

/****************************************************************************************************************************
**  Name: qutl_get_datetypes_by_itemtype
**  Desc: This stored procedure returns a list of datetype (task) values based off the
**				itemtype filtering in gentables, as well as security
**
**    Auth: Dustin Miller
**    Date: 11/13/12
*****************************************************************************************************************************
**    Change History
*****************************************************************************************************************************
**    Date:        Author:         Description:
**    --------     --------        --------------------------------------------------------------------------------------
**    05/10/2016   Uday			   37359 Allow "Copy from Project" to be a different class from project being created 
*****************************************************************************************************************************/

BEGIN  
  DECLARE 
    @error_var  INT,
    @rowcount_var INT,
    @v_class  INT,
    @v_itemtype INT,
    @v_tableid	INT,
    @v_qsicode INT

  SET @o_error_code = 0
  SET @o_error_desc = ''
  SET @v_qsicode = 0
  
  SET @v_tableid = 323 --datetype

  SET NOCOUNT ON
  
  SELECT * FROM dbo.qutl_get_datetype_itemtype_filtering(@i_userkey, @i_windowname, @i_bookkey, @i_printingkey, @i_itemtype, @i_usageclass)
  
  -- Save the @@ERROR and @@ROWCOUNT values in local 
  -- variables before they are cleared.
  SELECT @error_var = @@ERROR, @rowcount_var = @@ROWCOUNT
  IF @error_var <> 0 BEGIN
    SET @o_error_code = -1
    SET @o_error_desc = 'Error accessing gentables tableid=' + cast(@v_tableid AS VARCHAR)
  END     

END
GO

GRANT EXEC ON qutl_get_datetypes_by_itemtype TO PUBLIC
GO
