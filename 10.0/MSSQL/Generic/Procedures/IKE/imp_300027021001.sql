/******************************************************************************
**  Name: imp_300027021001
**  Desc: IKE P&L accounting
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

if exists (select * from dbo.sysobjects where id = object_id(N'[dbo].[imp_300027021001]') and OBJECTPROPERTY(id, N'IsProcedure') = 1)
drop procedure [dbo].[imp_300027021001]
GO

CREATE PROCEDURE dbo.imp_300027021001 
  
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

/* P&L accounting */

BEGIN 

DECLARE @v_elementval    VARCHAR(4000),
  @v_errcode    INT,
  @v_errmsg     VARCHAR(4000),
  @v_elementdesc    VARCHAR(4000),
  @v_elementkey    BIGINT,
  @v_lobcheck     VARCHAR(20),
  @v_lobkey     INT,
  @v_bookkey     INT,
  @i_pagecount  int
BEGIN
  SET @o_writehistoryind = 0
  SET @v_errcode = 1
  SET @v_errmsg = 'P&L accounting'
  SET @v_bookkey = dbo.resolve_keyset(@i_titlekeyset,1)
  SET @i_pagecount = 0


-- on hold


  exec imp_pl_accounting_data
    @v_bookkey,
    @i_batch,@i_row,@i_elementseq,@i_dmlkey,@i_userid,
    @v_errcode output,@v_errmsg output

  IF @v_errcode < 2
    BEGIN
      EXECUTE imp_write_feedback @i_batch,@i_row,@v_elementkey,@i_elementseq ,@i_dmlkey,@v_errmsg,@i_level,3     
    END
END

end

GO
SET QUOTED_IDENTIFIER OFF 
GO
SET ANSI_NULLS ON 
GO

GRANT EXECUTE ON dbo.[imp_300027021001] to PUBLIC 
GO
