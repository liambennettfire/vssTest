/******************************************************************************
**  Name: imp_300010033001
**  Desc: IKE associatedtitles
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

if exists (select * from dbo.sysobjects where id = object_id(N'[dbo].[imp_300010033001]') and OBJECTPROPERTY(id, N'IsProcedure') = 1)
drop procedure [dbo].[imp_300010033001]
GO

CREATE PROCEDURE dbo.imp_300010033001
  
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
/*    START SPROC    */
/*associatedtitle update*/
DECLARE
  @v_isbn    VARCHAR(	4000),
  @v_isbn_org    VARCHAR(4000),
  @v_count    INT,
  @v_errcode    INT,
  @v_errmsg     VARCHAR(4000),
  @v_elementdesc    VARCHAR(4000),
  @v_elementkey    BIGINT,
  @v_associationtypecode     INT,
  @v_associationtypesubcode     INT,
  @v_bookkey     INT ,
  @v_assoc_type  varchar(40),
  @v_assoc_bookkey     INT ,
  @v_addlqualifier  VARCHAR(4000),
  @v_value1  VARCHAR(4000),
  @v_value2  VARCHAR(4000)
BEGIN
  SET @o_writehistoryind = 0
  SET @v_errcode = 1
  SET @v_errmsg = 'n/a'
  SET @v_bookkey = dbo.resolve_keyset(@i_titlekeyset,1)
  SELECT @v_assoc_type= LTRIM(RTRIM(originalvalue))
    FROM imp_batch_detail
    WHERE batchkey=@i_batch
      AND row_id=@i_row
      AND elementseq=@i_elementseq
      AND elementkey=100010032
  SELECT @v_isbn= LTRIM(RTRIM(originalvalue))
    FROM imp_batch_detail
    WHERE batchkey=@i_batch
      AND row_id=@i_row
      AND elementseq=@i_elementseq
      AND elementkey=100010033

  exec dbo.find_subgentables_mixed  @v_assoc_type,440,@v_associationtypecode output,@v_associationtypesubcode output,@v_value1 output

  --select 
  --     @v_associationtypecode=sg.datacode,
  --     @v_associationtypesubcode=sg.datasubcode,
  --     @v_value1=sg.datadesc
  --  from subgentables sg, subgentables_ext sgx
  --  where sg.tableid=440
  --    and sg.datacode=sgx.datacode
  --    and sg.datasubcode=sgx.datasubcode
  --    and (sg.datadesc=@v_assoc_type
  --     or sg.externalcode=@v_assoc_type
  --     or sgx.onixsubcode=@v_assoc_type)

  SET @v_errmsg = 'Association: '+@v_value1
  
  select @v_assoc_bookkey=bookkey 
    from isbn
    where ean13=replace(@v_isbn,'-','')
  if @v_assoc_bookkey is null
    select @v_assoc_bookkey=bookkey
      from isbn
      where isbn=replace(@v_isbn,'-','')
        
  select @v_count=count(*)
    from associatedtitles
    where bookkey=@v_bookkey
      and associationtypecode=@v_associationtypecode
      and associationtypesubcode=@v_associationtypesubcode
      
  if @v_assoc_bookkey is not null
    begin   
      if @v_count=0
        begin
          insert into associatedtitles
            (bookkey,associationtypecode,associationtypesubcode,associatetitlebookkey,productidtype,sortorder,isbn,lastuserid,lastmaintdate)
            values
            (@v_bookkey,@v_associationtypecode,@v_associationtypesubcode,@v_assoc_bookkey,2,1,@v_isbn,@i_userid,getdate())
          set @o_writehistoryind = 1
          set @v_errmsg = @v_errmsg+' added'
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
                  associatetitlebookkey=@v_assoc_bookkey,
                  lastuserid=@i_userid,
                  lastmaintdate=getdate()
                where bookkey=@v_bookkey
                  and associationtypecode=@v_associationtypecode
                  and associationtypesubcode=@v_associationtypesubcode
              SET @o_writehistoryind = 1
              SET @v_errmsg = @v_errmsg+' updated'
            end
          else
            begin
              SET @v_errmsg = @v_errmsg+' unchanged'
            end
        end
    end
    
  IF @v_errcode < 2
    BEGIN
      EXECUTE imp_write_feedback @i_batch, @i_row, @v_elementkey, @i_elementseq ,@i_dmlkey , @v_errmsg, @i_level, 3 
    END
END

/*     END SPROC     */
END

GO
SET QUOTED_IDENTIFIER OFF 
GO
SET ANSI_NULLS ON 
GO

GRANT EXECUTE ON dbo.[imp_300010033001] to PUBLIC 
GO
