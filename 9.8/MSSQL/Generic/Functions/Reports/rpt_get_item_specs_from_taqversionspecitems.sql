
/****** Object:  UserDefinedFunction [dbo].[rpt_get_minimum_project_category]    Script Date: 3/4/2016 2:00:01 PM ******/
IF  EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[rpt_get_item_specs_from_taqversionspecitems]') AND type in (N'FN', N'IF', N'TF', N'FS', N'FT'))
DROP FUNCTION [dbo].[rpt_get_item_specs_from_taqversionspecitems]
GO


/****** Object:  UserDefinedFunction [dbo].[rpt_get_item_specs_from_taqversionspecitems]    Script Date: 3/2/2016 7:12:26 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

-- =============================================
-- Author:		Bill Adams
-- Create date: 02/11/16
-- Description:	This will get specs from production enviornment (taqversionspecitems)
/*
@i_bookkey
@i_printingkey 
@datacode = get from (select * from taqspecadmin) or or (select * from gentables where tableid=616)
@datasubcode = get from (select * from taqspecadmin) based on itemlabel column name or (select * from subgentables where tableid=616)
@i_selectcolumn = 'U' will return the unit of measure for this spec item type if it exists 
					'UD' will return the unit of measure DATACODE
					--GENTABLE SPECS
					'' (IF GENTABLE VALUE,WILL RETURN DATA DESCRIPTION COLUMN)
					'EX' (IF GENTABLE VALUE, Will return External Code)
					'SD' (IF GENTABLE VALUE, Will return Short Desc)
					'DC' (IF GENTABLE VALUE, Will return Datacode Code)
					'DS' (IF GENTABLE VALUE, and rests in (sub or sub2 tables) Will return Datasubcode Code)
					'D2' (IF GENTABLE VALUE, and rests in (sub2 table) Will return Datasub2code Code)
@i_descriptionnumber = 
						--IF @scalevaluetype=1 (data)  ***scalevaluetype if found automatically based on the i_itemcategorycode and i_itemcode
						'1' will return the first field (ie. trim width)
						'2' will return the second field (ie. trim height)

						--IF @scalevaluetype=5 (gentable) ***scalevaluetype if found automatically based on the i_itemcategorycode and i_itemcode
						'1' will return the first field (gentable lvl)
						'2' will return the second field (subgentable lvl)
						'3' will return the third field (sub2gentable lvl)

*/

-- =============================================
CREATE FUNCTION [dbo].[rpt_get_item_specs_from_taqversionspecitems]
(
	-- Add the parameters for the function here
	@i_bookkey int, @i_printingkey int, @datacode int, @datasubcode int,@i_selectcolumn varchar(2), @i_descriptionnumber varchar(1)
)
RETURNS varchar(max)
AS
BEGIN
Declare @result varchar(max),
		@scalevaluetype int,
		@showqtyind int,
		@showdecimalind int,
		@showdescind int,
		@showunitofmeasure int,
		@showdesc2ind int,
		@i_itemcategorycode int, @i_itemcode int

		IF @i_selectcolumn=NULL set @i_selectcolumn=''

		SET @i_itemcategorycode = @datacode
		SET @i_itemcode = @datasubcode
		IF isnull(@i_printingkey,0)=0 set @i_printingkey=1
		IF @i_descriptionnumber ='' set @i_descriptionnumber='1'

		--COLLECT INFO ABOUT SPEC ITEM
			select @scalevaluetype=scalevaluetype,
			@showqtyind=showqtyind,
			@showdecimalind=showdecimalind,
			@showdescind=showdescind,
			@showunitofmeasure=showunitofmeasureind,
			@showdesc2ind=showdesc2ind
			from taqspecadmin where itemcode=@i_itemcode and itemcategorycode=@i_itemcategorycode


