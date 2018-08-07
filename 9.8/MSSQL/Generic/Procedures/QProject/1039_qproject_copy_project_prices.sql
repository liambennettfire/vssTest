IF  EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[qproject_copy_project_prices]') AND type in (N'P', N'PC'))
DROP PROCEDURE [dbo].[qproject_copy_project_prices]
/****** Object:  StoredProcedure [dbo].[qproject_copy_project_prices]    Script Date: 07/16/2008 10:28:22 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

CREATE PROCEDURE [dbo].[qproject_copy_project_prices]
  (@i_copy_projectkey integer,
  @i_copy2_projectkey integer,
  @i_new_projectkey		integer,
  @i_userid				varchar(30),
  @i_cleardatagroups_list	varchar(max),
  @o_error_code			integer output,
  @o_error_desc			varchar(2000) output)
AS

/****************************************************************************************************************************
**  Name: [qproject_copy_project_prices]
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
**    Date:        Author:         Description:
**    --------     --------        --------------------------------------------------------------------------------------
**    05/11/2016   Uday			   37359 Allow "Copy from Project" to be a different class from project being created 
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
	@v_maxsort  int,
	@v_sortorder  int,
    @v_newprojectitemtype   INT,
    @v_newprojectusageclass	INT	

IF @i_copy_projectkey IS NULL OR @i_copy_projectkey = 0
BEGIN
	SET @o_error_code = -1
	SET @o_error_desc = 'copy project key not passed to copy prices (' + CAST(@error_var AS VARCHAR) + '): taqprojectkey = ' + CAST(@i_copy_projectkey AS VARCHAR)   
	RETURN
END

IF @i_new_projectkey IS NULL OR @i_new_projectkey = 0
BEGIN
	SET @o_error_code = -1
	SET @o_error_desc = 'new project key not passed to copy prices (' + CAST(@error_var AS VARCHAR) + '): taqprojectkey = ' + CAST(@i_copy_projectkey AS VARCHAR)   
	RETURN
END

-- only want to copy items types that are defined for the new project
IF (@i_new_projectkey > 0)
BEGIN
  SELECT @v_newprojectitemtype = searchitemcode, @v_newprojectusageclass = usageclasscode
  FROM taqproject
  WHERE taqprojectkey = @i_new_projectkey

  IF @v_newprojectitemtype is null or @v_newprojectusageclass = 0
  BEGIN
    SET @o_error_code = -1
    SET @o_error_desc = 'Unable to copy elements because item type is not populated: taqprojectkey = ' + cast(@i_new_projectkey AS VARCHAR)   
    RETURN
  END
  
  IF @v_newprojectusageclass is null 
    SET @v_newprojectusageclass = 0
END

SET @cleardata = dbo.find_integer_in_comma_delim_list (@i_cleardatagroups_list,11)

SELECT @newkeycount = COUNT(*), @tobecopiedkey = MIN(q.pricekey), @v_maxsort = MAX(sortorder)
FROM taqprojectprice q
WHERE taqprojectkey = @i_copy_projectkey AND
	  (COALESCE(q.pricetypecode, 0) = 0 OR q.pricetypecode IN (SELECT datacode FROM qutl_get_gentable_itemtype_filtering(306, @v_newprojectitemtype, @v_newprojectusageclass))) AND
	  (COALESCE(q.currencytypecode, 0) = 0 OR q.currencytypecode IN (SELECT datacode FROM qutl_get_gentable_itemtype_filtering(122, @v_newprojectitemtype, @v_newprojectusageclass)))

SET @counter = 1

WHILE @counter <= @newkeycount
BEGIN
	EXEC get_next_key @i_userid, @newkey OUTPUT

	INSERT INTO taqprojectprice
		(pricekey, taqprojectkey, pricetypecode, currencytypecode, activeind, 
		budgetprice, finalprice, effectivedate, expirationdate, sortorder, lastuserid, lastmaintdate)
	SELECT @newkey, @i_new_projectkey, pricetypecode, currencytypecode, activeind, 
		CASE WHEN @cleardata = 'Y' THEN NULL ELSE budgetprice END, 
		CASE WHEN @cleardata = 'Y' THEN NULL ELSE finalprice END, 
		CASE WHEN @cleardata = 'Y' THEN NULL ELSE effectivedate END,
		expirationdate, sortorder, @i_userid, getdate()
	FROM taqprojectprice
	WHERE taqprojectkey = @i_copy_projectkey AND pricekey = @tobecopiedkey

	SELECT @error_var = @@ERROR, @rowcount_var = @@ROWCOUNT
	IF @error_var <> 0 BEGIN
		SET @o_error_code = -1
		SET @o_error_desc = 'copy/insert into taqprojectprice failed (' + CAST(@error_var AS VARCHAR) + '): taqprojectkey=' + CAST(@i_copy_projectkey AS VARCHAR)   
		RETURN
	END 

	SET @counter = @counter + 1

	SELECT @tobecopiedkey = MIN(q.pricekey)
	FROM taqprojectprice q
	WHERE taqprojectkey = @i_copy_projectkey AND q.pricekey > @tobecopiedkey AND
	  (COALESCE(q.pricetypecode, 0) = 0 OR q.pricetypecode IN (SELECT datacode FROM qutl_get_gentable_itemtype_filtering(306, @v_newprojectitemtype, @v_newprojectusageclass))) AND
	  (COALESCE(q.currencytypecode, 0) = 0 OR q.currencytypecode IN (SELECT datacode FROM qutl_get_gentable_itemtype_filtering(122, @v_newprojectitemtype, @v_newprojectusageclass)))	
END

/* 5/4/12 - KW - From case 17842:
Prices (11):  copy from i_copy_projectkey; add non-existing price/currency types from i_copy2_projectkey */
IF @i_copy2_projectkey > 0
BEGIN
  SELECT @newkeycount = COUNT(*), @tobecopiedkey = MIN(p1.pricekey)
  FROM taqprojectprice p1
  WHERE p1.taqprojectkey = @i_copy2_projectkey AND
	(COALESCE(p1.pricetypecode, 0) = 0 OR p1.pricetypecode IN (SELECT datacode FROM qutl_get_gentable_itemtype_filtering(306, @v_newprojectitemtype, @v_newprojectusageclass))) AND
    (COALESCE(p1.currencytypecode, 0) = 0 OR p1.currencytypecode IN (SELECT datacode FROM qutl_get_gentable_itemtype_filtering(122, @v_newprojectitemtype, @v_newprojectusageclass))) AND
    NOT EXISTS (SELECT * FROM taqprojectprice p2
                WHERE p1.pricetypecode = p2.pricetypecode AND 
                  p1.currencytypecode = p2.currencytypecode AND 
                  p2.taqprojectkey = @i_copy_projectkey)

  SET @counter = 1
  SET @v_sortorder = @v_maxsort + 1

  WHILE @counter <= @newkeycount
  BEGIN
	  EXEC get_next_key @i_userid, @newkey OUTPUT

	  INSERT INTO taqprojectprice
		  (pricekey, taqprojectkey, pricetypecode, currencytypecode, activeind, 
		  budgetprice, finalprice, effectivedate, expirationdate, sortorder, lastuserid, lastmaintdate)
	  SELECT @newkey, @i_new_projectkey, pricetypecode, currencytypecode, activeind, 
		  CASE WHEN @cleardata = 'Y' THEN NULL ELSE budgetprice END, 
		  CASE WHEN @cleardata = 'Y' THEN NULL ELSE finalprice END, 
		  CASE WHEN @cleardata = 'Y' THEN NULL ELSE effectivedate END,
		  expirationdate, @v_sortorder, @i_userid, getdate()
	  FROM taqprojectprice
	  WHERE taqprojectkey = @i_copy2_projectkey AND pricekey = @tobecopiedkey

	  SELECT @error_var = @@ERROR, @rowcount_var = @@ROWCOUNT
	  IF @error_var <> 0 BEGIN
		  SET @o_error_code = -1
		  SET @o_error_desc = 'Copy/insert into taqprojectprice failed (' + CAST(@error_var AS VARCHAR) + '): taqprojectkey=' + CAST(@i_copy2_projectkey AS VARCHAR)   
		  RETURN
	  END 

	  SET @counter = @counter + 1
	  SET @v_sortorder = @v_sortorder + 1

    SELECT @tobecopiedkey = MIN(p1.pricekey)
    FROM taqprojectprice p1
    WHERE p1.taqprojectkey = @i_copy2_projectkey AND
      p1.pricekey > @tobecopiedkey AND
	  (COALESCE(p1.pricetypecode, 0) = 0 OR p1.pricetypecode IN (SELECT datacode FROM qutl_get_gentable_itemtype_filtering(306, @v_newprojectitemtype, @v_newprojectusageclass))) AND
      (COALESCE(p1.currencytypecode, 0) = 0 OR p1.currencytypecode IN (SELECT datacode FROM qutl_get_gentable_itemtype_filtering(122, @v_newprojectitemtype, @v_newprojectusageclass))) AND     
      NOT EXISTS (SELECT * FROM taqprojectprice p2
                  WHERE p1.pricetypecode = p2.pricetypecode AND 
                    p1.currencytypecode = p2.currencytypecode AND 
                    p2.taqprojectkey = @i_copy_projectkey)	
  END --WHILE LOOP
END --@i_copy2_projectkey > 0

RETURN