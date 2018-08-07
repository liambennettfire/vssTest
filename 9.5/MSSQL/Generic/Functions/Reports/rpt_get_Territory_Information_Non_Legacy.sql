IF  EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[rpt_get_Territory_Information_Non_Legacy]') AND type in (N'FN', N'IF', N'TF', N'FS', N'FT'))
DROP FUNCTION [dbo].[rpt_get_Territory_Information_Non_Legacy]
GO


CREATE FUNCTION dbo.rpt_get_Territory_Information_Non_Legacy(@_i_bookkey int,@i_Territory_Type int)  

/*
@i_Territory_Type
pass a 1 in to get Exclusive territories
pass a 2 in to get non-exclusive territories
pass in a 3 to get not for sale
*/
Returns varchar(8000)  
as   
BEGIN  
	DECLARE @i_titlefetchstatus1 int  
	Declare @v_Name varchar(8000)  
	Declare @v_All_Names varchar(8000)  
	Declare @return varchar(8000)  
	Declare @i_Count int  
	Declare @i_iteration_Count int  
	
	Select @v_All_Names=''  
	Select @i_iteration_Count=1  


		If @i_Territory_Type=1
		BEGIN
			Select @i_Count=COUNT(*)
			FROM qtitle_get_territorycountry_by_title(@_i_bookkey) t, gentables g
			WHERE forsaleind = 1
			AND currentexclusiveind = 1
			AND t.countrycode = g.datacode
			AND g.tableid=114
			AND g.deletestatus='N'
			AND g.eloquencefieldtag IS NOT NULL
			AND g.exporteloquenceind = 1

			DECLARE c_Territories CURSOR LOCAL  
			FOR  
         
			SELECT g.datadesc 
			FROM qtitle_get_territorycountry_by_title(@_i_bookkey) t, gentables g
			WHERE forsaleind = 1
			AND currentexclusiveind = 1
			AND t.countrycode = g.datacode
			AND g.tableid=114
			AND g.deletestatus='N'
			AND g.eloquencefieldtag IS NOT NULL
			AND g.exporteloquenceind = 1
			order by g.datadesc
 
			FOR READ ONLY  
		END
  
		If @i_Territory_Type=2
		BEGIN
			Select @i_Count=COUNT(*)
			FROM qtitle_get_territorycountry_by_title(@_i_bookkey) t, gentables g
			WHERE forsaleind = 1
			AND (currentexclusiveind IS NULL OR currentexclusiveind = 0)
			AND t.countrycode = g.datacode
			AND g.tableid=114
			AND g.deletestatus='N'
			AND g.eloquencefieldtag IS NOT NULL
			AND g.exporteloquenceind = 1
         
			-- Non-exclusive Rights
			DECLARE c_Territories CURSOR LOCAL  
			FOR  

			SELECT g.datadesc 
			FROM qtitle_get_territorycountry_by_title(@_i_bookkey) t, gentables g
			WHERE forsaleind = 1
			AND (currentexclusiveind IS NULL OR currentexclusiveind = 0)
			AND t.countrycode = g.datacode
			AND g.tableid=114
			AND g.deletestatus='N'
			AND g.eloquencefieldtag IS NOT NULL
			AND g.exporteloquenceind = 1
			order by g.datadesc
         
			FOR READ ONLY 
		END
		If @i_Territory_Type=3
		-- Not For Sale
		BEGIN
			Select @i_Count= COUNT(*) FROM qtitle_get_territorycountry_by_title(@_i_bookkey) t, gentables g
			WHERE forsaleind = 0
			AND t.countrycode = g.datacode
			AND g.tableid=114
			AND g.deletestatus='N'
			AND g.eloquencefieldtag IS NOT NULL
			AND g.exporteloquenceind = 1
         
			DECLARE c_Territories CURSOR LOCAL  
			FOR  
			SELECT g.Datadesc 
			FROM qtitle_get_territorycountry_by_title(@_i_bookkey) t, gentables g
			WHERE forsaleind = 0
			AND t.countrycode = g.datacode
			AND g.tableid=114
			AND g.deletestatus='N'
			AND g.eloquencefieldtag IS NOT NULL
			AND g.exporteloquenceind = 1
			order by g.datadesc
    
			FOR READ ONLY       
		END         
		BEGIN
  
			OPEN c_Territories  
   
            FETCH NEXT FROM c_Territories    
			INTO @v_Name  
				select  @i_titlefetchstatus1  = @@FETCH_STATUS  
   
				while (@i_titlefetchstatus1 >-1 )  
					begin  
                    IF (@i_titlefetchstatus1 <>-2)   
						begin  
						If @i_iteration_Count <> @i_Count  
							BEGIN  
								Select  @v_All_Names=@v_All_Names + @v_Name + ','  
							END  
						else  
								Select  @v_All_Names=@v_All_Names + @v_Name + ''   
								Select @i_iteration_Count=@i_iteration_Count + 1  
						END  
              
              
             
            FETCH NEXT FROM c_Territories  
           INTO @v_Name  
                select  @i_titlefetchstatus1  = @@FETCH_STATUS  
					END  
                          
			close c_Territories  
			deallocate c_Territories  
     
Select @return=@v_All_Names  
Return @return  
END
END
Go
Grant all on rpt_get_Territory_Information_Non_Legacy to public

