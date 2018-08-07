SET QUOTED_IDENTIFIER ON 
GO
SET ANSI_NULLS ON 
GO

/******************************************************************************
**  Name: imp_seq_check
**  Desc: IKE 
**  Auth: Bennett     
**  Date: 5/9/2016
*******************************************************************************
**  Change History
*******************************************************************************
**  Date:        Author:     Description:
*   --------     --------    -------------------------------------------
**  5/9/2016     Bennett     original
**  11/2/2016    Bennett     add EAN13 to exception list
*******************************************************************************/

if exists (select * from dbo.sysobjects where id = object_id(N'[dbo].[imp_seq_check]') and OBJECTPROPERTY(id, N'IsProcedure') = 1)
drop procedure [dbo].[imp_seq_check]
GO


CREATE PROCEDURE imp_seq_check
  @i_columnname varchar(100),
  @i_templatekey int,
  @o_column_mnemonic varchar(100) output,
  @o_seq_number int output
AS

DECLARE 
  @v_col_len int,
  @v_seq_start int,
  @v_loop_exit int,
  @v_char char(1),
  @v_seq_str varchar(100),
  @v_mnemonic varchar(100)
  
BEGIN

  --initialize
  set @v_col_len = datalength(@i_columnname)
  set @v_seq_start = @v_col_len
  set @v_loop_exit = 0
  set @v_seq_str = ''
  set @v_mnemonic = null

  --exceptions
  if @i_columnname in ('isbn10','isbn13','ean13')
    begin
      set @v_loop_exit=1
    end

  while @v_loop_exit = 0 or @v_seq_start = 0
    begin
      set @v_char = substring(@i_columnname,@v_seq_start,1)
      if @v_char >= '0' and @v_char <= '9'
        begin
          set @v_seq_str = @v_char+@v_seq_str
        end
      else
        begin
          set @v_loop_exit = 1
        end
      set @v_seq_start = @v_seq_start -1
    end

    if @v_seq_str = ''
      begin
        set @o_seq_number=0
        select @o_column_mnemonic = transmnemonic
          from imp_template_detail
          where templatekey = @i_templatekey
            and columnname = @i_columnname
        if @o_column_mnemonic is null
          begin
            set @o_column_mnemonic=@i_columnname
          end
      end
    else
      begin
        set @o_seq_number=cast(@v_seq_str as int)
        select @o_column_mnemonic = transmnemonic
          from imp_template_detail
          where templatekey = @i_templatekey
            and columnname = substring(@i_columnname,1,@v_seq_start+1)
        if @o_column_mnemonic is null
          begin
            set @o_column_mnemonic=substring(@i_columnname,1,@v_seq_start+1)
          end

      end

END

GO
SET QUOTED_IDENTIFIER OFF 
GO
SET ANSI_NULLS ON 
GO


GRANT EXECUTE ON imp_seq_check to PUBLIC 
GO
