if exists (select * from dbo.sysobjects where id = object_id(N'dbo.qcontact_get_miscitems_defaults') and OBJECTPROPERTY(id, N'IsProcedure') = 1)
  drop procedure dbo.qcontact_get_miscitems_defaults
GO

CREATE PROCEDURE qcontact_get_miscitems_defaults
 (@i_contactkey       integer,
  @i_configobjectid   varchar(100),
  @i_usageclasscode   integer,
  @o_error_code       integer output,
  @o_error_desc       varchar(2000) output)
AS

/*************************************************************************************
**  Name: qcontact_get_miscitems_defaults
**  Desc: Returns Miscellaneous Item Defaults for given web section 
**        and contact's orgentries.
**
**  Auth: Alan Katzen
**  Date: 5/4/2011
**************************************************************************************/

  DECLARE
    @v_configobjectkey  INT,
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
  END
    
  SELECT i.misckey, i.miscname, i.misclabel, i.misctype, i.fieldformat, i.datacode,
      i.taqtotmmind, i.sendtoeloquenceind, i.defaultsendtoeloqvalue, d.orglevel, d.orgentrykey, 
      CASE WHEN i.misctype=1 THEN d.longvalue ELSE NULL END longvalue,
      CASE WHEN i.misctype=4 THEN d.longvalue ELSE NULL END checkboxvalue, 
      CASE WHEN i.misctype=5 THEN d.longvalue ELSE NULL END dropdownvalue,
      d.floatvalue, d.textvalue,
      s.usageclasscode, s.columnnumber, s.itemposition, s.updateind, d.orglevel
  FROM bookmiscitems i   
  INNER JOIN miscitemsection s
  ON i.misckey = s.misckey
  LEFT OUTER JOIN bookmiscdefaults d
  ON d.misckey = i.misckey AND  d.orgentrykey IN (SELECT orgentrykey FROM globalcontactorgentry WHERE globalcontactkey = @i_contactkey)
  WHERE 
      i.activeind = 1 AND
      s.configobjectkey = @v_configobjectkey AND
      s.usageclasscode = @i_usageclasscode
  UNION
  SELECT i.misckey, i.miscname, i.misclabel, i.misctype, i.fieldformat, i.datacode,
      i.taqtotmmind, i.sendtoeloquenceind, i.defaultsendtoeloqvalue, d.orglevel, d.orgentrykey, 
      CASE WHEN i.misctype=1 THEN d.longvalue ELSE NULL END longvalue,
      CASE WHEN i.misctype=4 THEN d.longvalue ELSE NULL END checkboxvalue, 
      CASE WHEN i.misctype=5 THEN d.longvalue ELSE NULL END dropdownvalue,
      d.floatvalue, d.textvalue,
      s.usageclasscode, s.columnnumber, s.itemposition, s.updateind, d.orglevel
  FROM bookmiscitems i   
  INNER JOIN miscitemsection s
  ON i.misckey = s.misckey
  LEFT OUTER JOIN bookmiscdefaults d
  ON d.misckey = i.misckey AND  d.orgentrykey IN (SELECT orgentrykey FROM globalcontactorgentry WHERE globalcontactkey = @i_contactkey)
  WHERE 
      i.activeind = 1 AND
      s.configobjectkey = @v_configobjectkey AND
      s.usageclasscode = 0
  AND
   NOT EXISTS (SELECT * FROM bookmiscitems i2 INNER JOIN miscitemsection s2 
               ON i2.misckey = s2.misckey
               LEFT OUTER JOIN bookmiscdefaults d2
               ON i2.misckey = d2.misckey
               AND d2.orgentrykey IN (SELECT orgentrykey FROM globalcontactorgentry WHERE globalcontactkey = @i_contactkey)
               WHERE 
               i2.activeind = 1 AND
               s2.configobjectkey = @v_configobjectkey AND
               s2.usageclasscode = @i_usageclasscode)
  ORDER BY i.misckey ASC, d.orglevel DESC

  -- Save @@ERROR and @@ROWCOUNT values in local variables before they are cleared
  SELECT @v_error = @@ERROR, @v_rowcount = @@ROWCOUNT
  IF @v_error <> 0 BEGIN
    SET @o_error_code = -1
    SET @o_error_desc = 'Could not retrieve Miscellaneous Item Defaults.'
  END 
GO

GRANT EXEC ON qcontact_get_miscitems_defaults TO PUBLIC
GO
