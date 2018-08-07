if exists (select * from dbo.sysobjects where id = object_id(N'dbo.qutl_get_isbnlabels') and OBJECTPROPERTY(id, N'IsProcedure') = 1)
  drop procedure dbo.qutl_get_isbnlabels
GO

SET QUOTED_IDENTIFIER ON 
GO
SET ANSI_NULLS ON 
GO


CREATE PROCEDURE qutl_get_isbnlabels
 (@o_error_code     integer output,
  @o_error_desc     varchar(2000) output)
AS

/******************************************************************************
**  Name: qutl_get_isbnlabels
**  Desc: Returns client's isbn labels configuration.
**              
**  Auth: Kate J. Wiewiora
**  Date: 18 July 2006
*******************************************************************************/

  DECLARE @error_var    INT
  DECLARE @rowcount_var INT

  SET @o_error_code = 0
  SET @o_error_desc = ''

  SELECT * 
  FROM isbnlabels

  -- Save the @@ERROR and @@ROWCOUNT values in local 
  -- variables before they are cleared.
  SELECT @error_var = @@ERROR, @rowcount_var = @@ROWCOUNT
  IF @error_var <> 0 BEGIN
    SET @o_error_code = 1
    SET @o_error_desc = 'Error accessing isbnlabels table.'
  END 
GO

GRANT EXEC ON qutl_get_isbnlabels TO PUBLIC
GO
