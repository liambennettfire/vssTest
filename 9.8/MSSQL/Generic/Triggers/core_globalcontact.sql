IF EXISTS (SELECT * FROM sysobjects WHERE id = object_id('dbo.core_globalcontact') AND type = 'TR')
	DROP TRIGGER dbo.core_globalcontact
GO

CREATE TRIGGER core_globalcontact ON globalcontact
FOR INSERT, UPDATE AS
IF UPDATE (displayname)

BEGIN

  DECLARE @v_contactkey INT
  DECLARE @v_projectkey INT
  SELECT @v_contactkey = i.globalcontactkey
    FROM inserted i

  exec CoreContactInfo_Row_Refresh @v_contactkey 	
  
  DECLARE crTaqProjectContact CURSOR FOR
  	 select taqprojectkey from taqprojectcontact where globalcontactkey = @v_contactkey
   OPEN crTaqProjectContact 

  FETCH NEXT FROM crTaqProjectContact INTO @v_projectkey

  WHILE (@@FETCH_STATUS <> -1)
  BEGIN 
    exec CoreProjectInfo_Row_Refresh @v_projectkey 	
	FETCH NEXT FROM crTaqProjectContact INTO @v_projectkey
  END /* WHILE FECTHING */

  CLOSE crTaqProjectContact 
  DEALLOCATE crTaqProjectContact	   

END


