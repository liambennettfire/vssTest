/******************************************************************************
**  Name: imp_200020101001
**  Desc: IKE GenericDate addlqualifier definition check
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

if exists (select * from dbo.sysobjects where id = object_id(N'[dbo].[imp_200020101001]') and OBJECTPROPERTY(id, N'IsProcedure') = 1)
drop procedure [dbo].[imp_200020101001]
GO

CREATE PROCEDURE dbo.imp_200020101001 
  
  @i_batch int,
  @i_row int,
  @i_elementkey int,
  @i_elementseq int,
  @i_templatekey int,
  @i_rulekey bigint,
  @i_rpt int
AS

/* GenericDate addlqualifier definition check */

BEGIN 

DECLARE
  @v_addlqualifier     VARCHAR(500),
  @v_elementseq     INT,
  @v_errcode     INT,
  @v_errlevel     INT,
  @v_msg       VARCHAR(4000),
  @v_act_est       VARCHAR(40),
  @v_datetype  varchar(40),
  @v_datetypecode  INT,
  @v_count  INT,
  @v_pntr  INT
begin

  SELECT @v_addlqualifier=td.addlqualifier
    FROM  imp_template_detail td
    WHERE td.templatekey=@i_templatekey
      and td.elementkey=@i_elementkey
  
  set @v_msg=' '
  set @v_errlevel = 1
  set @v_errcode=1
      
  if @v_addlqualifier is not null and @v_errcode=1
    begin
      set @v_act_est=substring(@v_addlqualifier,1,3)
      set @v_pntr=charindex(',',@v_addlqualifier)
    end
  else
    begin
      set @v_errcode=2
    end
  if @v_act_est not in ('est','act') and @v_errcode=1
    begin
      set @v_errcode=2
    end
  if @v_pntr>0 and @v_errcode=1
    begin
      set @v_datetype=substring(@v_addlqualifier,@v_pntr+1,10)
    end
  else
    begin
      set @v_errcode=2
    end
  if isnumeric(@v_datetype)=1 and @v_errcode=1
    begin
      set @v_datetypecode=cast(@v_datetype as int)
    end
  else
    begin
      set @v_errcode=2
    end
  if isnumeric(@v_datetype)=1 and @v_errcode=1
    begin
      select @v_count = count(*)
        from datetype
        where datetypecode=@v_datetypecode 
      if @v_count=0
        begin
          set @v_errlevel=2
        end
    end
  if @v_errcode=2
    begin
      set @v_msg='Invalid addlqualifier ['+coalesce(@v_addlqualifier,'n/a')+'] defined in template'
      EXECUTE imp_write_feedback @i_batch, @i_row, @i_elementkey, @i_elementseq, @i_rulekey , @v_msg, @v_errlevel, 2
    end
  
END

end

GO
SET QUOTED_IDENTIFIER OFF 
GO
SET ANSI_NULLS ON 
GO

GRANT EXECUTE ON dbo.[imp_200020101001] to PUBLIC 
GO
