/******************************************************************************
**  Name: imp_300013023001
**  Desc: IKE Add/Replace Price
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

if exists (select * from dbo.sysobjects where id = object_id(N'[dbo].[imp_300013023001]') and OBJECTPROPERTY(id, N'IsProcedure') = 1)
drop procedure [dbo].[imp_300013023001]
GO

CREATE PROCEDURE dbo.imp_300013023001 
  
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

/* Add/Replace Price */

BEGIN 

DECLARE @v_elementval    VARCHAR(4000),
  @v_elementdesc    VARCHAR(4000),
  @v_elementkey    BIGINT,
  @v_errcode    INT,
  @v_errmsg     VARCHAR(4000),
  @v_bookkey     INT,
  @v_new_price    FLOAT,
  @v_price      VARCHAR(100),
  @v_effdate    DATETIME,
  @v_date      VARCHAR(100),
  @v_hit      INT,
  @v_newkey    INT,
  @v_sortorder    INT,
  @v_pricetypecode    INT,
  @v_pricetype    VARCHAR(100),
  @v_pricedesc    VARCHAR(100),
  @v_currencytypecode  INT,
  @v_currencytype    VARCHAR(100),
  @v_destinationcolumn  VARCHAR(50),
  @v_pricemaint    VARCHAR(100),
  @v_datadesc    VARCHAR(max)
BEGIN
  SET @v_hit = 0
  SET @v_newkey  = 0
  SET @v_sortorder = 0  
  SET @o_writehistoryind = 0
  SET @v_errcode = 1
  SET @v_errmsg = 'Inserted Price Type, Currency Type, Final Price, Effective Date'
  SET @v_bookkey = dbo.resolve_keyset(@i_titlekeyset,1)
  SELECT @v_price =  originalvalue
    FROM imp_batch_detail 
    WHERE batchkey = @i_batch
      AND row_id = @i_row
      AND elementseq = @i_elementseq
      AND elementkey = 100013023
  set @v_pricedesc='finalprice'
  if @v_price is null
    begin
      SELECT @v_price =  originalvalue
        FROM imp_batch_detail 
        WHERE batchkey = @i_batch
          AND row_id = @i_row
          AND elementseq = @i_elementseq
          AND elementkey = 100013022
      set @v_pricedesc='budgetprice'
    end
  if @v_price is null
    begin
      SELECT @v_price =  originalvalue
        FROM imp_batch_detail 
        WHERE batchkey = @i_batch
          AND row_id = @i_row
          AND elementseq = @i_elementseq
          AND elementkey = 100013021
      set @v_pricedesc='allprice'
    end
  SELECT @v_pricetype =  originalvalue
    FROM imp_batch_detail 
    WHERE batchkey = @i_batch
      AND row_id = @i_row
      AND elementseq = @i_elementseq
      AND elementkey = 100013024
      
  SELECT @v_currencytype =  originalvalue
    FROM imp_batch_detail 
    WHERE batchkey = @i_batch
      AND row_id = @i_row
      AND elementseq = @i_elementseq
      AND elementkey = 100013026
      
  SELECT @v_effdate =  originalvalue
    FROM imp_batch_detail 
    WHERE batchkey = @i_batch
      AND row_id = @i_row
      AND elementseq = @i_elementseq
      AND elementkey = 100013028
      
  SET @v_new_price = CONVERT(FLOAT,@v_price )
  SET @v_date = dbo.resolve_date(@v_effdate)  
  
  exec dbo.find_gentables_mixed  @v_pricetype,306,@v_pricetypecode output,@v_datadesc output
  exec dbo.find_gentables_mixed  @v_currencytype,122,@v_currencytypecode output,@v_datadesc output
  
  if @v_pricedesc='allprice'
    begin
      set @v_pricedesc='budgetprice'
      EXECUTE imp_rule_ext_300013000001 @i_batch, @v_bookkey,@v_new_price,@i_newtitleind,@v_pricetypecode,@v_currencytypecode,@v_pricedesc,@v_date,@i_userid
      set @v_pricedesc='finalprice'
      EXECUTE imp_rule_ext_300013000001 @i_batch, @v_bookkey,@v_new_price,@i_newtitleind,@v_pricetypecode,@v_currencytypecode,@v_pricedesc,@v_date,@i_userid
    end
  else
    begin
      EXECUTE imp_rule_ext_300013000001 @i_batch, @v_bookkey,@v_new_price,@i_newtitleind,@v_pricetypecode,@v_currencytypecode,@v_pricedesc,@v_date,@i_userid
    end
  EXECUTE imp_write_feedback @i_batch, @i_row, 100013023, @i_elementseq ,@i_dmlkey , @v_errmsg, @i_level, 3 
END

end

GO
SET QUOTED_IDENTIFIER OFF 
GO
SET ANSI_NULLS ON 
GO

GRANT EXECUTE ON dbo.[imp_300013023001] to PUBLIC 
GO
