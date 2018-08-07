if exists (select * from dbo.sysobjects where id = object_id(N'dbo.qpo_generate_gpocost') and OBJECTPROPERTY(id, N'IsProcedure') = 1)
drop procedure dbo.qpo_generate_gpocost
GO

SET QUOTED_IDENTIFIER ON 
GO
SET ANSI_NULLS ON 
GO

CREATE PROCEDURE qpo_generate_gpocost
 (@i_related_projectkey   integer,
  @i_printing_projectkey  integer,
  @i_gpokey               integer,
  @i_sectionkey           integer,
  @i_subsectionkey        integer,
  @i_quantity             integer,
  @i_taqversionspeccategorykey integer,
  @i_itemcategorycode     integer,
  @i_taqversionkey		  integer,
  @i_report_detail_display_type integer,
  @i_sortorder			  integer,
  @i_gpo_section_desc	  varchar(100),
  @i_lastuserid           varchar(30),
  @o_error_code           integer output,
  @o_error_desc           varchar(2000) output)
AS

/******************************************************************************
**  Name: qpo_generate_gpocost
**  Desc: This procedure will be called from the Generate PO Details procedure.
**        Related project key, printing projectkey,gpokey,sectionkey,subsectionkey,
**        taqversionspecategorykey, itemcategorycode (component)will be passed in.
**	Auth: Kusum
**	Date: 25 September 2014
*******************************************************************************
*******************************************************************************
**    Change History
*******************************************************************************
**    Date:       Author:      Case #:   Description:
**    --------    --------     -------   --------------------------------------
**   
*******************************************************************************/
BEGIN

 SET @o_error_code = 0
 SET @o_error_desc = ''
 
 
 DECLARE @v_taqversionformatkey INT
 DECLARE @v_acctgcode	INT
 DECLARE @v_externalcodedesc VARCHAR(30)
 DECLARE @v_externalcostcode VARCHAR(30)
 DECLARE @v_acceptgenerationind INT
 DECLARE @v_versioncostsamount FLOAT
 DECLARE @v_costkey INT
 DECLARE @v_costlinenumber INT
 DECLARE @v_unitcost FLOAT
 DECLARE @v_totalcost FLOAT
 --DECLARE @v_unitcost FLOAT
 DECLARE @v_pocostind INT
 DECLARE @v_count INT
 DECLARE @v_manualentryind CHAR(1)
 DECLARE @v_pocostind_char CHAR(1)
 DECLARE @v_plstagecode INT
 DECLARE @v_sectionkey INT
 DECLARE @v_potag1 varchar(8)
 DECLARE @v_potag2 varchar(8)
 DECLARE @v_autidmessage varchar(60)
 DECLARE @v_taqversionspeccategorykey INT
 DECLARE @v_min_sortorder INT
 
 
 SELECT @v_taqversionformatkey = taqversionformatkey
   FROM taqversionformatrelatedproject
  WHERE taqprojectkey = @i_related_projectkey
    AND relatedprojectkey = @i_printing_projectkey
    AND plantcostpercent = '100.00'
    AND editioncostpercent = '100.00'
    
  SELECT @v_plstagecode = plstagecode
    FROM taqversionspeccategory
   WHERE taqversionspecategorykey = @i_taqversionspeccategorykey
   
 SELECT @v_min_sortorder = min(sortorder) FROM taqversionspeccategory WHERE taqprojectkey = @i_related_projectkey
 
 IF @v_min_sortorder IS NULL OR @v_min_sortorder = 0
	SELECT @v_min_sortorder = min(itemcategorycode) FROM taqversionspeccategory WHERE taqprojectkey = @i_related_projectkey
    
 IF @i_report_detail_display_type NOT IN (1,2) BEGIN
	IF @i_sortorder = @v_min_sortorder BEGIN
		 DECLARE taqversion_costs_cur CURSOR FOR
		 SELECT DISTINCT c.acctgcode,  
				dbo.qutl_get_cdlist_desc(c.acctgcode,'externaldesc') externalcostdesc,
				dbo.qutl_get_cdlist_desc(c.acctgcode,'externalcode') externalcostcode,
				c.acceptgenerationind,c.versioncostsamount,c.pocostind,c.compunitcost,
				COALESCE(c.taqversionspeccategorykey,0)
		   FROM taqversionformatyear f,taqversioncosts c
		  WHERE f.taqversionformatyearkey = c.taqversionformatyearkey AND
				f.taqprojectformatkey = @v_taqversionformatkey AND 
				c.taqversionspeccategorykey in (@i_taqversionspeccategorykey,0,NULL) 
				AND c.pocostind = 1
				--c.versioncostsamount > 0
			ORDER BY c.acctgcode
	 END
	 ELSE BEGIN
		DECLARE taqversion_costs_cur CURSOR FOR
		 SELECT DISTINCT c.acctgcode,  
				dbo.qutl_get_cdlist_desc(c.acctgcode,'externaldesc') externalcostdesc,
				dbo.qutl_get_cdlist_desc(c.acctgcode,'externalcode') externalcostcode,
				c.acceptgenerationind,c.versioncostsamount,c.pocostind,c.compunitcost,
				COALESCE(c.taqversionspeccategorykey,0)
		   FROM taqversionformatyear f,taqversioncosts c
		  WHERE f.taqversionformatyearkey = c.taqversionformatyearkey AND
				f.taqprojectformatkey = @v_taqversionformatkey AND 
				c.taqversionspeccategorykey = (@i_taqversionspeccategorykey) 
				AND c.pocostind = 1
				--c.versioncostsamount > 0
			ORDER BY c.acctgcode
	 
	 
	 END
