if exists (select * from dbo.sysobjects where id = object_id(N'dbo.qtitle_get_miscitems_by_section') and OBJECTPROPERTY(id, N'IsProcedure') = 1)
  drop procedure dbo.qtitle_get_miscitems_by_section
GO

CREATE PROCEDURE qtitle_get_miscitems_by_section
 (@i_bookkey          integer,
  @i_configobjectid   varchar(100),
  @i_usageclasscode   integer,
  @o_error_code       integer output,
  @o_error_desc       varchar(2000) output)
AS

/*************************************************************************************
**  Name: qtitle_get_miscitems_by_section
**  Desc: Returns Title Miscellaneous Item information for given title
**        and section (configobjectkey).
**
**  Auth: Kate
**  Date: 2/27/07
**  
**  Changed by: Kusum Date 07/18/14 Added usageclasscode parameter
**************************************************************************************/

  DECLARE
    @v_configobjectkey  INT,
    @v_error  INT,
    @v_rowcount INT
 
  SET @o_error_code = 0
  SET @o_error_desc = ''
  
  CREATE TABLE #miscitemssectioninfo (
	usageclasscode INT null,
	columnnumber SMALLINT null,
	itemposition SMALLINT null,
	updateind TINYINT null,  
    misckey int null,
    miscname VARCHAR(50) null,     
	misclabel VARCHAR(50) null,
	misctype int null,
	fieldformat VARCHAR(40) null,
	datacode INT null,
	item_sendtoeloquenceind TINYINT null,
	newrowind INT,
	longvalue INT null,
	checkboxvalue INT null,
	dropdownvalue INT null,
	floatvalue FLOAT null,
	textvalue VARCHAR(4000) null,	
  sendtoeloquenceind TINYINT null,
	datevalue DATETIME null
	 )       
  
  -- There is typically more than one row in qsiconfigobjects with a configobjectid of 'shTitleInfo', 
  -- we have to assume we want the one associated with the TitleSummary window
  IF LOWER(@i_configobjectid) = 'shtitleinfo' BEGIN
    SELECT @v_configobjectkey = o.configobjectkey
    FROM qsiconfigobjects o, qsiwindows w
    WHERE LOWER(configobjectid) = LOWER(@i_configobjectid) AND LOWER(w.windowname) = 'titlesummary' AND o.windowid = w.windowid
  END ELSE BEGIN
    SELECT @v_configobjectkey = configobjectkey
    FROM qsiconfigobjects
    WHERE LOWER(configobjectid) = LOWER(@i_configobjectid)
  END

  -- Save @@ERROR and @@ROWCOUNT values in local variables before they are cleared
  SELECT @v_error = @@ERROR, @v_rowcount = @@ROWCOUNT
  IF @v_error <> 0 or @v_rowcount = 0 BEGIN
    SET @o_error_code = 1
    SET @o_error_desc = 'Counld not determine Web Section (qsiconfigobjects.configobjectid ' + CONVERT(VARCHAR, @i_configobjectid) + ').'
    RETURN
  END
  
  IF @i_usageclasscode > 0 BEGIN 
  	  INSERT INTO #miscitemssectioninfo	
	  SELECT s.usageclasscode, s.columnnumber, s.itemposition, s.updateind,
		  i.misckey, i.miscname, i.misclabel, i.misctype, i.fieldformat, i.datacode,
		  i.sendtoeloquenceind item_sendtoeloquenceind, 0 newrowind,
		  CASE WHEN i.misctype=1 THEN b.longvalue ELSE NULL END longvalue,
		  CASE WHEN i.misctype=4 THEN b.longvalue ELSE NULL END checkboxvalue, 
		  CASE WHEN i.misctype=5 THEN b.longvalue ELSE NULL END dropdownvalue,
		  b.floatvalue, b.textvalue, COALESCE(b.sendtoeloquenceind,0) sendtoeloquenceind, b.datevalue
	  FROM miscitemsection s, bookmiscitems i, bookmisc b
	  WHERE s.misckey = i.misckey AND 
		  i.misckey = b.misckey AND
		  b.bookkey = @i_bookkey AND
		  s.configobjectkey = @v_configobjectkey AND 
		  i.activeind = 1 AND
		  s.usageclasscode = @i_usageclasscode   
	  ORDER BY s.columnnumber, s.itemposition   
  END
  
  INSERT INTO #miscitemssectioninfo	  
  SELECT s.usageclasscode, s.columnnumber, s.itemposition, s.updateind,
      i.misckey, i.miscname, i.misclabel, i.misctype, i.fieldformat, i.datacode,
      i.sendtoeloquenceind item_sendtoeloquenceind, 0 newrowind,
      CASE WHEN i.misctype=1 THEN b.longvalue ELSE NULL END longvalue,
      CASE WHEN i.misctype=4 THEN b.longvalue ELSE NULL END checkboxvalue, 
      CASE WHEN i.misctype=5 THEN b.longvalue ELSE NULL END dropdownvalue,
      b.floatvalue, b.textvalue, COALESCE(b.sendtoeloquenceind,0) sendtoeloquenceind, b.datevalue
  FROM miscitemsection s 
      INNER JOIN bookmiscitems i
		ON s.misckey = i.misckey
      INNER JOIN bookmisc b 
		ON i.misckey = b.misckey
	  LEFT OUTER JOIN #miscitemssectioninfo	t ON t.misckey = i.misckey
  WHERE 
      b.bookkey = @i_bookkey AND
      s.configobjectkey = @v_configobjectkey AND 
      i.activeind = 1 AND
      s.usageclasscode = 0 AND
      t.misckey IS NULL      
  ORDER BY s.columnnumber, s.itemposition 

  SELECT @v_error = @@ERROR
  IF @v_error <> 0 BEGIN
    SET @o_error_code = 1
    SET @o_error_desc = 'Could not retrieve Title Miscellaneous Items (bookkey=' + CONVERT(VARCHAR, @i_bookkey) + ', configobjectkey=' + CONVERT(VARCHAR, @v_configobjectkey) + ').'
  END 
  
  SELECT * FROM #miscitemssectioninfo  ORDER BY columnnumber, itemposition 
  
  -- Save @@ERROR and @@ROWCOUNT values in local variables before they are cleared
  SELECT @v_error = @@ERROR, @v_rowcount = @@ROWCOUNT
  IF @v_error <> 0 BEGIN
    SET @o_error_code = -1
    SET @o_error_desc = 'Could not retrieve Title Miscellaneous Items (bookkey=' + CONVERT(VARCHAR, @i_bookkey) + ', configobjectkey=' + CONVERT(VARCHAR, @v_configobjectkey) + ').'
  END   
  
  DROP TABLE #miscitemssectioninfo  
GO

GRANT EXEC ON qtitle_get_miscitems_by_section TO PUBLIC
GO
