if exists (select * from dbo.sysobjects where id = object_id(N'dbo.qtitle_get_miscitems_defaults') and OBJECTPROPERTY(id, N'IsProcedure') = 1)
  drop procedure dbo.qtitle_get_miscitems_defaults
GO

CREATE PROCEDURE qtitle_get_miscitems_defaults
 (@i_bookkey          integer,
  @i_configobjectid   varchar(100),
  @i_usageclasscode   integer,
  @o_error_code       integer output,
  @o_error_desc       varchar(2000) output)
AS

/*************************************************************************************
**  Name: qtitle_get_miscitems_defaults
**  Desc: Returns Miscellaneous Item Defaults
**
**  Auth: Alan Katzen
**  Date: 3/19/07
**
************************************************************************************
**  Change History
************************************************************************************
**  Date:     Author:     Description:
**  -------   ---------   -----------------------------------------------------------
**  6/8/07    Kate        Instead of returning defaults for a list of orgentries,
**                        return defaults for given section and title's orgentries.
**  
**  07/18/14  Kusum Date  Added usageclasscode parameter
**  06/20/16  Kusum		  Case 35718
**************************************************************************************/

  DECLARE
    @v_configobjectkey  INT,
    @v_error  INT,
    @v_rowcount INT
 
  SET @o_error_code = 0
  SET @o_error_desc = ''
  
  CREATE TABLE #miscitemsdefaultsinfo (
    misckey int null,
    miscname VARCHAR(50) null,     
	misclabel VARCHAR(50) null,
	misctype int null,
	fieldformat VARCHAR(40) null,
	datacode INT null,
	sendtoeloquenceind TINYINT null,
	defaultsendtoeloqvalue TINYINT null,
	orglevel INT null,
	orgentrykey INT null,
	longvalue INT null,
	checkboxvalue INT null,
	dropdownvalue INT null,
	floatvalue FLOAT null,
	textvalue VARCHAR(255) null,
	usageclasscode INT null,
	columnnumber SMALLINT null,
	itemposition SMALLINT null,
	updateind TINYINT null,
  datevalue DATETIME null
	 )    
  
  SELECT @v_configobjectkey = configobjectkey
  FROM qsiconfigobjects
  WHERE LOWER(configobjectid) = LOWER(@i_configobjectid)

  -- Save @@ERROR and @@ROWCOUNT values in local variables before they are cleared
  SELECT @v_error = @@ERROR, @v_rowcount = @@ROWCOUNT
  IF @v_error <> 0 or @v_rowcount = 0 BEGIN
    SET @o_error_code = 1
    SET @o_error_desc = 'Counld not determine Web Section (qsiconfigobjects.configobjectid ' + CONVERT(VARCHAR, @i_configobjectid) + ').'
    RETURN
  END
  
  IF @i_usageclasscode > 0 BEGIN 
	  INSERT INTO #miscitemsdefaultsinfo	  
	  SELECT i.misckey, i.miscname, i.misclabel, i.misctype, i.fieldformat, COALESCE(d.datacode,i.datacode) datacode,
		  i.sendtoeloquenceind, i.defaultsendtoeloqvalue, 
		  d.orglevel, d.orgentrykey, 
		  CASE WHEN i.misctype=1 THEN d.longvalue ELSE NULL END longvalue,
		  CASE WHEN i.misctype=4 THEN d.longvalue ELSE NULL END checkboxvalue, 
		  CASE WHEN i.misctype=5 THEN d.longvalue ELSE NULL END dropdownvalue,
		  d.floatvalue, d.textvalue,
		  s.usageclasscode, s.columnnumber, s.itemposition, s.updateind, d.datevalue
	  FROM bookmiscitems i join miscitemsection s  on 
				i.misckey = s.misckey    
			left outer JOIN bookmiscdefaults d on 
				d.misckey = i.misckey AND
		  d.orgentrykey IN (SELECT orgentrykey FROM bookorgentry WHERE bookkey = @i_bookkey)			
	  WHERE i.activeind = 1 AND
	        coalesce(i.copymiscitemind,0) = 0 AND
		  s.configobjectkey = @v_configobjectkey 
		  AND s.usageclasscode = @i_usageclasscode  
	  ORDER BY i.misckey ASC, d.orglevel DESC
	  
	  SELECT @v_error = @@ERROR, @v_rowcount = @@ROWCOUNT
	  IF @v_error <> 0 BEGIN
		SET @o_error_code = -1
		SET @o_error_desc = 'Could not retrieve Miscellaneous Item Defaults.'
	  END   
  END  

  INSERT INTO #miscitemsdefaultsinfo	
  SELECT i.misckey, i.miscname, i.misclabel, i.misctype, i.fieldformat, COALESCE(d.datacode,i.datacode) datacode,
      i.sendtoeloquenceind, i.defaultsendtoeloqvalue, 
      d.orglevel, d.orgentrykey, 
      CASE WHEN i.misctype=1 THEN d.longvalue ELSE NULL END longvalue,
      CASE WHEN i.misctype=4 THEN d.longvalue ELSE NULL END checkboxvalue, 
      CASE WHEN i.misctype=5 THEN d.longvalue ELSE NULL END dropdownvalue,
      d.floatvalue, d.textvalue,
      s.usageclasscode, s.columnnumber, s.itemposition, s.updateind, d.datevalue
  FROM bookmiscitems i INNER join miscitemsection s  on 
			i.misckey = s.misckey    
	    left outer JOIN bookmiscdefaults d on 
			d.misckey = i.misckey AND
      d.orgentrykey IN (SELECT orgentrykey FROM bookorgentry WHERE bookkey = @i_bookkey)
       left outer JOIN #miscitemsdefaultsinfo t on
			t.misckey = i.misckey and t.orgentrykey = d.orgentrykey 			
  WHERE i.activeind = 1 AND
        coalesce(i.copymiscitemind,0) = 0 AND
      s.configobjectkey = @v_configobjectkey 
      AND s.usageclasscode = 0  
      AND t.misckey IS NULL      
  ORDER BY i.misckey ASC, d.orglevel DESC

  -- Save @@ERROR and @@ROWCOUNT values in local variables before they are cleared
  SELECT @v_error = @@ERROR, @v_rowcount = @@ROWCOUNT
  IF @v_error <> 0 BEGIN
    SET @o_error_code = -1
    SET @o_error_desc = 'Could not retrieve Miscellaneous Item Defaults.'
  END 
  
  SELECT * FROM #miscitemsdefaultsinfo  ORDER BY misckey ASC, orglevel DESC
  
  -- Save @@ERROR and @@ROWCOUNT values in local variables before they are cleared
  SELECT @v_error = @@ERROR, @v_rowcount = @@ROWCOUNT
  IF @v_error <> 0 BEGIN
    SET @o_error_code = -1
    SET @o_error_desc = 'Could not retrieve Miscellaneous Item Defaults.'
  END 

  DROP TABLE #miscitemsdefaultsinfo    
GO

GRANT EXEC ON qtitle_get_miscitems_defaults TO PUBLIC
GO
