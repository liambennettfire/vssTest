
IF EXISTS (SELECT * FROM sysobjects WHERE type = 'P' AND name = 'history_sp')
  BEGIN
   DROP  procedure history_sp
  END
GO
CREATE procedure [dbo].history_sp @i_tablename varchar(80),@i_TriggerActionID varchar(20) as

BEGIN

DECLARE 
  @v_TriggerID INT,
  @v_TableID INT,
  @v_SelectSql VARCHAR(8000),
  @v_sql nvarchar(2000),
  @v_colection_sql nvarchar(2000),
  @v_before_parmdef NVARCHAR(500),
  @v_after_parmdef NVARCHAR(500),
  @v_sql_parmdef NVARCHAR(500),
  @v_resolution_parmdef NVARCHAR(500),
  @o_beforevalue varchar(max),
  @o_aftervalue varchar(max),
  @o_displayvalue varchar(max),
  @v_keyvalue varchar(50),
  @v_keyname varchar(50),
  @v_returncode  int,
  @v_datacode  int,
  @v_datasubcode  int,
  @v_datetypecode  int,
  @v_datadesc_a varchar(80),
  @v_datadesc_b varchar(80)

DECLARE  -- history table values
--  @v_tablename  varchar(50),
  @v_columnname  varchar(50),
  @v_columnkey  int,
  @v_bookkey  int,
  @v_printingkey  int,
  @v_taqprojectkey  int,
  @v_elementkey  int,
  @v_misckey  int,
  @v_beforevalue  varchar(max),
  @v_aftervalue  varchar(max),
  @v_displayvalue  varchar(max),
  @v_lastmaintdate  datetime,
  @v_lastuserid varchar(50),
  @v_collectivecolumntag varchar(10),
  @v_collectivecolumntag_list varchar(10),
  @v_processind int,
  @v_resolutionsql nvarchar(4000),
  @v_itemtype int

  --dynamic sql parms
  set @v_before_parmdef = N'@o_beforevalue varchar(max) output' 
  set @v_after_parmdef = N'@o_aftervalue varchar(max) output' 
  set @v_sql_parmdef = N'@o_keyvalue varchar(50) output' 
  set @v_resolution_parmdef = N'@o_displayvalue varchar(max) output'

  -- get key filed values
  if @i_TriggerActionID='delete'
    --get values from a deleted row
    begin
      -- issues with deletes of Journals - temporarily disable history for all deletes
      return
    
      set @v_keyname=null
      select @v_keyname=sc.name
        from tempdb..sysobjects so, tempdb..syscolumns sc, tempdb..systypes st
        with (READUNCOMMITTED)
        where so.name like '#deleted'+'%'
            and so.id=sc.id
            and sc.xtype=st.xtype
            and st.name not like 'sys%'
            and sc.name='bookkey'
      if @v_keyname is not null
        begin  
            set @v_sql = N'select @o_keyvalue=bookkey from #deleted' 
            exec sp_executesql @v_sql, @v_sql_parmdef,
              @o_keyvalue = @v_keyvalue output
            set @v_bookkey=@v_keyvalue
        end
      else
        begin  
          set @v_bookkey=null
        end

      set @v_keyname=null
      select @v_keyname=sc.name
        from tempdb..sysobjects so, tempdb..syscolumns sc, tempdb..systypes st
        with (READUNCOMMITTED)
        where so.id=object_id('tempdb..#deleted')
            and so.id=sc.id
            and sc.xtype=st.xtype
            and st.name not like 'sys%'
            and sc.name='printingkey'
      if @v_keyname is not null
        begin  
            set @v_sql = N'select @o_keyvalue=printingkey from #deleted' 
            exec sp_executesql @v_sql, @v_sql_parmdef,
              @o_keyvalue = @v_keyvalue output
            set @v_printingkey=@v_keyvalue
        end
      else
        begin  
          set @v_printingkey=null
        end

      set @v_keyname=null
      select @v_keyname=sc.name
        from tempdb..sysobjects so, tempdb..syscolumns sc, tempdb..systypes st
        with (READUNCOMMITTED)
        where so.id=object_id('tempdb..#deleted')
            and so.id=sc.id
            and sc.xtype=st.xtype
            and st.name not like 'sys%'
            and sc.name='taqprojectkey'
      if @v_keyname is not null
        begin  
            set @v_sql = N'select @o_keyvalue=taqprojectkey from #deleted' 
            exec sp_executesql @v_sql, @v_sql_parmdef,
              @o_keyvalue = @v_keyvalue output
            set @v_taqprojectkey=@v_keyvalue
        end
      else
        begin  
          set @v_taqprojectkey=null
        end

      -- issues with deletes of Journals - temporarily disable history for Journal deletes
      if @v_taqprojectkey > 0 begin
        select @v_itemtype = searchitemcode
          from coreprojectinfo 
         where projectkey = @v_taqprojectkey
         
        if @v_itemtype = 6 begin
          return
        end
      end

      set @v_keyname=null
      select @v_keyname=sc.name
        from tempdb..sysobjects so, tempdb..syscolumns sc, tempdb..systypes st
        with (READUNCOMMITTED)
        where so.id=object_id('tempdb..#deleted')
            and so.id=sc.id
            and sc.xtype=st.xtype
            and st.name not like 'sys%'
            and sc.name='elementkey'
      if @v_keyname is not null
        begin  
            set @v_sql = N'select @o_keyvalue=elementkey from #deleted' 
            exec sp_executesql @v_sql, @v_sql_parmdef,
              @o_keyvalue = @v_keyvalue output
            set @v_elementkey=@v_keyvalue
        end
      else
        begin  
          set @v_elementkey=null
        end

      set @v_keyname=null
      select @v_keyname=sc.name
        from tempdb..sysobjects so, tempdb..syscolumns sc, tempdb..systypes st
        with (READUNCOMMITTED)
        where so.id=object_id('tempdb..#deleted')
            and so.id=sc.id
            and sc.xtype=st.xtype
            and st.name not like 'sys%'
            and sc.name='misckey'
      if @v_keyname is not null
        begin  
            set @v_sql = N'select @o_keyvalue=misckey from #deleted' 
            exec sp_executesql @v_sql, @v_sql_parmdef,
              @o_keyvalue = @v_keyvalue output
            set @v_misckey=@v_keyvalue
        end
      else
        begin  
          set @v_misckey=null
        end

      --get last info
      set @v_lastmaintdate=getdate() -- no usable date on delete, using system time
      begin try 
        select @v_lastuserid=lastuserid
          from #deleted
      end try
      begin catch
        set @v_lastuserid='n/a'
      end catch;
      if @v_lastuserid is null
        set @v_lastuserid='n/a'
    end
  else
    --get values from an inserted or updated row
    begin

      set @v_keyname=null
      select @v_keyname=sc.name
        from tempdb..sysobjects so, tempdb..syscolumns sc, tempdb..systypes st
        with (READUNCOMMITTED)
        where so.id=object_id('tempdb..#inserted')
            and so.id=sc.id
            and sc.xtype=st.xtype
            and st.name not like 'sys%'
            and sc.name='bookkey'
      if @v_keyname is not null
        begin  
            set @v_sql = N'select @o_keyvalue=bookkey from #inserted' 
            exec sp_executesql @v_sql, @v_sql_parmdef,
              @o_keyvalue = @v_keyvalue output
            set @v_bookkey=@v_keyvalue
        end
      else
        begin  
          set @v_bookkey=null
        end

      set @v_keyname=null
      select @v_keyname=sc.name
        from tempdb..sysobjects so, tempdb..syscolumns sc, tempdb..systypes st
        with (READUNCOMMITTED)
        where so.id=object_id('tempdb..#inserted')
            and so.id=sc.id
            and sc.xtype=st.xtype
            and st.name not like 'sys%'
            and sc.name='printingkey'
      if @v_keyname is not null
        begin  
            set @v_sql = N'select @o_keyvalue=printingkey from #inserted' 
            exec sp_executesql @v_sql, @v_sql_parmdef,
              @o_keyvalue = @v_keyvalue output
            set @v_printingkey=@v_keyvalue
        end
      else
        begin  
          set @v_printingkey=null
        end

      set @v_keyname=null
      select @v_keyname=sc.name
        from tempdb..sysobjects so, tempdb..syscolumns sc, tempdb..systypes st
        with (READUNCOMMITTED)
        where so.id=object_id('tempdb..#inserted')
            and so.id=sc.id
            and sc.xtype=st.xtype
            and st.name not like 'sys%'
            and sc.name='taqprojectkey'
      if @v_keyname is not null
        begin  
            set @v_sql = N'select @o_keyvalue=taqprojectkey from #inserted' 
            exec sp_executesql @v_sql, @v_sql_parmdef,
              @o_keyvalue = @v_keyvalue output
            set @v_taqprojectkey=@v_keyvalue
        end
      else
        begin  
          set @v_taqprojectkey=null
        end

      set @v_keyname=null
      select @v_keyname=sc.name
        from tempdb..sysobjects so, tempdb..syscolumns sc, tempdb..systypes st
        with (READUNCOMMITTED)
        where so.id=object_id('tempdb..#inserted')
            and so.id=sc.id
            and sc.xtype=st.xtype
            and st.name not like 'sys%'
            and sc.name='elementkey'
      if @v_keyname is not null
        begin  
            set @v_sql = N'select @o_keyvalue=elementkey from #inserted' 
            exec sp_executesql @v_sql, @v_sql_parmdef,
              @o_keyvalue = @v_keyvalue output
            set @v_elementkey=@v_keyvalue
        end
      else
        begin  
          set @v_elementkey=null
        end

      set @v_keyname=null
      select @v_keyname=sc.name
        from tempdb..sysobjects so, tempdb..syscolumns sc, tempdb..systypes st
        with (READUNCOMMITTED)
        where so.id=object_id('tempdb..#inserted')
            and so.id=sc.id
            and sc.xtype=st.xtype
            and st.name not like 'sys%'
            and sc.name='misckey'
      if @v_keyname is not null
        begin  
            set @v_sql = N'select @o_keyvalue=misckey from #inserted' 
            exec sp_executesql @v_sql, @v_sql_parmdef,
              @o_keyvalue = @v_keyvalue output
            set @v_misckey=@v_keyvalue
        end
      else
        begin  
          set @v_misckey=null
        end


      --get last info
      begin try 
        select @v_lastmaintdate=lastmaintdate
          from #inserted
      end try
      begin catch
        set @v_lastmaintdate=getdate()
      end catch;
      if @v_lastmaintdate is null
        set @v_lastmaintdate=getdate()

      begin try 
        select @v_lastuserid=lastuserid
          from #inserted
      end try
      begin catch
        set @v_lastuserid='n/a'
      end catch;
      if @v_lastuserid is null
        set @v_lastuserid='n/a'
    end

  -- initialize column collection list
  --   values are space delimited and padded
  set @v_collectivecolumntag_list=' '

  -- get history columns per tablename
  declare c_columns cursor fast_forward for
    select columnkey,columnname,tableid,datacode,datasubcode,datetypecode,collectivecolumntag,resolutionsql
      from historytablecolumndefs
      where  tablename = @i_tablename
  open c_columns
  fetch  c_columns into @v_columnkey,@v_columnname,@v_tableid,@v_datacode,@v_datasubcode,@v_datetypecode,@v_collectivecolumntag,@v_resolutionsql
  while @@fetch_status=0
    begin
      if @v_collectivecolumntag is not null
        begin
          set @v_processind=charindex(' '+@v_collectivecolumntag+' ',@v_collectivecolumntag_list)
        end
      else 
        begin
          set @v_processind=0
        end

      -- only prosses if a 1st column from the group  
      if @v_processind=0
        begin
          set @v_collectivecolumntag_list=@v_collectivecolumntag_list+@v_collectivecolumntag+' '
          
          -- get before value for the given table/column
          if @v_resolutionsql is null
            begin
              set @v_sql = N'select @o_beforevalue='+@v_columnname+' from #deleted' 
              exec sp_executesql @v_sql, @v_before_parmdef,
                @o_beforevalue = @v_beforevalue output
            end
          else
            begin
              set @v_sql = replace(@v_resolutionsql,'$replacetablename$','#deleted') 
              exec sp_executesql @v_sql, @v_resolution_parmdef,
                @o_displayvalue = @v_beforevalue output
            end

          -- get after value for the given table/column
          if @v_resolutionsql is null
            begin
              set @v_sql = N'select @o_aftervalue='+@v_columnname+' from #inserted' 
              exec sp_executesql @v_sql, @v_after_parmdef,
                @o_aftervalue = @v_aftervalue output
            end
          else
            begin
              set @v_sql = replace(@v_resolutionsql,'$replacetablename$','#inserted') 
              exec sp_executesql @v_sql, @v_resolution_parmdef,
                @o_displayvalue = @v_aftervalue output
            end

          -- resolve gentable values if nessasary
          if @v_tableid is not null
            begin
              set @v_datadesc_b = null
              set @v_datadesc_a = null

              if 
                @v_datacode is null and
                @v_datasubcode is null 
                begin
                  select @v_datadesc_b=datadesc
                    from gentables
                    where tableid=@v_tableid
                      and datacode=@v_beforevalue
                  select @v_datadesc_a=datadesc
                    from gentables
                    where tableid=@v_tableid
                      and datacode=@v_aftervalue
                end
              if 
                @v_datacode is not null and
                @v_datasubcode is null 
                begin
                  select @v_datadesc_b=datadesc
                    from subgentables
                    where tableid=@v_tableid
                      and datacode=@v_datacode
                      and datasubcode=@v_beforevalue
                  select @v_datadesc_a=datadesc
                    from subgentables
                    where tableid=@v_tableid
                      and datacode=@v_datacode
                      and datasubcode=@v_aftervalue
                end
              if 
                @v_datacode is not null and
                @v_datasubcode is not null
                begin
                  select @v_datadesc_b=datadesc
                    from subgentables
                    where tableid=@v_tableid
                      and datacode=@v_datacode
                      and datasubcode=@v_beforevalue
                  select @v_datadesc_a=datadesc
                    from subgentables
                    where tableid=@v_tableid
                      and datacode=@v_datacode
                      and datasubcode=@v_aftervalue
                end

              if @v_datadesc_a is not null
                set @v_aftervalue=@v_datadesc_a
              if @v_datadesc_b is not null
                set @v_beforevalue=@v_datadesc_b

            end
    
          if @v_beforevalue<>@v_aftervalue
            or (@v_beforevalue is null and @v_aftervalue is not null)
            or (@v_beforevalue is not null and @v_aftervalue is null)
            --or @i_TriggerActionID='delete'
            begin
              insert into historychanges
               (columnkey,bookkey,printingkey,taqprojectkey,elementkey,misckey,beforevalue,aftervalue,changetype,lastmaintdate,lastuserid)
               values
               (@v_columnkey,@v_bookkey,@v_printingkey,@v_taqprojectkey,@v_elementkey,@v_misckey,@v_beforevalue,@v_aftervalue,@i_TriggerActionID,@v_lastmaintdate,@v_lastuserid)
            end

         -- initialize values
         set @v_beforevalue=null
         set @v_aftervalue=null

        end

      fetch  c_columns into @v_columnkey,@v_columnname,@v_tableid,@v_datacode,@v_datasubcode,@v_datetypecode,@v_collectivecolumntag,@v_resolutionsql

    end
  close c_columns
  deallocate c_columns

END

