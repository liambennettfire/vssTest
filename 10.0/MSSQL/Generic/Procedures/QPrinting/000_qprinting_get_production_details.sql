if exists (select * from dbo.sysobjects where id = object_id(N'dbo.qprinting_get_production_details') and OBJECTPROPERTY(id, N'IsProcedure') = 1)
	drop procedure dbo.qprinting_get_production_details
GO

SET QUOTED_IDENTIFIER ON 
GO
SET ANSI_NULLS ON 
GO

CREATE PROCEDURE qprinting_get_production_details
 (@i_rightskey						integer,
  @o_error_code           integer output,
  @o_error_desc           varchar(2000) output)
AS

/******************************************************************************
**  Name: qprinting_get_production_details
**  Desc: This procedure returns associated formats with the given contract workkey,
**				if no workkey, it will find formats for all works associated with contractprojkey
**
**	Auth: Dustin Miller
**	Date: February 24 2017
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

	SELECT tpr.productionbookkey, tpr.taqprojectprintingkey, COALESCE(b.title, null) booktitle, titleclass
	FROM taqprojectrights tpr
	LEFT JOIN book b
	ON tpr.productionbookkey = b.bookkey
	WHERE tpr.rightskey = @i_rightskey

	-- Save the @@ERROR and @@ROWCOUNT values in local 
  -- variables before they are cleared.
  SELECT @error_var = @@ERROR, @rowcount_var = @@ROWCOUNT
  IF @error_var <> 0 or @rowcount_var = 0 BEGIN
    SET @o_error_code = 1
    SET @o_error_desc = 'no data found: rightskey = ' + cast(@i_rightskey AS VARCHAR)   
  END 
GO

GRANT EXEC ON qprinting_get_production_details TO PUBLIC
GO