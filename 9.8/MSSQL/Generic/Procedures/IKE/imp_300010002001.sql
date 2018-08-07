/******************************************************************************
**  Name: imp_300010002001
**  Desc: IKE Update ISBN13(EAN) Number
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

if exists (select * from dbo.sysobjects where id = object_id(N'[dbo].[imp_300010002001]') and OBJECTPROPERTY(id, N'IsProcedure') = 1)
drop procedure [dbo].[imp_300010002001]
GO

CREATE PROCEDURE dbo.imp_300010002001 
  
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

/* Update ISBN13(EAN) Number */

BEGIN 

DECLARE @v_elementval VARCHAR(4000),
  @v_errcode INT,
  @v_errmsg VARCHAR(4000),
  @v_elementdesc VARCHAR(4000),
  @v_lobcheck VARCHAR(20),
  @v_lobkey INT,
  @v_bookkey INT ,   
  @v_isbnkey INT,
  @v_isbn  VARCHAR(20),
  @v_isbnprefixcode INT,
  @v_eanprefixcode INT,
  @v_isbn10 VARCHAR(20),
  @v_isbn13 VARCHAR(20),
  @v_ean VARCHAR(20),
  @v_ean13 VARCHAR(20),
  @v_ean13_old VARCHAR(20),
  @v_gtin VARCHAR(20),
  @v_gtin14 VARCHAR(20),
  @v_isbnprefix VARCHAR(20),
  @v_isbnprefix_gt VARCHAR(20),
  @v_isbnpostfix VARCHAR(20),
  @v_eanprefix VARCHAR(20),
  @v_warning VARCHAR(2000)
  
BEGIN
  SET @o_writehistoryind = 0
  SET @v_errcode = 1   
  SET @v_errmsg = 'ISBN table updated'
  SET @v_bookkey = dbo.resolve_keyset(@i_titlekeyset,1)      
  SELECT @v_elementval =  originalvalue
    FROM imp_batch_detail b , imp_DML_elements d
    WHERE b.batchkey = @i_batch
      AND b.row_id = @i_row
      AND b.elementseq = @i_elementseq
      AND b.elementkey = d.elementkey
      AND d.DMLkey = @i_dmlkey     
  SELECT @v_eanprefixcode = 1
  SELECT @v_isbn10 = ''
  SELECT @v_isbn13 = ''
  SELECT @v_ean = ''
  SELECT @v_ean13 = REPLACE(@v_elementval,'-','')
  SELECT @v_gtin = ''
  SELECT @v_gtin14 = ''
  SELECT @v_isbn10 = ''
  SELECT @v_ean13_old = ean13
    FROM isbn
    WHERE bookkey = @v_bookkey
  set @v_ean13_old=coalesce(@v_ean13_old,'x')
  IF @v_ean13_old <> @v_ean13
    BEGIN
      DECLARE @varcharGroupIdentifier    VARCHAR(1)
      DECLARE @hyphen        INT
      DECLARE @varcharCheckSum    VARCHAR(1)
      SELECT @varcharGroupIdentifier = SUBSTRING(@v_isbn13, 1, 1)
      SELECT @varcharCheckSum = SUBSTRING(@v_isbn13, 10, 1)

      EXECUTE qean_validate_product @v_ean13,1,0,null,@v_isbn13 out,@v_errcode out,@v_errmsg out
      set @hyphen=charindex('-',@v_isbn13)
      set @hyphen=charindex('-',@v_isbn13,@hyphen+1)
      set @hyphen=charindex('-',@v_isbn13,@hyphen+1)
      set @v_isbnprefix=substring(@v_isbn13,1,@hyphen-1)
      set @v_isbnpostfix=substring(@v_isbn13,@hyphen+1,20)
      SELECT @v_isbnpostfix = substring(@v_isbn13,@hyphen+1,20)
      set @v_isbnprefix_gt=substring(@v_isbnprefix,5,15)
      SELECT @v_isbnprefixcode = datasubcode
        FROM subgentables
        WHERE tableid = 138 
          AND datacode = 1 
          AND datadesc = LTRIM(RTRIM(@v_isbnprefix_gt))
      EXECUTE qean_generate_ean @v_isbnprefix_gt,NULL,NULL,@v_isbnpostfix,1,@v_bookkey,
            @v_isbn13 out,@v_ean out,@v_gtin out,@v_errcode out,@v_errmsg out
      SELECT @v_ean13 = REPLACE(@v_ean,'-','')
      SELECT @v_gtin14 = REPLACE(@v_gtin,'-','')
      SELECT @v_isbn10 = REPLACE(@v_isbn13,'-','')
      UPDATE isbn 
        SET isbn = @v_isbn13,
          isbn10 = @v_isbn10,
          isbnprefixcode = @v_isbnprefixcode,
          ean = @v_ean,
          ean13 = @v_ean13,
          eanprefixcode = @v_eanprefixcode,
          gtin = @v_gtin,
          gtin14 = @v_gtin14,
          lastuserid = @i_userid,
          lastmaintdate = GETDATE()
      WHERE  bookkey = @v_bookkey
      SET @o_writehistoryind = 1
    END
    if @v_errcode < 0
      BEGIN        
        set @v_errcode =3
      END
    if @v_errcode = 0
      BEGIN        
        set @v_errcode = 1
      END
    IF @v_errcode >= @i_level    
        BEGIN        
      EXECUTE imp_write_feedback @i_batch, @i_row, null, @i_elementseq ,'300010000001' , @v_errmsg, @v_errcode, 3      
    END
END

end

GO
SET QUOTED_IDENTIFIER OFF 
GO
SET ANSI_NULLS ON 
GO

GRANT EXECUTE ON dbo.[imp_300010002001] to PUBLIC 
GO
