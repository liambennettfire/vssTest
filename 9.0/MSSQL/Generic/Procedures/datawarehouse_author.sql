PRINT 'STORED PROCEDURE : dbo.datawarehouse_author'
GO

if exists (select * from dbo.sysobjects where id = Object_id('dbo.datawarehouse_author') and (type = 'P' or type = 'RF'))
begin
 drop proc dbo.datawarehouse_author
end

GO

CREATE  proc dbo.datawarehouse_author 
@ware_bookkey int, @ware_logkey int, @ware_warehousekey int,
@ware_system_date datetime

AS 

/* add reportind and primaryind on 8/26/02*/


DECLARE @ware_count int
DECLARE @ware_statecode_long varchar(40)
DECLARE @ware_authortype_long varchar(40)
DECLARE @ware_authortype_short varchar(20)
DECLARE @ware_authorprimind varchar(1)
DECLARE @ware_authorrepind varchar(1)
DECLARE @ware_authorcity1  varchar(100) 
DECLARE @ware_authordisplayname1 varchar(100) 
DECLARE @ware_authorfirstname1 varchar(100) 
DECLARE @ware_authorlastname1 varchar(100) 
DECLARE @ware_authormiddlename1 varchar(100) 
DECLARE @ware_authorstateabbrev1 varchar(100) 
DECLARE @ware_authortype1  varchar(100) 
DECLARE @ware_authortypeshort1 varchar(100)
DECLARE @ware_authorprimind1 varchar(1) 
DECLARE @ware_authorrepind1 varchar(1) 
DECLARE @ware_authorcity2  varchar(100) 
DECLARE @ware_authordisplayname2 varchar(100) 
DECLARE @ware_authorfirstname2 varchar(100) 
DECLARE @ware_authorlastname2 varchar(100) 
DECLARE @ware_authormiddlename2 varchar(100) 
DECLARE @ware_authorstateabbrev2 varchar(100) 
DECLARE @ware_authortype2  varchar(100) 
DECLARE @ware_authortypeshort2 varchar(100) 
DECLARE @ware_authorprimind2 varchar(1) 
DECLARE @ware_authorrepind2 varchar(1) 
DECLARE @ware_authorcity3  varchar(100) 
DECLARE @ware_authordisplayname3 varchar(100) 
DECLARE @ware_authorfirstname3 varchar(100) 
DECLARE @ware_authorlastname3 varchar(100) 
DECLARE @ware_authormiddlename3 varchar(100) 
DECLARE @ware_authorstateabbrev3 varchar(100) 
DECLARE @ware_authortype3  varchar(100) 
DECLARE @ware_authortypeshort3 varchar(100) 
DECLARE @ware_authorprimind3 varchar(1) 
DECLARE @ware_authorrepind3 varchar(1) 
DECLARE @ware_authorcity4  varchar(100) 
DECLARE @ware_authordisplayname4 varchar(100) 
DECLARE @ware_authorfirstname4 varchar(100) 
DECLARE @ware_authorlastname4 varchar(100) 
DECLARE @ware_authormiddlename4 varchar(100) 
DECLARE @ware_authorstateabbrev4 varchar(100)  
DECLARE @ware_authortype4  varchar(100) 
DECLARE @ware_authortypeshort4 varchar(100)
DECLARE @ware_authorprimind4 varchar(1) 
DECLARE @ware_authorrepind4 varchar(1) 
DECLARE @ware_authorcity5  varchar(100) 
DECLARE @ware_authordisplayname5 varchar(100) 
DECLARE @ware_authorfirstname5 varchar(100) 
DECLARE @ware_authorlastname5 varchar(100) 
DECLARE @ware_authormiddlename5 varchar(100) 
DECLARE @ware_authorstateabbrev5 varchar(100)  
DECLARE @ware_authortype5  varchar(100) 
DECLARE @ware_authortypeshort5 varchar(100) 
DECLARE @ware_authorprimind5 varchar(1) 
DECLARE @ware_authorrepind5 varchar(1) 
DECLARE @c_displayname varchar(100) 
DECLARE @c_firstname varchar(100)
DECLARE @c_lastname varchar(100)
DECLARE @c_city varchar(100)
DECLARE @i_statecode int
DECLARE @c_middlename varchar(100)
DECLARE @i_authortypecode int
DECLARE @i_primaryind int
DECLARE @i_reportind  int
DECLARE @i_authorstatus int
DECLARE @i_authorkey int
DECLARE @ware_accreditation1  varchar(40) 
DECLARE @ware_accreditation2 varchar(40) 
DECLARE @ware_accreditation3 varchar(40) 
DECLARE @ware_accreditation4 varchar(40) 
DECLARE @ware_accreditation5 varchar(40) 
DECLARE @ware_suffix1 varchar(75)  
DECLARE @ware_suffix2  varchar(75) 
DECLARE @ware_suffix3 varchar(75) 
DECLARE @ware_suffix4 varchar(75) 
DECLARE @ware_suffix5 varchar(75) 
DECLARE @ware_degree1 varchar(75)  
DECLARE @ware_degree2  varchar(75) 
DECLARE @ware_degree3 varchar(75) 
DECLARE @ware_degree4 varchar(75) 
DECLARE @ware_degree5 varchar(75) 
DECLARE @ware_completeauth1 varchar(1000)  
DECLARE @ware_completeauth2  varchar(1000) 
DECLARE @ware_completeauth3 varchar(1000) 
DECLARE @ware_completeauth4 varchar(1000) 
DECLARE @ware_completeauth5 varchar(1000) 

