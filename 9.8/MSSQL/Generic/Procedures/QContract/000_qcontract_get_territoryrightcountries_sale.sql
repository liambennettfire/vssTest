if exists (select * from dbo.sysobjects where id = object_id(N'dbo.qcontract_get_territoryrightcountries_sale') and OBJECTPROPERTY(id, N'IsProcedure') = 1)
drop procedure dbo.qcontract_get_territoryrightcountries_sale
GO

SET QUOTED_IDENTIFIER ON 
GO
SET ANSI_NULLS ON 
GO

CREATE PROCEDURE qcontract_get_territoryrightcountries_sale
 (@i_projectkey						integer,
  @i_rightskey						integer,
  @i_foresaleind					integer,
  @o_error_code           integer output,
  @o_error_desc           varchar(2000) output)
AS

/******************************************************************************
**  Name: qcontract_get_territoryrightcountries_sale
**  Desc: This procedure returns rows from the territoryrightcountries table based on whether they are forsale or not
**
**	Auth: Dustin Miller
**	Date: May 8 2012
*******************************************************************************/

  DECLARE @v_error			INT,
          @v_rowcount		INT

  SET @o_error_code = 0
  SET @o_error_desc = ''
	
  SELECT trc.*, gen.datadesc
	FROM territoryrightcountries trc, gentables gen
	WHERE trc.taqprojectkey = @i_projectkey
		AND trc.rightskey = @i_rightskey
		AND trc.forsaleind = @i_foresaleind
		AND gen.tableid = 114
		AND gen.datacode = trc.countrycode
	ORDER BY gen.datadesc ASC
		
  SELECT @v_error = @@ERROR, @v_rowcount = @@ROWCOUNT
  IF @v_error <> 0 BEGIN
    SET @o_error_code = -1
    SET @o_error_desc = 'Error returning territoryrightcountries details (projectkey=' + cast(@i_projectkey as varchar) + ')'
    RETURN  
  END   
GO

GRANT EXEC ON qcontract_get_territoryrightcountries_sale TO PUBLIC
GO