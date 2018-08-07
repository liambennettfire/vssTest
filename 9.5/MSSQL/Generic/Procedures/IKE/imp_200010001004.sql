/******************************************************************************
**  Name: imp_200010001004
**  Desc: IKE Product number check
**  Auth: Bennett     
**  Date: 5/9/2016
*******************************************************************************
**  Change History
*******************************************************************************
**  Date:        Author:     Description:
*   --------     --------    -------------------------------------------
**  5/9/2016     Bennett     original
*******************************************************************************/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO


IF EXISTS (SELECT * FROM dbo.sysobjects	WHERE id = object_id(N'[dbo].[imp_200010001004]') AND OBJECTPROPERTY(id, N'IsProcedure') = 1)
	DROP PROCEDURE [dbo].[imp_200010001004]
GO

CREATE PROCEDURE [dbo].[imp_200010001004] 
  
  @i_batch int,
  @i_row int,
  @i_elementkey int,
  @i_elementseq int,
  @i_templatekey int,
  @i_rulekey bigint,
  @i_rpt int
AS

/* Product number check */

BEGIN 

DECLARE @v_elementval       VARCHAR(4000),
  @v_elementdesc       VARCHAR(4000),
  @v_errlevel       INT,
  @v_errcode      INT,
  @v_errmsg       VARCHAR(4000),
  @v_msg         VARCHAR(4000),
  @v_isbn        VARCHAR(20),
  @v_productnum       VARCHAR(20),
  @v_productnumdesc       VARCHAR(20),
  @v_productnumtype       int,
  @v_isbn13       VARCHAR(20),
  @v_isbn13in      VARCHAR(20),
  @v_ean         VARCHAR(20),
  @v_count      INT,
  @v_prefix_count      INT,
  @hyphen      INT,
  @v_isbnprefix         VARCHAR(20),
  @v_isbnpostfix         VARCHAR(20),
  @v_isbnprefix_gt         VARCHAR(20)

  
BEGIN
  SET @v_errlevel = 1   
  SET @v_errmsg = 'ISBN Prefix and EAN OK'
  set @v_count=0
  
  SELECT @v_elementval = COALESCE(originalvalue,'')
    FROM imp_batch_detail 
    WHERE  batchkey = @i_batch
      AND row_id = @i_row
      AND elementkey =  @i_elementkey
      AND elementseq =  @i_elementseq    
  SET @v_productnum = REPLACE(@v_elementval,'-','')
  
  select @v_productnumdesc=destinationcolumn
    from imp_element_defs
    where elementkey=@i_elementkey
   
  if @v_productnumdesc like 'isbn%'
    begin
      SELECT @v_count = COUNT(*)
        FROM isbn
        WHERE isbn10 = @v_elementval
      set @v_productnumtype=0
    end
  if @v_productnumdesc like 'ean%'
    begin
      SELECT @v_count = COUNT(*)
        FROM isbn
        WHERE ean13 = @v_elementval
      set @v_productnumtype=1
    end
    
  IF @v_count < 1
    BEGIN
      EXECUTE qean_validate_product @v_productnum,@v_productnumtype,0,null,@v_isbn13 out,@v_errcode out,@v_msg out
      IF @v_errcode<>0
        BEGIN
          SET @v_errmsg = 'Invalid ISBN or an EAN - '+@v_msg
          SET @v_errlevel = 3
        END
      else
        begin
          -- qean_validate_product does not check for prefix on gentables so do it here
          set @hyphen=charindex('-',@v_isbn13)
          set @hyphen=charindex('-',@v_isbn13,@hyphen+1)
          set @hyphen=charindex('-',@v_isbn13,@hyphen+1)
          set @v_isbnprefix=substring(@v_isbn13,1,@hyphen-1)
          set @v_isbnpostfix=substring(@v_isbn13,@hyphen+1,20)
          SELECT @v_isbnpostfix = substring(@v_isbn13,@hyphen+1,20)
          if @v_productnumdesc like 'isbn%'
            begin
              set @hyphen=charindex('-',@v_isbnprefix)
              set @hyphen=charindex('-',@v_isbnprefix,@hyphen+1)
              set @v_isbnprefix_gt=substring(@v_isbn13,1,@hyphen-1)
            end
          if @v_productnumdesc like 'ean%'
            begin
              set @v_isbnprefix_gt=substring(@v_isbnprefix,5,15)
            end
          SELECT @v_prefix_count=count(*)
            FROM subgentables
            WHERE tableid = 138 
              AND datacode = 1
              AND datadesc = LTRIM(RTRIM(@v_isbnprefix_gt))
          if @v_prefix_count=0
            begin
              SET @v_errmsg = 'Missing ISBN or an EAN prefix '+coalesce(@v_isbnprefix,'n/a')
              SET @v_errlevel = 3
            end
        end
    END
    EXECUTE imp_write_feedback @i_batch, @i_row, @i_elementkey, @i_elementseq, @i_rulekey , @v_errmsg, @v_errlevel, 2
END

end

