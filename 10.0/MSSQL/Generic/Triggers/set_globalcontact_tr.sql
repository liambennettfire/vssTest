IF EXISTS (SELECT * FROM sysobjects WHERE id = object_id('dbo.set_globalcontact_tr') AND type = 'TR')
	DROP TRIGGER dbo.set_globalcontact_tr 
GO

/******************************************************************************
**    Change History
*******************************************************************************
**  Date        Who      Change
**  ----------  -------  ------------------------------------------------------
**  10/11/2017  Colman   Case 47714 - Purge SSN references
*******************************************************************************/

CREATE TRIGGER set_globalcontact_tr ON author
FOR INSERT, UPDATE AS
IF UPDATE (firstname) OR 
   UPDATE (lastname) OR 
   UPDATE (middlename) OR 
   UPDATE (displayname) OR 
   UPDATE (ssn) OR 
   UPDATE (uscitizenind) OR 
   UPDATE (lastuserid) OR 
   UPDATE (authordegree) OR 
   UPDATE (authorsuffix) OR 
   UPDATE (nameabbrcode) OR 
   UPDATE (notes) OR 
   UPDATE (corporatecontributorind) OR
   UPDATE (activeind)

BEGIN
  DECLARE
    @v_authorkey int,
    @v_displayname varchar(80),
    @v_firstname varchar(75) ,
    @v_lastname varchar(75) ,
    @v_middlename varchar(75) ,
    @v_ssn varchar(15) ,
    @v_uscitizenind int ,
    @v_suffix varchar(75) ,
    @v_degree varchar(75) ,
    @v_notes varchar(255) ,
    @v_corparateind int,
    @v_accreditationcode int,
    @v_lastuserid varchar(30),
    @v_activeind int

  select 
    @v_authorkey = authorkey,
    @v_displayname = displayname,
    @v_firstname = firstname,
    @v_lastname = lastname,
    @v_middlename = middlename,
    @v_ssn = NULL,
    @v_uscitizenind = uscitizenind,
    @v_suffix = authorsuffix,
    @v_degree = authordegree,
    @v_accreditationcode = nameabbrcode,
    @v_notes =notes ,
    @v_corparateind = corporatecontributorind,
    @v_lastuserid = lastuserid,
    @v_activeind = activeind
  from inserted i

  exec set_globalcontact_sp @v_authorkey,@v_displayname,@v_firstname,@v_lastname,@v_middlename,@v_ssn,@v_uscitizenind,@v_degree,@v_suffix,@v_accreditationcode,@v_notes,@v_corparateind,@v_lastuserid,@v_activeind

END
go



