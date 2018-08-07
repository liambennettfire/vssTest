SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER OFF
GO

IF EXISTS(SELECT * FROM sys.objects WHERE type = 'p' and name = 'qutl_insert_qsiconfigdetailtabs_for_configdetail' ) 
     DROP PROCEDURE qutl_insert_qsiconfigdetailtabs_for_configdetail 
go

CREATE PROCEDURE [dbo].[qutl_insert_qsiconfigdetailtabs_for_configdetail]
 (@i_configdetailkey	integer,
  @i_itemtypecode		integer,
  @i_usageclasscode		integer,
  @o_error_code			integer OUTPUT,
  @o_error_desc			varchar(2000) OUTPUT)
AS

/******************************************************************************************
**  Name: qutl_insert_qsiconfigdetailtabs_for_configdetail  
**  Desc: This stored procedure searches fills in qsiconfigdetailtab records for the specified
**		  parameters.    
**    Auth: Dustin Miller
**    Date: 16 September 2016
********************************************************************************************
**    Change History
********************************************************************************************
**    Date:         Author:        Description:
**    --------      --------       --------------------------------------------------------
**    2/2/17        Alan           Case #40755
********************************************************************************************/

DECLARE @v_qsiwindowviewkey INT,
		@v_count INT,
		@v_datacode INT,
		@v_itemtypecode INT,
		@v_itemtypesubcode INT,
		@v_sortorder INT,
		@v_error_code INT,
		@v_error_desc VARCHAR(1000),
    @v_tabgroup_datacode INT
     
BEGIN
	SET @v_itemtypecode = NULL
	IF @i_itemtypecode > 0
	BEGIN
		SET @v_itemtypecode = @i_itemtypecode
	END
	SET @v_itemtypesubcode = NULL
	IF @i_usageclasscode > 0
	BEGIN
		SET @v_itemtypesubcode = @i_usageclasscode
	END
	SET @v_qsiwindowviewkey = NULL
	SET @v_sortorder = NULL

	SELECT @v_itemtypecode = COALESCE(@v_itemtypecode, co.itemtypecode),
		   @v_itemtypesubcode = COALESCE(@v_itemtypesubcode, cd.usageclasscode),
		   @v_qsiwindowviewkey = cd.qsiwindowviewkey,
       @v_tabgroup_datacode = (select datacode from gentables g where g.tableid = 680 and g.datadesc = co.configobjectdesc)  
	FROM qsiconfigdetail cd
	JOIN qsiconfigobjects co
	ON cd.configobjectkey = co.configobjectkey
	WHERE cd.configdetailkey = @i_configdetailkey

	DECLARE gentablesitemtype_cur CURSOR FOR
	SELECT i.datacode, COALESCE(i.sortorder, g.sortorder)
		FROM gentablesitemtype i
		JOIN gentables g
		ON i.tableid = g.tableid AND i.datacode = g.datacode
		WHERE i.tableid = 583 
		AND i.itemtypecode = @v_itemtypecode
		AND (i.itemtypesubcode = @v_itemtypesubcode OR COALESCE(@v_itemtypesubcode, 0) = 0 OR COALESCE(i.itemtypesubcode, 0) = 0)
		AND (deletestatus <> 'Y' or deletestatus <> 'y')
    AND i.relateddatacode = @v_tabgroup_datacode
		ORDER BY i.datacode
	
	OPEN gentablesitemtype_cur
		
	FETCH NEXT FROM gentablesitemtype_cur INTO @v_datacode, @v_sortorder
		
	WHILE (@@FETCH_STATUS = 0)
	BEGIN
		SELECT @v_count = COUNT(*) FROM qsiconfigdetailtabs WHERE configdetailkey = @i_configdetailkey AND relationshiptabcode = @v_datacode		
		IF COALESCE(@v_sortorder, 0) = 0
		BEGIN
			SET @v_sortorder = 1
		END

		IF @v_count = 0 BEGIN
			INSERT INTO qsiconfigdetailtabs (configdetailkey, relationshiptabcode, sortorder, lastuserid, lastmaintdate)
			VALUES(@i_configdetailkey,@v_datacode,@v_sortorder,'QSIDBA',GETDATE())
							
			SELECT @v_error_code = @@ERROR
			IF @v_error_code <> 0 BEGIN
	  			SET @v_error_desc = 'Error occurred inserting into qsiconfigdetailtabs for configdetailkey: ' + @i_configdetailkey  
				print @v_error_desc
			END	
		END

		FETCH NEXT FROM gentablesitemtype_cur INTO @v_datacode, @v_sortorder
	END

	CLOSE gentablesitemtype_cur
	DEALLOCATE gentablesitemtype_cur
	
END

GO
GRANT EXEC ON qutl_insert_qsiconfigdetailtabs_for_configdetail TO PUBLIC
GO