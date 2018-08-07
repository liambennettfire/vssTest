/******************************************************************************
**  Name: imp_200010026001
**  Desc: IKE generic assoc title addlqualifier check
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

if exists (select * from dbo.sysobjects where id = object_id(N'[dbo].[imp_200010026001]') and OBJECTPROPERTY(id, N'IsProcedure') = 1)
drop procedure [dbo].[imp_200010026001]
GO

CREATE PROCEDURE dbo.imp_200010026001 
  
  @i_batch int,
  @i_row int,
  @i_elementkey int,
  @i_elementseq int,
  @i_templatekey int,
  @i_rulekey bigint,
  @i_rpt int
AS

/* generic assoc title addlqualifier check */

BEGIN 

DECLARE	@v_elementval 		VARCHAR(4000),
	@v_errcode 		INT,
	@v_errlevel 		INT,
	@v_msg 			  VARCHAR(4000),
	@v_addlqualifier  VARCHAR(4000),
    @v_value1  VARCHAR(4000),
    @v_value2  VARCHAR(4000)
    
    select @v_addlqualifier=addlqualifier
      from imp_template_detail
      where templatekey=@i_templatekey
        and elementkey=@i_elementkey
        
    set @v_value1=dbo.resolve_keyset(@v_addlqualifier,1)
    set @v_value2=dbo.resolve_keyset(@v_addlqualifier,2)
	IF ISNUMERIC(@v_value1)=0 or ISNUMERIC(@v_value2)=0
      BEGIN
        set @v_msg='Invalid Addlqualifier value in template. Requires Associationtypecode and Associationtypesubcode. ex: 4,4'
        set @v_errlevel=3
        EXECUTE imp_write_feedback @i_batch, @i_row, @i_elementkey, @i_elementseq, @i_rulekey , @v_msg, @v_errlevel, 2
      END
END

GO
SET QUOTED_IDENTIFIER OFF 
GO
SET ANSI_NULLS ON 
GO

GRANT EXECUTE ON dbo.[imp_200010026001] to PUBLIC 
GO
