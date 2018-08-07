if exists (select * from dbo.sysobjects where id = object_id(N'dbo.qpo_generate_gpocost') and OBJECTPROPERTY(id, N'IsProcedure') = 1)
  drop procedure dbo.qpo_generate_gpocost
GO

SET QUOTED_IDENTIFIER ON 
GO
SET ANSI_NULLS ON
GO

CREATE PROCEDURE qpo_generate_gpocost
 (@i_related_projectkey   integer,
  @i_gpokey               integer,
  @i_sectionkey           integer,
  @i_subsectionkey        integer,
  @i_taqversionspeccategorykey integer,
  @i_report_detail_display_type integer,
  @i_first_component  tinyint,
  @i_lastuserid       varchar(30),
  @o_error_code       integer output,
  @o_error_desc       varchar(2000) output)
AS

/******************************************************************************************************
**  Name: qpo_generate_gpocost
**  Desc: This procedure will be called from the Generate PO Details procedure.
**        Related project key, printing projectkey,gpokey,sectionkey,subsectionkey,
**        taqversionspecategorykey will be passed in.
**	Auth: Kusum
**	Date: 25 September 2014
*******************************************************************************************************
**  Change History
*******************************************************************************************************
**  Date:       Author:   Description:
**  --------    -------   --------------------------------------
**	03/03/16    Kate      Took out the restriction for NOT NULL amounts (see case 35860)
**  10/14/15    Kate      Rewritten
**	12/02/16	Dustin	  Case 41464
**  01/17/17	Dustin	  Case 42686
******************************************************************************************************/

DECLARE
  @v_acceptgenerationind INT,
  @v_acctgcode	INT,
  @v_categorykey  INT,
  @v_costkey INT,
  @v_costlinenumber INT,
  @v_count  INT,
  @v_manualentryind CHAR(1),
  @v_min_sortorder INT,
  @v_potag1 VARCHAR(8),
  @v_potag2 VARCHAR(8),
  @v_quantity INT,
  @v_taqversionformatkey INT,
  @v_totalcost FLOAT,
  @v_unitcost FLOAT
  
