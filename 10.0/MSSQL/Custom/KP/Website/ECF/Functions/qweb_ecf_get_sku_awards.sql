if exists (select * from dbo.sysobjects where id = object_id(N'[dbo].[qweb_ecf_get_sku_awards]') and OBJECTPROPERTY(id, N'IsScalarFunction') = 1)
drop function [dbo].[qweb_ecf_get_sku_awards]
GO

CREATE function [dbo].[qweb_ecf_get_sku_awards] (@i_bookkey int) 

RETURNS varchar(512)

as

BEGIN

DECLARE @v_awards varchar(512),
		@i_titlefetchstatus int,
		@v_awardsList varchar(8000)
		

	DECLARE c_pss_awards CURSOR
	FOR

	
	Select cbd.dbo.get_gentables_desc_alt1(303,speccode,'D') + ' ' + cbd.dbo.get_gentables_desc(545,awardyearcode,'D')
	from cbd..productspecs
	where specid = 303
	and bookkey = @i_bookkey
	order by awardyearcode desc
	
	FOR READ ONLY
			
	OPEN c_pss_awards
	
	FETCH NEXT FROM c_pss_awards
		INTO @v_awards

	select  @i_titlefetchstatus  = @@FETCH_STATUS

	 while (@i_titlefetchstatus >-1 )
		begin
		IF (@i_titlefetchstatus <>-2) 
		begin

		Select @v_awardsList = ISNULL(@v_awardsList,'') + ISNULL(@v_awards,'') + '<BR>' 

		end


	FETCH NEXT FROM c_pss_awards
		INTO @v_awards
	        select  @i_titlefetchstatus  = @@FETCH_STATUS
		end

close c_pss_awards
deallocate c_pss_awards

Select @v_awardsList = SUBSTRING(@v_awardsList,1,len(@v_awardsList)-4)

RETURN @v_awardsList

END

GO
Grant execute on dbo.qweb_ecf_get_sku_awards to Public
GO