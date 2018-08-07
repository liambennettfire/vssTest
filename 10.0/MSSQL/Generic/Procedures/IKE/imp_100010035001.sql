/******************************************************************************
**  Name: imp_100010035001
**  Desc: IKE Base level Org Entry
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

if exists (select * from dbo.sysobjects where id = object_id(N'[dbo].[imp_100010035001]') and OBJECTPROPERTY(id, N'IsProcedure') = 1)
drop procedure [dbo].[imp_100010035001]
GO

CREATE PROCEDURE dbo.imp_100010035001 
  
  @i_batchkey int,
  @i_row int,
--  @i_elementkey int,
  @i_elementseq int,
  @i_templatekey int,
  @i_rulekey bigint,
  @i_level int,
  @i_userid varchar(50)
AS

/* Base level Org Entry */

BEGIN 

DECLARE  
  @v_elementval      VARCHAR(4000),
  @v_elementdesc    VARCHAR(4000),
  @v_elementkey     BIGINT,
  @v_errcode     INT,
  @v_errmsg     VARCHAR(4000),
  @v_idtype  varchar(20),
  @v_idvalue  varchar(40)
   
BEGIN

  SET @v_errcode = 1
  SET @v_errmsg = 'ONIX work load to element 100010030'

  SELECT @v_idtype = originalvalue
    FROM imp_batch_detail 
    WHERE batchkey = @i_batchkey
      and row_id = @i_row
      and elementseq = @i_elementseq
      and elementkey = 100010035

  if @v_idtype='05' or @v_idtype='15'
    begin 
      SELECT @v_idvalue = originalvalue
        FROM imp_batch_detail 
        WHERE batchkey = @i_batchkey
          and row_id = @i_row
          and elementseq = @i_elementseq
          and elementkey = 100010036
          
      INSERT INTO imp_batch_detail
       (batchkey,row_id,elementkey,elementseq,originalvalue,lastuserid,lastmaintdate)
       VALUES
       (@i_batchkey,@i_row,100010030,@i_elementseq,@v_idvalue,'loader_rule_100010035001',getdate())
    
      EXECUTE imp_write_feedback @i_batchkey, @i_row, @v_elementkey, @i_elementseq, @i_rulekey , @v_errmsg, 1, 1
    end

    
END

end

GO
SET QUOTED_IDENTIFIER OFF 
GO
SET ANSI_NULLS ON 
GO

GRANT EXECUTE ON dbo.[imp_100010035001] to PUBLIC 
GO

