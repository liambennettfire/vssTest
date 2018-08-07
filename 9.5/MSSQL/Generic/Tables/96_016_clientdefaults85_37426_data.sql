IF NOT EXISTS(SELECT * FROM clientdefaults WHERE clientdefaultid = 85) BEGIN
	INSERT INTO clientdefaults
	  (clientdefaultid, clientdefaultname, defaultvaluecomment, 
	  clientdefaultvalue, lastuserid, lastmaintdate, activeind, systemfunctioncode,defaultdescription,
	  valuetypecode)
	VALUES
	  (85, 'Number Projects for Background Process', 
	  'This value will be used for the number of projects that will prompt a background Create or Approval for projects.', 
	  10, 'QSIDBA', getdate(),1,1,
	  'Used to determine the number of projects that will trigger a background process for Create or Approval projects.',
	  1)
END 
GO
