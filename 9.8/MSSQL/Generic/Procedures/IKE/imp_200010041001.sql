/******************************************************************************
**  Name: imp_200010041001
**  Desc: IKE Propigate from Title exists
**  Auth: Bennett     
**  Date: 5/9/2016
*******************************************************************************
**  Change History
*******************************************************************************
**  Date:        Author:     Description:
*   --------     --------    -------------------------------------------
**  5/9/2016     Bennett     original
*******************************************************************************/

SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

if exists (select * from dbo.sysobjects where id = object_id(N'[dbo].[imp_200010041001]') and OBJECTPROPERTY(id, N'IsProcedure') = 1)
drop procedure [dbo].[imp_200010041001]
GO

CREATE PROCEDURE [dbo].[imp_200010041001]
  
  @i_batch int,
  @i_row int,
  @i_elementkey int,
  @i_elementseq int,
  @i_templatekey int,
  @i_rulekey bigint,
  @i_rpt int
AS


DECLARE
  @v_elementval VARCHAR(4000),
  @v_errcode INT,
  @v_errlevel INT,
  @v_code INT,
  @v_msg VARCHAR(4000),
  @v_elementdesc VARCHAR(4000),
  @v_count int,
  @v_propagate_bookkey int,
  @v_double_propagate_bookkey int,
  @v_isbn9 VARCHAR(20)    

  SET @v_errlevel = 1
  SET @v_msg = 'Propigate from Title exists'

BEGIN

  SELECT @v_elementval =  COALESCE(originalvalue,'')
    FROM imp_batch_detail 
    WHERE batchkey = @i_batch
      AND row_id = @i_row
      AND elementseq = @i_elementseq
      AND elementkey = @i_elementkey

  select @v_count=count(*)
    from isbn
    where ean13=REPLACE(@v_elementval,'-','')
  if @v_count=0
    select @v_count=count(*)
      from isbn
      where isbn10=REPLACE(@v_elementval,'-','')

  if @v_count=1
    begin
      select @v_propagate_bookkey=bookkey
        from isbn
        where ean13=REPLACE(@v_elementval,'-','')
      if @v_propagate_bookkey is null
        select @v_propagate_bookkey=bookkey
          from isbn
          where isbn10=REPLACE(@v_elementval,'-','')
      exec qtitle_copy_work_info @v_propagate_bookkey,null,null,@v_code output,@v_msg output
    end
  else
    begin
      SET @v_errlevel = 3
      SET @v_msg = 'Propagate from Title ('+coalesce(@v_elementval,'n/a')+') does not exists'
      EXEC imp_write_feedback @i_batch, @i_row, @i_elementkey, @i_elementseq, @i_rulekey , @v_msg, @v_errlevel, 2
    END
    
  SET @v_double_propagate_bookkey=NULL  
  SELECT @v_double_propagate_bookkey=propagatefrombookkey
    from book
    WHERE @v_double_propagate_bookkey=@v_propagate_bookkey

  -- check for nested propigatation
  if @v_double_propagate_bookkey IS NOT NULL
    BEGIN
      SET @v_errlevel = 3
      SET @v_msg = 'Propagate from Title ('+coalesce(@v_elementval,'n/a')+') is already propigated. No nesting'
      EXEC imp_write_feedback @i_batch, @i_row, @i_elementkey, @i_elementseq, @i_rulekey , @v_msg, @v_errlevel, 2
    END

END
