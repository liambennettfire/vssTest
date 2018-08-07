/* Drop the PROCEDURE if it exists */
IF EXISTS (SELECT * FROM dbo.sysobjects WHERE id = Object_id('dbo.specs_copy_write_materialspecs') AND (type = 'P' OR type = 'RF'))
BEGIN
  DROP PROC dbo.specs_copy_write_materialspecs
END
GO

CREATE PROCEDURE specs_copy_write_materialspecs 	(
  @i_from_bookkey     INT,
  @i_from_printingkey INT,
  @i_to_bookkey       INT,
  @i_to_printingkey   INT,
  @i_specind          INT,
  @i_userid           VARCHAR(30),
  @o_error_code       INT OUTPUT,
  @o_error_desc       VARCHAR(2000) OUTPUT
)
AS

DECLARE @v_materialkey INT,
	@v_rmc varchar(30),
	@v_stocktypecode int ,
	@v_basisweight int,
	@v_caliper  float,
	@v_rollsize int,
	@v_speckey varchar(1),
	@v_groupnum  int ,
	@v_stockdesc  varchar(20),
	@v_paperbulk int ,
	@v_allocation int ,
	@v_currpaperprice float ,
	@v_sheetsize int ,
	@v_reserveind char(1),
	@v_rawmaterialkey int,
	@v_color int,
	@v_opacity int ,
	@v_requestdate datetime ,
	@v_requireddate datetime ,
	@v_requireddayind varchar(1),
	@v_ldcind varchar(1),
	@v_ldcdate datetime ,
	@v_notekey int ,
	@v_alternatermkey int ,
	@v_lastuserid varchar(30),
	@v_lastmaintdate datetime ,
	@v_actualallocation int ,
	@v_matsuppliercode int ,
	@v_batchgenerate varchar(1),
	@v_allocationunit int ,
	@v_currpaperpriceunit int ,
	@v_mweightfactor int ,
	@v_allocationmr int ,
	@v_allocationper1000 int ,
	@v_requeststat varchar(1),
   @v_count INT,
   @v_newmaterialkey INT,
   @v_newnotekey INT,
   @v_text varchar(5500),
   @v_showonpoind varchar(1),
   @v_copynextprtgind varchar(1),
   @v_detaillinenbr  INT,
   @v_signaturesize INT,
   @v_numsignatures INT,
   @v_convgroupnum INT,
   @v_convrmc varchar(30),
   @v_convstocktypecode INT,
   @v_convcolor INT, 
   @v_convpaperbulk INT,
   @v_convbasisweight INT,
   @v_convrollsize INT,
   @v_convsheetsize INT, 
   @v_convmatsuppliercode INT

DECLARE materialspecs_cur CURSOR FOR
  SELECT materialkey,rollsize,sheetsize,stockdesc,stocktypecode,basisweight,paperbulk,rmc,
			groupnum,currpaperprice,reserveind,rawmaterialkey,color,opacity,requireddayind,notekey,matsuppliercode,
		   caliper,mweightfactor,allocationunit,currpaperpriceunit
	 FROM materialspecs
   WHERE bookkey=@i_from_bookkey AND printingkey=@i_from_printingkey AND groupnum = 0
  ORDER BY materialkey


BEGIN

	  IF @i_specind = 0  -- specs might exist for title/printing being copied to
     BEGIN
		  OPEN materialspecs_cur
		
		  FETCH materialspecs_cur INTO @v_materialkey,@v_rollsize,@v_sheetsize,@v_stockdesc,@v_stocktypecode,@v_basisweight,@v_paperbulk,@v_rmc,
				 @v_groupnum,@v_currpaperprice,@v_reserveind,@v_rawmaterialkey,@v_color,@v_opacity,@v_requireddayind,@v_notekey,@v_matsuppliercode,
				 @v_caliper,@v_mweightfactor,@v_allocationunit,@v_currpaperpriceunit
--print 'first fetch in specind 0'		
		
		  WHILE (@@FETCH_STATUS = 0 )
		  BEGIN

				SELECT @v_count = count(*)
               FROM materialspecs
             WHERE materialkey = @v_materialkey AND
                   bookkey = @i_to_bookkey AND
                   printingkey = @i_to_printingkey
