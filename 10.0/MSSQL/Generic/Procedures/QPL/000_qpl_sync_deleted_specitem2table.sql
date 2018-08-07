IF  EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[qpl_sync_deleted_specitem2table]') AND type in (N'P', N'PC'))
DROP PROCEDURE [dbo].[qpl_sync_deleted_specitem2table]
GO


SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO

CREATE procedure dbo.qpl_sync_deleted_specitem2table(
@i_specitemcategory          INT,
@i_specitemkey				 INT,
@i_key1					     INT,   --bookkey
@i_key2				         INT,   --printingkey
@i_projectkey			     INT,
@i_usageclass				 INT,
@i_itemtype					 INT,
@i_versionkey			     INT,
@i_userid                    VARCHAR(30),
@o_error_code                integer output,
@o_error_desc                varchar(2000) output)

AS
BEGIN
	/** BL  46313**/

	SET NOCOUNT ON
	--print '1'
	DECLARE 
		@v_selectedversionkey	INT,
		@v_specitemcategory		INT,
		@v_specitemcode			INT,
		@v_tablename			NVARCHAR(50),
		@v_column				NVARCHAR(255),
		@v_datatype				VARCHAR(255),
		@v_specitemtype			VARCHAR(255),
		@v_itemtype				INT,
		@v_usageclass			INT,
		@v_tablenamekeycode1	NVARCHAR(255),
		@v_tablenamekeycode2	NVARCHAR(255),
		@v_tablenamekeycode3	NVARCHAR(255),
		@v_update				NVARCHAR(1000),
	    @v_select				NVARCHAR(1000),
	    @v_count_syncspecs      INT,
	    @v_params				NVARCHAR(1000),
	    @v_key1                 VARCHAR(255),
	    @v_key2                 VARCHAR(255),
	    @v_key3	                VARCHAR(255),
	    @i_key3                 INT,
	    @v_updatevalue          NVARCHAR(1000),
	    @v_count				NVARCHAR(1000),
	    @i_count				INT,
	    @v_count2				INT,
	    @v_itemcategorycode	    INT,
	    @v_itemcode				INT,
	    @v_count_booklock       INT   
	        
	    
	    select @v_updatevalue = null	
			
		--set userid if empty
		SELECT @i_userid = coalesce(@i_userid,'QSISYNC')
		SELECT @i_userid = '''' + @i_userid + '''' 
		
		 SET @v_updatevalue  = 'NULL'
		 
		 SET @o_error_code = 0
		 SET @o_error_desc = ''
	
	
	    SELECT @v_selectedversionkey = dbo.qpl_get_selected_version(@i_projectkey)
	    
	    IF coalesce(@i_versionkey,@v_selectedversionkey) = @v_selectedversionkey BEGIN
	    
	        SELECT @v_count2 = COUNT(*) FROM taqversionspecitems_view WHERE taqversionspecitemkey = @i_specitemkey AND taqprojectkey = @i_projectkey
	        
	        IF @v_count2 = 1 BEGIN
	        
	            SELECT @v_itemcategorycode = itemcategorycode, @v_itemcode = itemcode FROM taqversionspecitems_view WHERE taqversionspecitemkey = @i_specitemkey AND taqprojectkey = @i_projectkey
	    
				SELECT @v_count_syncspecs = COUNT(*) FROM qsiconfigspecsync WHERE specitemcode= @v_itemcode AND specitemcategory = @v_itemcategorycode 
				 AND usageclass = @i_usageclass AND itemtype = @i_itemtype AND syncfromspecsind=1 and activeind=1
				 
				IF coalesce(@v_count_syncspecs,0)>0  BEGIN
				   SELECT @v_tablename = tablename, @v_column = columnname, @v_tablenamekeycode1 = keycolumn1,@v_tablenamekeycode2 = keycolumn2,
						  @v_tablenamekeycode3 = keycolumn3
					FROM qsiconfigspecsync WHERE specitemcode= @v_itemcode AND specitemcategory = @v_itemcategorycode
					 AND usageclass = @i_usageclass AND itemtype = @i_itemtype AND syncfromspecsind=1 and activeind=1
				     
				   --cast keys to varchar for dynmaic sql
					SELECT @v_key1 = CAST(@i_key1 AS VARCHAR(50))
					SELECT @v_key2 = CAST(@i_key2 AS VARCHAR(50))
					
					
					IF @v_tablenamekeycode3 IS NOT NULL BEGIN 
						PRINT '@v_tablenamekeycode3=' + convert(varchar, @v_tablenamekeycode3)
		
						SET @v_select = N'SELECT TOP 1 @v_keyvalue=' + @v_tablenamekeycode3 + ' FROM ' + @v_tablename + ' WHERE ' + @v_tablenamekeycode1 + '=@i_key1 AND ' + @v_tablenamekeycode2 + '=@i_key2'
						SET @v_params = N'@i_key1 INT, @i_key2 INT, @v_keyvalue INT OUTPUT'
						
						PRINT @v_select

						EXEC sp_executesql @v_select, @v_params, @i_key1, @i_key2, @v_keyvalue = @i_key3 OUTPUT
						
						SELECT @v_key3 = CAST(@i_key3 AS VARCHAR(50))
						
						SELECT @v_count = 'select @i_count=count(*) from ' + @v_tablename + 
						  ' where ' + @v_tablenamekeycode1 + '=' + @v_key1 + ' and '+ @v_tablenamekeycode2 + '=' + @v_key2 + ' and ' + @v_tablenamekeycode3 + '=' + @v_key3
						  
						exec sp_executesql @v_count, @params = N'@i_count INT OUTPUT',@i_count = @i_count OUTPUT 
											
						IF coalesce(@i_count,0) = 1 BEGIN
							select @v_update = 'update ' + @v_tablename + ' set ' + @v_column + '=' + @v_updatevalue + ', lastuserid=' + @i_userid + ', lastmaintdate=getdate()' +
							' where ' + @v_tablenamekeycode1 + '= ' + @v_key1 + ' and ' + @v_tablenamekeycode2 + '=' + @v_key2 + ' and ' + @v_tablenamekeycode3 + '=' + @v_key3
						
						END
					END --IF @v_tablenamekeycode3 IS NOT NULL
					ELSE IF coalesce(@v_tablenamekeycode2,'') <> ''	BEGIN --if two keys
						select @v_count = 'select @i_count = count(*) from '+@v_tablename+' where '+@v_tablenamekeycode1+' = '+@v_key1+' and '+ @v_tablenamekeycode2+' = '+@v_key2
						print @v_count
						
						exec sp_executesql @v_count, @params = N'@i_count INT OUTPUT',@i_count = @i_count OUTPUT 
																	
						IF coalesce(@i_count,0) = 1 BEGIN
						   select @v_update = 'update ' + @v_tablename + ' set ' + @v_column + ' = ' + @v_updatevalue +', lastuserid ='+@i_userid+', lastmaintdate=getdate()'+' where ' + 
							   @v_tablenamekeycode1 + '= ' + @v_key1 + ' and ' + @v_tablenamekeycode2 + ' = ' + @v_key2
						
						END
					END	
					ELSE IF coalesce(@v_tablenamekeycode1,'') <> ''	--if only one key
					BEGIN
						select @v_count = 'select @i_count = count(*) from '+@v_tablename+' where '+@v_tablenamekeycode1+' = '+@v_key1
						
						exec sp_executesql @v_count,@params = N'@i_count INT OUTPUT',@i_count = @i_count OUTPUT 
						
						IF coalesce(@i_count,0) = 1 BEGIN
							select @v_update = 'update ' + @v_tablename + ' set ' + @v_column + ' = ' + @v_updatevalue +', lastuserid ='+@i_userid+', lastmaintdate=getdate()'+' where ' + 
								@v_tablenamekeycode1 + '= ' + @v_key1
						
						END
					END	
					
					print @v_update
					IF coalesce(@v_update,'')<>'' BEGIN	
					    --lock the table so the trigger doesn't fire while updating - the trigger will check the booklock table to see if the book is locked
						--select @v_count_booklock = 0
						--select @v_count_booklock = COUNT(*) from booklock where bookkey = @i_key1 and printingkey = @i_key2
						--if @v_count_booklock = 0 begin
							insert into booklock (bookkey,printingkey,userid,locktimestamp,locktypecode,lastuserid,lastmaintdate,systemind)
							select @v_key1,@v_key2,'FBTSYNC',GETDATE(),1,@i_userid,GETDATE(),'TMMW'
						--end
													
						EXEC (@v_update) 
						
						delete from booklock where bookkey=@i_key1 and printingkey=@i_key2 and userid='FBTSYNC'
					
					END	--IF coalesce(@v_update,'')<>''
				END --IF coalesce(@@v_count_syncspecs,0)>0
			END --IF @v_count2 = 1 BEGIN
		END --IF coalesce(@i_taqversionkey,@i_selectedversionkey) = @i_selectedversionkey
			
	SET NOCOUNT OFF	
END
GO

GRANT EXEC on dbo.qpl_sync_deleted_specitem2table to public
go
