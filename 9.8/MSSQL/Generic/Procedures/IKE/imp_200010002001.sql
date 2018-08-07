/******************************************************************************
**  Name: imp_200010002001
**  Desc: IKE ISBN13 LENGTH CHECK
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

if exists (select * from dbo.sysobjects where id = object_id(N'[dbo].[imp_200010002001]') and OBJECTPROPERTY(id, N'IsProcedure') = 1)
drop procedure [dbo].[imp_200010002001]
GO

CREATE PROCEDURE dbo.imp_200010002001
  
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
  @v_msg VARCHAR(4000),
  @v_elementdesc VARCHAR(4000),
  @v_checkdigit CHAR(1),
  @v_isbn9 VARCHAR(20)    

  SET @v_errlevel = 1
  SET @v_msg = 'ISBN 13 has the correct length'

  BEGIN

    SELECT @v_elementval =  COALESCE(originalvalue,'')
    FROM imp_batch_detail 
    WHERE batchkey = @i_batch
        AND row_id = @i_row
        AND elementseq = @i_elementseq
        AND elementkey = @i_elementkey

/*  VERIFY THAT THE ISBN13 HAS TEN CHARACTERS  */
  IF LEN(replace(@v_elementval,'-',''))<> 13
    BEGIN      
      SET @v_msg = 'ISBN13 is not the proper length.'      
      SET @v_errlevel = 3     
    END

  IF @v_errlevel >= @i_rpt
    BEGIN
      EXECUTE imp_write_feedback @i_batch, @i_row, @i_elementkey, @i_elementseq, @i_rulekey , @v_msg, @v_errlevel, 2
    END

END
go
