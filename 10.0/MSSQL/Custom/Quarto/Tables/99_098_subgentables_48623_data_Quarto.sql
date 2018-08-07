/*
	Case 48623 - need to update custom quarto procedure for Disk and Royalty contract class 
*/

UPDATE 
	sx 
SET
	sx.gentext1 = 'qproject_relate_master_contract_quarto'
FROM	
	subgentables_ext sx
INNER JOIN subgentables sub
	ON sx.tableid = sub.tableid
	AND sx.datacode = sub.datacode
	AND sx.datasubcode = sub.datasubcode
WHERE
	sub.qsicode = 76 --Disk & Royalty Deals
AND sub.dataCode = 10 --Contract class
AND sub.tableID = 550


