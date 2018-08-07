SET QUOTED_IDENTIFIER ON 
GO
SET ANSI_NULLS ON 
GO

/******************************************************************************
**  Name: imp_element_status
**  Desc: IKE display element and thier attached attached 
**  Auth: Bennett     
**  Date: 5/26/2016
**  Paramteres:
**    batchkey = an existing batchkey will return elements status or left empty (run withnout a parameter) it will return all elements
*******************************************************************************
**  Change History
*******************************************************************************
**  Date:        Author:     Description:
*   --------     --------    -------------------------------------------
**  5/26/2016     Bennett     original
*******************************************************************************/

if exists (select * from dbo.sysobjects where id = object_id(N'[dbo].[imp_element_status]') and OBJECTPROPERTY(id, N'IsProcedure') = 1)
drop procedure [dbo].[imp_element_status]
GO

CREATE PROCEDURE dbo.imp_element_status
  @v_bathckey int = null
as

declare
  @v_elementkey bigint,
  @v_elementmnemonic varchar(50),
  @v_elementdesc varchar(500),
  @v_feedbackmsg varchar(500),
  @v_tableid int,
  @v_datacode int,
  @v_datasubcode int,
  @v_destinationtable varchar(50),
  @v_destinationcolumn varchar(50),
  @v_datetypecode int,
  @v_lobind int,
  @v_importnullind int,
  @v_leadkeyname varchar(50),
  @v_indent_header varchar(20),
  @v_indent_detail varchar(20),
  @v_rule_count int,
  @v_rulekey bigint,
  @v_ruledesc varchar(500),
  @v_batchkey int,
  @v_count int,
  @v_processorder varchar(10)

begin

  set @v_indent_header = '   '
  set @v_indent_detail = '      '

