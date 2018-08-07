/******************************************************************************
**  Name: imp_100000001001
**  Desc: IKE Strip numeric element of non-numeric format characters
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

if exists (select * from dbo.sysobjects where id = object_id(N'[dbo].[imp_100000001001]') and OBJECTPROPERTY(id, N'IsProcedure') = 1)
drop procedure [dbo].[imp_100000001001]
GO

CREATE PROCEDURE dbo.imp_100000001001 
  
  @i_batchkey int,
  @i_row int,
--  @i_elementkey int,
  @i_elementseq int,
  @i_templatekey int,
  @i_rulekey bigint,
  @i_level int,
  @i_userid varchar(50)
AS

/* Strip numeric element of non-numeric format characters */

BEGIN 

DECLARE  
  @v_errcode INT,
  @v_new_value varchar(4000),
  @v_elementkey int,
  @v_originalvalue varchar(4000),
  @v_errlevel INT,
  @v_msg VARCHAR(4000)

BEGIN
	SET @v_errcode = 0
	SET @v_errlevel = 0
	SET @v_msg = ''

	DECLARE element_cur INSENSITIVE CURSOR FOR
		SELECT b.elementkey,b.originalvalue
		FROM  imp_batch_detail b, imp_load_elements l
		WHERE l.elementkey = b.elementkey
					AND l.loadkey = 100000001001
    					AND b.batchkey = @i_batchkey
					AND b.row_id = @i_row
					AND b.elementseq = @i_elementseq

	OPEN element_cur 

	FETCH  element_cur 
	INTO @v_elementkey,@v_originalvalue 

	WHILE @@fetch_status=0
		BEGIN
			SET @v_new_value = @v_originalvalue 
			SET @v_new_value = replace(@v_new_value,'$','')
      			SET  @v_new_value = replace(@v_new_value,',','')
      			SET  @v_new_value = replace(@v_new_value,'%','')
      			SET  @v_new_value = replace(@v_new_value,' ','')

			UPDATE imp_batch_detail
			SET originalvalue = @v_new_value 
			WHERE batchkey = @i_batchkey
          				AND row_id = @i_row
                    			AND  elementseq = @i_elementseq
                    			AND  elementkey = @v_elementkey

      IF @v_errlevel >= @i_level 
        BEGIN
          EXECUTE imp_write_feedback @i_batchkey, @i_row, @v_elementkey, @i_elementseq, @i_rulekey , @v_msg, @v_errlevel, 1
        END

      fetch element_cur into @v_elementkey,@v_originalvalue 
    end
  	CLOSE element_cur 
	DEALLOCATE element_cur
END

end

GO
SET QUOTED_IDENTIFIER OFF 
GO
SET ANSI_NULLS ON 
GO

GRANT EXECUTE ON dbo.[imp_100000001001] to PUBLIC 
GO
