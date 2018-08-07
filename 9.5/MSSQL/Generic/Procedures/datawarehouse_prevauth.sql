/* 6/2/04 - PV - Expand title to 255 chars (CRM 1373) */
/* c_prevtitle */

PRINT 'STORED PROCEDURE : dbo.datawarehouse_prevauth'
GO

if exists (select * from dbo.sysobjects where id = Object_id('dbo.datawarehouse_prevauth') and (type = 'P' or type = 'RF'))
begin
 drop proc dbo.datawarehouse_prevauth
end

GO

CREATE  proc dbo.datawarehouse_prevauth 
@ware_bookkey int, @ware_logkey int, @ware_warehousekey int,
@ware_system_date datetime

AS 

DECLARE @ware_count		int
DECLARE @ware_commentline  	int

DECLARE @ware_orig_long  	varchar(40)  
DECLARE @ware_orig_short  	varchar(20)  
DECLARE @ware_media_long  	varchar(40)  
DECLARE @ware_media_short  	varchar(20)  
DECLARE @ware_format_long  	varchar(120)  
DECLARE @ware_format_short  	varchar(20)  
DECLARE @ware_mcnaughtonind  	char(1) 
DECLARE @ware_primaryind   	char(1) 
DECLARE @ware_sales 		varchar(40)

DECLARE @c_previsbn 		varchar(13)
DECLARE @c_prevtitle 		varchar(255)
DECLARE @i_mediatypecode 	int
DECLARE @i_mediatypesubcode 	int
DECLARE @i_salestypecode 	int
DECLARE @i_prevsalesunit 	int
DECLARE @i_mcnaughtonind 	int
DECLARE @i_origpubhousecode 	int
DECLARE @d_pubdate 		datetime
DECLARE @i_prevsalesunitnet 	int
DECLARE @c_firstname 		varchar(75)
DECLARE @c_lastname 		varchar(75)
DECLARE @c_displayname 		varchar(80)
DECLARE @i_primaryind 		int
DECLARE @i_prevstatus 		int

DECLARE warehouseprevau INSENSITIVE CURSOR
FOR
	SELECT ap.previsbn, ap.prevtitle,ap.mediatypecode,ap.mediatypesubcode,ap.salestypecode,ap.prevsalesunit,
		ap.mcnaughtonind,ap.origpubhousecode, ap.pubdate,ap.prevsalesunitnet,a.firstname,a.lastname,a.displayname,
		ba.primaryind
		    FROM author a, authorpreviousworks ap,bookauthor ba
		   	WHERE  a.authorkey= ap.authorkey
				AND ap.authorkey = ba.authorkey
				AND ba.bookkey = @ware_bookkey

FOR READ ONLY

select @ware_primaryind   = 'N'
select @ware_mcnaughtonind = 'N'

select @ware_count = 1
OPEN warehouseprevau

FETCH NEXT FROM warehouseprevau
INTO @c_previsbn, @c_prevtitle ,@i_mediatypecode, @i_mediatypesubcode, @i_salestypecode,
@i_prevsalesunit ,@i_mcnaughtonind ,@i_origpubhousecode, @d_pubdate, @i_prevsalesunitnet,
@c_firstname,@c_lastname, @c_displayname,@i_primaryind  

