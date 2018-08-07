/******************************************************************************
**  Name: imp_300018101001
**  Desc: IKE Add/Replace Dates
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

if exists (select * from dbo.sysobjects where id = object_id(N'[dbo].[imp_300018101001]') and OBJECTPROPERTY(id, N'IsProcedure') = 1)
drop procedure [dbo].imp_300018101001
GO

CREATE PROCEDURE dbo.imp_300018101001 
  
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

/* Add/Replace Dates */

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

  SET @v_hit = 0
  SET @v_sortorder = 0
  SET @v_new_key = 0
  SET @o_writehistoryind = 0
  SET @v_errcode = 1
  SET @v_bookkey = dbo.resolve_keyset(@i_titlekeyset,1)
  SELECT @v_elementval =  LTRIM(RTRIM(b.originalvalue)),@v_elementkey = b.elementkey,@v_categorytableid = td.addlqualifier,
         @v_elementdesc = e.elementdesc,@v_destinationcolumn = e.destinationcolumn
    FROM imp_batch_detail b , imp_DML_elements d, imp_element_defs e,imp_template_detail td
    WHERE b.batchkey = @i_batch
      AND b.row_id = @i_row
      AND b.elementseq = @i_elementseq
      AND d.dmlkey = @i_dmlkey
      AND d.elementkey = b.elementkey
      AND d.elementkey = e.elementkey
      AND d.elementkey = td.elementkey
      AND td.templatekey = @i_templatekey

  SET @v_errmsg = 'booksubjectcategory update from subgen...'

  SELECT @v_categorycode = datacode, @v_categorysubcode = datasubcode
    FROM subgentables
    WHERE tableid = @v_categorytableid
      AND datadesc = @v_elementval

  SELECT @v_hit = COUNT(*)
    FROM booksubjectcategory
    WHERE categorytableid = @v_categorytableid
      AND categorycode = @v_categorycode
      AND categorysubcode = @v_categorysubcode
      AND bookkey = @v_bookkey

  IF @v_hit = 0
    begin
      if @v_categorytableid is not null  and @v_categorycode is not null  and @v_categorysubcode is not null  
        BEGIN
          SELECT @v_new_key = generickey+1
            FROM keys
          UPDATE keys
            SET generickey = @v_new_key
          SELECT @v_sortorder = MAX(sortorder)
            FROM booksubjectcategory
            WHERE bookkey = @v_bookkey
          set @v_sortorder=COALESCE(@v_sortorder,0)+1
          INSERT INTO booksubjectcategory(bookkey,subjectkey,categorytableid,categorycode,categorysubcode,sortorder,lastuserid,lastmaintdate,categorysub2code)
            VALUES (@v_bookkey,@v_new_key,@v_categorytableid,@v_categorycode,@v_categorysubcode,@v_sortorder,@i_userid,GETDATE(),NULL)
          SET @o_writehistoryind = 1
          SET @v_errmsg = 'Subject Category added'
          EXECUTE imp_write_feedback @i_batch, @i_row, @v_elementkey, @i_elementseq ,@i_dmlkey , @v_errmsg, 1, 3 
        end
      ELSE
        begin
          SET @v_errmsg = 'Err: ('+ COALESCE(cast(@v_categorycode as varchar),'code?') +'/'+ COALESCE(cast(@v_categorysubcode as varchar),'subcode?')+') tableid '+COALESCE(cast(@v_categorytableid as varchar),'tableid?')
          EXECUTE imp_write_feedback @i_batch, @i_row, @v_elementkey, @i_elementseq ,@i_dmlkey , @v_errmsg, 2, 3 
        END
    end
END