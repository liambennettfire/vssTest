/* Drop the PROCEDURE if it exists */
IF EXISTS (SELECT * FROM dbo.sysobjects WHERE id = Object_id('dbo.specs_copy_write_illus') AND (type = 'P' OR type = 'RF'))
BEGIN
  DROP PROC dbo.specs_copy_write_illus
END
GO

CREATE PROCEDURE specs_copy_write_illus
	(
  @i_from_bookkey     INT,
  @i_from_printingkey INT,
  @i_to_bookkey       INT,
  @i_to_printingkey   INT,
  @i_userid           VARCHAR(30),
  @o_error_code       INT OUTPUT,
  @o_error_desc       VARCHAR(2000) OUTPUT
)
AS

	DECLARE @v_groupnum int,
	@v_userdesc varchar(30) ,
	@v_vendorkey int,
	@v_insertpagecnt int,
	@v_printingmethod int,
	@v_bleedind char(1) ,
	@v_inks int,
	@v_linecuts char(1) ,
	@v_halftones int,
	@v_materialkey int,
   @v_newmaterialkey int,
	@v_notekey int ,
   @v_newnotekey int,
	@v_lastuserid varchar(30) ,
	@v_lastmaintdate datetime,
	@v_perforationscount int,
	@v_film int,
	@v_rmc varchar(30),
	@v_stocktypecode int ,
	@v_basisweight int,
	@v_caliper  float,
	@v_rollsize int,
	@v_speckey varchar(1),
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
	@v_alternatermkey int ,
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
    @v_text varchar(5500),
    @v_showonpoind varchar(1),
    @v_copynextprtgind varchar(1),
    @v_detaillinenbr  INT

	DECLARE illus_cur CURSOR FOR
		SELECT groupnum, userdesc, insertpagecnt, printingmethod, bleedind, inks,
			 linecuts, halftones, materialkey, perforationscount, film
		FROM illus
		WHERE (bookkey=@i_from_bookkey) AND
			 (printingkey=@i_from_printingkey)
		ORDER BY materialkey 

BEGIN

	OPEN illus_cur
   
   FETCH illus_cur INTO @v_groupnum,@v_userdesc,@v_insertpagecnt,@v_printingmethod,@v_bleedind,@v_inks,@v_linecuts,@v_halftones,
		@v_materialkey,@v_perforationscount,@v_film

	WHILE (@@FETCH_STATUS = 0 )
   BEGIN
      IF @v_materialkey > 0
      BEGIN
			 UPDATE keys SET generickey = generickey+1,lastuserid = 'QSIADMIN',lastmaintdate = getdate()

          SELECT @v_newmaterialkey = generickey from keys
      END
      ELSE
        SET @v_newmaterialkey = 0

		INSERT into illus	(bookkey, printingkey, groupnum, userdesc,insertpagecnt, printingmethod, bleedind,
			inks,linecuts,halftones,film,materialkey,lastuserid, lastmaintdate, perforationscount)
 		VALUES (@i_to_bookkey,@i_to_printingkey,@v_groupnum,@v_userdesc,@v_insertpagecnt,@v_printingmethod,@v_bleedind,
          @v_inks,@v_linecuts,@v_halftones,@v_film,@v_newmaterialkey,@i_userid,getdate(),@v_perforationscount)


		IF @v_materialkey > 0
      BEGIN
         SELECT @v_count = count(*)
           FROM materialspecs
          WHERE bookkey=@i_from_bookkey AND
			 		 printingkey=@i_from_printingkey AND
                groupnum = @v_groupnum

        IF @v_count > 0 
        BEGIN
				SELECT @v_rollsize=rollsize,@v_sheetsize=sheetsize,@v_stockdesc=stockdesc,@v_stocktypecode=stocktypecode,@v_basisweight=basisweight,
					@v_paperbulk=paperbulk,@v_rmc=rmc,@v_groupnum=groupnum,@v_currpaperprice=currpaperprice,@v_reserveind=reserveind,@v_rawmaterialkey=rawmaterialkey,
					@v_color=color,@v_opacity=opacity,@v_requireddayind=requireddayind,@v_notekey=notekey,@v_matsuppliercode=matsuppliercode,
					@v_caliper=caliper,@v_mweightfactor=mweightfactor,@v_allocationunit=allocationunit,@v_currpaperpriceunit=currpaperpriceunit
			    FROM materialspecs
           WHERE bookkey=@i_from_bookkey AND
			  		  printingkey=@i_from_printingkey AND
                 groupnum = @v_groupnum

          
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

				 INSERT into materialspecs(materialkey,rollsize,sheetsize,stockdesc,stocktypecode,basisweight,paperbulk,rmc,bookkey,printingkey,
					groupnum,currpaperprice,reserveind,lastuserid,lastmaintdate,rawmaterialkey,color,opacity,notekey,requireddayind,matsuppliercode,
					caliper,mweightfactor,allocationunit,currpaperpriceunit)
				 VALUES (@v_newmaterialkey,@v_rollsize,@v_sheetsize,@v_stockdesc,@v_stocktypecode,@v_basisweight,@v_paperbulk,@v_rmc,@i_to_bookkey,@i_to_printingkey,
					  @v_groupnum,@v_currpaperprice,@v_reserveind,@i_userid,getdate(),@v_rawmaterialkey,@v_color,@v_opacity,@v_newnotekey,@v_requireddayind,@v_matsuppliercode,
					  @v_caliper,@v_mweightfactor,@v_allocationunit,@v_currpaperpriceunit)
			END
		END

		FETCH illus_cur INTO @v_groupnum,@v_userdesc,@v_insertpagecnt,@v_printingmethod,@v_bleedind,@v_inks,@v_linecuts,@v_halftones,
		@v_materialkey,@v_perforationscount,@v_film

	END --- illus_cur
   CLOSE illus_cur
   DEALLOCATE illus_cur

	-- Copy all notes associated with insert specs
   EXEC Specs_Copy_write_notes @i_from_bookkey,@i_from_printingkey,@i_to_bookkey,@i_to_printingkey,8,@i_userid,@o_error_code OUTPUT,@o_error_desc OUTPUT

END
