/******************************************************************************
**  Name: imp_300012006001
**  Desc: IKE Add/Replace Format by short short
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

if exists (select * from dbo.sysobjects where id = object_id(N'[dbo].[imp_300012006001]') and OBJECTPROPERTY(id, N'IsProcedure') = 1)
drop procedure [dbo].[imp_300012006001]
GO

CREATE PROCEDURE dbo.imp_300012006001 
  
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

/* Add/Replace Format by short short */

BEGIN 

SET NOCOUNT ON
DECLARE @v_elementval VARCHAR(4000),
  @v_errcode INT,
  @v_errmsg VARCHAR(4000),
  @v_elementdesc VARCHAR(4000),
  @v_elementkey BIGINT,
  @v_lobcheck VARCHAR(20),
  @v_lobkey INT,
  @v_bookkey INT,
  @v_formatcode INT,
  @v_formatcode_org INT,
  @v_media INT,
  @v_media_new INT,
  @v_hit INT
  
BEGIN
  SET @v_hit = 0
  SET @v_formatcode_org = 0
  SET @v_formatcode = 0
  SET @o_writehistoryind = 0
  SET @v_errcode = 1
  SET @v_errmsg = 'format updated'
  SET @v_bookkey = dbo.resolve_keyset(@i_titlekeyset,1)

/*  GET IMPORTED format       */
  SELECT @v_elementval =  LTRIM(RTRIM(originalvalue)),@v_elementkey = b.elementkey
    FROM imp_batch_detail b , imp_DML_elements d
    WHERE b.batchkey = @i_batch
      AND b.row_id = @i_row
      AND b.elementseq = @i_elementseq
      AND d.dmlkey = @i_dmlkey
      AND d.elementkey = b.elementkey

/* GET CURRENT CURRENT FORMAT VALUE    */
  SELECT @v_media = mediatypecode,@v_formatcode_org = COALESCE(mediatypesubcode,-1)
    FROM bookdetail
    WHERE bookkey=@v_bookkey 

/* FIND IMPORT format ON GENTABLES     */  
  SELECT @v_hit = COUNT(*)
    FROM subgentables
    WHERE tableid = 312  
      AND datadescshort = @v_elementval

  IF @v_hit = 1
    BEGIN
      SELECT @v_formatcode = datasubcode, @v_media_new=datacode
        FROM subgentables
        WHERE tableid = 312  
          AND datadescshort = @v_elementval
  if @v_media is null
    begin
      set @v_media=@v_media_new
    end
  /* IF VALUE HAS CHANGED - UPDATE BOOKDETAIL AND SET WRITE HISTORY INDICATOR  */
      IF @v_formatcode <> @v_formatcode_org 
        and (@v_media is not null and @v_formatcode is not null)
        BEGIN
          UPDATE bookdetail
            SET mediatypecode = @v_media,
              mediatypesubcode = @v_formatcode,
              lastuserid = @i_userid,
              lastmaintdate = GETDATE()
            WHERE bookkey = @v_bookkey
          SET @o_writehistoryind = 1
        END
      END
  ELSE      
    BEGIN
      SET @v_errcode = 1
      SET @v_errmsg = 'Can not find ('+@v_elementval+') value on Format User Table(312).  Format was not updated'
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

GRANT EXECUTE ON dbo.[imp_300012006001] to PUBLIC 
GO
