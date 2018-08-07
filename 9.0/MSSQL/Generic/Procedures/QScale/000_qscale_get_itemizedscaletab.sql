if exists (select * from dbo.sysobjects where id = object_id(N'dbo.qscale_get_itemizedscaletab') and OBJECTPROPERTY(id, N'IsProcedure') = 1)
drop procedure dbo.qscale_get_itemizedscaletab
GO

SET QUOTED_IDENTIFIER ON 
GO
SET ANSI_NULLS ON 
GO

CREATE PROCEDURE qscale_get_itemizedscaletab
 (@i_projectkey						integer,
	@i_scaletabkey					integer,
	@i_scaletypecode        integer,
  @o_error_code           integer output,
  @o_error_desc           varchar(2000) output)
AS

/******************************************************************************
**  Name: qscale_get_itemizedscaletab
**  Desc: This procedure returns rows for the specified itemized Scale Tab
**        and globalcontactkey.
**
**	Auth: Dustin Miller
**	Date: February 17 2012
*******************************************************************************/

  DECLARE @v_error						INT,
          @v_rowcount					INT,
          @v_itemcategorycode	INT,
					@v_itemcode					INT,
					@v_itemdetailcode		INT,
					@v_description			VARCHAR(2000),
					@v_sortorder				INT,
					@v_datadesc					VARCHAR(40),
					@v_tableid					INT,
					@v_scalekey					INT

  SET @o_error_code = 0
  SET @o_error_desc = ''

	DECLARE @temp_scaledetails_table TABLE
	(
		taqdetailscalekey	int,
		taqprojectkey	int,
		rowkey	int,
		columnkey	int,
		itemcategorycode	int,
		itemcode	int,
		itemdetailcode	int,
		autoapplyind	tinyint,
		fixedamount	float,
		fixedchargecode	int,
		amount	float,
		calculationtypecode	int,
		thresholdspeccategorycode	int,
		thresholdspecitemcode	int,
		thresholdvalue1	decimal(15,4),
		thresholdvalue2	decimal(15,4),
		chargecode	int,
		lastuserid	varchar(30),
		lastmaintdate	datetime,
		description	varchar(2000),
		sortorder int,
		gendesc	varchar(40),
		subsortorder	int,
		subdesc	varchar(40),
		sub2sortorder	int,
		sub2desc	varchar(40)
	)

	INSERT @temp_scaledetails_table
	SELECT *, null, null, null, null, null, null
	FROM taqprojectscaledetails sd WHERE EXISTS
		(SELECT itemcategorycode, itemcode FROM taqscaleadminspecitem si WHERE parametertypecode=3 AND scaletypecode=@i_scaletypecode
    AND scaletabkey=@i_scaletabkey) AND sd.taqprojectkey=@i_projectkey AND sd.rowkey IS NULL AND sd.columnkey IS NULL

	DECLARE scaledetail_cursor CURSOR FOR
	SELECT taqdetailscalekey, itemcategorycode, itemcode, itemdetailcode
	FROM @temp_scaledetails_table

	OPEN scaledetail_cursor

	FETCH scaledetail_cursor
	INTO @v_scalekey, @v_itemcategorycode, @v_itemcode, @v_itemdetailcode

	WHILE (@@FETCH_STATUS = 0)
	BEGIN
		--gentables level
		SET @v_sortorder = NULL
		SET @v_datadesc = NULL

		SELECT @v_sortorder = sortorder, @v_datadesc = datadesc
		FROM gentables
		WHERE tableid=616
			AND datacode=@v_itemcategorycode
			
		UPDATE @temp_scaledetails_table
		SET sortorder = @v_sortorder, gendesc = @v_datadesc
		WHERE taqdetailscalekey = @v_scalekey
			AND itemcategorycode = @v_itemcategorycode
		
		--subgentables level
		SET @v_sortorder = NULL
		SET @v_datadesc = NULL

		SELECT @v_sortorder = sortorder, @v_datadesc = datadesc
		FROM subgentables
		WHERE tableid=616
			AND datacode=@v_itemcategorycode
			AND datasubcode=@v_itemcode
			
		UPDATE @temp_scaledetails_table
		SET subsortorder = @v_sortorder, subdesc = @v_datadesc
		WHERE taqdetailscalekey = @v_scalekey
			AND itemcategorycode = @v_itemcategorycode
			AND itemcode = @v_itemcode
		
		--sub2gentables level
		SET @v_sortorder = NULL
		SET @v_datadesc = NULL
		SET @v_tableid = NULL
		
		SELECT @v_tableid=numericdesc1 
		FROM subgentables 
		WHERE tableid=616 
			AND datacode=@v_itemcategorycode 
			AND datasubcode=@v_itemcode
			
		IF @v_tableid IS NULL OR @v_tableid = 0
		BEGIN
			SELECT @v_sortorder = sortorder, @v_datadesc = datadesc 
			FROM sub2gentables 
			WHERE tableid=616
				AND datacode=@v_itemcategorycode 
				AND datasubcode=@v_itemcode
				AND datasub2code=@v_itemdetailcode
		END
		ELSE BEGIN
			SELECT @v_sortorder = sortorder, @v_datadesc = datadesc 
			FROM gentables
			WHERE tableid=@v_tableid
				AND datacode=@v_itemdetailcode
		END
		
		UPDATE @temp_scaledetails_table
		SET sub2sortorder = @v_sortorder, sub2desc = @v_datadesc
		WHERE taqdetailscalekey = @v_scalekey
			AND itemcategorycode = @v_itemcategorycode
			AND itemcode = @v_itemcode
			AND itemdetailcode = @v_itemdetailcode
		
		FETCH scaledetail_cursor
		INTO @v_scalekey, @v_itemcategorycode, @v_itemcode, @v_itemdetailcode
	END

	CLOSE scaledetail_cursor
	DEALLOCATE scaledetail_cursor

	SELECT * FROM @temp_scaledetails_table
  ORDER BY COALESCE(sortorder, ASCII(gendesc) * 1000),
					 COALESCE(subsortorder, ASCII(subdesc) * 1000),
					 COALESCE(sub2sortorder, ASCII(sub2desc) * 1000),
					 description ASC
					 
       
  --SELECT * FROM taqprojectscaledetails sd WHERE EXISTS
	--	(SELECT itemcategorycode, itemcode FROM taqscaleadminspecitem si WHERE parametertypecode=3 AND scaletypecode=@i_scaletypecode
  --  AND scaletabkey=@i_scaletabkey) AND taqprojectkey=@i_projectkey AND rowkey IS NULL AND columnkey IS NULL
  --ORDER BY coalesce(CAST((select sortorder from gentables where tableid=616 and datacode=sd.itemcategorycode) AS VARCHAR(40)), (select datadesc from gentables where tableid=616 and datacode=sd.itemcategorycode)),
	--			 coalesce(CAST((select sortorder from subgentables where tableid=616 and datacode=sd.itemcategorycode and datasubcode=sd.itemcode) AS VARCHAR(40)), (select datadesc from subgentables where tableid=616 and datacode=sd.itemcategorycode and datasubcode=sd.itemcode)),
	--			 coalesce(CAST((select sortorder from sub2gentables where tableid=616 and datacode=sd.itemcategorycode and datasubcode=sd.itemcode and datasub2code=sd.itemdetailcode) AS VARCHAR(40)), (select datadesc from sub2gentables where tableid=616 and datacode=sd.itemcategorycode and datasubcode=sd.itemcode and datasub2code=sd.itemdetailcode)),
	--			 description ASC
	
	--SELECT * FROM taqprojectscaledetails sd
	--LEFT JOIN gentables g
	--ON (g.tableid=616 AND sd.itemcategorycode = g.datacode)
	--LEFT JOIN subgentables s
	--ON (s.tableid=616 AND sd.itemcategorycode = s.datacode AND sd.itemcode = s.datasubcode)
	--LEFT JOIN sub2gentables s2
	--ON (s2.tableid=616 AND sd.itemcategorycode = s2.datacode AND sd.itemcode = s2.datasubcode AND sd.itemdetailcode=s2.datasub2code)
	--WHERE EXISTS
	--	(SELECT itemcategorycode, itemcode FROM taqscaleadminspecitem si WHERE parametertypecode=3 AND scaletypecode=@i_scaletypecode
 --    AND scaletabkey=@i_scaletabkey) AND sd.taqprojectkey=@i_projectkey AND sd.rowkey IS NULL AND sd.columnkey IS NULL
	--ORDER BY COALESCE(CAST(g.sortorder AS varchar(40)), g.datadesc), 
	--				 COALESCE(CAST(s.sortorder AS varchar(40)), s.datadesc),
	--				 COALESCE(CAST(s2.sortorder AS varchar(40)), s2.datadesc),
	--				 description ASC

  SELECT @v_error = @@ERROR, @v_rowcount = @@ROWCOUNT
  IF @v_error <> 0 BEGIN
    SET @o_error_code = -1
    SET @o_error_desc = 'Error returning taqscaleadminspecitem information (scaletabkey=' + cast(@i_scaletabkey as varchar) + ', scaletypecode=' + cast(@i_scaletypecode as varchar) + ')'
    RETURN  
  END 
  
GO

GRANT EXEC ON qscale_get_itemizedscaletab TO PUBLIC
GO