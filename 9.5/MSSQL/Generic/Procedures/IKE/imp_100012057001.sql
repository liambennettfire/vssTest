/******************************************************************************
**  Name: imp_100012057001
**  Desc: IKE Remove Media on condition
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

if exists (select * from dbo.sysobjects where id = object_id(N'[dbo].[imp_100012057001]') and OBJECTPROPERTY(id, N'IsProcedure') = 1)
drop procedure [dbo].[imp_100012057001]
GO

CREATE PROCEDURE dbo.imp_100012057001 
  
  @i_batchkey int,
  @i_row int,
--  @i_elementkey int,
  @i_elementseq int,
  @i_templatekey int,
  @i_rulekey bigint,
  @i_level int,
  @i_userid varchar(50)
AS

/* Remove Media on condition */

BEGIN 

DECLARE  
  @v_errcode int,
  @v_errlevel int,
  @v_msg varchar(500),
  @v_addlqualifier varchar(4000),
  @v_orgvalue varchar(4000),
  @v_mediavalue varchar(4000),
  @v_formatvalue varchar(4000),
  @v_elementseq int,
  @v_elementkey int,
  @v_target_elementkey int,
  @v_mapkey int,
  @v_pntr int,
  @v_count int
BEGIN
  set @v_errlevel=1
  set @v_errcode=1
  set @v_msg='additional data mapping'

  select @v_mediavalue=originalvalue
    from imp_batch_detail
    where batchkey=@i_batchkey
      and row_id=@i_row
      and elementkey=100012051
  select @v_formatvalue=originalvalue
    from imp_batch_detail
    where batchkey=@i_batchkey
      and row_id=@i_row
      and elementkey=100012050
  select @v_mapkey=mapkey
    from imp_template_detail
    where templatekey=@i_templatekey
      and elementkey=100012057
  if @v_mediavalue is not null and @v_formatvalue is not null and @v_mapkey is not null 
    begin
      select @v_count=count(*)
        from imp_mapping
        where mapkey=@v_mapkey
          and from_value=@v_mediavalue
          and to_value=@v_formatvalue
      if @v_count=1
        begin
          delete from imp_batch_detail
            where batchkey=@i_batchkey
              and row_id=@i_row
              and elementkey=100012051
          set @v_msg='Removing Media element. It will be inferred from the format value'
          exec imp_write_feedback @i_batchkey, @i_row, @v_elementkey, @i_elementseq, @i_rulekey, @v_msg, @v_errlevel, 1
        end
    end
    
END

end

GO
SET QUOTED_IDENTIFIER OFF 
GO
SET ANSI_NULLS ON 
GO

GRANT EXECUTE ON dbo.[imp_100012057001] to PUBLIC 
GO
