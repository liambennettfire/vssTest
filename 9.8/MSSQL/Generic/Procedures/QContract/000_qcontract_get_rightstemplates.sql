if exists (select * from dbo.sysobjects where id = object_id(N'dbo.qcontract_get_rightstemplates') and OBJECTPROPERTY(id, N'IsProcedure') = 1)
drop procedure dbo.qcontract_get_rightstemplates
GO

SET QUOTED_IDENTIFIER ON 
GO
SET ANSI_NULLS ON 
GO

CREATE PROCEDURE qcontract_get_rightstemplates
 (@i_orgentryfilterstring varchar(max),
  @o_error_code           integer output,
  @o_error_desc           varchar(2000) output)
AS

/******************************************************************************
**  Name: qcontract_get_rightstemplates
**  Desc: This procedure returns data for the contracts rights format rows
**
**	Auth: Dustin Miller
**	Date: June 7 2012
**
**  Modified By: Colman
**  Date: December 28, 2015
**	Desc: Add orgentry filtering for Case 28988
*******************************************************************************
**  Change History
*******************************************************************************
**  Date:        Author:     Description:
*   --------     --------    -------------------------------------------
**  03/10/2016   UK          Case 36937
**  03/28/2016   AK          Case 28988
*******************************************************************************/

  DECLARE @v_searchitemcode	    INT,
          @v_usageclasscode	    INT,
          @v_error              INT,
          @v_rowcount           INT,
          @v_sql                NVARCHAR(MAX),
          @v_sql_select         NVARCHAR(MAX),
          @v_sql_from           NVARCHAR(MAX),
          @v_sql_where          NVARCHAR(MAX),
          --@v_orgsecurityfilter  VARCHAR(1000),
          @v_filterkey          INT,
          @v_filterorglevel     INT

  SET @o_error_code = 0
  SET @o_error_desc = ''
  SET @v_searchitemcode = null
  SET @v_usageclasscode = null
	
  SELECT @v_searchitemcode=datacode, @v_usageclasscode = datasubcode  
  FROM subgentables
  WHERE tableid=550 AND 
        qsicode=50
	      
    IF @v_searchitemcode IS NOT NULL AND @v_usageclasscode IS NOT NULL
    BEGIN
      SET @v_sql_select = 'SELECT distinct p.taqprojectkey, p.taqprojecttitle, 1 orgentriesind '
      SET @v_sql_from = ' FROM taqproject p'
      SET @v_sql_where = ' WHERE searchitemcode='+cast(@v_searchitemcode as varchar)+' AND 
                                usageclasscode='+cast(@v_usageclasscode as varchar)

      -- If orglevel security filter is populated,
      -- add corresponding orgentry table join to the select
      IF ltrim(rtrim(@i_orgentryfilterstring)) <> '' BEGIN
        SET @v_sql_from = @v_sql_from + ' , taqprojectorgentry o'
        SET @v_sql_where = @v_sql_where + ' AND p.taqprojectkey=o.taqprojectkey AND o.orgentrykey IN ' + @i_orgentryfilterstring + ''
      END

      SET @v_sql =  @v_sql_select + @v_sql_from + @v_sql_where
      
      IF ltrim(rtrim(@i_orgentryfilterstring)) <> '' BEGIN
        -- Include templates without orgentry settings
        SET @v_sql = @v_sql + ' UNION '
        SET @v_sql = @v_sql + 'SELECT p.taqprojectkey, p.taqprojecttitle, 0 orgentriesind FROM taqproject p
                               WHERE searchitemcode=' + cast(@v_searchitemcode as varchar) + ' AND usageclasscode=' + cast(@v_usageclasscode as varchar) + 
                               ' AND NOT EXISTS (SELECT * FROM taqprojectorgentry o WHERE p.taqprojectkey = o.taqprojectkey)'
      END
      
      SET @v_sql = @v_sql + ' ORDER BY p.taqprojecttitle'
      
      EXECUTE sp_executesql @v_sql
    END
    ELSE BEGIN
     SET @o_error_code = -1
     SET @o_error_desc = 'Error obtaining search item code/usage class code for rights templates.'
     RETURN 
    END

------------
ExitHandler:
------------
  SELECT @v_error = @@ERROR, @v_rowcount = @@ROWCOUNT
  IF @v_error <> 0 BEGIN
    SET @o_error_code = -1
    SET @o_error_desc = 'Error returning rights templates.'
    RETURN  
  END   
GO

GRANT EXEC ON qcontract_get_rightstemplates TO PUBLIC
GO