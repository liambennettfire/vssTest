
/****** Object:  StoredProcedure [dbo].[qpl_calc_ver_cv_Manuscript_by_format_YUP]    Script Date: 05/01/2014 14:07:24 ******/
IF  EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[qpl_calc_ver_cv_Manuscript_by_format_YUP]') AND type in (N'P', N'PC'))
DROP PROCEDURE [dbo].[qpl_calc_ver_cv_Manuscript_by_format_YUP]
GO


GO

/****** Object:  StoredProcedure [dbo].[qpl_calc_ver_cv_Manuscript_by_format_YUP]    Script Date: 05/01/2014 14:07:24 ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER OFF
GO



CREATE PROCEDURE [dbo].[qpl_calc_ver_cv_Manuscript_by_format_YUP] (  
  @i_projectkey INT,
  @i_plstage    INT,
  @i_plversion	INT,
  @i_formattype  VARCHAR(50), 
  @i_clientvalue VARCHAR(50),
  @o_result     FLOAT OUTPUT)
AS

/******************************************************************************************
**  Name:qpl_calc_ver_cv_Manuscript_by_format_YUP

**  Desc: Generic Version calculation which multiples a client value * pagecount by format

**
**  Auth: JAS
**  Date: 05/14/2014
*******************************************************************************************/
 
DECLARE
@v_total FLOAT,
  @v_clientvalue_amount  FLOAT,
  --@v_clientvalue_percent FLOAT,
  @v_Page_count FLOAT,
  @v_built_clause VARCHAR(4000),
  @v_sqlstring NVARCHAR(4000),
  @SQLparams_var NVARCHAR(4000)

BEGIN

	BEGIN
      -- If 0 is passed in for the version Get the selected versionkey for this stage
      If @i_plversion=0
		SELECT @i_plversion = selectedversionkey
		FROM taqplstage
		WHERE taqprojectkey = @i_projectkey AND plstagecode = @i_plstage
    END


    -- Now get the format clause for media and format based on the @i_formattype parameter  

	SET @v_built_clause = ''
	
	Select @v_built_clause = dbo.qpl_calc_get_unit_by_type_clause(@i_formattype)
 

SET @v_sqlstring = N'Select @total=tvs.quantity FROM taqversionformat f
	inner join taqversionspeccategory tvs
	on f.taqprojectkey=tvs.taqprojectkey
	and f.taqprojectformatkey=tvs.taqversionformatkey 
	inner join taqversionspecitems tvsi
	on tvs.taqversionspecategorykey=tvsi.taqversionspecategorykey and itemcode=2 ' +  
	' AND f.taqprojectkey  = ' + CONVERT(VARCHAR, @i_projectkey) +  
	' AND f.plstagecode = ' + CONVERT(VARCHAR, @i_plstage) +  
	' AND f.taqversionkey = ' + CONVERT(VARCHAR, @i_plversion) +   
	' AND (' + @v_built_clause + ') ' 

	set @SQLparams_var = N'@total FLOAT OUTPUT' 
	EXECUTE sp_executesql @v_sqlstring, @SQLparams_var, @v_total  OUTPUT
 
  SELECT @v_clientvalue_amount = v.clientvalue
    FROM gentables g 
      LEFT OUTER JOIN taqversionclientvalues v ON v.clientvaluecode = g.datacode AND 
        v.taqprojectkey = @i_projectkey AND
        v.plstagecode = @i_plstage AND
        v.taqversionkey = @i_plversion
    WHERE g.tableid = 614 AND g.datacode IN (SELECT datacode FROM gentables 
             WHERE tableid = 614 AND UPPER(LTRIM(RTRIM(alternatedesc1))) = @i_clientvalue)

    IF @v_clientvalue_amount IS NULL
      SET @v_clientvalue_amount = 0
 

      
    SET @v_clientvalue_amount = @v_clientvalue_amount * @v_total
    If @v_clientvalue_amount is null
    SeT @v_clientvalue_amount=0
    
    SET @o_result = @v_clientvalue_amount
  
END

GO

Grant all on qpl_calc_ver_cv_Manuscript_by_format_YUP to Public
