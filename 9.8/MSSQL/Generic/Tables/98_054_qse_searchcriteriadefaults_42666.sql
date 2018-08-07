UPDATE qse_searchcriteriadefaults SET sequence = 5 WHERE searchcriteriakey = 167 and listkey = 3 AND sequence = 4 and subsequence = 1 
UPDATE qse_searchcriteriadefaults SET sequence = 4 WHERE searchcriteriakey = 67 and listkey = 3 AND sequence = 3 and subsequence = 1 
UPDATE qse_searchcriteriadefaults SET sequence = 3 WHERE searchcriteriakey = 66 and listkey = 3 AND sequence = 2 and subsequence = 1 


IF NOT EXISTS(SELECT * FROM qse_searchcriteriadefaults WHERE listkey = 3 AND sequence = 2 and subsequence = 1 AND searchcriteriakey = 330) BEGIN
	INSERT INTO qse_searchcriteriadefaults (listkey,sequence,subsequence,searchcriteriakey,defaultoperator,
	  operatordesc,logicaloperator)
	VALUES (3,2,1,330,3,'S',1)
END
go

UPDATE qse_searchcriteriadefaults SET sequence = 4 WHERE searchcriteriakey = 167 and listkey = 46 AND sequence = 3 and subsequence = 1 

IF NOT EXISTS(SELECT * FROM qse_searchcriteriadefaults WHERE listkey = 46 AND sequence = 3 and subsequence = 1 AND searchcriteriakey = 330) BEGIN
	INSERT INTO qse_searchcriteriadefaults (listkey,sequence,subsequence,searchcriteriakey,defaultoperator,
	  operatordesc,logicaloperator)
	VALUES (46,3,1,330,3,'S',1)
END
go