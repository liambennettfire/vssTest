/****** Object:  StoredProcedure [dbo].[hna_calc_binding_vendor_sp]    Script Date: 04/07/2015 16:41:17 ******/
IF  EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[hna_calc_binding_vendor_sp]') AND type in (N'P', N'PC'))
DROP PROCEDURE [dbo].[hna_calc_binding_vendor_sp]
GO

/****** Object:  StoredProcedure [dbo].[hna_calc_binding_vendor_sp]    Script Date: 04/07/2015 16:41:17 ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO

CREATE procedure [dbo].[hna_calc_binding_vendor_sp] 
(
@bookkey int,
@printingkey int,
@result varchar(75) OUTPUT
)
as
begin

DECLARE
@v_vendorname varchar(75),
@v_countrycode varchar(75),
@i_exists int

select @v_vendorname = [dbo].[rpt_get_printing_taqversionspeccategory_vendorname] (@bookkey,1,5,'G')

--new style
IF coalesce(@v_vendorname,'')<>''
	BEGIN
	
	select @result =  @v_vendorname+ ', '+[dbo].[rpt_get_printing_taqversionspeccategory_vendorname] (@bookkey,1,5,'C')
	select @v_countrycode = [dbo].[rpt_get_printing_taqversionspeccategory_vendorname] (@bookkey,1,5,'CC')
	
	--select @i_exists =  count(*) from bookmisc where bookkey=@bookkey and misckey=6
	
	--IF coalesce(@i_exists,0)>0
	--	update bookmisc set longvalue = @v_countrycode 
	--	where misckey=6 and bookkey = @bookkey 
	
	--IF coalesce(@i_exists,0)=0
	--	insert into bookmisc (bookkey,misckey,longvalue,lastuserid,lastmaintdate,sendtoeloquenceind)
	--	select @bookkey,6,cast(@v_countrycode as int),'FBTCC',GETDATE(),0
		
	END

ELSE select @result =''

----old style - check for vendor
--IF coalesce(@result,'')=''
--	Select @result =  v.name From bindingspecs bs
--	join vendor v
--	on bs.vendorkey = v.vendorkey 
--	where bs.bookkey = @bookkey
--	and bs.printingkey = 1 

--IF coalesce(@result,'')=''
--	Select printercountry from hna_printerinfo_view where bookkey = @bookkey

end

GO

grant execute on dbo.hna_calc_binding_vendor_sp to public
go
