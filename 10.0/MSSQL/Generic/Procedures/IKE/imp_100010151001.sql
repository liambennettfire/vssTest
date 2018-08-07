/******************************************************************************
**  Name: imp_100010151001
**  Desc: IKE Map data value
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

if exists (select * from dbo.sysobjects where id = object_id(N'[dbo].[imp_100010151001]') and OBJECTPROPERTY(id, N'IsProcedure') = 1)
drop procedure [dbo].[imp_100010151001]
GO

CREATE PROCEDURE dbo.imp_100010151001 
  
  @i_batchkey int,
  @i_row int,
--  @i_elementkey int,
  @i_elementseq int,
  @i_templatekey int,
  @i_rulekey bigint,
  @i_level int,
  @i_userid varchar(50)
AS

/* Map data value */

BEGIN 

DECLARE  
  @v_errcode int,
  @v_errlevel int,
  @v_msg varchar(500),
  @v_addlqualifier varchar(4000),
  @v_orgvalue varchar(4000),
  @v_fromvalue varchar(4000),
  @v_tovalue varchar(4000),
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
  set @v_elementkey=100010151
  set @v_pntr=0
  SELECT @v_addlqualifier=td.addlqualifier
    FROM  imp_template_detail td
    WHERE td.templatekey=@i_templatekey
      and td.elementkey=@v_elementkey
  if @v_addlqualifier is not null and @v_errcode=1
    begin
      set @v_pntr=charindex(',',@v_addlqualifier)
    end
  else
    begin
      set @v_errcode=2
    end
  if @v_pntr>0 and @v_errcode=1
    begin
      set @v_target_elementkey=dbo.resolve_keyset(@v_addlqualifier,1)
      set @v_mapkey=dbo.resolve_keyset(@v_addlqualifier,2)
    end
  else
    begin
      set @v_errcode=2
    end
  if @v_errcode=1 and @v_mapkey is not null
    begin
      declare c_elementseqs cursor for
        select elementseq
          from imp_batch_detail
          where batchkey=@i_batchkey
            and row_id=@i_row
            and elementkey=@v_target_elementkey
      open c_elementseqs
      fetch c_elementseqs into @v_elementseq
      while @@fetch_status=0
        begin
          select @v_orgvalue=originalvalue
            from imp_batch_detail
            where batchkey=@i_batchkey
              and row_id=@i_row
              and elementseq=@v_elementseq
              and elementkey=@v_target_elementkey
          select @v_count=count(*)
            from imp_mapping
            where mapkey=@v_mapkey
              and from_value=@v_orgvalue
          if @v_count=1
            begin
              select @v_tovalue=to_value
                from imp_mapping
                where mapkey=@v_mapkey
                  and from_value=@v_orgvalue
              update imp_batch_detail
                set originalvalue=@v_tovalue
                where batchkey=@i_batchkey
                  and row_id=@i_row
                  and elementseq=@v_elementseq
                  and elementkey=@v_target_elementkey
            end
          fetch c_elementseqs into @v_elementseq
        end
      close c_elementseqs
      deallocate c_elementseqs
    end

  --IF @v_errlevel >= @i_level 
  --  begin
      exec imp_write_feedback @i_batchkey, @i_row, @v_elementkey, @i_elementseq, @i_rulekey, @v_msg, @v_errlevel, 1
  --  end
END

end

GO
SET QUOTED_IDENTIFIER OFF 
GO
SET ANSI_NULLS ON 
GO

GRANT EXECUTE ON dbo.[imp_100010151001] to PUBLIC 
GO
