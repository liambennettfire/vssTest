if exists (select * from dbo.sysobjects where id = object_id(N'dbo.qpl_get_plstage_version_info') and OBJECTPROPERTY(id, N'IsProcedure') = 1)
  drop procedure dbo.qpl_get_plstage_version_info
GO

CREATE PROCEDURE qpl_get_plstage_version_info (  
  @i_projectkey integer,
  @i_plstage    integer,
  @o_error_code integer output,
  @o_error_desc varchar(2000) output)
AS

/*************************************************************************************
**  Name: qpl_get_plstage_version_info
**  Desc: This stored procedure returns all versions for given projectkey and P&L Stage.
**
**  Auth: Kate
**  Date: September 10 2007
**************************************************************************************/

BEGIN

  DECLARE
    @v_error  INT,
    @v_versionformats VARCHAR(120),
	@v_versionformatsstring VARCHAR(MAX),
	@v_activeprice FLOAT,
	@v_versionkey INT
    
  SET @o_error_code = 0
  SET @o_error_desc = ''   

  SELECT 
    CASE v.taqversionkey
      WHEN (SELECT s.selectedversionkey FROM taqplstage s WHERE s.taqprojectkey = v.taqprojectkey AND s.plstagecode = v.plstagecode) THEN 1
      ELSE 0
    END isselected, CAST(NULL AS VARCHAR(MAX)) as versionformatsstring, v.*
  INTO #Temp 
  FROM taqversion v
  WHERE v.taqprojectkey = @i_projectkey AND v.plstagecode = @i_plstage
  ORDER BY v.taqversionkey

  SELECT @v_error = @@ERROR
  IF @v_error <> 0 BEGIN
    SET @o_error_code = -1
    SET @o_error_desc = 'Could not access taqversion table to get all Versions for Stage (taqprojectkey=' + CAST(@i_projectkey AS VARCHAR) + 
      ', plstagecode=' + CAST(@i_plstage AS VARCHAR) + ').'
    GOTO EXIT_PROC  
  END
    
  DECLARE version_cur CURSOR FOR
    SELECT taqversionkey FROM #Temp

  OPEN version_cur 

  FETCH version_cur INTO @v_versionkey
    SET @v_versionformatsstring = NULL
    WHILE (@@FETCH_STATUS=0)
	BEGIN  
	  DECLARE versionformats_cur CURSOR FOR
   	  SELECT s.datadesc formatdesc, f.activeprice
		FROM #Temp t INNER JOIN taqversionformat f ON t.taqprojectkey = f.taqprojectkey AND t.plstagecode = f.plstagecode AND t.taqversionkey = f.taqversionkey
		  LEFT OUTER JOIN gentables g ON g.tableid = 312 AND g.datacode = f.mediatypecode
		  LEFT OUTER JOIN subgentables s ON s.tableid = 312 AND s.datacode = f.mediatypecode AND s.datasubcode = f.mediatypesubcode
		WHERE f.taqprojectkey = @i_projectkey AND
		  f.plstagecode = @i_plstage AND 
		  f.taqversionkey = @v_versionkey

	   OPEN versionformats_cur 

	   FETCH versionformats_cur INTO @v_versionformats, @v_activeprice

	   SET @v_versionformatsstring = ' '
	   WHILE (@@FETCH_STATUS=0)
	   BEGIN  
		 IF @v_versionformatsstring <> ' '
		   SET @v_versionformatsstring = @v_versionformatsstring + ', '
	    
		 IF @v_activeprice IS NOT NULL BEGIN
			SET @v_versionformats = @v_versionformats + '(' + CAST(@v_activeprice AS VARCHAR) + ')'
		 END
	    
		 SET @v_versionformatsstring = @v_versionformatsstring + @v_versionformats

		FETCH versionformats_cur INTO @v_versionformats, @v_activeprice
	  END

	  CLOSE versionformats_cur 
	  DEALLOCATE versionformats_cur    
	  
	IF @v_versionformatsstring IS NOT NULL BEGIN
		UPDATE #Temp SET versionformatsstring = @v_versionformatsstring 
		WHERE taqprojectkey = @i_projectkey AND plstagecode = @i_plstage AND taqversionkey = @v_versionkey
	END  

    FETCH version_cur INTO @v_versionkey
  END

  CLOSE version_cur 
  DEALLOCATE version_cur    
  
  SELECT * FROM #Temp
  
  DROP TABLE #Temp

EXIT_PROC:
END
GO

GRANT EXEC ON qpl_get_plstage_version_info TO PUBLIC
GO
