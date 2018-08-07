PRINT 'STORED PROCEDURE : dbo.datawarehouse_bookcustom'
GO

if exists (select * from dbo.sysobjects where id = Object_id('dbo.datawarehouse_bookcustom') and (type = 'P' or type = 'RF'))
begin
 drop proc dbo.datawarehouse_bookcustom
end

GO

create proc dbo.datawarehouse_bookcustom
@ware_bookkey int, @ware_logkey int, @ware_warehousekey int,
@ware_system_date datetime

AS 

 
DECLARE @ware_count int
DECLARE @lv_rowcount int
DECLARE @LV_CUSTOMIND01 VARCHAR(3) 
DECLARE @LV_CUSTOMIND02 VARCHAR(3) 
DECLARE @LV_CUSTOMIND03 VARCHAR(3) 
DECLARE @LV_CUSTOMIND04 VARCHAR(3) 
DECLARE @LV_CUSTOMIND05 VARCHAR(3) 
DECLARE @LV_CUSTOMIND06 VARCHAR(3) 
DECLARE @LV_CUSTOMIND07 VARCHAR(3) 
DECLARE @LV_CUSTOMIND08 VARCHAR(3) 
DECLARE @LV_CUSTOMIND09 VARCHAR(3) 
DECLARE @LV_CUSTOMIND10 VARCHAR(3) 
DECLARE @LV_CUSTOMCODE01 int
DECLARE @LV_CUSTOMCODE02  int
DECLARE @LV_CUSTOMCODE03  int
DECLARE @LV_CUSTOMCODE04  int
DECLARE @LV_CUSTOMCODE05 int 
DECLARE @LV_CUSTOMCODE06  int
DECLARE @LV_CUSTOMCODE07  int
DECLARE @LV_CUSTOMCODE08  int
DECLARE @LV_CUSTOMCODE09  int
DECLARE @LV_CUSTOMCODE10  int

DECLARE @lv_gentableid int
DECLARE @lv_custind1 varchar(3) 
DECLARE @lv_custind2 varchar(3) 
DECLARE @lv_custind3 varchar(3) 
DECLARE @lv_custind4 varchar(3) 
DECLARE @lv_custind5 varchar(3) 
DECLARE @lv_custind6 varchar(3) 
DECLARE @lv_custind7 varchar(3) 
DECLARE @lv_custind8 varchar(3) 
DECLARE @lv_custind9 varchar(3) 
DECLARE @lv_custind10 varchar(3) 
DECLARE @lv_description1 varchar(40) 
DECLARE @lv_description2 varchar(40) 
DECLARE @lv_description3 varchar(40) 
DECLARE @lv_description4 varchar(40) 
DECLARE @lv_description5 varchar(40) 
DECLARE @lv_description6 varchar(40) 
DECLARE @lv_description7 varchar(40) 
DECLARE @lv_description8 varchar(40) 
DECLARE @lv_description9 varchar(40) 
DECLARE @lv_description10 varchar(40) 


select @ware_count = 0

select @lv_rowcount = 0
SELECT @lv_rowcount = count(*) 
	FROM bookcustom WHERE BOOKKEY = @ware_bookkey
	
if @lv_rowcount = 0 
  begin
	insert into whtitlecustom (bookkey,lastuserid,lastmaintdate)
		values (@ware_bookkey,'WARE_STORED_PROC', @ware_system_date)
  end
