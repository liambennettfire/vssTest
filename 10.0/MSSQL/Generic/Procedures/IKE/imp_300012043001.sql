/******************************************************************************
**  Name: imp_300012043001
**  Desc: IKE Barcode
**  Auth: Bennett     
**  Date: 5/9/2016
*******************************************************************************
**  Change History
*******************************************************************************
**  Date:        Author:     Description:
*   --------     --------    -------------------------------------------
**  5/9/2016     Bennett     original
*******************************************************************************/
IF  EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[imp_300012043001]') AND type in (N'P', N'PC'))
DROP PROCEDURE [dbo].[imp_300012043001]

SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

CREATE PROCEDURE [dbo].[imp_300012043001] 
  
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

/* Barcode */

BEGIN 

DECLARE
  @v_barcodetype    VARCHAR(4000),
  @v_barcodeposition    VARCHAR(4000),
  @v_errcode    INT,
  @v_errmsg     VARCHAR(4000),
  @v_elementdesc    VARCHAR(4000),
  @v_elementkey    BIGINT,
  @v_lobcheck     VARCHAR(20),
  @v_datacode     INT,
  @v_datadesc    VARCHAR(4000),
  @v_datasubcode     INT,
  @v_datacode_org     INT,
  @v_datasubcode_org     INT,
  @v_bookkey     INT,
  @v_canrestriction  INT,
  @v_canrestrictioncode  INT,
  @v_hit      INT
  
BEGIN
--print 'Barcode1 update'

  SET @v_hit = 0
  SET @v_canrestriction = 0
  SET @v_canrestrictioncode = 0
  SET @o_writehistoryind = 0
  SET @v_errcode = 1
  SET @v_errmsg = 'Barcode1 update'
  SET @v_bookkey = dbo.resolve_keyset(@i_titlekeyset,1)

  select  
      @v_datacode_org=barcodeid1,
      @v_datasubcode_org=barcodeposition1
    from printing
    where bookkey=@v_bookkey
      and printingkey=1
  SELECT @v_barcodetype = originalvalue
    FROM imp_batch_detail
    WHERE batchkey = @i_batch
      AND row_id = @i_row
      AND elementseq = @i_elementseq
      AND elementkey = 100012043
  SELECT @v_barcodeposition = originalvalue
    FROM imp_batch_detail
    WHERE batchkey = @i_batch
      AND row_id = @i_row
      AND elementseq = @i_elementseq
      AND elementkey = 100012044
      
      --print '@v_barcodetype'
      --print @v_barcodetype
      --print '@v_barcodeposition'
      --print @v_barcodeposition
      
      exec find_gentables_mixed @v_barcodetype,552,@v_datacode OUTPUT,@v_datadesc OUTPUT
      
  --select @v_datacode = datacode
  --  from gentables
  --  where tableid=552
  --    and datadesc=@v_barcodetype
  if @v_datacode is not null
    begin
      if coalesce(@v_datacode_org,0)<>coalesce(@v_datacode,0)
        begin
          update printing
            set barcodeid1=@v_datacode
            where bookkey=@v_bookkey
              and printingkey=1
          EXECUTE imp_write_feedback @i_batch, @i_row, @v_elementkey, @i_elementseq ,@i_dmlkey , 'Barcode type updated', @i_level, 3
        end
      else
        begin
          EXECUTE imp_write_feedback @i_batch, @i_row, @v_elementkey, @i_elementseq ,@i_dmlkey , 'Barcode type unchanged', @i_level, 3
        end
      if @v_barcodeposition is not null
        begin
		  exec find_subgentables_mixed @v_barcodeposition,552,@v_datacode OUTPUT,@v_datasubcode OUTPUT,@v_datadesc OUTPUT
        
          --select @v_datasubcode = datasubcode
          --  from subgentables
          --  where tableid=552
          --    and datacode=@v_datacode
          --    and datadesc=@v_barcodeposition
          if @v_datasubcode is not null
            begin
              if coalesce(@v_datasubcode_org,0)<>coalesce(@v_datasubcode,0)
                begin
                  update printing
                    set barcodeposition1=@v_datasubcode
                    where bookkey=@v_bookkey
                      and printingkey=1
                  EXECUTE imp_write_feedback @i_batch, @i_row, @v_elementkey, @i_elementseq ,@i_dmlkey , 'Barcode position updated', @i_level, 3
                end
              else
                begin
                  EXECUTE imp_write_feedback @i_batch, @i_row, @v_elementkey, @i_elementseq ,@i_dmlkey , 'Barcode position unchnaged', @i_level, 3
                end
            end
        end
    end
  else
    begin
      EXECUTE imp_write_feedback @i_batch, @i_row, @v_elementkey, @i_elementseq ,@i_dmlkey , 'Barcode not updated', @i_level, 3
    end

  IF @v_errcode < 2
    BEGIN
      EXECUTE imp_write_feedback @i_batch, @i_row, @v_elementkey, @i_elementseq ,@i_dmlkey , @v_errmsg, @i_level, 3 
    END

END

end

