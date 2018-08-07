/******************************************************************************************
**  Executes the relationship tab procedure
**  MKTG PROJECTS, EXHIBITS, CAMPAIGNS and PLANS
**  Created 2/5/2016 SLB
*******************************************************************************************/

BEGIN

  DECLARE
  @v_datacode   integer,
  @v_error_code		 integer,
  @v_error_desc		 varchar(2000) 



  SET @v_datacode = 0
  SET @v_error_code = 0
  SET @v_error_desc	= ' '

 exec @v_datacode = qutl_get_gentables_datacode 583, 15,'Titles (Projects)'	IF @v_datacode =  0  print 'There is no datacode found for datadesc = ' + 'Titles (Projects)' 	UPDATE gentables_ext SET  gentext2 = 'far fa-book' WHERE tableid = 583  and datacode = @v_datacode
exec @v_datacode = qutl_get_gentables_datacode 583, 16,'Formats'	IF @v_datacode =  0  print 'There is no datacode found for datadesc = ' + 'Formats' 	UPDATE gentables_ext SET  gentext2 = 'far fa-book' WHERE tableid = 583  and datacode = @v_datacode
exec @v_datacode = qutl_get_gentables_datacode 583, 17,'Formats of Work'	IF @v_datacode =  0  print 'There is no datacode found for datadesc = ' + 'Formats of Work' 	UPDATE gentables_ext SET  gentext2 = 'far fa-book' WHERE tableid = 583  and datacode = @v_datacode
 	 	 
exec @v_datacode = qutl_get_gentables_datacode 583, 21,'Titles Requested (Contacts)'	IF @v_datacode =  0  print 'There is no datacode found for datadesc = ' + 'Titles Requested (Contacts)' 	UPDATE gentables_ext SET  gentext2 = 'far fa-book' WHERE tableid = 583  and datacode = @v_datacode
exec @v_datacode = qutl_get_gentables_datacode 583, 22,'Contacts Receiving Copies'	IF @v_datacode =  0  print 'There is no datacode found for datadesc = ' + 'Contacts Receiving Copies' 	UPDATE gentables_ext SET  gentext2 = 'fas fa-user' WHERE tableid = 583  and datacode = @v_datacode
exec @v_datacode = qutl_get_gentables_datacode 583, 23,'Works'	IF @v_datacode =  0  print 'There is no datacode found for datadesc = ' + 'Works' 	UPDATE gentables_ext SET  gentext2 = 'far fa-archive' WHERE tableid = 583  and datacode = @v_datacode
exec @v_datacode = qutl_get_gentables_datacode 583, 24,'Titles (Contracts)'	IF @v_datacode =  0  print 'There is no datacode found for datadesc = ' + 'Titles (Contracts)' 	UPDATE gentables_ext SET  gentext2 = 'far fa-book' WHERE tableid = 583  and datacode = @v_datacode
exec @v_datacode = qutl_get_gentables_datacode 583, 25,'Contracts'	IF @v_datacode =  0  print 'There is no datacode found for datadesc = ' + 'Contracts' 	UPDATE gentables_ext SET  gentext2 = 'Contracts.svg' WHERE tableid = 583  and datacode = @v_datacode
exec @v_datacode = qutl_get_gentables_datacode 583, 26,'Contracts (Titles)'	IF @v_datacode =  0  print 'There is no datacode found for datadesc = ' + 'Contracts (Titles)' 	UPDATE gentables_ext SET  gentext2 = 'Contracts.svg' WHERE tableid = 583  and datacode = @v_datacode
exec @v_datacode = qutl_get_gentables_datacode 583, 27,'Contracts (Contacts)'	IF @v_datacode =  0  print 'There is no datacode found for datadesc = ' + 'Contracts (Contacts)' 	UPDATE gentables_ext SET  gentext2 = 'Contracts.svg' WHERE tableid = 583  and datacode = @v_datacode
exec @v_datacode = qutl_get_gentables_datacode 583, 29,'Additional P&L'	IF @v_datacode =  0  print 'There is no datacode found for datadesc = ' + 'Additional P&L' 	UPDATE gentables_ext SET  gentext2 = 'far fa-chart-line' WHERE tableid = 583  and datacode = @v_datacode
exec @v_datacode = qutl_get_gentables_datacode 583, 30,'Primary P&L'	IF @v_datacode =  0  print 'There is no datacode found for datadesc = ' + 'Primary P&L' 	UPDATE gentables_ext SET  gentext2 = 'far fa-chart-line' WHERE tableid = 583  and datacode = @v_datacode
exec @v_datacode = qutl_get_gentables_datacode 583, 31,'Printings (on Titles)'	IF @v_datacode =  0  print 'There is no datacode found for datadesc = ' + 'Printings (on Titles)' 	UPDATE gentables_ext SET  gentext2 = 'Printings.svg' WHERE tableid = 583  and datacode = @v_datacode
exec @v_datacode = qutl_get_gentables_datacode 583, 32,'Purchase Orders (on Printings)'	IF @v_datacode =  0  print 'There is no datacode found for datadesc = ' + 'Purchase Orders (on Printings)' 	UPDATE gentables_ext SET  gentext2 = 'PurchaseOrders.svg' WHERE tableid = 583  and datacode = @v_datacode
exec @v_datacode = qutl_get_gentables_datacode 583, 33,'Printings (on Purchase Orders)'	IF @v_datacode =  0  print 'There is no datacode found for datadesc = ' + 'Printings (on Purchase Orders)' 	UPDATE gentables_ext SET  gentext2 = 'Printings.svg' WHERE tableid = 583  and datacode = @v_datacode
exec @v_datacode = qutl_get_gentables_datacode 583, 34,'Purchase Orders (on PO Reports)'	IF @v_datacode =  0  print 'There is no datacode found for datadesc = ' + 'Purchase Orders (on PO Reports)' 	UPDATE gentables_ext SET  gentext2 = 'PurchaseOrders.svg' WHERE tableid = 583  and datacode = @v_datacode
exec @v_datacode = qutl_get_gentables_datacode 583, 35,'PO Reports'	IF @v_datacode =  0  print 'There is no datacode found for datadesc = ' + 'PO Reports' 	UPDATE gentables_ext SET  gentext2 = 'PurchaseOrders.svg' WHERE tableid = 583  and datacode = @v_datacode
exec @v_datacode = qutl_get_gentables_datacode 583, 36,'Printings (on PO Reports)'	IF @v_datacode =  0  print 'There is no datacode found for datadesc = ' + 'Printings (on PO Reports)' 	UPDATE gentables_ext SET  gentext2 = 'Printings.svg' WHERE tableid = 583  and datacode = @v_datacode
			 	 
