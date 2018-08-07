if exists (select * from dbo.sysobjects where id = object_id(N'[dbo].[qweb_ecf_Insert_CategoryObjectAccess]') and OBJECTPROPERTY(id, N'IsProcedure') = 1)
drop procedure [dbo].[qweb_ecf_Insert_CategoryObjectAccess]
GO


set ANSI_NULLS ON
set QUOTED_IDENTIFIER ON
go

create procedure [dbo].[qweb_ecf_Insert_CategoryObjectAccess] as
DECLARE @i_categoryid int,
@i_ecfcategory_fetchstatus int

BEGIN

	DECLARE c_ecf_categories INSENSITIVE CURSOR
	FOR



	Select categoryid
	from category
	where parentcategoryid <> 0
	and categoryid not in (Select objectid from ObjectAccess)
	

	FOR READ ONLY
			
	OPEN c_ecf_categories

	/* Get next bookkey that has more than one citation row */	
	FETCH NEXT FROM c_ecf_categories
		INTO @i_categoryid

	select  @i_ecfcategory_fetchstatus  = @@FETCH_STATUS

	 while (@i_ecfcategory_fetchstatus >-1 )
		begin
		IF (@i_ecfcategory_fetchstatus <>-2) 
		begin
			
	--Category = sys,category_id,1,3,1,0,1				

	If not exists (Select * from ObjectAccess where objectid = @i_categoryid)

		begin
		exec [dbo].[ObjectAccessInsert]
		NULL,		 --@ObjectAccessId int = NULL output,
		@i_categoryid,--@ObjectId int,
		1,			 --@PrincipalId int,
		3,			 --@ObjectTypeId int,
		1,			 --@AllowLevel tinyint,
		0,			 --@DenyLevel tinyint,
		1			 --@IsInherited bit
		end

	end

	FETCH NEXT FROM c_ecf_categories
		INTO @i_categoryid
	        select  @i_ecfcategory_fetchstatus  = @@FETCH_STATUS
		end

close c_ecf_categories
deallocate c_ecf_categories


END
