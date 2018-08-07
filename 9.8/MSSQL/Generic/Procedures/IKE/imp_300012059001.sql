/******************************************************************************
**  Name: imp_300012059001
**  Desc: IKE spinesize unit of measure
**  Auth: Bennett     
**  Date: 5/9/2016
*******************************************************************************
**  Change History
*******************************************************************************
**  Date:        Author:     Description:
*   --------     --------    -------------------------------------------
**  5/9/2016     Bennett     original
**  5/20/16      Kusum       Case 37304 - increased size of datadesc VARCHAR(MAX) 
**                           to allow for alternatedesc1
*******************************************************************************/

SET QUOTED_IDENTIFIER ON 
GO
SET ANSI_NULLS ON 
GO

if exists (select * from dbo.sysobjects where id = object_id(N'[dbo].[imp_300012059001]') and OBJECTPROPERTY(id, N'IsProcedure') = 1)
drop procedure [dbo].[imp_300012059001]
GO

CREATE PROCEDURE dbo.imp_300012059001
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
DECLARE
  @v_elementval    VARCHAR(4000),
  @v_errcode    INT,
  @v_errmsg     VARCHAR(4000),
  @v_elementdesc    VARCHAR(4000),
  @v_elementkey    BIGINT,
  @v_bookkey     INT,
  @v_printingkey     INT,
  @v_tableid   INT,
  @v_datacode   INT,
  @v_datacode_org   INT,
  @v_datadesc   VARCHAR(MAX),
  @v_hit      INT,
  @v_debug int
  
BEGIN
  set @v_debug=0
  SET @v_hit = 0
  SET @o_writehistoryind = 0
  SET @v_errcode = 1
  SET @v_bookkey = dbo.resolve_keyset(@i_titlekeyset,1)
  SET @v_printingkey = dbo.resolve_keyset(@i_titlekeyset,2)
  SET @v_errmsg = 'spinesize unit of measure unchanged'

  SELECT
      @v_elementval =  Ltrim(Rtrim(originalvalue)),
      @v_elementkey = b.elementkey,
      @v_tableid = ed.tableid
    FROM imp_batch_detail b , imp_DML_elements d, imp_element_defs ed
    WHERE b.batchkey = @i_batch
      AND b.row_id = @i_row
      AND b.elementseq = @i_elementseq
      AND d.dmlkey = @i_dmlkey
      AND d.elementkey = b.elementkey
      AND ed.elementkey = b.elementkey

  if @v_debug=1 print 'spinesize unit...'
  if @v_debug=1 print '@v_elementval '+coalesce(@v_elementval,'n/a')

  SELECT @v_datacode_org = COALESCE(spinesizeunitofmeasure,0)
    FROM printing
    WHERE bookkey=@v_bookkey 
      and printingkey=@v_printingkey

  if @v_debug=1 print '@v_datacode_org '+coalesce(cast(@v_datacode_org as varchar),'n/a')
      
  exec find_gentables_mixed @v_elementval,@v_tableid ,@v_datacode output,@v_datadesc output

  if @v_debug=1 print '@v_datacode '+coalesce(cast(@v_datacode as varchar),'n/a')

  IF @v_datacode is not null
    begin
      IF @v_datacode_org <> @v_datacode
         BEGIN
          if @v_debug=1 print 'update '
          UPDATE printing
            SET
              spinesizeunitofmeasure = @v_datacode,
              lastuserid = @i_userid,
              lastmaintdate = GETDATE()
            WHERE bookkey = @v_bookkey
              and printingkey=@v_printingkey
          SET @o_writehistoryind = 1
          SET @v_errmsg = 'spinesize unit of measure updated'
        END
      END

  if @v_debug=1 print 'feedback '+coalesce(cast(@v_errmsg as varchar),'n/a')
  EXECUTE imp_write_feedback @i_batch, @i_row, @v_elementkey, @i_elementseq ,@i_dmlkey , @v_errmsg, @i_level, 3 

END

  if @v_debug=1 print '...spinesize unit'
/*     END SPROC     */
END



GO
SET QUOTED_IDENTIFIER OFF 
GO
SET ANSI_NULLS ON 
GO

GRANT EXECUTE ON dbo.[imp_300012059001] to PUBLIC 
GO
