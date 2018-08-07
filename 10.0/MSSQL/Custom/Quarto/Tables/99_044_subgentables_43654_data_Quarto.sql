/*
	Quarto Case 43654
	43654 Procedure needed to auto link contract with master contract 1991 Quarto Publishing Group : Quarto Co-editions 01 Analysis, Config, Dev, QA
	subgentables update to point at new procedure

	Summary:
		We need a procedure (quarto specific) that when called from the web will look to see if there are any 'Active' (using clientdefault 85) 
		Master Contracts (qsicode = 64) that have the same client (using client role qsicode) and will relate that master contract to the newly created 
		Co-edition contract using these project relationships - 'Master Contract' and 'Subordinate Contra
*/

UPDATE 
	gentablesdesc 
SET 
	subgentext1Label = 'Custom Project Create' 
WHERE 
	tableid = 550 

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
	sub.qsicode = 63 --Co/Edition Contract
AND sub.dataCode = 10 --Contract class
AND sub.tableID = 550


