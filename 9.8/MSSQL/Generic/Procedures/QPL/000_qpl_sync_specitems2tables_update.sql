/****** Object:  StoredProcedure [dbo].[qpl_sync_specitems2tables_update]    Script Date: 05/18/2015 15:55:43 ******/
IF  EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[qpl_sync_specitems2tables_update]') AND type in (N'P', N'PC'))
DROP PROCEDURE [dbo].[qpl_sync_specitems2tables_update]
GO


/****** Object:  StoredProcedure [dbo].[qpl_sync_specitems2tables_update]    Script Date: 05/18/2015 15:55:43 ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO


CREATE procedure [dbo].[qpl_sync_specitems2tables_update]   (
@v_table varchar (255), --target table
@v_tablekeycode1 varchar(255),  --target key column 1
@v_tablekeycode2 varchar(255),  --target key column 2
@v_tablekeycode3 varchar(255),  --target key column 3
@i_key1 int, -- key value 1
@i_key2 int, -- key value 2
@i_key3 int, -- key value 3
@v_column varchar(255), -- target column
@i_value int, --numeric
@i_decimalvalue decimal (15,4),
@i_detailvalue int,
@i_detail2value int,
@v_value nvarchar (2000), --text
@v_value2 nvarchar (2000),
@i_uomvalue int,
@v_type varchar(2), --what kind of value
@i_qtydecimalind int,
@v_userid varchar(50)) --is it a decimal

/********************************************************************************************************
**    Change History
**********************************************************************************************************
**    Date:       Author:      Case #:   Description:
**    --------    --------     -------   --------------------------------------
**   02/25/2016   Kusum        36463     Bookweight is not populated on the Printing table for new titles
**   03/28/2016   Kusum        31327     Barcode is written out to title history every time a spec item is updated
**   06/30/2016   Uday         38816     Propagation Not Working
**   11/01/2017   Colman       47014     SS-Clearing page counts does not write back to printing table
**********************************************************************************************************/

