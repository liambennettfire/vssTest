/******************************************************************************
**  Name: imp_cr8_gentables
**  Desc: IKE gentables insert
**  Auth: Bennett     
**  Date: 5/9/2016
*******************************************************************************
**  Change History
*******************************************************************************
**  Date:        Author:     Description:
*   --------     --------    -------------------------------------------
**  5/9/2016     Bennett     original
*******************************************************************************/

SET QUOTED_IDENTIFIER ON 
GO
SET ANSI_NULLS ON 
GO

if exists (select * from dbo.sysobjects where id = object_id(N'[dbo].[imp_cr8_gentables]') and OBJECTPROPERTY(id, N'IsProcedure') = 1)
drop procedure [dbo].[imp_cr8_gentables]
GO

CREATE PROCEDURE dbo.imp_cr8_gentables
    @i_batchkey int,
    @i_elementkey int,
    @i_option int,
    @i_userid varchar(50)

AS
--
--options
-- 1 = report
-- 2 = generate inserts
--

DECLARE
  @v_element_value varchar(400),
  @v_exsists_rpt varchar(max),
  @v_add_rpt varchar(max),
  @v_add_sql varchar(max),
  @v_add_sql_all varchar(max),
  @v_datacode int,
  @v_datadesc varchar(40),
  @v_datadescshort varchar(20),
  @v_tablemnemonic varchar(20),
  @v_newline varchar(20),
  @v_count int,
  @v_length int,
  @v_start int,
  @v_end int,
  @v_tableid int

BEGIN
  set @v_newline=char(13)+char(10)
  set @v_exsists_rpt='Exsists...'+@v_newline
  set @v_add_rpt='Add...'+@v_newline

  select @v_tableid=tableid
    from imp_element_defs
    where elementkey=@i_elementkey
  if @v_tableid is null
    begin
      print 'Element has no tableid assign'
      return
    end
  else
    begin
      select @v_tablemnemonic=tablemnemonic
        from gentablesdesc
        where tableid=@v_tableid
      --select @v_datacode=max(datacode)
      --  from gentables
      --  where tableid=@v_tableid
      --set @v_datacode=coalesce(@v_datacode,0)
      --set @v_add_sql='set @v_datacode='+CAST(@v_datacode as varchar)+@v_newline
      set @v_add_sql='declare @v_datacode int'+@v_newline
      set @v_add_sql=@v_add_sql+'select @v_datacode=max(datacode) from gentables where tableid='+CAST(@v_tableid as varchar)+@v_newline
    end

  declare c_element_value cursor fast_forward for 
    select distinct originalvalue
      from imp_batch_detail
      where batchkey=@i_batchkey
        and elementkey=@i_elementkey
  open c_element_value
  fetch c_element_value into @v_element_value
  while @@fetch_status=0
    begin
      select @v_count=count(*) 
        from gentables
        where tableid=@v_tableid
          and datadesc=substring(@v_element_value,1,40)
      if @v_count=0
        begin
          set @v_add_rpt=@v_add_rpt+@v_element_value
          if DATALENGTH(@v_element_value)>40
            begin
              set @v_add_rpt=@v_add_rpt+'        truncate ('+cast(40-DATALENGTH(@v_element_value) as varchar)+') to:  '+substring(@v_element_value,1,40)
            end
          set @v_add_rpt=@v_add_rpt+@v_newline
          if @i_option=2
            begin
              set @v_datacode=@v_datacode+1
              set @v_add_sql=@v_add_sql+ 'set @v_datacode=@v_datacode+1'+@v_newline

              set @v_add_sql=@v_add_sql+ 'insert into gentables'+@v_newline
              set @v_add_sql=@v_add_sql+ ' (tableid,datacode,datadesc,datadescshort,tablemnemonic,lastuserid,lastmaintdate)'+@v_newline
              set @v_add_sql=@v_add_sql+ ' values'+@v_newline
              set @v_add_sql=@v_add_sql+ ' ('
              set @v_add_sql=@v_add_sql+ cast(@v_tableid as varchar)+','
              set @v_add_sql=@v_add_sql+ '@v_datacode,'
              set @v_add_sql=@v_add_sql+ char(39)+substring(@v_element_value,1,40)+char(39)+','
              set @v_add_sql=@v_add_sql+ char(39)+substring(@v_element_value,1,20)+char(39)+','
              set @v_add_sql=@v_add_sql+ char(39)+@v_tablemnemonic+char(39)+','
              set @v_add_sql=@v_add_sql+ char(39)+@i_userid+char(39)+','
              set @v_add_sql=@v_add_sql+ 'getdate()'
              set @v_add_sql=@v_add_sql+ ')'+@v_newline
            end
        end
      else
        begin
          set @v_exsists_rpt=@v_exsists_rpt+@v_element_value+@v_newline
        end
      fetch c_element_value into @v_element_value
    end
  close c_element_value
  deallocate c_element_value
  
  if @i_option=1
    begin
      print @v_exsists_rpt
      print @v_add_rpt
    end
  if @i_option=2
    begin
      set @v_length=DATALENGTH(@v_add_sql)
      set @v_start=1
      set @v_end=1
      while @v_start<=@v_length
        begin
          set @v_end=charindex(@v_newline,@v_add_sql,@v_start)
          print replace(replace(substring(@v_add_sql,@v_start,@v_end-@v_start+1),char(10),''),char(13),'')
          set @v_start=@v_end+2
        end
      
    end
END

GO
SET QUOTED_IDENTIFIER OFF 
GO
SET ANSI_NULLS ON 
GO

GRANT EXECUTE ON dbo.imp_cr8_gentables TO PUBLIC 
GO
