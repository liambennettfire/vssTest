
declare
@v_misckey integer,
@v_orglevelkey integer,
@v_orgentrykey integer,
@v_calcsql varchar(8000)

DECLARE calcsql_cur CURSOR FOR 
SELECT misckey, orglevelkey, orgentrykey, calcsql
FROM miscitemcalc
FOR READ ONLY


begin

   open calcsql_cur
   FETCH NEXT FROM calcsql_cur into @v_misckey, @v_orglevelkey, @v_orgentrykey, @v_calcsql
 	WHILE (@@FETCH_STATUS <> -1) BEGIN

	set @v_calcsql = REPLACE (@v_calcsql , 'from dual' , '' )

	update miscitemcalc
	set calcsql = @v_calcsql
	where misckey = @v_misckey
	and orglevelkey = @v_orglevelkey
	and orgentrykey = @v_orgentrykey

	FETCH NEXT FROM calcsql_cur into @v_misckey, @v_orglevelkey, @v_orgentrykey, @v_calcsql
   END 
close calcsql_cur
deallocate calcsql_cur	
end
go

