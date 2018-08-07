
IF OBJECT_ID('dbo.AMP_to_TM_test_Interface') IS NOT NULL DROP PROCEDURE dbo.AMP_to_TM_test_Interface
GO

CREATE PROCEDURE AMP_to_TM_test_Interface
@qsijobkey		int,
@record_buffer	varchar(500),
@o_result_code	int output,
@o_result_desc	varchar(2000) output
AS
BEGIN

declare @userid varchar(30)
declare @isbn varchar(18)
declare @bookkey int
declare @dtstamp datetime

set @userid = 'AMP_to_TM_test_Interface'

set @dtstamp = getdate()


declare @start int
declare @length int
set @start = 0
set @length = 0

EXEC dbo.UpdFld_Util_DelimitedFieldPos @record_buffer, 2, '	', @start output, @length output
Set @bookkey = CONVERT(int,substring(@record_buffer,@start,@length))
print substring(@record_buffer,@start,@length)

--Set @isbn = dbo.rpt_get_isbn(Cast(substring(@record_buffer,@start,@length) as int),17)

Set @isbn = substring(@record_buffer,@start,@length)

set @start = 0
set @length = 0

--Item Number
EXEC dbo.UpdFld_Util_DelimitedFieldPos @record_buffer, 1, '	', @start output, @length output
EXEC dbo.UpdFld_XVQ_Table 'ISBN', @bookkey, 'itemnumber', 0, 0, 0, @record_buffer, @start, @length, @userid, null, 'isnumeric', 2, 4, @isbn, @qsijobkey, @o_result_code output, @o_result_desc output  -- ORIG_PRT_QTY
if @o_result_code < 3 RETURN

EXEC dbo.UpdFld_Util_DelimitedFieldPos @record_buffer, 1, '	', @start output, @length output--Skipping bookkey field.

--EXEC dbo.UpdFld_Util_DelimitedFieldPos @record_buffer, 1, '	', @start output, @length output--Skipping UPC field.
--UPC
EXEC dbo.UpdFld_Util_DelimitedFieldPos @record_buffer, 1, '	', @start output, @length output
EXEC dbo.UpdFld_XVQ_Table 'ISBN', @bookkey, 'UPC', 0, 0, 0, @record_buffer, @start, @length, @userid, null, 'isnumeric', 1, 7, @isbn, @qsijobkey, @o_result_code output, @o_result_desc output  -- ORIG_PRT_QTY
if @o_result_code < 3 RETURN

--Carton Quantity
EXEC dbo.UpdFld_Util_DelimitedFieldPos @record_buffer, 1, '	', @start output, @length output
EXEC dbo.UpdFld_XVQ_Table 'bindingspecs', @bookkey, 'cartonqty1', 0, 0, 0, @record_buffer, @start, @length, @userid, null, 'isnumeric', 2, 4, @isbn, @qsijobkey, @o_result_code output, @o_result_desc output  -- ORIG_PRT_QTY
if @o_result_code < 3 RETURN




--Carton Depth
EXEC dbo.UpdFld_Util_DelimitedFieldPos @record_buffer, 1, '	', @start output, @length output
EXEC dbo.UpdFld_XVQ_MiscItem @bookkey, 105, 0,  @record_buffer, @start, @length, @userid,  null , 'isnumeric', 2, 4, @isbn, @qsijobkey, @o_result_code output, @o_result_desc output  -- MTD Remainder Units
if @o_result_code < 3 RETURN

--Carton Depth UOM (3 Corresponds to Data Desc)
EXEC dbo.UpdFld_Util_DelimitedFieldPos @record_buffer, 1, '	', @start output, @length output
EXEC dbo.UpdFld_XVQ_MiscItem @bookkey, 112, 3,  @record_buffer, @start, @length, @userid, null, 'UpdFld_XVQ_Validate_MiscItemType5_Exists', 2, 4, @isbn, @qsijobkey, @o_result_code output, @o_result_desc output  -- MTD Remainder Units
if @o_result_code < 3 RETURN


