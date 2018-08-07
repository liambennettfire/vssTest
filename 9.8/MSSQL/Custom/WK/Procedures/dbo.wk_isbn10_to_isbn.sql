if exists (select * from dbo.sysobjects where id = object_id(N'dbo.[wk_isbn10_to_isbn]') and OBJECTPROPERTY(id, N'IsProcedure') = 1)
  drop procedure dbo.[wk_isbn10_to_isbn]
GO

CREATE procedure [dbo].[wk_isbn10_to_isbn] 
as

Begin

DECLARE @i_bookkey as int,
		@i_isbn10 as varchar(25),
		@o_new_string       VARCHAR(25),
		@o_error_code       INT,
		@o_error_desc       VARCHAR(2000)

-- CURSOR STUB

DECLARE cursor_isbn INSENSITIVE CURSOR
FOR
	select bookkey, isbn10 
	from isbn 
	where isbn10 is not null
	and isbn10 is not null and isbn is null
	--and bookkey = 14470193
FOR READ ONLY

OPEN cursor_isbn 

FETCH NEXT FROM cursor_isbn 
INTO @i_bookkey, @i_isbn10

while (@@FETCH_STATUS<>-1 )
begin
	IF (@@FETCH_STATUS<>-2)
	begin

	exec [dbo].[qean_validate_product]
	  @i_isbn10,
	  0,
	  0,
	  @i_bookkey,
	  @o_new_string output, 
	  @o_error_code output,      
	  @o_error_desc output      

update isbn
set isbn = @o_new_string
where bookkey = @i_bookkey

end

	FETCH NEXT FROM cursor_isbn
INTO @i_bookkey, @i_isbn10
        
end

close cursor_isbn
deallocate cursor_isbn

-- END OF CURSOR STUB

END