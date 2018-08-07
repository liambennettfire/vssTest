/******************************************************************************
**  Name: imp_300012023001
**  Desc: IKE Add/Replace Send to Eloquence Indicator
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

if exists (select * from dbo.sysobjects where id = object_id(N'[dbo].[imp_300012023001]') and OBJECTPROPERTY(id, N'IsProcedure') = 1)
drop procedure [dbo].[imp_300012023001]
GO

CREATE PROCEDURE dbo.imp_300012023001 
  
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

/* Add/Replace Send to Eloquence Indicator */

BEGIN 

DECLARE @v_elementval    VARCHAR(4000),
  @v_errcode    INT,
  @v_errmsg     VARCHAR(4000),
  @v_elementdesc    VARCHAR(4000),
  @v_elementkey    BIGINT,
  @v_lobcheck     VARCHAR(20),
  @v_lobkey     INT,
  @v_bookkey     INT,
  @v_hit      INT,
  @printingkey    INT,
  @v_sendtoeloind    INT,
  @v_sendtoelo    INT
    
BEGIN
  SET @v_sendtoeloind = 0
  SET @v_sendtoelo = 0
  SET @o_writehistoryind = 0
  SET @v_errcode = 1
  SET @v_errmsg = 'To Eloquence Outbox'
  SET @v_bookkey = dbo.resolve_keyset(@i_titlekeyset,1)

/*  GET IMPORTED Send to Eloquence Indicator      */
  SELECT @v_elementval =  COALESCE(originalvalue,''),
    @v_elementkey = b.elementkey
    FROM imp_batch_detail b , imp_DML_elements d
    WHERE b.batchkey = @i_batch
      AND b.row_id = @i_row
      AND b.elementseq = @i_elementseq
      AND d.dmlkey = @i_dmlkey
      AND d.elementkey = b.elementkey

/* GET CURRENT SEND TO ELOQUENCE INDICATOR  VALUE    */
  SELECT @v_sendtoeloind = COALESCE(sendtoeloind,0)
    FROM book
    WHERE bookkey=@v_bookkey 

/* SET THE IMPORTED VALUE AN INTEGER   */  

  SELECT @v_sendtoelo = 
    CASE
      WHEN @v_elementval = 'YES'   THEN 1
      WHEN @v_elementval = '1'  THEN 1
    ELSE
       0
    END  

/* IF VALUE HAS CHANGED - UPDATE BOOK AND SET WRITE HISTORY INDICATOR  */
  IF @v_sendtoelo <> @v_sendtoeloind
    BEGIN
      UPDATE book
        SET sendtoeloind = @v_sendtoelo,
          lastuserid = @i_userid,
          lastmaintdate = GETDATE()
        WHERE bookkey = @v_bookkey 
      SELECT @v_hit = COUNT(*)
        FROM bookedipartner
        WHERE bookkey = @v_bookkey
      IF @v_hit < 1
        BEGIN
          INSERT INTO bookedipartner(edipartnerkey,bookkey,printingkey,lastuserid,lastmaintdate,sendtoeloquenceind)
          VALUES (1,@v_bookkey,1,@i_userid,GETDATE(),1)
        END
      SET @v_hit = 0
      SELECT @v_hit = COUNT(*)
        FROM bookedistatus
        WHERE bookkey = @v_bookkey
      IF @v_hit < 1
        BEGIN
          INSERT INTO bookedistatus(edipartnerkey,bookkey,printingkey,edistatuscode,lastuserid,lastmaintdate,previousedistatuscode)
            VALUES(1,@v_bookkey,1,1,@i_userid,GETDATE(),0)
        END
      SET @v_errmsg = @v_errmsg +' updated'
      SET @o_writehistoryind = 1
    end
  ELSE
    begin
      SET @v_errmsg = @v_errmsg +' unchanged'
    end
-- IF @v_errcode < 2
--   BEGIN
     EXECUTE imp_write_feedback @i_batch, @i_row, @v_elementkey, @i_elementseq ,@i_dmlkey , @v_errmsg, @i_level, 3 
--   END
END

end

GO
SET QUOTED_IDENTIFIER OFF 
GO
SET ANSI_NULLS ON 
GO

GRANT EXECUTE ON dbo.[imp_300012023001] to PUBLIC 
GO
