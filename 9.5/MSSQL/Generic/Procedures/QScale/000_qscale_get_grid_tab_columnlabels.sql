if exists (select * from dbo.sysobjects where id = object_id(N'dbo.qscale_get_grid_tab_columnlabels') and OBJECTPROPERTY(id, N'IsProcedure') = 1)
drop procedure dbo.qscale_get_grid_tab_columnlabels
GO

SET QUOTED_IDENTIFIER ON 
GO
SET ANSI_NULLS ON 
GO

CREATE PROCEDURE qscale_get_grid_tab_columnlabels
 (@i_projectkey          integer,
  @i_scaletabkey         integer,
  @i_columnspeckey       integer,
  @o_error_code          integer output,
  @o_error_desc          varchar(2000) output)
AS

/******************************************************************************
**  File: 
**  Name: qscale_get_grid_tab_columnlabels
**  Desc: This stored procedure returns all grid tab column label info. 
**
**    Auth: Alan Katzen
**    Date: 26 February 2012
*******************************************************************************/

BEGIN
  SET @o_error_code = 0
  SET @o_error_desc = ''
  DECLARE @error_var    INT,
          @rowcount_var INT,
          @v_fieldtype  INT,
          @v_parametervaluecode INT,
          @v_column_itemcategorycode INT,
          @v_column_itemcode INT,
          @v_column_tableid INT

  SELECT @v_parametervaluecode = COALESCE(parametervaluecode,0),
         @v_fieldtype = dbo.qscale_get_fieldtype(616,itemcategorycode,itemcode),
         @v_column_itemcategorycode = itemcategorycode,@v_column_itemcode = itemcode
    FROM taqscaleadminspecitem 
   WHERE scaleadminspeckey = @i_columnspeckey
   
  SELECT @error_var = @@ERROR, @rowcount_var = @@ROWCOUNT
  IF @error_var <> 0 BEGIN
    SET @o_error_code = -1
    SET @o_error_desc = 'Unable to access taqscaleadminspecitem table.'
    RETURN
  END 

  SET @v_column_tableid = 0
  IF @v_fieldtype = 5 BEGIN
    -- get gentable location of column values (616 means that they are defined as a sub2gentable for tableid 616)
    SELECT @v_column_tableid = COALESCE(numericdesc1,616)
      FROM subgentables
     WHERE tableid = 616
       AND datacode = @v_column_itemcategorycode
       AND datasubcode = @v_column_itemcode

    SELECT @error_var = @@ERROR, @rowcount_var = @@ROWCOUNT
    IF @error_var <> 0 BEGIN
      SET @o_error_code = -1
      SET @o_error_desc = 'Unable to determine if gentable location of column values.'
      RETURN
    END 
  END
   
  SELECT dbo.qscale_get_columnlabeldesc(@v_parametervaluecode,@v_fieldtype,@v_column_itemcategorycode,@v_column_itemcode,columnvalue1,columnvalue2) columnlabeldesc,*,
         dbo.qscale_get_columnlabel_sortorder(@v_parametervaluecode,@v_fieldtype,@v_column_itemcategorycode,@v_column_itemcode,columnvalue1,columnvalue2) columnlabelsortorder,
         @v_column_tableid tableid, @v_fieldtype fieldtype, @v_column_itemcategorycode itemcategorycode, 
         @v_column_itemcode itemcode, @v_parametervaluecode parametervaluecode
    FROM taqprojectscalecolumnvalues
   WHERE taqprojectkey = @i_projectkey
     AND scaletabkey = @i_scaletabkey
  order by columnlabelsortorder

  SELECT @error_var = @@ERROR, @rowcount_var = @@ROWCOUNT
  IF @error_var <> 0 BEGIN
    SET @o_error_code = -1
    SET @o_error_desc = 'Unable to access taqprojectscalecolumnvalues table.'
    RETURN
  END 
END

GO
GRANT EXEC ON qscale_get_grid_tab_columnlabels TO PUBLIC
GO


