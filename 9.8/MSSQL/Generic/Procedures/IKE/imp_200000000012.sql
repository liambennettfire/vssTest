/******************************************************************************
**  Name: imp_200000000012
**  Desc: IKE Gentable exists by datadesc using element tableid
**  Auth: Bennett     
**  Date: 5/9/2016
*******************************************************************************
**  Change History
*******************************************************************************
**  Date:        Author:     Description:
*   --------     --------    -------------------------------------------
**  5/9/2016     Bennett     original
**  5/19/16      Kusum       Case 37304 - increased size of datadesc VARCHAR(MAX) 
**                           to allow for alternatedesc1
*******************************************************************************/

SET QUOTED_IDENTIFIER ON 
GO
SET ANSI_NULLS ON 
GO

if exists (select * from dbo.sysobjects where id = object_id(N'[dbo].[imp_200000000012]') and OBJECTPROPERTY(id, N'IsProcedure') = 1)
drop procedure [dbo].[imp_200000000012]
GO

CREATE PROCEDURE dbo.imp_200000000012 
  
  @i_batch int,
  @i_row int,
  @i_elementkey int,
  @i_elementseq int,
  @i_templatekey int,
  @i_rulekey bigint,
  @i_rpt int
AS

/* Gentable exists by datadesc using element tableid */

BEGIN 
DECLARE
  @v_elementdesc     VARCHAR(4000),
  @v_elementval     VARCHAR(4000),
  @v_tabledesc     VARCHAR(100),
  @v_datacode     INT,
  @v_datadesc     varchar(MAX),
  @v_elementseq     INT,
  @v_tableid     INT,
  @v_errcode     INT,
  @v_errlevel     INT,
  @v_msg       VARCHAR(4000),
  @v_gentables_desc varchar(500)
  
begin

  SELECT @v_elementval=b.originalvalue,@v_tableid=ed.tableid
    FROM  imp_batch_detail b, imp_element_defs ed
    WHERE b.batchkey = @i_batch
      AND b.row_id = @i_row
      AND b.elementseq = @i_elementseq
      and b.elementkey=@i_elementkey
      and b.elementkey=ed.elementkey
     
  set @v_msg=' '
  set @v_errlevel = 1
  
  exec find_gentables_mixed @v_elementval,@v_tableid,@v_datacode output,@v_datadesc output
  select @v_gentables_desc=tabledesclong from gentablesdesc where tableid=@v_tableid

  if @v_datacode is null and @v_tableid is not null
    begin
      set @v_errlevel=2
      set @v_msg='Can not find ['+@v_elementval+'] in use table '+@v_gentables_desc+' (ID '+cast(@v_tableid as varchar)+')'
      EXECUTE imp_write_feedback @i_batch, @i_row, @i_elementkey, @i_elementseq, @i_rulekey , @v_msg, @v_errlevel, 2
    end

END

end

GO
SET QUOTED_IDENTIFIER OFF 
GO
SET ANSI_NULLS ON 
GO

GRANT EXECUTE ON dbo.[imp_200000000012] to PUBLIC 
GO

