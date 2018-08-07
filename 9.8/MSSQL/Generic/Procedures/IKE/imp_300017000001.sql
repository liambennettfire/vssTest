/******************************************************************************
**  Name: imp_300017000001
**  Desc: IKE BISAC SUBJECTS 
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

if exists (select * from dbo.sysobjects where id = object_id(N'[dbo].[imp_300017000001]') and OBJECTPROPERTY(id, N'IsProcedure') = 1)
drop procedure [dbo].[imp_300017000001]
GO

CREATE PROCEDURE dbo.imp_300017000001 
  
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

/* DEFINE BATCH VARIABLES    */
DECLARE @v_elementval    VARCHAR(4000),
  @v_errcode    INT,
  @v_errmsg     VARCHAR(4000),
  @v_elementdesc    VARCHAR(4000),
  @v_elementkey    BIGINT,
  @v_lobcheck     VARCHAR(20),
  @v_lobkey     INT,
  @v_bookkey     INT,
  @v_printingkey     INT,
  @v_hit      INT,
  @v_count      INT,
  @v_sortorder    INT,
  @v_bisaccategorycode    INT,
  @v_bisaccategorysubcode    INT,
  @v_rowcount    INT,
  @v_subjectcode    INT,
  @v_subjectsubcode  INT,
  @v_datadesc  varchar(40),
  @v_NEW_sortorder    INT
  

BEGIN
  SET @v_hit = 0
  SET @v_sortorder = 1
  SET @v_bisaccategorycode = 0
  SET @v_bisaccategorysubcode = 0
  SET @v_rowcount = 0
  SET @o_writehistoryind = 0
  SET @v_errcode = 1
  SET @v_errmsg = 'BISAC Subjects'
  SET @v_bookkey = dbo.resolve_keyset(@i_titlekeyset,1)
  SET @v_printingkey = dbo.resolve_keyset(@i_titlekeyset,2)

/*  GET IMPORTED BISAC SUBJECTS       */
  SELECT
      @v_elementval =  LTRIM(RTRIM(originalvalue)),
      @v_elementkey = b.elementkey
    FROM imp_batch_detail b , imp_DML_elements d
    WHERE b.batchkey = @i_batch
      AND b.row_id = @i_row
      AND b.elementseq = @i_elementseq
      AND d.dmlkey = @i_dmlkey
      AND d.elementkey = b.elementkey

/* FIND IMPORT BISAC SUBJECTS ON GENTABLES     */  

  exec find_subgentables_mixed @v_elementval,339,@v_subjectcode output,@v_subjectsubcode output,@v_datadesc output

  IF @v_subjectcode is not null and  @v_subjectsubcode is not null
    BEGIN
      select @v_count=count(*)
        from bookbisaccategory
        where bookkey=@v_bookkey
          and printingkey=@v_printingkey
          and bisaccategorycode=@v_subjectcode
          and bisaccategorysubcode=@v_subjectsubcode
      
      if @v_count=0
        begin
          SELECT @v_sortorder = COALESCE(MAX(sortorder),0)
            FROM bookbisaccategory
            WHERE bookkey = @v_bookkey
          SET @v_sortorder = @v_sortorder+1
          INSERT INTO bookbisaccategory(bookkey,printingkey,bisaccategorycode,bisaccategorysubcode,sortorder,lastuserid,lastmaintdate)
            VALUES(@v_bookkey,1,@v_subjectcode,@v_subjectsubcode,@v_sortorder,@i_userid,GETDATE())
          SET @v_errmsg = 'BISAC Subjects updated'
          SET @o_writehistoryind = 1
        end
	
	  -- make sure the sort orders are correct 
	  -- ... The sort order list will always be rebuild from 1 =
	  -- ... (current value that may or may not have been there) to @v_count
	  
	  select @v_count=count(*)
	  from bookbisaccategory
	  where bookkey=@v_bookkey
		and printingkey=@v_printingkey	  
	  
      if @v_count>1
		begin
			declare cur_bookbisaccategory cursor for 
				select 
					bisaccategorycode
					,bisaccategorysubcode
					,sortorder
				from bookbisaccategory
				where bookkey=@v_bookkey
					and printingkey=@v_printingkey			
				order by sortorder desc
			open cur_bookbisaccategory 
			fetch cur_bookbisaccategory into @v_bisaccategorycode,@v_bisaccategorysubcode,@v_sortorder
			while @@fetch_status=0 		
				begin
					if @v_bisaccategorycode=@v_subjectcode AND @v_bisaccategorysubcode=@v_subjectsubcode 
						set @v_NEW_sortorder = 1
					else	
						begin
							set @v_NEW_sortorder = @v_count
							set @v_count=@v_count-1
						end
						
					update bookbisaccategory set sortorder = @v_NEW_sortorder
					where bookkey=@v_bookkey
					  and printingkey=@v_printingkey
					  and bisaccategorycode=@v_bisaccategorycode
					  and bisaccategorysubcode=@v_bisaccategorysubcode

					fetch cur_bookbisaccategory into @v_bisaccategorycode,@v_bisaccategorysubcode,@v_sortorder
				end
			close cur_bookbisaccategory
			deallocate cur_bookbisaccategory
		end        
    END

  IF @v_errcode < 2
    BEGIN
      EXECUTE imp_write_feedback @i_batch, @i_row, @v_elementkey, @i_elementseq ,@i_dmlkey , @v_errmsg, @i_level, 3     
    END
    
END

GO
SET QUOTED_IDENTIFIER OFF 
GO
SET ANSI_NULLS ON 
GO

GRANT EXECUTE ON dbo.[imp_300017000001] to PUBLIC 
GO
