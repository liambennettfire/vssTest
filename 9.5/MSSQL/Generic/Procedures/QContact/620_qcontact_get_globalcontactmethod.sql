if exists (select * from dbo.sysobjects where id = object_id(N'dbo.qcontact_get_globalcontactmethod') and OBJECTPROPERTY(id, N'IsProcedure') = 1)
  drop procedure dbo.qcontact_get_globalcontactmethod
GO

SET QUOTED_IDENTIFIER ON 
GO
SET ANSI_NULLS ON 
GO

CREATE PROCEDURE qcontact_get_globalcontactmethod
 (@i_methodkey      integer,
  @o_error_code     integer output,
  @o_error_desc     varchar(2000) output)
AS

/******************************************************************************
**  Name: qcontact_get_globalcontactmethod
**  Desc: This stored procedure returns contact method information for given
**        globalcontactmethodkey.
**
**  Auth: Kate J. Wiewiora
**  Date: 1 July 2005
*******************************************************************************/

  DECLARE @v_error    INT,
          @v_rowcount INT

  SET @o_error_code = 0
  SET @o_error_desc = ''

  SELECT contactmethodcode, contactmethodvalue
  FROM globalcontactmethod
  WHERE globalcontactmethodkey = @i_methodkey

  -- Save the @@ERROR and @@ROWCOUNT values in local 
  -- variables before they are cleared.
  SELECT @v_error = @@ERROR, @v_rowcount = @@ROWCOUNT
  IF @v_error <> 0 OR @v_rowcount = 0 BEGIN
    SET @o_error_code = 1
    SET @o_error_desc = 'no data found on globalcontactmethod (' + cast(@v_error AS VARCHAR) + '): globalcontactmethodkey = ' + cast(@i_methodkey AS VARCHAR)   
  END 

GO

GRANT EXEC ON qcontact_get_globalcontactmethod TO PUBLIC
GO


