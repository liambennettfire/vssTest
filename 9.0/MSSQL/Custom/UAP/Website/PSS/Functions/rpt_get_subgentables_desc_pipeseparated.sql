

CREATE function [dbo].[rpt_get_subgentables_desc_pipeseparated] 
(@globalcontactkey int,
@tableid int,
@datacode smallint
) 
/*
This function returns pipe seperated list of subgentable entries for a globalcontact
e.g. contact relationships, contact subjects, contact methods, etc..where multiple values 
can be added from TMM


*/
RETURNS varchar(max)

as

BEGIN

DECLARE @datadesc varchar(120),
		@i_titlefetchstatus int,
		@result varchar(max)
	

		Set @result = ''

	DECLARE c_pss_contactcategory_desc CURSOR
	FOR

	Select dbo.[rpt_get_subgentables_desc](@tableid,@datacode,contactcategorysubcode,'long') 
	FROM globalcontactcategory
	WHERE globalcontactkey = @globalcontactkey
	and contactcategorycode = @datacode


	
	FOR READ ONLY
			
	OPEN c_pss_contactcategory_desc
	
	FETCH NEXT FROM c_pss_contactcategory_desc
		INTO @datadesc

		select  @i_titlefetchstatus  = @@FETCH_STATUS

		 while (@i_titlefetchstatus >-1 )
			begin
				IF (@i_titlefetchstatus <>-2) 
					begin


						Select @result = @result + @datadesc + ' | ' 

					end


	FETCH NEXT FROM c_pss_contactcategory_desc
	INTO @datadesc
	        select  @i_titlefetchstatus  = @@FETCH_STATUS
		end

close c_pss_contactcategory_desc
deallocate c_pss_contactcategory_desc

If @result is not null and @result <> ''
	Select @result = rtrim(@result)
	--Select @result = SUBSTRING(@result,1,len(@result)-3)

RETURN @result

END