--Carton Height
EXEC dbo.UpdFld_Util_DelimitedFieldPos @record_buffer, 1, '	', @start output, @length output
EXEC dbo.UpdFld_XVQ_MiscItem @bookkey, 104, 0,  @record_buffer, @start, @length, @userid,  null , 'isnumeric', 2, 4, @isbn, @qsijobkey, @o_result_code output, @o_result_desc output  -- MTD Remainder Units
if @o_result_code < 3 RETURN

--Carton Height UOM (3 Corresponds to Data Desc)
EXEC dbo.UpdFld_Util_DelimitedFieldPos @record_buffer, 1, '	', @start output, @length output
EXEC dbo.UpdFld_XVQ_MiscItem @bookkey, 111, 3,  @record_buffer, @start, @length, @userid, null, 'UpdFld_XVQ_Validate_MiscItemType5_Exists', 2, 4, @isbn, @qsijobkey, @o_result_code output, @o_result_desc output  -- MTD Remainder Units
if @o_result_code < 3 RETURN

--Carton Length
EXEC dbo.UpdFld_Util_DelimitedFieldPos @record_buffer, 1, '	', @start output, @length output
EXEC dbo.UpdFld_XVQ_MiscItem @bookkey, 107, 0,  @record_buffer, @start, @length, @userid,  null , 'isnumeric', 2, 4, @isbn, @qsijobkey, @o_result_code output, @o_result_desc output  -- MTD Remainder Units
if @o_result_code < 3 RETURN

--Carton Length UOM (3 Corresponds to Data Desc)
EXEC dbo.UpdFld_Util_DelimitedFieldPos @record_buffer, 1, '	', @start output, @length output
EXEC dbo.UpdFld_XVQ_MiscItem @bookkey, 110, 3,  @record_buffer, @start, @length, @userid, null, 'UpdFld_XVQ_Validate_MiscItemType5_Exists', 2, 4, @isbn, @qsijobkey, @o_result_code output, @o_result_desc output  -- MTD Remainder Units
if @o_result_code < 3 RETURN

--Carton Weight
EXEC dbo.UpdFld_Util_DelimitedFieldPos @record_buffer, 1, '	', @start output, @length output
EXEC dbo.UpdFld_XVQ_MiscItem @bookkey, 101, 0,  @record_buffer, @start, @length, @userid,  null , 'isnumeric', 2, 4, @isbn, @qsijobkey, @o_result_code output, @o_result_desc output  -- MTD Remainder Units
if @o_result_code < 3 RETURN

--Carton Weight UOM (3 Corresponds to Data Desc)
EXEC dbo.UpdFld_Util_DelimitedFieldPos @record_buffer, 1, '	', @start output, @length output
EXEC dbo.UpdFld_XVQ_MiscItem @bookkey, 113, 3,  @record_buffer, @start, @length, @userid, null, 'UpdFld_XVQ_Validate_MiscItemType5_Exists', 2, 4, @isbn, @qsijobkey, @o_result_code output, @o_result_desc output  -- MTD Remainder Units
if @o_result_code < 3 RETURN

--Length
EXEC dbo.UpdFld_Util_DelimitedFieldPos @record_buffer, 1, '	', @start output, @length output
EXEC dbo.UpdFld_XVQ_Table 'printing', @bookkey, 'tmmactualtrimlength',       0, 0, 0, @record_buffer, @start, @length, @userid, 'UpdFld_XVQ_Transform_OversizedFloatText', 'isnumeric', 2, 4, @isbn, @qsijobkey, @o_result_code output, @o_result_desc output  -- Length
if @o_result_code < 3 RETURN

--Length Unit of Measure
EXEC dbo.UpdFld_Util_DelimitedFieldPos @record_buffer, 1, '	', @start output, @length output
EXEC dbo.UpdFld_XVQ_Table 'printing', @bookkey, 'trimsizeunitofmeasure',   613, 3, 0, @record_buffer, @start, @length, @userid, null, 'UpdFld_XVQ_Validate_RefTableItem', 2, 4, @isbn, @qsijobkey, @o_result_code output, @o_result_desc output  -- TrimSize UofM
if @o_result_code < 3 RETURN

