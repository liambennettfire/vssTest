/******************************************************************************
**  Name: imp_200010046001
**  Desc: IKE Template exists
**  Auth: Bennett     
**  Date: 5/9/2016
*******************************************************************************
**  Change History
*******************************************************************************
**  Date:        Author:     Description:
*   --------     --------    -------------------------------------------
**  5/9/2016     Bennett     original
*******************************************************************************/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

if exists (select * from dbo.sysobjects where id = object_id(N'[dbo].[imp_200010046001]') and OBJECTPROPERTY(id, N'IsProcedure') = 1)
drop procedure [dbo].[imp_200010046001]
GO

CREATE PROCEDURE [dbo].[imp_200010046001]
  
  @i_batch int,
  @i_row int,
  @i_elementkey int,
  @i_elementseq int,
  @i_templatekey int,
  @i_rulekey bigint,
  @i_rpt int
AS

DECLARE
  @v_elementval VARCHAR(4000),
  @v_errcode INT,
  @v_errlevel INT,
  @v_code INT,
  @v_msg VARCHAR(4000),
  @v_elementdesc VARCHAR(4000),
  @v_count int,
  @v_propagate_bookkey int,
  @v_isbn9 VARCHAR(20)    

  SET @v_errlevel = 1
  SET @v_msg = 'Template exists'

BEGIN

  SELECT @v_elementval =  COALESCE(originalvalue,'')
    FROM imp_batch_detail 
    WHERE batchkey = @i_batch
      AND row_id = @i_row
      AND elementseq = @i_elementseq
      AND elementkey = @i_elementkey

  if ISNUMERIC(@v_elementval)=0
    begin
      SET @v_errlevel = 3
      SET @v_msg = 'invalid template ID, non-numeric ('+coalesce(@v_elementval,'n/a')+')'
      EXEC imp_write_feedback @i_batch, @i_row, @i_elementkey, @i_elementseq, @i_rulekey , @v_msg, @v_errlevel, 2
      return
    end
    
  select @v_count=count(*)
    from book
    where bookkey=cast(@v_elementval as int)
  if @v_count<>1
    begin
      SET @v_errlevel = 3
      SET @v_msg = 'invalid template ID ('+coalesce(@v_elementval,'n/a')+')'
      EXEC imp_write_feedback @i_batch, @i_row, @i_elementkey, @i_elementseq, @i_rulekey , @v_msg, @v_errlevel, 2
    end

END
