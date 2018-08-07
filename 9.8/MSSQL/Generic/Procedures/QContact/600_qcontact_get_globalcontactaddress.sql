if exists (select * from dbo.sysobjects where id = object_id(N'dbo.qcontact_get_globalcontactaddress') and OBJECTPROPERTY(id, N'IsProcedure') = 1)
  drop procedure dbo.qcontact_get_globalcontactaddress
GO

SET QUOTED_IDENTIFIER ON 
GO
SET ANSI_NULLS ON 
GO

CREATE PROCEDURE qcontact_get_globalcontactaddress
 (@i_addresskey     integer,
  @o_error_code     integer output,
  @o_error_desc     varchar(2000) output)
AS

/******************************************************************************
**  Name: qcontact_get_globalcontactaddress
**  Desc: This stored procedure returns address information for given
**        globalcontactaddresskey.
**
**  Auth: Kate J. Wiewiora
**  Date: 23 June 2005
*******************************************************************************/

  DECLARE @v_error    INT,
          @v_rowcount INT

  SET @o_error_code = 0
  SET @o_error_desc = ''

  SELECT address1, address2, address3, city, statecode, zipcode, countrycode
  FROM globalcontactaddress
  WHERE globalcontactaddresskey = @i_addresskey

  -- Save the @@ERROR and @@ROWCOUNT values in local 
  -- variables before they are cleared.
  SELECT @v_error = @@ERROR, @v_rowcount = @@ROWCOUNT
  IF @v_error <> 0 OR @v_rowcount = 0 BEGIN
    SET @o_error_code = 1
    SET @o_error_desc = 'no data found on globalcontactaddress (' + cast(@v_error AS VARCHAR) + '): globalcontactaddresskey = ' + cast(@i_addresskey AS VARCHAR)   
  END 

GO
GRANT EXEC ON qcontact_get_globalcontactaddress TO PUBLIC
GO


