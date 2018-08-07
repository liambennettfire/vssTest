if exists (select * from dbo.sysobjects where id = object_id(N'[dbo].[qweb_ecf_Insert_ProductObjectAccess]') and OBJECTPROPERTY(id, N'IsProcedure') = 1)
drop procedure [dbo].[qweb_ecf_Insert_ProductObjectAccess]
GO


set ANSI_NULLS ON
set QUOTED_IDENTIFIER ON
go

create procedure [dbo].[qweb_ecf_Insert_ProductObjectAccess] (@i_bookkey int) as
DECLARE @i_productid int,
@i_ecfproduct_fetchstatus int

BEGIN

	DECLARE c_ecf_products INSENSITIVE CURSOR
	FOR

	Select productid
	from product
	where code = cast(@i_bookkey as varchar)
	

	FOR READ ONLY
			
	OPEN c_ecf_products

	/* Get next bookkey that has more than one citation row */	
	FETCH NEXT FROM c_ecf_products
		INTO @i_productid

	select  @i_ecfproduct_fetchstatus  = @@FETCH_STATUS

	 while (@i_ecfproduct_fetchstatus >-1 )
		begin
		IF (@i_ecfproduct_fetchstatus <>-2) 
		begin
			
				
	If not exists (Select * from objectaccess where objectid = @i_productid)
			begin

			exec [dbo].[ObjectAccessInsert]
			NULL,		 --@ObjectAccessId int = NULL output,
			@i_productid,--@ObjectId int,
			1,			 --@PrincipalId int,
			1,			 --@ObjectTypeId int,
			1,			 --@AllowLevel tinyint,
			0,			 --@DenyLevel tinyint,
			0			 --@IsInherited bit

			end
		end

	FETCH NEXT FROM c_ecf_products
		INTO @i_productid
	        select  @i_ecfproduct_fetchstatus  = @@FETCH_STATUS
		end

close c_ecf_products
deallocate c_ecf_products


END
