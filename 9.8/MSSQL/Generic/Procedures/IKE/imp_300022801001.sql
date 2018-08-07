﻿/******************************************************************************
**  Name: imp_300022801001
**  Desc: IKE 
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

if exists (select * from dbo.sysobjects where id = object_id(N'[dbo].[imp_300022801001]') and OBJECTPROPERTY(id, N'IsProcedure') = 1)
drop procedure [dbo].[imp_300022801001]
GO

CREATE PROCEDURE dbo.imp_300022801001
  
  @i_batch int, 
  @i_row int , 
  @i_dmlkey bigint, 
  @i_titlekeyset varchar(500),
  @i_contactkeyset varchar(500),
  @i_templatekey int,
  @i_elementseq int,
  @i_level int,
  @i_userid varchar(50),
  @i_newtitleind int,
  @i_newcontactind int,
  @o_writehistoryind int output
AS

BEGIN 
/*    START SPROC    */
/* comment update */
DECLARE 
  @v_source_pointer binary(16),
  @v_destination_pointer binary(16),
  @v_source_prefix varchar(20),
  @v_pointer int,
  @v_addlqualifier varchar(500),
  @v_qualifier varchar(500),
  @v_elementkey int,
  @v_lobkey int,
  @v_commenttypecode int,
  @v_commenttypesubcode int,
  @v_commentkey int,
  @v_bookkey int,
  @v_contactkey int,
  @v_printingkey int,
  @v_datacode int,
  @v_datasubcode int,
  @v_row_count int,
  @v_errmsg varchar(500),
  @v_errcode int,
  @v_errmsg2 varchar(500),
  @v_errcode2 int,
  @v_invalidhtmlind int,
  @v_html_part varchar(8000)

begin
--  set @v_errcode=1
--  set @v_errmsg='bookcomments: updated'
 -- no history, causes a tittlehistory error
  set @o_writehistoryind = 0 
  SET @v_contactkey = dbo.resolve_keyset(@i_contactkeyset,1)

  SELECT 
      @v_addlqualifier=td.addlqualifier
    FROM imp_batch_detail b ,imp_DML_elements d,imp_element_defs e,imp_template_detail td
    WHERE b.batchkey=@i_batch
      AND b.row_id=@i_row
      AND b.elementseq=@i_elementseq
      AND d.dmlkey=@i_dmlkey
      AND d.elementkey=b.elementkey
      and td.templatekey=@i_templatekey
      and b.elementkey=td.elementkey

  set @v_qualifier=@v_addlqualifier+','+cast(@v_contactkey as varchar)
  exec imp_rule_ext_300022801001 @i_batch,@i_row,@i_elementseq,@i_templatekey,300022801001,@i_level,@i_userid,@i_titlekeyset,@v_qualifier,@o_writehistoryind output

END

/*     END SPROC     */
END

GO
SET QUOTED_IDENTIFIER OFF 
GO
SET ANSI_NULLS ON 
GO

GRANT EXECUTE ON dbo.[imp_300022801001] to PUBLIC 
GO
