SET QUOTED_IDENTIFIER ON 
GO
SET ANSI_NULLS ON 
GO

IF EXISTS (SELECT * FROM dbo.sysobjects WHERE id = Object_id('dbo.EoD_turnoff_review_quotes') AND (type = 'P' or type = 'RF')) BEGIN
	DROP PROC EoD_turnoff_review_quotes 
END
GO

CREATE PROCEDURE dbo.EoD_turnoff_review_quotes 
	(@i_bookkey integer, 
	 @o_error_code integer output,
	 @o_standardmsgcode integer output,
	 @o_standardmsgsubcode integer output,
	 @o_error_desc	varchar(2000) output)
AS
/******************************************************************************
**  File: 
**  Name: EoD_turnoff_review_quotes
**  Desc: This stored procedure turns off the release to elo for all quotes if
**        citations are populated and marked as release to elo
**          
**        Input parameters: bookkey
**        Output parameters: returncode and message
**   
**    Auth: Kusum Basra
**    Date: 12 April 2016
*******************************************************************************
**    Change History
*******************************************************************************
**    Date:    Author:        Description:
**    -------- --------        -------------------------------------------
**    
*******************************************************************************/
BEGIN
	DECLARE @v_count INT
	DECLARE @v_error INT
	DECLARE @v_rowcount INT
	DECLARE @v_printingkey INT
	DECLARE @v_commenttypecode INT
	DECLARE @v_commenttypesubcode INT
	DECLARE @v_FieldDescDetail VARCHAR(255)
	DECLARE @v_update_value CHAR(1)
	DECLARE @v_return_string VARCHAR(2000)
	
	
	SET @o_error_code = 0
	SET @o_error_desc = ''
	SET @o_standardmsgcode = 0
	SET @o_standardmsgsubcode = 0
	
	SELECT o_standardmsgcode = datacode FROM gentables WHERE tableid = 678 and datadesc = 'Process citations before send to elo.'
	SET @o_standardmsgsubcode = 0
	
	SELECT @v_count = COUNT(*)  
	  FROM citation c JOIN qsicomments q ON c.qsiobjectkey = q.commentkey 
	  LEFT OUTER JOIN gentables g ON c.citationexternaltypecode = g.datacode
       AND g.tableid = 504 AND	g.exporteloquenceind = 1 and g.eloquencefieldtag <> ''
     WHERE c.bookkey=@i_bookkey 
       AND C.releasetoeloquenceind = 1 
       
    IF @v_count > 0 BEGIN
    
    	DECLARE bookcomments_cur CURSOR FOR
			 SELECT printingkey,commenttypecode,commenttypesubcode,sg.datadesc 
               FROM bookcomments  BC 
               JOIN gentables g ON g.datacode = bc.commenttypecode AND g.tableid = 284
               JOIN subgentables sg ON sg.datacode = g.datacode and sg.datasubcode=bc.commenttypesubcode AND sg.tableid = 284
                AND sg.eloquencefieldtag IN ('Q1','Q2','Q3','Q4','Q5','Q6','Q7','Q8')
                AND bc.bookkey=@i_bookkey
                AND bc.releasetoeloquenceind = 1
              ORDER BY bookkey, commenttypecode, commenttypesubcode
    
        OPEN bookcomments_cur

		FETCH NEXT FROM bookcomments_cur INTO @v_printingkey,@v_commenttypecode,@v_commenttypesubcode,@v_FieldDescDetail
		  
		WHILE (@@FETCH_STATUS = 0) BEGIN
		
			SET @o_error_code = 0
			SET @o_error_desc = ''
						
			
			UPDATE bookcomments
			   SET releasetoeloquenceind = 0,
			       lastuserid = 'EOD_TURNOFF_REVIEW_QUOTES',
			       lastmaintdate = GETDATE()
			 WHERE bookkey = @i_bookkey
			   AND printingkey = @v_printingkey
			   AND commenttypecode = @v_commenttypecode
			   AND commenttypesubcode = @v_commenttypesubcode
			   AND releasetoeloquenceind = 1
			   
			SELECT @v_error = @@ERROR, @v_rowcount = @@ROWCOUNT
            IF @v_error <> 0 BEGIN
			  SET @o_error_code = -1
			  
			  SELECT @v_return_string = COALESCE(dbo.qutl_get_system_message_desc (@o_standardmsgcode,@o_standardmsgsubcode),'')
	          SET @v_return_string = @v_return_string + ' Update of releasetoeloquenceind on bookcomments failed for bookkey: ' + CAST(@i_bookkey AS VARCHAR) + ' AND ' + @v_FieldDescDetail
	          SET @o_error_desc = @v_return_string
	          GOTO end_processing
	       END 
				
            IF @v_error = 0 BEGIN            
				IF @v_FieldDescDetail IS NOT NULL BEGIN
					IF @v_commenttypecode = 1 BEGIN
						SET @v_FieldDescDetail = '(M) ' + @v_FieldDescDetail
					END
					ELSE IF @v_commenttypecode = 3 BEGIN
						SET @v_FieldDescDetail = '(E) ' + @v_FieldDescDetail
					END
					ELSE IF @v_commenttypecode = 4 BEGIN
						SET @v_FieldDescDetail = '(T) ' + @v_FieldDescDetail
					END
					ELSE IF @v_commenttypecode = 5 BEGIN
						SET @v_FieldDescDetail = '(P) ' + @v_FieldDescDetail
					END
				END    
				
				SET @v_update_value = '0'                    
				  
				EXEC qtitle_update_titlehistory 'bookcomments', 'releasetoeloquenceind', @i_bookkey, @v_printingkey, null,
			  		  @v_update_value, 'UPDATE', 'EOD_TURNOFF_REVIEW_QUOTES', null, @v_FieldDescDetail, @o_error_code, @o_error_desc
			 END 		  
			
		
			FETCH NEXT FROM bookcomments_cur INTO @v_printingkey,@v_commenttypecode,@v_commenttypesubcode,@v_FieldDescDetail
		END --WHILE (@@FETCH_STATUS = 0
		
		end_processing:
		CLOSE bookcomments_cur 
        DEALLOCATE bookcomments_cur
    END --IF @v_count > 0
END
GO

GRANT EXECUTE on EoD_turnoff_review_quotes TO PUBLIC
GO