if exists (select * from dbo.sysobjects where id = object_id(N'dbo.qpl_get_taqversionspecitems') and OBJECTPROPERTY(id, N'IsProcedure') = 1)
  drop procedure dbo.qpl_get_taqversionspecitems
GO

CREATE PROCEDURE qpl_get_taqversionspecitems
 (@i_projectkey     integer,
  @i_plstagecode    integer,
  @i_taqversionkey  integer,
  @i_formatkey      integer,
  @i_categorycode		integer,
  @o_error_code   integer output,
  @o_error_desc   varchar(2000) output)
AS

/*********************************************************************************
**  Name: qpl_get_taqversionspecitems
**  Desc: This stored procedure gets the P&L spec items for given version/format.
**
**  Auth: Kate
**  Date: April 13 2010
**
**
**  Modified By: Dustin Miller
**  Date: February 28, 2012
**	Desc: Modified to match changes made for case 14193 (Specifications Enhancement)
**********************************************************************************/
  
DECLARE
  @v_error    INT,
  @v_rowcount INT

BEGIN
  SET @o_error_code = 0
  SET @o_error_desc = ''
 
	IF @i_categorycode > 0
	BEGIN
		SELECT s.numericdesc1, i.*, c.itemcategorycode
		FROM taqversionspecitems i, subgentables s, taqversionspeccategory c
		WHERE i.taqversionspecategorykey = c.taqversionspecategorykey AND
			c.itemcategorycode = s.datacode AND
			i.itemcode = s.datasubcode AND
			s.tableid = 616 AND
			c.taqprojectkey = @i_projectkey AND
			c.plstagecode = @i_plstagecode AND
			c.taqversionkey = @i_taqversionkey AND
			c.taqversionformatkey = @i_formatkey AND
			c.itemcategorycode = @i_categorycode
  END
  ELSE BEGIN
		SELECT s.numericdesc1, i.*, c.itemcategorycode
		FROM taqversionspecitems i, subgentables s, taqversionspeccategory c
		WHERE i.taqversionspecategorykey = c.taqversionspecategorykey AND
			c.itemcategorycode = s.datacode AND
			i.itemcode = s.datasubcode AND
			s.tableid = 616 AND
			c.taqprojectkey = @i_projectkey AND
			c.plstagecode = @i_plstagecode AND
			c.taqversionkey = @i_taqversionkey AND
			c.taqversionformatkey = @i_formatkey
  END

  SELECT @v_error = @@ERROR
  IF @v_error <> 0 BEGIN
    SET @o_error_code = -1
    SET @o_error_desc = 'Could not access taqversionspecitems table (taqprojectkey=' + CAST(@i_projectkey AS VARCHAR) + 
      ', plstagecode=' + CAST(@i_plstagecode AS VARCHAR) + ', taqversionkey=' + CAST(@i_taqversionkey AS VARCHAR) + 
      ', taqprojectformatkey=' + CAST(@i_formatkey AS VARCHAR) + ').'
  END
  
END
go

GRANT EXEC ON qpl_get_taqversionspecitems TO PUBLIC
go
