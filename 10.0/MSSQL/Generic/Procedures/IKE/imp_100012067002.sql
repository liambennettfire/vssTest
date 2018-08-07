/******************************************************************************
**  Name: imp_100012067002
**  Desc: IKE Sort AudienceRange into Age or Grade values
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

if exists (select * from dbo.sysobjects where id = object_id(N'[dbo].[imp_100012067002]') and OBJECTPROPERTY(id, N'IsProcedure') = 1)
drop procedure [dbo].[imp_100012067002]
GO

CREATE PROCEDURE dbo.imp_100012067002 
  
  @i_batchkey int,
  @i_row int,
--  @i_elementkey int,
  @i_elementseq int,
  @i_templatekey int,
  @i_rulekey bigint,
  @i_level int,
  @i_userid varchar(50)
AS

/* Sort AudienceRange into Age or Grade values */

BEGIN 

DECLARE  
  @v_errcode int,
  @v_errlevel int,
  @v_msg varchar(500),
  @v_qualifier varchar(4000),
  @v_precision varchar(4000),
  @v_value varchar(4000)
BEGIN
  set @v_errlevel=1
  set @v_errcode=1
  set @v_msg='additional data mapping'

  select @v_qualifier=originalvalue
    from imp_batch_detail
    where batchkey=@i_batchkey
      and row_id=@i_row
      and elementkey=100012067
      and elementseq=@i_elementseq
  select @v_precision=originalvalue
    from imp_batch_detail
    where batchkey=@i_batchkey
      and row_id=@i_row
      and elementkey=100012068
      and elementseq=@i_elementseq
  select @v_value=originalvalue
    from imp_batch_detail
    where batchkey=@i_batchkey
      and row_id=@i_row
      and elementkey=100012069
      and elementseq=@i_elementseq
  if @v_qualifier='11'  --grade
    begin
      if @v_precision='01' or @v_precision='03'  --exact or from
        begin
	      INSERT INTO imp_batch_detail
            (batchkey,row_id,elementkey,elementseq,originalvalue,lastuserid,lastmaintdate)
	        VALUES
            (@i_batchkey,@i_row,100012071,@i_elementseq,@v_value,'loader_rule_100012067002',getdate())
        end
      if @v_precision='01' or @v_precision='04'  --exact or to
        begin
	      INSERT INTO imp_batch_detail
            (batchkey,row_id,elementkey,elementseq,originalvalue,lastuserid,lastmaintdate)
	        VALUES
            (@i_batchkey,@i_row,100012072,@i_elementseq,@v_value,'loader_rule_100012067002',getdate())
        end
    end
  if @v_qualifier='18'
    begin
      if @v_precision='01' or @v_precision='03'  --exact or from
        begin
	      INSERT INTO imp_batch_detail
            (batchkey,row_id,elementkey,elementseq,originalvalue,lastuserid,lastmaintdate)
	        VALUES
            (@i_batchkey,@i_row,100012063,@i_elementseq,@v_value,'loader_rule_100012067002',getdate())
        end
      if @v_precision='01' or @v_precision='04'  --exact or to
        begin
	      INSERT INTO imp_batch_detail
            (batchkey,row_id,elementkey,elementseq,originalvalue,lastuserid,lastmaintdate)
	        VALUES
            (@i_batchkey,@i_row,100012064,@i_elementseq,@v_value,'loader_rule_100012067002',getdate())
        end
    end
    
END

end

GO
SET QUOTED_IDENTIFIER OFF 
GO
SET ANSI_NULLS ON 
GO

GRANT EXECUTE ON dbo.[imp_100012067002] to PUBLIC 
GO
