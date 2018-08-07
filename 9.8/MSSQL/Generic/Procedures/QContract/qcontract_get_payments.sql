if exists (select * from dbo.sysobjects where id = object_id(N'dbo.qcontract_get_payments') and OBJECTPROPERTY(id, N'IsProcedure') = 1)
  drop procedure dbo.qcontract_get_payments
GO

CREATE PROCEDURE qcontract_get_payments (  
  @i_projectkey   integer,
  @i_tabcode      integer,
  @i_tabsubcode   integer,
  @o_error_code   integer output,
  @o_error_desc   varchar(2000) output)
AS

/**************************************************************************************************
**  Name: qcontract_get_payments
**  Desc: This stored procedure returns Payments information from taqprojectpayments table
**        for the given tab.
**
**  Auth: Kate
**  Date: 11 May 2012
*******************************************************************************
**  Change History
*******************************************************************************
**  Date:        Author:     Description:
**  --------     --------    -------------------------------------------
**  10/20/2016   Colman      41071 Add work filter dropdown to the payments section on contracts
**  03/13/2017   Colman      41071 Returning wrong fromworkkey
****************************************************************************************************/

BEGIN

  DECLARE
    @v_bookkey	INT,
    @v_error  INT,    
    @v_fromorigdate DATETIME,
    @v_fromreviseddate DATETIME,
    @v_fromtitle VARCHAR(400),
    @v_fromworkkey INT,
    @v_offsetdays INT,
    @v_offsetmonths INT,
    @v_taqprojectkey	INT,
    @v_taqtaskkey	INT,
    @v_workrolecode INT
    
  SET @o_error_code = 0
  SET @o_error_desc = ''

  SELECT @v_workrolecode = datacode FROM gentables WHERE tableid=604 AND qsicode=1
  
  IF @i_tabcode = 0
    SELECT p.*
    FROM taqprojectpayments p, gentables g
    WHERE p.taqprojectkey = @i_projectkey AND
      p.paymenttype = g.datacode AND
      g.tableid = 635
  ELSE
  BEGIN
    SELECT p.*, COALESCE(g.gen1ind,0) linkwithtaskind, COALESCE(g2.numericdesc1,0) offsetmonths, COALESCE(g2.numericdesc2,0) offsetdays,
    CAST('' AS VARCHAR(400)) as fromtitle, CONVERT(DATETIME, NULL, 101) fromorigdate, CONVERT(DATETIME, NULL, 101) fromreviseddate, 0 fromworkkey,
    CASE
      WHEN payeecontactkey > 0 THEN (SELECT g.displayname FROM globalcontact g WHERE g.globalcontactkey = p.payeecontactkey)
      ELSE ''
    END payeename
    INTO #temp_payments_table
    FROM taqprojectpayments p
      JOIN gentables g ON g.tableid = 635 AND p.paymenttype = g.datacode 
      LEFT OUTER JOIN gentables g2 ON g2.tableid = 466 AND p.dateoffsetcode = g2.datacode
    WHERE p.taqprojectkey = @i_projectkey AND      
      p.paymenttype IN (SELECT code1 FROM gentablesrelationshipdetail
			         WHERE gentablesrelationshipkey = 25 
			         AND code2 = @i_tabcode 
			         AND subcode2 = @i_tabsubcode)			         
    
    DECLARE payment_cursor CURSOR FOR
      SELECT taqprojectkey, taqtaskkey, offsetmonths, offsetdays
      FROM #temp_payments_table

    OPEN payment_cursor

    FETCH payment_cursor
    INTO @v_taqprojectkey, @v_taqtaskkey, @v_offsetmonths, @v_offsetdays

    WHILE (@@FETCH_STATUS = 0)
    BEGIN
      SET @v_bookkey = NULL
      SET @v_fromtitle = ''
      SET @v_fromworkkey = 0
    	
      SELECT @v_bookkey = bookkey, @v_fromorigdate = activedate
      FROM taqprojecttask
      WHERE taqtaskkey = @v_taqtaskkey
          	
      IF @v_bookkey IS NOT NULL AND @v_bookkey > 0
      BEGIN
        SELECT @v_fromtitle = c.title + '/' + c.formatname, @v_fromworkkey = ISNULL(p.taqprojectkey, 0)
        FROM coretitleinfo c
          LEFT OUTER JOIN taqprojecttitle p ON p.bookkey = c.bookkey AND p.projectrolecode = @v_workrolecode
        WHERE c.bookkey = @v_bookkey
	        AND c.printingkey = 1
      END
      ELSE BEGIN
        SELECT @v_fromtitle = t.taqprojecttitle
        FROM taqproject t
        WHERE t.taqprojectkey = @v_taqprojectkey
      END
    	
      -- Calculate Revised Date based on Date Offset
      SET @v_fromreviseddate = DATEADD(mm, @v_offsetmonths, @v_fromorigdate)	   
      SET @v_fromreviseddate = DATEADD(dd, @v_offsetdays, @v_fromreviseddate)    	
    	
      IF @v_fromtitle IS NOT NULL AND @v_fromtitle <> ''
      BEGIN
        UPDATE #temp_payments_table
        SET fromtitle = @v_fromtitle, fromorigdate = @v_fromorigdate, fromreviseddate = @v_fromreviseddate, fromworkkey = @v_fromworkkey
        WHERE taqprojectkey = @v_taqprojectkey
	        AND taqtaskkey = @v_taqtaskkey
      END
    		
      FETCH payment_cursor
      INTO @v_taqprojectkey, @v_taqtaskkey, @v_offsetmonths, @v_offsetdays
    END

    CLOSE payment_cursor
    DEALLOCATE payment_cursor 

    SELECT * FROM #temp_payments_table
    ORDER BY sortorder ASC
  END
     
  SELECT @v_error = @@ERROR
  IF @v_error <> 0 BEGIN
    SET @o_error_code = -1
    SET @o_error_desc = 'Could not access taqprojectpayments table (taqprojectkey=' + CAST(@i_projectkey AS VARCHAR) + ').'
  END 

END
GO

GRANT EXEC ON qcontract_get_payments TO PUBLIC
GO
