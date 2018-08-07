if exists (select * from dbo.sysobjects where id = object_id(N'dbo.qscale_get_specitems') and OBJECTPROPERTY(id, N'IsProcedure') = 1)
drop procedure dbo.qscale_get_specitems
GO

SET QUOTED_IDENTIFIER ON 
GO
SET ANSI_NULLS ON 
GO

CREATE PROCEDURE qscale_get_specitems
	(@i_getsubtypes					 tinyint,	--whether to get sub descs and codes too (1 = true, 0 = false)
	 @o_error_code           integer output,
   @o_error_desc           varchar(2000) output)
AS

/******************************************************************************
**  Name: qscale_get_specitems
**  Desc: This procedure returns all the spec items for use with scales
**
**	Auth: Dustin Miller
**	Date: February 22 2012
*******************************************************************************/

  DECLARE @v_error	INT,
          @v_rowcount INT

  SET @o_error_code = 0
  SET @o_error_desc = ''
  
  IF @i_getsubtypes > 0
  BEGIN
		SELECT g.datadesc, s.datacode, s.datasubcode, s.datadesc AS datasubdesc 
		FROM gentables g, subgentables s
		WHERE g.tableid=616 
			AND s.tableid=g.tableid 
			AND g.datacode=s.datacode 
			AND subgen1ind=1 --comment line out for debug (if no values populating drop downs for spec items)
	END
	ELSE BEGIN
		SELECT datadesc, datacode 
		FROM gentables g 
		WHERE tableid=616 AND datacode IN 
			(SELECT DISTINCT datacode FROM subgentables WHERE tableid=g.tableid)
	END

  SELECT @v_error = @@ERROR, @v_rowcount = @@ROWCOUNT
  IF @v_error <> 0 BEGIN
    SET @o_error_code = -1
    SET @o_error_desc = 'Error returning spec item information'
    RETURN  
  END 
  
GO

GRANT EXEC ON qscale_get_specitems TO PUBLIC
GO