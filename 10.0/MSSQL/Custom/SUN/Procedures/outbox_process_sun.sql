
IF EXISTS (SELECT * FROM sysobjects WHERE type = 'P' AND name = 'outbox_process_sun')
BEGIN
 DROP  Procedure  [outbox_process_sun]
END

GO

set ANSI_NULLS ON
set QUOTED_IDENTIFIER ON
go


CREATE procedure [dbo].[outbox_process_sun]
(@i_bookkey int,
@i_printingkey int,
@i_edistatuscode int,
@i_file_name varchar(255),
@i_filekey int,
@i_elo_cutomer_num varchar(100))

AS

DECLARE
@i_internalstatus_qsicode int,
@i_linklevelcode int,
@i_current_edistatuscode int,
@i_seqcount int,
@i_totalcount int,
@initialstepcount int,
@v_DOScmd varchar (500),
@v_ftp_SET_Filename varchar(255),
@v_ftp_CMT_Filename varchar(255),
@f_parent_price money,
@i_error_commenttypesubcode int,
@c_TOservername varchar(25),
@c_TOserveruserid varchar(25),
@c_TOserverpassword varchar(25),
@c_TOdestinationfolder varchar(50),
@c_FROMServername varchar(200),
@c_FROMDatabase varchar(50),
@c_eloqcustomerid  varchar(6),
@c_destination_folder varchar(200),
@i_setindicator int


BEGIN

Select @i_current_edistatuscode = edistatuscode
	from bookedistatus b
	where bookkey = @i_bookkey

Select @c_TOservername = substring(servername,1,25) ,@c_TOserveruserid=substring(serveruserid,1,12),@c_TOserverpassword=substring(serverpassword,1,12) from ftpdata where elocustomerkey=@i_elo_cutomer_num


Select @c_FROMServername = @@servername
Select @c_FROMDatabase = db_name()

Select @c_eloqcustomerid = eloqcustomerid from customer where customerkey=convert(int,LTRIM(RTRIM(@i_elo_cutomer_num)))

select @c_destination_folder = '/upload/DOE/' + @c_eloqcustomerid + '/'

Select @i_error_commenttypesubcode = datasubcode
from subgentables
where tableid = 284
and qsicode = 2

------------ PRE PROCESS

Select @initialstepcount = stepcount from outbox_procseq

	If @initialstepcount = 0

	begin

		delete from outbox_DOEBundleFeedStaging
		delete from outbox_CMTISBNS

		update outbox_procseq
		set totaltitles = (SELECT count(bookedistatus.bookkey)
			FROM bookedipartner,   
				 bookedistatus,   
				 book  
		   WHERE ( bookedipartner.edipartnerkey = bookedistatus.edipartnerkey ) and  
				 ( bookedipartner.bookkey = bookedistatus.bookkey ) and  
				 ( bookedipartner.printingkey = bookedistatus.printingkey ) and  
				 ( bookedistatus.bookkey = book.bookkey ) and  
				 ( ( bookedipartner.sendtoeloquenceind = 1 ) AND  
				 ( bookedistatus.edistatuscode in (1,3,6) ) ) )
	end

------------ END PRE PROCESS

-- if the first title is a successful send, the status has already changed and we'll take that into account here

	If @initialstepcount = 0 and @i_current_edistatuscode = 4
		begin
			update outbox_procseq
			set totaltitles = totaltitles + 1,
			    stepcount = stepcount + 1

		end
	else
		begin
			update outbox_procseq
			set stepcount = stepcount + 1
		end


	Select @i_seqcount = stepcount from outbox_procseq
	Select @i_totalcount = totaltitles from outbox_procseq


/*
		insert into sun_bundlefeedtemp
		Select 
		@i_bookkey,
		@i_printingkey,
		@i_edistatuscode,
		@i_file_name,
		@i_filekey,
		@i_elo_cutomer_num,
		'',
		0,
		getdate()

		update sun_bundlefeedtemp
		set title = b.title
		from book b
		where sun_bundlefeedtemp.i_bookkey = b.bookkey

		update sun_bundlefeedtemp
		set edistatuscode = b.edistatuscode
		from bookedistatus b
		where sun_bundlefeedtemp.i_bookkey = b.bookkey

*/


		Select @i_internalstatus_qsicode = g.qsicode
			from book b, gentables g
			where b.titlestatuscode = g.datacode
			and g.tableid = 149
			and bookkey = @i_bookkey

		Select @i_linklevelcode = linklevelcode
			from book
			where bookkey = @i_bookkey
			
		if @i_linklevelcode = 30
			select @i_setindicator = 1
		else
			select @i_setindicator = 0


