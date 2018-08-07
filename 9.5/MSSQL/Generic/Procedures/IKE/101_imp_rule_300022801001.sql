/******************************************************************************
**  Name: imp_rule_ext_300022801001
**  Desc: IKE boookcomment update
**  Auth: Bennett     
**  Date: 5/9/2016
*******************************************************************************
**  Change History
*******************************************************************************
**  Date:        Author:     Description:
*   --------     --------    -------------------------------------------
**  5/9/2016     Bennett     original
*******************************************************************************/

if exists (select * from dbo.sysobjects where id = object_id(N'[dbo].[imp_rule_ext_300022801001]') and OBJECTPROPERTY(id, N'IsProcedure') = 1)
drop procedure [dbo].[imp_rule_ext_300022801001]
GO

SET QUOTED_IDENTIFIER OFF 
GO
SET ANSI_NULLS ON 
GO

CREATE PROCEDURE imp_rule_ext_300022801001
(@i_batchkey int,
 @i_row int,
 @i_elementseq int,
 @i_templatekey int,
 @i_rulekey bigint,
 @i_level int,
 @i_userid varchar(50),
 @i_titlekeyset varchar(500),
 @i_qualifiers varchar(500),
 @o_writehistoryind int output)

AS

declare
  @v_addlqualifier varchar(500),
  @v_bookkey int,
  @v_citationind int,
  @v_history_order int,
  @v_forced_commentkey int,
  @v_qsiobjectkey int,
  @v_commentkey int,
  @v_commenttext varchar(max),
  @v_commenttypecode int,
  @v_commenttypesubcode int,
  @v_count int,
  @v_datacode int,
  @v_datasubcode int,
  @v_destination_pointer binary(16),
  @i_dmlkey int,
  @v_elementkey int,
  @v_elementdesc varchar(500),
  @v_elementval varchar(max),
  @v_errcode int,
  @v_errcode2 int,
  @v_errmsg varchar(500),
  @v_errmsg2 varchar(500),
  @v_html_part varchar(500),
  @v_invalidhtmlind int,
  @v_lobkey int,
  @v_pointer int,
  @v_printingkey int,
  @v_row_count int,
  @v_sortorder int,
  @v_source_pointer binary(16),
  @v_source_prefix varchar(20),
  @v_text_releasetoelo_ind  varchar(500),
  @v_textauthor_d107  varchar(500),
  @v_textpubdate_d019  varchar(500),
  @v_textsource_d108  varchar(500)

begin
  set @v_errcode=1
  set @v_errmsg='bookcomments: updated'
 -- no history, causes a tittlehistory error
  set @o_writehistoryind = 0 
  set @v_bookkey = dbo.resolve_keyset(@i_titlekeyset,1)
  set @v_printingkey = dbo.resolve_keyset(@i_titlekeyset,2)

  SELECT 
      @v_elementval= LTRIM(RTRIM(b.originalvalue)),
      @v_elementkey=b.elementkey,
      @v_elementdesc=elementdesc,
      @v_lobkey = lobkey,
      @v_addlqualifier=td.addlqualifier
    FROM imp_batch_detail b ,imp_DML_elements d,imp_element_defs e,imp_template_detail td
    WHERE b.batchkey=@i_batchkey
      AND b.row_id=@i_row
      AND b.elementseq=@i_elementseq
      AND d.dmlkey=@i_rulekey
      AND d.elementkey=b.elementkey
      and td.templatekey=@i_templatekey
      and b.elementkey=td.elementkey

  set @v_commenttypecode=dbo.resolve_keyset(@i_qualifiers,1)
  set @v_commenttypesubcode=dbo.resolve_keyset(@i_qualifiers,2)
  set @v_forced_commentkey=dbo.resolve_keyset(@i_qualifiers,3)
  select @v_commenttext = textvalue
    from imp_batch_lobs
    where lobkey=@v_lobkey

  if @v_commenttypecode is not null and @v_commenttypesubcode is not null
    begin
      set @v_qsiobjectkey=@v_forced_commentkey
      select @v_count=count(*)
        from qsicomments
        where commentkey=@v_qsiobjectkey
          and commenttypecode=@v_commenttypecode
          and commenttypesubcode=@v_commenttypesubcode
      if @v_count=0
        begin    
          insert into qsicomments
            (commentkey,commenttypecode,commenttypesubcode,commenthtml,lastuserid,lastmaintdate)
            values
            (@v_qsiobjectkey,@v_commenttypecode,@v_commenttypesubcode,@v_commenttext,@i_userid,getdate())
        end
      else
        begin
          update qsicomments
            set commenthtml=@v_commenttext,lastmaintdate=getdate()
            where commentkey=@v_qsiobjectkey
              and commenttypecode=@v_commenttypecode
              and commenttypesubcode=@v_commenttypesubcode
        end
      exec check_valid_html null,@v_bookkey,null,@v_commenttypecode,@v_commenttypesubcode,'QSICOMMENTS',1,1,@v_invalidhtmlind output

      if @v_invalidhtmlind=0
        begin
          if @v_source_prefix <> '<div'
            begin
              updatetext qsicomments.commenthtml @v_destination_pointer 0 0 '<div>'
              updatetext qsicomments.commenthtml @v_destination_pointer null 0 '</div>'
            end
          exec html_to_lite_from_row @v_bookkey,@v_printingkey,@v_commenttypecode,@v_commenttypesubcode,'QSICOMMENTS', @v_errcode2 , @v_errmsg2 
          exec html_to_text_from_row @v_bookkey,@v_printingkey,@v_commenttypecode,@v_commenttypesubcode,'QSICOMMENTS', @v_errcode2 , @v_errmsg2 
        end
      else
        begin
          exec commenthtml_fix 'QSICOMMENTS',@v_qsiobjectkey,null,@v_commenttypecode,@v_commenttypesubcode
        end

    end

  if @v_errcode >= @i_level
    begin
      EXECUTE imp_write_feedback @i_batchkey, @i_row, null, @i_elementseq ,300022111001 , @v_errmsg, @v_errcode,3
    end

END


GO
