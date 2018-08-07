/***** Printing Participants  ****/
DECLARE
  @count                int,
  @maxkey               int,
  @new_windowid         int,
  @applicationind       int,
  @windowcategoryid     int,
  @securitygroupkey     int,
  @windowind            char(1),
  @orgsecurityind       char(1),
  @windowname           varchar(50),
  @windowtitle          varchar(50),
  @itemtypecode         int,
  @allowviewsind        int,
  @allowmiscsectionind  int,
  @numviewcolumns       int

SET @windowname = 'PrintingParticipants'
SET @windowtitle = 'Printing Participants'
SET @windowcategoryid = 132
SET @applicationind = 14
SET @windowind = 'Y'
SET @orgsecurityind = 'N'
SET @itemtypecode = 14

/** Continue only if this window doesn't already exist for this application **/
SELECT @count = count(*) FROM qsiwindows
WHERE windowname = @windowname AND applicationind = @applicationind

IF @count = 0 BEGIN

  SELECT @new_windowid = MAX(windowid) + 1 FROM qsiwindows 

  INSERT INTO qsiwindows 
    (windowid,
    windowcategoryid,
    windowname,
    windowtitle,
    sortorder,
    applicationind,
    windowind,
    orglevelsecurityind,
    lastuserid,
    lastmaintdate,
    itemtypecode,
    allowviewsind,
    allowmiscsectionind,
    numviewcolumns)
  VALUES 
    (@new_windowid,
    @windowcategoryid,
    @windowname,
    @windowtitle,
    NULL,
    @applicationind,
    @windowind,
    @orgsecurityind,
    'QSIDBA',
    getdate(),
    @itemtypecode,
    NULL,
    NULL,
    NULL)

  /*** Set security on new item for ALL GROUPS to 'NoAccess' ***/
  DECLARE crSecWin CURSOR FOR
  SELECT securitygroupkey
  FROM securitygroup

  OPEN crSecWin 

  FETCH NEXT FROM crSecWin INTO @securitygroupkey

  WHILE (@@FETCH_STATUS <> -1)
  BEGIN
    SELECT @maxkey = MAX(securitywindowskey) + 1 FROM securitywindows

    INSERT INTO securitywindows
    (securitywindowskey,
    windowid,
    securitygroupkey,
    userkey,
    accessind,
    lastuserid,
    lastmaintdate)
    VALUES 
    (@maxkey,
    @new_windowid,
    @securitygroupkey,
    NULL,
    0,
    'QSIDBA',
    getdate())

    FETCH NEXT FROM crSecWin INTO @securitygroupkey
  END /* WHILE FECTHING */

  CLOSE crSecWin 
  DEALLOCATE crSecWin 

  /*** Set 'Update' access security for the 'ALL ACCESS' group ***/
  UPDATE securitywindows
  SET accessind = 2
  WHERE windowid = @new_windowid AND
    securitygroupkey IN (SELECT securitygroupkey FROM securitygroup 
  WHERE lower(securitygroupname) = 'all access')

END
go