BEGIN

  SET @o_error_code = 0
  SET @o_error_desc = ''
  
  IF COALESCE(@i_taqversionspeccategorykey, 0) > 0
  BEGIN
	DECLARE cur_format CURSOR FOR
	SELECT fsp.taqversionformatkey --@v_taqversionformatkey
	FROM taqversionspeccategory fsp
	JOIN taqversionformat f
	ON fsp.taqversionformatkey = f.taqprojectformatkey
	WHERE fsp.taqversionspecategorykey = @i_taqversionspeccategorykey 
  END
  ELSE IF COALESCE(@i_subsectionkey, 0) > 0 AND COALESCE(@i_sectionkey, 0) > 0
  BEGIN
	DECLARE cur_format CURSOR FOR
	SELECT taqversionformatkey
	FROM gposubsection
	WHERE sectionkey = @i_sectionkey
	  AND subsectionkey = @i_subsectionkey
  END
  ELSE IF COALESCE(@i_sectionkey, 0) > 0
  BEGIN
	DECLARE cur_format CURSOR FOR
	SELECT taqversionformatkey
	FROM gposection
	WHERE sectionkey = @i_sectionkey
  END
 
  OPEN cur_format

  FETCH cur_format INTO @v_taqversionformatkey
    
  WHILE @@fetch_status = 0
  BEGIN

	  --PRINT 'COSTS @v_taqversionformatkey=' + CONVERT(VARCHAR, @v_taqversionformatkey)
	  --PRINT '@i_gpokey=' + CONVERT(VARCHAR, @i_gpokey)
	  --PRINT '@i_sectionkey=' + CONVERT(VARCHAR, @i_sectionkey)
	  --PRINT '@i_subsectionkey=' + CONVERT(VARCHAR, @i_subsectionkey)
	  --PRINT '@i_taqversionspeccategorykey=' + CONVERT(VARCHAR, @i_taqversionspeccategorykey)
	  --PRINT '@i_first_component=' + CONVERT(VARCHAR, @i_first_component)

	  -- Get section quantity
	  IF @i_subsectionkey > 0
		SELECT @v_quantity = quantity
		FROM gposubsection
		WHERE gpokey = @i_gpokey AND sectionkey = @i_sectionkey AND subsectionkey = @i_subsectionkey
	  ELSE
		SELECT @v_quantity = quantity
		FROM gposection
		WHERE gpokey = @i_gpokey AND sectionkey = @i_sectionkey

	  --PRINT '@v_quantity=' + CONVERT(VARCHAR, @v_quantity)

	  -- Get the initial line number for this  
	  SELECT @v_costlinenumber = MAX(COALESCE(costlinenumber,0)) FROM gpocost WHERE gpokey = @i_gpokey
  
	  IF @v_costlinenumber IS NULL
		SET @v_costlinenumber = 1
	  ELSE
		SET @v_costlinenumber = @v_costlinenumber + 1
	
	  --PRINT '@v_costlinenumber=' + CONVERT(VARCHAR, @v_costlinenumber)
    
	  IF @i_report_detail_display_type NOT IN (1,2)
	  BEGIN
		-- Include costs entered for no component (@i_taqversionspeccategorykey=0) under the first component
		IF @i_first_component = 1
		  DECLARE taqversion_costs_cur CURSOR FOR
			SELECT DISTINCT c.acctgcode, c.acceptgenerationind, COALESCE(c.taqversionspeccategorykey,0)
			  --dbo.qutl_get_cdlist_desc(c.acctgcode,'externaldesc') externalcostdesc, c.versioncostsamount, c.compunitcost    --not needed, left for debugging
			FROM taqversionformatyear f, taqversioncosts c
			WHERE f.taqversionformatyearkey = c.taqversionformatyearkey
			  AND f.taqprojectformatkey = @v_taqversionformatkey
			  AND COALESCE(c.taqversionspeccategorykey,0) IN (@i_taqversionspeccategorykey,0) 
			  AND c.pocostind = 1
			ORDER BY c.acctgcode
		ELSE
		  DECLARE taqversion_costs_cur CURSOR FOR
			SELECT DISTINCT c.acctgcode, c.acceptgenerationind, COALESCE(c.taqversionspeccategorykey,0)
			FROM taqversionformatyear f, taqversioncosts c
			WHERE f.taqversionformatyearkey = c.taqversionformatyearkey
			  AND f.taqprojectformatkey = @v_taqversionformatkey
			  AND c.taqversionspeccategorykey = @i_taqversionspeccategorykey
			  AND c.pocostind = 1
			ORDER BY c.acctgcode
	  END
	  ELSE
		DECLARE taqversion_costs_cur CURSOR FOR
		  SELECT DISTINCT c.acctgcode, c.acceptgenerationind, 0
		  FROM taqversionformatyear f, taqversioncosts c
		  WHERE f.taqversionformatyearkey = c.taqversionformatyearkey
			AND f.taqprojectformatkey = @v_taqversionformatkey
			AND c.pocostind = 1
		  ORDER BY c.acctgcode
			
		OPEN taqversion_costs_cur

		FETCH taqversion_costs_cur INTO @v_acctgcode, @v_acceptgenerationind, @v_categorykey

		WHILE @@fetch_status = 0 BEGIN

		--PRINT '@v_acctgcode=' 
		--PRINT CONVERT(VARCHAR, @v_acctgcode)
		--PRINT '@v_categorykey='
		--Print CONVERT(VARCHAR, @v_categorykey)
			
		SELECT @v_count = COUNT(*)
		FROM gpocost
		WHERE gpokey = @i_gpokey
		  AND sectionkey = @i_sectionkey
		  AND COALESCE(subsectionkey,0) = COALESCE(@i_subsectionkey,0)
		  AND chgcodecode = @v_acctgcode
		    
		IF @v_count = 0
		BEGIN
		 
		  -- Get the sum of the Total cost for the specific chargecode and component when Report Specification Detail Type=3 (Spec Item Detail),
		  -- otherwise, get the sum of the Total cost for this chargecode
		  IF @i_report_detail_display_type NOT IN (1,2)   
			SELECT @v_totalcost = COALESCE(SUM(c.versioncostsamount),0) 
			FROM taqversioncosts c, taqversionformatyear y 
			WHERE c.taqversionformatyearkey = y.taqversionformatyearkey AND 
			  y.taqprojectformatkey = @v_taqversionformatkey AND 
			  c.acctgcode = @v_acctgcode AND
			  c.taqversionspeccategorykey = @v_categorykey
		  ELSE
			SELECT @v_totalcost = COALESCE(SUM(c.versioncostsamount),0), @v_quantity = SUM(f.quantity)
			FROM taqversioncosts c, taqversionformatyear f
			WHERE c.taqversionformatyearkey = f.taqversionformatyearkey AND
			  f.taqprojectformatkey = @v_taqversionformatkey AND
			  c.acctgcode = @v_acctgcode

		  --PRINT '@v_quantity=' + CONVERT(VARCHAR, @v_quantity)

		  -- Calculate the Unit Cost as the Total Cost / section quantity
		  IF @v_quantity > 0
			SET @v_unitcost = @v_totalcost / @v_quantity
		  ELSE
			SET @v_unitcost = NULL   
					    
		  IF @v_acceptgenerationind = 0
			SET @v_manualentryind = 'Y'
		  ELSE
			SET @v_manualentryind = 'N'

		  SELECT @v_potag1 = tag1, @v_potag2 = tag2 
		  FROM cdlist 
		  WHERE internalcode = @v_acctgcode
			
		  EXEC get_next_key @i_lastuserid, @v_costkey OUTPUT

		  INSERT INTO gpocost 
			(gpokey, costkey, sectionkey, subsectionkey, chgcodecode, manualentryind, potag1, potag2,/*auditmessage,*/ 
			unitcost, totalcost, lastuserid, lastmaintdate, pocostind, costlinenumber)
		  VALUES
			(@i_gpokey, @v_costkey, COALESCE(@i_sectionkey,0), COALESCE(@i_subsectionkey,0), @v_acctgcode, @v_manualentryind, @v_potag1, @v_potag2,
			 @v_unitcost, @v_totalcost, @i_lastuserid, getdate(), 'Y', @v_costlinenumber)

		  SET @v_costlinenumber = @v_costlinenumber + 1
		END
	  
		FETCH taqversion_costs_cur INTO @v_acctgcode, @v_acceptgenerationind, @v_categorykey
	  END

	  CLOSE taqversion_costs_cur
	  DEALLOCATE taqversion_costs_cur
  
	  FETCH cur_format INTO @v_taqversionformatkey
  END

  CLOSE cur_format
  DEALLOCATE cur_format
END
GO

GRANT EXEC ON qpo_generate_gpocost TO PUBLIC
GO