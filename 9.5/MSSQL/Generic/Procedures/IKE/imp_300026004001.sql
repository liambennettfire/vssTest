/******************************************************************************
**  Name: imp_300026004001
**  Desc: IKE Add/Replace Author Corporate Contriubtor Ind
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

if exists (select * from dbo.sysobjects where id = object_id(N'[dbo].[imp_300026004001]') and OBJECTPROPERTY(id, N'IsProcedure') = 1)
drop procedure [dbo].[imp_300026004001]
GO

CREATE PROCEDURE dbo.imp_300026004001 
  
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

/* Add/Replace Author Corporate Contriubtor Ind */

BEGIN 

/*  AUTHOR CORPORATE IND		*/
DECLARE	@v_elementval		VARCHAR(4000),
  	@v_elementkey		INT,
  	@v_errcode 		INT,
  	@v_errmsg 		VARCHAR(4000),
  	@v_elementdesc 		VARCHAR(4000),
	@v_authorkey 		INT,
	@v_new_corpind		VARCHAR(75),
	@v_cur_corpind		VARCHAR(75)

BEGIN
	SET @o_writehistoryind = 0
	SET @v_errcode = 1
	SET @v_errmsg = 'Author Corporate Contriubtor Indicator Updated'
	SET @v_authorkey = dbo.resolve_keyset(@i_contactkeyset,1)

	SELECT @v_elementval =  COALESCE(originalvalue,''),
		@v_elementkey = b.elementkey
	FROM imp_batch_detail b , imp_DML_elements d
	WHERE b.batchkey = @i_batch
      			AND b.row_id = @i_row
			AND b.elementseq = @i_elementseq
			AND b.elementkey = d.elementkey
			AND d.DMLkey = @i_dmlkey

  	IF UPPER(substring(@v_elementval,1,1))= 'Y' OR  UPPER(substring(@v_elementval,1,1))='N'
		BEGIN
			SET @v_new_corpind = CASE
						WHEN UPPER(@v_elementval) = 'Y' 	THEN 1
						WHEN UPPER(@v_elementval) = 'YES' 	THEN 1
					ELSE
						0			
						END
		
			SELECT @v_cur_corpind = COALESCE(corporatecontributorind,'')
			FROM author
			WHERE authorkey = @v_authorkey 		

			IF @v_new_corpind <> @v_cur_corpind
				BEGIN
					UPDATE author
				     	SET corporatecontributorind = @v_new_corpind
					WHERE authorkey = @v_authorkey 		

					SET @o_writehistoryind = 1
    				END
		END
	

  	IF @v_errcode >= @i_level
    		BEGIN
      			EXECUTE imp_write_feedback @i_batch, @i_row, @v_elementkey, @i_elementseq ,@i_dmlkey , @v_errmsg, @v_errcode, 3
    		END

END

end

GO
SET QUOTED_IDENTIFIER OFF 
GO
SET ANSI_NULLS ON 
GO

GRANT EXECUTE ON dbo.[imp_300026004001] to PUBLIC 
GO
