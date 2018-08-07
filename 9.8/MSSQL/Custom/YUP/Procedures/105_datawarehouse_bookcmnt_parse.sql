PRINT 'STORED PROCEDURE : dbo.datawarehouse_bookcmnt_parse'
GO

if exists (select * from dbo.sysobjects where id = Object_id('dbo.datawarehouse_bookcmnt_parse') and (type = 'P' or type = 'RF'))
begin
 drop proc dbo.datawarehouse_bookcmnt_parse
end

GO

CREATE  proc dbo.datawarehouse_bookcmnt_parse
@ware_bookkey int, @ware_logkey int, @ware_warehousekey int,
@ware_system_date datetime,@ware_commenttypecode int,@ware_commenttypesubcode int,
@ware_beginline int,@ware_endline int,@ware_commentline int,@ware_releasetoeloq varchar

AS 

DECLARE @out_val VARCHAR(8000) 
DECLARE @out_length INTEGER  
DECLARE @ll_length int
DECLARE @ll_begin int 

DECLARE @ware_length int 
DECLARE @ware_length2 int 
DECLARE @ware_totallength int 
DECLARE @ware_commenttext  varchar(4000)
DECLARE @ware_commenttexttot  varchar(4000) 

SELECT @ware_commenttexttot = commenttext 
FROM bookcomments 
WHERE bookkey = @ware_bookkey
and printingkey = 1
and commenttypecode = @ware_commenttypecode 
and commenttypesubcode = @ware_commenttypesubcode


 
  IF @ware_commentline > 0 
    begin
	select @ll_begin = @ware_beginline
	if @ll_begin > 0 and @ware_endline > 0 
	  begin
		select @ll_length = @ware_endline - @ll_begin  + 1
		if @ll_length < 1 /* no need to check if greater it will get up to length of comment and no more*/
		  begin
			select @ll_length = @ll_begin  /*use begin length*/	
		  end
	  end
	if @ll_begin > 0 and @ware_endline = 0 
	  begin
		select @ll_length = @ll_begin  /*no end so use begin*/
	  end
	if @ll_begin = 0 /* get defaults*/
	  begin
		select @ll_begin = 1
		select @ll_length = 4000
	   end

	select @ware_totallength = datalength(@ware_commenttexttot)
	if @ll_length > @ware_totallength 
	  begin
		select @out_length = @ware_totallength 
	  end
	else
	  begin
		select @out_length = @ll_length
	  end

	 IF @ware_totallength >= @ll_begin 
	   begin

		select @ware_commenttext = substring(@ware_commenttexttot,@ll_begin,@ll_length)
		select @ware_length2 = 0
		select @ware_length2 = datalength(@ware_commenttext)
	   IF @ware_length2> 0 
		begin
