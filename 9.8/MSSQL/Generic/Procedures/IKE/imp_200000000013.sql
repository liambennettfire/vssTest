/******************************************************************************
**  Name: imp_200000000013
**  Desc: IKE Subgentable exists by datadesc using element tableid
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

if exists (select * from dbo.sysobjects where id = object_id(N'[dbo].[imp_200000000013]') and OBJECTPROPERTY(id, N'IsProcedure') = 1)
drop procedure [dbo].[imp_200000000013]
GO

CREATE PROCEDURE dbo.imp_200000000013 
  
  @i_batch int,
  @i_row int,
  @i_elementkey int,
  @i_elementseq int,
  @i_templatekey int,
  @i_rulekey bigint,
  @i_rpt int
AS

/* Subgentable exists by datadesc using element tableid */

BEGIN 

DECLARE
  @v_elementdesc     VARCHAR(4000),
  @v_elementval     VARCHAR(4000),
  @v_tabledesc     VARCHAR(100),
  @v_tableid     INT,
  @v_errcode     INT,
  @v_errlevel     INT,
  @v_msg       VARCHAR(4000),
    @v_datacode  INT,
    @v_count1  INT,
    @v_count2  INT
begin
  SELECT 
      @v_elementdesc = elementdesc,
      @v_tableid = tableid
    FROM imp_element_defs
    WHERE elementkey =  @i_elementkey

  SELECT @v_elementval = COALESCE(originalvalue,'')
    FROM imp_batch_detail 
    WHERE  batchkey = @i_batch
      AND row_id = @i_row
      AND elementkey =  @i_elementkey
      AND elementseq =  @i_elementseq
  set @v_errlevel = 1
  
  select @v_count1 = count(*)
    from subgentables
    where tableid=@v_tableid
      and (datadesc=@v_elementval OR externalcode=@v_elementval)
  if @v_count1=0
    begin
      select @v_tabledesc=tabledesclong
        from gentablesdesc
        where tableid=@v_tableid
      set @v_errlevel=2
      set @v_msg='Can not find ['+@v_elementval+'] in use sub table '+cast(@v_tableid as varchar)+' - '+@v_tabledesc
      EXECUTE imp_write_feedback @i_batch, @i_row, @i_elementkey, @i_elementseq, @i_rulekey , @v_msg, @v_errlevel, 2
    end
END

end

GO
SET QUOTED_IDENTIFIER OFF 
GO
SET ANSI_NULLS ON 
GO

GRANT EXECUTE ON dbo.[imp_200000000013] to PUBLIC 
GO
