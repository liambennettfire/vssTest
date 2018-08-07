
/****** Object:  StoredProcedure [dbo].[qutl_insert_security_windows]    Script Date: 01/09/2015 11:56:09 ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER OFF
GO

IF EXISTS(SELECT * FROM sys.objects WHERE type = 'p' and name = 'qutl_insert_security_windows' ) 
drop procedure qutl_insert_security_windows
go

CREATE PROCEDURE [dbo].[qutl_insert_security_windows]
 (@i_windowid             integer,
  @o_error_code           integer output,
  @o_error_desc			  varchar(2000) output)
AS

/********************************************************************************
**  Name: qutl_insert_security_windows
**  Desc: This stored procedure creates security rows for the qsiwindow row passed
**        to the procedure.  All rows are set to No Access except the "All Access"
**        user group.  "All Access" users are set to Update.  If security rows
**        exist already, no action is taken.
**    Auth: SLB
**    Date: 9 Jan 2015
*********************************************************************************
**    Change History
*********************************************************************************
**    Date:    Author:        Description:
**    --------    --------        -------------------------------------------
**    
*********************************************************************************/

  DECLARE 
    @v_max_key  INT,
    @v_error  INT,
    @v_count  INT,
    @v_securitygroupkey INT,
    @v_windowcategoryid INT
     
  SET @v_count = 0
  SET @o_error_code = 0
  SET @o_error_desc = ''
  SET @v_max_key = 0
  SET @v_securitygroupkey = 0
    
BEGIN
	  SELECT @v_count = count(*) FROM securitywindows WHERE windowid = @i_windowid
	  IF @v_count > 0 and @v_count is not NULL    --Security Rows exist already so no action is taken
	      RETURN
 
	  /*** Set security on new item for ALL GROUPS to 'NoAccess' ***/
	  DECLARE crSecWin CURSOR FOR
	  SELECT securitygroupkey FROM securitygroup
	  OPEN crSecWin 
	  
	  FETCH NEXT FROM crSecWin INTO @v_securitygroupkey

	  WHILE (@@FETCH_STATUS <> -1)BEGIN
		SELECT @v_max_key = MAX(securitywindowskey) + 1 FROM securitywindows

		INSERT INTO securitywindows (securitywindowskey, windowid, securitygroupkey, userkey, accessind, lastuserid, lastmaintdate)
		VALUES     (@v_max_key, @i_windowid, @v_securitygroupkey, NULL, 0, 'QSIDBA', getdate())

		FETCH NEXT FROM crSecWin INTO @v_securitygroupkey
      END /* WHILE FETCHING */

	  CLOSE crSecWin 
	  DEALLOCATE crSecWin 

	  /*** Set 'Update' access security for the 'ALL ACCESS' group ***/
	  UPDATE securitywindows
	  SET accessind = 2
	  WHERE windowid = @i_windowid AND
		securitygroupkey IN (SELECT securitygroupkey FROM securitygroup 
	  WHERE lower(securitygroupname) = 'all access')
   
END --Stored Procedure
		
GO


