/****** Object:  StoredProcedure [dbo].[hmco_import_from_SAP_barcode]    Script Date: 02/25/2009 14:08:04 ******/

IF  EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[hmco_import_from_SAP_barcode]') AND type in (N'P', N'PC'))
DROP PROCEDURE [dbo].[hmco_import_from_SAP_barcode]SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO



create PROCEDURE [dbo].[hmco_import_from_SAP_barcode] 
	@i_bookkey int, 
	@i_userid   varchar(30),
	@i_update_mode char(1),
	@barcodetype1code	varchar(30),
	@barcodeposition1code	varchar(30),
--	@barcodetype2code	varchar(30),
--	@barcodeposition2code	varchar(30),
	@o_error_code   integer output,
	@o_error_desc   varchar(2000) output

AS
BEGIN

declare @count	int,
@barcode1	varchar(100),
@barcodeposition1	varchar(100),
@oldtype	int,
@oldposition	int,
@update	int,
@v_error	varchar(2000),
@v_rowcount	int

if (@barcodetype1code is null and @barcodeposition1code > 0) or (@barcodetype1code > 0 and @barcodeposition1code is null)
begin
	SET @o_error_code = -2
	SET @o_error_desc = 'Unable to update barcode 1.  You must populate both values.'
	RETURN
end

select @barcode1 = g.datadesc,
@barcodeposition1 = sg.datadesc
from gentables g
join subgentables sg
on g.tableid = sg.tableid
and g.datacode = sg.datacode
where g.tableid = 552
and g.datacode = @barcodetype1code
and sg.datasubcode = @barcodeposition1code

SELECT @v_rowcount = @@ROWCOUNT
if @v_rowcount = 0
begin
	SET @o_error_code = -2
	SET @o_error_desc = 'Unable to update barcode 1.  Invalid combination of values.'
	RETURN
end

select @update = 1

select @oldtype = isnull(barcodeid1, 0),
@oldposition = isnull(barcodeposition1, 0)
from printing
where bookkey = @i_bookkey
and printingkey = 1

if @i_update_mode = 'B' and @oldtype > 0 and @oldposition > 0
	select @update = 0

if @update = 1 and (@oldtype <> @barcodetype1code or @oldposition <> @barcodeposition1code)
begin

	update printing
	set barcodeid1 = @barcodetype1code,
	barcodeposition1 = @barcodeposition1code,
	lastuserid = @i_userid,
	lastmaintdate = getdate()
	where bookkey = @i_bookkey
	and printingkey = 1


	exec qtitle_update_titlehistory 'printing', 'barcodeid1' , @i_bookkey, 1, 0, @barcode1, 'Update', @i_userid, 
		null, 'Bar Code ID 1', @o_error_code output, @o_error_desc output

	exec qtitle_update_titlehistory 'printing', 'barcodeposition1' , @i_bookkey, 1, 0, @barcodeposition1, 'Update', @i_userid, 
		null, 'Bar Code Position 1', @o_error_code output, @o_error_desc output


end
end