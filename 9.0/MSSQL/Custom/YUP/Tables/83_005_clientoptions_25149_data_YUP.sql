INSERT INTO clientoptions
  (optionid, optionname, optioncomment, optionvalue, lastuserid, lastmaintdate)
VALUES
  (115, 'Allow Alternate P&L Currencies', '1 will allow P&L information to be entered in multiple currencies and to view/report the consolidated P&L values; 0 (default) will use a single P&L currency', 1, 'QSIDBA', getdate())
go
