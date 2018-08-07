-- setup default search result views
DECLARE 
  @v_resultsviewkey int,
  @v_itemtype int,
  @v_usageclass int,
  @v_searchtypecode int

BEGIN  

  -- Printing
  SET @v_searchtypecode = 28  -- WEB Printings - tableid 442
  SET @v_itemtype = 14
  SET @v_usageclass = 0      -- all usageclasses
  
  DECLARE searchresultsview_cur CURSOR FOR
	  SELECT resultsviewkey FROM qse_searchresultsview 
	  WHERE searchtypecode = @v_searchtypecode AND itemtypecode = @v_itemtype AND usageclasscode = 0
	  OPEN searchresultsview_cur

  FETCH NEXT FROM searchresultsview_cur INTO @v_resultsviewkey

  WHILE (@@FETCH_STATUS = 0) 
  BEGIN
	  INSERT INTO qse_searchresultsviewlayout (resultsviewkey,columnnumber,columnorder,columnwidth,lastuserid,lastmaintdate)
	  SELECT @v_resultsviewkey,columnnumber,websortorder,defaultwidth,'INITDATA',getdate()
		FROM qse_searchresultscolumns
	   WHERE searchtypecode = @v_searchtypecode
		 AND searchitemcode = @v_itemtype 
		 AND displayind = 1  
		 AND usageclasscode = 0   
		 AND columnnumber IN (11, 12)        		
	FETCH NEXT FROM searchresultsview_cur INTO @v_resultsviewkey
  END

  CLOSE searchresultsview_cur 
  DEALLOCATE searchresultsview_cur  
  
END  
go
     