-- If Internal Status is Send/Resend to DOE
		If @i_current_edistatuscode = 4   
		and @i_internalstatus_qsicode in (3,5) 
		

			begin

			insert into outbox_CMTISBNS 
			Select i.ean13,@i_setindicator, 'qsi', getdate()
			from isbn i
			where bookkey = @i_bookkey

			--change internal status only if NOT a SET. Internal Status will be changed in later section for SETs
			if  @i_linklevelcode <> 30
			begin
				update book 
				set titlestatuscode = g.datacode
				from gentables g
				where tableid = 149
				and g.qsicode = 4 
		   	 	and bookkey = @i_bookkey

				insert into titlehistory (bookkey, printingkey, columnkey, lastmaintdate, stringvalue, lastuserid, currentstringvalue, fielddesc)
				Select @i_bookkey,1,2,getdate(),datadesc,'BundleFeed',datadesc, 'Internal Status'
				from gentables
				where tableid = 149
				and qsicode = 4
			
			end
		

			-- clear old error

			delete from bookcomments 
			where commenttypecode = 4 
			and commenttypesubcode = @i_error_commenttypesubcode 
			and bookkey = @i_bookkey
	

			end

-- Send/Resend to DOE and not in outbox

		Else if @i_current_edistatuscode in (1,3) -- Title not sent, Resend
		    and @i_internalstatus_qsicode = 3
		    
			
			begin


			-- clear old error
			delete from bookcomments 
			where commenttypecode = 4 
			and commenttypesubcode = @i_error_commenttypesubcode
			and bookkey = @i_bookkey

			insert into bookcomments 
			(bookkey, 
			printingkey, 
			commenttypecode, 
			commenttypesubcode, 
			commentstring, 
			commenttext, 
			lastuserid, 
			lastmaintdate, 
			releasetoeloquenceind, 
			commenthtml, 
			commenthtmllite, 
			invalidhtmlind)

			Select 
			@i_bookkey, 
			1, 
			4, 
			@i_error_commenttypesubcode, 
			'Title was not sent to DOE because of an eloquence error on ' + Cast(getdate() as varchar) + '.  Please correct error in outbox then resend.',
			'Title was not sent to DOE because of an eloquence error on ' + Cast(getdate() as varchar) + '.  Please correct error in outbox then resend.',
			'outbox_proc',
			getdate(),
			0,
			'<DIV><FONT face="Times New Roman">Title was not send to DOE because of an eloquence error on ' + Cast(getdate() as varchar) + '.  Please look up error in outbox to resend.</FONT></DIV>',
			'<DIV>Title was not send to DOE because of an eloquence error on ' + Cast(getdate() as varchar) + '.  Please look up error in outbox to resend.</DIV>',
			0

			--Set to Error in send to DOE
			update book 
			set titlestatuscode = g.datacode
			from gentables g
			where tableid = 149
			and g.qsicode = 5 
		    and bookkey = @i_bookkey

			insert into titlehistory (bookkey, printingkey, columnkey,lastmaintdate, stringvalue, lastuserid, currentstringvalue, fielddesc)
			Select @i_bookkey,1,2,getdate(),datadesc,'BundleFeed',datadesc, 'Internal Status'
			from gentables
			where tableid = 149
			and qsicode = 5
		

			

			end

