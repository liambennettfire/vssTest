-- 8/6/04 - AA - CRM 01674 - The WH title catalog table should be built 
-- from a stored procedure which can be called either from an Incremental 
-- or Full Build procedure.  Build table according to bookkey,
--  ** Be sure to create a row on tables 
-- at all times even if title is not attached to any catalogs 
-- currently only doing retail catalogs do add other just add to select and repeat the update for that catalogtype

PRINT 'STORED PROCEDURE : dbo.datawarehouse_whtitlecatalog'
GO

IF EXISTS (SELECT * FROM dbo.sysobjects WHERE id = 
		Object_id('dbo.datawarehouse_whtitlecatalog') AND (type = 'P' OR type = 'RF'))
BEGIN
	DROP PROC dbo.datawarehouse_whtitlecatalog
END

GO

CREATE  proc dbo.datawarehouse_whtitlecatalog
@ware_bookkey int, @ware_logkey int, @ware_warehousekey int,@ware_system_date datetime

AS


DECLARE @ware_count  INT 
DECLARE @nc_sqlstring NVARCHAR(4000)
DECLARE @nc_sqlparameters NVARCHAR(4000)
DECLARE @c_catalogtitle VARCHAR(100)
DECLARE @c_description VARCHAR(50)
DECLARE @i_catalogtypecode INT
DECLARE @i_catalogkey INT
DECLARE @d_pubmonth datetime

DECLARE warehousewhtitlecatalog INSENSITIVE CURSOR
FOR
     select distinct c.catalogkey,c.catalogtitle,c.description,c.catalogtypecode,c.pubmonth
			from bookcatalog b,catalogsection cs, catalog c
			  where b.bookkey=@ware_bookkey
				and b.sectionkey=cs.sectionkey
				and cs.catalogkey=c.catalogkey
			order by catalogtypecode,c.pubmonth,c.catalogtitle

FOR READ ONLY


	SELECT @ware_count = 1
BEGIN tran
	DELETE FROM whtitlecatalog
	WHERE bookkey = @ware_bookkey

	INSERT INTO whtitlecatalog(bookkey, lastuserid, lastmaintdate)
	  VALUES (@ware_bookkey, 'WARE_STORED_PROC', @ware_system_date)

commit tran

	OPEN warehousewhtitlecatalog

	FETCH NEXT FROM warehousewhtitlecatalog
	  INTO @i_catalogkey, @c_catalogtitle, @c_description,@i_catalogtypecode,@d_pubmonth

	WHILE (@@FETCH_STATUS <> - 1)
	  BEGIN

-- currently only using catalogtypecode =1, retail, to add others just repeat below

		IF @i_catalogtypecode = 1 
		  BEGIN	
			IF @ware_count <=20
			  BEGIN
				if @c_catalogtitle is null 
				  begin
					select @c_catalogtitle = ''
				  end
				if @c_description is null 
				  begin
					select @c_description = ''
				  end
BEGIN tran
				set @nc_sqlstring = N'update whtitlecatalog set '  + 'retailcatalogtitle' + 
				   convert (varchar (10),@ware_count) + '=@c_catalogtitle,' + 'retailcatalogdescription' +
				   convert (varchar (10),@ware_count) + '=@c_description,' +
				  'retailcatalogkey' + convert (varchar (10),@ware_count) + '=@i_catalogkey' +' where bookkey= @ware_bookkey'
				
				set @nc_sqlparameters = '@ware_bookkey INT, @i_catalogkey INT, @c_catalogtitle varchar (100),@c_description varchar(50)'

				EXEC sp_executesql @nc_sqlstring, @nc_sqlparameters,@ware_bookkey, @i_catalogkey,@c_catalogtitle,@c_description


				if @@ROWCOUNT = 0 or  @@ERROR <> 0
				  begin
					INSERT INTO wherrorlog (logkey, warehousekey,errordesc,
        				  errorseverity, errorfunction,lastuserid, lastmaintdate)
					 VALUES (convert(varchar (10),@ware_logkey)  ,convert(varchar (10),@ware_warehousekey),
					'Unable to insert whtitlecatalog',
					('Warning/data error bookkey ' + convert(varchar (10),@ware_bookkey)),
					'Stored procedure datawarehouse_whtitlecatalog','WARE_STORED_PROC', @ware_system_date)
				  end
commit tran
				select @ware_count = @ware_count + 1
			END  /* count */
		END   /* catalogtype */


		FETCH NEXT FROM warehousewhtitlecatalog
	  		INTO @i_catalogkey, @c_catalogtitle, @c_description,@i_catalogtypecode,@d_pubmonth
	  END
      
	CLOSE warehousewhtitlecatalog
	DEALLOCATE warehousewhtitlecatalog

GO

GRANT EXECUTE ON  dbo.datawarehouse_whtitlecatalog TO PUBLIC

GO