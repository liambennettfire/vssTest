/******************************************************************************
**  Name: imp_load_inserts
**  Desc: IKE inserts elements based on template
**  Auth: Bennett     
**  Date: 5/9/2016
*******************************************************************************
**  Change History
*******************************************************************************
**  Date:        Author:     Description:
*   --------     --------    -------------------------------------------
**  5/9/2016     Bennett     original
*******************************************************************************/

if exists (select * from dbo.sysobjects where id = object_id(N'[dbo].[imp_load_inserts]') and OBJECTPROPERTY(id, N'IsProcedure') = 1)
drop procedure [dbo].[imp_load_inserts]
GO

SET QUOTED_IDENTIFIER ON 
GO
SET ANSI_NULLS ON 
GO

CREATE PROCEDURE imp_load_inserts
  @i_batchkey int,
  @i_templatekey int,
  @i_userid varchar(50),
  @o_errcode int output,
  @o_errmsg varchar(500) output
AS

DECLARE
  @v_row_inserts int,
  @v_seq_inserts int,
  @v_rowcnt int,
  @v_row_id varchar(20),
  @v_elementkey int,
  @v_elementseq int,
  @v_row_ins_seq int,
  @v_exists int,
  @v_row_count int,
  @v_seq_count int,
  @v_defaultvalue VARCHAR(4000),
  @v_RowInsertSeqNumber as int
            
BEGIN
  select @v_row_inserts = count(*)
    from imp_template_detail
    where rowinsertind = 1
      and templatekey = @i_templatekey 
  select @v_seq_inserts = count(*)
    from imp_template_detail
    where seqinsertind = 1
      and templatekey = @i_templatekey 

  if @v_row_inserts > 0 or @v_seq_inserts > 0
    begin
      declare rows_cur cursor for 
        select distinct row_id
          from imp_batch_detail
          where batchkey = @i_batchkey
          order by row_id
      open rows_cur 
      fetch rows_cur into @v_row_id
      while @@fetch_status = 0
        begin

          declare row_inserts cursor for 
            select distinct elementkey,defaultvalue
              from imp_template_detail
              where coalesce(rowinsertind,-99) >= 0
                and templatekey = @i_templatekey 
          open row_inserts 
          fetch row_inserts into @v_elementkey,@v_defaultvalue
          while @@fetch_status = 0
            begin
              select @v_row_count = count(*)
                from imp_batch_detail
                where batchkey=@i_batchkey
                  and row_id=@v_row_id
                  and elementkey=@v_elementkey
              if @v_row_count  = 0
                begin
                  -- using rowinsertind to determine which seq number to insert under
                  --  some rule need to fire first and some last
                  --  -set the rowinsertind in the tempate
                  
					--New code to parse XML data ni the new XMLQualifier Field
					IF EXISTS (
							SELECT *
							FROM dbo.sysobjects
							WHERE id = object_id(N'[dbo].[sp_XMLNodeValue_GET]')
								AND OBJECTPROPERTY(id, N'IsProcedure') = 1
							)
					BEGIN
						declare @WHERE as varchar(256)
						set @WHERE ='WHERE ElementKey='+CAST(@v_elementkey as varchar(256))+' and templatekey = ' + CAST(@i_templatekey as varchar(256))
						EXEC sp_XMLNodeValue_GET 'imp_template_detail','XMLQualifier',@WHERE , 'RowInsertSeqNumber', @v_RowInsertSeqNumber OUTPUT 
					END
                  
                  IF @v_RowInsertSeqNumber is NULL 
                  BEGIN
					  select @v_row_ins_seq=coalesce(rowinsertind,1)
						from imp_template_detail
						where templatekey = @i_templatekey 
						  and elementkey=@v_elementkey
                  END
                  ELSE
                  BEGIN
					SET @v_row_ins_seq=@v_RowInsertSeqNumber
                  END
                  insert into imp_batch_detail
                    (batchkey,row_id,elementseq,elementkey,originalvalue,lastuserid,lastmaintdate)
                    values
                    (@i_batchkey,@v_row_id,@v_row_ins_seq,@v_elementkey,@v_defaultvalue,@i_userid,getdate())
                end
              fetch row_inserts into @v_elementkey,@v_defaultvalue
            end
          close row_inserts 
          deallocate row_inserts 

          if @v_seq_inserts > 0
            begin
              declare seq_cur cursor for 
                select distinct elementseq
                  from imp_batch_detail
                  where batchkey = @i_batchkey
                    and row_id = @v_row_id
                  order by elementseq
              open seq_cur 
              fetch seq_cur into @v_elementseq
              while @@fetch_status = 0
                begin

                  declare seq_inserts cursor for 
                    select distinct elementkey,defaultvalue
                      from imp_template_detail
                      where seqinsertind = 1
                        and templatekey = @i_templatekey
                  open seq_inserts 
                  fetch seq_inserts into @v_elementkey,@v_defaultvalue
                  while @@fetch_status = 0
                    begin
                      select @v_seq_count = count(*)
                        from imp_batch_detail
                        where batchkey=@i_batchkey
                          and row_id=@v_row_id
                          and elementkey=@v_elementkey
                          and elementseq=@v_elementseq
                      if @v_seq_count = 0
                        begin
                          insert into imp_batch_detail
                            (batchkey,row_id,elementseq,elementkey,originalvalue,lastuserid,lastmaintdate)
                            values
							(@i_batchkey,@v_row_id,@v_elementseq,@v_elementkey,@v_defaultvalue ,@i_userid,getdate())
                        end
                      fetch seq_inserts into @v_elementkey,@v_defaultvalue
                    end
                  close seq_inserts 
                  deallocate seq_inserts 

                  fetch seq_cur into @v_elementseq
                end

              close seq_cur 
              deallocate seq_cur 
            end

         fetch rows_cur into @v_row_id
       end
      close rows_cur 
      deallocate rows_cur 
    end

END
GO

SET QUOTED_IDENTIFIER OFF 
GO
SET ANSI_NULLS ON 
GO
