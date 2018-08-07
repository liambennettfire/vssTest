UPDATE qse_searchcriteriadetail SET sortorder = 5 WHERE parentcriteriakey =  210 AND detailcriteriakey = 213 

IF NOT EXISTS(SELECT * FROM qse_searchcriteriadetail WHERE parentcriteriakey = 210 AND detailcriteriakey = 331) BEGIN
	INSERT INTO qse_searchcriteriadetail
	  (parentcriteriakey, detailcriteriakey, sortorder)
	VALUES
	  (210, 331, 4)
END  
go

UPDATE qse_searchcriteriadetail SET sortorder = 6 WHERE parentcriteriakey =  245 AND detailcriteriakey = 249 

IF NOT EXISTS(SELECT * FROM qse_searchcriteriadetail WHERE parentcriteriakey = 245 AND detailcriteriakey = 331) BEGIN
	INSERT INTO qse_searchcriteriadetail
	  (parentcriteriakey, detailcriteriakey, sortorder)
	VALUES
	  (245, 331, 5)
END  
go

UPDATE qse_searchcriteriadetail SET sortorder = 3 WHERE parentcriteriakey =  172 AND detailcriteriakey = 174 

IF NOT EXISTS(SELECT * FROM qse_searchcriteriadetail WHERE parentcriteriakey = 172 AND detailcriteriakey = 331) BEGIN
	INSERT INTO qse_searchcriteriadetail
	  (parentcriteriakey, detailcriteriakey, sortorder)
	VALUES
	  (172, 331, 2)
END   
go


UPDATE qse_searchcriteriadetail SET sortorder = 4 WHERE parentcriteriakey =  1 AND detailcriteriakey = 4 
UPDATE qse_searchcriteriadetail SET sortorder = 3 WHERE parentcriteriakey =  1 AND detailcriteriakey = 3 

IF NOT EXISTS(SELECT * FROM qse_searchcriteriadetail WHERE parentcriteriakey = 1 AND detailcriteriakey = 331) BEGIN
	INSERT INTO qse_searchcriteriadetail
	  (parentcriteriakey, detailcriteriakey, sortorder)
	VALUES
	  (1, 331, 2)
END    
go


UPDATE qse_searchcriteriadetail SET sortorder = 7 WHERE parentcriteriakey =  157 AND detailcriteriakey = 294 

IF NOT EXISTS(SELECT * FROM qse_searchcriteriadetail WHERE parentcriteriakey = 157 AND detailcriteriakey = 333) BEGIN
	INSERT INTO qse_searchcriteriadetail
	  (parentcriteriakey, detailcriteriakey, sortorder)
	VALUES
	  (157, 333, 6)
END    
go