exec @v_datacode = qutl_get_gentables_datacode 583, NULL,'Master Work'	IF @v_datacode =  0  print 'There is no datacode found for datadesc = ' + 'Master Work' 	UPDATE gentables_ext SET  gentext2 = 'far fa-archive' WHERE tableid = 583  and datacode = @v_datacode
  	 
exec @v_datacode = qutl_get_gentables_datacode 583, NULL,'Rights Deal Contracts (on Titles)'	IF @v_datacode =  0  print 'There is no datacode found for datadesc = ' + 'Rights Deal Contracts (on Titles)' 	UPDATE gentables_ext SET  gentext2 = 'Contracts.svg' WHERE tableid = 583  and datacode = @v_datacode
exec @v_datacode = qutl_get_gentables_datacode 583, NULL,'Rights Deal Contracts (on Work)'	IF @v_datacode =  0  print 'There is no datacode found for datadesc = ' + 'Rights Deal Contracts (on Work)' 	UPDATE gentables_ext SET  gentext2 = 'Contracts.svg' WHERE tableid = 583  and datacode = @v_datacode
exec @v_datacode = qutl_get_gentables_datacode 583, NULL,'Rights Deal Projects (on Titles)'	IF @v_datacode =  0  print 'There is no datacode found for datadesc = ' + 'Rights Deal Projects (on Titles)' 	UPDATE gentables_ext SET  gentext2 = 'Contracts.svg' WHERE tableid = 583  and datacode = @v_datacode
  	 	 
exec @v_datacode = qutl_get_gentables_datacode 583, NULL,'Sub Works (on Master)'	IF @v_datacode =  0  print 'There is no datacode found for datadesc = ' + 'Sub Works (on Master)' 	UPDATE gentables_ext SET  gentext2 = 'far fa-archive' WHERE tableid = 583  and datacode = @v_datacode
exec @v_datacode = qutl_get_gentables_datacode 583, NULL,'Titles (for Rights Deal)'	IF @v_datacode =  0  print 'There is no datacode found for datadesc = ' + 'Titles (for Rights Deal)' 	UPDATE gentables_ext SET  gentext2 = 'far fa-book' WHERE tableid = 583  and datacode = @v_datacode
 	 	 
exec @v_datacode = qutl_get_gentables_datacode 583, NULL,'Work (for Acquisition)'	IF @v_datacode =  0  print 'There is no datacode found for datadesc = ' + 'Work (for Acquisition)' 	UPDATE gentables_ext SET  gentext2 = 'far fa-archive' WHERE tableid = 583  and datacode = @v_datacode
exec @v_datacode = qutl_get_gentables_datacode 583, NULL,'Works (for Acq Projects)'	IF @v_datacode =  0  print 'There is no datacode found for datadesc = ' + 'Works (for Acq Projects)' 	UPDATE gentables_ext SET  gentext2 = 'far fa-archive' WHERE tableid = 583  and datacode = @v_datacode
exec @v_datacode = qutl_get_gentables_datacode 583, NULL,'Works (on Series)'	IF @v_datacode =  0  print 'There is no datacode found for datadesc = ' + 'Works (on Series)' 	UPDATE gentables_ext SET  gentext2 = 'far fa-archive' WHERE tableid = 583  and datacode = @v_datacode


END  
  
 GO