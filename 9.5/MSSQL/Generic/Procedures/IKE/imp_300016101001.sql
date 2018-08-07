/******************************************************************************
**  Name: imp_300016101001
**  Desc: IKE book category
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

if exists (select * from dbo.sysobjects where id = object_id(N'[dbo].[imp_300016101001]') and OBJECTPROPERTY(id, N'IsProcedure') = 1)
drop procedure [dbo].[imp_300016101001]
GO

CREATE PROCEDURE dbo.imp_300016101001 
  
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
  @v_sortorder    INT,
  @v_rowcount    INT,
  @v_categorycode    INT,
  @v_categorycode_org    INT,
  @v_audience    INT
  
BEGIN
  SET @v_hit = 0
  SET @v_sortorder = 0
  SET @v_rowcount = 0
  SET @v_audience = 0
  SET @v_audience = 0
  SET @o_writehistoryind = 0
  SET @v_errcode = 1
  SET @v_errmsg = 'Book Category'
  SET @v_bookkey = dbo.resolve_keyset(@i_titlekeyset,1)

  SELECT @v_elementval =  LTRIM(RTRIM(originalvalue)), @v_elementkey = b.elementkey
    FROM imp_batch_detail b , imp_DML_elements d
    WHERE b.batchkey = @i_batch
      AND b.row_id = @i_row
      AND b.elementseq = @i_elementseq
      AND d.dmlkey = @i_dmlkey
      AND d.elementkey = b.elementkey

  SELECT @v_hit = COUNT(*)
    FROM gentables
     WHERE tableid = 317 AND datadesc = @v_elementval
  IF @v_hit = 1
    BEGIN
      SELECT @v_categorycode = datacode
        FROM gentables
        WHERE tableid = 317  AND datadesc = @v_elementval
        
      SELECT @v_rowcount = COUNT(*)
        FROM bookcategory
        WHERE bookkey = @v_bookkey
          AND categorycode = @v_categorycode

      SELECT @v_sortorder = MAX(sortorder)+1
        FROM bookcategory
        WHERE bookkey = @v_bookkey

      IF @v_sortorder is null 
        SET @v_sortorder = 1

      IF @v_rowcount = 0
        BEGIN
          INSERT INTO bookcategory(bookkey,categorycode,sortorder,lastuserid,lastmaintdate)
            VALUES(@v_bookkey,@v_categorycode,@v_sortorder,@i_userid,GETDATE())
          SET @o_writehistoryind = 1
          SET @v_errmsg = 'Book Category added'
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

GRANT EXECUTE ON dbo.[imp_300016101001] to PUBLIC 
GO
