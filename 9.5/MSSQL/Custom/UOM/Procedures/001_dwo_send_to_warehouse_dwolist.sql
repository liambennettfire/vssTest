if exists (select * from dbo.sysobjects where id = object_id(N'dbo.dwo_send_to_whse_dwolist') and OBJECTPROPERTY(id, N'IsProcedure') = 1)
drop procedure dbo.dwo_send_to_whse_dwolist
GO

SET QUOTED_IDENTIFIER ON 
GO
SET ANSI_NULLS ON 
GO

CREATE PROCEDURE dwo_send_to_whse_dwolist
 (@i_taqprojectkey          integer,
  @i_userid                 varchar(30),
  @o_error_code             integer output,
  @o_error_desc             varchar(2000) output)
AS


/******************************************************************************
**  File: 
**  Name: dwo_send_to_whse_dwolist
**  Desc: This stored procedure will create the DWO tables and set the 
**        status to the client default Send to Warehouse status
**
**    Auth: Kusum Basra
**    Date: 2 February 2009
*******************************************************************************
**    Change History
*******************************************************************************
**    Date:    Author:        Description:
**    --------    --------        -------------------------------------------
**    
*******************************************************************************/

  SET @o_error_code = 0
  SET @o_error_desc = ''
  DECLARE @error_var    INT
  DECLARE @rowcount_var INT

  IF @i_taqprojectkey IS NULL OR @i_taqprojectkey = 0 BEGIN
    SET @o_error_code = -1
    SET @o_error_desc = 'Unable to send to warehouse: projectkey is empty.'
    RETURN
  END 


/**** dwolist table ********/

DECLARE 
	@v_dwokey		   	INT,
   @v_dwodesc        	VARCHAR(255),
   @v_dwoponumber			INT,
   @v_dwostatuscode	   INT,
	@v_listkey				INT,
   @v_misckey				INT,
	@v_bucode				INT,
	@v_publicist			VARCHAR(255),
   @v_shipping_code		INT,
   @v_shipping_code_str VARCHAR(255),
   @v_special_instr3		VARCHAR(255),
   @v_special_instr4		VARCHAR(255),
   @v_special_instr		VARCHAR(550),
   @v_approvalind			TINYINT,
	@v_acctnumber			VARCHAR(255),
	@v_createdate			DATETIME,
   @v_lastmaintdate		DATETIME,
   @v_shipdate				DATETIME,
   @v_count 				INT,
   @v_count1            INT,
   @v_misckey_qsicode1	INT,
   @v_misckey_qsicode2	INT,
   @v_misckey_qsicode3  INT,
   @v_misckey_qsicode4	INT,
   @v_rolecode				INT,
   @v_displayname			VARCHAR(255),
   @v_taqprojectstatuscode INT,
   @v_error_code			INT,
   @v_error_desc			VARCHAR(255)

	

--dwokey
SELECT @v_dwokey = @i_taqprojectkey 

SELECT @v_count = 0

SELECT @v_count = count(*)
  FROM dwolist
 WHERE dwokey = @v_dwokey

IF @v_count > 0 
BEGIN
   -- Error
   SET @o_error_code = -2
   SET @o_error_desc = 'DWO already exists for this project.'
   RETURN
END

--Dwodesc
SELECT @v_dwodesc = taqprojecttitle
  FROM taqproject
 WHERE taqprojectkey = @i_taqprojectkey 


-- dwoponumber
SELECT @v_count = 0

SELECT @v_count = count(*)
	FROM taqproductnumbers
 WHERE taqprojectkey = @i_taqprojectkey  
   AND productidcode = (select datacode from gentables where tableid = 594
   AND qsicode = 8)

IF @v_count > 0
BEGIN
	SELECT @v_dwoponumber = productnumber
	  FROM taqproductnumbers
	 WHERE taqprojectkey = @i_taqprojectkey  
		AND productidcode = (select datacode from gentables where tableid = 594
		AND qsicode = 8)
END 


-- Dwostatuscode
SELECT @v_count = count(*)
  FROM clientdefaults 
 WHERE clientdefaultid = 44

IF @v_count = 0 
BEGIN
	-- Error
   SET @o_error_code = -1
   SET @o_error_desc = 'No client default set for DWO Status.'
   RETURN
END
ELSE
BEGIN
	SELECT @v_dwostatuscode = clientdefaultvalue
	  FROM clientdefaults
	 WHERE clientdefaultid = 44
END

--Listkey
--will be set to NULL in the insert statement

--Bucode
SELECT @v_count = 0
SELECT @v_count = count(*)
  FROM bookmiscitems
 WHERE qsicode = 5

IF @v_count > 0
BEGIN
	SELECT @v_bucode = longvalue
	  FROM taqprojectmisc
	 WHERE taqprojectkey = @i_taqprojectkey
		AND misckey = (SELECT misckey FROM bookmiscitems WHERE qsicode = 5)
END

-- Publicist
SET @v_count = 0
SELECT @v_count = count(*)
  FROM clientdefaults 
 WHERE clientdefaultid = 45

IF @v_count = 0 
BEGIN
	-- Error
   SET @o_error_code = -1
   SET @o_error_desc = 'No client default set for role of Publicist.'
   RETURN
END
ELSE
BEGIN
	SELECT @v_rolecode = clientdefaultvalue
	  FROM clientdefaults 
	 WHERE clientdefaultid = 45
	
	SELECT @v_count1 = count(*)
	  FROM taqprojectcontactrole
	 WHERE rolecode = @v_rolecode 
		AND taqprojectkey = @i_taqprojectkey

	IF @v_count1 = 1
	BEGIN
