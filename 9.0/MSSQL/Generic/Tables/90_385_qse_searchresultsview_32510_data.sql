-- setup default search result views
DECLARE 
  @new_resultsviewkey int,
  @v_itemtype int,
  @v_usageclass int,
  @v_searchtypecode int

BEGIN  

  -- contract
  SET @v_searchtypecode = 29  -- WEB WEB Purchase Orders - tableid 442
  SET @v_itemtype = 15
  SET @v_usageclass = 0      -- all usageclasses
  --SELECT @v_usageclassdesc = COALESCE(dbo.get_subgentables_desc(550,@v_itemtype,@v_usageclass,'long'),' ')

  exec get_next_key 'qsidba', @new_resultsviewkey output

  insert into qse_searchresultsview(resultsviewkey,resultsviewname,resultsviewdesc,searchtypecode,
                                   itemtypecode,usageclasscode,userkey,defaultind,lastuserid,lastmaintdate) 
  values (@new_resultsviewkey,'Default PO Search Results', 'Default PO Search Results',@v_searchtypecode,
          @v_itemtype,@v_usageclass,-1,1,'INITDATA',getdate())

  -- default layout for printings
  insert into qse_searchresultsviewlayout (resultsviewkey,columnnumber,columnorder,columnwidth,lastuserid,lastmaintdate)
  select @new_resultsviewkey,columnnumber,websortorder,defaultwidth,'INITDATA',getdate()
    from qse_searchresultscolumns
   where searchtypecode = @v_searchtypecode
     and searchitemcode = @v_itemtype 
     and displayind = 1  
     and usageclasscode = 0   
     
  
END  
go
     