/******************************************************************************
**  Name: imp_100017011001
**  Desc: IKE Book/BISAC Subject
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

if exists (select * from dbo.sysobjects where id = object_id(N'[dbo].[imp_100017011001]') and OBJECTPROPERTY(id, N'IsProcedure') = 1)
drop procedure [dbo].[imp_100017011001]
GO

CREATE PROCEDURE dbo.imp_100017011001
  
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
  @v_SubjectSchemeIdentifier varchar(4000),
  @v_SubjectSchemeName varchar(4000),
  @v_SubjectHeadingText varchar(4000),
  @v_subjectcode varchar(100),
  @v_subjecttest varchar(100),
  @v_elementkey int,
  @v_mapkey int,
  @v_fromvalue varchar(100),
  @v_tovalue varchar(100),
  @v_count int

BEGIN
  set @v_errlevel=1
  set @v_msg='Book/BISAC Subject'
  --
  select @v_SubjectSchemeIdentifier=originalvalue
    from imp_batch_detail
    where batchkey=@i_batchkey
      and row_id=@i_row
      and elementkey=100017011
      and elementseq=@i_elementseq
  select @v_SubjectSchemeName=originalvalue
    from imp_batch_detail
    where batchkey=@i_batchkey
      and row_id=@i_row
      and elementkey=100017012
      and elementseq=@i_elementseq
  select @v_SubjectHeadingText=originalvalue
    from imp_batch_detail
    where batchkey=@i_batchkey
      and row_id=@i_row
      and elementkey=100017013
      and elementseq=@i_elementseq
  select @v_SubjectCode=originalvalue
    from imp_batch_detail
    where batchkey=@i_batchkey
      and row_id=@i_row
      and elementkey=100017014
      and elementseq=@i_elementseq

  if @v_SubjectSchemeIdentifier='10'  --BISAC subject
    begin
      insert into imp_batch_detail
        (batchkey,row_id,elementseq,elementkey,originalvalue,lastuserid,lastmaintdate)
        values
        (@i_batchkey,@i_row,@i_elementseq,100017001,@v_subjectcode ,@i_userid,getdate()) 
      set @v_msg='BISAC subject set by SubjectCode'
    end

  if @v_SubjectSchemeIdentifier='24'  --book subject
    begin
      select @v_mapkey=mapkey
        from imp_template_detail
        where elementkey=100017012
      set @v_mapkey=17012
      declare booksubjectmaps cursor fast_forward for 
        select from_value,to_value
          from imp_mapping
          where mapkey=@v_mapkey
      open booksubjectmaps
      fetch booksubjectmaps into @v_fromvalue,@v_tovalue
      while @@fetch_status=0 and @v_SubjectSchemeName=@v_fromvalue
        begin
          fetch booksubjectmaps into @v_fromvalue,@v_tovalue
        end
      if @v_SubjectSchemeName=@v_fromvalue
        begin
          set @v_elementkey=@v_tovalue
        end
      close booksubjectmaps
      deallocate booksubjectmaps
      if @v_tovalue is not null
        begin
          insert into imp_batch_detail
            (batchkey,row_id,elementseq,elementkey,originalvalue,lastuserid,lastmaintdate)
            values
            (@i_batchkey,@i_row,@i_elementseq,@v_tovalue,@v_subjectcode ,@i_userid,getdate()) 
          set @v_msg='Booksubject calculated from SubjectSchemeName'
          set @v_msg='Book subject set by SubjectCode'
        end
      else
        begin
          set @v_msg='No matching SubjectSchemeName defined in template'
        end
    end
  --
  IF @v_errlevel >= @i_level
    begin
     exec imp_write_feedback @i_batchkey, @i_row, @v_elementkey, @i_elementseq, @i_rulekey, @v_msg, @v_errlevel, 1
    end
  --
END

/*     END SPROC     */
END

GO
SET QUOTED_IDENTIFIER OFF 
GO
SET ANSI_NULLS ON 
GO

GRANT EXECUTE ON dbo.[imp_100017011001] to PUBLIC 
GO
