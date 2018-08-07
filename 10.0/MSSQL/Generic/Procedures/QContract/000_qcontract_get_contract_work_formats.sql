if exists (select * from dbo.sysobjects where id = object_id(N'dbo.qcontract_get_contract_work_formats') and OBJECTPROPERTY(id, N'IsProcedure') = 1)
	drop procedure dbo.qcontract_get_contract_work_formats
GO

SET QUOTED_IDENTIFIER ON 
GO
SET ANSI_NULLS ON 
GO

CREATE PROCEDURE qcontract_get_contract_work_formats
 (@i_contractprojectkey		integer,
  @i_workkey							integer,
  @o_error_code           integer output,
  @o_error_desc           varchar(2000) output)
AS

/******************************************************************************
**  Name: qcontract_get_contract_work_formats
**  Desc: This procedure returns associated formats with the given contract workkey
**
**	Auth: Dustin Miller
**	Date: February 24 2017
*******************************************************************************
**  Change History
*******************************************************************************
**  Date:        Author:     Description:
**  --------     --------    -------------------------------------------
**  03/13/2017   Dustin      42876 No longer typeahed "search" based, just takes projectkey and workkey.
**													 Renamed qcontract_get_contract_work_formats from qcontract_search_contract_work_formats
**	03/29/2017	 Dustin			 Also returns productnumber if available (to distinguish formats with same title)
****************************************************************************************************/

  DECLARE @v_workbookkey INT,
					@v_error			 INT,
          @v_rowcount		 INT

  SET @o_error_code = 0
  SET @o_error_desc = ''
	
  IF COALESCE(@i_workkey, 0) > 0
	BEGIN
		SELECT @v_workbookkey = workkey
		FROM taqproject
		WHERE taqprojectkey = @i_workkey

		SELECT b.bookkey,
			b.title workformatinfo,
			COALESCE(c.productnumberx, c.eanx) prodnum,
			b.usageclasscode, c.mediatypecode, c.mediatypesubcode
    FROM book b,  
      coretitleinfo c
    WHERE 
      b.bookkey = c.bookkey AND
      c.printingkey = 1 AND
      c.workkey = (SELECT workkey FROM book where bookkey = @v_workbookkey)
    ORDER BY b.linklevelcode ASC
	END
GO

GRANT EXEC ON qcontract_get_contract_work_formats TO PUBLIC
GO