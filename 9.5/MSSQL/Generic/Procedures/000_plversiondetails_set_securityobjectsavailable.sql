if exists (select * from dbo.sysobjects where id = object_id(N'dbo.plversiondetails_set_securityobjectsavailable') and OBJECTPROPERTY(id, N'IsProcedure') = 1)
  drop procedure dbo.plversiondetails_set_securityobjectsavailable
GO

CREATE PROCEDURE plversiondetails_set_securityobjectsavailable (  
  @i_datadesc   varchar(120),
  @i_activeind  integer,
  @o_error_code integer OUTPUT,
  @o_error_desc varchar(2000) OUTPUT)
AS

/******************************************************************************************
**  Name: plversiondetails_set_securityobjectsavailable
**  Desc: Security feature to insert or delete from securityobjectsavailable when 
**        PL Version Details are activated or inactivated.
**
**  Auth: Kusum
**  Date: October 29 2014
*******************************************************************************************/

DECLARE
  @v_count  int,
  @v_maxid  int,
  @v_availobjectid varchar(50),
  @v_spacepos int,
  @v_availobjectdesc varchar(50),
  @v_availablesecurityobjectskey int,
  @v_windowid INT,
  @v_error  INT,
  @v_rowcount INT 
  
BEGIN
	SET @o_error_code = 0
	SET @o_error_desc = ''
	
	SELECT @v_windowid = windowid from qsiwindows where lower(windowname) = 'plversiondetails'
	
	IF @i_activeind = 1 BEGIN  -- pl version details row activated
		SELECT @v_count = COUNT(*)
		  FROM securityobjectsavailable
		 WHERE windowid = @v_windowid
		   AND SUBSTRING(availobjectdesc,1,(CHARINDEX('-',availobjectdesc) - 1)) = ltrim(rtrim(@i_datadesc))
	   
		IF @v_count = 0 BEGIN
			execute get_next_key 'QSIADMIN',@v_maxid OUTPUT
			
			--SET @v_spacepos = CHARINDEX(' ',@i_datadesc) - 1
			
			SET @v_spacepos = LEN(@i_datadesc)
			
			SET @v_availobjectid = 'PLVer' + SUBSTRING(@i_datadesc,1,@v_spacepos)
			SET @v_availobjectdesc = @i_datadesc + ' - ALL'

			INSERT INTO securityobjectsavailable (availablesecurityobjectskey,windowid,availobjectid,availobjectname,availobjectdesc,sortorder,menuitemid,menuitemname,menuitemdesc,lastuserid,lastmaintdate,availobjectcode,availobjectwholerowind,availobjectcodetableid)
			  select @v_maxid, windowid,@v_availobjectid,Null,@v_availobjectdesc,1,Null,Null,Null,'QSIADMIN', getdate(),Null,0,Null from qsiwindows where lower(windowname) = 'plversiondetails'
			  
			SELECT @v_error = @@ERROR, @v_rowcount = @@ROWCOUNT
			IF @v_error <> 0 OR @v_rowcount = 0 BEGIN
			  SET @o_error_code = -1
			  SET @o_error_desc = 'Error inserting to securityobjectsavailable table'
			END  
        END
	END
	
	IF @i_activeind = 0 BEGIN  -- pl version details row de-activated so remove rows from securityobjectsavailable and securityobjects
		SELECT @v_count = COUNT(*)
		  FROM securityobjectsavailable
		 WHERE windowid = @v_windowid
		   AND SUBSTRING(availobjectdesc,1,(CHARINDEX('-',availobjectdesc) - 1)) = ltrim(rtrim(@i_datadesc))
	   
		IF @v_count = 1 BEGIN
			SELECT @v_availablesecurityobjectskey  = availablesecurityobjectskey
			  FROM securityobjectsavailable
		     WHERE windowid = @v_windowid
		       AND SUBSTRING(availobjectdesc,1,(CHARINDEX('-',availobjectdesc) - 1)) = ltrim(rtrim(@i_datadesc))
		       
		    DELETE FROM securityobjects
		      WHERE availsecurityobjectkey = @v_availablesecurityobjectskey
		      
		    SELECT @v_error = @@ERROR, @v_rowcount = @@ROWCOUNT
            IF @v_error <> 0 BEGIN
			  SET @o_error_code = -1
			  SET @o_error_desc = 'Error deleting from securityobjects table'
			END 
		      
		    DELETE FROM securityobjectsavailable 
		      WHERE availablesecurityobjectskey = @v_availablesecurityobjectskey
		      
		    SELECT @v_error = @@ERROR, @v_rowcount = @@ROWCOUNT
            IF @v_error <> 0 BEGIN
			  SET @o_error_code = -1
			  SET @o_error_desc = 'Error deleting from securityobjectsavailable table'
			END 
        END
	END
END
GO

GRANT EXEC ON plversiondetails_set_securityobjectsavailable TO PUBLIC
GO