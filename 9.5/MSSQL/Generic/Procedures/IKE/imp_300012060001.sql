/******************************************************************************
**  Name: imp_300012060001
**  Desc: IKE Book weight unit of measure
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

if exists (select * from dbo.sysobjects where id = object_id(N'[dbo].[imp_300012060001]') and OBJECTPROPERTY(id, N'IsProcedure') = 1)
drop procedure [dbo].[imp_300012060001]
GO

CREATE PROCEDURE dbo.imp_300012060001
  
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
DECLARE @v_elementval    VARCHAR(4000),
  @v_elementdesc    VARCHAR(4000),
  @v_elementkey    INT,
  @v_errcode    INT,
  @v_errmsg     VARCHAR(4000),
  @v_new_bookweight_units  int,
  @v_cur_bookweight_units  int,
  @v_bookkey     INT,
  @v_printingkey  INT,
  @v_count    INT,
  @DEBUG	INT
  
BEGIN
  SET @v_count = 0
  SET @o_writehistoryind = 0
  SET @v_errcode = 1
  SET @v_errmsg = 'Book weight unit of measure update...'
  SET @v_bookkey = dbo.resolve_keyset(@i_titlekeyset,1)
  SET @v_printingkey = dbo.resolve_keyset(@i_titlekeyset,2)
  SET @DEBUG=0

/*  GET IMPORTED BOOK WEIGHT    */
  SELECT @v_elementval =  originalvalue, @v_elementkey = b.elementkey
    FROM imp_batch_detail b , imp_DML_elements d
    WHERE b.batchkey = @i_batch
      AND b.row_id = @i_row
      AND b.elementseq = @i_elementseq
      AND d.dmlkey = @i_dmlkey
      AND d.elementkey = b.elementkey
      
  IF @DEBUG<>0 PRINT '@v_elementval = ' + cast (@v_elementval as varchar(max))
  IF @DEBUG<>0 PRINT '@v_elementkey = ' + cast (@v_elementkey as varchar(max))

/* GET CURRENT CURRENT BOOK WEIGHT VALUE    */
  SELECT @v_cur_bookweight_units =bookweightunitofmeasure
    FROM printing
    WHERE bookkey=@v_bookkey 
      and printingkey=@v_printingkey

  IF @DEBUG<>0 PRINT '@v_cur_bookweight_units = ' + cast (@v_cur_bookweight_units as varchar(max))

  select @v_new_bookweight_units = datacode
    from gentables 
    where tableid=613
      and datadesc=@v_elementval

  IF @DEBUG<>0 PRINT '@v_new_bookweight_units = ' + cast (@v_new_bookweight_units as varchar(max))
  
  IF coalesce(@v_cur_bookweight_units,-1) <> coalesce(@v_new_bookweight_units,-1)
    BEGIN
      UPDATE printing
        SET  bookweightunitofmeasure = @v_new_bookweight_units,
             lastuserid = @i_userid,
             lastmaintdate = GETDATE()
        WHERE bookkey = @v_bookkey
          and printingkey = @v_printingkey
      SET @o_writehistoryind = 1
      SET @v_errmsg = 'Book weight unit of measure updated'
    END
  else
    begin
      SET @v_errmsg = 'Book weight unit of measure unchanged'
    end

  EXECUTE imp_write_feedback @i_batch, @i_row,@v_elementkey , @i_elementseq ,@i_dmlkey , @v_errmsg, @v_errcode, 3
END

/*     END SPROC     */
END

GO
SET QUOTED_IDENTIFIER OFF 
GO
SET ANSI_NULLS ON 
GO

GRANT EXECUTE ON dbo.[imp_300012060001] to PUBLIC 
GO
