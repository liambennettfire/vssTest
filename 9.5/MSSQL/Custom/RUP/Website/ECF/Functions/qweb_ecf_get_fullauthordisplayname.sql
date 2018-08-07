USE [RUP]
GO
/****** Object:  UserDefinedFunction [dbo].[qweb_ecf_get_fullauthordisplayname]    Script Date: 02/12/2013 11:31:33 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO





ALTER function [dbo].[qweb_ecf_get_fullauthordisplayname] (@i_authordisplayname nvarchar(512), @i_bookkey int, @i_includerole bit) 

RETURNS nvarchar(512)

as

BEGIN

DECLARE @v_fullauthordisplayname nvarchar(512),
				@v_authorkey int,
				@v_authortypecode	int,
				@v_firstname	varchar(75),
				@v_middlename	varchar(75),
				@v_lastname	varchar(75),
				@v_degree	varchar(75),
				@v_role	varchar(75)
		
set @v_fullauthordisplayname = @i_authordisplayname

if LEN(RTRIM(LTRIM(COALESCE(@v_fullauthordisplayname, '')))) = 0
begin
	set @v_fullauthordisplayname = ''
	
	DECLARE c_bookauthor CURSOR FOR
	select authorkey, authortypecode
	from rup..bookauthor
	where bookkey = @i_bookkey
	order by primaryind desc, sortorder asc
	
	OPEN c_bookauthor
	
	FETCH NEXT FROM c_bookauthor 
	INTO @v_authorkey, @v_authortypecode
	
	WHILE (@@FETCH_STATUS = 0)
	BEGIN
		select @v_firstname = firstname, @v_middlename = middlename, @v_lastname = lastname, @v_degree = authordegree
		from RUP..author
		where authorkey = @v_authorkey
		
		set @v_role = ''
		select @v_role = datadesc from gentables where tableid = 134 and datacode = @v_authortypecode
		
		if LEN(RTRIM(LTRIM(COALESCE(@v_firstname, '')))) > 0
		begin
			if LEN(RTRIM(LTRIM(COALESCE(@v_fullauthordisplayname, '')))) > 0
			begin
				set @v_fullauthordisplayname = @v_fullauthordisplayname + ', '
			end
			
			set @v_fullauthordisplayname = @v_fullauthordisplayname + @v_firstname
			if LEN(RTRIM(LTRIM(COALESCE(@v_middlename, '')))) > 0
			begin
				set @v_fullauthordisplayname = @v_fullauthordisplayname + ' ' + @v_middlename
			end
			if LEN(RTRIM(LTRIM(COALESCE(@v_lastname, '')))) > 0
			begin
				set @v_fullauthordisplayname = @v_fullauthordisplayname + ' ' + @v_lastname
			end
			if LEN(RTRIM(LTRIM(COALESCE(@v_degree, '')))) > 0
			begin
				set @v_fullauthordisplayname = @v_fullauthordisplayname + ' ' + @v_degree
			end
			if @i_includerole > 0
			begin
				if LEN(RTRIM(LTRIM(COALESCE(@v_role, '')))) > 0
				begin
					set @v_fullauthordisplayname = @v_fullauthordisplayname + ' (' + @v_role + ')'
				end
			end
		end
		
		FETCH NEXT FROM c_bookauthor 
		INTO @v_authorkey, @v_authortypecode
	END
	
	CLOSE c_bookauthor
	DEALLOCATE c_bookauthor
end

RETURN @v_fullauthordisplayname

END







