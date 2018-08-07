/* Drop the PROCEDURE if it exists */
IF EXISTS (SELECT * FROM dbo.sysobjects WHERE id = Object_id('dbo.specs_copy_write_textsigs') AND (type = 'P' OR type = 'RF'))
BEGIN
  DROP PROC dbo.specs_copy_write_textsigs
END
GO

CREATE PROCEDURE specs_copy_write_textsigs 	(@i_from_materialkey INT,
  @i_to_materialkey   INT,
  @i_from_bookkey     INT,
  @i_from_printingkey INT,
  @i_to_bookkey       INT,
  @i_to_printingkey   INT,
  @i_userid           VARCHAR(30)
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
   @v_text varchar(2000),
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



DECLARE textsigs_cursor CURSOR FOR
	SELECT signaturesize,numsignatures from textsigs
  	  WHERE materialkey = @i_from_materialkey and bookkey = @i_from_bookkey and printingkey = @i_from_printingkey

BEGIN
	
	OPEN textsigs_cursor
   FETCH textsigs_cursor INTO  @v_signaturesize,@v_numsignatures

   WHILE (@@FETCH_STATUS = 0 )
   BEGIN
           
		INSERT INTO textsigs (materialkey,signaturesize,bookkey,printingkey,numsignatures,lastuserid,lastmaintdate)  
		 VALUES (@i_to_materialkey,@v_signaturesize,@i_to_bookkey,@i_to_printingkey,@v_numsignatures,@i_userid,getdate()) 
	  
		FETCH textsigs_cursor INTO  @v_signaturesize,@v_numsignatures  
	END  --- textsigs_cursor
	CLOSE textsigs_cursor
	DEALLOCATE textsigs_cursor
END	
go