--		SELECT @v_publicist = displayname 
--		  FROM globalcontact
--		 WHERE globalcontactkey in (SELECT taqprojectcontactkey FROM taqprojectcontactrole WHERE rolecode = @v_rolecode
--			AND taqprojectkey = @i_taqprojectkey)

      SELECT @v_publicist = displayname 
        FROM globalcontact WHERE globalcontactkey IN (SELECT globalcontactkey FROM taqprojectcontact
                                                     WHERE taqprojectkey = @i_taqprojectkey AND 
                                                           taqprojectcontactkey = (SELECT taqprojectcontactkey FROM taqprojectcontactrole 
                                                                                    WHERE taqprojectkey = @i_taqprojectkey AND rolecode = @v_rolecode))
	END
	IF @v_count > 1
	BEGIN
		SELECT @v_publicist = displayname 
        FROM globalcontact WHERE globalcontactkey IN (SELECT globalcontactkey FROM taqprojectcontact
                                                     WHERE taqprojectkey = @i_taqprojectkey AND 
                                                           taqprojectcontactkey = (SELECT min(taqprojectcontactkey) FROM taqprojectcontactrole 
                                                                                   WHERE taqprojectkey = @i_taqprojectkey AND rolecode = @v_rolecode))
	END
END

SELECT @v_count = 0

-- Shippingcode
SELECT @v_count = count(*)
  FROM bookmiscitems
 WHERE qsicode = 2

IF @v_count > 0
BEGIN
	SELECT @v_misckey_qsicode2 = misckey
	  FROM bookmiscitems
	 WHERE qsicode = 2
	
   SELECT @v_shipping_code = longvalue
	  FROM taqprojectmisc
	 WHERE taqprojectkey = @i_taqprojectkey
		AND misckey = @v_misckey_qsicode2
END

SET @v_count = 0

--Special_instr
SELECT @v_count = count(*)
  FROM bookmiscitems
 WHERE qsicode = 3

IF @v_count > 0
BEGIN
	SELECT @v_misckey_qsicode3 = misckey
	  FROM bookmiscitems
	 WHERE qsicode = 3
	
  	SELECT @v_special_instr3 = substring(dbo.qproject_get_misc_value(@i_taqprojectkey,@v_misckey_qsicode3),1,120)
END

SET @v_count = 0

SELECT @v_count = count(*)
  FROM bookmiscitems
 WHERE qsicode = 4

IF @v_count > 0
BEGIN
	SELECT @v_misckey_qsicode4 = misckey
	  FROM bookmiscitems
	 WHERE qsicode = 4
	
   SELECT @v_special_instr4 = substring(dbo.qproject_get_misc_value(@i_taqprojectkey,@v_misckey_qsicode4),1,135)
END

IF @v_special_instr3 IS NULL 
BEGIN
   SET @v_special_instr3 = ''
END
IF @v_special_instr4 IS NULL 
BEGIN
   SET @v_special_instr4 = ''
END
SET @v_special_instr = @v_special_instr3 + @v_special_instr4


-- Approvalind
SET @v_approvalind = 1

SET @v_count = 0

-- Acctnumber
SELECT @v_count = count(*)
  FROM bookmiscitems
 WHERE qsicode = 1

IF @v_count > 0
BEGIN
	SELECT @v_misckey_qsicode1 = misckey
	  FROM bookmiscitems
	 WHERE qsicode = 1
	
   SELECT @v_acctnumber = substring(dbo.qproject_get_misc_value(@i_taqprojectkey,@v_misckey_qsicode1),1,40)
END

INSERT INTO dwolist (dwokey,dwodesc,dwoponumber,dwostatuscode,listkey,bucode,publicist,shippingcode,
   special_instr,approvalind,acctnumber,createdate,lastmaintdate,lastuserid,shipdate)
  VALUES(@v_dwokey,@v_dwodesc,@v_dwoponumber,@v_dwostatuscode,NULL,@v_bucode,@v_publicist,@v_shipping_code,
    @v_special_instr,@v_approvalind,@v_acctnumber,getdate(),getdate(),@i_userid,getdate())

EXEC dwo_send_to_whse_dwocontact @i_taqprojectkey, @v_dwokey, @i_userid, @v_error_code OUTPUT, @v_error_desc OUTPUT
IF @v_error_code = -1
BEGIN
    SET @o_error_code = -1
    SET @o_error_desc = 'Unable to create row on dwocontact table for dwokey = ' + CONVERT(VARCHAR(20),@v_dwokey)
	RETURN
END

EXEC dwo_send_to_whse_dwodetail @i_taqprojectkey, @v_dwokey, @i_userid, @v_error_code OUTPUT, @v_error_desc OUTPUT
IF @v_error_code = -1
BEGIN
	SET @o_error_code = -1
    SET @o_error_desc = 'Unable to create row on dwodetail table for dwokey = ' + CONVERT(VARCHAR(20),@v_dwokey)
    RETURN  
END

-- Project Status Code
SELECT @v_count = 0

SELECT @v_count = count(*)
  FROM clientdefaults 
 WHERE clientdefaultid = 43

IF @v_count = 0 
BEGIN
	-- Error
   SET @o_error_code = -1
   SET @o_error_desc = 'No client default set for Project Status.'
   RETURN
END
ELSE
BEGIN
	SELECT @v_taqprojectstatuscode = clientdefaultvalue
	  FROM clientdefaults
	 WHERE clientdefaultid = 43
END
 
UPDATE taqproject
   SET taqprojectstatuscode = @v_taqprojectstatuscode
 WHERE taqprojectkey = @i_taqprojectkey
  
GO
GRANT EXEC ON dwo_send_to_whse_dwolist TO PUBLIC
GO



