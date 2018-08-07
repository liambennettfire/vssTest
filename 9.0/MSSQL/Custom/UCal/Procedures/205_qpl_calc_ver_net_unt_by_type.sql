if exists (select * from dbo.sysobjects where id = object_id(N'dbo.qpl_calc_ver_net_unt_by_type') and OBJECTPROPERTY(id, N'IsProcedure') = 1)
  drop procedure dbo.qpl_calc_ver_net_unt_by_type
GO

CREATE PROCEDURE dbo.qpl_calc_ver_net_unt_by_type (  
  @i_projectkey INT,
  @i_plstage    INT,
  @i_plversion	INT,
  @i_formattype  VARCHAR(50),    
  @o_result     FLOAT OUTPUT)
AS

/******************************************************************************************
**  Name: qpl_calc_ver_net_unt_by_type
**  Desc: Generic Routine that allows the client to get net units by "type".  This type is 
**        determined by the summary item code stored on the format subgentable.  If no type
**        exists on the format subgentable, use the default summary item type on the media    
**        gentable.  If neither exists, assume 'OTHER'
**        - Version/Net Units - By Format Type.
**
**  Auth: TT
**  Date: June 1 2012
*******************************************************************************************/
BEGIN

DECLARE
  @v_net_units  INT,
	@v_built_clause	varchar(2000),
	@v_formattype varchar(50),
	@SQLString_var NVARCHAR(4000),
	@v_whereclause NVARCHAR(4000),
	@SQLparams_var NVARCHAR(4000)

	SET @v_built_clause = ''

	-- Now get the where clause for media and format based on the @i_formattype parameter
	Select @v_built_clause = dbo.qpl_calc_get_unit_by_type_clause(@i_formattype)


	SET @v_whereclause = 'u.taqversionsaleskey = c.taqversionsaleskey AND
	  c.taqprojectkey = f.taqprojectkey AND
	  c.plstagecode = f.plstagecode AND
	  c.taqversionkey = f.taqversionkey AND
	  c.taqprojectformatkey = f.taqprojectformatkey AND
	  c.taqprojectkey = ' +  convert(varchar,@i_projectkey)  + ' AND c.plstagecode = ' + convert(varchar,@i_plstage) +  ' AND c.taqversionkey =   ' +  convert(varchar,@i_plversion)  
	  +  ' AND (' + @v_built_clause + ')'


	SET @SQLString_var = N'SELECT @netunits = SUM(netsalesunits) FROM taqversionsalesunit u, taqversionsaleschannel c, taqversionformat f' +
					   N' WHERE ' + @v_whereclause

	set @SQLparams_var = N'@netunits INT OUTPUT' 
	EXECUTE sp_executesql @SQLString_var, @SQLparams_var, @v_net_units OUTPUT

  SET @o_result = @v_net_units
 
END
GO
GRANT EXEC ON dbo.qpl_calc_ver_net_unt_by_type TO PUBLIC
GO
