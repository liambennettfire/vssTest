if exists (select * from dbo.sysobjects where id = object_id(N'dbo.qtitle_get_relationships_title_contracts') and OBJECTPROPERTY(id, N'IsProcedure') = 1)
  drop procedure dbo.qtitle_get_relationships_title_contracts
GO

SET QUOTED_IDENTIFIER ON 
GO
SET ANSI_NULLS ON 
GO

CREATE PROCEDURE qtitle_get_relationships_title_contracts
 (@i_bookkey        integer,
  @o_error_code     integer output,
  @o_error_desc     varchar(2000) output)
AS

/******************************************************************************
**  Name: qtitle_get_relationships_title_contracts
**  Desc: This stored procedure gets all contracts related to the given title.
**
**  Auth: Kate W.
**  Date: 21 May 2012
*******************************************************************************/

DECLARE
  @v_configCount_1 INT,
  @v_configCount_2 INT,
  @v_configCount_3 INT,
  @v_error  INT,
  @v_rowcount  INT,
  @v_gentablesrelationshipkey INT,
  @v_relationshipTabCode INT,
  @v_itemType INT,
  @v_usageClass INT,
  @v_qsicode INT,
  @v_datetypecode1 INT,
  @v_datetypecode2 INT,
  @v_datetypecode3 INT,
  @v_datetypecode4 INT,
  @v_datetypecode5 INT,
  @v_datetypecode6 INT
  
BEGIN

  SET @o_error_code = 0
  SET @o_error_desc = ''

  SELECT @v_gentablesrelationshipkey = COALESCE(gentablesrelationshipkey,0)
  FROM gentablesrelationships
  WHERE gentable1id = 604 and gentable2id = 583

  SELECT @v_error = @@ERROR, @v_rowcount = @@ROWCOUNT
  IF @v_error <> 0 BEGIN
    SET @o_error_code = -1
    SET @o_error_desc = 'error acessing gentablesrelationships: bookkey = ' + cast(@i_bookkey AS VARCHAR)
    RETURN  
  END 

  IF @v_gentablesrelationshipkey <= 0 BEGIN
    RETURN
  END
  
  SELECT @v_relationshipTabCode = datacode FROM gentables where tableid = 583 and qsicode = 26
  SET @v_qsicode = 26
  
	SELECT @v_itemType = itemtypecode, @v_usageClass = usageclasscode
	FROM coretitleinfo
	WHERE bookkey = @i_bookkey
	
  SELECT @v_error = @@ERROR
  IF @v_error <> 0 BEGIN
    SET @o_error_code = -1
    SET @o_error_desc = 'Could not access coretitleinfo table: bookkey=' + cast(@i_bookkey AS VARCHAR)
    RETURN  
  END	
				
  --********************************************************************

	-- Run three counts against tabrelationshiptabconfig, 
	-- 1. Matching relationshiptabcode, itemtypecode and usageclass
	-- 2. Matching relationshiptabcode and itemtype with NULL usageclass
	-- 3. Matching relationshiptabcode and NULL itemtype and usageclass
	-- This will satisfy the spec requirements as written: 
		/** "It will first check for the tab name using the item type/usage class of the current item 
		(for example. the Project Key of the Project you are on in Project Summary) on taqrelationshiptabconfig.  
		If nothing is found for the item type/usage class, check again using the item type with a null usage class; 
		this will find a default for the item type if there is any.  If nothing is selected still, check again with 
		both the item type and usage class set to null; this will find a default for the tab if there is any.
		If nothing is found at all, set all of the configurable columns to invisible. " **/

  SELECT @v_configCount_1 = COUNT(*)
  FROM taqrelationshiptabconfig
  WHERE relationshiptabcode = @v_relationshipTabCode AND itemtypecode = @v_itemType AND usageclass = @v_usageClass

  SELECT @v_configCount_2 = COUNT(*)
  FROM taqrelationshiptabconfig
  WHERE	relationshiptabcode = @v_relationshipTabCode AND itemtypecode = @v_itemType AND usageclass IS NULL

  SELECT @v_configCount_3 = COUNT(*)
  FROM taqrelationshiptabconfig
  WHERE	relationshiptabcode = @v_relationshipTabCode AND itemtypecode IS NULL AND usageclass IS NULL

	IF @v_configCount_1 > 0
    SELECT @v_datetypecode1 = datetypecode1, @v_datetypecode2 = datetypecode2, 
      @v_datetypecode3 = datetypecode3, @v_datetypecode4 = datetypecode4, 
      @v_datetypecode5 = datetypecode5, @v_datetypecode6 = datetypecode6
    FROM taqrelationshiptabconfig
    WHERE relationshiptabcode = @v_relationshipTabCode AND itemtypecode = @v_itemType AND usageclass = @v_usageClass

	ELSE IF @v_configCount_2 > 0
    SELECT @v_datetypecode1 = datetypecode1, @v_datetypecode2 = datetypecode2, 
      @v_datetypecode3 = datetypecode3, @v_datetypecode4 = datetypecode4, 
      @v_datetypecode5 = datetypecode5, @v_datetypecode6 = datetypecode6
    FROM taqrelationshiptabconfig
    WHERE	relationshiptabcode = @v_relationshipTabCode AND itemtypecode = @v_itemType AND usageclass IS NULL

	ELSE IF @v_configCount_3 > 0
    SELECT @v_datetypecode1 = datetypecode1, @v_datetypecode2 = datetypecode2, 
      @v_datetypecode3 = datetypecode3, @v_datetypecode4 = datetypecode4, 
      @v_datetypecode5 = datetypecode5, @v_datetypecode6 = datetypecode6
    FROM taqrelationshiptabconfig
    WHERE	relationshiptabcode = @v_relationshipTabCode AND itemtypecode IS NULL AND usageclass IS NULL

  SELECT v.*,
    @v_datetypecode1 as datetypecode1, dbo.qproject_get_last_taskdate( v.contractprojectkey, @v_datetypecode1 ) as date1value, 
    @v_datetypecode2 as datetypecode2, dbo.qproject_get_last_taskdate( v.contractprojectkey, @v_datetypecode2 ) as date2value,
    @v_datetypecode3 as datetypecode3, dbo.qproject_get_last_taskdate( v.contractprojectkey, @v_datetypecode3 ) as date3value,
    @v_datetypecode4 as datetypecode4, dbo.qproject_get_last_taskdate( v.contractprojectkey, @v_datetypecode4 ) as date4value,
    @v_datetypecode5 as datetypecode5, dbo.qproject_get_last_taskdate( v.contractprojectkey, @v_datetypecode5 ) as date5value,
    @v_datetypecode6 as datetypecode6, dbo.qproject_get_last_taskdate( v.contractprojectkey, @v_datetypecode6 ) as date6value
  FROM contractstitlesview v
  WHERE v.bookkey = @i_bookkey AND v.templateind = 0
  
  SELECT @v_error = @@ERROR
  IF @v_error <> 0 BEGIN
    SET @o_error_code = 1
    SET @o_error_desc = 'Error getting related contracts for title from contractstitlesview (' + cast(@v_error AS VARCHAR) + '): bookkey=' + cast(@i_bookkey AS VARCHAR)   
  END 
    
END
go

GRANT EXEC ON qtitle_get_relationships_title_contracts TO PUBLIC
GO


