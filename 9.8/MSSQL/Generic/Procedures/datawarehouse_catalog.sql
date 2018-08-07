PRINT 'STORED PROCEDURE : dbo.datawarehouse_catalog'
GO

if exists (select * from dbo.sysobjects where id = Object_id('dbo.datawarehouse_catalog') and (type = 'P' or type = 'RF'))
begin
 drop proc dbo.datawarehouse_catalog
end

GO

CREATE PROCEDURE  datawarehouse_catalog
@ware_logkey int,@ware_warehousekey int, @ware_system_date datetime
AS

DECLARE @ware_count int
DECLARE @ware_seasonkey int
DECLARE @ware_catalogtitle  varchar(50)
DECLARE @ware_description varchar(100) 
DECLARE @ware_catalogtypecode int
DECLARE @ware_purposetypecode int
DECLARE @ware_versionnumber  varchar(15) 
DECLARE @ware_revisionnumber varchar(6) 
DECLARE @ware_catalogstatuscode  int
DECLARE @ware_layoutkey int
DECLARE @ware_orgentrydesc  varchar(40) 
DECLARE @ware_layoutdesc varchar(80) 
DECLARE @ware_seasontypecode  int
DECLARE @ware_seasonyear   int
DECLARE @ware_seasontype_long varchar(40)
DECLARE @ware_cattype_long  varchar(40) 
DECLARE @ware_cattype_short  varchar(20) 
DECLARE @ware_purpose_long  varchar(40) 
DECLARE @ware_purpose_short  varchar(20)
DECLARE @ware_status_long  varchar(40) 
DECLARE @ware_status_short  varchar(20)
DECLARE @i_catalogkey int
DECLARE @i_catstatus int
DECLARE @ware_pubmonth datetime

select @ware_count = 1

/*12-4-03 add pubmonth and pubyear*/

DECLARE warehousecatalog INSENSITIVE CURSOR
   FOR
	SELECT catalogkey
		    FROM catalog
