if exists (select * from dbo.sysobjects where id = object_id(N'dbo.qtitle_get_titlerelationshiptabconfig_hide') and OBJECTPROPERTY(id, N'IsProcedure') = 1)
  drop procedure dbo.qtitle_get_titlerelationshiptabconfig_hide
GO

SET QUOTED_IDENTIFIER ON 
GO
SET ANSI_NULLS ON 
GO

CREATE PROCEDURE qtitle_get_titlerelationshiptabconfig_hide
  (@i_assotypecode  integer,
  @i_itemtypecode	integer,
  @i_usageclasscode integer,
  @o_error_code     integer output,
  @o_error_desc     varchar(2000) output)
AS

/****************************************************************************************
**  Name: qtitle_get_titlerelationshiptabconfig_hide
**  Desc: This stored procedure returns hidden column info for relationship tabs, including misc items
**
**  Auth: Dustin Miller
**  Date: 25 January 2016
**
****************************************************************************************/

  DECLARE @error_var    INT,
          @rowcount_var INT,
          @pubdate varchar(12)

  SET @o_error_code = 0
  SET @o_error_desc = ''
  
  SELECT
	miscitem1label,
	miscitemkey1,
	miscitem2label,
	miscitemkey2,
	miscitem3label,
	miscitemkey3,
	miscitem4label,
	miscitemkey4,
	miscitem5label,
	miscitemkey5,
	miscitem6label,
	miscitemkey6,
	date1label,
	datetypecode1,
	date2label,
	datetypecode2,
	date3label,
	datetypecode3,
	date4label,
	datetypecode4,
	date5label,
	datetypecode5,
	date6label,
	datetypecode6,
	hideproductnumberind,
	hideitemnumberind,
	hidetitleind,
	hideauthorind,
	hidemediaformatind,
	hidebisacstatusind,
	hideeditionind,
	hidepubdateind,
	hidepriceind,
	hidepublisherind,
	hideprimaryind,
	hidepropagateinfoind,
	hidesumulpubind,
	hideillustrationind,
	hiderptind,
	hidepagecntind,
	hidebookposind,
	hidelifetodateposind,
	hideyeartodateposind,
	hideprevyearposind,
	hideproscommentind,
	hideconscommentind,
	hidesortorderind,
	hideqtyind,
	hidevolumeind,
	CASE
		WHEN LEN(COALESCE(miscitem1label, '')) > 0 THEN 0
		ELSE 1
	END AS hidemisc1ind,
	CASE
		WHEN LEN(COALESCE(miscitem2label, '')) > 0 THEN 0
		ELSE 1
	END AS hidemisc2ind,
	CASE
		WHEN LEN(COALESCE(miscitem3label, '')) > 0 THEN 0
		ELSE 1
	END AS hidemisc3ind,
	CASE
		WHEN LEN(COALESCE(miscitem4label, '')) > 0 THEN 0
		ELSE 1
	END AS hidemisc4ind,
	CASE
		WHEN LEN(COALESCE(miscitem5label, '')) > 0 THEN 0
		ELSE 1
	END AS hidemisc5ind,
	CASE
		WHEN LEN(COALESCE(miscitem6label, '')) > 0 THEN 0
		ELSE 1
	END AS hidemisc6ind,
	CASE
		WHEN LEN(COALESCE(date1label, '')) > 0 THEN 0
		ELSE 1
	END AS hidedate1ind,
	CASE
		WHEN LEN(COALESCE(date2label, '')) > 0 THEN 0
		ELSE 1
	END AS hidedate2ind,
	CASE
		WHEN LEN(COALESCE(date3label, '')) > 0 THEN 0
		ELSE 1
	END AS hidedate3ind,
	CASE
		WHEN LEN(COALESCE(date4label, '')) > 0 THEN 0
		ELSE 1
	END AS hidedate4ind,
	CASE
		WHEN LEN(COALESCE(date5label, '')) > 0 THEN 0
		ELSE 1
	END AS hidedate5ind,
	CASE
		WHEN LEN(COALESCE(date6label, '')) > 0 THEN 0
		ELSE 1
	END AS hidedate6ind,
	salesunitnetlabel,
	salesunitgrosslabel
  FROM titlerelationshiptabconfig tc  
  WHERE tc.relationshiptabcode = @i_assotypecode AND tc.itemtypecode = @i_itemtypecode AND (@i_usageclasscode = 0 OR tc.usageclass = 0 OR tc.usageclass = @i_usageclasscode)

  -- Save the @@ERROR and @@ROWCOUNT values in local 
  -- variables before they are cleared.
  SELECT @error_var = @@ERROR, @rowcount_var = @@ROWCOUNT
  IF @error_var <> 0 or @rowcount_var = 0 BEGIN
    SET @o_error_code = 1
    SET @o_error_desc = 'no data found: assotypecode = ' + cast(@i_assotypecode AS VARCHAR)  
  END 

GO
GRANT EXEC ON qtitle_get_titlerelationshiptabconfig_hide TO PUBLIC
GO