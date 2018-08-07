/******************************************************************************
**  Name: imp_100012050001
**  Desc: IKE Set Media Defaults from Format
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

if exists (select * from dbo.sysobjects where id = object_id(N'[dbo].[imp_100012050001]') and OBJECTPROPERTY(id, N'IsProcedure') = 1)
drop procedure [dbo].[imp_100012050001]
GO

CREATE PROCEDURE dbo.imp_100012050001 
  
  @i_batchkey int,
  @i_row int,
--  @i_elementkey int,
  @i_elementseq int,
  @i_templatekey int,
  @i_rulekey bigint,
  @i_level int,
  @i_userid varchar(50)
AS

/* Set Media Defaults from Format */

BEGIN 

DECLARE 
  @v_media     VARCHAR(4000),
  @v_format     VARCHAR(4000),
  @v_errlevel     INT,
  @v_msg       VARCHAR(4000),
  @v_count    INT,
  @v_fmsg      VARCHAR(4000),
  @v_datacode int,
  @v_datasubcode int,
  @v_datadesc VARCHAR(4000)

BEGIN
  SET @v_errlevel = 0
  SET @v_media = NULL
  SET @v_format = NULL
  SET @v_count = 0
  SET @v_datacode = NULL
  SET @v_datasubcode = NULL
  SET @v_msg = 'Inserted Media from Format'
  
  SELECT @v_media = originalvalue
    FROM imp_batch_detail
    WHERE batchkey=@i_batchkey
      AND row_id=@i_row
      AND elementseq=@i_elementseq
      AND elementkey=100012051
  SELECT @v_format = originalvalue
    FROM imp_batch_detail
    WHERE batchkey=@i_batchkey
      AND row_id=@i_row
      AND elementseq=@i_elementseq
      AND elementkey=100012050
  
  exec dbo.find_subgentables_mixed  @v_format,312,@v_datacode output,@v_datasubcode output,@v_datadesc output
   
  IF @v_media IS NULL
    BEGIN
      IF @v_format IS NOT NULL AND @v_format NOT IN ('CDROM','ROM')
        BEGIN

          IF @v_datacode is not null
            BEGIN
			  --mk> commented out the following line because @v_datacode was already figured out above in exec dbo.find_subgentables_mixed  
			  -- ... plus this routine expects a format ... looking a format up on gentables isn't going to work anyway
              --exec dbo.find_gentables_mixed  @v_format,312,@v_datacode output,@v_datadesc output
              SELECT @v_media = datadesc
                FROM gentables
                WHERE tableid = 312
                  AND datacode = @v_datacode
              INSERT INTO imp_batch_detail(batchkey,row_id,elementkey,elementseq,originalvalue,lobkey,lastuserid,lastmaintdate)
                VALUES (@i_batchkey,@i_row,100012051,@i_elementseq,@v_media,NULL,'imp_load_master',getdate())
              SET @v_msg = 'Defaulted Media to ('+COALESCE(@v_media,'*NULL*')+') based upon the Format Description ('+COALESCE(@v_format,'*NULL*')+')'
              SET @v_errlevel = 1
            END  
          ELSE
            BEGIN
              SET @v_fmsg = 'Can not find a distinct Format Description ('+COALESCE(@v_format,'*NULL*')+') in gentables'
              SET @v_errlevel = 1
              EXECUTE imp_write_feedback @i_batchkey, @i_row, 100012050, @i_elementseq, 100012050001 , @v_fmsg, @v_errlevel, 1
            END
        END
                  
      IF @v_format IN ('ROM','CDROM')
        BEGIN
          SET @v_media = 'CD-ROM'
          SET @v_format = 'Other'
          INSERT INTO imp_batch_detail(batchkey,row_id,elementkey,elementseq,originalvalue,lobkey,lastuserid,lastmaintdate)
            VALUES (@i_batchkey,@i_row,100012051,@i_elementseq,@v_media,NULL,'imp_load_master',getdate())
          UPDATE imp_batch_detail
            SET originalvalue = 'Other'
            WHERE batchkey = @i_batchkey
              AND row_id = @i_row
              AND elementseq = @i_elementseq
              AND elementkey = 100012050
          SET @v_msg = 'Defaulted Media to ('+COALESCE(@v_media,'*NULL*')+') based upon the Format Description ('+@v_format
              +') and then modified the loaded format to an exact match of existing formats'
          SET @v_errlevel = 1
        END
    END
  IF @v_errlevel >= @i_level 
    BEGIN
      EXECUTE imp_write_feedback @i_batchkey, @i_row, 100012050, @i_elementseq, 100012050001 , @v_msg, @v_errlevel, 1
    END
END

end

GO
SET QUOTED_IDENTIFIER OFF 
GO
SET ANSI_NULLS ON 
GO

GRANT EXECUTE ON dbo.[imp_100012050001] to PUBLIC 
GO
