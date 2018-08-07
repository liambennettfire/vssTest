/******************************************************************************
**  Name: imp_100012075001
**  Desc: IKE Title break out
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

if exists (select * from dbo.sysobjects where id = object_id(N'[dbo].[imp_100012075001]') and OBJECTPROPERTY(id, N'IsProcedure') = 1)
drop procedure [dbo].[imp_100012075001]
GO

CREATE PROCEDURE dbo.imp_100012075001 
  
  @i_batchkey int,
  @i_row int,
--  @i_elementkey int,
  @i_elementseq int,
  @i_templatekey int,
  @i_rulekey bigint,
  @i_level int,
  @i_userid varchar(50)
AS

/* Title break out */

BEGIN 

DECLARE  @v_errcode   INT,
  @v_new_seq   INT,
  @v_title   VARCHAR(4000),
  @v_titleprefix  VARCHAR(4000),  
  @v_shorttitle  VARCHAR(4000),  
  @v_errlevel   INT,
  @v_msg     VARCHAR(4000),
  @v_pricetype  VARCHAR(40)

BEGIN
  SET @v_errcode = 0
  SET @v_errlevel = 0
  SET @v_msg = 'Title: prefix and short title expand'

  SELECT @v_title = originalvalue
    FROM imp_batch_detail 
    WHERE batchkey = @i_batchkey
      and row_id = @i_row
      and elementseq = @i_elementseq
      and elementkey = 100012075

  set @v_shorttitle = substring(@v_title,1,50)

  if substring(@v_title,1,4)='The ' 
    and len(@v_title)>4
    begin
      set @v_titleprefix=substring(@v_title,1,3)
      set @v_title=substring(@v_title,5,500)
    end 
  if substring(@v_title,1,3)='An ' and @v_titleprefix is null 
    and len(@v_title)>3
    begin
      set @v_titleprefix=substring(@v_title,1,2)
      set @v_title=substring(@v_title,4,500)
    end 
  if substring(@v_title,1,2)='A ' and @v_titleprefix is null
    and len(@v_title)>2
    begin
      set @v_titleprefix=substring(@v_title,1,1)
      set @v_title=substring(@v_title,3,500)
    end 

  INSERT INTO imp_batch_detail(batchkey,row_id,elementkey,elementseq,originalvalue,lastuserid,lastmaintdate)
    VALUES (@i_batchkey,@i_row,100012024,@i_elementseq,@v_shorttitle,'loader_rule_100012075001',getdate())

  INSERT INTO imp_batch_detail(batchkey,row_id,elementkey,elementseq,originalvalue,lastuserid,lastmaintdate)
    VALUES (@i_batchkey,@i_row,100012027,@i_elementseq,@v_title,'loader_rule_100012075001',getdate())

  if @v_titleprefix is not null
    begin
      INSERT INTO imp_batch_detail(batchkey,row_id,elementkey,elementseq,originalvalue,lastuserid,lastmaintdate)
        VALUES (@i_batchkey,@i_row,100012028,@i_elementseq,@v_titleprefix,'loader_rule_100012075001',getdate())
    end

  IF @v_errlevel >= @i_level 
    BEGIN
      EXECUTE imp_write_feedback @i_batchkey, @i_row, null, @i_elementseq, @i_rulekey , @v_msg, @v_errlevel, 1
    END

END

end

GO
SET QUOTED_IDENTIFIER OFF 
GO
SET ANSI_NULLS ON 
GO

GRANT EXECUTE ON dbo.[imp_100012075001] to PUBLIC 
GO
