/******************************************************************************
**  Name: imp_300016002001
**  Desc: IKE remove audience
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

if exists (select * from dbo.sysobjects where id = object_id(N'[dbo].[imp_300016002001]') and OBJECTPROPERTY(id, N'IsProcedure') = 1)
drop procedure [dbo].[imp_300016002001]
GO

CREATE PROCEDURE dbo.imp_300016002001 
  
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

/* remove bookaudience rows not found  on the import */

DECLARE @v_elementval    VARCHAR(4000),
  @v_errcode    INT,
  @v_errmsg     VARCHAR(4000),
  @v_elementdesc    VARCHAR(4000),
  @v_elementkey    BIGINT,
  @v_lobcheck     VARCHAR(20),
  @v_lobkey     INT,
  @v_bookkey     INT,
  @v_hit      INT,
  @v_sortorder    INT,
  @v_rowcount    INT,
  @v_datacode    INT,
  @v_audiencecode    INT,
  @v_audience    INT
  
BEGIN

  SET @v_hit = 0
  SET @v_sortorder = 0
  SET @v_rowcount = 0
  SET @v_audience = 0
  SET @v_audience = 0
  SET @o_writehistoryind = 0
  SET @v_errcode = 1
  SET @v_bookkey = dbo.resolve_keyset(@i_titlekeyset,1)
  
  SELECT audiencecode
    into #audiences
    FROM bookaudience b
    WHERE bookkey=@v_bookkey
    
  DELETE #audiences
    WHERE audiencecode IN  
      (SELECT datacode
         FROM imp_batch_detail ibd, gentables g
         WHERE elementkey=100016001
           AND batchkey=@i_batch
           and row_id=@i_row
           and tableid=460
           and (datadesc = originalvalue or externalcode = originalvalue))
      
  SELECT TOP 1 @v_audiencecode=audiencecode FROM #audiences ia
  WHILE @v_audiencecode IS NOT NULL
     BEGIN
       DELETE FROM bookaudience WHERE bookkey=@v_bookkey AND audiencecode=@v_audiencecode
       set @v_errmsg='book audience row removed('+cast(@v_audiencecode as varchar)+')'
       EXECUTE imp_write_feedback @i_batch, @i_row, @v_elementkey, @i_elementseq ,@i_dmlkey , @v_errmsg, @i_level, 3     
       delete #audiences WHERE audiencecode=@v_audiencecode
       SET @v_audiencecode=null
       SELECT TOP 1 @v_audiencecode=audiencecode FROM #audiences ia
     END
    
END
GO
SET QUOTED_IDENTIFIER OFF 
GO
SET ANSI_NULLS ON 
GO

GRANT EXECUTE ON dbo.[imp_300016002001] to PUBLIC 
GO