DECLARE warehouseauthor INSENSITIVE CURSOR
FOR
	SELECT  a.authorkey,displayname,  firstname, lastname, city,  statecode,
		 middlename,  authortypecode, primaryind,  reportind 
		    FROM bookauthor b, author a
		   	WHERE  b.authorkey=a.authorkey
				AND bookkey = @ware_bookkey
					 ORDER BY  b.primaryind DESC ,b.sortorder ASC, authortypecode ASC

FOR READ ONLY


select @ware_count = 1
OPEN warehouseauthor

FETCH NEXT FROM warehouseauthor
INTO @i_authorkey,@c_displayname, @c_firstname,@c_lastname,@c_city,@i_statecode,
@c_middlename,@i_authortypecode,@i_primaryind,@i_reportind  

select @i_authorstatus = @@FETCH_STATUS

if @i_authorstatus <> 0  /** NO Author**/
    begin
	INSERT INTO wherrorlog (logkey, warehousekey,errordesc,
	 	errorseverity, errorfunction,lastuserid, lastmaintdate)
	 VALUES (convert(varchar, @ware_logkey)  ,convert(varchar,@ware_warehousekey),
		'No Author rows for this title,  inserting blanks in whauthor table',
		('Warning/data error bookkey '+ convert(varchar,@ware_bookkey)),
		'Stored procedure datawarehouse_author','WARE_STORED_PROC',@ware_system_date)
   end
 while (@i_authorstatus<>-1 )
   begin

	IF (@i_authorstatus<>-2)
	  begin
		if @c_displayname is null 
		  begin
			select @c_displayname = ''
		  end
		if @c_firstname is null 
		  begin
			select @c_firstname = ''
		  end
 		if @c_lastname is null 
		  begin
			select @c_lastname = ''
		  end
		if @c_city is null 
		  begin
			select @c_city = ''
		  end
		if @i_statecode is null 
		  begin
			select @i_statecode = 0
		  end
		if @c_middlename is null 
		  begin
			select @c_middlename = ''
		  end
		if @i_authortypecode is null 
		  begin
			select @i_authortypecode = 0
		  end
		if @i_primaryind is null 
		  begin
			select @i_primaryind = 0
		  end
		if @i_reportind is null 
		  begin
			select @i_reportind = 0
		  end

		if @i_statecode > 0 
		  begin
			exec  gentables_longdesc 160,@i_statecode, @ware_statecode_long OUTPUT
			select @ware_statecode_long = substring(@ware_statecode_long,1,5)
		  end
		else
		  begin
			select @ware_statecode_long = ''
		  end

	if @i_authortypecode > 0 
	  begin
		exec  gentables_longdesc 134,@i_authortypecode, @ware_authortype_long OUTPUT
		exec  gentables_shortdesc 134,@i_authortypecode, @ware_authortype_short OUTPUT
		select @ware_authortype_short = substring(@ware_authortype_short,1,20)
	  end
	else
	  begin
		select @ware_authortype_long = ''
		select @ware_authortype_short = ''
	  end 

	if @i_primaryind > 0 
	  begin
		select @ware_authorprimind = 'Y'
	  end
	else
	  begin
		select @ware_authorprimind = 'N'
	  end
	if @i_reportind > 0 
	  begin
		select @ware_authorrepind = 'Y'
	  end
	else
	  begin
		select @ware_authorrepind = 'N'
	  end 

	if @ware_count = 1 
	  begin
		select @ware_authorcity1 = @c_city
		select @ware_authordisplayname1  =  @c_displayname
		select @ware_authorfirstname1 =  @c_firstname
		select @ware_authorlastname1  = @c_lastname
		select @ware_authormiddlename1  = @c_middlename
		select @ware_authorstateabbrev1  = @ware_statecode_long
		select @ware_authortype1  = @ware_authortype_long
		select @ware_authortypeshort1  =  @ware_authortype_short
		select @ware_authorprimind1 = @ware_authorprimind
		select @ware_authorrepind1 = @ware_authorrepind
		exec  authorextra_sp @i_authorkey,1, @ware_accreditation1 OUTPUT
		exec  authorextra_sp @i_authorkey,2, @ware_suffix1 OUTPUT
		exec  authorextra_sp @i_authorkey,3, @ware_degree1 OUTPUT
		exec  authorextra_sp @i_authorkey,4, @ware_completeauth1 OUTPUT
	  end
	 if @ware_count = 2 
	  begin 
		select @ware_authorcity2 = @c_city
		select @ware_authordisplayname2  =  @c_displayname
		select @ware_authorfirstname2 =  @c_firstname
		select @ware_authorlastname2  = @c_lastname
		select @ware_authormiddlename2  = @c_middlename
		select @ware_authorstateabbrev2  = @ware_statecode_long
		select @ware_authortype2  = @ware_authortype_long
		select @ware_authortypeshort2  =  @ware_authortype_short
		select @ware_authorprimind2 = @ware_authorprimind
		select @ware_authorrepind2 = @ware_authorrepind
		exec  authorextra_sp @i_authorkey,1, @ware_accreditation2 OUTPUT
		exec  authorextra_sp @i_authorkey,2, @ware_suffix2 OUTPUT
		exec  authorextra_sp @i_authorkey,3, @ware_degree2 OUTPUT
		exec  authorextra_sp @i_authorkey,4, @ware_completeauth2 OUTPUT
	  end
	if @ware_count = 3 
	  begin
		select @ware_authorcity3 = @c_city
		select @ware_authordisplayname3  =  @c_displayname
		select @ware_authorfirstname3 =  @c_firstname
		select @ware_authorlastname3 = @c_lastname
		select @ware_authormiddlename3  = @c_middlename
		select @ware_authorstateabbrev3  = @ware_statecode_long
		select @ware_authortype3 = @ware_authortype_long
		select @ware_authortypeshort3 =  @ware_authortype_short
		select @ware_authorprimind3 = @ware_authorprimind
		select @ware_authorrepind3 = @ware_authorrepind
		exec  authorextra_sp @i_authorkey,1, @ware_accreditation3 OUTPUT
		exec  authorextra_sp @i_authorkey,2, @ware_suffix3 OUTPUT
		exec  authorextra_sp @i_authorkey,3, @ware_degree3 OUTPUT
		exec  authorextra_sp @i_authorkey,4, @ware_completeauth3 OUTPUT
	  end
	if @ware_count = 4 
	  begin
		select @ware_authorcity4 = @c_city
		select @ware_authordisplayname4  =  @c_displayname
		select @ware_authorfirstname4 =  @c_firstname
		select @ware_authorlastname4 = @c_lastname
		select @ware_authormiddlename4  = @c_middlename
		select @ware_authorstateabbrev4  = @ware_statecode_long
		select @ware_authortype4 = @ware_authortype_long
		select @ware_authortypeshort4 =  @ware_authortype_short
		select @ware_authorprimind4 = @ware_authorprimind
		select @ware_authorrepind4 = @ware_authorrepind
		exec  authorextra_sp @i_authorkey,1, @ware_accreditation4 OUTPUT
		exec  authorextra_sp @i_authorkey,2, @ware_suffix4 OUTPUT
		exec  authorextra_sp @i_authorkey,3, @ware_degree4 OUTPUT
		exec  authorextra_sp @i_authorkey,4, @ware_completeauth4 OUTPUT
	end
	if @ware_count = 5 
	  begin 
		select @ware_authorcity5 = @c_city
		select @ware_authordisplayname5  =  @c_displayname
		select @ware_authorfirstname5 =  @c_firstname
		select @ware_authorlastname5 = @c_lastname
		select @ware_authormiddlename5  = @c_middlename
		select @ware_authorstateabbrev5  = @ware_statecode_long
		select @ware_authortype5 = @ware_authortype_long
		select @ware_authortypeshort5 =  @ware_authortype_short
		select @ware_authorprimind5 = @ware_authorprimind
		select @ware_authorrepind5 = @ware_authorrepind
		exec  authorextra_sp @i_authorkey,1, @ware_accreditation5 OUTPUT
		exec  authorextra_sp @i_authorkey,2, @ware_suffix5 OUTPUT
		exec  authorextra_sp @i_authorkey,3, @ware_degree5 OUTPUT
		exec  authorextra_sp @i_authorkey,4, @ware_completeauth5 OUTPUT
		break
	 end
	select @ware_count = @ware_count + 1	
	
