SET QUOTED_IDENTIFIER ON 
GO
SET ANSI_NULLS ON 
GO

/******************************************************************************
**  Name: imp_template_extract
**  Desc: IKE prints SQL to create a given Template
**  Auth: Bennett     
**  Date: 5/9/2016
**  Parameters:
**    @v_templatekey = templatekey that is to be displayed
*******************************************************************************
**  Change History
*******************************************************************************
**  Date:        Author:     Description:
*   --------     --------    -------------------------------------------
**  5/9/2016     Bennett     original
*******************************************************************************/

if exists (select * from dbo.sysobjects where id = object_id(N'[dbo].[imp_template_extract]') and OBJECTPROPERTY(id, N'IsProcedure') = 1)
drop procedure [dbo].[imp_template_extract]
GO

CREATE PROCEDURE dbo.imp_template_extract
  @v_templatekey int 

as

declare c_template cursor fast_forward for
  select templatekey,elementkey,columnname,transmnemonic,rowinsertind,seqinsertind,mapkey,defaultvalue,lastuserid,addlqualifier
    from imp_template_detail
    where templatekey=@v_templatekey
    order by elementkey

declare
  @v_elementkey  bigint,
  @v_columnname  varchar(max),
  @v_transmnemonic  varchar(max),
  @v_rowinsertind  int,
  @v_seqinsertind  int,
  @v_mapkey  int,
  @v_defaultvalue  varchar(max),
  @v_lastmaintdate  datetime,
  @v_addlqualifier  varchar(max),
  @v_line  varchar(max),
  @v_newline varchar(10),
  @v_lastuserid  varchar(max),
  @v_mapseq int,
  @v_from_value varchar(max),
  @v_to_value varchar(max),
  @v_templatedesc varchar(500),
  @v_processtype int,
  @v_default_orgkeyset varchar(500)

set @v_newline=char(13)+char(10)

PRINT 'set nocount on'
PRINT @v_newline

PRINT 'declare @v_templatekey int'
PRINT 'set @v_templatekey=1'
PRINT @v_newline
PRINT @v_newline

set @v_line='delete imp_template_master where templatekey=@v_templatekey'
PRINT @v_line
PRINT @v_newline

select @v_templatedesc=templatedesc,@v_processtype=processtype,@v_default_orgkeyset=default_orgkeyset,@v_lastuserid=lastuserid
  from imp_template_master 
  where templatekey=@v_templatekey
set @v_line='insert into imp_template_master '+@v_newline
set @v_line=@v_line+' (templatekey,templatedesc,processtype,default_orgkeyset,lastuserid,lastmaintdate) '+@v_newline
set @v_line=@v_line+'values'+@v_newline+' ('
--set @v_line=@v_line+coalesce(cast(@v_templatekey as varchar),'null')+','
set @v_line=@v_line+'@v_templatekey,'
set @v_line=@v_line+coalesce(''''+@v_templatedesc+'''','null')+','
set @v_line=@v_line+coalesce(cast(@v_processtype as varchar),'null')+','
set @v_line=@v_line+coalesce(''''+@v_default_orgkeyset+'''','null')+','
set @v_line=@v_line+coalesce(''''+@v_lastuserid+'''','null')+','
set @v_line=@v_line+''''+cast(getdate() as varchar)+''');'
PRINT @v_line
PRINT @v_newline
PRINT @v_newline

set @v_line='delete imp_template_detail where templatekey=@v_templatekey'
PRINT @v_line
PRINT @v_newline

open c_template
fetch c_template into 
  @v_templatekey,
  @v_elementkey,
  @v_columnname,
  @v_transmnemonic,
  @v_rowinsertind,
  @v_seqinsertind,
  @v_mapkey,
  @v_defaultvalue,
  @v_lastuserid,
  @v_addlqualifier  
  
while @@fetch_status=0
  begin
    set @v_line='insert into imp_template_detail '+@v_newline
    set @v_line=@v_line+' (templatekey,elementkey,columnname,transmnemonic,rowinsertind,seqinsertind,mapkey,defaultvalue,lastuserid,lastmaintdate,addlqualifier) '+@v_newline
    set @v_line=@v_line+'values'+@v_newline+' ('
    --set @v_line=@v_line+coalesce(cast(@v_templatekey as varchar),'null')+','
    set @v_line=@v_line+'@v_templatekey,'
    set @v_line=@v_line+coalesce(cast(@v_elementkey as varchar),'null')+','
    set @v_line=@v_line+coalesce(''''+@v_columnname+'''','null')+','
    set @v_line=@v_line+coalesce(''''+@v_transmnemonic+'''','null')+','
    set @v_line=@v_line+coalesce(''''+cast(@v_rowinsertind as varchar)+'''','null')+','
    set @v_line=@v_line+coalesce(''''+cast(@v_seqinsertind as varchar)+'''','null')+','
    set @v_line=@v_line+coalesce(cast(@v_mapkey as varchar),'null')+','
    set @v_line=@v_line+coalesce(''''+@v_defaultvalue+'''','null')+','
    set @v_line=@v_line+coalesce(''''+@v_lastuserid+'''','null')+','
    set @v_line=@v_line+''''+cast(getdate() as varchar)+''','
    set @v_line=@v_line+coalesce(''''+@v_addlqualifier+'''','null')+');'
    PRINT @v_line
    PRINT @v_newline
    
    if @v_mapkey is not null
      begin
        set @v_line='delete imp_mapping where mapkey='+cast(@v_mapkey as varchar)
        PRINT @v_line
        declare c_mapping cursor fast_forward for
          select mapseq,replace(from_value,'''',''''''),replace(to_value,'''','''''')
            from imp_mapping
            where mapkey=@v_mapkey
        open c_mapping
        fetch c_mapping into @v_mapseq,@v_from_value,@v_to_value
        while @@fetch_status=0
          begin
            if @v_from_value<>@v_to_value
              begin
                set @v_line='insert into imp_mapping '+@v_newline
                set @v_line=@v_line+' (mapkey,mapseq,from_value,to_value) '+@v_newline
                set @v_line=@v_line+'values'+@v_newline+' ('
                set @v_line=@v_line+coalesce(cast(@v_mapkey as varchar),'null')+','
                set @v_line=@v_line+coalesce(cast(@v_mapseq as varchar),'null')+','
                set @v_line=@v_line+coalesce(''''+@v_from_value+'''','null')+','
                set @v_line=@v_line+coalesce(''''+@v_to_value+'''','null')+');'
                PRINT @v_line
               end
               
            fetch c_mapping into @v_mapseq,@v_from_value,@v_to_value
          end
        PRINT @v_newline

        close c_mapping
        deallocate c_mapping 
      end
   
    fetch c_template into 
      @v_templatekey,
      @v_elementkey,
      @v_columnname,
      @v_transmnemonic,
      @v_rowinsertind,
      @v_seqinsertind,
      @v_mapkey,
      @v_defaultvalue,
      @v_lastuserid,
      @v_addlqualifier  
  end
  
close c_template
deallocate c_template
