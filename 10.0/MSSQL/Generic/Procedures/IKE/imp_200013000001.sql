/******************************************************************************
**  Name: imp_200013000001
**  Desc: IKE Book pricing validation
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

if exists (select * from dbo.sysobjects where id = object_id(N'[dbo].[imp_200013000001]') and OBJECTPROPERTY(id, N'IsProcedure') = 1)
drop procedure [dbo].[imp_200013000001]
GO

CREATE PROCEDURE dbo.imp_200013000001 
  
  @i_batch int,
  @i_row int,
  @i_elementkey bigint,
  @i_elementseq int,
  @i_templatekey int,
  @i_rulekey bigint,
  @i_rpt int
AS

/* Book pricing */

BEGIN 

declare 
  @v_elementval varchar(4000),
  @v_errcode int,
  @v_valid_date int,
  @v_errlevel int,
  @v_msg varchar(4000),
  @v_elementdesc varchar(4000),
  @v_price_value varchar(4000),
  @v_price_type varchar(4000),
  @v_currency_type varchar(4000),
  @v_curranct_type int


begin

  -- find price value
/*  select @v_price_value = originalvalue
    from imp_batch_detail
    where batchkey = @i_batch
      and row_id = @i_row
      and elementkey = 100013021
      and elementseq = @i_elementseq
  if @v_price_value is null 
    begin
      select @v_price_value = originalvalue
        from imp_batch_detail
        where batchkey = @i_batch
          and row_id = @i_row
          and elementkey = 100013022
          and elementseq = @i_elementseq
    end
  if @v_price_value is null 
    begin
      select @v_price_value = originalvalue
        from imp_batch_detail
        where batchkey = @i_batch
          and row_id = @i_row
          and elementkey = 100013023
          and elementseq = @i_elementseq
    end
  if @v_price_value is null 
    begin
      set @v_msg = 'missing book price value'
      exec imp_write_feedback @i_batch, @i_row, null, @i_elementseq, @i_rulekey, @v_msg, 2, 2
    end
*/
  -- find price type
  select @v_price_type = originalvalue
    from imp_batch_detail
    where batchkey = @i_batch
      and row_id = @i_row
      and elementkey = 100013024
      and elementseq = @i_elementseq
  if @v_price_type is null 
    begin
      select @v_price_value = originalvalue
        from imp_batch_detail
        where batchkey = @i_batch
          and row_id = @i_row
          and elementkey = 100013025
          and elementseq = @i_elementseq
    end
  if @v_price_type is null 
    begin
      set @v_msg = 'missing book price type'
      exec imp_write_feedback @i_batch, @i_row, null, @i_elementseq, @i_rulekey, @v_msg, 2, 2
    end

  -- find currency tpe
  select @v_currency_type = originalvalue
    from imp_batch_detail
    where batchkey = @i_batch
      and row_id = @i_row
      and elementkey = 100013026
      and elementseq = @i_elementseq
  if @v_price_type is null 
    begin
      select @v_curranct_type = originalvalue
        from imp_batch_detail
        where batchkey = @i_batch
          and row_id = @i_row
          and elementkey = 100013027
          and elementseq = @i_elementseq
    end
  if @v_curranct_type is null 
    begin
      set @v_msg = 'missing currancy type for book price'
      exec imp_write_feedback @i_batch, @i_row, null, @i_elementseq, @i_rulekey, @v_msg, 2, 2
    end

end

end

GO
SET QUOTED_IDENTIFIER OFF 
GO
SET ANSI_NULLS ON 
GO

GRANT EXECUTE ON dbo.[imp_200013000001] to PUBLIC 
GO
