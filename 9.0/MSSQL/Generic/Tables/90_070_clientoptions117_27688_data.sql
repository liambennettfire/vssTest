IF NOT EXISTS (SELECT * FROM clientoptions WHERE optionid=117)
	INSERT INTO clientoptions
	       (optionid, optionname, optioncomment, optionvalue, lastuserid, lastmaintdate, optionmessage)
    VALUES (117, 'Production on the Web', 
    '1 means client is using Production on the Web; 0 (default) means they are not.  Before this option can be turned on, sql must be run to creating Printing and Purchase Order Items and converting specification tables',
            0, 'qsiadmin', getdate(), 
    'Even clients not wanting to use full blown production will likely want to take advantage of the new Title Spec functionality which can only be implemented if the option is turned on and sql run to create printing projects.  Only clients who currently use desktop production should not immediately be moved over to Production on the Web.  There will need to be analysis for these clients before they can turn this option on and convert to using Production on the Web'
) 
  
GO