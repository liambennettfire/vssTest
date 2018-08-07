DECLARE @v_newkey int
select @v_newkey = max(columnkey) from historytablecolumndefs

SET @v_newkey = @v_newkey + 1
INSERT into historytablecolumndefs (columnkey, tablename, columnname, collectivecolumntag, historylabel, tableid, datacode, datasubcode, datetypecode, resolutionsql, lastmaintdate, lastuserid)
	VALUES (@v_newkey, 'taqprojectpayments', 'pmtstatuscode', NULL, 'Payment Status', 542, NULL, NULL,NULL,NULL, GETDATE(), 'firebrand');

SET @v_newkey = @v_newkey + 1
INSERT into historytablecolumndefs (columnkey, tablename, columnname, collectivecolumntag, historylabel, tableid, datacode, datasubcode, datetypecode, resolutionsql, lastmaintdate, lastuserid)
	VALUES (@v_newkey, 'taqprojectpayments', 'paymentamount', NULL, 'Payment Amount', NULL, NULL, NULL,NULL,NULL, GETDATE(), 'firebrand');
	
SET @v_newkey = @v_newkey + 1
INSERT into historytablecolumndefs (columnkey, tablename, columnname, collectivecolumntag, historylabel, tableid, datacode, datasubcode, datetypecode, resolutionsql, lastmaintdate, lastuserid)
	VALUES (@v_newkey, 'taqprojectpayments', 'note', NULL, 'Payment Note', NULL, NULL, NULL,NULL,NULL, GETDATE(), 'firebrand');

SET @v_newkey = @v_newkey + 1
INSERT into historytablecolumndefs (columnkey, tablename, columnname, collectivecolumntag, historylabel, tableid, datacode, datasubcode, datetypecode, resolutionsql, lastmaintdate, lastuserid)
	VALUES (@v_newkey, 'taqprojectpayments', 'date', NULL, 'Payment Date', NULL, NULL, NULL,NULL,NULL, GETDATE(), 'firebrand');

SET @v_newkey = @v_newkey + 1
INSERT into historytablecolumndefs (columnkey, tablename, columnname, collectivecolumntag, historylabel, tableid, datacode, datasubcode, datetypecode, resolutionsql, lastmaintdate, lastuserid)
	VALUES (@v_newkey, 'taqprojectpayments', 'payeecontactkey', NULL, 'Payment Payee', NULL, NULL, NULL,NULL,'select @o_displayvalue=ltrim(rtrim(coalesce(firstname,groupname,'''')+'' ''+coalesce(lastname,'''')))
    from globalcontact
    where globalcontactkey=(select payeecontactkey from $replacetablename$)', GETDATE(), 'firebrand');

SET @v_newkey = @v_newkey + 1
INSERT into historytablecolumndefs (columnkey, tablename, columnname, collectivecolumntag, historylabel, tableid, datacode, datasubcode, datetypecode, resolutionsql, lastmaintdate, lastuserid)
	VALUES (@v_newkey, 'taqprojectpayments', 'originaldate', NULL, 'Payment Original Date', NULL, NULL, NULL,NULL,NULL, GETDATE(), 'firebrand');

SET @v_newkey = @v_newkey + 1
INSERT into historytablecolumndefs (columnkey, tablename, columnname, collectivecolumntag, historylabel, tableid, datacode, datasubcode, datetypecode, resolutionsql, lastmaintdate, lastuserid)
	VALUES (@v_newkey, 'taqprojectpayments', 'reviseddate', NULL, 'Payment Revised Date', NULL, NULL, NULL,NULL,NULL, GETDATE(), 'firebrand');
	
SET @v_newkey = @v_newkey + 1
INSERT into historytablecolumndefs (columnkey, tablename, columnname, collectivecolumntag, historylabel, tableid, datacode, datasubcode, datetypecode, resolutionsql, lastmaintdate, lastuserid)
	VALUES (@v_newkey, 'taqprojectpayments', 'datetypecode', NULL, 'Payment Task', NULL, NULL, NULL,NULL,'select @o_displayvalue=ltrim(rtrim(coalesce(d.description,'''')))
    from datetype d 
    where d.datetypecode=(select datetypecode from $replacetablename$)', GETDATE(), 'firebrand');

SET @v_newkey = @v_newkey + 1
INSERT into historytablecolumndefs (columnkey, tablename, columnname, collectivecolumntag, historylabel, tableid, datacode, datasubcode, datetypecode, resolutionsql, lastmaintdate, lastuserid)
	VALUES (@v_newkey, 'taqprojectpayments', 'paymentmethodcode', NULL, 'Payment Method', 687, NULL, NULL,NULL,NULL, GETDATE(), 'firebrand');
	
SET @v_newkey = @v_newkey + 1
INSERT into historytablecolumndefs (columnkey, tablename, columnname, collectivecolumntag, historylabel, tableid, datacode, datasubcode, datetypecode, resolutionsql, lastmaintdate, lastuserid)
	VALUES (@v_newkey, 'taqprojectpayments', 'invoicenumber', NULL, 'Payment Invoice Number', NULL, NULL, NULL,NULL,NULL, GETDATE(), 'firebrand');

SET @v_newkey = @v_newkey + 1
INSERT into historytablecolumndefs (columnkey, tablename, columnname, collectivecolumntag, historylabel, tableid, datacode, datasubcode, datetypecode, resolutionsql, lastmaintdate, lastuserid)
	VALUES (@v_newkey, 'taqprojectpayments', 'invoicesent', NULL, 'Payment Invoice Sent Date', NULL, NULL, NULL,NULL,NULL, GETDATE(), 'firebrand');

SET @v_newkey = @v_newkey + 1
INSERT into historytablecolumndefs (columnkey, tablename, columnname, collectivecolumntag, historylabel, tableid, datacode, datasubcode, datetypecode, resolutionsql, lastmaintdate, lastuserid)
	VALUES (@v_newkey, 'taqprojectpayments', 'checknumber', NULL, 'Payment Check Number', NULL, NULL, NULL,NULL,NULL, GETDATE(), 'firebrand');




	