FOR READ ONLY

   OPEN  warehousecatalog

	FETCH NEXT FROM warehousecatalog
		INTO @i_catalogkey

	select @i_catstatus = @@FETCH_STATUS

	if @i_catstatus <> 0 /** NOne **/
    	  begin
			
		INSERT INTO wherrorlog (logkey, warehousekey,errordesc,
     	   		 errorfunction,lastuserid, lastmaintdate)
		 VALUES (convert(varchar,@ware_logkey)  ,convert(varchar,@ware_warehousekey),
			'No Catalogs to Process','Stored procedure datawarehouse_catalog',
			'WARE_STORED_PROC',@ware_system_date)
		RETURN
   	end
	 while (@i_catstatus<>-1 )
	   begin

		IF (@i_catstatus <>-2)
		  begin
			select @ware_count = 0
			select @ware_seasonkey = 0
			select @ware_catalogtitle = ''
			select @ware_description = ''
			select @ware_catalogtypecode = 0
			select @ware_purposetypecode = 0;
			select @ware_versionnumber = ''
			select @ware_revisionnumber = ''
			select @ware_catalogstatuscode = 0
			select @ware_layoutkey = 0
			select @ware_orgentrydesc = ''
			select @ware_layoutdesc = ''
			select @ware_seasontypecode = 0
			select @ware_seasonyear = 0
			select @ware_seasontype_long = ''
			select @ware_cattype_long = ''
			select @ware_cattype_short = ''
			select @ware_purpose_long = ''
			select @ware_purpose_short = ''
			select @ware_status_long = ''
			select @ware_status_short = ''
			select @ware_pubmonth  = ''

			select @ware_count = count(*)
				from  catalog c, catalogorgentry co,
					orgentry o, season s, layoutformat l
						where c.catalogkey = co.catalogkey and
					         co.orgentrykey = o.orgentrykey and
					          c.layoutkey = l.layoutkey and
					           c.seasonkey = s.seasonkey and
					 	     co.primaryind = 1  and
						      c.catalogkey = @i_catalogkey 

			if @ware_count >0 
			  begin
				select @ware_seasonkey = c.seasonkey, @ware_catalogtitle = c.catalogtitle,
					@ware_description = c.description,@ware_catalogtypecode = c.catalogtypecode,
					@ware_purposetypecode = c.purposetypecode,@ware_versionnumber =c.versionnumber,
					@ware_revisionnumber = c.revisionnumber,@ware_catalogstatuscode= c.catalogstatuscode,
					@ware_layoutkey = c.layoutkey,@ware_orgentrydesc = o.orgentrydesc,
					@ware_layoutdesc = l.layoutdesc,@ware_seasontypecode = s.seasontypecode,@ware_seasonyear = s.seasonyear,
					@ware_pubmonth = c.pubmonth
						from  catalog c, catalogorgentry co,
							orgentry o, season s, layoutformat l
								where c.catalogkey = co.catalogkey and
					      		   co.orgentrykey = o.orgentrykey and
							          c.layoutkey = l.layoutkey and
							           c.seasonkey = s.seasonkey and
							 	     co.primaryind = 1  and
								      c.catalogkey = @i_catalogkey 
				if @ware_seasontypecode is null
				  begin
					select @ware_seasontypecode = 0
				  end
				if @ware_catalogtypecode is null
				  begin
					select @ware_catalogtypecode = 0
				  end
				if @ware_purposetypecode is null
				  begin
					select @ware_purposetypecode = 0
				  end
				if @ware_catalogstatuscode is null
				  begin
					select @ware_catalogstatuscode = 0
				  end
				if @ware_seasontypecode> 0 
				  begin
					exec gentables_longdesc 289,@ware_seasontypecode, @ware_seasontype_long OUTPUT
					select @ware_seasontype_long = @ware_seasontype_long + ' ' + convert(varchar,@ware_seasonyear)
				  end	
				else
				  begin
					select @ware_seasontype_long = ''
				  end

				if @ware_catalogtypecode > 0 
				  begin
					exec gentables_longdesc 297,@ware_catalogtypecode,@ware_cattype_long OUTPUT
					exec gentables_shortdesc 297,@ware_catalogtypecode, @ware_cattype_short OUTPUT
					select @ware_cattype_short  = substring(@ware_cattype_short,1,8)
				  end
				else
				  begin
					select @ware_cattype_long = ''
					select @ware_cattype_short = ''
				  end 

				if @ware_purposetypecode > 0 
				  begin
					exec gentables_longdesc 298,@ware_purposetypecode,@ware_purpose_long OUTPUT
					exec gentables_shortdesc 298,@ware_purposetypecode,@ware_purpose_short OUTPUT
					select @ware_purpose_short  = substring(@ware_purpose_short,1,8)
				  end
				else	
				  begin
					select @ware_purpose_long = ''
					select @ware_purpose_short = ''
				  end

				if @ware_catalogstatuscode > 0 
				  begin
					exec gentables_longdesc 324,@ware_catalogstatuscode, @ware_status_long OUTPUT
			 		exec gentables_shortdesc 324,@ware_catalogstatuscode,@ware_status_short OUTPUT
					select @ware_status_short  = substring(@ware_status_short,1,8)
				  end
				else
				  begin
					select @ware_status_long = ''
					select @ware_status_short = ''
				  end
BEGIN tran
				INSERT INTO whcatalog (catalogkey,seasonyear,catalogtitle,
					description,catalogtype,catalogtypeshort,purpose,purposeshort,
					version,revision,status,statusshort,layout,primaryimprint,lastuserid,
					lastmaintdate,catalogpubmonth,catalogpubyear)
				VALUES (@i_catalogkey,@ware_seasontype_long,@ware_catalogtitle,
				@ware_description,@ware_cattype_long,@ware_cattype_short,
				@ware_purpose_long,@ware_purpose_short,@ware_versionnumber,
				@ware_revisionnumber,@ware_status_long,@ware_status_short,
				@ware_layoutdesc,@ware_orgentrydesc,'WARE_STORED_PROC',@ware_system_date,@ware_pubmonth,substring(convert(varchar,@ware_pubmonth,101),7,4))
commit tran	
		end
	end /*<>*/
FETCH NEXT FROM warehousecatalog
		INTO @i_catalogkey

	select @i_catstatus = @@FETCH_STATUS
end

close warehousecatalog
deallocate warehousecatalog


GO