--print'@v_materialkey in specind 0'
--print@v_materialkey
--print'@v_count'
--print@v_count	
            IF @v_count > 0 
            BEGIN
					SELECT @v_convgroupnum=groupnum,@v_convrmc=rmc,@v_convstocktypecode=stocktypecode,@v_convcolor=color,@v_convpaperbulk=paperbulk,
						 @v_convbasisweight=basisweight,@v_convrollsize=rollsize,@v_convsheetsize=sheetsize,@v_convmatsuppliercode=matsuppliercode
					  FROM materialspecs
					 WHERE materialkey = @v_materialkey
				

					-- do not overwrite selected fields if printing already exists
					IF @v_convgroupnum is not null  AND @v_convgroupnum <> 0 
						SET @v_groupnum = @v_convgroupnum
			
					IF @v_convrmc is not NULL AND @v_convrmc <> '' 
						SET @v_rmc = @v_convgroupnum
			
					IF @v_convcolor IS NOT NULL AND @v_convcolor <> 0 
						SET @v_color = @v_convcolor
					
					IF @v_convpaperbulk IS NOT NULL AND @v_convpaperbulk <> 0 
						SET @v_paperbulk = @v_convpaperbulk
	
					IF @v_convstocktypecode IS NOT NULL AND @v_convstocktypecode <> 0 
						SET @v_stocktypecode = @v_convstocktypecode
			
					IF @v_convbasisweight IS NOT NULL AND @v_convstocktypecode <> 0 
						SET @v_stocktypecode = @v_convstocktypecode
			
					IF @v_convrollsize IS NOT NULL AND @v_convrollsize <> 0 
						SET @v_rollsize = @v_convrollsize
						SET @v_sheetsize = NULL
				
					IF @v_convsheetsize IS NOT NULL AND @v_convsheetsize <> 0 
						SET @v_sheetsize = @v_convsheetsize
						SET @v_rollsize = NULL
					
					IF @v_convmatsuppliercode IS NOT NULL AND @v_convmatsuppliercode <> 0 
						SET @v_matsuppliercode = @v_convmatsuppliercode
	
					UPDATE materialspecs
						SET rollsize=@v_rollsize,sheetsize=@v_sheetsize,stockdesc=@v_stockdesc,stocktypecode=@v_stocktypecode,basisweight=@v_basisweight,
							 paperbulk=@v_paperbulk,groupnum=@v_groupnum,rmc=@v_rmc,currpaperprice=@v_currpaperprice,reserveind=@v_reserveind,
							 rawmaterialkey=@v_rawmaterialkey,color=@v_color,opacity=@v_opacity,requireddayind=@v_requireddayind,notekey=@v_notekey,
							 matsuppliercode=@v_matsuppliercode,caliper=@v_caliper,mweightfactor=@v_mweightfactor,allocationunit=@v_allocationunit
					 WHERE materialkey = @v_materialkey AND
							 bookkey = @i_to_bookkey AND
							 printingkey = @i_to_printingkey
            END 
            ELSE
            BEGIN
					 IF @v_notekey is not null and @v_notekey <> 0
					 BEGIN
						SELECT @v_text = text,@v_showonpoind = showonpoind,@v_copynextprtgind = copynextprtgind,@v_detaillinenbr = detaillinenbr
						  FROM note  
						 WHERE notekey= @v_notekey
					
						UPDATE keys SET generickey = generickey+1,lastuserid = 'QSIADMIN',lastmaintdate = getdate()
		
						SELECT @v_newnotekey = generickey from keys
						
						INSERT INTO note (notekey,text,bookkey,printingkey,compkey,showonpoind,copynextprtgind,detaillinenbr,lastuserid,lastmaintdate )
							VALUES (@v_newnotekey,@v_text,@i_to_bookkey,@i_to_printingkey,0,@v_showonpoind,@v_copynextprtgind,@v_detaillinenbr,@i_userid,getdate())
					 END
					 ELSE
					 BEGIN
						SET @v_newnotekey = NULL
					 END
			
					 UPDATE keys SET generickey = generickey+1,lastuserid = 'QSIADMIN',lastmaintdate = getdate()

                SELECT @v_newmaterialkey = generickey from keys

					INSERT into materialspecs (materialkey,rollsize,sheetsize,stockdesc,stocktypecode,basisweight,paperbulk,rmc,bookkey,printingkey,
					groupnum,currpaperprice,reserveind,lastuserid,lastmaintdate,rawmaterialkey,color,opacity,notekey,requireddayind,matsuppliercode,
					caliper,mweightfactor,allocationunit,currpaperpriceunit)
					VALUES (@v_newmaterialkey,@v_rollsize,@v_sheetsize,@v_stockdesc,@v_stocktypecode,@v_basisweight,@v_paperbulk,@v_rmc,@i_to_bookkey,@i_to_printingkey,
					  0,@v_currpaperprice,@v_reserveind,@i_userid,getdate(),@v_rawmaterialkey,@v_color,@v_opacity,@v_newnotekey,@v_requireddayind,@v_matsuppliercode,
					  @v_caliper,@v_mweightfactor,@v_allocationunit,@v_currpaperpriceunit)

					 SELECT @v_count = count(*)
						FROM textsigs
					  WHERE materialkey = @v_materialkey and bookkey = @i_from_bookkey and printingkey = @i_from_printingkey
		
					 IF @v_count > 0 
					 BEGIN
						EXEC specs_copy_write_textsigs @v_materialkey,@v_newmaterialkey,@i_from_bookkey,@i_from_printingkey,@i_to_bookkey,@i_to_printingkey,@i_userid
					 END	
				END

				FETCH materialspecs_cur INTO @v_materialkey,@v_rollsize,@v_sheetsize,@v_stockdesc,@v_stocktypecode,@v_basisweight,@v_paperbulk,@v_rmc,
				 @v_groupnum,@v_currpaperprice,@v_reserveind,@v_rawmaterialkey,@v_color,@v_opacity,@v_requireddayind,@v_notekey,@v_matsuppliercode,
				 @v_caliper,@v_mweightfactor,@v_allocationunit,@v_currpaperpriceunit


		  END   ----materialspecs_cur
		  CLOSE materialspecs_cur
		  DEALLOCATE materialspecs_cur
     END
     IF @i_specind = 1    --specs exist for title/printing being copied from 
     BEGIN
		
		  OPEN materialspecs_cur
		
		  FETCH materialspecs_cur INTO @v_materialkey,@v_rollsize,@v_sheetsize,@v_stockdesc,@v_stocktypecode,@v_basisweight,@v_paperbulk,@v_rmc,
             @v_groupnum,@v_currpaperprice,@v_reserveind,@v_rawmaterialkey,@v_color,@v_opacity,@v_requireddayind,@v_notekey,@v_matsuppliercode,
				 @v_caliper,@v_mweightfactor,@v_allocationunit,@v_currpaperpriceunit
			
		  WHILE (@@FETCH_STATUS = 0 )
		  BEGIN

			 IF @v_notekey is not null and @v_notekey <> 0
          BEGIN
				SELECT @v_text = text,@v_showonpoind = showonpoind,@v_copynextprtgind = copynextprtgind,@v_detaillinenbr = detaillinenbr
				  FROM note  
				 WHERE notekey= @v_notekey
			
				UPDATE keys SET generickey = generickey+1,lastuserid = 'QSIADMIN',lastmaintdate = getdate()

				SELECT @v_newnotekey = generickey from keys
				
				INSERT INTO note (notekey,text,bookkey,printingkey,compkey,showonpoind,copynextprtgind,detaillinenbr,lastuserid,lastmaintdate )
					VALUES (@v_newnotekey,@v_text,@i_to_bookkey,@i_to_printingkey,0,@v_showonpoind,@v_copynextprtgind,@v_detaillinenbr,@i_userid,getdate())
			 END
          ELSE
          BEGIN
          	SET @v_newnotekey = NULL
          END
   
          UPDATE keys SET generickey = generickey+1,lastuserid = 'QSIADMIN',lastmaintdate = getdate()

          SELECT @v_newmaterialkey = generickey from keys

			 INSERT into materialspecs (materialkey,rollsize,sheetsize,stockdesc,stocktypecode,basisweight,paperbulk,rmc,bookkey,printingkey,
		 		groupnum,currpaperprice,reserveind,lastuserid,lastmaintdate,rawmaterialkey,color,opacity,notekey,requireddayind,matsuppliercode,
		 		caliper,mweightfactor,allocationunit,currpaperpriceunit)
				VALUES (@v_newmaterialkey,@v_rollsize,@v_sheetsize,@v_stockdesc,@v_stocktypecode,@v_basisweight,@v_paperbulk,@v_rmc,@i_to_bookkey,@i_to_printingkey,
              0,@v_currpaperprice,@v_reserveind,@i_userid,getdate(),@v_rawmaterialkey,@v_color,@v_opacity,@v_newnotekey,@v_requireddayind,@v_matsuppliercode,
              @v_caliper,@v_mweightfactor,@v_allocationunit,@v_currpaperpriceunit)

          SELECT @v_count = count(*)
            FROM textsigs
           WHERE materialkey = @v_materialkey and bookkey = @i_from_bookkey and printingkey = @i_from_printingkey

          IF @v_count > 0 
          BEGIN
            EXEC specs_copy_write_textsigs @v_materialkey,@v_newmaterialkey,@i_from_bookkey,@i_from_printingkey,@i_to_bookkey,@i_to_printingkey,@i_userid
			 END	
			
			 FETCH materialspecs_cur INTO @v_materialkey,@v_rollsize,@v_sheetsize,@v_stockdesc,@v_stocktypecode,@v_basisweight,@v_paperbulk,@v_rmc,
             @v_groupnum,@v_currpaperprice,@v_reserveind,@v_rawmaterialkey,@v_color,@v_opacity,@v_requireddayind,@v_notekey,@v_matsuppliercode,
				 @v_caliper,@v_mweightfactor,@v_allocationunit,@v_currpaperpriceunit
		  END   ----materialspecs_cur

		  CLOSE materialspecs_cur
		  DEALLOCATE materialspecs_cur
		END		

END 
go