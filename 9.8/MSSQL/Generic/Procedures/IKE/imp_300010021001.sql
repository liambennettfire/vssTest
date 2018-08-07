/******************************************************************************
**  Name: imp_300010021001
**  Desc: IKE Add/Replace Replaced BY ISBN
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

if exists (select * from dbo.sysobjects where id = object_id(N'[dbo].[imp_300010021001]') and OBJECTPROPERTY(id, N'IsProcedure') = 1)
drop procedure [dbo].[imp_300010021001]
GO

CREATE PROCEDURE dbo.imp_300010021001 
  
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

/* Add/Replace Replaced BY ISBN */

BEGIN 

DECLARE
  @v_isbn    VARCHAR(4000),
  @v_isbn_org    VARCHAR(4000),
  @v_count    INT,
  @v_errcode    INT,
  @v_errmsg     VARCHAR(4000),
  @v_elementdesc    VARCHAR(4000),
  @v_elementkey    BIGINT,
  @v_associationtypecode     INT,
  @v_associationtypesubcode     INT,
  @v_bookkey     INT  

BEGIN
  SET @o_writehistoryind = 0
  SET @v_errcode = 1
  SET @v_errmsg = 'Replaced By ISBN'
  SET @v_bookkey = dbo.resolve_keyset(@i_titlekeyset,1)
  set @v_associationtypecode = 4
  set @v_associationtypesubcode = 4


  SELECT @v_isbn = LTRIM(RTRIM(originalvalue))
    FROM imp_batch_detail 
    WHERE batchkey = @i_batch
      AND row_id = @i_row
      AND elementseq = @i_elementseq
      AND elementkey = 100010021

   select @v_count=count(*)
      from associatedtitles
      where bookkey=@v_bookkey
        and associationtypecode=@v_associationtypecode
        and associationtypesubcode=@v_associationtypesubcode
     
  if @v_count=0
    begin
      -- ?? find assoc bookkey,title, authorname and sortoder ??
      insert into associatedtitles
        (bookkey,associationtypecode,associationtypesubcode,associatetitlebookkey,sortorder,isbn,lastuserid,lastmaintdate)
        values
        (@v_bookkey,@v_associationtypecode,@v_associationtypesubcode,0,1,@v_isbn,@i_userid,getdate())
      SET @o_writehistoryind = 1
      SET @v_errmsg = 'Replaced By ISBN added'
    end
  else
    begin
      select @v_isbn_org=isbn
        from associatedtitles
        where bookkey=@v_bookkey
          and associationtypecode=@v_associationtypecode
          and associationtypesubcode=@v_associationtypesubcode
      if @v_isbn_org<>@v_isbn
        begin
          update associatedtitles
            set
              isbn=@v_isbn,
              lastuserid=@i_userid,
              lastmaintdate=getdate()
            where bookkey=@v_bookkey
              and associationtypecode=@v_associationtypecode
              and associationtypesubcode=@v_associationtypesubcode
          SET @o_writehistoryind = 1
          SET @v_errmsg = 'Replaced By ISBN updated'
        end
      else
        begin
          SET @v_errmsg = 'Replaced By ISBN unchanged'
        end
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

GRANT EXECUTE ON dbo.[imp_300010021001] to PUBLIC 
GO
