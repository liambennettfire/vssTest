/******************************************************************************
**  Name: imp_300014057002
**  Desc: IKE Add/Replace BISAC Status
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

if exists (select * from dbo.sysobjects where id = object_id(N'[dbo].[imp_300014057002]') and OBJECTPROPERTY(id, N'IsProcedure') = 1)
drop procedure [dbo].[imp_300014057002]
GO

CREATE PROCEDURE dbo.imp_300014057002 
  
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

/* Add/Replace BISAC Status */

BEGIN 

DECLARE @v_elementval    VARCHAR(4000),
   @v_errcode    INT,
   @v_errmsg     VARCHAR(4000),
   @v_elementdesc    VARCHAR(4000),
   @v_datadesc    VARCHAR(4000),
   @v_elementkey    BIGINT,
   @v_lobcheck     VARCHAR(20),
   @v_lobkey     INT,
   @v_bookkey     INT,
   @v_BisacStatus    INT,
   @v_BisacStatuscode    INT,
   @v_hit      INT
  
BEGIN
  SET @v_hit = 0
  SET @v_BisacStatus = 0
  SET @v_BisacStatuscode = 0
  SET @o_writehistoryind = 0
  SET @v_errcode = 1
  SET @v_errmsg = 'BisacStatus updated'
  SET @v_bookkey = dbo.resolve_keyset(@i_titlekeyset,1)

  SELECT @v_elementval =  LTRIM(RTRIM(originalvalue)),
    @v_elementkey = b.elementkey
    FROM imp_batch_detail b , imp_DML_elements d
    WHERE b.batchkey = @i_batch
      AND b.row_id = @i_row
      AND b.elementseq = @i_elementseq
      AND d.dmlkey = @i_dmlkey
      AND d.elementkey = b.elementkey

  SELECT @v_BisacStatus = COALESCE(BisacStatuscode,0)
    FROM bookdetail
    WHERE bookkey=@v_bookkey 

  exec dbo.find_gentables_mixed  @v_elementval,314,@v_BisacStatuscode output,@v_datadesc output

  IF @v_BisacStatuscode>0 and @v_BisacStatuscode is not null
    BEGIN
      --SELECT @v_BisacStatuscode = datacode
      --  FROM gentables
      --  WHERE tableid = 314  AND datadesc = @v_elementval
      IF coalesce(@v_BisacStatuscode,'') <> coalesce(@v_BisacStatus,'')
        BEGIN
          UPDATE bookdetail
            SET
              BisacStatuscode = @v_BisacStatuscode,
              lastuserid = @i_userid,
              lastmaintdate = GETDATE()
            WHERE bookkey = @v_bookkey
          SET @o_writehistoryind = 1
        END
    END
  ELSE      
    BEGIN
      SET @v_errcode = 2
      SET @v_errmsg = 'Can not find Bisac Status on gentables'
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

GRANT EXECUTE ON dbo.[imp_300014057002] to PUBLIC 
GO
