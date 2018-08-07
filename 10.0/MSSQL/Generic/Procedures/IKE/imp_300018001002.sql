/******************************************************************************
**  Name: imp_300018001002
**  Desc: IKE Add/Replace Book Subjects
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

if exists (select * from dbo.sysobjects where id = object_id(N'[dbo].[imp_300018001002]') and OBJECTPROPERTY(id, N'IsProcedure') = 1)
drop procedure [dbo].[imp_300018001002]
GO

CREATE PROCEDURE dbo.imp_300018001002 
  
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

/* Add/Replace Book Subjects */

BEGIN 

DECLARE @v_elementval    VARCHAR(4000),
  @v_errcode INT,
  @v_errmsg VARCHAR(4000),
  @v_elementdesc VARCHAR(4000),
  @v_elementkey BIGINT,
  @v_bookkey INT,
  @v_categorytableid INT,
  @v_hit INT,
  @v_categorycode INT,
  @v_categorysubcode INT,
  @v_sortorder INT,
  @v_new_key INT,
  @v_destinationcolumn VARCHAR(100)
BEGIN
  SET @v_hit = 0
  SET @v_sortorder = 0
  SET @v_new_key = 0
  SET @o_writehistoryind = 0
  SET @v_errcode = 1
  SET @v_bookkey = dbo.resolve_keyset(@i_titlekeyset,1)
  SELECT @v_elementval =  LTRIM(RTRIM(b.originalvalue)),@v_elementkey = b.elementkey,@v_categorytableid = e.tableid,
         @v_elementdesc = e.elementdesc,@v_destinationcolumn = e.destinationcolumn
    FROM imp_batch_detail b , imp_DML_elements d, imp_element_defs e
    WHERE b.batchkey = @i_batch
      AND b.row_id = @i_row
      AND b.elementseq = @i_elementseq
      AND d.dmlkey = @i_dmlkey
      AND d.elementkey = b.elementkey
      AND d.elementkey = e.elementkey
  SET @v_errmsg = 'Subject Category update...'
  IF @v_destinationcolumn = 'externalcode'
    BEGIN
      SELECT @v_categorycode = datacode, @v_categorysubcode = NULL
        FROM gentables
        WHERE tableid = @v_categorytableid
          AND externalcode = @v_elementval
      IF @v_categorycode is null
          SELECT @v_categorycode = datacode,@v_categorysubcode = datasubcode
            FROM subgentables
            WHERE tableid = @v_categorytableid
              AND externalcode = @v_elementval
    END
  IF @v_destinationcolumn = 'datadesc'
    BEGIN
      SELECT @v_categorycode = datacode, @v_categorysubcode = NULL
        FROM gentables
        WHERE tableid = @v_categorytableid
          AND datadesc = @v_elementval
      IF @v_categorycode is null
          SELECT @v_categorycode = datacode, @v_categorysubcode = datasubcode
            FROM subgentables
            WHERE tableid = @v_categorytableid
              AND datadesc = @v_elementval
    END
  if @v_categorysubcode is null
      SELECT @v_hit = COUNT(*)
        FROM booksubjectcategory
        WHERE categorytableid = @v_categorytableid
          AND categorycode = @v_categorycode
          AND bookkey = @v_bookkey
  else
      SELECT @v_hit = COUNT(*)
        FROM booksubjectcategory
        WHERE categorytableid = @v_categorytableid
          AND categorycode = @v_categorycode
          AND categorysubcode = @v_categorysubcode
          AND bookkey = @v_bookkey
  IF @v_hit = 0
    BEGIN
      SELECT @v_new_key = generickey+1
        FROM keys
      UPDATE keys
        SET generickey = @v_new_key
      IF @i_elementseq = 0
		BEGIN
			SELECT ROW_NUMBER() OVER(PARTITION BY bookkey,categorytableid ORDER BY bookkey, categorytableid, sortorder ASC) AS "RowNumber",*
			INTO #booksubjectcategory
			FROM booksubjectcategory
			WHERE booksubjectcategory.bookkey=@v_bookkey
			ORDER BY booksubjectcategory.sortorder
			
			UPDATE bsc
			SET bsc.sortorder = bsct.RowNumber
			FROM #booksubjectcategory bsct
			INNER JOIN booksubjectcategory bsc ON bsc.bookkey = bsct.bookkey
				AND bsc.subjectkey = bsct.subjectkey
				AND bsc.categorytableid = bsct.categorytableid
				AND bsc.categorycode = bsct.categorycode
				AND bsc.lastmaintdate = bsct.lastmaintdate
		
			SELECT @v_sortorder = MAX(COALESCE(sortorder,0))+1
			FROM booksubjectcategory
			WHERE bookkey=@v_bookkey				
		END
      ELSE
        SET @v_sortorder = @i_elementseq  
      IF @v_categorycode > 0
        begin
          INSERT INTO booksubjectcategory(bookkey,subjectkey,categorytableid,categorycode,categorysubcode,sortorder,lastuserid,lastmaintdate,categorysub2code)
            VALUES (@v_bookkey,@v_new_key,@v_categorytableid,@v_categorycode,@v_categorysubcode,@v_sortorder,@i_userid,GETDATE(),NULL)
          SET @o_writehistoryind = 1
          SET @v_errmsg = 'Subject Category added'
        end
      ELSE
        SET @v_errmsg = 'Subject Category unchanged'
    END
  else
    begin
      SET @v_errmsg = 'Err: ('+ COALESCE(cast(@v_categorycode as varchar),'n/a') +'/'+ COALESCE(cast(@v_categorysubcode as varchar),'n/a')+') tableid '+COALESCE(cast(@v_categorytableid as varchar),'n/a')
    end
      SELECT @v_hit = COUNT(*)
        FROM booksubjectcategory
        WHERE categorytableid = @v_categorytableid
          AND categorycode = @v_categorycode
  EXECUTE imp_write_feedback @i_batch, @i_row, @v_elementkey, @i_elementseq ,@i_dmlkey , @v_errmsg, @i_level, 3 
END

end

GO
SET QUOTED_IDENTIFIER OFF 
GO
SET ANSI_NULLS ON 
GO

GRANT EXECUTE ON dbo.[imp_300018001002] to PUBLIC 
GO
