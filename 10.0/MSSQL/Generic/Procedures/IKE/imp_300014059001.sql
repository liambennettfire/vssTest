/******************************************************************************
**  Name: imp_300014059001
**  Desc: IKE Add/Replace Product Availability
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

if exists (select * from dbo.sysobjects where id = object_id(N'[dbo].[imp_300014059001]') and OBJECTPROPERTY(id, N'IsProcedure') = 1)
drop procedure [dbo].[imp_300014059001]
GO

CREATE PROCEDURE dbo.imp_300014059001 
  
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

/* Add/Replace Product Availability */

BEGIN 

DECLARE
  @v_bisacstatus    VARCHAR(4000),
  @v_prodavail    VARCHAR(4000),
  @v_errcode    INT,
  @v_errmsg     VARCHAR(4000),
  @v_elementdesc    VARCHAR(4000),
  @v_elementkey    BIGINT,
  @v_lobcheck     VARCHAR(20),
  @v_datacode     INT,
  @v_datasubcode     INT,
  @v_datasubcode_org     INT,
  @v_datadesc varchar(MAX),	
  @v_bookkey     INT,
  @v_printingkey     INT,
  @v_BisacStatuscode    INT,
  @v_hit      INT
  
BEGIN
  SET @v_hit = 0
  SET @v_BisacStatus = 0
  SET @v_BisacStatuscode = 0
  SET @o_writehistoryind = 0
  SET @v_errcode = 1
  SET @v_errmsg = 'Product Availability'
  SET @v_bookkey = dbo.resolve_keyset(@i_titlekeyset,1)

  SELECT @v_bisacstatus = LTRIM(RTRIM(originalvalue))
    FROM imp_batch_detail 
    WHERE batchkey = @i_batch
      AND row_id = @i_row
      AND elementseq = @i_elementseq
      AND elementkey = 100014057

  exec dbo.find_gentables_mixed  @v_bisacstatus,314,@v_datacode output,@v_datadesc output
        
  SELECT @v_prodavail = LTRIM(RTRIM(originalvalue))
    FROM imp_batch_detail 
    WHERE batchkey = @i_batch
      AND row_id = @i_row
      AND elementseq = @i_elementseq
      AND elementkey = 100014059
  
  exec dbo.find_subgentables_mixed @v_prodavail,314,@v_datacode output,@v_datasubcode output,@v_datadesc output
        
  select @v_datasubcode_org=prodavailability
    from bookdetail
    where bookkey=@v_bookkey
    
  if coalesce(@v_datasubcode,-1)<>coalesce(@v_datasubcode_org,-1)
    begin
      update bookdetail
        set
          prodavailability=@v_datasubcode,
          lastuserid=@i_userid,
          lastmaintdate=getdate()
        where bookkey=@v_bookkey
      SET @o_writehistoryind = 1
      SET @v_errmsg = 'Product Availability updated'
    end
  else
    begin
      SET @v_errmsg = 'Product Availability unchanged'
    end

  IF @v_errcode < 2
    BEGIN
      EXECUTE imp_write_feedback @i_batch, @i_row, @v_elementkey, @i_elementseq ,@i_dmlkey , @v_errmsg, @i_level, 3 
    END
END

end

GO
SET QUOTED_IDENTIFIER OFF 
GO
SET ANSI_NULLS ON 
GO

GRANT EXECUTE ON dbo.[imp_300014059001] to PUBLIC 
GO
