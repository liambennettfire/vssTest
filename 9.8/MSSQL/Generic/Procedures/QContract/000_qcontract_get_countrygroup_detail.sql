if exists (select * from dbo.sysobjects where id = object_id(N'dbo.qcontract_get_countrygroup_detail') and OBJECTPROPERTY(id, N'IsProcedure') = 1)
drop procedure dbo.qcontract_get_countrygroup_detail
GO

SET QUOTED_IDENTIFIER ON 
GO
SET ANSI_NULLS ON 
GO

CREATE PROCEDURE qcontract_get_countrygroup_detail
 (@i_groupcode						integer,
  @o_error_code           integer output,
  @o_error_desc           varchar(2000) output)
AS

/******************************************************************************
**  Name: qcontract_get_countrygroup_detail
**  Desc: This procedure returns detail for all the countries in a given country group
**
**	Auth: Dustin Miller
**	Date: May 15 2012
*******************************************************************************/

  DECLARE @v_error			INT,
          @v_rowcount		INT

  SET @o_error_code = 0
  SET @o_error_desc = ''
	
  SELECT code2
  FROM gentablesrelationshipdetail
  WHERE gentablesrelationshipkey = 23
		AND code1 = @i_groupcode
		
  SELECT @v_error = @@ERROR, @v_rowcount = @@ROWCOUNT
  IF @v_error <> 0 BEGIN
    SET @o_error_code = -1
    SET @o_error_desc = 'Error returning country group details data.'
    RETURN  
  END   
GO

GRANT EXEC ON qcontract_get_countrygroup_detail TO PUBLIC
GO