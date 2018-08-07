/******************************************************************************
**  Name: imp_300016001001
**  Desc: IKE Add/Replace Audiences
**  Auth: Bennett     
**  Date: 5/9/2016
*******************************************************************************
**  Change History
*******************************************************************************
**  Date:        Author:     Description:
*   --------     --------    -------------------------------------------
**  5/9/2016     Bennett     original
**  5/20/16      Kusum       Case 37304 - increased size of datadesc VARCHAR(MAX) 
**                           to allow for alternatedesc1
*******************************************************************************/
SET QUOTED_IDENTIFIER ON 
GO
SET ANSI_NULLS ON 
GO

if exists (select * from dbo.sysobjects where id = object_id(N'[dbo].[imp_300016001001]') and OBJECTPROPERTY(id, N'IsProcedure') = 1)
drop procedure [dbo].[imp_300016001001]
GO

CREATE PROCEDURE dbo.imp_300016001001 
  
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

/* Add/Replace Audiences */

BEGIN 

SET NOCOUNT ON
/* DEFINE BATCH VARIABLES    */
DECLARE @v_elementval    VARCHAR(4000),
  @v_errcode    INT,
  @v_errmsg     VARCHAR(4000),
  @v_elementdesc    VARCHAR(4000),
  @v_elementkey    BIGINT,
  @v_lobcheck     VARCHAR(20),
  @v_lobkey     INT,
  @v_bookkey     INT,
  @v_hit      INT,
  @v_sortorder    INT,
  @v_rowcount    INT,
  @v_audiencecode    INT,
  @v_audience    INT,
  @v_datadesc  varchar(MAX)
  
BEGIN
  SET @v_hit = 0
  SET @v_sortorder = 0
  SET @v_rowcount = 0
  SET @v_audience = 0
  SET @v_audience = 0
  SET @o_writehistoryind = 0
  SET @v_errcode = 1
  SET @v_errmsg = 'Audience updated'
  SET @v_bookkey = dbo.resolve_keyset(@i_titlekeyset,1)

/*  GET IMPORTED Audience       */
  SELECT @v_elementval =  LTRIM(RTRIM(originalvalue)), @v_elementkey = b.elementkey
    FROM imp_batch_detail b , imp_DML_elements d
    WHERE b.batchkey = @i_batch
      AND b.row_id = @i_row
      AND b.elementseq = @i_elementseq
      AND d.dmlkey = @i_dmlkey
      AND d.elementkey = b.elementkey

/* FIND IMPORT BISAC SUBJECTS ON GENTABLES     */  

  exec find_gentables_mixed @v_elementval,460,@v_audiencecode output,@v_datadesc output 
  IF @v_audiencecode is not null
    BEGIN
      SELECT @v_rowcount = COUNT(*)
        FROM bookaudience
        WHERE bookkey = @v_bookkey
          AND audiencecode = @v_audiencecode

      SELECT @v_sortorder = MAX(sortorder)+1
        FROM bookaudience
        WHERE bookkey = @v_bookkey

      IF @v_sortorder is null 
        SET @v_sortorder = 1

      IF @v_rowcount = 0
        BEGIN
          INSERT INTO bookaudience(bookkey,audiencecode,sortorder,lastuserid,lastmaintdate)
            VALUES(@v_bookkey,@v_audiencecode,@v_sortorder,@i_userid,GETDATE())

          SET @o_writehistoryind = 1
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

GRANT EXECUTE ON dbo.[imp_300016001001] to PUBLIC 
GO
