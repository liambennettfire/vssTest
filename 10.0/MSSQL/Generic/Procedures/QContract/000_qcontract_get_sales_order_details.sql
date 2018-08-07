if exists (select * from dbo.sysobjects where id = object_id(N'dbo.qcontract_get_sales_order_details') and OBJECTPROPERTY(id, N'IsProcedure') = 1)
	drop procedure dbo.qcontract_get_sales_order_details
GO

SET QUOTED_IDENTIFIER ON 
GO
SET ANSI_NULLS ON 
GO

CREATE PROCEDURE qcontract_get_sales_order_details
 (@i_rightskey						integer,
  @o_error_code           integer output,
  @o_error_desc           varchar(2000) output)
AS

/******************************************************************************
**  Name: qcontract_get_sales_order_details
**  Desc: This procedure returns data for the Sales Order Details section
**
**	Auth: Dustin Miller
**	Date: March 6 2017
*******************************************************************************/

  DECLARE @v_workbookkey			 INT,
					@v_printrunitemcode  INT,
					@v_printrunusagecode INT,
					@v_printrunname      VARCHAR(255),
					@v_printrunkey       INT,
					@v_error						 INT,
          @v_rowcount					 INT

  SET @o_error_code = 0
  SET @o_error_desc = ''
  DECLARE @error_var    INT
  DECLARE @rowcount_var INT

	SELECT tpr.*
	FROM taqprojectrights tpr
	WHERE tpr.rightskey = @i_rightskey

	-- Save the @@ERROR and @@ROWCOUNT values in local 
  -- variables before they are cleared.
  SELECT @error_var = @@ERROR, @rowcount_var = @@ROWCOUNT
  IF @error_var <> 0 or @rowcount_var = 0 BEGIN
    SET @o_error_code = 1
    SET @o_error_desc = 'no data found: rightskey = ' + cast(@i_rightskey AS VARCHAR)   
  END 
GO

GRANT EXEC ON qcontract_get_sales_order_details TO PUBLIC
GO