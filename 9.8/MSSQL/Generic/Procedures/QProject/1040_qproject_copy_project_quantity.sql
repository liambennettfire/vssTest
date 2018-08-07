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

/****************************************************************************************************************************
**  Name: [qproject_copy_project_quantity]
**  Desc: This stored procedure copies the details of 1 or all elements to new elements.
**        The project key to copy and the data groups to copy are passed as arguments.
**
**			If you call this procedure from anyplace other than qproject_copy_project,
**			you must do your own transaction/commit/rollbacks on return from this procedure.
**
**    Auth: Jennifer Hurd
**    Date: 23 June 2008
*****************************************************************************************************************************
**    Change History
*****************************************************************************************************************************
**    Date:        Author:     Description:
**    --------     --------    ------------------------------------------------------------------------------------------
**    05/16/2016   Uday			   Case 37359 Allow "Copy from Project" to be a different class from project being created 
**    04/05/2018   Colman      Case 50667 Duplicate key creating issue
*****************************************************************************************************************************/

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
	@cleardata		char(1),
  @v_newprojectitemtype INT,
  @v_newprojectusageclass INT,
  @v_taqprojectkey int, 
  @v_qtyoutletcode int, 
  @v_qtyoutletsubcode int, 
  @v_qty int, 
  @v_estqty int, 
  @v_qtynote varchar(255), 
  @v_lastuserid varchar(30), 
  @v_lastmaintdate datetime

DECLARE @tmp_taqprojectqtybreakdown TABLE(
	taqprojectkey int NOT NULL,
	qtyoutletcode int NOT NULL,
	qtyoutletsubcode int NOT NULL,
	qty int NULL,
	lastuserid varchar(30) NULL,
	lastmaintdate datetime NULL,
	estqty int NULL,
	qtynote varchar(255) NULL
)

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

-- only want to copy elements types that are defined for the new project
IF (@i_new_projectkey > 0)
BEGIN
  SELECT @v_newprojectitemtype = searchitemcode, @v_newprojectusageclass = usageclasscode
  FROM taqproject
  WHERE taqprojectkey = @i_new_projectkey

  IF @v_newprojectitemtype is null or @v_newprojectitemtype = 0
  BEGIN
     SET @o_error_code = -1
     SET @o_error_desc = 'Unable to copy royaltyinfo because item type is not populated: taqprojectkey = ' + cast(@i_new_projectkey AS VARCHAR)   
     RETURN
  END

  IF @v_newprojectusageclass is null 
    SET @v_newprojectusageclass = 0
END    

set @cleardata = dbo.find_integer_in_comma_delim_list (@i_cleardatagroups_list,12)

INSERT INTO @tmp_taqprojectqtybreakdown (taqprojectkey, qtyoutletcode, qtyoutletsubcode, qty, estqty, qtynote, lastuserid, lastmaintdate)
SELECT @i_new_projectkey, qtyoutletcode, qtyoutletsubcode,
    CASE WHEN @cleardata = 'Y'
      THEN NULL
      ELSE qty
    END, 
    CASE WHEN @cleardata = 'Y'
      THEN NULL
      ELSE estqty
    END, qtynote, @i_userid, getdate()
FROM taqprojectqtybreakdown
WHERE taqprojectkey = @i_copy_projectkey
  AND qtyoutletcode IN (
    SELECT datacode
    FROM qutl_get_gentable_itemtype_filtering(527, @v_newprojectitemtype, @v_newprojectusageclass)
    )
  AND (
    COALESCE(qtyoutletsubcode, 0) = 0
    OR qtyoutletsubcode IN (
      SELECT datasubcode
      FROM qutl_get_gentable_itemtype_filtering(527, @v_newprojectitemtype, @v_newprojectusageclass)
      WHERE datacode = qtyoutletcode
      )
    )

SELECT @error_var = @@ERROR
IF @error_var <> 0 BEGIN
	SET @o_error_code = -1
	SET @o_error_desc = 'copy/insert into taqprojectqtybreakdown failed (' + cast(@error_var AS VARCHAR) + '): taqprojectkey=' + cast(@i_copy_projectkey AS VARCHAR)   
	RETURN