--spec item is data
IF @scalevaluetype=1
BEGIN
--GET UNIT OF MEASURE FOR DECIMAL IF U IS SENT IN AN UNIT OF MEASURE EXISTS
	IF @i_selectcolumn='UD' and @showunitofmeasure=1
	BEGIN
		select @result=g.datacode from taqprojecttitle t join 
		taqversionspeccategory  tc on t.taqprojectkey=tc.taqprojectkey  and itemcategorycode=@i_itemcategorycode
		join taqversionspecitems  si on si.taqversionspecategorykey=tc.taqversionspecategorykey and si.itemcode=@i_itemcode
		join (select * from gentables where tableid=613 and deletestatus<>'Y') g on g.datacode=si.unitofmeasurecode
		where t.bookkey=@i_bookkey  and tc.itemcategorycode=@i_itemcategorycode and t.printingkey=@i_printingkey

	END
	ELSE
	IF @i_selectcolumn='U' and @showunitofmeasure=1
	BEGIN
		select @result=g.datadesc from taqprojecttitle t join 
		taqversionspeccategory  tc on t.taqprojectkey=tc.taqprojectkey  and itemcategorycode=@i_itemcategorycode
		join taqversionspecitems  si on si.taqversionspecategorykey=tc.taqversionspecategorykey and si.itemcode=@i_itemcode
		join (select * from gentables where tableid=613 and deletestatus<>'Y') g on g.datacode=si.unitofmeasurecode
		where t.bookkey=@i_bookkey  and tc.itemcategorycode=@i_itemcategorycode and t.printingkey=@i_printingkey

	END
	ELSE
	
	IF @showdecimalind = 1 
	BEGIN
	
		--GET DECIMAL
	
			select @result=si.decimalvalue from taqprojecttitle t join 
			taqversionspeccategory  tc on t.taqprojectkey=tc.taqprojectkey  and itemcategorycode=@i_itemcategorycode
			join taqversionspecitems  si on si.taqversionspecategorykey=tc.taqversionspecategorykey and si.itemcode=@i_itemcode
			where t.bookkey=@i_bookkey  and tc.itemcategorycode=@i_itemcategorycode and t.printingkey=@i_printingkey

	END
	--
	ELSE IF 
	@showdescind > 0 and @i_descriptionnumber='1'
	BEGIN								

						--get 
							select @result=si.description from taqprojecttitle t join 
								taqversionspeccategory  tc on t.taqprojectkey=tc.taqprojectkey  and itemcategorycode=@i_itemcategorycode
								join taqversionspecitems  si on si.taqversionspecategorykey=tc.taqversionspecategorykey and si.itemcode=@i_itemcode
								where t.bookkey=@i_bookkey  and tc.itemcategorycode=@i_itemcategorycode and t.printingkey=@i_printingkey
	END
	ELSE IF 
	@showqtyind = 1
	BEGIN
							select @result=si.quantity from taqprojecttitle t join 
								taqversionspeccategory  tc on t.taqprojectkey=tc.taqprojectkey  and itemcategorycode=@i_itemcategorycode
								join taqversionspecitems  si on si.taqversionspecategorykey=tc.taqversionspecategorykey and si.itemcode=@i_itemcode
								where t.bookkey=@i_bookkey  and tc.itemcategorycode=@i_itemcategorycode and t.printingkey=@i_printingkey
	END
	ELSE IF 
	@showdesc2ind > 0 and @i_descriptionnumber='2'
	BEGIN
							select @result=si.description2 from taqprojecttitle t join 
								taqversionspeccategory  tc on t.taqprojectkey=tc.taqprojectkey  and itemcategorycode=@i_itemcategorycode
								join taqversionspecitems  si on si.taqversionspecategorykey=tc.taqversionspecategorykey and si.itemcode=@i_itemcode
								where t.bookkey=@i_bookkey  and tc.itemcategorycode=@i_itemcategorycode and t.printingkey=@i_printingkey
	END

	
END

--spec item is gentable
IF @scalevaluetype=5
BEGIN
	DECLARE @tableid int,
		@itemdetailcode int,
		@itemdetailsubcode int,
		@itemdetailsub2code int

	--get tableid
	SELECT @tableid =numericdesc1 from subgentables where tableid=616 and datacode=@i_itemcategorycode and datasubcode=@i_itemcode
	--get datacodes for gentable
	SELECT @itemdetailcode=si.itemdetailcode,@itemdetailsubcode=itemdetailsubcode,@itemdetailsub2code=itemdetailsub2code from taqprojecttitle t join 
			taqversionspeccategory  tc on t.taqprojectkey=tc.taqprojectkey  and itemcategorycode=@i_itemcategorycode
			join taqversionspecitems  si on si.taqversionspecategorykey=tc.taqversionspecategorykey and si.itemcode=@i_itemcode
			where t.bookkey=@i_bookkey  and tc.itemcategorycode=@i_itemcategorycode and t.printingkey=@i_printingkey

