delete from gentables
where tableid = 543
and datacode = 17

delete from gentablesitemtype
where tableid = 543
and datacode = 17

delete FROM gentablesrelationshipdetail
where gentablesrelationshipkey = 30
and code2 = 17

UPDATE gentables_ext
SET	gentext1 = 'HMHMktgCampaignISBNs',
	lastuserid = 'Cleanup',
	lastmaintdate = GETDATE()
WHERE tableid = 669
AND gentext1 = 'HMHMktgCampaingISBNs'