BEGIN tran
			if @ware_commentline = 1 
			  begin
				update whtitlecomments
					set commenttext1 = @ware_commenttext,
						releloind1 = @ware_releasetoeloq
						where bookkey= @ware_bookkey
			  end
			if @ware_commentline = 2 	
			   begin
				update whtitlecomments
					set commenttext2 = @ware_commenttext,
						releloind2 = @ware_releasetoeloq
						where bookkey= @ware_bookkey
			  end
			if @ware_commentline = 3 
			  begin
				update whtitlecomments
					set commenttext3 = @ware_commenttext,
						releloind3 = @ware_releasetoeloq
						where bookkey= @ware_bookkey
			  end
			if @ware_commentline = 4 
			  begin
				update whtitlecomments
					set commenttext4 = @ware_commenttext,
						releloind4 = @ware_releasetoeloq
						where bookkey= @ware_bookkey
			  end
			if @ware_commentline = 5 
			  begin
				update whtitlecomments
					set commenttext5 = @ware_commenttext,
						releloind5 = @ware_releasetoeloq
						where bookkey= @ware_bookkey
			  end
			if @ware_commentline = 6 
			   begin
				update whtitlecomments
					set commenttext6 = @ware_commenttext,
						releloind6 = @ware_releasetoeloq
						where bookkey= @ware_bookkey
			  end
			if @ware_commentline = 7 
			  begin
				update whtitlecomments
					set commenttext7 = @ware_commenttext,
						releloind7 = @ware_releasetoeloq
						where bookkey= @ware_bookkey
			  end
			if @ware_commentline = 8 
			  begin
				update whtitlecomments
					set commenttext8 = @ware_commenttext,
						releloind8 = @ware_releasetoeloq
						where bookkey= @ware_bookkey
			  end
			if @ware_commentline = 9 
			  begin
				update whtitlecomments
					set commenttext9 = @ware_commenttext,
						releloind9 = @ware_releasetoeloq
						where bookkey= @ware_bookkey
			  end
			if @ware_commentline = 10 
				begin
				update whtitlecomments
					set commenttext10 = @ware_commenttext,
						releloind10 = @ware_releasetoeloq
						where bookkey= @ware_bookkey
			  end
			if @ware_commentline = 11 
			  begin
				update whtitlecomments
					set commenttext11 = @ware_commenttext,
						releloind11 = @ware_releasetoeloq
						where bookkey= @ware_bookkey
			  end
			if @ware_commentline = 12 
			  begin
				update whtitlecomments
					set commenttext12 = @ware_commenttext,
						releloind12 = @ware_releasetoeloq
						where bookkey= @ware_bookkey
			  end
			if @ware_commentline = 13 
			  begin
				update whtitlecomments
					set commenttext13 = @ware_commenttext,
						releloind13 = @ware_releasetoeloq
						where bookkey= @ware_bookkey
			  end
			if @ware_commentline = 14 
			  begin
				update whtitlecomments
					set commenttext14 = @ware_commenttext,
						releloind14 = @ware_releasetoeloq
						where bookkey= @ware_bookkey			
			  end
			if @ware_commentline = 15 
			  begin
				update whtitlecomments
					set commenttext15 = @ware_commenttext,
						releloind15 = @ware_releasetoeloq
						where bookkey= @ware_bookkey
			  end
			if @ware_commentline = 16 
			  begin
				update whtitlecomments
					set commenttext16 = @ware_commenttext,
						releloind16 = @ware_releasetoeloq
						where bookkey= @ware_bookkey
			  end
			if @ware_commentline = 17 
			  begin
				update whtitlecomments
					set commenttext17 = @ware_commenttext,
						releloind17 = @ware_releasetoeloq
						where bookkey= @ware_bookkey
			  end
			if @ware_commentline = 18 
			  begin
				update whtitlecomments
					set commenttext18 = @ware_commenttext,
						releloind18 = @ware_releasetoeloq
						where bookkey= @ware_bookkey
			  end
			if @ware_commentline = 19
			   begin
				update whtitlecomments
					set commenttext19 = @ware_commenttext,
						releloind19 = @ware_releasetoeloq
						where bookkey= @ware_bookkey
			  end
			if @ware_commentline = 20 
			  begin
				update whtitlecomments
					set commenttext20 = @ware_commenttext,
						releloind20 = @ware_releasetoeloq
						where bookkey= @ware_bookkey
			  end
			if @ware_commentline = 21 
			  begin
				update whtitlecomments
					set commenttext21 = @ware_commenttext,
						releloind21 = @ware_releasetoeloq
						where bookkey= @ware_bookkey
			  end
			if @ware_commentline = 22 
			  begin
				update whtitlecomments
					set commenttext22 = @ware_commenttext,
						releloind22 = @ware_releasetoeloq
						where bookkey= @ware_bookkey
			  end
			if @ware_commentline = 23 
			  begin
				update whtitlecomments
					set commenttext23 = @ware_commenttext,	
						releloind23 = @ware_releasetoeloq
						where bookkey= @ware_bookkey
			  end
			if @ware_commentline = 24 
			  begin
				update whtitlecomments
					set commenttext24 = @ware_commenttext,
						releloind24 = @ware_releasetoeloq
						where bookkey= @ware_bookkey
			  end
			if @ware_commentline = 25 
			  begin
				update whtitlecomments
					set commenttext25 = @ware_commenttext,
						releloind25 = @ware_releasetoeloq
						where bookkey= @ware_bookkey
			  end
			if @ware_commentline = 26 
			  begin
				update whtitlecomments
					set commenttext26 = @ware_commenttext,
						releloind26 = @ware_releasetoeloq
						where bookkey= @ware_bookkey
			  end
			if @ware_commentline = 27 
			  begin
				update whtitlecomments
					set commenttext27 = @ware_commenttext,
						releloind27 = @ware_releasetoeloq
						where bookkey= @ware_bookkey
			  end
			if @ware_commentline = 28 
			  begin				
				update whtitlecomments
					set commenttext28 = @ware_commenttext,
						releloind28 = @ware_releasetoeloq
						where bookkey= @ware_bookkey
			  end
			if @ware_commentline = 29 
			  begin
				update whtitlecomments
					set commenttext29 = @ware_commenttext,
						releloind29 = @ware_releasetoeloq
						where bookkey= @ware_bookkey
			  end
			if @ware_commentline = 30 
			  begin
				update whtitlecomments
					set commenttext30 = @ware_commenttext,
						releloind30 = @ware_releasetoeloq
						where bookkey= @ware_bookkey
			  end
			if @ware_commentline = 31 
			  begin
				update whtitlecomments
					set commenttext31 = @ware_commenttext,
						releloind31 = @ware_releasetoeloq
						where bookkey= @ware_bookkey
			  end
			if @ware_commentline = 32 
			  begin
				update whtitlecomments
					set commenttext32 = @ware_commenttext,
						releloind32 = @ware_releasetoeloq
						where bookkey= @ware_bookkey
			  end
			if @ware_commentline = 33 
			  begin
				update whtitlecomments
					set commenttext33 = @ware_commenttext,
						releloind33 = @ware_releasetoeloq
						where bookkey= @ware_bookkey
			  end
			if @ware_commentline = 34 
			  begin
				update whtitlecomments
					set commenttext34 = @ware_commenttext,
						releloind34 = @ware_releasetoeloq
						where bookkey= @ware_bookkey
			  end
			if @ware_commentline = 35 
			  begin
				update whtitlecomments
					set commenttext35 = @ware_commenttext,
						releloind35 = @ware_releasetoeloq
						where bookkey= @ware_bookkey
			  end
			if @ware_commentline = 36 
			  begin
				update whtitlecomments
					set commenttext36 = @ware_commenttext,
						releloind36 = @ware_releasetoeloq
						where bookkey= @ware_bookkey
			  end
			if @ware_commentline = 37 
			  begin
				update whtitlecomments
					set commenttext37 = @ware_commenttext,
						releloind37 = @ware_releasetoeloq
						where bookkey= @ware_bookkey
			  end
			if @ware_commentline = 38 
			  begin
				update whtitlecomments
					set commenttext38 = @ware_commenttext,
						releloind38 = @ware_releasetoeloq
						where bookkey= @ware_bookkey
			  end
			if @ware_commentline = 39 
			  begin
				update whtitlecomments
					set commenttext39 = @ware_commenttext,
						releloind39 = @ware_releasetoeloq
						where bookkey= @ware_bookkey
			  end
			if @ware_commentline = 40 
			  begin
				update whtitlecomments
					set commenttext40 = @ware_commenttext,
						releloind40 = @ware_releasetoeloq
						where bookkey= @ware_bookkey
			  end
			if @ware_commentline = 41 
			  begin
				update whtitlecomments2
					set commenttext41 = @ware_commenttext,
						releloind41 = @ware_releasetoeloq
						where bookkey= @ware_bookkey	
			  end
			if @ware_commentline = 42 
			  begin
				update whtitlecomments2
					set commenttext42 = @ware_commenttext,
						releloind42 = @ware_releasetoeloq
						where bookkey= @ware_bookkey
			  end
			if @ware_commentline = 43 
			  begin
				update whtitlecomments2
					set commenttext43 = @ware_commenttext,
						releloind43 = @ware_releasetoeloq
						where bookkey= @ware_bookkey
			  end
			if @ware_commentline = 44 
			  begin
				update whtitlecomments2
					set commenttext44 = @ware_commenttext,
						releloind44 = @ware_releasetoeloq
						where bookkey= @ware_bookkey
			  end
			if @ware_commentline = 45 
			  begin
				update whtitlecomments2
					set commenttext45 = @ware_commenttext,
						releloind45 = @ware_releasetoeloq
						where bookkey= @ware_bookkey
			  end
			if @ware_commentline = 46 
			  begin
				update whtitlecomments2
					set commenttext46 = @ware_commenttext,
						releloind46 = @ware_releasetoeloq
						where bookkey= @ware_bookkey
			  end
			if @ware_commentline = 47 
			  begin
				update whtitlecomments2
					set commenttext47 = @ware_commenttext,
						releloind47 = @ware_releasetoeloq
						where bookkey= @ware_bookkey
			  end
			if @ware_commentline = 48 
			  begin
				update whtitlecomments2
					set commenttext48 = @ware_commenttext,
						releloind48 = @ware_releasetoeloq
						where bookkey= @ware_bookkey
			  end
			if @ware_commentline = 49 
			  begin
				update whtitlecomments2
					set commenttext49 = @ware_commenttext,
						releloind49 = @ware_releasetoeloq
						where bookkey= @ware_bookkey
			  end
			if @ware_commentline = 50 
			  begin
				update whtitlecomments2
					set commenttext50 = @ware_commenttext,
						releloind50 = @ware_releasetoeloq
						where bookkey= @ware_bookkey
			  end
			if @ware_commentline = 51 	
			  begin
				update whtitlecomments2
					set commenttext51 = @ware_commenttext,
						releloind51 = @ware_releasetoeloq
						where bookkey= @ware_bookkey
			  end
			if @ware_commentline = 52 
			  begin
				update whtitlecomments2
					set commenttext52 = @ware_commenttext,
						releloind52 = @ware_releasetoeloq
						where bookkey= @ware_bookkey
			  end
			if @ware_commentline = 53 
			  begin
				update whtitlecomments2
					set commenttext53 = @ware_commenttext,
						releloind53 = @ware_releasetoeloq
						where bookkey= @ware_bookkey
			  end
			if @ware_commentline = 54 
			  begin
				update whtitlecomments2
					set commenttext54 = @ware_commenttext,
						releloind54 = @ware_releasetoeloq
						where bookkey= @ware_bookkey
			  end
			if @ware_commentline = 55 
			  begin
				update whtitlecomments2
					set commenttext55 = @ware_commenttext,
						releloind55 = @ware_releasetoeloq
						where bookkey= @ware_bookkey
			  end
			if @ware_commentline = 56 
			  begin
				update whtitlecomments2
					set commenttext56 = @ware_commenttext,
						releloind56 = @ware_releasetoeloq
						where bookkey= @ware_bookkey
			  end
			if @ware_commentline = 57 
			  begin
				update whtitlecomments2
					set commenttext57 = @ware_commenttext,
						releloind57 = @ware_releasetoeloq
						where bookkey= @ware_bookkey
			  end
			if @ware_commentline = 58 
			  begin
				update whtitlecomments2
					set commenttext58 = @ware_commenttext,
						releloind58 = @ware_releasetoeloq
						where bookkey= @ware_bookkey
			  end
			if @ware_commentline = 59 
			  begin
				update whtitlecomments2
					set commenttext59 = @ware_commenttext,
						releloind59 = @ware_releasetoeloq
						where bookkey= @ware_bookkey
			  end
			if @ware_commentline = 60 
			  begin
				update whtitlecomments2
					set commenttext60 = @ware_commenttext,
						releloind60 = @ware_releasetoeloq
						where bookkey= @ware_bookkey
			  end
			if @ware_commentline = 61 
			  begin
				update whtitlecomments2
					set commenttext61 = @ware_commenttext,
						releloind61 = @ware_releasetoeloq
						where bookkey= @ware_bookkey
			  end
			if @ware_commentline = 62 
			  begin
				update whtitlecomments2
					set commenttext62 = @ware_commenttext,
						releloind62 = @ware_releasetoeloq
						where bookkey= @ware_bookkey
			  end
			if @ware_commentline = 63 
			  begin
				update whtitlecomments2
					set commenttext63 = @ware_commenttext,
						releloind63 = @ware_releasetoeloq
						where bookkey= @ware_bookkey
			  end
			if @ware_commentline = 64 
			  begin
				update whtitlecomments2
					set commenttext64 = @ware_commenttext,
						releloind64 = @ware_releasetoeloq
						where bookkey= @ware_bookkey
			  end
			if @ware_commentline = 65 
			  begin
				update whtitlecomments2
					set commenttext65 = @ware_commenttext,
						releloind65 = @ware_releasetoeloq
						where bookkey= @ware_bookkey
			  end
			if @ware_commentline = 66 
			  begin
				update whtitlecomments2
					set commenttext66 = @ware_commenttext,
						releloind66 = @ware_releasetoeloq
						where bookkey= @ware_bookkey
			  end
			if @ware_commentline = 67 
			  begin
				update whtitlecomments2
					set commenttext67 = @ware_commenttext,
						releloind67 = @ware_releasetoeloq
						where bookkey= @ware_bookkey
			  end
			if @ware_commentline = 68 
			  begin
				update whtitlecomments2
					set commenttext68 = @ware_commenttext,
						releloind68 = @ware_releasetoeloq
						where bookkey= @ware_bookkey
			  end
			if @ware_commentline = 69 
			  begin
				update whtitlecomments2
					set commenttext69 = @ware_commenttext,
						releloind69 = @ware_releasetoeloq
						where bookkey= @ware_bookkey
			  end
			if @ware_commentline = 70 
			  begin
				update whtitlecomments2
					set commenttext70 = @ware_commenttext,
						releloind70 = @ware_releasetoeloq
						where bookkey= @ware_bookkey
			  end
			if @ware_commentline = 71 
			  begin
				update whtitlecomments2
					set commenttext71 = @ware_commenttext,
						releloind71 = @ware_releasetoeloq
						where bookkey= @ware_bookkey
			  end
			if @ware_commentline = 72 
			  begin
				update whtitlecomments2
					set commenttext72 = @ware_commenttext,
						releloind72 = @ware_releasetoeloq
						where bookkey= @ware_bookkey
			  end
			if @ware_commentline = 73 
			  begin
				update whtitlecomments2
					set commenttext73 = @ware_commenttext,
						releloind73 = @ware_releasetoeloq
						where bookkey= @ware_bookkey
			  end
			if @ware_commentline = 74 
			  begin
				update whtitlecomments2	
					set commenttext74 = @ware_commenttext,
						releloind74 = @ware_releasetoeloq
						where bookkey= @ware_bookkey
			  end
			if @ware_commentline = 75 
			  begin
				update whtitlecomments2
					set commenttext75 = @ware_commenttext,
						releloind75 = @ware_releasetoeloq
						where bookkey= @ware_bookkey
			  end
			if @ware_commentline = 76 
			  begin
				update whtitlecomments2
					set commenttext76 = @ware_commenttext,
						releloind76 = @ware_releasetoeloq
						where bookkey= @ware_bookkey			  
			  end
			if @ware_commentline = 77 
			  begin
				update whtitlecomments2
					set commenttext77 = @ware_commenttext,
						releloind77 = @ware_releasetoeloq
						where bookkey= @ware_bookkey
			  end
			if @ware_commentline = 78 
			  begin
				update whtitlecomments2
					set commenttext78 = @ware_commenttext,
						releloind78 = @ware_releasetoeloq
						where bookkey= @ware_bookkey
			  end
			if @ware_commentline = 79 
			  begin
				update whtitlecomments2
					set commenttext79 = @ware_commenttext,
						releloind79 = @ware_releasetoeloq
						where bookkey= @ware_bookkey
			  end
			if @ware_commentline = 80 
			  begin
				update whtitlecomments2
					set commenttext80 = @ware_commenttext,
						releloind80 = @ware_releasetoeloq
						where bookkey= @ware_bookkey
			  end
			if @ware_commentline = 81 
			  begin
				update whtitlecomments3
					set commenttext81 = @ware_commenttext,
						releloind81 = @ware_releasetoeloq
						where bookkey= @ware_bookkey
			  end	
			if @ware_commentline = 82 
			  begin
				update whtitlecomments3
					set commenttext82 = @ware_commenttext,
						releloind82 = @ware_releasetoeloq
						where bookkey= @ware_bookkey
			  end
			if @ware_commentline = 83 
			  begin
				update whtitlecomments3
					set commenttext83 = @ware_commenttext,
						releloind83 = @ware_releasetoeloq
						where bookkey= @ware_bookkey
			  end
			if @ware_commentline = 84 
			  begin
				update whtitlecomments3
					set commenttext84 = @ware_commenttext,
						releloind84 = @ware_releasetoeloq
						where bookkey= @ware_bookkey	  
			  end
			if @ware_commentline = 85 
			  begin
				update whtitlecomments3
					set commenttext85 = @ware_commenttext,
						releloind85 = @ware_releasetoeloq
						where bookkey= @ware_bookkey
			  end
			if @ware_commentline = 86 
			  begin
				update whtitlecomments3
					set commenttext86 = @ware_commenttext,
						releloind86 = @ware_releasetoeloq
						where bookkey= @ware_bookkey
			  end
			if @ware_commentline = 87 
			begin
				update whtitlecomments3
					set commenttext87 = @ware_commenttext,
						releloind87 = @ware_releasetoeloq
						where bookkey= @ware_bookkey
			end
			if @ware_commentline = 88 
			  begin
				update whtitlecomments3
					set commenttext88 = @ware_commenttext,
						releloind88 = @ware_releasetoeloq
						where bookkey= @ware_bookkey
			  end
			if @ware_commentline = 89 
			  begin
				update whtitlecomments3
					set commenttext89 = @ware_commenttext,
						releloind89 = @ware_releasetoeloq
						where bookkey= @ware_bookkey
			  end
			if @ware_commentline = 90 
			  begin
				update whtitlecomments3
					set commenttext90 = @ware_commenttext,
						releloind90 = @ware_releasetoeloq
						where bookkey= @ware_bookkey
			  end
			if @ware_commentline = 91 
			  begin
				update whtitlecomments3
					set commenttext91 = @ware_commenttext,
						releloind91 = @ware_releasetoeloq
						where bookkey= @ware_bookkey
			  end
			if @ware_commentline = 92 
			  begin
				update whtitlecomments3
					set commenttext92 = @ware_commenttext,
						releloind92 = @ware_releasetoeloq
						where bookkey= @ware_bookkey
			  end
			if @ware_commentline = 93 
			  begin
				update whtitlecomments3
					set commenttext93 = @ware_commenttext,
						releloind93 = @ware_releasetoeloq
						where bookkey= @ware_bookkey
			  end
			if @ware_commentline = 94 
			  begin
				update whtitlecomments3
					set commenttext94 = @ware_commenttext,
						releloind94 = @ware_releasetoeloq
						where bookkey= @ware_bookkey
			  end
			if @ware_commentline = 95 
			  begin
				update whtitlecomments3
					set commenttext95 = @ware_commenttext,
						releloind95 = @ware_releasetoeloq
						where bookkey= @ware_bookkey
				  end
			if @ware_commentline = 96 
			  begin
				update whtitlecomments3
					set commenttext96 = @ware_commenttext,
						releloind96 = @ware_releasetoeloq
						where bookkey= @ware_bookkey
			  end
			if @ware_commentline = 97 
			  begin
				update whtitlecomments3
					set commenttext97 = @ware_commenttext,
						releloind97 = @ware_releasetoeloq
						where bookkey= @ware_bookkey
			  end
			if @ware_commentline = 98 			  
			  begin
				update whtitlecomments3
					set commenttext98 = @ware_commenttext,
						releloind98 = @ware_releasetoeloq
						where bookkey= @ware_bookkey
			  end
			if @ware_commentline = 99 
			  begin
				update whtitlecomments3
					set commenttext99 = @ware_commenttext,
						releloind99 = @ware_releasetoeloq
						where bookkey= @ware_bookkey
			  end
			if @ware_commentline = 100 
			  begin
				update whtitlecomments3
					set commenttext100 = @ware_commenttext,
						releloind100 = @ware_releasetoeloq
						where bookkey= @ware_bookkey
			  end
			if @ware_commentline = 101 
			  begin
				update whtitlecomments3
					set commenttext101 = @ware_commenttext,
						releloind101 = @ware_releasetoeloq
						where bookkey= @ware_bookkey
			  end
			if @ware_commentline = 102 
			  begin
				update whtitlecomments3
					set commenttext102 = @ware_commenttext,
						releloind102 = @ware_releasetoeloq
						where bookkey= @ware_bookkey
			  end
			if @ware_commentline = 103 
			  begin
				update whtitlecomments3
					set commenttext103 = @ware_commenttext,
						releloind103 = @ware_releasetoeloq
						where bookkey= @ware_bookkey
			  end
			if @ware_commentline = 104 
			  begin
				update whtitlecomments3
					set commenttext104 = @ware_commenttext,
						releloind104 = @ware_releasetoeloq
						where bookkey= @ware_bookkey
			  end
			if @ware_commentline = 105 
			  begin
				update whtitlecomments3
					set commenttext105 = @ware_commenttext,
						releloind105 = @ware_releasetoeloq
						where bookkey= @ware_bookkey
			  end
			if @ware_commentline = 106 
			  begin
				update whtitlecomments3
					set commenttext106 = @ware_commenttext,
						releloind106 = @ware_releasetoeloq
						where bookkey= @ware_bookkey
			  end
			if @ware_commentline = 107 
			  begin
				update whtitlecomments3
					set commenttext107 = @ware_commenttext,
						releloind107 = @ware_releasetoeloq
						where bookkey= @ware_bookkey
			  end
			if @ware_commentline = 108 
			  begin
				update whtitlecomments3
					set commenttext108 = @ware_commenttext,
						releloind108 = @ware_releasetoeloq
						where bookkey= @ware_bookkey
			  end
			if @ware_commentline = 109 
			  begin
				update whtitlecomments3
					set commenttext109 = @ware_commenttext,
						releloind109 = @ware_releasetoeloq
						where bookkey= @ware_bookkey
			  end
			if @ware_commentline = 110 
			  begin
				update whtitlecomments3
					set commenttext110 = @ware_commenttext,
						releloind110 = @ware_releasetoeloq
						where bookkey= @ware_bookkey
			  end
			if @ware_commentline = 111 
			  begin
				update whtitlecomments3
					set commenttext111 = @ware_commenttext,
						releloind111 = @ware_releasetoeloq
						where bookkey= @ware_bookkey
			  end
			if @ware_commentline = 112 
			  begin
				update whtitlecomments3
					set commenttext112 = @ware_commenttext,
						releloind112 = @ware_releasetoeloq
						where bookkey= @ware_bookkey
			  end
			if @ware_commentline = 113 
			  begin
				update whtitlecomments3
					set commenttext113 = @ware_commenttext,
						releloind113 = @ware_releasetoeloq
						where bookkey= @ware_bookkey
			  end
			if @ware_commentline = 114 
			  begin
				update whtitlecomments3	
					set commenttext114 = @ware_commenttext,
						releloind114 = @ware_releasetoeloq
						where bookkey= @ware_bookkey
			  end
			if @ware_commentline = 115 
			  begin
				update whtitlecomments3
					set commenttext115 = @ware_commenttext,
						releloind115 = @ware_releasetoeloq
						where bookkey= @ware_bookkey
			  end
			if @ware_commentline = 116 
			  begin
				update whtitlecomments3
					set commenttext116 = @ware_commenttext,
						releloind116 = @ware_releasetoeloq
						where bookkey= @ware_bookkey
			  end
			if @ware_commentline = 117 
			  begin
				update whtitlecomments3
					set commenttext117 = @ware_commenttext,
						releloind117 = @ware_releasetoeloq
						where bookkey= @ware_bookkey
			  end
			if @ware_commentline = 118 
			begin
				update whtitlecomments3
					set commenttext118 = @ware_commenttext,
						releloind118 = @ware_releasetoeloq
						where bookkey= @ware_bookkey
			  end
			if @ware_commentline = 119 
			  begin
				update whtitlecomments3
					set commenttext119 = @ware_commenttext,
						releloind119 = @ware_releasetoeloq
						where bookkey= @ware_bookkey
			  end
			if @ware_commentline = 120 
			  begin
				update whtitlecomments3
					set commenttext120 = @ware_commenttext,
						releloind120 = @ware_releasetoeloq
						where bookkey= @ware_bookkey
			  end
commit tran
		     END  /* @ware_length2 > 0 */
		
		END  /*@ware_totallength */
 END  /* comment line > 0 */
GO