if exists (select * from dbo.sysobjects where id = object_id(N'dbo.qcontact_get_linked_items') and OBJECTPROPERTY(id, N'IsProcedure') = 1)
  drop procedure dbo.qcontact_get_linked_items
GO

SET QUOTED_IDENTIFIER ON 
GO
SET ANSI_NULLS ON 
GO

CREATE PROCEDURE qcontact_get_linked_items
 (@i_itemkey      integer,
  @i_tablename    varchar(30),
  @o_error_code   integer output,
  @o_error_desc   varchar(2000) output)
AS

/******************************************************************************
**  Name: qcontact_get_linked_items
**  Desc: This stored procedure returns all linked addresses or communication
**        methods for the given master key and table name.
**
**  Auth: Kate Wiewiora
**  Date: June 20, 2005
*******************************************************************************/

  DECLARE @v_linkkey  INT,
    @v_error  INT,
    @v_rowcount   INT

  SET @o_error_code = 0
  SET @o_error_desc = ''
  
  IF @i_tablename = 'globalcontactaddress'
    BEGIN
      SELECT @v_linkkey = linkaddresskey
      FROM globalcontactaddress
      WHERE globalcontactaddresskey = @i_itemkey
      
      SELECT c.globalcontactkey, c.displayname,
        a.globalcontactaddresskey itemkey, a.linkaddresskey linkkey,
        a.primaryind, a.addresstypecode itemtypecode,
        0 itemtypesubcode, a.addressdescription itemdesc,
        ispassedkey = 
          CASE globalcontactaddresskey
            WHEN @i_itemkey THEN 1
            ELSE 0
          END
      FROM globalcontactaddress a, globalcontact c 
      WHERE a.globalcontactkey = c.globalcontactkey AND 
        linkaddresskey = @v_linkkey
      ORDER BY ispassedkey DESC, displayname ASC
    END
    
  ELSE IF @i_tablename = 'globalcontactmethod'
    BEGIN
      SELECT @v_linkkey = linkmethodkey
      FROM globalcontactmethod
      WHERE globalcontactmethodkey = @i_itemkey
    
      SELECT c.globalcontactkey, c.displayname,
        m.globalcontactmethodkey itemkey, m.linkmethodkey linkkey,
        m.primaryind, m.contactmethodcode itemtypecode,
        m.contactmethodsubcode itemtypesubcode, m.contactmethodaddtldesc itemdesc,
        ispassedkey = 
          CASE globalcontactmethodkey
            WHEN @i_itemkey THEN 1
            ELSE 0
          END
      FROM globalcontactmethod m, globalcontact c 
      WHERE m.globalcontactkey = c.globalcontactkey AND 
        linkmethodkey = @v_linkkey
      ORDER BY ispassedkey DESC, displayname ASC
    END

  -- Save the @@ERROR and @@ROWCOUNT values in local 
  -- variables before they are cleared.
  SELECT @v_error = @@ERROR, @v_rowcount = @@ROWCOUNT
  IF @v_error <> 0 OR @v_rowcount = 0 BEGIN
    SET @o_error_code = 1
    SET @o_error_desc = 'no data found on ' + @i_tablename + '(key = ' + cast(@i_itemkey AS VARCHAR) + ')'
  END 

GO

GRANT EXEC ON qcontact_get_linked_items TO PUBLIC
GO