select @i_prevstatus = @@FETCH_STATUS

 while (@i_prevstatus<>-1 )
   begin

	IF (@i_prevstatus<>-2)
	  begin
	
		if @i_origpubhousecode > 0 
		  begin
			exec gentables_longdesc 126, @i_origpubhousecode,@ware_orig_long OUTPUT
			exec gentables_shortdesc 126,@i_origpubhousecode,@ware_orig_short  OUTPUT
			select @ware_orig_short  = substring(@ware_orig_short,1,20)
		  end
		else
		  begin
			select @ware_orig_long = ''
			select @ware_orig_short = ''
		  end

	if @i_mediatypecode > 0 
	  begin
		exec gentables_longdesc 312,@i_mediatypecode,@ware_media_long OUTPUT
		exec gentables_shortdesc 312,@i_mediatypecode,@ware_media_short OUTPUT 
		select @ware_media_short  = substring(@ware_media_short,1,20)
	  end
	else
	  begin
		select @ware_media_long = ''
		select @ware_media_short = ''
	  end
	if @i_mediatypecode > 0  and @i_mediatypesubcode > 0 
	  begin
		exec subgent_longdesc 312,@i_mediatypecode,@i_mediatypesubcode,@ware_format_long OUTPUT
		exec subgent_shortdesc 312,@i_mediatypecode,@i_mediatypesubcode, @ware_format_short OUTPUT
		select @ware_format_short = substring(@ware_format_short,1,20)
	  end
	else
	  begin
		select @ware_format_long = ''
		select @ware_format_short = ''
	  end
	if @i_salestypecode > 0   
	  begin
		exec   gentables_longdesc 308,@i_salestypecode,@ware_sales OUTPUT
	  end
	else
	  begin
		select @ware_sales = ''
	  end

	if @i_primaryind = 1 
	  begin
		select @ware_primaryind = 'Y'
	  end
	else
	  begin
		select @ware_primaryind = 'N'
	  end
	if @i_mcnaughtonind = 1 
	  begin
		select @ware_mcnaughtonind = 'Y'
	  end
	else
	  begin
		select @ware_mcnaughtonind = 'N'
	  end
BEGIN tran

	INSERT INTO  whtitleprevworks
		(bookkey,authorfirstname,authorlastname,authordisplayname,authorprimaryind,
		mcnaughtonind,originalpubhouse,originalpubhouseshort,previsbn,prevformat,
		prevformatshort,prevmedia,prevmediashort,prevpubdate,prevtitle,
		salesunitgross,salesunitnet,lastuserid,lastmaintdate)
	VALUES (@ware_bookkey,@c_firstname,@c_lastname,@c_displayname,@ware_primaryind,
		@ware_mcnaughtonind,@ware_orig_long,@ware_orig_short,
		@c_previsbn,@ware_format_long,@ware_format_short,@ware_media_long,
		@ware_media_short,@d_pubdate,@c_prevtitle,@i_prevsalesunit,
		@i_prevsalesunitnet,'WARE_STORED_PROC',@ware_system_date)

commit tran
	select @ware_count = @ware_count + 1
 end
	FETCH NEXT FROM warehouseprevau
	INTO @c_previsbn, @c_prevtitle ,@i_mediatypecode, @i_mediatypesubcode, @i_salestypecode,
	@i_prevsalesunit ,@i_mcnaughtonind ,@i_origpubhousecode, @d_pubdate, @i_prevsalesunitnet,
	 @c_firstname,@c_lastname, @c_displayname,@i_primaryind  

	select @i_prevstatus = @@FETCH_STATUS
end

if @ware_count = 1 
  begin
BEGIN tran
	INSERT INTO  whtitleprevworks
		(bookkey,authorfirstname,authorlastname,authordisplayname,authorprimaryind,
		mcnaughtonind,originalpubhouse,originalpubhouseshort,previsbn,prevformat,
		prevformatshort,prevmedia,prevmediashort,prevpubdate,prevtitle,
		salesunitgross,salesunitnet,lastuserid,lastmaintdate)
	VALUES (@ware_bookkey,@c_firstname,@c_lastname,@c_displayname,@ware_primaryind,
		@ware_mcnaughtonind,@ware_orig_long,@ware_orig_short,
		@c_previsbn,@ware_format_long,@ware_format_short,@ware_media_long,
		@ware_media_short,@d_pubdate,@c_prevtitle,@i_prevsalesunit,
		@i_prevsalesunitnet,'WARE_STORED_PROC',@ware_system_date)
commit tran
  end

close warehouseprevau
deallocate warehouseprevau


GO