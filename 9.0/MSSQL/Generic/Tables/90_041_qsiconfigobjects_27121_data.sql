-- Printing Participants

DECLARE @v_maxid		int,
        @v_windowid     int,
        @v_itemtypecode int

begin
  select @v_itemtypecode = 14  -- Printings

 -- Printing Participants
  select @v_windowid = windowid from qsiwindows where lower(windowname) = 'PrintingParticipants'  

  exec dbo.get_next_key 'FBT',@v_maxid out  
  INSERT INTO qsiconfigobjects (configobjectkey,windowid,configobjectid,configobjectdesc,defaultlabeldesc,
                                lastuserid,lastmaintdate,defaultvisibleind,defaultminimizedind,itemtypecode,
                                miscsectionind,path,viewcontrolname,editcontrolname,position)
  VALUES (@v_maxid,@v_windowid,'PrintingParticipants','Printing Participants','Printing Participants','QSIDBA', 
          getdate(),1,0,@v_itemtypecode,0,null,null,null,null)

  exec dbo.get_next_key 'FBT',@v_maxid out  
  INSERT INTO qsiconfigobjects (configobjectkey,windowid,configobjectid,configobjectdesc,defaultlabeldesc,
                                lastuserid,lastmaintdate,defaultvisibleind,defaultminimizedind,itemtypecode,
                                miscsectionind,path,viewcontrolname,editcontrolname,position)
  VALUES (@v_maxid,@v_windowid,'shProjectSummary','Summary','Summary','QSIDBA', 
          getdate(),1,0,@v_itemtypecode,0,null,null,null,null)

  exec dbo.get_next_key 'FBT',@v_maxid out  
  INSERT INTO qsiconfigobjects (configobjectkey,windowid,configobjectid,configobjectdesc,defaultlabeldesc,
                                lastuserid,lastmaintdate,defaultvisibleind,defaultminimizedind,itemtypecode,
                                miscsectionind,path,viewcontrolname,editcontrolname,position)
  VALUES (@v_maxid,@v_windowid,'shParticipantSummary','Participant Summary','Participant Summary','QSIDBA', 
          getdate(),1,0,@v_itemtypecode,0,null,null,null,null)

  exec dbo.get_next_key 'FBT',@v_maxid out  
  INSERT INTO qsiconfigobjects (configobjectkey,windowid,configobjectid,configobjectdesc,defaultlabeldesc,
                                lastuserid,lastmaintdate,defaultvisibleind,defaultminimizedind,itemtypecode,
                                miscsectionind,path,viewcontrolname,editcontrolname,position)
  VALUES (@v_maxid,@v_windowid,'shParticipantDetail','Contact Detail','Contact Detail','QSIDBA', 
          getdate(),1,0,@v_itemtypecode,0,null,null,null,null)

  exec dbo.get_next_key 'FBT',@v_maxid out  
  INSERT INTO qsiconfigobjects (configobjectkey,windowid,configobjectid,configobjectdesc,defaultlabeldesc,
                                lastuserid,lastmaintdate,defaultvisibleind,defaultminimizedind,itemtypecode,
                                miscsectionind,path,viewcontrolname,editcontrolname,position)
  VALUES (@v_maxid,@v_windowid,'shParticipantRoles','Participant Roles','Participant Roles','QSIDBA', 
          getdate(),1,0,@v_itemtypecode,0,null,null,null,null)

  exec dbo.get_next_key 'FBT',@v_maxid out  
  INSERT INTO qsiconfigobjects (configobjectkey,windowid,configobjectid,configobjectdesc,defaultlabeldesc,
                                lastuserid,lastmaintdate,defaultvisibleind,defaultminimizedind,itemtypecode,
                                miscsectionind,path,viewcontrolname,editcontrolname,position)
  VALUES (@v_maxid,@v_windowid,'shParticipantNotes','Participant Notes','Participant Notes','QSIDBA', 
          getdate(),1,0,@v_itemtypecode,0,null,null,null,null)

end  
