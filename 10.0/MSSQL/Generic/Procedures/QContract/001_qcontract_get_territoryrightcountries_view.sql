if exists (select * from dbo.sysobjects where id = object_id(N'dbo.qcontract_get_territoryrightcountries_view') and OBJECTPROPERTY(id, N'IsProcedure') = 1)
drop procedure dbo.qcontract_get_territoryrightcountries_view
GO

SET QUOTED_IDENTIFIER ON 
GO
SET ANSI_NULLS ON 
GO

CREATE PROCEDURE qcontract_get_territoryrightcountries_view
 (@i_currentterritorycode	integer,
  @i_exclusivecode				integer,
  @i_singlecountrycode		integer,
  @i_singlecountrygroup		integer,
  @o_error_code           integer output,
  @o_error_desc           varchar(2000) output)
AS

/******************************************************************************
**  Name: qcontract_get_territoryrightcountries_view
**  Desc: This procedure returns country details for all rows from the get_countries_from_territory view
**
**	Auth: Dustin Miller
**	Date: May 15 2012
*******************************************************************************/

  DECLARE @v_error			INT,
          @v_rowcount		INT

  SET @o_error_code = 0
  SET @o_error_desc = ''
	
  SELECT *
  FROM get_countries_from_territory(@i_currentterritorycode,@i_singlecountrycode,@i_singlecountrygroup,@i_exclusivecode)
		
  SELECT @v_error = @@ERROR, @v_rowcount = @@ROWCOUNT
  IF @v_error <> 0 BEGIN
    SET @o_error_code = -1
    SET @o_error_desc = 'Error returning territoryrightcountries view details.'
    RETURN  
  END   
GO

GRANT EXEC ON qcontract_get_territoryrightcountries_view TO PUBLIC
GO