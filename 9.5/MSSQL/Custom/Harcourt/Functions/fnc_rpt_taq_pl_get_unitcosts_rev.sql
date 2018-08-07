/****** Object:  UserDefinedFunction [dbo].[rpt_taq_pl_get_unitcosts_rev]    Script Date: 04/13/2010 10:06:45 ******/
IF  EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[rpt_taq_pl_get_unitcosts_rev]') AND type in (N'FN', N'IF', N'TF', N'FS', N'FT'))
DROP FUNCTION [dbo].[rpt_taq_pl_get_unitcosts_rev]

GO
/****** Object:  UserDefinedFunction [dbo].[rpt_taq_pl_get_unitcosts_rev]    Script Date: 04/05/2010 17:38:22 ******/
CREATE FUNCTION [dbo].[rpt_taq_pl_get_unitcosts_rev]
		(@i_taqprojectkey INT,@i_plstagecode int, @i_taqversionkey int, @v_format varchar(40))

RETURNS VARCHAR(100)

AS

BEGIN

	DECLARE @RETURN			VARCHAR(100)
	DECLARE @f_avg_unit_cost FLOAT
	DECLARE @f_discount_percentage decimal(13,2)
	DECLARE @f_format_price FLOAT
	DECLARE @n_dividend decimal(13,2)
	DECLARE @i_taqprojectformatkey int

	If @v_format = 'Hardcover' begin
	Select top 1 @i_taqprojectformatkey = taqprojectformatkey
	from taqversionformat
	where taqprojectkey = @i_taqprojectkey
	  and plstagecode = @i_plstagecode
	  and taqversionkey = @i_taqversionkey
	  and mediatypecode = 2
	  and mediatypesubcode in (6,26) end
	Else If @v_format = 'Paperback' begin
	Select top 1 @i_taqprojectformatkey = taqprojectformatkey
	from taqversionformat
	where taqprojectkey = @i_taqprojectkey
	  and plstagecode = @i_plstagecode
	  and taqversionkey = @i_taqversionkey
	  and mediatypecode = 2
	  and mediatypesubcode in (20,27) end
	Else If @v_format = 'eBook' begin
	Select top 1 @i_taqprojectformatkey = taqprojectformatkey
	from taqversionformat
	where taqprojectkey = @i_taqprojectkey
	  and plstagecode = @i_plstagecode
	  and taqversionkey = @i_taqversionkey
	  and mediatypecode = 14 end

	Select @f_avg_unit_cost = dbo.qpl_get_avg_unitcost_by_format(@i_taqprojectkey,@i_plstagecode,@i_taqversionkey,@i_taqprojectformatkey)	
	
	If @v_format = 'Hardcover' begin
    Select @f_format_price = Year1_Price from rpt_taq_pl_priceby_formatyear_view where taqprojectkey = @i_taqprojectkey and type = 'HC List Price' end
	Else If @v_format = 'Paperback' begin
    Select @f_format_price = Year1_Price from rpt_taq_pl_priceby_formatyear_view where taqprojectkey = @i_taqprojectkey and type = 'PB List Price' end
	Else If @v_format = 'eBook' begin
    Select @f_format_price = Year1_Price from rpt_taq_pl_priceby_formatyear_view where taqprojectkey = @i_taqprojectkey and type = 'Ebook List Price' end
	

Select top 1 @f_discount_percentage  = discountpercent from rpt_taq_pl_discountpercent_bysaleschannel_format_view 
where taqprojectkey = @i_taqprojectkey
and plstagecode = @i_plstagecode
and taqversionkey = @i_taqversionkey

Select @n_dividend = 100


Select @RETURN = @f_avg_unit_cost/(@f_format_price * (1-(@f_discount_percentage / @n_dividend))) * 100

Select @RETURN = ROUND(@RETURN,1) 

--Select 1.51818/ (26 * (1-50.00 / 100.00))

--Select @RETURN = '(' + CAST(@f_avg_unit_cost as varchar) + '/' + CAST(@f_format_price as varchar) + ') * ((1-' + CAST(@f_discount_percentage as varchar) +' / ' + CAST(@n_dividend as varchar) + ')'


--Unit Cost / Format Price * (1 – (Format Discount % / 100))


	RETURN @RETURN


END

GO
GRANT ALL ON rpt_taq_pl_get_unitcosts_rev to PUBLIC