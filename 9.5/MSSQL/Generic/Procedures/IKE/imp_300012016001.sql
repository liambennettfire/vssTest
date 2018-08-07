/******************************************************************************
**  Name: imp_300012016001
**  Desc: IKE Generate Pub Month & Year from Pub Date
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

IF EXISTS (SELECT * FROM dbo.sysobjects	WHERE id = object_id(N'[dbo].[imp_300012016001]') AND OBJECTPROPERTY(id, N'IsProcedure') = 1)
	DROP PROCEDURE [dbo].[imp_300012016001]
GO

create PROCEDURE [dbo].[imp_300012016001] 
  
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

/* Generate Pub Month & Year from Pub Date */

BEGIN 

SET NOCOUNT ON
/* DEFINE BATCH VARIABLES    */
DECLARE @v_elementval    VARCHAR(4000),
  @v_errcode INT,
  @v_errmsg VARCHAR(4000),
  @v_elementdesc VARCHAR(4000),
  @v_elementkey BIGINT,
  @v_lobcheck VARCHAR(20),
  @v_lobkey INT,
  @v_printingkey INT,
  @v_bookkey INT
/*  DEFINE LOCAL VARIABLES    */
DECLARE @v_pubmonth INT,
  @v_pubyear INT,
  @v_pubmonthcode INT,
  @v_pubmonthdesc varchar(80),
  @v_pubdate DATETIME,
  @v_pubmonthcode_org INT,
  @v_pubdate_org DATETIME,
  @DEBUG int =0

BEGIN
  SET @o_writehistoryind = 0
  SET @v_errcode = 1
  SET @v_errmsg = 'Pub Month Year Updated'
  SET @v_bookkey = dbo.resolve_keyset(@i_titlekeyset,1)
  SET @v_pubmonth = 0
  SET @v_pubmonthcode = 0

  SELECT @v_elementval =  COALESCE(originalvalue,''), @v_elementkey = b.elementkey
    FROM imp_batch_detail b , imp_DML_elements d
    WHERE b.batchkey = @i_batch
      AND b.row_id = @i_row
      AND b.elementseq = @i_elementseq
      AND b.elementkey = d.elementkey
      AND d.DMLkey = @i_dmlkey

  set @v_pubdate = dbo.resolve_date (@v_elementval)

  set @v_pubmonthcode = DATEPART(month,@v_pubdate)
  set @v_pubyear = DATEPART(year,@v_pubdate)
  
  select  @v_pubdate_org=pubmonth, @v_pubmonthcode_org=pubmonthcode
    from printing
	WHERE bookkey = @v_bookkey
      AND printingkey = 1

  if coalesce(@v_pubdate_org,getdate())<>@v_pubdate and
     coalesce(@v_pubmonthcode_org,99)<>@v_pubmonthcode
    begin
      IF @DEBUG <> 0 print '.pubdate comp.'
      IF @DEBUG <> 0 print @v_pubdate
      IF @DEBUG <> 0 print @v_pubdate_org
      IF @DEBUG <> 0 print '.pub month comp.'
      IF @DEBUG <> 0 print @v_pubmonthcode
      IF @DEBUG <> 0 print @v_pubmonthcode_org

      UPDATE printing
        SET pubmonth=@v_pubdate ,pubmonthcode=@v_pubmonthcode, lastuserid=@i_userid, lastmaintdate=getdate()
        WHERE bookkey = @v_bookkey
          AND printingkey = 1
      SET @o_writehistoryind = 1
    end

  IF @v_errcode >= @i_level
    BEGIN
      EXECUTE imp_write_feedback @i_batch, @i_row, @v_elementkey, @i_elementseq ,@i_dmlkey , @v_errmsg, @i_level, 3     
    END

  IF @DEBUG <> 0 print '.history ind.'
  IF @DEBUG <> 0 print @o_writehistoryind


END

end