else
  begin
	SELECT  @LV_CUSTOMIND01 = CUSTOMIND01 , @LV_CUSTOMIND02 =CUSTOMIND02 , @LV_CUSTOMIND03 =CUSTOMIND03 , @LV_CUSTOMIND04  = CUSTOMIND04 , 
		@LV_CUSTOMIND05 = CUSTOMIND05 , @LV_CUSTOMIND06 =CUSTOMIND06 , @LV_CUSTOMIND07 = CUSTOMIND07 , @LV_CUSTOMIND08  =CUSTOMIND08 , 
		@LV_CUSTOMIND09 = CUSTOMIND09 , @LV_CUSTOMIND10 = CUSTOMIND10 , @LV_CUSTOMCODE01 = CUSTOMCODE01 , @LV_CUSTOMCODE02 = CUSTOMCODE02 , 
		@LV_CUSTOMCODE03 = CUSTOMCODE03 , @LV_CUSTOMCODE04  = CUSTOMCODE04 ,@LV_CUSTOMCODE05 = CUSTOMCODE05 , @LV_CUSTOMCODE06 = CUSTOMCODE06,
		@LV_CUSTOMCODE07 = CUSTOMCODE07 , @LV_CUSTOMCODE08 = CUSTOMCODE08 , @LV_CUSTOMCODE09  = CUSTOMCODE09 , 
		@LV_CUSTOMCODE10 = CUSTOMCODE10 
			FROM BOOKCUSTOM WHERE BOOKKEY = @ware_bookkey

		if @lv_customind01 = 1 
		 begin
			select @lv_custind1 = 'Yes'
		 end
		else	
		 begin
			select @lv_custind1 = 'No'
		 end

		if @lv_customind02 = 1 
		  begin
			select @lv_custind2 = 'Yes'
		  end
		else	
		  begin
			select @lv_custind2 = 'No'
		  end	
	
		if @lv_customind03 = 1 
		  begin
			select @lv_custind3 = 'Yes'
		  end
		else	
		  begin
			select @lv_custind3 = 'No'
		  end

		if @lv_customind04 = 1 
		  begin
			select @lv_custind4 = 'Yes'
		  end
		else	
		  begin  
			select @lv_custind4 = 'No'
		  end
			
		if @lv_customind05 = 1 
		  begin
			select @lv_custind5 = 'Yes'
		  end
		else	
		  begin
			select @lv_custind5 = 'No'
		  end
			
		if @lv_customind06 = 1 
		  begin
			select @lv_custind6 = 'Yes'
		  end
		else		
		  begin
			select @lv_custind6 = 'No'
		  end
			
		if @lv_customind07 = 1 
		  begin
			select @lv_custind7 = 'Yes'
		  end
		else	
		  begin
			select @lv_custind7 = 'No'
		  end
			
		if @lv_customind08 = 1 
		  begin
			select @lv_custind8 = 'Yes'
		  end
		else	
		  begin
			select @lv_custind8 = 'No'
		  end
			
		if @lv_customind09 = 1 
		  begin
			select @lv_custind9 = 'Yes'
		  end
		else	
		  begin
			select @lv_custind9 = 'No'
		  end
			
		if @lv_customind10 = 1 		
		  begin
			select @lv_custind10 = 'Yes'
		 end
		else	
		  begin
			select @lv_custind10 = 'No'
		  end

			select @lv_gentableid = 0
			select @ware_count = 0
		
			if @lv_customcode01 > 0 
			  begin
				select @ware_count = count(*)
					from  gentablesdesc g
						where upper(rtrim(tabledesclong)) = (select upper(rtrim(c.customfieldlabel))
						from customfieldsetup c where upper(customfieldname) ='CUSTOMCODE01')
				if @ware_count > 0 
				  begin
					select @lv_gentableid = tableid
						from  gentablesdesc g
							where upper(rtrim(tabledesclong)) = (select upper(rtrim(c.customfieldlabel)) 
								from customfieldsetup c where upper(customfieldname) ='CUSTOMCODE01')
					if @lv_gentableid > 0 
					  begin
						select @lv_description1 = datadesc  
							from gentables where tableid= @lv_gentableid and datacode= @lv_customcode01
					  end
				  end
			  end
			select @lv_gentableid = 0
			select @ware_count = 0
		
			if @lv_customcode02 > 0 	
			  begin
				select @ware_count = count(*)
					from  gentablesdesc g
						where upper(rtrim(tabledesclong)) = (select upper(rtrim(c.customfieldlabel))
							from customfieldsetup c where upper(customfieldname) ='CUSTOMCODE02')
				if @ware_count > 0 
				  begin
					select @lv_gentableid = tableid 
							from  gentablesdesc g
								where upper(rtrim(tabledesclong)) = (select upper(rtrim(c.customfieldlabel)) 
									from customfieldsetup c where upper(customfieldname) ='CUSTOMCODE02')
					if @lv_gentableid > 0 
					  begin
						select @lv_description2 =datadesc
							from gentables where tableid= @lv_gentableid and datacode= @lv_customcode02
					  end
				  end
			  end
			select @lv_gentableid = 0
			select @ware_count = 0
		
			if @lv_customcode03 > 0 
			  begin
				select @ware_count = count(*)
					from  gentablesdesc g
						where upper(rtrim(tabledesclong)) = (select upper(rtrim(c.customfieldlabel)) 
							from customfieldsetup c where upper(customfieldname) ='CUSTOMCODE03')
				if @ware_count > 0 
				  begin
					select @lv_gentableid = tableid
					from  gentablesdesc g
						where upper(rtrim(tabledesclong)) = (select upper(rtrim(c.customfieldlabel)) 
							from customfieldsetup c where upper(customfieldname) ='CUSTOMCODE03')
					if @lv_gentableid > 0 
					  begin
						select  @lv_description3 = datadesc
							from gentables where tableid= @lv_gentableid and datacode= @lv_customcode03
					  end
				  end
			  end

			select @lv_gentableid = 0
			select @ware_count = 0

			if @lv_customcode04 > 0 
			  begin
				select @ware_count = count(*)
						from  gentablesdesc g
							where upper(rtrim(tabledesclong)) = (select upper(rtrim(c.customfieldlabel)) 
								from customfieldsetup c where upper(customfieldname) ='CUSTOMCODE04')
				if @ware_count > 0 
				  begin
					select @lv_gentableid = tableid
							from  gentablesdesc g
								where upper(rtrim(tabledesclong)) = (select upper(rtrim(c.customfieldlabel)) 
									from customfieldsetup c where upper(customfieldname) ='CUSTOMCODE04')
					if @lv_gentableid > 0 
					  begin
						select @lv_description4 = datadesc
							from gentables where tableid= @lv_gentableid and datacode= @lv_customcode04
					  end
				  end
			  end

			select @lv_gentableid = 0
			select @ware_count = 0

			if @lv_customcode05 > 0 
			  begin
				select @ware_count = count(*)
						from  gentablesdesc g
							where upper(rtrim(tabledesclong)) = (select upper(rtrim(c.customfieldlabel)) 
								from customfieldsetup c where upper(customfieldname) ='CUSTOMCODE05')
				if @ware_count > 0 
				  begin
					select @lv_gentableid = tableid
							from  gentablesdesc g
								where upper(rtrim(tabledesclong)) = (select upper(rtrim(c.customfieldlabel)) 
									from customfieldsetup c where upper(customfieldname) ='CUSTOMCODE05')
					if @lv_gentableid > 0 
					  begin
						select @lv_description5 = datadesc
							from gentables where tableid= @lv_gentableid and datacode= @lv_customcode05
					  end
				  end
			  end

			select @lv_gentableid = 0
			select @ware_count = 0
		
			if @lv_customcode06 > 0 
			  begin
				select @ware_count = count(*)
						from  gentablesdesc g
							where upper(rtrim(tabledesclong)) = (select upper(rtrim(c.customfieldlabel)) 
								from customfieldsetup c where upper(customfieldname) ='CUSTOMCODE06')
				if @ware_count > 0 
				  begin
					select @lv_gentableid = tableid
							from  gentablesdesc g
								where upper(rtrim(tabledesclong)) = (select upper(rtrim(c.customfieldlabel)) 
									from customfieldsetup c where upper(customfieldname) ='CUSTOMCODE06')
					if @lv_gentableid > 0 
					  begin
						select @lv_description6 = datadesc
							from gentables where tableid= @lv_gentableid and datacode= @lv_customcode06
					  end
				 end
			 end

			select @lv_gentableid = 0
			select @ware_count = 0

		
			if @lv_customcode07 > 0
			  begin
				select  @ware_count = count(*) 
						from  gentablesdesc g
							where upper(rtrim(tabledesclong)) = (select upper(rtrim(c.customfieldlabel)) 
								from customfieldsetup c where upper(customfieldname) ='CUSTOMCODE07')
				if @ware_count > 0 
				  begin
					select @lv_gentableid  = tableid
							from  gentablesdesc g
								where upper(rtrim(tabledesclong)) = (select upper(rtrim(c.customfieldlabel)) 
									from customfieldsetup c where upper(customfieldname) ='CUSTOMCODE07')
					if @lv_gentableid > 0 
					 begin
						select @lv_description7 = datadesc
							from gentables where tableid= @lv_gentableid and datacode= @lv_customcode07
					  end
				  end
			  end

			select @lv_gentableid = 0
			select @ware_count = 0
		
			if @lv_customcode08 > 0 
			  begin
				select @ware_count = count(*)
						from  gentablesdesc g
							where upper(rtrim(tabledesclong)) = (select upper(rtrim(c.customfieldlabel)) 
								from customfieldsetup c where upper(customfieldname) ='CUSTOMCODE08')
				if @ware_count > 0 
				  begin
					select @lv_gentableid = tableid
							from  gentablesdesc g
								where upper(rtrim(tabledesclong)) = (select upper(rtrim(c.customfieldlabel)) 
									from customfieldsetup c where upper(customfieldname) ='CUSTOMCODE08')
					if @lv_gentableid > 0 
					  begin
						select @lv_description8 = datadesc
							from gentables where tableid= @lv_gentableid and datacode= @lv_customcode08
					  end
				  end
			  end
	
			select @lv_gentableid = 0
			select @ware_count = 0

			if @lv_customcode09 > 0 
			  begin
				select @ware_count = count(*)
						from  gentablesdesc g
							where upper(rtrim(tabledesclong)) = (select upper(rtrim(c.customfieldlabel)) 
								from customfieldsetup c where upper(customfieldname) ='CUSTOMCODE09')
				if @ware_count > 0 
				  begin
					select @lv_gentableid = tableid
							from  gentablesdesc g
								where upper(rtrim(tabledesclong)) = (select upper(rtrim(c.customfieldlabel)) 
									from customfieldsetup c where upper(customfieldname) ='CUSTOMCODE09')
					if @lv_gentableid > 0 
					  begin
						select @lv_description9 = datadesc
							from gentables where tableid= @lv_gentableid and datacode= @lv_customcode09
					  end 
				  end
			  end

			select @lv_gentableid = 0
			select @ware_count = 0

			if @lv_customcode10 > 0 
			  begin
				select  @ware_count = count(*)
						from  gentablesdesc g
							where upper(rtrim(tabledesclong)) = (select upper(rtrim(c.customfieldlabel))
								from customfieldsetup c where upper(customfieldname) ='CUSTOMCODE10')
				if @ware_count > 0 
				  begin
					select  @lv_gentableid = tableid
							from  gentablesdesc g
							where upper(rtrim(tabledesclong)) = (select upper(rtrim(c.customfieldlabel)) 
									from customfieldsetup c where upper(customfieldname) ='CUSTOMCODE10')
					if @lv_gentableid > 0 
					  begin
						select @lv_description10 = datadesc 
							from gentables where tableid= @lv_gentableid and datacode= @lv_customcode10
					  end
				  end
			  end
