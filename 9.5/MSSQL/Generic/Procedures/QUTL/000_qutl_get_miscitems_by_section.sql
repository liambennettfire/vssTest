if exists (select * from dbo.sysobjects where id = object_id(N'dbo.qutl_get_miscitems_by_section') and OBJECTPROPERTY(id, N'IsProcedure') = 1)
  drop procedure dbo.qutl_get_miscitems_by_section
GO

CREATE PROCEDURE qutl_get_miscitems_by_section
 (@i_configobjectid   varchar(100),
  @i_usageclasscode   integer,
  @o_error_code       integer output,
  @o_error_desc       varchar(2000) output)
AS

/*************************************************************************************
**  Name: qutl_get_miscitems_by_section
**  Desc: Returns all Miscellaneous Items for given section (configobjectkey).
**
**  Auth: Kate
**  Date: 6/11/07
**************************************************************************************/

  DECLARE
    @v_configobjectkey  INT,
    @v_error  INT,
    @v_rowcount INT
 
  SET @o_error_code = 0
  SET @o_error_desc = ''
  
  CREATE TABLE #miscitemssectioninfo (
    misckey int null,
    miscname VARCHAR(50) null,     
	misclabel VARCHAR(50) null,
	misctype int null,
	fieldformat VARCHAR(40) null,
	datacode INT null,
	sendtoeloquenceind TINYINT null,
	defaultsendtoeloqvalue TINYINT null,
	taqtotmmind TINYINT null,
	searchurl VARCHAR(2000) null,
	usageclasscode INT null,
	columnnumber SMALLINT null,
	itemposition SMALLINT null,
	updateind TINYINT null
	 )     
  
  SELECT TOP(1) @v_configobjectkey = configobjectkey
  FROM qsiconfigobjects
  WHERE LOWER(configobjectid) = LOWER(@i_configobjectid)

  -- Save @@ERROR and @@ROWCOUNT values in local variables before they are cleared
  SELECT @v_error = @@ERROR, @v_rowcount = @@ROWCOUNT
  IF @v_error <> 0 or @v_rowcount = 0 BEGIN
    SET @o_error_code = 1
    SET @o_error_desc = 'Could not determine Web Section (qsiconfigobjects.configobjectid ' + CONVERT(VARCHAR, @i_configobjectid) + ').'
  END

  IF @i_usageclasscode > 0 BEGIN 
	  INSERT INTO #miscitemssectioninfo	  
	  SELECT i.misckey, i.miscname, i.misclabel, i.misctype, i.fieldformat, i.datacode, 
		  i.sendtoeloquenceind, i.defaultsendtoeloqvalue, i.taqtotmmind, i.searchurl,
		  s.usageclasscode, s.columnnumber, s.itemposition, s.updateind
	  FROM bookmiscitems i,   
		  miscitemsection s 
	  WHERE i.misckey = s.misckey AND
		  i.activeind = 1 AND
		  s.configobjectkey = @v_configobjectkey AND
		  s.usageclasscode = @i_usageclasscode
	  UNION
	  SELECT i.misckey, i.miscname, i.misclabel, i.misctype, i.fieldformat, i.datacode, 
		  i.sendtoeloquenceind, i.defaultsendtoeloqvalue, i.taqtotmmind, i.searchurl,
		  s.usageclasscode, s.columnnumber, s.itemposition, s.updateind
	  FROM bookmiscitems i,   
		  miscitemsection s 
	  WHERE i.misckey = s.misckey AND
		  i.activeind = 1 AND
		  s.configobjectkey = @v_configobjectkey AND
		  s.usageclasscode = 0 AND      
		  NOT EXISTS (SELECT * FROM miscitemsection s2 
					  WHERE i.misckey = s2.misckey AND
						  i.activeind = 1 AND
						  s2.configobjectkey = @v_configobjectkey AND
						  s2.usageclasscode = @i_usageclasscode)	  
						  
	  SELECT @v_error = @@ERROR
	  IF @v_error <> 0 BEGIN
		SET @o_error_code = 1
		SET @o_error_desc = 'Could not retrieve Miscellaneous Items (configobjectkey=' + CONVERT(VARCHAR, @v_configobjectkey) + ').'
	  END 						  
  END
  
  INSERT INTO #miscitemssectioninfo	  
  SELECT i.misckey, i.miscname, i.misclabel, i.misctype, i.fieldformat, i.datacode, 
      i.sendtoeloquenceind, i.defaultsendtoeloqvalue, i.taqtotmmind, i.searchurl,
      s.usageclasscode, s.columnnumber, s.itemposition, s.updateind
  FROM bookmiscitems i,   
      miscitemsection s 
  WHERE i.misckey = s.misckey AND
      i.activeind = 1 AND
      s.configobjectkey = @v_configobjectkey AND
      s.usageclasscode = 0
      AND NOT EXISTS(SELECT * FROM #miscitemssectioninfo t WHERE t.misckey = i.misckey)        
  UNION
  SELECT i.misckey, i.miscname, i.misclabel, i.misctype, i.fieldformat, i.datacode, 
      i.sendtoeloquenceind, i.defaultsendtoeloqvalue, i.taqtotmmind, i.searchurl,
      s.usageclasscode, s.columnnumber, s.itemposition, s.updateind
  FROM bookmiscitems i,   
      miscitemsection s 
  WHERE i.misckey = s.misckey AND
      i.activeind = 1 AND
      s.configobjectkey = @v_configobjectkey AND
      s.usageclasscode = 0 AND      
      NOT EXISTS (SELECT * FROM miscitemsection s2 
                  WHERE i.misckey = s2.misckey AND
                      i.activeind = 1 AND
                      s2.configobjectkey = @v_configobjectkey AND
                      s2.usageclasscode = 0)
      AND NOT EXISTS(SELECT * FROM #miscitemssectioninfo t WHERE t.misckey = i.misckey)                         
                      
  SELECT @v_error = @@ERROR
  IF @v_error <> 0 BEGIN
    SET @o_error_code = 1
    SET @o_error_desc = 'Could not retrieve Miscellaneous Items (configobjectkey=' + CONVERT(VARCHAR, @v_configobjectkey) + ').'
  END 
  
  SELECT * FROM #miscitemssectioninfo
  SELECT @v_error = @@ERROR
  IF @v_error <> 0 BEGIN
    SET @o_error_code = 1
    SET @o_error_desc = 'Could not retrieve Miscellaneous Items (configobjectkey=' + CONVERT(VARCHAR, @v_configobjectkey) + ').'
  END   
  
  DROP TABLE #miscitemssectioninfo  
GO

GRANT EXEC ON qutl_get_miscitems_by_section TO PUBLIC
GO
