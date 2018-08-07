/******************************************************************************
**  Name: imp_300013051001
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
IF EXISTS (SELECT * FROM dbo.sysobjects	WHERE id = object_id(N'[dbo].[imp_300013051001]') AND OBJECTPROPERTY(id, N'IsProcedure') = 1)
	DROP PROCEDURE [dbo].[imp_300013051001]
GO

create PROCEDURE [dbo].[imp_300013051001] 
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
  @v_pricedescind    INT,
  @v_currencytypecode  INT,
  @v_currencytype    VARCHAR(100),
  @v_destinationcolumn  VARCHAR(50),
  @v_pricemaint    VARCHAR(100),
  @v_datadesc    VARCHAR(max),
  @v_addlqualifier   varchar(200)
  
declare @debug int = 0

BEGIN
/*
AddlQualifier Parms
1st = pricetype code from gentables
2nd = currencytype  code from gentables
3rd = 1='budgetprice',2='finalprice',0='allprice' (default)
*/

  if @debug<>0 print '...debugging [imp_300013051001] begin...'

  SET @v_hit = 0
  SET @v_newkey  = 0
  SET @v_sortorder = 0  
  SET @o_writehistoryind = 0
  SET @v_errcode = 1
  SET @v_errmsg = 'Price update'
  
  SET @v_bookkey = dbo.resolve_keyset(@i_titlekeyset,1)

  SELECT 
    @v_price =  originalvalue,
	@v_elementkey = b.elementkey
	FROM imp_batch_detail b , imp_DML_elements d
	WHERE b.batchkey = @i_batch
    	AND b.row_id = @i_row
		AND b.elementseq = @i_elementseq
		AND b.elementkey = d.elementkey
		AND d.DMLkey = @i_dmlkey

  --find addlqualifier
  select @v_addlqualifier=addlqualifier from imp_template_detail where templatekey=@i_templatekey and elementkey=@v_elementkey
  SET @v_pricetypecode = dbo.resolve_keyset(@v_addlqualifier,1)
  SET @v_currencytypecode = dbo.resolve_keyset(@v_addlqualifier,2)
  SET @v_pricedescind = coalesce(dbo.resolve_keyset(@v_addlqualifier,3),0)
  set @v_pricedesc = 
    case 
      when @v_pricedescind=1 then 'budgetprice'
      when @v_pricedescind=2 then 'finalprice'
      else 'allprice'
	end
  -- @v_date needs to be handled in another rule

  if @debug<>0 print @v_addlqualifier
  if @debug<>0 print @v_pricetypecode
  if @debug<>0 print @v_currencytypecode
  if @debug<>0 print @v_pricedescind
  if @debug<>0 print @v_pricedesc

  BEGIN TRY
	SET @v_new_price = CONVERT(FLOAT,@v_price )
  END TRY
  BEGIN CATCH
	set @v_errmsg='Price Update Failed due to bad PriceData: '+coalesce(CAST(@v_price as varchar(max)),'')+' is not avalid price.' 
	set @i_level=2
	EXECUTE imp_write_feedback @i_batch, @i_row, @v_elementkey, @i_elementseq ,@i_dmlkey , @v_errmsg, @i_level, 3 
  END CATCH
 
  if @debug<>0 print @v_new_price
  
  if @v_pricedesc='allprice'
    begin
      set @v_pricedesc='budgetprice'
      EXECUTE imp_rule_ext_300013000001 @i_batch, @v_bookkey,@v_new_price,@i_newtitleind,@v_pricetypecode,@v_currencytypecode,@v_pricedesc,@v_date,@i_userid
      set @v_pricedesc='finalprice'
      EXECUTE imp_rule_ext_300013000001 @i_batch, @v_bookkey,@v_new_price,@i_newtitleind,@v_pricetypecode,@v_currencytypecode,@v_pricedesc,@v_date,@i_userid
      
      --print 'allprice'
    end
  else
    begin
      EXECUTE imp_rule_ext_300013000001 @i_batch, @v_bookkey,@v_new_price,@i_newtitleind,@v_pricetypecode,@v_currencytypecode,@v_pricedesc,@v_date,@i_userid
      --print 'not allprice'
    end
  EXECUTE imp_write_feedback @i_batch, @i_row, 100013023, @i_elementseq ,@i_dmlkey , @v_errmsg, @i_level, 3 
END

if @debug<>0 print '...debugging [imp_300013051001] end...'

end

