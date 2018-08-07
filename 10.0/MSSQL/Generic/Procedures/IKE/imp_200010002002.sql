/******************************************************************************
**  Name: imp_200010002002
**  Desc: IKE  ISBN13 LENGTH CHECK
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

if exists (select * from dbo.sysobjects where id = object_id(N'[dbo].[imp_200010002002]') and OBJECTPROPERTY(id, N'IsProcedure') = 1)
drop procedure [dbo].[imp_200010002002]
GO

CREATE PROCEDURE dbo.imp_200010002002
  
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
  @v_checkdigit_org CHAR(1),
  @v_isbn13_nodashes VARCHAR(20),    
  @v_isbn13body VARCHAR(20)    

  SET @v_errlevel = 1
  SET @v_msg = 'ISBN 13 has the correct check digit'

  BEGIN

    SELECT @v_elementval =  COALESCE(originalvalue,'')
    FROM imp_batch_detail 
    WHERE batchkey = @i_batch
        AND row_id = @i_row
        AND elementseq = @i_elementseq
        AND elementkey = @i_elementkey

  set @v_isbn13_nodashes=replace(@v_elementval,'-','')

  IF LEN(@v_isbn13_nodashes)<> 13
    BEGIN      
      SET @v_msg = 'ISBN13 is not the proper length. Can not calculate check digit'      
      SET @v_errlevel = 3     
    END
  else
    begin
      set @v_isbn13body=substring(@v_isbn13_nodashes,1,12)
      set @v_checkdigit_org=substring(@v_isbn13_nodashes,13,1)
      exec dbo.qean_generate_check_digit @v_isbn13body,@v_checkdigit output,1
      if @v_checkdigit_org<>@v_checkdigit
        begin
          SET @v_msg = 'ISBN13 has an invalid check digit'      
          SET @v_errlevel = 3     
        end
    end

  IF @v_errlevel >= @i_rpt
    BEGIN
      EXECUTE imp_write_feedback @i_batch, @i_row, @i_elementkey, @i_elementseq, @i_rulekey , @v_msg, @v_errlevel, 2
    END

END

go