BEGIN tran
			insert into whtitlecustom
				(BOOKKEY,CUSTOMYESNO01 , CUSTOMYESNO02 , CUSTOMYESNO03 , CUSTOMYESNO04 , 
				CUSTOMYESNO05 , CUSTOMYESNO06 , CUSTOMYESNO07 , CUSTOMYESNO08 , CUSTOMYESNO09 , 
				CUSTOMYESNO10 , CUSTOMDESC01 , CUSTOMDESC02 , CUSTOMDESC03 , CUSTOMDESC04 , 
				CUSTOMDESC05 , CUSTOMDESC06 , CUSTOMDESC07 , CUSTOMDESC08 , CUSTOMDESC09 , 
				CUSTOMDESC10,CUSTOMINT01 , CUSTOMINT02 , CUSTOMINT03 , CUSTOMINT04 , CUSTOMINT05 , 
				CUSTOMINT06 , CUSTOMINT07 , CUSTOMINT08 , CUSTOMINT09 , CUSTOMINT10, CUSTOMFLOAT01 , 
				CUSTOMFLOAT02 , CUSTOMFLOAT03 , CUSTOMFLOAT04 , CUSTOMFLOAT05 , CUSTOMFLOAT06 , 
				CUSTOMFLOAT07 , CUSTOMFLOAT08 , CUSTOMFLOAT09 , CUSTOMFLOAT10 ,LASTUSERID,LASTMAINTDATE)
		
				SELECT @ware_bookkey ,@lv_custind1  ,@lv_custind2  ,@lv_custind3  ,@lv_custind4  ,@lv_custind5 ,
					@lv_custind6  ,@lv_custind7  ,@lv_custind8  ,@lv_custind9  ,@lv_custind10 ,
					@lv_description1  ,@LV_description2 ,@LV_description3  ,@LV_description4  ,@LV_description5 ,
					@lv_description6  ,@LV_description7  ,@LV_description8  ,@LV_description9  ,@LV_description10 ,
					CUSTOMINT01 , CUSTOMINT02 , CUSTOMINT03 , CUSTOMINT04 , CUSTOMINT05 , 
					CUSTOMINT06 , CUSTOMINT07 , CUSTOMINT08 , CUSTOMINT09 , CUSTOMINT10, CUSTOMFLOAT01 , 
					CUSTOMFLOAT02 , CUSTOMFLOAT03 , CUSTOMFLOAT04 , CUSTOMFLOAT05 , CUSTOMFLOAT06 , 
					CUSTOMFLOAT07 , CUSTOMFLOAT08 , CUSTOMFLOAT09 , CUSTOMFLOAT10 ,'WARE_STORED_PROC',@ware_system_date
						FROM BOOKCUSTOM WHERE BOOKKEY= @ware_bookkey
commit tran
  END		
/**
			if SQL%ROWCOUNT > 0 then 
				commit
			else
				INSERT INTO qsidba.wherrorlog (logkey, warehousekey,errordesc, 
      			    errorseverity, errorfunction,lastuserid, lastmaintdate)
				 VALUES (to_char(ware_logkey)  ,to_char(ware_warehousekey),
					'Unable to update whtitlecustom table - for book custom',
					('Warning/data error bookkey'||to_char(ware_bookkey)),
					'Stored procedure datawarehouse_bookcustom','WARE_STORED_PROC', ware_system_date) 
				commit
			end if
**/


GO