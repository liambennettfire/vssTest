-- Set up all new sample Home page misc items
DECLARE
  @v_misckey INT

BEGIN
  SELECT @v_misckey = COALESCE(MAX(misckey),0) + 1 FROM bookmiscitems

  INSERT INTO bookmiscitems
    (misckey, miscname, misclabel, misctype, fieldformat, activeind, calcitemtypecode, lastuserid, lastmaintdate)
  VALUES
    (@v_misckey, 'Titles in Outbox', 'Titles in Outbox', 6, '#,##0', 1, -1, 'QSIDBA', getdate())

  SET @v_misckey = @v_misckey + 1

  INSERT INTO bookmiscitems
    (misckey, miscname, misclabel, misctype, fieldformat, activeind, calcitemtypecode, lastuserid, lastmaintdate)
  VALUES
    (@v_misckey, 'Distributions in Outbox', 'Distributions in Outbox', 6, '#,##0', 1, -1, 'QSIDBA', getdate())

  SET @v_misckey = @v_misckey + 1

  INSERT INTO bookmiscitems
    (misckey, miscname, misclabel, misctype, fieldformat, activeind, calcitemtypecode, lastuserid, lastmaintdate)
  VALUES
    (@v_misckey, 'Titles Publishing in next 30 days', 'Titles Publishing in next 30 days', 6, '#,##0', 1, -1, 'QSIDBA', getdate())

  SET @v_misckey = @v_misckey + 1

  INSERT INTO bookmiscitems
    (misckey, miscname, misclabel, misctype, fieldformat, activeind, calcitemtypecode, lastuserid, lastmaintdate)
  VALUES
    (@v_misckey, 'Titles Sent in last 30 days', 'Titles Sent in last 30 days', 6, '#,##0', 1, -1, 'QSIDBA', getdate())

  SET @v_misckey = @v_misckey + 1

  INSERT INTO bookmiscitems
    (misckey, miscname, misclabel, misctype, fieldformat, activeind, calcitemtypecode, lastuserid, lastmaintdate)
  VALUES
    (@v_misckey, 'Distributions in last 30 days', 'Distributions in last 30 days', 6, '#,##0', 1, -1, 'QSIDBA', getdate())

  SET @v_misckey = @v_misckey + 1

  INSERT INTO bookmiscitems
    (misckey, miscname, misclabel, misctype, fieldformat, activeind, calcitemtypecode, lastuserid, lastmaintdate)
  VALUES
    (@v_misckey, 'Assets Uploaded in last 30 days', 'Assets Uploaded in last 30 days', 6, '#,##0', 1, -1, 'QSIDBA', getdate())

  SET @v_misckey = @v_misckey + 1

  INSERT INTO bookmiscitems
    (misckey, miscname, misclabel, misctype, fieldformat, activeind, calcitemtypecode, lastuserid, lastmaintdate)
  VALUES
    (@v_misckey, 'Jobs with Errors in last 7 days', 'Jobs with Errors in last 7 days', 6, '#,##0', 1, -1, 'QSIDBA', getdate())

  SET @v_misckey = @v_misckey + 1

  INSERT INTO bookmiscitems
    (misckey, miscname, misclabel, misctype, fieldformat, activeind, calcitemtypecode, lastuserid, lastmaintdate)
  VALUES
    (@v_misckey, 'Distribution Failures in last 7 days', 'Distribution Failures in last 7 days', 6, '#,##0', 1, -1, 'QSIDBA', getdate())

  SET @v_misckey = @v_misckey + 1

  INSERT INTO bookmiscitems
    (misckey, miscname, misclabel, misctype, fieldformat, activeind, calcitemtypecode, lastuserid, lastmaintdate)
  VALUES
    (@v_misckey, 'Cloud Approved Titles failing Verification', 'Cloud Approved Titles failing Verification', 6, '#,##0', 1, -1, 'QSIDBA', getdate())

  SET @v_misckey = @v_misckey + 1

  INSERT INTO bookmiscitems
    (misckey, miscname, misclabel, misctype, fieldformat, activeind, calcitemtypecode, lastuserid, lastmaintdate)
  VALUES
    (@v_misckey, 'Idea Phase Acquisitions', 'Idea Phase Acquisitions', 6, '#,##0', 1, -1, 'QSIDBA', getdate())

  SET @v_misckey = @v_misckey + 1

  INSERT INTO bookmiscitems
    (misckey, miscname, misclabel, misctype, fieldformat, activeind, calcitemtypecode, lastuserid, lastmaintdate)
  VALUES
    (@v_misckey, 'Acquisitions Approved in last 30 days', 'Acquisitions Approved in last 30 days', 6, '#,##0', 1, -1, 'QSIDBA', getdate())

  SET @v_misckey = @v_misckey + 1

  INSERT INTO bookmiscitems
    (misckey, miscname, misclabel, misctype, fieldformat, activeind, calcitemtypecode, lastuserid, lastmaintdate)
  VALUES
    (@v_misckey, 'Acquisitions Currently Active', 'Acquisitions Currently Active', 6, '#,##0', 1, -1, 'QSIDBA', getdate())

  SET @v_misckey = @v_misckey + 1

  INSERT INTO bookmiscitems
    (misckey, miscname, misclabel, misctype, fieldformat, activeind, calcitemtypecode, lastuserid, lastmaintdate)
  VALUES
    (@v_misckey, 'Contracts Signed in last 30 days', 'Contracts Signed in last 30 days', 6, '#,##0', 1, -1, 'QSIDBA', getdate())

  SET @v_misckey = @v_misckey + 1

  INSERT INTO bookmiscitems
    (misckey, miscname, misclabel, misctype, fieldformat, activeind, calcitemtypecode, lastuserid, lastmaintdate)
  VALUES
    (@v_misckey, 'Contracts Pending', 'Contracts Pending', 6, '#,##0', 1, -1, 'QSIDBA', getdate())

  SET @v_misckey = @v_misckey + 1

  INSERT INTO bookmiscitems
    (misckey, miscname, misclabel, misctype, fieldformat, activeind, calcitemtypecode, lastuserid, lastmaintdate)
  VALUES
    (@v_misckey, 'Transmittal P&L Approved in last 30 days', 'Transmittal P&L Approved in last 30 days', 6, '#,##0', 1, -1, 'QSIDBA', getdate())

  SET @v_misckey = @v_misckey + 1

  INSERT INTO bookmiscitems
    (misckey, miscname, misclabel, misctype, fieldformat, activeind, calcitemtypecode, lastuserid, lastmaintdate)
  VALUES
    (@v_misckey, 'Active Titles', 'Active Titles', 6, '#,##0', 1, -1, 'QSIDBA', getdate())

  SET @v_misckey = @v_misckey + 1

  INSERT INTO bookmiscitems
    (misckey, miscname, misclabel, misctype, fieldformat, activeind, calcitemtypecode, lastuserid, lastmaintdate)
  VALUES
    (@v_misckey, 'Total Gross Margin for Transmittals/last 30 days', 'Total Gross Margin for Transmittals/last 30 days', 6, '$#,##0', 1, -1, 'QSIDBA', getdate())

END
go
