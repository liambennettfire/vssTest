/******************************************************************************
**  Name: imp_100012067001
**  Desc: IKE Sort AudienceRange into Age or Grade values
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

if exists (select * from dbo.sysobjects where id = object_id(N'[dbo].[imp_100012067001]') and OBJECTPROPERTY(id, N'IsProcedure') = 1)
drop procedure [dbo].[imp_100012067001]
GO

CREATE PROCEDURE dbo.imp_100012067001 
  
  @i_batchkey int,
  @i_row int,
--  @i_elementkey int,
  @i_elementseq int,
  @i_templatekey int,
  @i_rulekey bigint,
  @i_level int,
  @i_userid varchar(50)
AS

/* Sort AudienceRange into Age or Grade values */

BEGIN 

-- copy audiencerangequalifier forward so it groups correctly with the 2nd set if nessasary
declare
  @v_elementseq int,
  @v_audiencerangequalifier varchar(4000)

select @v_audiencerangequalifier=originalvalue
  from imp_batch_detail
  where batchkey=@i_batchkey
    and row_id=@i_row
    and elementkey=100012067
    and elementseq=@i_elementseq

set @v_elementseq=@i_elementseq+1000

insert into imp_batch_detail
  (batchkey ,row_id ,elementseq ,elementkey, originalvalue, lastuserid, lastmaintdate)
  values
  (@i_batchkey , @i_row , @v_elementseq , 100012067, @v_audiencerangequalifier,'except_loader_100012067001', getdate())


end

GO
SET QUOTED_IDENTIFIER OFF 
GO
SET ANSI_NULLS ON 
GO

GRANT EXECUTE ON dbo.[imp_100012067001] to PUBLIC 
GO
