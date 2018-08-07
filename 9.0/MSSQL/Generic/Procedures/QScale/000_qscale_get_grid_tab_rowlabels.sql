if exists (select * from dbo.sysobjects where id = object_id(N'dbo.qscale_get_grid_tab_rowlabels') and OBJECTPROPERTY(id, N'IsProcedure') = 1)
drop procedure dbo.qscale_get_grid_tab_rowlabels
GO

SET QUOTED_IDENTIFIER ON 
GO
SET ANSI_NULLS ON 
GO

CREATE PROCEDURE qscale_get_grid_tab_rowlabels
 (@i_projectkey          integer,
  @i_scaletabkey         integer,
  @i_rowspeckey          integer,
  @o_error_code          integer output,
  @o_error_desc          varchar(2000) output)
AS

/******************************************************************************
**  File: 
**  Name: qscale_get_grid_tab_rowlabels
**  Desc: This stored procedure returns all grid tab row label info. 
**
**    Auth: Alan Katzen
**    Date: 24 February 2012
*******************************************************************************/

BEGIN
  SET @o_error_code = 0
  SET @o_error_desc = ''
  DECLARE @error_var    INT,
          @rowcount_var INT,
          @v_fieldtype  INT,
          @v_parametervaluecode INT,
          @v_row_itemcategorycode INT,
          @v_row_itemcode INT,
          @v_row_tableid INT

  SELECT @v_parametervaluecode = COALESCE(parametervaluecode,0),
         @v_fieldtype = dbo.qscale_get_fieldtype(616,itemcategorycode,itemcode),
         @v_row_itemcategorycode = itemcategorycode,@v_row_itemcode = itemcode
    FROM taqscaleadminspecitem 
   WHERE scaleadminspeckey = @i_rowspeckey
   
  SELECT @error_var = @@ERROR, @rowcount_var = @@ROWCOUNT
  IF @error_var <> 0 BEGIN
    SET @o_error_code = -1
    SET @o_error_desc = 'Unable to access taqscaleadminspecitem table.'
    RETURN
  END 
  
  SET @v_row_tableid = 0
  IF @v_fieldtype = 5 BEGIN
    -- get gentable location of row values (616 means that they are defined as a sub2gentable for tableid 616)
    SELECT @v_row_tableid = COALESCE(numericdesc1,616)
      FROM subgentables
     WHERE tableid = 616
       AND datacode = @v_row_itemcategorycode
       AND datasubcode = @v_row_itemcode

    SELECT @error_var = @@ERROR, @rowcount_var = @@ROWCOUNT
    IF @error_var <> 0 BEGIN
      SET @o_error_code = -1
      SET @o_error_desc = 'Unable to determine if gentable location of row values.'
      RETURN
    END 
  END
  
  SELECT dbo.qscale_get_rowlabeldesc(@v_parametervaluecode,@v_fieldtype,@v_row_itemcategorycode,@v_row_itemcode,rowvalue1,rowvalue2) rowlabeldesc,*,
         dbo.qscale_get_rowlabel_sortorder(@v_parametervaluecode,@v_fieldtype,@v_row_itemcategorycode,@v_row_itemcode,rowvalue1,rowvalue2) rowlabelsortorder,
         @v_row_tableid tableid, @v_fieldtype fieldtype, @v_row_itemcategorycode itemcategorycode, 
         @v_row_itemcode itemcode, @v_parametervaluecode parametervaluecode
    FROM taqprojectscalerowvalues
   WHERE taqprojectkey = @i_projectkey
     AND scaletabkey = @i_scaletabkey
order by rowlabelsortorder     

  SELECT @error_var = @@ERROR, @rowcount_var = @@ROWCOUNT
  IF @error_var <> 0 BEGIN
    SET @o_error_code = -1
    SET @o_error_desc = 'Unable to access taqprojectscalerowvalues table.'
    RETURN
  END 
END

GO
GRANT EXEC ON qscale_get_grid_tab_rowlabels TO PUBLIC
GO


