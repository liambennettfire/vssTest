/******************************************************************************
**  Name: imp_300011135001
**  Desc: IKE book verification
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

if exists (select * from dbo.sysobjects where id = object_id(N'[dbo].[imp_300011135001]') and OBJECTPROPERTY(id, N'IsProcedure') = 1)
drop procedure [dbo].[imp_300011135001]
GO

CREATE PROCEDURE dbo.imp_300011135001
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

DECLARE
  @verf_errcode    INT,
  @verf_errmsg     VARCHAR(4000),
  @v_errcode    INT,
  @v_errmsg     VARCHAR(4000),
  @v_bookkey     INT  

BEGIN
  SET @v_errcode = 1
  SET @v_errmsg = 'book verification'
  SET @v_bookkey = dbo.resolve_keyset(@i_titlekeyset,1)

  exec qtitle_auto_verify_title @v_bookkey,1,@i_userid,@verf_errcode output,@verf_errmsg output

  if @verf_errcode=2
    set @v_errcode=3

  if @verf_errcode=3
    set @v_errcode=2

  set @v_errmsg=@verf_errmsg

  EXECUTE imp_write_feedback @i_batch, @i_row, 100011135, @i_elementseq ,@i_dmlkey , @v_errmsg, @i_level, @v_errcode 

END
GO


