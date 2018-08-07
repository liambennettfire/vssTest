
/****** Object:  StoredProcedure [dbo].[qpl_calc_Production_Expense_version_by_format_YUP]  ******/
IF  EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[qpl_calc_Production_Expense_version_by_format_YUP]') AND type in (N'P', N'PC'))
DROP PROCEDURE [dbo].[qpl_calc_Production_Expense_version_by_format_YUP]
GO

/****** Object:  StoredProcedure [dbo].[qpl_calc_Production_Expense_version_by_format_YUP]    ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER OFF
GO


CREATE PROCEDURE [dbo].[qpl_calc_Production_Expense_version_by_format_YUP] (  

@i_projectkey INT,  
@i_plstage    INT,  
@i_plversion INT,  
@i_formattype  VARCHAR(50),     
@i_placctgcategory      VARCHAR(50),  
@i_placctgsubcategory   VARCHAR(50),    
@i_incomeind  TINYINT,  
@o_result     FLOAT OUTPUT)  

AS  

/**********************************************************************************************  
**  Name: qpl_calc_version_by_format  
**  Desc: Generic Version calculation which sums up costs or income records for all chargecodes  
**        in the given P&L Accounting Category/Subcategory for the given Format.  
**  
**  Auth: Kate  
**  Date: April 1 2010  
***********************************************************************************************/  
/*
*******************************************************************************
**    Change History
*******************************************************************************
**    Date:       Author:              Description:
**    --------    --------    -------------------------------------------
**    01-25-2016  
	Jason Donovan
	Needed to create a function called qpl_Convert_Same_Currency, to convert the SUM
	of the versioncostsamount

*******************************************************************************/
BEGIN  
  --New JSD Find the entered currency for the taqprojectkey that is coming in

  Declare @i_Main_project_Currency float
  Select @i_Main_project_Currency=plenteredcurrency  from taqproject where taqprojectkey=@i_projectkey
  Declare @i_Count_Temp_table int

 --Get all related Projectects for Joint Production
  
Create TABLE #Temp_Related_Projects  (taqprojectkey nvarchar(4000))  

Insert into #Temp_Related_Projects   

Select '(' + CAST(Isnull(relatedprojectkey,0) as nvarchar(4000)) + ',' + CAST(@i_projectkey  as nvarchar(4000)) + ')' from rpt_project_relationship_view where indicator2=1 and taqprojectkey=@i_projectkey    

Select @i_Count_Temp_table=count(*) from  #Temp_Related_Projects


If @i_Count_Temp_table=0


BEGIN 

	Insert into #Temp_Related_Projects 

	Select '(' + CAST(@i_projectkey  as nvarchar(4000)) + ')'

END


DECLARE @v_total  FLOAT  

