/******************************************************************************
**  Name: imp_300010019001
**  Desc: IKE Add/Replace Replaced BY ISBN
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

if exists (select * from dbo.sysobjects where id = object_id(N'[dbo].[imp_300010019001]') and OBJECTPROPERTY(id, N'IsProcedure') = 1)
drop procedure [dbo].[imp_300010019001]
GO

CREATE PROCEDURE dbo.imp_300010019001
  
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

/* Add/Replace Replaced BY ISBN */

BEGIN 

DECLARE 
	@v_elementval		VARCHAR(4000)
	,@v_errcode			INT
	,@v_errmsg			VARCHAR(4000)
	,@v_elementdesc		VARCHAR(4000)
	,@v_elementkey		BIGINT
	,@v_bookkey			INT
	,@v_count			INT
	,@v_sortorder		INT
	,@v_subjectcode		INT
	,@v_subjectsubcode	INT
	,@v_NEW_sortorder	INT
  	,@v_RelationCode	varchar(50)
	,@v_ProductIDType	varchar(50)
	,@v_IDValue			varchar(50)
	,@v_RelatedBookKey	int
	,@Debug				INT
	,@v_Rel2EloInd		INT
	,@v_SubGenRel2EloInd INT

BEGIN
	SET @Debug = 0
	SET @v_bookkey = dbo.resolve_keyset(@i_titlekeyset,1)
  
	/**************************************************************
	INSTRUCTIONS:
	01) this routine handles the related products for a given title
	02) the element that contains the relatedproduct id (isbn,ean,...) is 100010019
	03) get the nodes for this sequence to get type of ID passed in & type of related product
	04) These VALUES are in these element keys 100010017 & 100010018 for current @i_elementseq
	**************************************************************/
  
	SELECT 
		@v_RelationCode=LTRIM(RTRIM(originalvalue))
	FROM 
		imp_batch_detail b
	WHERE 
		b.batchkey = @i_batch
		AND b.row_id = @i_row
		AND b.elementseq = @i_elementseq
		AND b.elementkey = 100010017

	SELECT 
		@v_ProductIDType=LTRIM(RTRIM(originalvalue))
	FROM 
		imp_batch_detail b
	WHERE 
		b.batchkey = @i_batch
		AND b.row_id = @i_row
		AND b.elementseq = @i_elementseq
		AND b.elementkey = 100010018

	SELECT 
		@v_IDValue=LTRIM(RTRIM(originalvalue))
	FROM 
		imp_batch_detail b
	WHERE 
		b.batchkey = @i_batch
		AND b.row_id = @i_row
		AND b.elementseq = @i_elementseq
		AND b.elementkey = 100010019

	SELECT 
		@v_Rel2EloInd=coalesce(LTRIM(RTRIM(originalvalue)),0)
	FROM 
		imp_batch_detail b
	WHERE 
		b.batchkey = @i_batch
		AND b.row_id = @i_row
		AND b.elementseq = @i_elementseq
		AND b.elementkey = 100010020
		
	if @Debug<>0 print '@v_RelationCode = ' + cast(@v_RelationCode as varchar(max))
	if @Debug<>0 print '@v_ProductIDType = ' + cast(@v_ProductIDType as varchar(max))
	if @Debug<>0 print '@v_IDValue = ' + cast(@v_IDValue as varchar(max))
	if @Debug<>0 print '@v_Rel2EloInd = ' + cast(@v_Rel2EloInd as varchar(max))
	
	/**************************************************************
	05) get the datacode/datasubcode for @v_RelationCode (tableID=440)
	**************************************************************/

	SELECT 
		@v_subjectcode = datacode 
		,@v_subjectsubcode = datasubcode
		,@v_SubGenRel2EloInd = coalesce(exporteloquenceind,0)
	FROM 
		subgentables 
	WHERE 
		tableid=440
		and eloquencefieldtag = @v_RelationCode
		and deletestatus = 'N'

	if @Debug<>0 print '@v_subjectcode = ' + cast(@v_subjectcode as varchar(max))
	if @Debug<>0 print '@v_subjectsubcode = ' + cast(@v_subjectsubcode as varchar(max))

	/**************************************************************
	06) figure out what kind of ID is being passed in (EAN, EAN13, ISBN, ...)
	07) and get the bookkey FROM ISBN table using the correct column name
	**************************************************************/

	SELECT 
		@v_RelatedBookKey = coalesce(bookkey,0)
	FROM 
		isbn 
	WHERE
		CASE 
			WHEN @v_ProductIDType='02' AND ISBN10=@v_IDValue THEN 1
			WHEN @v_ProductIDType='03' AND EAN13=@v_IDValue THEN 1
			WHEN @v_ProductIDType='04' AND UPC=@v_IDValue THEN 1
			WHEN @v_ProductIDType='13' AND EAN13=@v_IDValue THEN 1
			WHEN @v_ProductIDType='14' AND ItemNumber=@v_IDValue THEN 1
			WHEN @v_ProductIDType='15' AND EAN13=@v_IDValue THEN 1
			ELSE 0
		END = 1	

	if @Debug<>0 print '@v_RelatedBookKey = ' + cast(@v_RelatedBookKey as varchar(max))
	
	/**************************************************************
	08) Check associatedtitles to see if association exists if not then INSERT
	**************************************************************/					
	
	if @v_RelatedBookKey > 0
		BEGIN
			SELECT 
				@v_count=count(*)
			FROM 
				associatedtitles
			WHERE 
				bookkey = @v_bookkey
				and (associatetitlebookkey=@v_RelatedBookKey OR ISBN = @v_IDValue)	
				and associationtypecode = @v_subjectcode
				and associationtypesubcode = @v_subjectsubcode
			
			if @v_count=0 
				BEGIN
					SELECT 
						@v_sortorder = COALESCE(MAX(sortorder),0)
					FROM 
						associatedtitles
					WHERE 
						bookkey = @v_bookkey
					
					SET @v_NEW_sortorder=@v_sortorder + 1
								
					INSERT into associatedtitles
					(bookkey,associationtypecode,associationtypesubcode,associatetitlebookkey,sortorder,isbn,lastmaintdate,releasetoeloquenceind,productidtype)
					VALUES
					(@v_bookkey,@v_subjectcode,@v_subjectsubcode,@v_RelatedBookKey,@v_NEW_sortorder,@v_IDValue,getdate(),@v_Rel2EloInd * @v_SubGenRel2EloInd,
							case 
								when (LEN(@v_IDValue)=10 and charindex('-',@v_IDValue)=0) then 2
								when (LEN(@v_IDValue)=13 and charindex('-',@v_IDValue)=0) then 2
								when (LEN(@v_IDValue)=13 and charindex('-',@v_IDValue)<>0) then 1
								when (LEN(@v_IDValue)=17 and charindex('-',@v_IDValue)<>0) then 2
								else 0
							end	 )
				END    
			
			SET @v_errcode= 1
			SET @v_errmsg = 'Related Products have been updated'
			EXECUTE imp_write_feedback @i_batch, @i_row, @v_elementkey, @i_elementseq ,@i_dmlkey , @v_errmsg, @v_errcode, 3
		END
	ELSE
		BEGIN
			SELECT 
				@v_count=count(*)
			FROM 
				associatedtitles
			WHERE 
				bookkey = @v_bookkey
				and ISBN = @v_IDValue	
				and associationtypecode = @v_subjectcode
				and associationtypesubcode = @v_subjectsubcode
			
			if @v_count=0 
				BEGIN
					SELECT 
						@v_sortorder = COALESCE(MAX(sortorder),0)
					FROM 
						associatedtitles
					WHERE 
						bookkey = @v_bookkey
					
					SET @v_NEW_sortorder=@v_sortorder + 1
								
					INSERT into associatedtitles
					(bookkey,associationtypecode,associationtypesubcode,associatetitlebookkey,sortorder,isbn,lastmaintdate,releasetoeloquenceind,productidtype)
					VALUES
					(@v_bookkey,@v_subjectcode,@v_subjectsubcode,0,@v_NEW_sortorder,@v_IDValue,getdate(),@v_Rel2EloInd * @v_SubGenRel2EloInd,
							case 
								when (LEN(@v_IDValue)=10 and charindex('-',@v_IDValue)=0) then 2
								when (LEN(@v_IDValue)=13 and charindex('-',@v_IDValue)=0) then 2
								when (LEN(@v_IDValue)=13 and charindex('-',@v_IDValue)<>0) then 1
								when (LEN(@v_IDValue)=17 and charindex('-',@v_IDValue)<>0) then 2
								else 0
							end	 )
				END    
			
			SET @v_errcode= 1
			SET @v_errmsg = 'Related external Products have been updated.'
			EXECUTE imp_write_feedback @i_batch, @i_row, @v_elementkey, @i_elementseq ,@i_dmlkey , @v_errmsg, @v_errcode, 3		END
	
	if @Debug<>0 print @v_errmsg

END

end

GO
SET QUOTED_IDENTIFIER OFF 
GO
SET ANSI_NULLS ON 
GO

GRANT EXECUTE ON dbo.[imp_300010019001] to PUBLIC 
GO