/* 
set @v_bathckey to NULL to list all elements
set @v_bathckey to a processed batch to list only element in that batch 
*/
  
  if @v_batchkey is null
    begin
      DECLARE c_elements CURSOR FOR
        select distinct elementkey,elementmnemonic,elementdesc,tableid,datacode,datasubcode,destinationtable,destinationcolumn,datetypecode,lobind,importnullind,leadkeyname
          from imp_element_defs
          order by elementkey
    end
  else
    begin
      select @v_count=count(*)
        from imp_feedback
        where batchkey=@v_batchkey
          and imp_agent=1
          and serverity=3
      if @v_count > 0
        begin
          print 'Load failures'
          declare c_load_failures cursor for
            select feedbackmsg
              from imp_feedback
              where batchkey=@v_batchkey
                and imp_agent=1
                and serverity=3
            open c_load_failures 
          fetch c_load_failures into @v_feedbackmsg
          while @@fetch_status=0
            begin
              print @v_indent_header+@v_feedbackmsg
              fetch c_load_failures into @v_feedbackmsg
            end
          close c_load_failures 
          deallocate c_load_failures 
          print ' '
        end
      DECLARE c_elements CURSOR FOR
        select distinct ef.elementkey,elementmnemonic,elementdesc,tableid,datacode,datasubcode,destinationtable,destinationcolumn,datetypecode,lobind,importnullind,leadkeyname
          from imp_element_defs ef, imp_batch_detail bd 
          where ef.elementkey=bd.elementkey
            and bd.batchkey=@v_batchkey
          order by ef.elementkey
    end

  open c_elements 
  fetch c_elements into @v_elementkey,@v_elementmnemonic,@v_elementdesc,@v_tableid,@v_datacode,@v_datasubcode,@v_destinationtable,@v_destinationcolumn,@v_datetypecode,@v_lobind,@v_importnullind,@v_leadkeyname
  while @@fetch_status=0
    begin
      print 'Element: '+@v_elementdesc+' ('+cast(@v_elementkey as varchar(20))+')'
      print @v_indent_header+'mnemonic:'+@v_elementmnemonic
      if @v_tableid is not null or @v_datacode is not null or @v_datasubcode is not null
        begin
          print @v_indent_header+'gentable info: '+
            ' tableid='+coalesce(cast(@v_tableid as varchar(20)),'n/a')+
            ' datacode='+coalesce(cast(@v_datacode as varchar(20)),'n/a')+
            ' datasubcode='+coalesce(cast(@v_datasubcode as varchar(20)),'n/a')
        end 
      if @v_leadkeyname is not null 
        begin
          print @v_indent_header+'leadkey: '+cast(@v_leadkeyname as varchar(20))
        end 
      if @v_lobind is not null or @v_lobind=0
        begin
          print @v_indent_header+'LOB type'
        end 
      if @v_importnullind is not null or @v_importnullind=0
        begin
          print @v_indent_header+'Imports NULL values'
        end 

      select @v_rule_count = count(*)
        from imp_load_master m, imp_load_elements e
        where e.elementkey = @v_elementkey
          and e.loadkey=m.loadkey
      if @v_rule_count > 0
        begin
          print @v_indent_header+'Loader rules'
          declare c_rules cursor for
            select m.rulekey,processorder
              from imp_load_master m, imp_load_elements e
              where e.elementkey=@v_elementkey
                and m.loadkey=e.loadkey
           open c_rules 
           fetch c_rules into @v_rulekey,@v_processorder
           while @@fetch_status=0
             begin
               print @v_indent_detail+'('+cast(@v_rulekey as varchar(20))+') process order: '+@v_processorder
               fetch c_rules into @v_rulekey,@v_processorder
             end
           close c_rules 
           deallocate c_rules 
        end

      select @v_rule_count = count(*)
        from imp_element_rules 
        where elementkey = @v_elementkey
      if @v_rule_count > 0
        begin
          print @v_indent_header+'Validation rules (element)'
          declare c_rules cursor for
            select e.rulekey,e.processorder
              from imp_element_rules e
              where e.elementkey=@v_elementkey
              order by e.processorder
           open c_rules 
           fetch c_rules into @v_rulekey,@v_processorder
           while @@fetch_status=0
             begin
               print @v_indent_detail+'('+cast(@v_rulekey as varchar(20))+') process order: '+@v_processorder
               fetch c_rules into @v_rulekey,@v_processorder
             end
           close c_rules 
           deallocate c_rules 
        end

      select @v_rule_count = count(*)
        from imp_collection_elements
        where elementkey = @v_elementkey
      if @v_rule_count > 0
        begin
          print @v_indent_header+'Validation rules (collection)'
          declare c_rules cursor for
            select m.collectionkey,m.processorder
              from imp_collection_elements e, imp_collection_master m
              where e.elementkey=@v_elementkey
                and m.collectionkey=e.collectionkey
              order by m.processorder
           open c_rules 
           fetch c_rules into @v_rulekey,@v_processorder
           while @@fetch_status=0
             begin
               print @v_indent_detail+'('+cast(@v_rulekey as varchar(20))+') process order: '+@v_processorder
               fetch c_rules into @v_rulekey,@v_processorder
             end
           close c_rules 
           deallocate c_rules 
        end

      select @v_rule_count = count(*)
        from imp_dml_elements
        where elementkey = @v_elementkey
      if @v_rule_count > 0
        begin
          print @v_indent_header+'DML rules'
          declare c_rules cursor for
            select m.rulekey,m.processorder
              from imp_dml_elements e, imp_dml_master m
              where e.elementkey=@v_elementkey
                and m.dmlkey=e.dmlkey
              order by m.processorder
           open c_rules 
           fetch c_rules into @v_rulekey,@v_processorder
           while @@fetch_status=0
             begin
               print @v_indent_detail+'('+cast(@v_rulekey as varchar(20))+') process order: '+@v_processorder
               fetch c_rules into @v_rulekey,@v_processorder
             end
           close c_rules 
           deallocate c_rules 
        end
                             
      print @v_indent_detail
      fetch c_elements into @v_elementkey,@v_elementmnemonic,@v_elementdesc,@v_tableid,@v_datacode,@v_datasubcode,@v_destinationtable,@v_destinationcolumn,@v_datetypecode,@v_lobind,@v_importnullind,@v_leadkeyname
    end
  close c_elements 
  deallocate c_elements 

end
