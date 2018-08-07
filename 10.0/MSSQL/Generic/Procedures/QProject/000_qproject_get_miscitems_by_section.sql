if exists (select * from dbo.sysobjects where id = object_id(N'dbo.qproject_get_miscitems_by_section') and OBJECTPROPERTY(id, N'IsProcedure') = 1)
  drop procedure dbo.qproject_get_miscitems_by_section
GO

CREATE PROCEDURE qproject_get_miscitems_by_section
 (@i_projectkey       integer,
  @i_configobjectid   varchar(100),
  @i_usageclasscode   integer,
  @o_error_code       integer output,
  @o_error_desc       varchar(2000) output)
AS

/*************************************************************************************
**  Name: qproject_get_miscitems_by_section
**  Desc: Returns Project Miscellaneous Item information for given project,
**        section (configobjectkey) and usage class.
**
**  Auth: Kate
**  Date: 2/27/07
**************************************************************************************/

  DECLARE
    @v_configobjectkey  INT,
    @v_error  INT,
    @v_rowcount INT
 
  SET @o_error_code = 0
  SET @o_error_desc = ''
  
  SELECT TOP(1) @v_configobjectkey = configobjectkey
  FROM qsiconfigobjects
  WHERE LOWER(configobjectid) = LOWER(@i_configobjectid)

  -- Save @@ERROR and @@ROWCOUNT values in local variables before they are cleared
  SELECT @v_error = @@ERROR, @v_rowcount = @@ROWCOUNT
  IF @v_error <> 0 or @v_rowcount = 0 BEGIN
    SET @o_error_code = 1
    SET @o_error_desc = 'Could not determine Web Section (qsiconfigobjects.configobjectid ' + CONVERT(VARCHAR, @i_configobjectid) + ').'
    RETURN
  END
               
  SELECT s.usageclasscode, s.columnnumber, s.itemposition, s.updateind,
      i.misckey, i.miscname, i.misclabel, i.misctype, i.fieldformat, i.datacode,
      i.taqtotmmind, 0 newrowind,
      CASE WHEN i.misctype=1 THEN p.longvalue ELSE NULL END longvalue,
      CASE WHEN i.misctype=4 THEN p.longvalue ELSE NULL END checkboxvalue, 
      CASE WHEN i.misctype=5 THEN p.longvalue ELSE NULL END dropdownvalue,
      p.floatvalue, p.textvalue, p.datevalue
  FROM miscitemsection s, bookmiscitems i, taqprojectmisc p
  WHERE s.misckey = i.misckey AND 
      i.misckey = p.misckey AND
      i.activeind = 1 AND
      p.taqprojectkey = @i_projectkey AND
      s.configobjectkey = @v_configobjectkey AND 
      s.usageclasscode = @i_usageclasscode
  UNION
  SELECT s.usageclasscode, s.columnnumber, s.itemposition, s.updateind,
      i.misckey, i.miscname, i.misclabel, i.misctype, i.fieldformat, i.datacode,
      i.taqtotmmind, 0 newrowind,
      CASE WHEN i.misctype=1 THEN p.longvalue ELSE NULL END longvalue,
      CASE WHEN i.misctype=4 THEN p.longvalue ELSE NULL END checkboxvalue, 
      CASE WHEN i.misctype=5 THEN p.longvalue ELSE NULL END dropdownvalue,
      p.floatvalue, p.textvalue, p.datevalue
  FROM miscitemsection s, bookmiscitems i, taqprojectmisc p
  WHERE s.misckey = i.misckey AND 
      i.misckey = p.misckey AND
      i.activeind = 1 AND
      p.taqprojectkey = @i_projectkey AND
      s.configobjectkey = @v_configobjectkey AND 
      s.usageclasscode = 0 AND
      NOT EXISTS (SELECT * FROM miscitemsection s2, taqprojectmisc p2
                  WHERE i.misckey = s2.misckey AND 
                      i.misckey = p2.misckey AND
                      i.activeind = 1 AND
                      p2.taqprojectkey = @i_projectkey AND
                      s2.configobjectkey = @v_configobjectkey AND
                      s2.usageclasscode = @i_usageclasscode)      
  ORDER BY s.columnnumber, s.itemposition

  -- Save @@ERROR and @@ROWCOUNT values in local variables before they are cleared
  SELECT @v_error = @@ERROR, @v_rowcount = @@ROWCOUNT
  IF @v_error <> 0 or @v_rowcount = 0 BEGIN
    SET @o_error_code = 1
    SET @o_error_desc = 'Could not retrieve Project Miscellaneous Items (projectkey=' + CONVERT(VARCHAR, @i_projectkey) + ', configobjectkey=' + CONVERT(VARCHAR, @v_configobjectkey) + ').'
  END 
GO

GRANT EXEC ON qproject_get_miscitems_by_section TO PUBLIC
GO
