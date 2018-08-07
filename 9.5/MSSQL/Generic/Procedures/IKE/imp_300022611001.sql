/******************************************************************************
**  Name: imp_300022611001
**  Desc: IKE citations deleted
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

if exists (select * from dbo.sysobjects where id = object_id(N'[dbo].[imp_300022611001]') and OBJECTPROPERTY(id, N'IsProcedure') = 1)
drop procedure [dbo].[imp_300022611001]
GO

CREATE PROCEDURE dbo.imp_300022611001
  
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
declare
  @v_elementkey int,
  @v_commenttypecode int,
  @v_commenttypesubcode int,
  @v_pointer int,
  @v_bookkey int,
  @v_addlqualifier varchar(500),
  @v_elementval varchar(max),
  @v_errmsg varchar(500),
  @v_errcode int

begin
  set @v_errcode=1
  set @v_errmsg='citations deleted'
  SET @v_bookkey = dbo.resolve_keyset(@i_titlekeyset,1)

--  SELECT 
--      @v_elementval= LTRIM(RTRIM(b.originalvalue)),
--      @v_elementkey=b.elementkey,
--      @v_elementdesc=elementdesc,
--      @v_addlqualifier=td.addlqualifier
--    FROM imp_batch_detail b ,imp_DML_elements d,imp_element_defs e,imp_template_detail td
--    WHERE b.batchkey=@i_batch
--      AND b.row_id=@i_row
--      AND b.elementseq=@i_elementseq
--      AND d.dmlkey=@i_dmlkey
--      AND d.elementkey=b.elementkey
--      and td.templatekey=@i_templatekey
--      and b.elementkey=td.elementkey

  delete qsicomments
    where commentkey in
       (select qsiobjectkey
          from citation
          where bookkey=@v_bookkey)
  delete citation
     where bookkey=@v_bookkey

  IF @v_errcode < 2
    BEGIN
      EXECUTE imp_write_feedback @i_batch,@i_row,@v_elementkey,@i_elementseq ,@i_dmlkey,@v_errmsg,@i_level,3     
    END

END

/*     END SPROC     */
END

GO
SET QUOTED_IDENTIFIER OFF 
GO
SET ANSI_NULLS ON 
GO

GRANT EXECUTE ON dbo.[imp_300022611001] to PUBLIC 
GO
