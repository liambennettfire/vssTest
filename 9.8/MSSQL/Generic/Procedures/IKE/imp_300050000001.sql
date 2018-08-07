/******************************************************************************
**  Name: imp_load_xml_explicit
**  Desc: IKE deletes from tables - DANGER!!!
**  Auth: Bennett     
**  Date: 5/9/2016
*******************************************************************************
**  Change History
*******************************************************************************
**  Date:        Author:     Description:
*   --------     --------    -------------------------------------------
**  5/9/2016     Bennett     original
*******************************************************************************/

/****** Object:  StoredProcedure [dbo].[imp_300050000001]    Script Date: 07/08/2013 20:48:24 ******/
IF  EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[imp_300050000001]') AND type in (N'P', N'PC'))
DROP PROCEDURE [dbo].[imp_300050000001]
GO

/****** Object:  StoredProcedure [dbo].[imp_300050000001]    Script Date: 07/08/2013 20:48:24 ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO

 
CREATE PROCEDURE [dbo].[imp_300050000001] @i_batch INT
       ,@i_row INT
       ,@i_dmlkey BIGINT
       ,@i_titlekeyset VARCHAR(500)
       ,@i_contactkeyset VARCHAR(500)
       ,@i_templatekey INT
       ,@i_elementseq INT
       ,@i_level INT
       ,@i_userid VARCHAR(50)
       ,@i_newtitleind INT
       ,@i_newcontactind INT
       ,@o_writehistoryind INT OUTPUT
AS

--This procedure will delete from specified tables.
--To Add a table you must use the stored proc
-- Make sure you add in RowInsertIND
--set rowinsertind=1
/*

 Select * from imp_element_Defs order by elementkey

SET @templatekey = 1 -- ... this you already have at the DML level
SET @TableName = 'imp_template_detail'
SET @FieldName = 'XMLQualifier'
SET @WhereClause = 'WHERE ElementKey=100050000 and templatekey = ' + CAST(@templatekey AS VARCHAR(max))
--the elementkey can be from 100050000 to 100050004. (Depends what's in the template).
SET @XMLNodeName = 'TABLE_NAME'
SET @XMLNodeValue = NULL -- Choose a table such as bookbisaccategory
EXEC sp_XMLNodeValue_SET @TableName, @FieldName, @WhereClause, @XMLNodeName, @XMLNodeValue

*/


