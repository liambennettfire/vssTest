/******************************************************************************
**  Name: imp_100614057001
**  Desc: IKE Load bisac status and product availability
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

if exists (select * from dbo.sysobjects where id = object_id(N'[dbo].[imp_100614057001]') and OBJECTPROPERTY(id, N'IsProcedure') = 1)
drop procedure [dbo].[imp_100614057001]
GO

CREATE PROCEDURE dbo.imp_100614057001
  
  @i_batchkey int,
  @i_row int,
--  @i_elementkey int,
  @i_elementseq int,
  @i_templatekey int,
  @i_rulekey bigint,
  @i_level int,
  @i_userid varchar(50)
AS

BEGIN 
/*    START SPROC    */
DECLARE  
  @v_errcode int,
  @v_new_value varchar(4000),
  @v_errlevel int,
  @v_msg varchar(500),
  @v_bisacstatus  varchar(100), 
  @v_product_availability  varchar(100), 
  @v_elementkey int,
  @v_count int,
  @v_orgdesc_count int

BEGIN
  set @v_errlevel=1
  set @v_msg='Load bisac status and product availability'
  --
  select @v_bisacstatus =originalvalue
    from imp_batch_detail
    where batchkey=@i_batchkey
      and row_id=@i_row
      and elementkey=100614057
      and elementseq=@i_elementseq

  SELECT @v_product_availability =
      CASE @v_bisacstatus
         WHEN 'IP' THEN 'Available'
         WHEN 'NP' THEN 'Not Yet Available'
         WHEN 'TU' THEN 'Temporarily Unavailable'
         WHEN 'OI' THEN 'Accumulating Backorders'
         WHEN 'AB' THEN 'Cancelled'
         WHEN 'DEL' THEN 'Withdrawn From Sale'
         WHEN 'MD'  THEN 'Manufactured on Demand'
         WHEN 'WS'  THEN 'Withdrawn From Sale'
         WHEN 'OP'  THEN 'Unknown'
         ELSE NULL
      END 

  insert into imp_batch_detail
     (batchkey,row_id,elementseq,elementkey,originalvalue,lastuserid,lastmaintdate)
     values
     (@i_batchkey,@i_row,@i_elementseq,100014057,@v_bisacstatus,@i_userid,getdate()) 

  if @v_product_availability is not null
    begin
      insert into imp_batch_detail
        (batchkey,row_id,elementseq,elementkey,originalvalue,lastuserid,lastmaintdate)
        values
        (@i_batchkey,@i_row,@i_elementseq,100014059,@v_product_availability,@i_userid,getdate()) 
    end

  IF @v_errlevel >= @i_level
    begin
      exec imp_write_feedback @i_batchkey,@i_row,@v_elementkey,@i_elementseq,@i_rulekey,@v_msg,@v_errlevel,1
    END
  --
END

/*     END SPROC     */
END

GO
SET QUOTED_IDENTIFIER OFF 
GO
SET ANSI_NULLS ON 
GO

GRANT EXECUTE ON dbo.[imp_100614057001] to PUBLIC 
GO