-- IS A SET and "Send/Resend to DOE" and successful eloq send
		if @i_current_edistatuscode = 4 
		    and @i_internalstatus_qsicode in (3,5)
		    and @i_linklevelcode = 30


			begin

			SELECT @f_parent_price = finalprice + floatvalue
			from bookprice bp, bookmisc b 
			where bp.pricetypecode = 21 
			and bp.currencytypecode = 6
			and b.misckey = 5 
			and b.bookkey =bp.bookkey
			and b.bookkey = @i_bookkey

			Insert into outbox_DOEBundleFeedStaging 
			(parentbookkey, 
			childbookkey, 
			parentisbn10, 
			parentisbn13, 
			parenttitle, 
			parentprice, 
			childitemnum, 
			childisbn10, 
			childisbn13, 
			childtitle, 
			childpublisher, 
			childpublistprice, 
			childnationallistprice, 
			childquantity, 
			itemform,
			sortorder,
			imprint)
			Select 
			parentbookkey,
			childbookkey,
			dbo.get_isbn(parentbookkey, 10),
			dbo.get_isbn(parentbookkey, 17),
			dbo.get_title(parentbookkey, 'F'),
			@f_parent_price,
			dbo.get_isbn(childbookkey, 22),
			dbo.get_isbn(childbookkey, 10),
			dbo.get_isbn(childbookkey, 17),
			dbo.get_title(childbookkey, 'F'),
			dbo.get_GroupLevel2(childbookkey,'F'),
			dbo.get_BestUSPrice(childbookkey,8),
			dbo.get_BestUSPrice(childbookkey,8),
			quantity,
			dbo.get_Format(childbookkey,'1'),
			sortorder,
			dbo.get_GroupLevel3(childbookkey,'1')
			from bookfamily 
			where parentbookkey = @i_bookkey
			and parentbookkey <> childbookkey and relationcode=20001
			order by sortorder


			update book 
			set titlestatuscode = g.datacode
			from gentables g
			where tableid = 149
			and g.qsicode = 4 --Sent to DOE
		    and bookkey = @i_bookkey

			insert into titlehistory (bookkey, printingkey, columnkey,lastmaintdate, stringvalue, lastuserid, currentstringvalue, fielddesc)
			Select @i_bookkey,1,2,getdate(),datadesc,'BundleFeed',datadesc, 'Internal Status'
			from gentables
			where tableid = 149
			and qsicode = 4
		


			-- clear old error

			delete from bookcomments 
			where commenttypecode = 4 
			and commenttypesubcode = @i_error_commenttypesubcode 
			and bookkey = @i_bookkey

		
			end

			-- IS A SET and "Send/Resend to DOE" and unsuccessful eloq send
		Else if @i_current_edistatuscode in (1,3)  -- 'title not sent', 'Resend'
		    and @i_internalstatus_qsicode = 3
		    and @i_linklevelcode = 30

			begin

			
			-- clear old error
			delete from bookcomments 
			where commenttypecode = 4 
			and commenttypesubcode = @i_error_commenttypesubcode
			and bookkey = @i_bookkey

			insert into bookcomments 
			(bookkey, 
			printingkey, 
			commenttypecode, 
			commenttypesubcode, 
			commentstring, 
			commenttext, 
			lastuserid, 
			lastmaintdate, 
			releasetoeloquenceind, 
			commenthtml, 
			commenthtmllite, 
			invalidhtmlind)


			Select 
			@i_bookkey, 
			1, 
			4, 
			@i_error_commenttypesubcode, 
			'Title was not sent to DOE because of an eloquence error on ' + Cast(getdate() as varchar) + '.  Please correct error in outbox then resend.',
			'Title was not sent to DOE because of an eloquence error on ' + Cast(getdate() as varchar) + '.  Please correct error in outbox then resend.',
			'outbox_proc',
			getdate(),
			0,
			'<DIV><FONT face="Times New Roman">Title was not sent to DOE because of an eloquence error on ' + Cast(getdate() as varchar) + '.  Please correct error in outbox then resend.</FONT></DIV>',
			'<DIV>Title was not sent to DOE because of an eloquence error on ' + Cast(getdate() as varchar) + '.  Please correct error in outbox then resend.</DIV>',
			0

			update book 
			set titlestatuscode = g.datacode
			from gentables g
			where tableid = 149
			and g.qsicode = 5 --Error in send to DOE
		    and bookkey = @i_bookkey

			insert into titlehistory (bookkey, printingkey, columnkey, lastmaintdate, stringvalue, lastuserid, currentstringvalue, fielddesc)
			Select @i_bookkey,1,2,getdate(),datadesc,'BundleFeed',datadesc, 'Internal Status'
			from gentables
			where tableid = 149
			and qsicode = 5
		

			end

-------------- POST PROCESSING

		If @i_seqcount = @i_totalcount
			begin
				update outbox_procseq 
				set success = 1,
				stepcount = 0
				where stepcount = totaltitles

				Select @v_DOScmd = 'bcp "Select * from ' + @c_FROMdatabase + '..outbox_DOEBundleFeedStaging" queryout c:\temp\' + @i_file_name + '.SET' + ' -S ' + @c_FROMservername + '  -U qsiadmin -P 666666 -c'
				EXEC master..xp_cmdshell @v_DOScmd
				select @v_DOScmd= 'bcp "Select * from ' + @c_FROMdatabase + '..outbox_CMTISBNS" queryout c:\temp\' + @i_file_name + '.CMT' + ' -S ' + @c_FROMservername + '  -U qsiadmin -P 666666 -c'
				--Select @v_DOScmd = 'bcp "Select * from SUN..outbox_CMTISBNS" queryout c:\temp\' + @i_file_name + '.CMT' + ' -S MOUNTAIN -U qsiadmin -P 666666 -c'
				EXEC master..xp_cmdshell @v_DOScmd

				Select @v_ftp_SET_Filename = ISNULL(@i_file_name,'') + '.SET'

				Select @v_ftp_CMT_Filename = ISNULL(@i_file_name,'') + '.CMT'
			

				exec outbox_ftp_PutFile
						@c_TOservername ,
						@c_TOserveruserid ,
						@c_TOserverpassword ,
						@c_destination_folder ,
						@v_ftp_SET_Filename,
						'c:\temp\' ,
						@v_ftp_SET_Filename,
						'c:\temp\'

				exec outbox_ftp_PutFile
						@c_TOservername ,
						@c_TOserveruserid ,
						@c_TOserverpassword ,
						@c_destination_folder ,
						@v_ftp_CMT_Filename,
						'c:\temp\' ,
						@v_ftp_CMT_Filename,
						'c:\temp\'
			end


		END


