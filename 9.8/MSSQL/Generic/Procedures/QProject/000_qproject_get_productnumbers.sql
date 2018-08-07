if exists (select * from dbo.sysobjects where id = object_id(N'dbo.qproject_get_productnumbers') and OBJECTPROPERTY(id, N'IsProcedure') = 1)
  drop procedure dbo.qproject_get_productnumbers
GO

SET QUOTED_IDENTIFIER ON 
GO
SET ANSI_NULLS ON 
GO


CREATE PROCEDURE qproject_get_productnumbers
 (@i_projectkey     integer,
  @o_error_code     integer       output,
  @o_error_desc     varchar(2000) output)
AS

/******************************************************************************
**  Name: qproject_get_productnumbers
**  Desc: This procedure gets all productnumbers from taqproductnumbers table
**        for the given taqprojectkey.
**
**  Auth: Kate W.
**  Date: 26 June 2008
*******************************************************************************/

  DECLARE @v_error  INT,
    @v_rowcount INT

  SET @o_error_code = 0
  SET @o_error_desc = ''

  SELECT g.datadesc, g.alternatedesc1, g.alternatedesc2, g.gen1ind, g.gen2ind, e.gen3ind, g.qsicode,
     NULL prod_order, NULL usageclasscode, 0 newrowind, 
    (SELECT COUNT(*) FROM subgentables WHERE tableid = 594 AND datacode = g.datacode) subgen_count, p.*
  FROM taqproductnumbers p, gentables g, gentables_ext e
  WHERE p.productidcode = g.datacode AND
	  g.tableid = e.tableid AND
	  g.datacode = e.datacode AND
      g.tableid = 594 AND
      p.taqprojectkey = @i_projectkey AND p.elementkey IS NULL

  -- Save the @@ERROR and @@ROWCOUNT values in local 
  -- variables before they are cleared.
  SELECT @v_error = @@ERROR, @v_rowcount = @@ROWCOUNT
  IF @v_error <> 0 or @v_rowcount = 0 BEGIN
    SET @o_error_code = 1
    SET @o_error_desc = 'Could not retrieve from taqproductnumbers table: taqprojectkey = ' + cast(@i_projectkey AS VARCHAR)   
  END 

GO

GRANT EXEC ON qproject_get_productnumbers TO PUBLIC
GO


