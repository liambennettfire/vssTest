if exists (select * from dbo.sysobjects where id = object_id(N'dbo.qelement_get_miscitems_defaults') and OBJECTPROPERTY(id, N'IsProcedure') = 1)
  drop procedure dbo.qelement_get_miscitems_defaults
GO

CREATE PROCEDURE qelement_get_miscitems_defaults
 (@i_elementkey       integer,
  @i_configobjectid   varchar(100),
  @i_usageclasscode   integer,
  @o_error_code       integer output,
  @o_error_desc       varchar(2000) output)
AS

/*************************************************************************************
**  Name: qelement_get_miscitems_defaults
**  Desc: Returns Miscellaneous Item Defaults for given web section 
**        and element's orgentries.
**
**  Auth: Alan Katzen
**  Date: 5/20/08
**************************************************************************************/

  DECLARE
    @v_configobjectkey  INT,
    @v_projectkey  INT,
    @v_bookkey  INT,
    @v_error  INT,
    @v_rowcount INT
 
  SET @o_error_code = 0
  SET @o_error_desc = ''
  
  SELECT @v_configobjectkey = configobjectkey
  FROM qsiconfigobjects
  WHERE LOWER(configobjectid) = LOWER(@i_configobjectid)

  -- Save @@ERROR and @@ROWCOUNT values in local variables before they are cleared
  SELECT @v_error = @@ERROR, @v_rowcount = @@ROWCOUNT
  IF @v_error <> 0 or @v_rowcount = 0 BEGIN
    SET @o_error_code = 1
    SET @o_error_desc = 'Could not determine Web Section (qsiconfigobjects.configobjectid ' + CONVERT(VARCHAR, @i_configobjectid) + ').'
    return
  END

  SELECT @v_bookkey = COALESCE(bookkey,0),
         @v_projectkey = COALESCE(taqprojectkey,0)
    FROM taqprojectelement
   WHERE taqelementkey = @i_elementkey
   
  SELECT @v_error = @@ERROR, @v_rowcount = @@ROWCOUNT
  IF @v_error <> 0 BEGIN
    SET @o_error_code = -1
    SET @o_error_desc = 'Could not access taqprojectelement (taqelementkey: ' + CONVERT(VARCHAR, @i_elementkey) + ').'
    return
  END

  IF (@v_bookkey <= 0 AND @v_projectkey <= 0) BEGIN
    -- this element is not associated with a title or a project/journal
    return
  END

  -- use the associated project's orgentries first
  IF @v_projectkey > 0 BEGIN
    SELECT i.misckey, i.miscname, i.misclabel, i.misctype, i.fieldformat, i.datacode,
        i.taqtotmmind, d.orglevel, d.orgentrykey, 
        CASE WHEN i.misctype=1 THEN d.longvalue ELSE NULL END longvalue,
        CASE WHEN i.misctype=4 THEN d.longvalue ELSE NULL END checkboxvalue, 
        CASE WHEN i.misctype=5 THEN d.longvalue ELSE NULL END dropdownvalue,
        d.floatvalue, d.textvalue, d.datevalue,
        s.usageclasscode, s.columnnumber, s.itemposition, s.updateind, d.orglevel
    FROM bookmiscitems i,   
        bookmiscdefaults d,   
        miscitemsection s
    WHERE d.misckey = i.misckey AND  
        i.misckey = s.misckey AND  
        i.activeind = 1 AND
        s.configobjectkey = @v_configobjectkey AND
        s.usageclasscode = @i_usageclasscode AND
        d.orgentrykey IN (SELECT orgentrykey FROM taqprojectorgentry WHERE taqprojectkey = @v_projectkey)
    UNION
    SELECT i.misckey, i.miscname, i.misclabel, i.misctype, i.fieldformat, i.datacode,
        i.taqtotmmind, d.orglevel, d.orgentrykey, 
        CASE WHEN i.misctype=1 THEN d.longvalue ELSE NULL END longvalue,
        CASE WHEN i.misctype=4 THEN d.longvalue ELSE NULL END checkboxvalue, 
        CASE WHEN i.misctype=5 THEN d.longvalue ELSE NULL END dropdownvalue,
        d.floatvalue, d.textvalue, d.datevalue,
        s.usageclasscode, s.columnnumber, s.itemposition, s.updateind, d.orglevel
    FROM bookmiscitems i,   
        bookmiscdefaults d,   
        miscitemsection s
    WHERE d.misckey = i.misckey AND  
        i.misckey = s.misckey AND  
        i.activeind = 1 AND
        s.configobjectkey = @v_configobjectkey AND
        s.usageclasscode = 0 AND
        d.orgentrykey IN (SELECT orgentrykey FROM taqprojectorgentry WHERE taqprojectkey = @v_projectkey) AND
        NOT EXISTS (SELECT * FROM miscitemsection s2, bookmiscdefaults d2
                    WHERE i.misckey = s2.misckey AND 
                        i.misckey = d2.misckey AND
                        i.activeind = 1 AND
                        s2.configobjectkey = @v_configobjectkey AND
                        s2.usageclasscode = @i_usageclasscode AND                      
                        d2.orgentrykey IN (SELECT orgentrykey FROM taqprojectorgentry WHERE taqprojectkey = @v_projectkey))
    ORDER BY i.misckey ASC, d.orglevel DESC
  END
  ELSE BEGIN
    SELECT i.misckey, i.miscname, i.misclabel, i.misctype, i.fieldformat, i.datacode,
        i.taqtotmmind, d.orglevel, d.orgentrykey, 
        CASE WHEN i.misctype=1 THEN d.longvalue ELSE NULL END longvalue,
        CASE WHEN i.misctype=4 THEN d.longvalue ELSE NULL END checkboxvalue, 
        CASE WHEN i.misctype=5 THEN d.longvalue ELSE NULL END dropdownvalue,
        d.floatvalue, d.textvalue, d.datevalue,
        s.usageclasscode, s.columnnumber, s.itemposition, s.updateind, d.orglevel
    FROM bookmiscitems i,   
        bookmiscdefaults d,   
        miscitemsection s
    WHERE d.misckey = i.misckey AND  
        i.misckey = s.misckey AND  
        i.activeind = 1 AND
        s.configobjectkey = @v_configobjectkey AND
        s.usageclasscode = @i_usageclasscode AND
        d.orgentrykey IN (SELECT orgentrykey FROM bookorgentry WHERE bookkey = @v_bookkey)
    UNION
    SELECT i.misckey, i.miscname, i.misclabel, i.misctype, i.fieldformat, i.datacode,
        i.taqtotmmind, d.orglevel, d.orgentrykey, 
        CASE WHEN i.misctype=1 THEN d.longvalue ELSE NULL END longvalue,
        CASE WHEN i.misctype=4 THEN d.longvalue ELSE NULL END checkboxvalue, 
        CASE WHEN i.misctype=5 THEN d.longvalue ELSE NULL END dropdownvalue,
        d.floatvalue, d.textvalue, d.datevalue,
        s.usageclasscode, s.columnnumber, s.itemposition, s.updateind, d.orglevel
    FROM bookmiscitems i,   
        bookmiscdefaults d,   
        miscitemsection s
    WHERE d.misckey = i.misckey AND  
        i.misckey = s.misckey AND  
        i.activeind = 1 AND
        s.configobjectkey = @v_configobjectkey AND
        s.usageclasscode = 0 AND
        d.orgentrykey IN (SELECT orgentrykey FROM bookorgentry WHERE bookkey = @v_bookkey) AND
        NOT EXISTS (SELECT * FROM miscitemsection s2, bookmiscdefaults d2
                    WHERE i.misckey = s2.misckey AND 
                        i.misckey = d2.misckey AND
                        i.activeind = 1 AND
                        s2.configobjectkey = @v_configobjectkey AND
                        s2.usageclasscode = @i_usageclasscode AND                      
                        d2.orgentrykey IN (SELECT orgentrykey FROM bookorgentry WHERE bookkey = @v_bookkey))        
    ORDER BY i.misckey ASC, d.orglevel DESC
  END
  
  -- Save @@ERROR and @@ROWCOUNT values in local variables before they are cleared
  SELECT @v_error = @@ERROR, @v_rowcount = @@ROWCOUNT
  IF @v_error <> 0 BEGIN
    SET @o_error_code = -1
    SET @o_error_desc = 'Could not retrieve Miscellaneous Item Defaults.'
  END 
GO

GRANT EXEC ON qelement_get_miscitems_defaults TO PUBLIC
GO
