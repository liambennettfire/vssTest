IF  EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[qproject_copy_project_quantity]') AND type in (N'P', N'PC'))
DROP PROCEDURE [dbo].[qproject_copy_project_quantity]
/****** Object:  StoredProcedure [dbo].[qproject_copy_project_quantity]    Script Date: 07/16/2008 10:27:11 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

CREATE PROCEDURE [dbo].[qproject_copy_project_quantity]
  (@i_copy_projectkey integer,
  @i_copy2_projectkey integer,
  @i_new_projectkey		integer,
  @i_userid				varchar(30),
  @i_cleardatagroups_list	varchar(max),
  @o_error_code			integer output,
  @o_error_desc			varchar(2000) output)
AS

/******************************************************************************
**  Name: [qproject_copy_project_quantity]
**  Desc: This stored procedure copies the details of 1 or all elements to new elements.
**        The project key to copy and the data groups to copy are passed as arguments.
**
**			If you call this procedure from anyplace other than qproject_copy_project,
**			you must do your own transaction/commit/rollbacks on return from this procedure.
**
**    Auth: Jennifer Hurd
**    Date: 23 June 2008
*******************************************************************************/

SET @o_error_code = 0
SET @o_error_desc = ''

DECLARE @error_var    INT,
	@rowcount_var INT,
	@newkeycount	int,
	@tobecopiedkey	int,
	@newkey	int,
	@counter		int,
	@newkeycount2	int,
	@tobecopiedkey2	int,
	@newkey2		int,
	@counter2		int,
	@cleardata		char(1)

if @i_copy_projectkey is null or @i_copy_projectkey = 0
begin
	SET @o_error_code = -1
	SET @o_error_desc = 'copy project key not passed to copy quantity (' + cast(@error_var AS VARCHAR) + '): taqprojectkey = ' + cast(@i_copy_projectkey AS VARCHAR)   
	RETURN
end

if @i_new_projectkey is null or @i_new_projectkey = 0
begin
	SET @o_error_code = -1
	SET @o_error_desc = 'new project key not passed to copy quantity (' + cast(@error_var AS VARCHAR) + '): taqprojectkey = ' + cast(@i_copy_projectkey AS VARCHAR)   
	RETURN
end

set @cleardata = dbo.find_integer_in_comma_delim_list (@i_cleardatagroups_list,12)

INSERT INTO taqprojectqtybreakdown
	(taqprojectkey, qtyoutletcode, qtyoutletsubcode, qty, estqty, qtynote, lastuserid, lastmaintdate)
SELECT @i_new_projectkey, qtyoutletcode, qtyoutletsubcode, 
	CASE WHEN @cleardata = 'Y' THEN NULL ELSE qty END, 
	CASE WHEN @cleardata = 'Y' THEN NULL ELSE estqty END, 
	qtynote, @i_userid, getdate()
FROM taqprojectqtybreakdown
WHERE taqprojectkey = @i_copy_projectkey

SELECT @error_var = @@ERROR, @rowcount_var = @@ROWCOUNT
IF @error_var <> 0 BEGIN
	SET @o_error_code = -1
	SET @o_error_desc = 'copy/insert into taqprojectqtybreakdown failed (' + cast(@error_var AS VARCHAR) + '): taqprojectkey=' + cast(@i_copy_projectkey AS VARCHAR)   
	RETURN
END 

/* 3/6/12 - KW - From case 17842:
Quantity (12):  copy from i_copy_projectkey; add non-existing qty types from i_copy2_projectkey */
IF @i_copy2_projectkey > 0
BEGIN
  INSERT INTO taqprojectqtybreakdown
	  (taqprojectkey, qtyoutletcode, qtyoutletsubcode, qty, estqty, qtynote, lastuserid, lastmaintdate)
  SELECT @i_new_projectkey, qtyoutletcode, qtyoutletsubcode, 
	  CASE WHEN @cleardata = 'Y' THEN NULL ELSE qty END, 
	  CASE WHEN @cleardata = 'Y' THEN NULL ELSE estqty END, 
	  qtynote, @i_userid, getdate()
  FROM taqprojectqtybreakdown q1
  WHERE q1.taqprojectkey = @i_copy2_projectkey AND
    NOT EXISTS (SELECT * FROM taqprojectqtybreakdown q2
                WHERE q1.qtyoutletcode = q2.qtyoutletcode AND
                  q1.qtyoutletsubcode = q2.qtyoutletsubcode AND
                  q2.taqprojectkey = @i_copy_projectkey)

  SELECT @error_var = @@ERROR, @rowcount_var = @@ROWCOUNT
  IF @error_var <> 0 BEGIN
	  SET @o_error_code = -1
	  SET @o_error_desc = 'Copy/insert into taqprojectqtybreakdown failed (' + cast(@error_var AS VARCHAR) + '): taqprojectkey=' + cast(@i_copy2_projectkey AS VARCHAR)   
	  RETURN
  END
END

RETURN