IF ISNULL(@tableid,0)<>0
BEGIN
	
	DECLARE @gendatacode varchar(max), @gendatasubcode varchar(max), @gendatasub2code varchar(max), 
	@gendatadesc varchar(max), @genexternalcode varchar(max), @genshortdesc varchar(max),
	@genpartdatadesc varchar(max),
	@subgenpartdatadesc varchar(max),
	@sub2genpartdatadesc varchar(max)

	IF (ISNULL(@itemdetailcode,0)<>0 and ISNULL(@itemdetailsubcode,0)=0 and ISNULL(@itemdetailsub2code,0)=0) or (@i_descriptionnumber=1 and ISNULL(@itemdetailcode,0)<>0)
	BEGIN --get gentable value

			SELECT 
			@gendatadesc=g.datadesc,
			@genshortdesc=g.datadescshort,
			@genexternalcode=g.externalcode,
			@gendatacode=g.datacode
						
			from gentables g where g.tableid=@tableid and datacode=@itemdetailcode

			
			set @genpartdatadesc=@gendatadesc
	END
	ELSE 
	IF ISNULL(@itemdetailcode,0)<>0 and ISNULL(@itemdetailsubcode,0)<>0 and ISNULL(@itemdetailsub2code,0)=0 or (@i_descriptionnumber=2 and ISNULL(@itemdetailcode,0)<>0 and ISNULL(@itemdetailsubcode,0)<>0)
	BEGIN --get subgentable value
			SELECT 
			@gendatadesc=sg.datadesc,
			@genshortdesc=sg.datadescshort,
			@genexternalcode=sg.externalcode,
			@gendatacode=sg.datacode,
			@gendatasubcode=sg.datasubcode

			 from subgentables sg where sg.tableid=@tableid and datacode=@itemdetailcode and datasubcode=@itemdetailsubcode

			 	SELECT 
			@genpartdatadesc=g.datadesc								
			from gentables g where g.tableid=@tableid and datacode=@itemdetailcode
			
			set @subgenpartdatadesc=@gendatadesc


	END 
	ELSE 
	IF ISNULL(@itemdetailcode,0)<>0 and ISNULL(@itemdetailsubcode,0)<>0 and ISNULL(@itemdetailsub2code,0)<>0  or (@i_descriptionnumber=3 and ISNULL(@itemdetailcode,0)<>0 and ISNULL(@itemdetailsubcode,0)<>0 and ISNULL(@itemdetailsub2code,0)<>0 )
	BEGIN --get sub2gentable value
			SELECT 
			@gendatadesc=sg.datadesc,
			@genshortdesc=sg.datadescshort,
			@genexternalcode=sg.externalcode,
			@gendatacode=sg.datacode,
			@gendatasubcode=sg.datasubcode,
			@gendatasub2code=sg.datasub2code

			from sub2gentables sg where sg.tableid=@tableid and datacode=@itemdetailcode and datasubcode=@itemdetailsubcode and datasub2code=@itemdetailsub2code
	
				SELECT 
			@genpartdatadesc=g.datadesc								
			from gentables g where g.tableid=@tableid and datacode=@itemdetailcode
				SELECT 
			@subgenpartdatadesc=g.datadesc								
			from subgentables g where g.tableid=@tableid and datacode=@itemdetailcode and datasubcode=@itemdetailsubcode
					
			set @sub2genpartdatadesc= @gendatadesc
	
	END 


	IF @i_descriptionnumber<>4
	BEGIN
	IF @i_selectcolumn=''
	BEGIN
	SET @result=@gendatadesc
	END
	ELSE
	IF @i_selectcolumn='EX'
	BEGIN
	SET @result=@genexternalcode
	END
	ELSE
	IF @i_selectcolumn='SD'
	BEGIN
	SET @result=@genshortdesc
	END
	ELSE
	IF @i_selectcolumn='DC'
	BEGIN
		IF @i_descriptionnumber=1
			BEGIN
			SET @result=@gendatacode
			END
		ELSE 
		IF @i_descriptionnumber=2
			BEGIN
			SET @result=@gendatasubcode
			END
		ELSE
		IF @i_descriptionnumber=3
			BEGIN
			SET @result=@gendatasub2code
			END
	END
	ELSE
	IF @i_selectcolumn='DS'
	BEGIN
	SET @result=@gendatasubcode
	END
	ELSE
	IF @i_selectcolumn='D2'
	BEGIN
	SET @result=@gendatasub2code
	END
	END
	ELSE IF @i_descriptionnumber=4
	BEGIN
	IF @genpartdatadesc is not null
	BEGIN
		set @result= isnull(@genpartdatadesc,'')+' '+isnull(@subgenpartdatadesc,'')+' '+isnull(@sub2genpartdatadesc,'')
	END

	END 


END

END


	RETURN @result

END