END 

/* 3/6/12 - KW - From case 17842:
Quantity (12):  copy from i_copy_projectkey; add non-existing qty types from i_copy2_projectkey */
IF @i_copy2_projectkey > 0
BEGIN
  INSERT INTO @tmp_taqprojectqtybreakdown (taqprojectkey, qtyoutletcode, qtyoutletsubcode, qty, estqty, qtynote, lastuserid, lastmaintdate)
  SELECT @i_new_projectkey, qtyoutletcode, qtyoutletsubcode, CASE 
      WHEN @cleardata = 'Y'
        THEN NULL
      ELSE qty
      END, CASE 
      WHEN @cleardata = 'Y'
        THEN NULL
      ELSE estqty
      END, qtynote, @i_userid, getdate()
  FROM taqprojectqtybreakdown q1
  WHERE q1.taqprojectkey = @i_copy2_projectkey
    AND NOT EXISTS (
      SELECT *
      FROM taqprojectqtybreakdown q2
      WHERE q1.qtyoutletcode = q2.qtyoutletcode
        AND q1.qtyoutletsubcode = q2.qtyoutletsubcode
        AND q2.taqprojectkey = @i_copy_projectkey
      )
    AND qtyoutletcode IN (
      SELECT datacode
      FROM qutl_get_gentable_itemtype_filtering(527, @v_newprojectitemtype, @v_newprojectusageclass)
      )
    AND (
      COALESCE(qtyoutletsubcode, 0) = 0
      OR qtyoutletsubcode IN (
        SELECT datasubcode
        FROM qutl_get_gentable_itemtype_filtering(527, @v_newprojectitemtype, @v_newprojectusageclass)
        WHERE datacode = qtyoutletcode
        )
      )

  SELECT @error_var = @@ERROR
  IF @error_var <> 0 BEGIN
    SET @o_error_code = - 1
    SET @o_error_desc = 'Copy/insert into taqprojectqtybreakdown failed (' + cast(@error_var AS VARCHAR) + '): taqprojectkey=' + cast(@i_copy2_projectkey AS VARCHAR)
    RETURN
  END
END

DECLARE cur_taqprojectqtybreakdown CURSOR LOCAL FOR
SELECT taqprojectkey, qtyoutletcode, qtyoutletsubcode, qty, estqty, qtynote, lastuserid, lastmaintdate
FROM @tmp_taqprojectqtybreakdown

OPEN cur_taqprojectqtybreakdown

FETCH cur_taqprojectqtybreakdown INTO
@v_taqprojectkey, @v_qtyoutletcode, @v_qtyoutletsubcode, @v_qty, @v_estqty, @v_qtynote, @v_lastuserid, @v_lastmaintdate

WHILE @@FETCH_STATUS = 0
BEGIN
  IF NOT EXISTS (
    SELECT 1 
    FROM taqprojectqtybreakdown
    WHERE taqprojectkey = @v_taqprojectkey
      AND qtyoutletcode = @v_qtyoutletcode
      AND qtyoutletsubcode = @v_qtyoutletsubcode
  )
    INSERT INTO taqprojectqtybreakdown
	    (taqprojectkey, qtyoutletcode, qtyoutletsubcode, qty, estqty, qtynote, lastuserid, lastmaintdate)
    VALUES
      (@v_taqprojectkey, @v_qtyoutletcode, @v_qtyoutletsubcode, @v_qty, @v_estqty, @v_qtynote, @v_lastuserid, @v_lastmaintdate)

  FETCH cur_taqprojectqtybreakdown INTO
  @v_taqprojectkey, @v_qtyoutletcode, @v_qtyoutletsubcode, @v_qty, @v_estqty, @v_qtynote, @v_lastuserid, @v_lastmaintdate
END

CLOSE cur_taqprojectqtybreakdown
DEALLOCATE cur_taqprojectqtybreakdown

RETURN
GO

GRANT EXEC ON qproject_copy_project_quantity TO PUBLIC
GO
