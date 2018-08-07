/******************************************************************************
**  Name: imp_200013026001
**  Desc: IKE Currency Type Validation
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

if exists (select * from dbo.sysobjects where id = object_id(N'[dbo].[imp_200013026001]') and OBJECTPROPERTY(id, N'IsProcedure') = 1)
drop procedure [dbo].[imp_200013026001]
GO

CREATE PROCEDURE dbo.imp_200013026001 
  
  @i_batch int,
  @i_row int,
  @i_elementkey int,
  @i_elementseq int,
  @i_templatekey int,
  @i_rulekey bigint,
  @i_rpt int
AS

/* Currency Type Validation */

BEGIN 

DECLARE @v_elementval     VARCHAR(4000),
  @v_errlevel     INT,
  @v_errmsg     VARCHAR(4000),
  @v_elementdesc     VARCHAR(4000),
  @v_row_count    INT,
  @v_datacode int,
  @v_datadesc varchar(MAX)
BEGIN
  SET @v_errlevel = 0
  SET @v_row_count = 0

  SELECT @v_elementdesc = elementdesc
    FROM imp_element_defs
    WHERE elementkey =  @i_elementkey

  SELECT @v_elementval = originalvalue
    FROM imp_batch_detail 
    WHERE  batchkey = @i_batch
      AND row_id = @i_row
      AND elementkey =  @i_elementkey
      AND elementseq =  @i_elementseq

  exec find_gentables_mixed @v_elementval,122,@v_datacode output,@v_datadesc output

  if @v_datacode is null
    BEGIN
      SET @v_errlevel = 2
      SET @v_errmsg = 'Can not find ('+@v_elementval+') value on  User Table(122) for '+@v_elementdesc
    END
  ELSE
    BEGIN
      SET @v_errmsg = 'Currency Type OK'
      SET @v_errlevel = 1
    END

  IF @v_errlevel >= @i_rpt
    BEGIN
      EXECUTE imp_write_feedback @i_batch, @i_row, @i_elementkey, @i_elementseq, @i_rulekey , @v_errmsg, @v_errlevel, 2
    END
  
END

end

GO
SET QUOTED_IDENTIFIER OFF 
GO
SET ANSI_NULLS ON 
GO

GRANT EXECUTE ON dbo.[imp_200013026001] to PUBLIC 
GO