end	/*<>2*/

	FETCH NEXT FROM warehouseauthor
	INTO @i_authorkey,@c_displayname, @c_firstname,@c_lastname,@c_city,@i_statecode,
	@c_middlename,@i_authortypecode,@i_primaryind,@i_reportind  


	select @i_authorstatus = @@FETCH_STATUS
end
	
BEGIN tran 

INSERT into whauthor
		(bookkey, authorcity1,authordisplayname1,authorfirstname1 ,
		authorlastname1,authormiddlename1,authorstateabbrev1,
		authortype1,authortypeshort1,authorcity2,authordisplayname2,
		authorfirstname2,authorlastname2,authormiddlename2,	
		authorstateabbrev2,authortype2,authortypeshort2,authorcity3,
		authordisplayname3,authorfirstname3,authorlastname3,
		authormiddlename3,authorstateabbrev3,authortype3,authortypeshort3,
		authorcity4,authordisplayname4,authorfirstname4,authorlastname4,
		authormiddlename4,authorstateabbrev4,authortype4,authortypeshort4,
		authorcity5,authordisplayname5,authorfirstname5,authorlastname5,
		authormiddlename5,authorstateabbrev5,authortype5,authortypeshort5,
		lastuserid,lastmaintdate,authorprimaryind1,authorprimaryind2,
		authorprimaryind3,authorprimaryind4,authorprimaryind5,authorreportind1,
		authorreportind2,authorreportind3,authorreportind4,authorreportind5,
		accreditation1,accreditation2,accreditation3,accreditation4,accreditation5,suffix1,suffix2,
		suffix3,suffix4,suffix5,degree1,degree2,degree3,degree4,degree5,completeauthorname1,
		completeauthorname2,completeauthorname3,completeauthorname4,completeauthorname5)

	VALUES (@ware_bookkey, @ware_authorcity1,@ware_authordisplayname1,@ware_authorfirstname1 ,
		@ware_authorlastname1,@ware_authormiddlename1,@ware_authorstateabbrev1,
		@ware_authortype1,@ware_authortypeshort1,@ware_authorcity2,@ware_authordisplayname2,
		@ware_authorfirstname2,@ware_authorlastname2,@ware_authormiddlename2,	
		@ware_authorstateabbrev2,@ware_authortype2,@ware_authortypeshort2,@ware_authorcity3,
		@ware_authordisplayname3,@ware_authorfirstname3,@ware_authorlastname3,
		@ware_authormiddlename3,@ware_authorstateabbrev3,@ware_authortype3,@ware_authortypeshort3,
		@ware_authorcity4,@ware_authordisplayname4,@ware_authorfirstname4,@ware_authorlastname4,
		@ware_authormiddlename4,@ware_authorstateabbrev4,@ware_authortype4,@ware_authortypeshort4,
		@ware_authorcity5,@ware_authordisplayname5,@ware_authorfirstname5,@ware_authorlastname5,
		@ware_authormiddlename5,@ware_authorstateabbrev5,@ware_authortype5,@ware_authortypeshort5,
		'WARE_STORED_PROC',@ware_system_date,@ware_authorprimind1,@ware_authorprimind2,@ware_authorprimind3,
		@ware_authorprimind4,@ware_authorprimind5,@ware_authorrepind1,@ware_authorrepind2,@ware_authorrepind3,
		@ware_authorrepind4,@ware_authorrepind5,@ware_accreditation1,@ware_accreditation2,@ware_accreditation3,
		@ware_accreditation4,@ware_accreditation5,@ware_suffix1,@ware_suffix2,@ware_suffix3,@ware_suffix4,
		@ware_suffix5,@ware_degree1,@ware_degree2,@ware_degree3,@ware_degree4,@ware_degree5,@ware_completeauth1,
		@ware_completeauth2,@ware_completeauth3,@ware_completeauth4,@ware_completeauth5)
commit tran

/* not sure how to check as yet 
if SQL%ROWCOUNT > 0 
  begin

	INSERT INTO qsidba.wherrorlog (logkey, warehousekey,errordesc, 
          errorseverity, errorfunction,lastuserid, lastmaintdate)
	 VALUES (convert(varchar,@ware_logkey)  ,convert(varchar,@ware_warehousekey),
		'Unable to insert whauthor table - for author',
		('Warning/data error bookkey ' + convert(varchar,@ware_bookkey)),
		'Stored procedure datawarehouse_author','WARE_STORED_PROC', @ware_system_date)
  end 
*/
close warehouseauthor
deallocate warehouseauthor


GO