/******************************************************************************
**  Name: imp_300012000001
**  Desc: IKE Copy from Title Template
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

if exists (select * from dbo.sysobjects where id = object_id(N'[dbo].[imp_300012000001]') and OBJECTPROPERTY(id, N'IsProcedure') = 1)
drop procedure [dbo].[imp_300012000001]
GO

CREATE PROCEDURE dbo.imp_300012000001 
  
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

/* Copy from Title Template */

BEGIN 

SET NOCOUNT ON
DECLARE @v_errcode 		INT,
	@v_errmsg 		VARCHAR(4000),
	@v_bookkey 		INT,
	@v_title_template	VARCHAR(255)  ,
	@v_template_bookkey	INT,
	@v_count		INT,
	@v_elementkey		INT
BEGIN
	SET @o_writehistoryind = 0
	SET @v_errcode = 1   
	SET @v_errmsg = 'Existing Title - Copy title template Skipped'
	SET @v_bookkey = dbo.resolve_keyset(@i_titlekeyset,1)      

	IF @i_newtitleind = 1
		BEGIN
			SELECT @v_count = count(distinct b.bookkey)  
			FROM bookorgentry bo1, bookorgentry bo2, book b
			WHERE bo1.bookkey = @v_bookkey
					AND bo1.orgentrykey = bo2.orgentrykey
					AND bo1.orglevelkey = bo2.orglevelkey
					AND bo2.bookkey = b.bookkey
					AND b.standardind = 'Y'
					AND b.tmmwebtemplateind = 1

			IF @v_count = 1
				BEGIN
					SELECT @v_template_bookkey = b.bookkey
					FROM bookorgentry bo1, bookorgentry bo2, book b
					WHERE bo1.bookkey = @v_bookkey
							AND bo1.orgentrykey = bo2.orgentrykey
							AND bo1.orglevelkey = bo2.orglevelkey
							AND bo2.bookkey = b.bookkey
							AND b.standardind = 'Y'
							AND b.tmmwebtemplateind = 1

					SELECT @v_title_template = title
					FROM book
					WHERE bookkey = @v_template_bookkey

					EXECUTE imp_rule_ext_300012000001 @v_bookkey,@v_template_bookkey,@i_userid
					

					SET @v_errmsg = 'The '+@v_title_template+' title template was applied'
				END
			IF @v_count = 0
				BEGIN
					SET @v_errcode = 2
					SET @v_errmsg = 'Import could not find any distribution templates for the specified title group level'
				END

			IF @v_count > 1
				BEGIN
					SET @v_errcode = 3
					SET @v_errmsg = 'Import found more than one distribution templates and could not determine which one to apply'
				END
		END


	
		
	IF @v_errcode < 2      
			BEGIN        
				EXECUTE imp_write_feedback @i_batch, @i_row, @v_elementkey, @i_elementseq ,@i_dmlkey , @v_errmsg, @i_level, 3      
			END
END

end

GO
SET QUOTED_IDENTIFIER OFF 
GO
SET ANSI_NULLS ON 
GO

GRANT EXECUTE ON dbo.[imp_300012000001] to PUBLIC 
GO
