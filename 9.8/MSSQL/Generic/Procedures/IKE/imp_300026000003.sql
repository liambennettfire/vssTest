/******************************************************************************
**  Name: imp_300026000003
**  Desc: IKE Insert Book Author
**  Auth: Bennett     
**  Date: 5/9/2016
*******************************************************************************
**  Change History
*******************************************************************************
**  Date:        Author:     Description:
*   --------     --------    -------------------------------------------
**  5/9/2016     Bennett     original
**  5/20/16      Kusum       Case 37304 - increased size of datadesc VARCHAR(MAX) 
**                           to allow for alternatedesc1
**  5/24/2016    Kusum       Case 36769
*******************************************************************************/
	
SET QUOTED_IDENTIFIER ON 
GO
SET ANSI_NULLS ON 
GO

if exists (select * from dbo.sysobjects where id = object_id(N'[dbo].[imp_300026000003]') and OBJECTPROPERTY(id, N'IsProcedure') = 1)
drop procedure [dbo].[imp_300026000003]
GO

CREATE PROCEDURE dbo.imp_300026000003 @i_batch int,@i_row int ,@i_dmlkey bigint,@i_titlekeyset varchar(500),@i_contactkeyset varchar(500),
  @i_templatekey int,@i_elementseq int,@i_level int,@i_userid varchar(50),@i_newtitleind int,@i_newcontactind int,@o_writehistoryind int output
AS

/* Insert Book Author */

BEGIN 

DECLARE 
  @v_errcode INT,
  @v_errmsg  VARCHAR(4000),
  @v_qerrmsg  VARCHAR(4000),
  @v_qerrcode  INT,
  @v_bookkey  INT,
  @v_printingkey INT,
  @v_authorkey  INT,
  @v_count  INT,
  @v_count2 INT,
  @v_sortorder  INT,
  @v_authorrole  VARCHAR(4000),
  @v_primary VARCHAR(4000),
  @v_primaryind INT,
  @v_reportind INT,
  @v_datacode  INT,
  @v_datadesc  VARCHAR(MAX),
  @v_transtype VARCHAR(15),
  @v_historymsg VARCHAR(2000),
  @v_historycode INT
BEGIN

	SET @v_bookkey = dbo.resolve_keyset(@i_titlekeyset,1)
	SET @v_printingkey = dbo.resolve_keyset(@i_titlekeyset,2)
	SET @v_authorkey = dbo.resolve_keyset(@i_contactkeyset,1)
	SET @o_writehistoryind = 0
	SET @v_errcode = 1
	SET @v_errmsg = 'Book Author Inserted'
	
	
	SELECT @v_count = count(*) FROM bookauthor WHERE bookkey = @v_bookkey  AND authorkey = @v_authorkey
	
	IF @v_count = 0 BEGIN
	  SELECT @v_authorrole = originalvalue FROM imp_batch_detail b 
	   WHERE b.batchkey = @i_batch
		 AND b.row_id = @i_row
		 AND b.elementseq = @i_elementseq
		 AND b.elementkey = 100026003  --Author Role
		 
		 
	  SELECT @v_reportind = originalvalue FROM imp_batch_detail b 
	   WHERE b.batchkey = @i_batch
		 AND b.row_id = @i_row
		 AND b.elementseq = @i_elementseq
		 AND b.elementkey = 100026011  --Author Report Indicator
		 
		 
	  SELECT @v_primary = originalvalue FROM imp_batch_detail b 
	   WHERE b.batchkey = @i_batch
		 AND b.row_id = @i_row
		 AND b.elementseq = @i_elementseq
		 AND b.elementkey = 100026012 --Author Primary Indicator (book)
		 
		 
	  SELECT @v_sortorder = COALESCE(originalvalue,0) FROM imp_batch_detail b 
	   WHERE b.batchkey = @i_batch
		 AND b.row_id = @i_row
		 AND b.elementseq = @i_elementseq
		 AND b.elementkey = 100026014  --Author Sort Order
		 
		 
	  IF @v_authorrole IS NOT NULL BEGIN
	  
		SELECT @v_datacode = datacode FROM gentables WHERE tableid = 134 AND datadesc = @v_authorrole 
		
		EXEC dbo.find_gentables_mixed @v_authorrole,134,@v_datacode output,@v_datadesc output
		
		if @v_datacode is null begin
			SELECT @v_datacode = datacode FROM gentables WHERE tableid = 134 AND bisacdatacode = @v_authorrole
		 end
	   END
	  ELSE BEGIN
	  	SELECT @v_datacode = datacode FROM gentables WHERE tableid = 134 AND datadesc = 'Author'
	  END
	  
	  IF @v_primary IS NULL BEGIN
		SET @v_primaryind = 0
	  END
	  ELSE BEGIN
		  SET @v_primaryind = CASE
			 WHEN UPPER(@v_primary) IN ('Y','YES') THEN 1 ELSE 0
			END
	  END
	  
	  SET @v_count2 = 0 
	  IF @v_primaryind = 1 BEGIN
		SELECT @v_count2 = count(*) FROM bookauthor WHERE bookkey = @v_bookkey  AND primaryind = 1
		IF @v_count2 = 1 BEGIN
			SET @v_errmsg = 'There is already a bookauthor row for this bookkey where primaryind = 1. Primaryind for this row will be set to 0. Book Author Inserted'
			SET @v_errcode = 1
			SET @v_primaryind = 0
		END
	  END
	 	
	  IF @v_reportind IS NULL BEGIN
		SET @v_reportind = 1
	  END
		  
	  IF @v_sortorder is NULL BEGIN
		SELECT @v_sortorder = COALESCE(sortorder,0) FROM bookauthor WHERE bookkey = @v_bookkey 
		IF @v_sortorder IS NULL
		 SET @v_sortorder = 1
		ELSE
		 SELECT @v_sortorder = MAX(sortorder)+1 FROM bookauthor
		  WHERE bookkey = @v_bookkey
	   END
		   
	   INSERT INTO bookauthor (bookkey,authorkey,authortypecode,primaryind,reportind,history_order,sortorder,lastuserid,lastmaintdate)
		   VALUES (@v_bookkey,@v_authorkey,@v_datacode,@v_primaryind,@v_reportind,@v_sortorder,@v_sortorder,@i_userid,getdate())
			   
	    EXEC qcontact_verify_or_add_author_role @v_authorkey,@v_datacode,@v_qerrcode,@v_qerrmsg
			  
		IF @@ROWCOUNT = 1 BEGIN
			IF @i_newcontactind = 1 
			  SET @v_transtype = 'insert'
			ELSE 
			  SET @v_transtype = 'update'
				
			EXECUTE qtitle_update_titlehistory 'bookauthor','authortypecode',@v_bookkey,@v_printingkey,0,
			 @v_authorrole,'insert',@i_userid,@v_sortorder,null,@v_historycode output, @v_historymsg output  
			EXECUTE qtitle_update_titlehistory 'bookauthor','primaryind',@v_bookkey,@v_printingkey,0,
			 @v_primaryind,'insert',@i_userid,@v_sortorder,null,@v_historycode output, @v_historymsg output 
		  END
		 END
		
		
		IF @v_errcode >= @i_level BEGIN
		  EXECUTE imp_write_feedback @i_batch, @i_row, 100026000, @i_elementseq ,@i_dmlkey , @v_errmsg, @v_errcode, 3
		END
	
END
END
GO

SET QUOTED_IDENTIFIER OFF 
GO
SET ANSI_NULLS ON 
GO

GRANT EXECUTE ON dbo.[imp_300026000003] to PUBLIC 
GO
