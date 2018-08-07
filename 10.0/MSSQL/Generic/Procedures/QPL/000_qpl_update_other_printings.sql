if exists (select * from dbo.sysobjects where id = object_id(N'dbo.qpl_update_other_printings') and OBJECTPROPERTY(id, N'IsProcedure') = 1)
  drop procedure dbo.qpl_update_other_printings
GO

SET QUOTED_IDENTIFIER ON 
GO
SET ANSI_NULLS ON 
GO

CREATE PROCEDURE qpl_update_other_printings
 (@i_projectkey   integer,
  @i_plstage      integer,
  @i_plversion    integer,
  @i_formatkey    integer,
  @i_chargecode   integer,
  @i_fromprinting integer,
  @i_newcalctype  integer,
  @i_newnote      varchar(2000),
  @i_userid       varchar(30),
  @i_plcalccostsubcode integer,
  @i_taqversionspeccategorykey integer,
  @o_error_code   integer output,
  @o_error_desc   varchar(2000) output)
AS

/**************************************************************************************************************
**  Name: qpl_update_other_printings
**  Desc: This stored procedure maintains the printings other than the 2 visible printings on 
**        the Production Costs by Printing page - this stored procedure must be called separately 
**        but as part of the same transaction when the values for the 2 visible printing columns are updated.
**
**  Auth: Kate
**  Date: March 19 2008
**************************************************************************************************************
**  Change History
**************************************************************************************************************
**  Date:        Author:     Description:
**  ----------   --------    ---------------------------------------------------------------------------------
**  05/08/2018   Colman      Case 51306 double lines appearing in the costs window for PL
**************************************************************************************************************/

DECLARE
  @v_count  INT,
  @v_count_in_taqprojectmisc  INT,
  @v_error  INT,
  @v_externalcode VARCHAR(20),
  @v_formatyearkey  INT,
  @v_mrchargeexternalcode VARCHAR(20),
  @v_prepchargeexternalcode VARCHAR(20),
  @v_printingnumber INT,
  @v_ppbrunchargeexternalcode VARCHAR(20),
  @v_pocostind TINYINT,
  @v_set_acctgcode_to_zero BIT -- 1 = true, 0 = false