AS
BEGIN
  SET NOCOUNT ON

  -- EXEC qutl_trace 'qpl_sync_specitems2tables_update',
    -- '@v_table', NULL, @v_table,
    -- '@v_column', NULL, @v_column,
    -- '@i_value', @i_value, NULL,
    -- '@i_decimalvalue', @i_decimalvalue, NULL,
    -- '@i_detailvalue', @i_detailvalue, NULL,
    -- '@i_detail2value', @i_detail2value, NULL,
    -- '@v_type', NULL, @v_type,
    -- '@i_qtydecimalind', @i_qtydecimalind
  
  DECLARE 
  @v_insert nvarchar(1000),
  @v_update nvarchar (1000),
  @v_count nvarchar(1000),
  @i_count int,
  @v_key1 varchar(255),
  @v_key2 varchar(255),
  @v_key3  varchar(255),
  @v_updatevalue varchar(1000),
  @i_targetlength int,
  @i_decimalvalueconverted numeric(10,4),
  @v_historyvalue varchar(255),
  @v_insupd varchar(255),
  @o_error_code int,
  @o_error_desc varchar(2000),
  @v_barcodeid1 INT,
  @v_barcodeid2 INT,
  @quote CHAR(1),
  @WorkFieldInd INT
  
  SET @WorkFieldInd = 0
  --int update value
  select @v_updatevalue = null
  
  
  --cast keys to varchar for dynmaic sql
  select @v_key1 = CAST(@i_key1 as varchar(50))
  select @v_key2 = CAST(@i_key2 as varchar(50))
  select @v_key3 = CAST(@i_key3 as varchar(50))
  
  --set userid if empty
  select @v_userid = coalesce(@v_userid,'QSISYNC')
  select @v_userid = '''' + @v_userid + '''' 
  
  --deal with decimal value
  select @i_decimalvalueconverted = cast(@i_decimalvalue as numeric(10,4))
  
  --init @v_insupd 
  select @v_insupd = 'update'
  
  --check to see if row exists, if not, insert it  
  IF coalesce(@v_tablekeycode3,'') <> ''  --if three keys
  BEGIN
    select @v_count = 'select @i_count=count(*) from ' + @v_table + 
      ' where ' + @v_tablekeycode1 + '=' + @v_key1 + ' and '+ @v_tablekeycode2 + '=' + @v_key2 + ' and ' + @v_tablekeycode3 + '=' + @v_key3
    exec sp_executesql @statement = @v_count, @params = N'@i_count INT OUTPUT',@i_count = @i_count OUTPUT 
                    
    IF coalesce(@i_count,0) = 0
    BEGIN
      select @v_insert = 'insert into ' + @v_table + ' (' + @v_tablekeycode1 + ',' + @v_tablekeycode2 + ',' + @v_tablekeycode3 + 
        ',lastuserid,lastmaintdate) select ' + @v_key1 + ',' + @v_key2 + ',' + @v_key3 + ',' + @v_userid + ',' + 'GETDATE()'
      exec (@v_insert)
      select @v_insupd = 'insert'
    END
  END  
  ELSE IF coalesce(@v_tablekeycode2,'') <> ''  --if two keys
  BEGIN
    select @v_count = 'select @i_count = count(*) from '+@v_table+' where '+@v_tablekeycode1+' = '+@v_key1+' and '+ @v_tablekeycode2+' = '+@v_key2
    exec sp_executesql @statement = @v_count, @params = N'@i_count INT OUTPUT',@i_count = @i_count OUTPUT 
                    
    IF coalesce(@i_count,0) = 0
    BEGIN
      select @v_insert = 'insert into '+ @v_table + ' ('+ @v_tablekeycode1+', '+@v_tablekeycode2+', lastuserid, lastmaintdate) select '+@v_key1+','+@v_key2+','+ @v_userid +','+'GETDATE()'
      exec (@v_insert)
      select @v_insupd = 'insert'
    END
  END  
  ELSE IF coalesce(@v_tablekeycode1,'') <> ''  --if only one key
  BEGIN
    select @v_count = 'select @i_count = count(*) from '+@v_table+' where '+@v_tablekeycode1+' = '+@v_key1
    exec sp_executesql @statement = @v_count,@params = N'@i_count INT OUTPUT',@i_count = @i_count OUTPUT 
    
    IF coalesce(@i_count,0) = 0
    BEGIN
         select @v_insert = 'insert into '+ @v_table + ' ('+ @v_tablekeycode1+', lastuserid, lastmaintdate) select '+@v_key1+','+ @v_userid +','+'GETDATE()'
      exec (@v_insert)
      select @v_insupd = 'insert'
    END
  END          
  
  --now that row is confirmed or inserted, prepare the values for update - convert numerics to varchar
  IF coalesce(@i_qtydecimalind,0)=1
    BEGIN
      select @v_updatevalue = cast(@i_decimalvalueconverted as varchar(50))
      select @v_historyvalue = @v_updatevalue
    END
      
  IF coalesce(@v_type,'') in ('Q','C','CK') AND coalesce(@i_qtydecimalind,0) = 0
    BEGIN
      select @v_updatevalue = case when ISNULL(@i_value,-1) = -1 THEN 'NULL' ELSE cast (@i_value as varchar(50)) END --qty and detailcode
      select @v_historyvalue = @v_updatevalue
    END
  
  IF coalesce(@v_type,'') in ('DT')
    BEGIN
      select @v_updatevalue = case when ISNULL(@i_detailvalue,-1) = -1 THEN 'NULL' ELSE cast (@i_detailvalue as varchar(50)) END --detailcode
      select @v_historyvalue = @v_updatevalue
      IF @v_updatevalue != 'NULL'
      BEGIN
        --select @v_historyvalue = will need to translate these to gentable\subgentable values eventually, for not nothing on the printing requires it for HNA
        IF @v_column = 'barcodeid1' BEGIN
           select @v_historyvalue = dbo.get_gentables_desc(552,convert(int,@v_updatevalue),'long') 
        END
        IF @v_column = 'barcodeid2' BEGIN
           select @v_historyvalue = dbo.get_gentables_desc(552,convert(int,@v_updatevalue),'long') 
        END
      END
    END  
  
  IF coalesce(@v_type,'') = 'T2'
    BEGIN
      select @v_updatevalue = case when ISNULL(@i_detail2value,-1) = -1 THEN 'NULL' ELSE cast (@i_detail2value as varchar(50)) END --detailcode
      select @v_historyvalue = @v_updatevalue
      IF @v_updatevalue != 'NULL'
      BEGIN
        --select @v_historyvalue = will need to translate these to gentable\subgentable values eventually, for not nothing on the printing requires it for HNA
        IF @v_column = 'barcodeposition1' BEGIN
         select @v_barcodeid1 = barcodeid1 FROM printing WHERE bookkey = @v_key1 AND printingkey = @v_key2
         select @v_historyvalue = dbo.get_subgentables_desc(552,@v_barcodeid1,convert(int,@v_updatevalue),'long') 
        END
        IF @v_column = 'barcodeposition2' BEGIN
         select @v_barcodeid2 = barcodeid2 FROM printing WHERE bookkey = @v_key1 AND printingkey = @v_key2
         select @v_historyvalue = dbo.get_subgentables_desc(552,@v_barcodeid2,convert(int,@v_updatevalue),'long') 
        END 
      END
    END    
    
  IF coalesce(@v_type,'') = 'U'
    BEGIN
      select @v_updatevalue = case when ISNULL(@i_uomvalue,-1) = -1 THEN 'NULL' ELSE cast (@i_uomvalue as varchar(50)) END --detailcode
      IF @v_updatevalue != 'NULL'
        select @v_historyvalue = datadesc from gentables where tableid=613 and datacode = @i_uomvalue
      ELSE
        select @v_historyvalue = @v_updatevalue
    END  
    
        
  IF coalesce(@v_value,'') <> ''  --desc and desc2
    BEGIN
      --determine the target column length
      select @i_targetlength = character_maximum_length from INFORMATION_SCHEMA.COLUMNS where TABLE_NAME = @v_table and COLUMN_NAME = @v_column
      
      --trim the value to fit  the target
      select @v_updatevalue = SUBSTRING(@v_value,1,@i_targetlength)
      IF CHARINDEX('''', @v_updatevalue, 1) > 0 BEGIN
        SET @v_updatevalue = REPLACE(@v_updatevalue, @quote, @quote + @quote)
      END
      select @v_historyvalue = @v_updatevalue
      
      --now wrap it in double quotes for the update
      select @v_updatevalue = '''' + @v_updatevalue + '''' 
    END
    
  IF coalesce(@v_value2,'') <> ''  --desc and desc2
    BEGIN
      --determine the target column length
      select @i_targetlength = character_maximum_length from INFORMATION_SCHEMA.COLUMNS where TABLE_NAME = @v_table and COLUMN_NAME = @v_column
      
      --trim the value to fit  the target
      select @v_updatevalue = SUBSTRING(@v_value2,1,@i_targetlength)
      select @v_historyvalue = @v_updatevalue
      
      --now wrap it in double quotes for the update
      select @v_updatevalue = '''' + @v_updatevalue + '''' 
    END  
  
  -- all values have been converted to varchar or formatted correctly, perform the update      
  IF coalesce(@v_updatevalue,'') = '' BEGIN
   SET @v_updatevalue  = 'NULL'
  END  
      
  IF coalesce(@v_updatevalue,'') <> ''
    BEGIN
    --HAS THREE KEYS
    IF coalesce(@v_tablekeycode3,'') <> ''
      BEGIN
        select @v_update = 'update ' + @v_table + ' set ' + @v_column + '=' + @v_updatevalue + ', lastuserid=' + @v_userid + ', lastmaintdate=getdate()' +
          ' where ' + @v_tablekeycode1 + '= ' + @v_key1 + ' and ' + @v_tablekeycode2 + '=' + @v_key2 + ' and ' + @v_tablekeycode3 + '=' + @v_key3
      END    
    --HAS TWO KEYS
    ELSE IF coalesce(@v_tablekeycode2,'') <> ''
      BEGIN
        select @v_update = 'update ' + @v_table + ' set ' + @v_column + ' = ' + @v_updatevalue +', lastuserid ='+@v_userid+', lastmaintdate=getdate()'+' where ' + @v_tablekeycode1 + '= ' + @v_key1 + ' and ' + @v_tablekeycode2 + ' = ' + @v_key2
      END
    --HAS ONE KEY
    ELSE IF coalesce(@v_tablekeycode1,'') <>  ''
      BEGIN
        select @v_update = 'update ' + @v_table + ' set ' + @v_column + ' = ' + @v_updatevalue +', lastuserid ='+@v_userid+', lastmaintdate=getdate()'+' where ' + @v_tablekeycode1 + '= ' + @v_key1
      END
    --print @v_update
    --confirm a value and execute the update dynamic sql then update title history 
    IF coalesce(@v_update,'')<>''
      BEGIN                  
        EXEC (@v_update) 
               
        EXEC dbo.qtitle_update_titlehistory @v_table,@v_column, @i_key1, @i_key2, 0, @v_historyvalue,
        @v_insupd, @v_userid, NULL, NULL, @o_error_code OUTPUT, @o_error_desc OUTPUT 
              
        SET @WorkFieldInd = 0
                  
          SELECT @WorkFieldInd = workfieldind
          FROM titlehistorycolumns
           WHERE tablename = @v_table
           AND columnname = @v_column
           AND activeind = 1
           
        IF @WorkFieldInd = 1 BEGIN
         -- propagate values to subordinate titles
         EXEC qtitle_copy_work_info @i_key1, @v_table, @v_column, @o_error_code OUT, @o_error_desc OUT          
          END --@WorkFieldInd = 1                               
      END  
    END
    
  SET NOCOUNT OFF  
END


GO

GRANT EXEC on [dbo].[qpl_sync_specitems2tables_update] to public
go


