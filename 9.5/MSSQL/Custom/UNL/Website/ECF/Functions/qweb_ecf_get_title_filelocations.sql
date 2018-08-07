/****** Object:  UserDefinedFunction [dbo].[qweb_ecf_get_title_filelocations]    Script Date: 04/13/2009 11:46:22 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

drop function [qweb_ecf_get_title_filelocations] 
go

CREATE function [dbo].[qweb_ecf_get_title_filelocations] (@i_bookkey int) 

RETURNS varchar(max)

as

BEGIN

DECLARE @bookkey int,
		@v_pathname varchar(255),
		@alternatedesc1 varchar(255),
		@i_titlefetchstatus int,
		@result varchar(max)
	
		Set @result = ''

	DECLARE c_pss_titles_filelocations CURSOR
	FOR

	Select fl.bookkey, fl.pathname, gt.alternatedesc1  
	FROM unl..filelocation fl
	JOIN unl..gentables gt
	ON fl.filetypecode = gt.datacode
	where gt.tableid = 354
	and gt.gen1ind = 1
	and fl.printingkey = 1
	and fl.bookkey = @i_bookkey
	and fl.pathname is not null
	and gt.alternatedesc1 is not null
	Order by gt.sortorder

	
	FOR READ ONLY
			
	OPEN c_pss_titles_filelocations
	
	FETCH NEXT FROM c_pss_titles_filelocations
		INTO @i_bookkey, @v_pathname, @alternatedesc1

		select  @i_titlefetchstatus  = @@FETCH_STATUS

		 while (@i_titlefetchstatus >-1 )
			begin
				IF (@i_titlefetchstatus <>-2) 
					begin

--						Select @result = @result + @alternatedesc1 + '|' 
--										 + @v_pathname + '~'
						--Some addresses have ~ in it so dont use that as a seperator
						--Replace all spaces from alt desc with _. 
						--Use |*| and |~| as seperators 
						DECLARE @altdesc varchar(255)
						DECLARE @pathname varchar(255)
						SET @altdesc = REPLACE(LTRIM(RTRIM(@alternatedesc1)), ' ','|~|')
						SET @pathname = REPLACE(LTRIM(RTRIM(@v_pathname)),' ','|~|')
						

						Select @result = @result + @altdesc + '|' 
										 + @pathname + ' '

					end


	FETCH NEXT FROM c_pss_titles_filelocations
	INTO @i_bookkey, @v_pathname, @alternatedesc1
	        select  @i_titlefetchstatus  = @@FETCH_STATUS
		end

close c_pss_titles_filelocations
deallocate c_pss_titles_filelocations

If @result is not null
	Select @result = rtrim(@result)
	--Select @result = SUBSTRING(@result,1,len(@result)-3)

RETURN @result

END