BEGIN

  SET @o_error_code = 0
  SET @o_error_desc = ''
  SET @v_set_acctgcode_to_zero = 0
  
  -- 6/24/15 - KW - Because taqversioncosts may have entirely different years in each Printing than taqversionformatyear records,
  -- we must use the correct taqversionformatyearkeys from costs if the records already exist; otherwise default from taqversionformatyear values
  DECLARE formatyear_cur CURSOR FOR 
    SELECT printingnumber
    FROM taqversionformatyear
    WHERE taqprojectkey = @i_projectkey AND
      plstagecode = @i_plstage AND
      taqversionkey = @i_plversion AND
      taqprojectformatkey = @i_formatkey AND
      (printingnumber < @i_fromprinting OR printingnumber >= @i_fromprinting + 2)

  OPEN formatyear_cur
  
  FETCH formatyear_cur INTO @v_printingnumber

  WHILE @@fetch_status = 0
  BEGIN

    SELECT @v_count = COUNT(*)
    FROM taqversioncosts 
    WHERE printingnumber = @v_printingnumber
      AND acctgcode = @i_chargecode
      AND taqversionformatyearkey IN (SELECT taqversionformatyearkey 
                                      FROM taqversionformatyear
                                      WHERE taqprojectkey = @i_projectkey AND
                                        plstagecode = @i_plstage AND
                                        taqversionkey = @i_plversion AND
                                        taqprojectformatkey = @i_formatkey)

    IF @v_count > 0 --costs exist for this project/version/format and printingnumber - loop through all taqversionformatyearkeys on costs
      DECLARE costs_cur CURSOR FOR 
        SELECT taqversionformatyearkey
        FROM taqversioncosts
        WHERE printingnumber = @v_printingnumber
          AND acctgcode = @i_chargecode
          AND taqversionformatyearkey IN (SELECT taqversionformatyearkey 
                                          FROM taqversionformatyear
                                          WHERE taqprojectkey = @i_projectkey AND
                                            plstagecode = @i_plstage AND
                                            taqversionkey = @i_plversion AND
                                            taqprojectformatkey = @i_formatkey)
    ELSE --costs don't exist yet - default taqversionformatyearkeys based on taqversionformatyear records
      DECLARE costs_cur CURSOR FOR 
        SELECT taqversionformatyearkey
        FROM taqversionformatyear
        WHERE taqprojectkey = @i_projectkey AND
          plstagecode = @i_plstage AND
          taqversionkey = @i_plversion AND
          taqprojectformatkey = @i_formatkey AND
          printingnumber = @v_printingnumber

    OPEN costs_cur
  
    FETCH costs_cur INTO @v_formatyearkey

    WHILE @@fetch_status = 0
    BEGIN

      SELECT @v_count = COUNT(*)
      FROM taqversioncosts 
      WHERE taqversionformatyearkey = @v_formatyearkey AND acctgcode = @i_chargecode

      IF @v_count > 0
        UPDATE taqversioncosts
        SET plcalccostcode = @i_newcalctype, versioncostsnote = @i_newnote, 
          plcalccostsubcode = @i_plcalccostsubcode, taqversionspeccategorykey = @i_taqversionspeccategorykey
        WHERE taqversionformatyearkey = @v_formatyearkey AND acctgcode = @i_chargecode
      ELSE
      BEGIN
        SET @v_set_acctgcode_to_zero = 0

        SELECT @v_externalcode = LTRIM(RTRIM(LOWER(externalcode))), @v_pocostind = ISNULL(pocostind, 0)
        FROM cdlist
        WHERE internalcode = @i_chargecode

        IF (EXISTS (SELECT * FROM INFORMATION_SCHEMA.TABLES WHERE TABLE_SCHEMA = 'dbo' AND  TABLE_NAME = 'wkbudgetimportcodes'))
        BEGIN
          SELECT @v_count_in_taqprojectmisc = count(*) 
          FROM taqprojectmisc 
          WHERE misckey = (SELECT b.misckey FROM bookmiscitems AS b WHERE LTRIM(RTRIM(LOWER(b.externalid))) LIKE 'budgetimport' AND b.activeind = 1) 
            AND taqprojectkey = @i_projectkey AND longvalue = 1

          IF @v_count_in_taqprojectmisc > 0
          BEGIN
            SELECT TOP(1) @v_prepchargeexternalcode = LTRIM(RTRIM(LOWER(prepchargeexternalcode))), 
              @v_mrchargeexternalcode = LTRIM(RTRIM(LOWER(mrchargeexternalcode))),
              @v_ppbrunchargeexternalcode = LTRIM(RTRIM(LOWER(ppbrunchargeexternalcode))) 
            FROM wkbudgetimportcodes

            IF ((@v_prepchargeexternalcode = @v_externalcode) OR (@v_mrchargeexternalcode = @v_externalcode) OR (@v_ppbrunchargeexternalcode = @v_externalcode))
            BEGIN
              INSERT INTO taqversioncosts
                (taqversionformatyearkey, acctgcode, plcalccostcode, versioncostsnote, printingnumber, 
                lastuserid, lastmaintdate, acceptgenerationind, plcalccostsubcode, taqversionspeccategorykey, pocostind)
              VALUES
                (@v_formatyearkey, @i_chargecode, @i_newcalctype, @i_newnote, @v_printingnumber,
                @i_userid, getdate(), 0, @i_plcalccostsubcode, @i_taqversionspeccategorykey, @v_pocostind)     

              SET @v_set_acctgcode_to_zero = 1               
            END
          END
        END

        IF @v_set_acctgcode_to_zero = 0
        BEGIN
          INSERT INTO taqversioncosts
            (taqversionformatyearkey, acctgcode, plcalccostcode, versioncostsnote, printingnumber,
            lastuserid, lastmaintdate, acceptgenerationind, plcalccostsubcode, taqversionspeccategorykey, pocostind)
          VALUES
            (@v_formatyearkey, @i_chargecode, @i_newcalctype, @i_newnote, @v_printingnumber, 
            @i_userid, getdate(), 0, @i_plcalccostsubcode, @i_taqversionspeccategorykey, @v_pocostind)
        END
      END

      SELECT @v_error = @@ERROR
      IF @v_error <> 0 BEGIN
        CLOSE formatyear_cur 
        DEALLOCATE formatyear_cur    
        SET @o_error_code = -1
        IF @v_count > 0
          SET @o_error_desc = 'Could not update plcalccostcode and versioncostsnote on taqversioncosts table ' + 
          '(taqversionformatyearkey=' + CAST(@v_formatyearkey AS VARCHAR) + ', acctgcode=' + CAST(@i_chargecode AS VARCHAR) + ').'
        ELSE
          SET @o_error_desc = 'Could not insert new row into taqversioncosts table ' + 
          '(taqversionformatyearkey=' + CAST(@v_formatyearkey AS VARCHAR) + ', acctgcode=' + CAST(@i_chargecode AS VARCHAR) + ').'
      END
    
      FETCH costs_cur INTO @v_formatyearkey
    END

    CLOSE costs_cur
    DEALLOCATE costs_cur

    FETCH formatyear_cur INTO @v_printingnumber
  END

  CLOSE formatyear_cur 
  DEALLOCATE formatyear_cur

END  
GO

GRANT EXEC ON qpl_update_other_printings TO PUBLIC
GO
