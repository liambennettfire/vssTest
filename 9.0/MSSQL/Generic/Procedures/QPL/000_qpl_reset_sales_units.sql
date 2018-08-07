if exists (select * from dbo.sysobjects where id = object_id(N'dbo.qpl_reset_sales_units') and OBJECTPROPERTY(id, N'IsProcedure') = 1)
  drop procedure dbo.qpl_reset_sales_units
GO

CREATE PROCEDURE qpl_reset_sales_units (  
  @i_projectkey   INT,
  @i_plstage      INT,
  @i_plversion    INT,
  @i_curunitcalc  TINYINT,
  @i_newunitcalc  TINYINT,
  @i_userid       VARCHAR(30),
  @o_error_code   INT OUTPUT,
  @o_error_desc   VARCHAR(2000) OUTPUT)
AS

/******************************************************************************************
**  Name: qpl_reset_sales_units
**  Desc: This stored procedure resets detail sales units and/or percentages
**        for the given p&l version.
**
**  Auth: Kate
**  Date: January 22 2008
*******************************************************************************************/

DECLARE
  @v_error  INT
  
BEGIN

  SET @o_error_code = 0
  SET @o_error_desc = ''
  
  IF @i_projectkey IS NULL OR @i_projectkey <= 0 BEGIN
    SET @o_error_desc = 'Invalid projectkey.'
    GOTO RETURN_ERROR
  END
  
  IF @i_plversion IS NULL OR @i_plversion <= 0 BEGIN
    SET @o_error_desc = 'Invalid taqversionkey.'
    GOTO RETURN_ERROR
  END  

  IF @i_plstage IS NULL BEGIN
    SET @o_error_desc = 'Invalid plstagecode.'
    GOTO RETURN_ERROR
  END  
  
  IF @i_curunitcalc = 0 --currently entering units, switching to one of the "Generate" options - discard current sales units
  BEGIN  
    IF @i_plstage > 0 --P&L version - also update templatechanged indicators
      UPDATE taqversionsalesunit
      SET grosssalesunits = 0, netsalesunits = 0, grosschangedind = 1, netchangedind = 1, lastmaintdate = getdate(), lastuserid = @i_userid
      WHERE grosssalesunits > 0 AND taqversionsaleskey IN 
        (SELECT taqversionsaleskey
        FROM taqversionsaleschannel 
        WHERE taqversionsalesunit.taqversionsaleskey = taqversionsaleschannel.taqversionsaleskey AND 
          taqprojectkey = @i_projectkey AND
          plstagecode = @i_plstage AND
          taqversionkey = @i_plversion)
    ELSE  --P&L template
      UPDATE taqversionsalesunit
      SET grosssalesunits = 0, netsalesunits = 0, lastmaintdate = getdate(), lastuserid = @i_userid
      WHERE grosssalesunits > 0 AND taqversionsaleskey IN 
        (SELECT taqversionsaleskey
        FROM taqversionsaleschannel 
        WHERE taqversionsalesunit.taqversionsaleskey = taqversionsaleschannel.taqversionsaleskey AND 
          taqprojectkey = @i_projectkey AND
          plstagecode = @i_plstage AND
          taqversionkey = @i_plversion)      
    END 
  
  ELSE  --currently generating (either from Total Units or from Target Market Data)
  BEGIN
  
    IF @i_curunitcalc = 1 --switching from "Generate from Total Units" - also discard Total Units
    BEGIN
      IF @i_plstage > 0 --P&L version
        UPDATE taqversion
        SET totalsalesunits = NULL, totalchangedind = 1, lastmaintdate = getdate(), lastuserid = @i_userid
        WHERE taqprojectkey = @i_projectkey AND
            plstagecode = @i_plstage AND
            taqversionkey = @i_plversion
      ELSE  --P&L template
        UPDATE taqversion
        SET totalsalesunits = NULL, lastmaintdate = getdate(), lastuserid = @i_userid
        WHERE taqprojectkey = @i_projectkey AND
            plstagecode = @i_plstage AND
            taqversionkey = @i_plversion
            
      SELECT @v_error = @@ERROR
      IF @v_error <> 0 BEGIN
        SET @o_error_desc = 'Update on taqversion table failed - could not reset Total Units (Error ' + cast(@v_error AS VARCHAR) + ').'
        GOTO RETURN_ERROR
      END
    END
    ELSE IF @i_curunitcalc = 2 --switching from "Generate from Target Market Data" - also discard Format Percentages
    BEGIN      
      IF @i_plstage > 0 --P&L version
        UPDATE taqversionformat
        SET formatpercentage = NULL, formatpercentchangedind = 1, lastmaintdate = getdate(), lastuserid = @i_userid
        WHERE taqprojectkey = @i_projectkey AND
            plstagecode = @i_plstage AND
            taqversionkey = @i_plversion
      ELSE  --P&L template
        UPDATE taqversionformat
        SET formatpercentage = NULL, lastmaintdate = getdate(), lastuserid = @i_userid
        WHERE taqprojectkey = @i_projectkey AND
            plstagecode = @i_plstage AND
            taqversionkey = @i_plversion 
            
      SELECT @v_error = @@ERROR
      IF @v_error <> 0 BEGIN
        SET @o_error_desc = 'Update on taqversionformat table failed - could not reset Format Percentages (Error ' + cast(@v_error AS VARCHAR) + ').'
        GOTO RETURN_ERROR
      END                  
    END  

    IF @i_newunitcalc = 0  --switching to "Enter" - discard current percentages
    BEGIN
      IF @i_plstage > 0 --P&L version
        UPDATE taqversionsalesunit
        SET salespercent = NULL, percentchangedind = 1, lastmaintdate = getdate(), lastuserid = @i_userid
        WHERE salespercent IS NOT NULL AND taqversionsaleskey IN 
          (SELECT taqversionsaleskey
           FROM taqversionsaleschannel 
           WHERE taqversionsalesunit.taqversionsaleskey = taqversionsaleschannel.taqversionsaleskey AND 
              taqprojectkey = @i_projectkey AND
              plstagecode = @i_plstage AND
              taqversionkey = @i_plversion)
      ELSE  --P&L template
        UPDATE taqversionsalesunit
        SET salespercent = NULL, lastmaintdate = getdate(), lastuserid = @i_userid
        WHERE salespercent IS NOT NULL AND taqversionsaleskey IN 
          (SELECT taqversionsaleskey
           FROM taqversionsaleschannel 
           WHERE taqversionsalesunit.taqversionsaleskey = taqversionsaleschannel.taqversionsaleskey AND 
              taqprojectkey = @i_projectkey AND
              plstagecode = @i_plstage AND
              taqversionkey = @i_plversion)
    END    
    ELSE  --switching from one "Generate" option to another - discard both units and percentages
    BEGIN   
      
      IF @i_plstage > 0 --P&L version
        UPDATE taqversionsalesunit
        SET grosssalesunits = 0, netsalesunits = 0, salespercent = NULL, grosschangedind = 1, netchangedind = 1, percentchangedind = 1, lastmaintdate = getdate(), lastuserid = @i_userid
        WHERE salespercent IS NOT NULL AND taqversionsaleskey IN 
          (SELECT taqversionsaleskey
           FROM taqversionsaleschannel 
           WHERE taqversionsalesunit.taqversionsaleskey = taqversionsaleschannel.taqversionsaleskey AND 
              taqprojectkey = @i_projectkey AND
              plstagecode = @i_plstage AND
              taqversionkey = @i_plversion)
      ELSE  --P&L template
        UPDATE taqversionsalesunit
        SET grosssalesunits = 0, netsalesunits = 0, salespercent = NULL, lastmaintdate = getdate(), lastuserid = @i_userid
        WHERE salespercent IS NOT NULL AND taqversionsaleskey IN 
          (SELECT taqversionsaleskey
           FROM taqversionsaleschannel 
           WHERE taqversionsalesunit.taqversionsaleskey = taqversionsaleschannel.taqversionsaleskey AND 
              taqprojectkey = @i_projectkey AND
              plstagecode = @i_plstage AND
              taqversionkey = @i_plversion)
    END
  END
  
  SELECT @v_error = @@ERROR
  IF @v_error <> 0 BEGIN
    SET @o_error_desc = 'Update on taqversionsalesunit table failed (Error ' + cast(@v_error AS VARCHAR) + ').'
    GOTO RETURN_ERROR
  END
  
  RETURN  

  RETURN_ERROR:  
    SET @o_error_code = -1
    RETURN
      
END
GO

GRANT EXEC ON qpl_reset_sales_units TO PUBLIC
GO