BEGIN
       DECLARE
       @DEBUG AS INT
       ,@v_elementval AS VARCHAR(max)
       ,@v_bookkey AS BIGINT
       ,@v_errcode AS INT
       ,@v_errmsg AS VARCHAR(4000)
       ,@v_errseverity AS INT
       ,@v_elementkey INT
       --new ones ...
       ,@templatekey INT
       ,@TableName VARCHAR(256)
       ,@FieldName VARCHAR(256)
       ,@WhereClause VARCHAR(256)
       ,@XMLNodeName VARCHAR(256)
       ,@XMLNodeValue VARCHAR(256)
       ,@Error INT
       ,@ErrorMSG VARCHAR(256)
       ,@SQL VARCHAR(max)
      
 
       SET @DEBUG = 0
       IF @DEBUG <> 0 PRINT ''
       IF @DEBUG <> 0 PRINT 'dbo.imp_300050000001'
      
       IF @DEBUG <> 0 PRINT  '@i_batch  =  ' + coalesce(cast(@i_batch as varchar(max)),'*NULL*')
       IF @DEBUG <> 0 PRINT  '@i_row  =  ' + coalesce(cast(@i_row as varchar(max)),'*NULL*')
       IF @DEBUG <> 0 PRINT  '@i_dmlkey  =  ' + coalesce(cast(@i_dmlkey as varchar(max)),'*NULL*')
       IF @DEBUG <> 0 PRINT  '@i_titlekeyset  =  ' + coalesce(cast(@i_titlekeyset as varchar(max)),'*NULL*')
       IF @DEBUG <> 0 PRINT  '@i_contactkeyset  =  ' + coalesce(cast(@i_contactkeyset as varchar(max)),'*NULL*')
       IF @DEBUG <> 0 PRINT  '@i_templatekey  =  ' + coalesce(cast(@i_templatekey as varchar(max)),'*NULL*')
       IF @DEBUG <> 0 PRINT  '@i_elementseq  =  ' + coalesce(cast(@i_elementseq as varchar(max)),'*NULL*')
       IF @DEBUG <> 0 PRINT  '@i_level  =  ' + coalesce(cast(@i_level as varchar(max)),'*NULL*')
       IF @DEBUG <> 0 PRINT  '@i_userid  =  ' + coalesce(cast(@i_userid as varchar(max)),'*NULL*')
       IF @DEBUG <> 0 PRINT  '@i_newtitleind  =  ' + coalesce(cast(@i_newtitleind as varchar(max)),'*NULL*')
       IF @DEBUG <> 0 PRINT  '@i_newcontactind  =  ' + coalesce(cast(@i_newcontactind as varchar(max)),'*NULL*')
       IF @DEBUG <> 0 PRINT  '@o_writehistoryind  =  ' + coalesce(cast(@o_writehistoryind as varchar(max)),'*NULL*')
      
       SET @v_bookkey = dbo.resolve_keyset(@i_titlekeyset, 1)
       
       IF @DEBUG <> 0 PRINT  '@v_bookkey = ' + coalesce(cast(@v_bookkey as varchar(max)),'*NULL*')
      
      SELECT @v_elementval =  originalvalue,
		@v_elementkey = b.elementkey
	FROM imp_batch_detail b , imp_DML_elements d
	WHERE b.batchkey = @i_batch
      			AND b.row_id = @i_row
			AND b.elementseq = @i_elementseq
			AND b.elementkey = d.elementkey
			AND d.DMLkey = @i_dmlkey
			
	IF @DEBUG <> 0 PRINT  '@v_elementkey = ' + coalesce(cast(@v_elementkey as varchar(max)),'*NULL*')
      
       SET @templatekey = @i_templatekey
       SET @TableName = 'imp_template_detail'
       SET @FieldName = 'XMLQualifier'
       --@v_elementkey  is dynamic here because you have 1 DML rule servicing multiple elements.
       SET @WhereClause = 'WHERE ElementKey=' + CAST(@v_elementkey AS VARCHAR(max)) + ' and templatekey = ' + CAST(@templatekey AS VARCHAR(max))
       SET @XMLNodeName = 'TABLE_NAME'
       SET @XMLNodeValue = NULL
 
       EXEC sp_XMLNodeValue_GET @TableName, @FieldName, @WhereClause, @XMLNodeName, @XMLNodeValue OUTPUT, @Error OUTPUT, @ErrorMSG OUTPUT
 
       IF @DEBUG <> 0 PRINT  @XMLNodeName
       IF @DEBUG <> 0 PRINT  @XMLNodeValue
       IF @DEBUG <> 0 PRINT  @Error
       IF @DEBUG <> 0 PRINT  @ErrorMSG
      
       BEGIN TRY
              IF @DEBUG <> 0 PRINT 'START UPDATE '
              print @xmlnodevalue
              IF LEN(COALESCE(@XMLNodeValue,''))>0 --.. may want to add a check that this table actually exists at this point
              BEGIN
              	SET @SQL = 'DELETE FROM ' + @XMLNodeValue + ' WHERE BOOKKEY = ' + CAST     (@v_bookkey as varchar(max))
              	print @sql
				execute (@sql)
			  END	
              IF @DEBUG <> 0 PRINT 'END UPDATE '
              
              SET @v_errmsg='Completed successfully'
			SET @v_errcode=1
              
       END TRY
       BEGIN CATCH
              IF @DEBUG <> 0 PRINT 'something really bad happened ?!?'
              SET @v_errcode = @@ERROR
              SET @v_errmsg = ERROR_MESSAGE()
              SET @v_errseverity = 3
              IF @DEBUG <> 0 PRINT @v_errcode
              IF @DEBUG <> 0 PRINT @v_errmsg          
       END CATCH
             
       
      
       IF @DEBUG <> 0 PRINT @v_errmsg
       EXECUTE imp_write_feedback @i_batch, @i_row,@v_elementkey , @i_elementseq ,@i_dmlkey , @v_errmsg, @v_errcode, 3
       
END
GO


