/******************************************************************************
**  Name: imp_300010004001
**  Desc: IKE Update UPC
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

if exists (select * from dbo.sysobjects where id = object_id(N'[dbo].[imp_300010004001]') and OBJECTPROPERTY(id, N'IsProcedure') = 1)
drop procedure [dbo].[imp_300010004001]
GO

CREATE PROCEDURE dbo.imp_300010004001 
  
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

/* Update UPC */

BEGIN 

DECLARE @v_elementval VARCHAR(4000),
  @v_errcode INT,
  @v_errmsg VARCHAR(4000),
  @v_bookkey int,
  @v_elementkey int,
  @v_elementdesc VARCHAR(4000),
  @v_upc VARCHAR(20),
  @v_upc_org VARCHAR(20),
  @v_warning VARCHAR(2000)
BEGIN
  SET @o_writehistoryind = 0
  SET @v_errcode = 1   
  SET @v_errmsg = 'UPC'
  SET @v_bookkey = dbo.resolve_keyset(@i_titlekeyset,1)      
  SELECT @v_upc =  originalvalue,
      @v_elementkey = b.elementkey
    FROM imp_batch_detail b , imp_DML_elements d
    WHERE b.batchkey = @i_batch
      AND b.row_id = @i_row
      AND b.elementseq = @i_elementseq
      AND b.elementkey = d.elementkey
      AND d.DMLkey = @i_dmlkey 

  --mk20131003>
  SELECT @v_upc_org = upc 
  FROM isbn 
  WHERE  bookkey = @v_bookkey
        
  IF upper(coalesce(@v_upc,'')) <> upper(coalesce(@v_upc_org,''))
    BEGIN
      UPDATE isbn 
        SET
          upc = @v_upc,
          lastuserid = @i_userid,
          lastmaintdate = GETDATE()
        WHERE  bookkey = @v_bookkey
      SET @o_writehistoryind = 1
      set @v_errmsg='UPC updated'
    end
  else
    begin
      set @i_level=1
      set @v_errmsg='UPC unchanged'
    end
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

GRANT EXECUTE ON dbo.[imp_300010004001] to PUBLIC 
GO
