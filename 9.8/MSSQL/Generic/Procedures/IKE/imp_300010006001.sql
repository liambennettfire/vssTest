/******************************************************************************
**  Name: imp_300010006001
**  Desc: IKE LCCN update
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

IF EXISTS (SELECT * FROM dbo.sysobjects	WHERE id = object_id(N'[dbo].[imp_300010006001]') AND OBJECTPROPERTY(id, N'IsProcedure') = 1)
	DROP PROCEDURE [dbo].[imp_300010006001]
GO

create PROCEDURE [dbo].[imp_300010006001]
  
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
DECLARE @v_elementval VARCHAR(4000),
  @v_errcode INT,
  @v_errmsg VARCHAR(4000),
  @v_elementdesc VARCHAR(4000),
  @v_lobcheck VARCHAR(20),
  @v_lobkey INT,
  @v_bookkey INT ,   
  @v_isbnkey INT,
  @v_item_number      VARCHAR(20),
  @v_item_number_org  VARCHAR(20),
  @v_warning     VARCHAR(2000)
  
BEGIN
  SET @o_writehistoryind = 0
  SET @v_errcode = 1   
  SET @v_errmsg = 'LCCN'
  SET @v_bookkey = dbo.resolve_keyset(@i_titlekeyset,1)      

  SELECT @v_item_number = originalvalue
    FROM imp_batch_detail 
    WHERE batchkey = @i_batch
      AND row_id = @i_row
      AND elementseq = @i_elementseq
      AND elementkey = 100010007

  select @v_item_number_org = itemnumber
    from isbn
    where bookkey=@v_bookkey

  if @v_item_number_org <> @v_item_number or 
    (@v_item_number_org is null and @v_item_number is not null)
    begin
      UPDATE isbn 
        SET 
          LCCN = @v_item_number,
          lastuserid = @i_userid,
          lastmaintdate = GETDATE()
        WHERE bookkey = @v_bookkey
      SET @o_writehistoryind = 1
      SET @v_errmsg = 'LCCN updated'
    END
  else
    begin
      SET @o_writehistoryind = 0
      SET @v_errmsg = 'LCCN unchanged'
    end

  IF @v_errcode >= @i_level    
    BEGIN        
      EXECUTE imp_write_feedback @i_batch, @i_row, null, @i_elementseq ,'300010006001' , @v_errmsg, @v_errcode, 3      
    END
END

/*     END SPROC     */
END

