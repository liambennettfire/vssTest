/******************************************************************************
**  Name: imp_200000000011
**  Desc: IKE Field is a valid date
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

if exists (select * from dbo.sysobjects where id = object_id(N'[dbo].[imp_200000000011]') and OBJECTPROPERTY(id, N'IsProcedure') = 1)
drop procedure [dbo].[imp_200000000011]
GO

CREATE PROCEDURE dbo.imp_200000000011 
  
  @i_batch int,
  @i_row int,
  @i_elementkey int,
  @i_elementseq int,
  @i_templatekey int,
  @i_rulekey bigint,
  @i_rpt int
AS

/* Field is a valid date */

BEGIN 

/* STANDARD BATCH VARIABLES  */
DECLARE  
  @v_elementval     varchar(4000),
  @v_errcode        int,
  @v_errlevel       int,
  @v_msg            varchar(4000),
  @v_elementdesc    varchar(4000),
  @v_date           datetime,
  @i_errlevel       int

  set @v_elementdesc = dbo.imp_get_element_desc(@i_elementkey)
  set @v_elementval = dbo.imp_get_originalvalue(@i_batch,@i_row,@i_elementkey,@i_elementseq)
  set @v_errlevel = 1
  set @v_msg = @v_elementdesc + ' is a valid date'
  --
  set @v_date = dbo.resolve_date(@v_elementval)
  if @v_date is null 
    begin
      set @v_errlevel = 2
      set @v_msg = @v_elementdesc + ' is an invalid date'
    end
  --
  IF @v_errlevel >= @i_errlevel 
    begin
      exec imp_write_feedback @i_batch, @i_row, @i_elementkey, @i_elementseq, @i_rulekey , @v_msg, @v_errlevel, 2
    END
END


GO
SET QUOTED_IDENTIFIER OFF 
GO
SET ANSI_NULLS ON 
GO

GRANT EXECUTE ON dbo.[imp_200000000011] to PUBLIC 
GO
