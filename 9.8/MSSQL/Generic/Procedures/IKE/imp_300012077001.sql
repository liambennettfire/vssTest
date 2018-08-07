/******************************************************************************
**  Name: imp_300012077001
**  Desc: IKE  All ages indicator
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

if exists (select * from dbo.sysobjects where id = object_id(N'[dbo].[imp_300012077001]') and OBJECTPROPERTY(id, N'IsProcedure') = 1)
drop procedure [dbo].[imp_300012077001]
GO

CREATE PROCEDURE dbo.imp_300012077001 
  
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

/* All ages indicator */

BEGIN 

DECLARE
  @v_elementval    float,
  @v_errcode    INT,
  @v_errmsg     VARCHAR(4000),
  @v_elementdesc    VARCHAR(4000),
  @v_age_org    int,
  @v_age_new    int,
  @v_bookkey     INT

BEGIN
  SET @o_writehistoryind = 0
  SET @v_errcode = 1
  SET @v_errmsg = 'All Ages Ind'
  SET @v_bookkey = dbo.resolve_keyset(@i_titlekeyset,1)

  SELECT @v_elementval =  COALESCE(originalvalue,0)
    FROM imp_batch_detail
    WHERE batchkey = @i_batch
      AND row_id = @i_row
      AND elementseq = @i_elementseq
      AND elementkey = 100012077
  select @v_age_org=allagesind
    from bookdetail
    where bookkey=@v_bookkey
        
  if ISNUMERIC(@v_elementval)=1
    begin
      set @v_age_new=@v_elementval
    end

  IF @v_age_org <> @v_age_new or
     (@v_age_org is null and @v_age_new is not null)  
    BEGIN
      UPDATE bookdetail
        SET allagesind= @v_elementval,
            lastuserid = @i_userid,
            lastmaintdate = getdate()
        WHERE bookkey = @v_bookkey
      SET @o_writehistoryind = 1
      SET @v_errmsg = @v_errmsg +' updated'
    END
  else
    begin
      SET @o_writehistoryind = 0
      SET @v_errmsg = @v_errmsg +' unchanged'
    end

  EXECUTE imp_write_feedback @i_batch, @i_row, '100012077', @i_elementseq ,@i_dmlkey , @v_errmsg, @i_level, 3     
END

end

GO
SET QUOTED_IDENTIFIER OFF 
GO
SET ANSI_NULLS ON 
GO

GRANT EXECUTE ON dbo.imp_300012077001 to PUBLIC 
GO
