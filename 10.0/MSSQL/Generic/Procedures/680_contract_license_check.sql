if exists (select * from dbo.sysobjects where id = object_id(N'[dbo].[contract_license_check]') and OBJECTPROPERTY(id, N'IsProcedure') = 1)
drop procedure [dbo].[contract_license_check]
GO

SET QUOTED_IDENTIFIER ON 
GO
SET ANSI_NULLS ON 
GO


create  procedure contract_license_check
as
BEGIN

DECLARE
@v_cnt int,
@v_misc_key int,
@v_cnt_misc int,
@v_bookkey int,
@v_lic_status int,
@v_licensecontractkey int,
@v_licenseexpirationtype int

DECLARE  c_book CURSOR FOR
select distinct bookkey
from contractbooklicense

DECLARE  c_license CURSOR FOR
select licensecontractkey, licenseexpirationtype
from contractbooklicense
where bookkey = @v_bookkey


BEGIN

select @v_misc_key = bookmiscitems.misckey
from bookmiscitems
where qsicode = 1

OPEN c_book 
FETCH NEXT FROM c_book INTO @v_bookkey
if  @@FETCH_STATUS = -1 begin
return
end 
WHILE @@FETCH_STATUS = 0
BEGIN 

  select @v_cnt_misc = count(*)
  from bookmisc
  where bookkey = @v_bookkey
  and misckey = @v_misc_key

  if @v_cnt_misc = 0 begin
    insert into bookmisc (bookkey, misckey, longvalue, floatvalue,textvalue, lastuserid, lastmaintdate, sendtoeloquenceind)
    values(@v_bookkey, @v_misc_key, 0, null, null, 'qsidba', getdate(), 0)
  end
	OPEN c_license 
	FETCH NEXT FROM c_license INTO @v_licensecontractkey, @v_licenseexpirationtype
	if  @@FETCH_STATUS = -1 begin
	return
	end 
	WHILE @@FETCH_STATUS = 0
	BEGIN 
		select @v_lic_status = count(licensestatus)
		from contractbooklicense
		where contractbooklicense.bookkey = @v_bookkey
		and contractbooklicense.licensecontractkey = @v_licensecontractkey
		
		if @v_lic_status = 0 
		begin
		    update bookmisc
		    set longvalue = 0, lastuserid = 'qsidba', lastmaintdate = getdate()
		    where bookkey = @v_bookkey
		    and misckey = @v_misc_key
		    goto next_lic
		end
		
		if @v_licenseexpirationtype in (2, 3, 4)  -- pub, on sign and sepcific end date
		begin
		        select @v_cnt = count(contractbooklicense.bookkey)
		        from CONTRACTBOOKLICENSE
		        where licensestatus = 1
		        and contractbooklicense.bookkey in (select bookdetail.bookkey
		                                            from bookdetail
		                                            where bookdetail.bookkey = contractbooklicense.bookkey
		                                            and bookdetail.bisacstatuscode in( select datacode
		                                                                               from gentables
		                                                                               where tableid = 314
		                                                                               and datacode in(1, 4, 7, 10)))
		        and contractbooklicense.bookkey = @v_bookkey
		        and contractbooklicense.licensecontractkey = @v_licensecontractkey
		        and expirationdate + 180 >  getdate()
		end        
		else if  @v_licenseexpirationtype in (6)   --no of copies
		begin
		        select @v_cnt = count(contractbooklicense.bookkey)
		        from CONTRACTBOOKLICENSE
		        where licensestatus = 1
		        and contractbooklicense.bookkey in (select bookdetail.bookkey
		                                            from bookdetail
		                                            where bookdetail.bookkey = contractbooklicense.bookkey
		                                            and bookdetail.bisacstatuscode in( select datacode
		                                                                               from gentables
		                                                                               where tableid = 314
		                                                                               and datacode in(1, 4, 7, 10)))
		        and contractbooklicense.bookkey = @v_bookkey
		        and contractbooklicense.licensecontractkey = @v_licensecontractkey
		        and numberofcopies * .66 < (select sum(isnull(quantity, 0))
		                                    from pohistory
		                                    where bookkey = @v_bookkey
		                                    and printingkey = 1)
		end                                  
		else if  @v_licenseexpirationtype in (5)   -- Printing No. 
		begin
		        select @v_cnt = count(contractbooklicense.bookkey)
		        from CONTRACTBOOKLICENSE
		        where licensestatus = 1
		        and contractbooklicense.bookkey in (select bookdetail.bookkey
		                                            from bookdetail
		                                            where bookdetail.bookkey = contractbooklicense.bookkey
		                                            and bookdetail.bisacstatuscode in( select datacode
		                                                                               from gentables
		                                                                               where tableid = 314
		                                                                               and datacode in(1, 4, 7, 10)))
		        and contractbooklicense.bookkey = @v_bookkey
		        and contractbooklicense.licensecontractkey = @v_licensecontractkey
		        and expirationprtgnum - (select printingnum from printing where bookkey = @v_bookkey and printingkey = 1) < 2
		end        
		else if  @v_licenseexpirationtype in (1)  -- Full Term 
		begin
		    set @v_cnt = 0
		end
		
		if @v_cnt > 0  --check box checked
		begin
		  update bookmisc
		  set longvalue = 1, lastuserid = user, lastmaintdate = getdate()
		  where bookkey = @v_bookkey
		  and misckey = @v_misc_key
		  goto next_book
		end
		else  --check box unchecked
		begin
		  update bookmisc
		  set longvalue = 0, lastuserid = user, lastmaintdate = getdate()
		  where bookkey = @v_bookkey
		  and misckey = @v_misc_key
		end
		
		next_lic:
		set @v_cnt = 0
		FETCH NEXT FROM c_license INTO @v_licensecontractkey, @v_licenseexpirationtype 
  	END --inner loop
next_book:
CLOSE c_license
FETCH NEXT FROM c_book INTO @v_bookkey
END --outer loop

CLOSE c_license
CLOSE c_book

END
END


GO
SET QUOTED_IDENTIFIER OFF 
GO
SET ANSI_NULLS ON 
GO