--Spine Size
EXEC dbo.UpdFld_Util_DelimitedFieldPos @record_buffer, 1, '	', @start output, @length output
EXEC dbo.UpdFld_XVQ_Table 'printing', @bookkey, 'spinesize',                 0, 0, 0, @record_buffer, @start, @length, @userid, 'UpdFld_XVQ_Transform_OversizedFloatText', 'isnumeric', 2, 4, @isbn, @qsijobkey, @o_result_code output, @o_result_desc output  -- Thickness
if @o_result_code < 3 RETURN


-- Ignore spinesize UofM if it and spinesize are both unpopulated
--if ltrim(substring(@record_buffer,87,3)) <> '' OR convert(float,substring(@record_buffer,77,10)) <> 0 begin
	EXEC dbo.UpdFld_Util_DelimitedFieldPos @record_buffer, 1, '	', @start output, @length output
	EXEC dbo.UpdFld_XVQ_Table 'printing', @bookkey, 'spinesizeunitofmeasure',  613, 3, 0, @record_buffer,@start, @length, @userid, null, 'UpdFld_XVQ_Validate_RefTableItem', 2, 4, @isbn, @qsijobkey, @o_result_code output, @o_result_desc output  -- SpineSize UofM
	if @o_result_code < 3 RETURN
--end

--Width
EXEC dbo.UpdFld_Util_DelimitedFieldPos @record_buffer, 1, '	', @start output, @length output
EXEC dbo.UpdFld_XVQ_Table 'printing', @bookkey, 'tmmactualtrimwidth',        0, 0, 0, @record_buffer, @start, @length, @userid,  'UpdFld_XVQ_Transform_OversizedFloatText' , 'isnumeric', 2, 4, @isbn, @qsijobkey, @o_result_code output, @o_result_desc output  -- Width
if @o_result_code < 3 RETURN

EXEC dbo.UpdFld_Util_DelimitedFieldPos @record_buffer, 1, '	', @start output, @length output

--Weight
EXEC dbo.UpdFld_Util_DelimitedFieldPos @record_buffer, 1, '	', @start output, @length output
EXEC dbo.UpdFld_XVQ_Table 'printing', @bookkey, 'bookweight',                0, 0, 0, @record_buffer, @start, @length, @userid,  'UpdFld_XVQ_Transform_OversizedFloatText' , 'isnumeric', 2, 4, @isbn, @qsijobkey, @o_result_code output, @o_result_desc output  -- Weight
if @o_result_code < 3 RETURN


--if ltrim(substring(@record_buffer,112,3)) <> '' OR convert(float,substring(@record_buffer,90,11)) <> 0 begin
	EXEC dbo.UpdFld_Util_DelimitedFieldPos @record_buffer, 1, '	', @start output, @length output
	EXEC dbo.UpdFld_XVQ_Table 'printing', @bookkey, 'bookweightunitofmeasure', 613, 3, 0, @record_buffer, @start, @length, @userid, null, 'UpdFld_XVQ_Validate_RefTableItem', 2, 4, @isbn, @qsijobkey, @o_result_code output, @o_result_desc output  -- Weight UofM
	if @o_result_code < 3 RETURN
--end

end

--go
/*
--Select * from AMP_DEV..isbn where bookkey = 566876
--Select * from AMP_ExportToTitleManagement.dbo.ProductInformation
--Select * from bookmiscitems order by miscname

Select * from qsijobmessages order by lastmaintdate desc

Field rejection error on job record identifier <null>, field Carton Weight UOM (Inches) : Reference table item does not exist.

Select * from AMP_Productinformation where bookkey = 571811
Select miscname,i.* from Bookmisc i
join bookmiscitems b on b.misckey=i.misckey where bookkey=571811
Select * from bindingspecs where bookkey = 571811
Select * from printing where bookkey = 571811


update AMP_Productinformation
set CartonWeightUOM = 'Ounces'
where bookkey = 566876
Select * from Bookmisc where bookkey=571811
lastuserid ='AMP_to_TM_test_Interface' and misckey= 101 bookkey =571811 

Select * from bookmiscitems where 

delete from qsijobmessages


Select * from qsijobmessages

Select * from gentablesdesc where tableid=613