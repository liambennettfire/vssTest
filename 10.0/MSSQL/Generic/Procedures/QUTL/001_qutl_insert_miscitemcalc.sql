
/****** Object:  StoredProcedure [dbo].[qutl_insert_miscitemcalc]    Script Date: 01/09/2015 11:56:09 ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER OFF
GO

IF EXISTS(SELECT * FROM sys.objects WHERE type = 'p' and name = 'qutl_insert_miscitemcalc' ) 
     DROP PROCEDURE qutl_insert_miscitemcalc 
go

CREATE PROCEDURE [dbo].[qutl_insert_miscitemcalc]
 (@i_misckey			integer,
  @i_calcname			varchar (50),
  @i_calcsql			varchar (4000),
  @o_error_code         integer output,
  @o_error_desc			varchar(2000) output)
AS

/******************************************************************************************
**  Name: qutl_insert_miscitemcalc  
**  Desc: This stored procedure searches to see if a miscitemcalc exists based on misckey.  
**        If no existing value is found, it is inserted for every org level.
**        If it is found, it will be deleted and re-inserted    
**    Auth: SLB
**    Date: 11 Jan 2015
********************************************************************************************
**    Change History
********************************************************************************************
**    Date:    Author:        Description:
**    --------    --------        --------------------------------------------------------
**    
********************************************************************************************/

  DECLARE 
    @v_count  INT,
    @v_error  INT
     
  SET @o_error_code = 0
  SET @o_error_desc = ''
    
    
BEGIN
  --Remove all existing miscitemcalc rows for this misckey 
  DELETE FROM miscitemcalc WHERE misckey = @i_misckey

 
  SELECT @v_count = COUNT(*)
  FROM bookmiscitems WHERE misckey = @i_misckey
  
  IF @v_count > 0
  BEGIN
  --a bookmiscitems row exists for this misckey so the miscitemcalc rows can be created  
  
    INSERT INTO miscitemcalc
      (misckey, orglevelkey, orgentrykey, calcname, calcsql, lastuserid, lastmaintdate)
    SELECT
      @i_misckey, orglevelkey, orgentrykey, @i_calcname, @i_calcsql, 'QSIDBA', getdate()
    FROM orgentry
    WHERE orglevelkey = 1
  	  
  	SELECT @v_error = @@ERROR
	    IF @v_error <> 0 BEGIN
		  SET @o_error_code = -1
		  SET @o_error_desc = 'insert to miscitemcalc had an error: misckey=' + cast(@i_misckey AS VARCHAR)
		END 
	END
	ELSE
	BEGIN
		SET @o_error_code = -1
		SET @o_error_desc = 'No bookmiscitems value exists for misckey=' + cast(@i_misckey AS VARCHAR)
	END 
END

GO