IF NOT EXISTS (SELECT * FROM gentablesrelationships WHERE gentablesrelationshipkey = 30) BEGIN

	INSERT INTO gentablesrelationships
	  (gentablesrelationshipkey, description, gentable1id, gentable2id, showallind, mappingind,
	   gentable1level, gentable2level, notes, 
	   lastuserid, lastmaintdate,mapinitialvalueind)
	VALUES
	  (30, 'TM Web Process Type to QSI Job Type', 669, 543, 0, 0,
	   1, 1, 'This relationship will allow us to connect the TM Web Process with a job type so that qsijob and qsijobmessages rows can be used for the TM Web Processes.', 
	   'qsidba', getdate(),1)
END
go