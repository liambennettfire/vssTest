if exists (select * from dbo.sysobjects where id = object_id(N'dbo.qcontact_get_miscitems_by_section') and OBJECTPROPERTY(id, N'IsProcedure') = 1)
  drop procedure dbo.qcontact_get_miscitems_by_section
GO

CREATE PROCEDURE qcontact_get_miscitems_by_section
 (@i_contactkey       integer,
  @i_configobjectid   varchar(100),
  @i_usageclasscode   integer,
  @o_error_code       integer output,
  @o_error_desc       varchar(2000) output)
AS

/*************************************************************************************
**  Name: qcontact_get_miscitems_by_section
**  Desc: Returns Contact Miscellaneous Item information for given globalcontact,
**        section (configobjectkey) and usage class.
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
    RETURN
  END
               
  SELECT s.usageclasscode, s.columnnumber, s.itemposition, s.updateind,
      i.misckey, i.miscname, i.misclabel, i.misctype, i.fieldformat, i.datacode,
      i.taqtotmmind, i.sendtoeloquenceind item_sendtoeloquenceind, 0 newrowind,
      CASE WHEN i.misctype=1 THEN p.longvalue ELSE NULL END longvalue,
      CASE WHEN i.misctype=4 THEN p.longvalue ELSE NULL END checkboxvalue, 
      CASE WHEN i.misctype=5 THEN p.longvalue ELSE NULL END dropdownvalue,
      p.floatvalue, p.textvalue, COALESCE(p.sendtoeloquenceind,0) sendtoeloquenceind
  FROM miscitemsection s, bookmiscitems i, globalcontactmisc p
  WHERE s.misckey = i.misckey AND 
      i.misckey = p.misckey AND
      i.activeind = 1 AND
      p.globalcontactkey = @i_contactkey AND
      s.configobjectkey = @v_configobjectkey AND 
      s.usageclasscode = @i_usageclasscode
  UNION
  SELECT s.usageclasscode, s.columnnumber, s.itemposition, s.updateind,
      i.misckey, i.miscname, i.misclabel, i.misctype, i.fieldformat, i.datacode,
      i.taqtotmmind, i.sendtoeloquenceind item_sendtoeloquenceind, 0 newrowind,
      CASE WHEN i.misctype=1 THEN p.longvalue ELSE NULL END longvalue,
      CASE WHEN i.misctype=4 THEN p.longvalue ELSE NULL END checkboxvalue, 
      CASE WHEN i.misctype=5 THEN p.longvalue ELSE NULL END dropdownvalue,
      p.floatvalue, p.textvalue, COALESCE(p.sendtoeloquenceind,0) sendtoeloquenceind
  FROM miscitemsection s, bookmiscitems i, globalcontactmisc p
  WHERE s.misckey = i.misckey AND 
      i.misckey = p.misckey AND
      i.activeind = 1 AND
      p.globalcontactkey = @i_contactkey AND
      s.configobjectkey = @v_configobjectkey AND 
      s.usageclasscode = 0 AND
      NOT EXISTS (SELECT * FROM miscitemsection s2, globalcontactmisc p2
                  WHERE i.misckey = s2.misckey AND 
                      i.misckey = p2.misckey AND
                      i.activeind = 1 AND
                      p2.globalcontactkey = @i_contactkey AND
                      s2.configobjectkey = @v_configobjectkey AND
                      s2.usageclasscode = @i_usageclasscode)      
  ORDER BY s.columnnumber, s.itemposition

  -- Save @@ERROR and @@ROWCOUNT values in local variables before they are cleared
  SELECT @v_error = @@ERROR, @v_rowcount = @@ROWCOUNT
  IF @v_error <> 0 or @v_rowcount = 0 BEGIN
    SET @o_error_code = 1
    SET @o_error_desc = 'Could not retrieve Project Miscellaneous Items (globalcontactkey=' + CONVERT(VARCHAR, @i_contactkey) + ', configobjectkey=' + CONVERT(VARCHAR, @v_configobjectkey) + ').'
  END 
GO

GRANT EXEC ON qcontact_get_miscitems_by_section TO PUBLIC
GO