END
ELSE BEGIN
	DECLARE taqversion_costs_cur CURSOR FOR
		 SELECT DISTINCT c.acctgcode,  
				dbo.qutl_get_cdlist_desc(c.acctgcode,'externaldesc') externalcostdesc,
				dbo.qutl_get_cdlist_desc(c.acctgcode,'externalcode') externalcostcode,
				c.acceptgenerationind,c.versioncostsamount,c.pocostind,c.compunitcost
		   FROM taqversionformatyear f,taqversioncosts c
		  WHERE f.taqversionformatyearkey = c.taqversionformatyearkey AND
				f.taqprojectformatkey = @v_taqversionformatkey AND
				c.pocostind = 1
				ORDER BY c.acctgcode
END
			
	OPEN taqversion_costs_cur

	FETCH taqversion_costs_cur INTO @v_acctgcode, @v_externalcodedesc, @v_externalcostcode, @v_acceptgenerationind, @v_versioncostsamount,
		@v_pocostind,@v_unitcost,@v_taqversionspeccategorykey

	WHILE @@fetch_status = 0 BEGIN

		IF @i_report_detail_display_type NOT IN (1,2) BEGIN    
		  SELECT @v_totalcost = COALESCE(SUM(c.versioncostsamount),0) 
			FROM taqversioncosts c, taqversionformatyear y 
			WHERE c.taqversionformatyearkey = y.taqversionformatyearkey AND 
				y.taqprojectkey = @i_related_projectkey AND 
				y.plstagecode = @v_plstagecode AND 
				y.taqversionkey = @i_taqversionkey AND 
				y.taqprojectformatkey = @v_taqversionformatkey AND 
				c.acctgcode = @v_acctgcode
			GROUP BY c.acctgcode
		 END
		 ELSE BEGIN
			SELECT @v_totalcost = COALESCE(SUM(c.versioncostsamount),0) 
			  FROM taqversionformatyear f, taqversioncosts c
			 WHERE f.taqversionformatyearkey = c.taqversionformatyearkey AND
				   f.taqprojectformatkey = @v_taqversionformatkey
				GROUP BY c.acctgcode
		 END
			
		 --IF (@i_quantity IS NOT NULL AND @i_quantity <> 0) 
			--SET @v_unitcost = @v_totalcost / @i_quantity --unit cost calculation
			
		 SELECT @v_count = COUNT(*)
		   FROM gpocost
		  WHERE gpokey = @i_gpokey
			AND sectionkey = @i_sectionkey
			AND subsectionkey = COALESCE(@i_subsectionkey,0)
			AND chgcodecode = @v_acctgcode
		    
		 IF @v_count = 0 BEGIN
		 
			SELECT @v_costlinenumber = COALESCE(costlinenumber,0) FROM gpocost WHERE gpokey = @i_gpokey + 1
			
			IF @v_taqversionspeccategorykey = 0 
				SET @v_sectionkey = 1
			ELSE
				SELECT @v_sectionkey = sectionkey FROM gposection WHERE gpokey = @i_gpokey AND key3 = @i_taqversionspeccategorykey
		    
			IF @v_acceptgenerationind = 0 --changed to 0 
				SET @v_manualentryind = 'Y'
			ELSE
				SET @v_manualentryind = 'N'
			
			IF @v_pocostind = 1 	
		     SET @v_pocostind_char = 'Y'
		    ELSE
		     SET @v_pocostind_char = 'N'

			exec get_next_key @i_lastuserid, @v_costkey output
			
			select @v_potag1 = tag1, @v_potag2 = tag2 from cdlist where internalcode=@v_acctgcode
			
						

			INSERT INTO gpocost (gpokey,costkey,sectionkey,subsectionkey, chgcodecode,manualentryind,potag1,potag2,/*auditmessage,*/unitcost,totalcost,lastuserid,
					lastmaintdate,pocostind,costlinenumber)
				VALUES(@i_gpokey,@v_costkey,COALESCE(@v_sectionkey,0),COALESCE(@i_subsectionkey,0),@v_acctgcode,@v_manualentryind,@v_potag1,@v_potag2,@v_unitcost,@v_totalcost,@i_lastuserid,
					getdate(),@v_pocostind_char,@v_costlinenumber)
		END
	  
		FETCH taqversion_costs_cur INTO @v_acctgcode, @v_externalcodedesc, @v_externalcostcode, @v_acceptgenerationind, @v_versioncostsamount,
			@v_pocostind,@v_unitcost,@v_taqversionspeccategorykey
	END
	CLOSE taqversion_costs_cur
	DEALLOCATE taqversion_costs_cur
  
END
GO

GRANT EXEC ON qpo_generate_gpocost TO PUBLIC
GO
