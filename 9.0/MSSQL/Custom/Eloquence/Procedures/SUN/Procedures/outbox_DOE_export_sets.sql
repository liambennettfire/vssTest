
IF EXISTS (SELECT * FROM sysobjects WHERE type = 'P' AND name = 'outbox_DOE_export_sets')
BEGIN
 DROP  Procedure  outbox_DOE_export_sets
END

GO

set ANSI_NULLS ON
set QUOTED_IDENTIFIER ON
go


CREATE procedure [dbo].[outbox_DOE_export_sets] @i_customerkey int

as

DECLARE @v_parentisbn10 varchar(10),
@v_DOScmd varchar (1000),
@i_bookkey int,
@v_publisher varchar(255),
@v_imprint varchar(255),
@v_userinitials varchar(2),
@v_filedate varchar(10),
@v_filename varchar(2000),
@v_isbn13 varchar(13),
@c_dbname varchar(100),
@i_count int

select @c_dbname=db_name()

DECLARE c_setrecs cursor for
		Select distinct parentisbn10
		from outbox_set_records

	open c_setrecs 

	fetch next from c_setrecs into @v_parentisbn10

	while @@FETCH_STATUS<>-1

		begin
--update outbox_set_records set childisbn10='N/A',childisbn13='N/A' where childisbn10 ='' and parentisbn10=@v_parentisbn10	
update outbox_set_records set childisbn10=NULL,childisbn13=NULL where childisbn10 ='' and parentisbn10=@v_parentisbn10			

if exists (select * from dbo.sysobjects where id = object_id(N'[dbo].[temp]') and OBJECTPROPERTY(id, N'IsUserTable') = 1)
drop table [dbo].[temp]

		Create table temp (
		col1 varchar(255),
		col2 varchar(255),
		col3 varchar(255),
		col4 varchar(255),
		col5 varchar(255),
		col6 varchar(255),
		col7 varchar(255),
		col8 varchar(255),
		col9 varchar(255),
		col10 varchar(255))


		insert into temp
		Select ' ',' ',' ',' ','NYC Department of Education','','','','',''

		insert into temp
		Select ' ',' ',' ','Bundle Submission/Price Change Template','','','','','',''

		insert into temp
		select distinct 'Bundle ISBN10 Number (if applicable):',parentisbn10,'','','','','','','',''
		from outbox_set_records
		where parentisbn10 = @v_parentisbn10

		insert into temp
		select distinct 'Bundle ISBN13 Number (if applicable):',parentisbn13,'','','','','','','',''
		from outbox_set_records
		where parentisbn10 = @v_parentisbn10

		insert into temp
		select distinct 'Bundle Name/Title (if applicable):',parenttitle,'','','','','','','',''
		from outbox_set_records
		where parentisbn10 = @v_parentisbn10
	
		insert into temp
		select distinct 'Bundle Price (if applicable):',parentprice,'','','','','','','',''
		from outbox_set_records
		where parentisbn10 = @v_parentisbn10

		insert into temp
		select 
		'BatchID#(Price Changes Only)',
		'NYC DOE Item Number',
		'Original Publisher ISBN 10',
		'Original Publisher ISBN 13 (if applicable)',
		'ComponentTitles',
		'Publisher Name',
		'Individual Published List Price (Trade/Professional Books)',
		'Individual National List Price',
		'Quantity',
		'Item Form'



		insert into temp
		select 
		' ',
		ISNULL(childitemnum,' '),
		ISNULL(childisbn10, ' '),
		ISNULL(childisbn13, ' '),
		ISNULL(childtitle,' '),
		ISNULL(childpublisher,' '),
		ISNULL(childpublistprice,' '),
		ISNULL(childnationallistprice,' '),
		ISNULL(childquantity,' '),
		ISNULL(itemform,' ')
		from outbox_set_records
		where parentisbn10 = @v_parentisbn10		

		-- Build File Name
		--_ParentPublishername_ImprintName_UsersInitialts_ParentISBN#_Date.xls. 
		
		Select @i_bookkey=0
		Select @i_bookkey = count(*)
		from isbn 
		where isbn10 = @v_parentisbn10
		if @i_bookkey > 0 
			select @i_bookkey = bookkey from isbn where isbn10 = @v_parentisbn10 

		Select @v_publisher = customershortname from customer where customerkey=@i_customerkey
		Select @v_imprint = imprint from outbox_Set_records where parentisbn10 = @v_parentisbn10
		Select @v_userinitials = substring(@v_publisher,1,2)
		Select @v_isbn13 = parentisbn13 from outbox_Set_records where parentisbn10 = @v_parentisbn10
		Select @v_filedate = CAST(Right('0' + Convert(VarChar(2), Month(GetDate())), 2) as varchar) + '-' + CAST(Right('0' + Convert(VarChar(2), Day(GetDate())), 2) as varchar) + '-' + CAST(Year(getdate()) as varchar)
		

		Select @v_filename = ISNULL(@v_publisher,'') + '_' + ISNULL(@v_imprint,'') + '_' + ISNULL(@v_userinitials,'') + '_' + ISNULL(@v_isbn13,'')+ '_' + ISNULL(@v_filedate,'')
		
		select @i_count=count(*)  from  elomiscitemdatabyISBN where ean13=@v_isbn13 and elocustomerkey=@i_customerkey and elofieldtag='ZFILENAME'
		if @i_count=0
			insert into elomiscitemdatabyISBN(ean13,elocustomerkey,elofieldtag,miscitemdata,lastuserid,lastmaintdate )  VALUES (@v_isbn13,@i_customerkey,'ZFILENAME',@v_filename,'DOE_export',getdate())
		else
			update elomiscitemdatabyISBN  set miscitemdata=@v_filename,lastuserid='DOE_export',lastmaintdate=getdate() where elofieldtag='ZFILENAME'
		
		print 'BCP: @v_filename'
		print @v_filename
	    	print @i_bookkey

		Select @v_DOScmd = 'bcp "Select * from ' + @c_dbname + '..temp" queryout \\maccoy\ftpsites\eloquenceweb\upload\DOE\000040\' + @v_filename + '.txt' + ' -S MIROSLAV -U qsiadmin -P 666666 -c'
		EXEC master..xp_cmdshell @v_DOScmd

		--Select @v_DOScmd = 'c:\temp\convertxls.exe /Jc:\temp\convertsets.SII /M2 /Lc:\temp\convert.log'
		--EXEC master..xp_cmdshell @v_DOScmd

	  drop table temp
		  
		fetch next from c_setrecs into @v_parentisbn10
		end



	  close c_setrecs 
	  deallocate c_setrecs






