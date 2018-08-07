INSERT INTO clientoptions
  (optionid, optionname, optioncomment, optionvalue, lastuserid, lastmaintdate, optionmessage)
VALUES
  (119, 'Auto Create Acq System Version', '1 will automatically create an acquisition system-generated version when formats are added/removed from acquisition project; 0 (default) will not.', 
  0, 'FIREBRAND', GETDATE(), 'This will be used for clients who are not using P&L so that they can add specifications at acquisition time.')
go