DECLARE   

 @v_built_clause varchar(2000),  

 --@v_formattype varchar(50),  

 @SQLString_var NVARCHAR(4000),  

 @v_whereclause NVARCHAR(4000),  

 @SQLparams_var NVARCHAR(4000)  

 SET @v_built_clause = ''  

 -- Now get the where clause for media and format based on the @i_formattype parameter  

 Select @v_built_clause = dbo.qpl_calc_get_unit_by_type_clause(@i_formattype)  

  SET @o_result = NULL  

  BEGIN  

      -- If 0 is passed in for the version Get the selected versionkey for this stage  

      If @i_plversion=0  

  SELECT @i_plversion = selectedversionkey  
  FROM taqplstage
  WHERE taqprojectkey = @i_projectkey AND plstagecode = @i_plstage  

  END  

  IF @i_incomeind = 1  

 BEGIN  

  IF @i_placctgsubcategory IS NULL  

   BEGIN  

    SET @v_whereclause = 'y.taqprojectkey = ' +  convert(varchar,@i_projectkey)  + ' AND y.plstagecode = ' + convert(varchar,@i_plstage) +  ' AND y.taqversionkey =   ' +  convert(varchar,@i_plversion)    

    +  ' AND (' + @v_built_clause + ')'  

    + ' AND cd.placctgcategorycode IN   

    (SELECT datacode FROM gentables   

     WHERE tableid = 571 AND UPPER(LTRIM(RTRIM(alternatedesc1))) = ' + ''''+ @i_placctgcategory + '''' + ')'  


    SET @SQLString_var = N'SELECT @total = SUM(i.incomeamount)  

    FROM taqversionincome i  

    JOIN cdlist cd  

    on i.acctgcode = cd.internalcode  

    JOIN taqversionformatyear y  

    ON i.taqversionformatyearkey = y.taqversionformatyearkey   

    JOIN taqversionformat f  

    ON y.taqprojectformatkey = f.taqprojectformatkey  WHERE ' + @v_whereclause  

    set @SQLparams_var = N'@total FLOAT OUTPUT'   

    EXECUTE sp_executesql @SQLString_var, @SQLparams_var, @v_total  OUTPUT  

   END  
  ELSE  
   BEGIN  

     SET @v_whereclause = 'y.taqprojectkey = ' +  convert(varchar,@i_projectkey)  + ' AND y.plstagecode = ' + convert(varchar,@i_plstage) +  ' AND y.taqversionkey =   ' +  convert(varchar,@i_plversion)    
     +  ' AND (' + @v_built_clause + ')'  
     + ' AND cd.placctgcategorycode IN   

     (SELECT datacode FROM gentables   

      WHERE tableid = 571 AND UPPER(LTRIM(RTRIM(alternatedesc1))) = ' + ''''+ @i_placctgcategory + '''' + ')'  

     + ' AND  

     cd.placctgcategorysubcode IN  

     (SELECT datasubcode FROM subgentables   

      WHERE tableid = 571 AND UPPER(LTRIM(RTRIM(alternatedesc1))) = ' + ''''+ @i_placctgsubcategory + '''' + ')'   

     SET @SQLString_var = N'SELECT @total = SUM(i.incomeamount)  

     FROM taqversionincome i  

     JOIN cdlist cd  

     on i.acctgcode = cd.internalcode  

     JOIN taqversionformatyear y  

     ON i.taqversionformatyearkey = y.taqversionformatyearkey   

     JOIN taqversionformat f  

     ON y.taqprojectformatkey = f.taqprojectformatkey  WHERE ' + @v_whereclause  

     --PRINT @SQLString_var  

     set @SQLparams_var = N'@total FLOAT OUTPUT'   
     EXECUTE sp_executesql @SQLString_var, @SQLparams_var, @v_total  OUTPUT  

   END  

    END  

   ELSE  

   --Get Current Project Sales Units  

   Declare @v_Current_Project_Sales_Units int  

   Select @v_Current_Project_Sales_Units=0  

   EXEC qpl_calc_ver_net_units_by_format_YUP @i_projectkey, @i_plstage, @i_plversion, @i_formattype, @v_Current_Project_Sales_Units OUTPUT  

   --Get Total Sales Units for all related projects  

   Declare @i_Projectkey2 int  

   Declare @v_Total2 float  

   Select @v_Total2=0  

   Declare @v_Total_Sales_Units float  

   Select @v_Total_Sales_Units=0  

   --Create Cursor to Grab total Sales Units across all related projects  

    DECLARE curTotal_Sales_Units SCROLL CURSOR FOR  
  Select relatedprojectkey from rpt_project_relationship_view where indicator2=1 and taqprojectkey=@i_projectkey    

  union    

  Select @i_projectkey  

 FOR READ ONLY  

 OPEN curTotal_Sales_Units  

 FETCH NEXT FROM curTotal_Sales_Units INTO @i_Projectkey2 WHILE @@FETCH_STATUS = 0  

    BEGIN  

   EXEC qpl_calc_ver_net_units_by_format_YUP @i_Projectkey2, @i_plstage, @i_plversion, @i_formattype, @v_Total2 OUTPUT  

   Select @v_Total_Sales_Units =@v_Total_Sales_Units + @v_Total2  

     FETCH NEXT FROM curTotal_Sales_Units INTO @i_Projectkey2  

  END  

 CLOSE curTotal_Sales_Units  

 DEALLOCATE curTotal_Sales_Units  


 --Current Project %  

 Declare @v_Current_Project_Percent float  

 Select @v_Current_Project_Percent=0  


 If @v_Total_Sales_Units <> 0  

 BEGIN  

 Select @v_Current_Project_Percent= @v_Current_Project_Sales_Units / @v_Total_Sales_Units  

 END  

   --Begin Joint Production Costs here as this is where the expenses are calculated and not the income  

  IF @i_placctgsubcategory IS NULL  

   BEGIN  

    -- Grab costs for all Production Costs across all related projects  

    SET @v_whereclause = 'y.taqprojectkey in ' +  convert(varchar,(Select taqprojectkey from #Temp_Related_Projects))  + ' AND y.plstagecode = ' + convert(varchar,@i_plstage) +  ' AND y.taqversionkey in   ' +  convert(varchar,@i_plversion)    

    +  ' AND (' + @v_built_clause + ')'  

    + ' AND cd.placctgcategorycode IN   

    (SELECT datacode FROM gentables   

     WHERE tableid = 571 AND UPPER(LTRIM(RTRIM(alternatedesc1))) = ' + ''''+ @i_placctgcategory + '''' + ')'  

  SET @SQLString_var = N'SELECT @total = SUM(i.versioncostsamount * dbo.qpl_Convert_Same_Currency(t.taqprojectkey,t.plenteredcurrency,' + Cast(@i_Main_project_Currency as varchar) +'))

    FROM taqversioncosts i  

    JOIN cdlist cd  

    on i.acctgcode = cd.internalcode  

    JOIN taqversionformatyear y  

    ON i.taqversionformatyearkey = y.taqversionformatyearkey   

    JOIN taqversionformat f  

    ON y.taqprojectformatkey = f.taqprojectformatkey  
		
	 inner join taqproject t
	 on t.taqprojectkey=y.taqprojectkey

	WHERE ' + @v_whereclause  

    set @SQLparams_var = N'@total FLOAT OUTPUT'   

    EXECUTE sp_executesql @SQLString_var, @SQLparams_var, @v_total  OUTPUT  

  
   END  
  ELSE  
   BEGIN  
    --Begin Joint Production Costs here as this is where the expenses are calculated and not the income  

     SET @v_whereclause = 'y.taqprojectkey in ' +  convert(varchar,(Select taqprojectkey from #Temp_Related_Projects))  + ' AND y.plstagecode = ' + convert(varchar,@i_plstage) +  ' AND y.taqversionkey =   ' +  convert(varchar,@i_plversion)    

     +  ' AND (' + @v_built_clause + ')'  

     + ' AND cd.placctgcategorycode IN   

     (SELECT datacode FROM gentables   

      WHERE tableid = 571 AND UPPER(LTRIM(RTRIM(alternatedesc1))) = ' + ''''+ @i_placctgcategory + '''' + ')'   
     + ' AND  
     cd.placctgcategorysubcode IN  

     (SELECT datasubcode FROM subgentables   

      WHERE tableid = 571 AND UPPER(LTRIM(RTRIM(alternatedesc1))) = ' + ''''+ @i_placctgsubcategory + '''' + ')'   

     SET @SQLString_var = N'SELECT @total = SUM(i.versioncostsamount * dbo.qpl_Convert_Same_Currency(t.taqprojectkey,t.plenteredcurrency,' + Cast(@i_Main_project_Currency as varchar) +'))
     FROM taqversioncosts i  
    JOIN cdlist cd  

     on i.acctgcode = cd.internalcode  

     JOIN taqversionformatyear y  

     ON i.taqversionformatyearkey = y.taqversionformatyearkey   

     JOIN taqversionformat f  

     ON y.taqprojectformatkey = f.taqprojectformatkey  
	 
	 inner join taqproject t
	 on t.taqprojectkey=y.taqprojectkey
	 
	 WHERE ' + @v_whereclause  

     --PRINT @SQLString_var  

     set @SQLparams_var = N'@total FLOAT OUTPUT'   

     EXECUTE sp_executesql @SQLString_var, @SQLparams_var, @v_total  OUTPUT  

   END  

If @i_incomeind=1  
BEGIN    

 SET @o_result = @v_total  

END  

ELSE  

BEGIN  
Set @o_result= @v_total * @v_Current_Project_Percent  
END  
     Return @o_result  

END  




