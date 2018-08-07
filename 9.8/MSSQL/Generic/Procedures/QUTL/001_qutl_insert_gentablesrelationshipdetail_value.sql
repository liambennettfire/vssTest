
/****** Object:  StoredProcedure [dbo].[qutl_insert_gentablesrelationshipdetail_value]    Script Date: 01/09/2015 11:56:09 ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER OFF
GO

IF EXISTS(SELECT * FROM sys.objects WHERE type = 'p' and name = 'qutl_insert_gentablesrelationshipdetail_value' ) 
drop procedure qutl_insert_gentablesrelationshipdetail_value
go

CREATE PROCEDURE [dbo].[qutl_insert_gentablesrelationshipdetail_value]
 (@i_gentablesrelationshipkey		integer,
  @i_datadesc1						varchar (40),
  @i_qsicode1						integer,
  @i_datadesc2						varchar (40),
  @i_qsicode2						integer,
  @i_sub_datadesc1					varchar (40),
  @i_sub_qsicode1					integer,
  @i_sub_datadesc2					varchar (40),
  @i_sub_qsicode2					integer,
  @i_defaultind		   				integer,
  @o_gentablesrelationshipdetailkey integer output,
  @o_error_code						integer output,
  @o_error_desc						varchar(2000) output)
AS

/******************************************************************************
**  Name: qutl_insert_gentablesrelationshipdetail_value
**  Desc: This stored procedure searches to see if the gentablesrelationshipdetails
**        value sent matches an existing value on either qsicodes or datadescs on
**        gentables and subgentables.  If a match is found, the existing 
**        gentablesrelationshipdetailkey is returned.  If it is not found
**        it is inserted and the new gentablesrelationshipdetailkey is returned    
**    Auth: SLB
**    Date: 9 Jan 2015
*******************************************************************************
**    Change History
*******************************************************************************
**    Date:     Author:        Description:
**    --------  --------       -------------------------------------------
**    09/06/16  Colman         gentables level 2 was broken (discovered working on case 39202)
*******************************************************************************/

  DECLARE 
    @v_tableid1  INT,
    @v_tableid2  INT,
    @v_gentable1level  INT,
    @v_gentable2level  INT,
    @v_datacode1  INT,
    @v_datacode2  INT,
    @v_datasubcode1  INT,
    @v_datasubcode2  INT,
    @v_max_key INT,
    @v_count  INT,
    @v_error  INT
     
    SET @o_error_code = 0
    SET @o_error_desc = ''
    SET @o_gentablesrelationshipdetailkey = 0 
    SET @v_datacode1 = 0 
    SET @v_datacode2 = 0 
    SET @v_datasubcode1 = NULL 
    SET @v_datasubcode2 = NULL 
    
BEGIN
   

   SELECT @v_tableid1 = Gentable1id, @v_tableid2 = Gentable2id, @v_gentable1level = gentable1level, @v_gentable2level = gentable2level 
   FROM gentablesrelationships WHERE @i_gentablesrelationshipkey =  gentablesrelationshipkey
   
   --Get Datacode (and datasubcode if gentable level = 2) for table 1 from qsicode and datadesc
   IF @v_gentable1level = 1 OR @v_gentable1level = 2 BEGIN	  	 
     IF @i_qsicode1 <> 0 and @i_qsicode1 IS NOT NULL 	
       SELECT @v_datacode1 = datacode FROM gentables
		    WHERE (tableid = @v_tableid1 AND qsicode = @i_qsicode1)
     ELSE
       SELECT @v_datacode1 = datacode FROM gentables
	        WHERE (tableid = @v_tableid1 AND datadesc = @i_datadesc1)		  
		  
     IF @v_datacode1 = 0 OR @v_datacode1 IS NULL  BEGIN
       SET @o_error_code = -1
       SET @o_error_desc = 'Cannot insert to gentablesrelationshipdetails.  No datacode found: tableid=' + cast(@v_tableid1 AS VARCHAR)+ ',  desc= ' + @i_datadesc1
       RETURN
       END
   END  --gentable1 level 1 or 2
   ELSE BEGIN
	 SET @o_error_code = -1
     SET @o_error_desc = 'This insert stored procedure only handles gentables levels 1 or 2.  Gentablelevel1 =' + cast(@v_gentable1level AS VARCHAR)+ ',  subgendesc= ' + @i_sub_datadesc1
     RETURN
   END --gentable1level error 

   IF @v_gentable1level = 2  BEGIN
     IF @i_sub_qsicode1 <> 0 and @i_sub_qsicode1 IS NOT NULL 	
       SELECT @v_datacode1 = datacode, @v_datasubcode1 = datasubcode FROM subgentables
		    WHERE (tableid = @v_tableid1 AND qsicode = @i_sub_qsicode1)
     ELSE
       SELECT @v_datasubcode1 = datasubcode FROM subgentables
		   WHERE (tableid = @v_tableid1 AND datacode = @v_datacode1 AND datadesc = @i_sub_datadesc1)

	   IF @v_datasubcode1 = 0 OR @v_datasubcode1 IS NULL  BEGIN
         SET @o_error_code = -1
         SET @o_error_desc = 'Cannot insert to gentablesrelationshipdetails.  No datacode/subcode found: tableid=' + cast(@v_tableid1 AS VARCHAR)+ ',  subgendesc= ' + @i_sub_datadesc1
         RETURN
	   END	   
   END	--gentable1 level 2 
   
   --Get Datacode (and datasubcode if gentable level = 2) for table 2 from qsicode and datadesc
   IF @v_gentable2level = 1 OR @v_gentable2level = 2 BEGIN	  	 
     IF @i_qsicode2 <> 0 and @i_qsicode2 IS NOT NULL 	
       SELECT @v_datacode2 = datacode FROM gentables
		    WHERE (tableid = @v_tableid2 AND qsicode = @i_qsicode2)
     ELSE
       SELECT @v_datacode2 = datacode FROM gentables
	        WHERE (tableid = @v_tableid2 AND datadesc = @i_datadesc2)		  
		  
     IF @v_datacode2 = 0 OR @v_datacode2 IS NULL  BEGIN
       SET @o_error_code = -1
       SET @o_error_desc = 'Cannot insert to gentablesrelationshipdetails.  No datacode found: tableid=' + cast(@v_tableid2 AS VARCHAR)+ ',  desc= ' + @i_datadesc2
       RETURN
       END
   END  --gentable2 level 1 or 2
   ELSE BEGIN
     SET @o_error_code = -1
     SET @o_error_desc = 'This insert stored procedure only handles gentables levels 1 or 2.  Gentablelevel2 =' + cast(@v_gentable2level AS VARCHAR)+ ',  subgendesc= ' + @i_sub_datadesc2
     RETURN
   END --gentable2level error 

   IF @v_gentable2level = 2  BEGIN
     IF @i_sub_qsicode2 <> 0 and @i_sub_qsicode2 IS NOT NULL 	
       SELECT @v_datacode2 = datacode, @v_datasubcode2 = datasubcode FROM subgentables
		    WHERE (tableid = @v_tableid2 AND qsicode = @i_sub_qsicode2)
     ELSE
       SELECT @v_datasubcode2 = datasubcode FROM subgentables
		   WHERE (tableid = @v_tableid2 AND datacode = @v_datacode2 AND datadesc = @i_sub_datadesc2)

	   IF @v_datasubcode2 = 0 OR @v_datasubcode2 IS NULL  BEGIN
         SET @o_error_code = -1
         SET @o_error_desc = 'Cannot insert to gentablesrelationshipdetails.  No datacode/subcode found: tableid=' + cast(@v_tableid2 AS VARCHAR)+ ',  subgendesc= ' + @i_sub_datadesc2
         RETURN
	   END	   
   END	--gentable2 level 2 
   
    --check to see if gentablesrelationshipdetail row exists already; sometimes subdatacodes are 0 and sometimes NULL when not used so need to check only required fields    
    IF @v_gentable1level = 1 and @v_gentable2level = 1   
	  SELECT TOP 1 @o_gentablesrelationshipdetailkey = gentablesrelationshipdetailkey FROM gentablesrelationshipdetail
         WHERE (gentablesrelationshipkey = @i_gentablesrelationshipkey AND code1 = @v_datacode1 AND code2 = @v_datacode2) 
    ELSE IF @v_gentable1level = 2 and @v_gentable2level = 2     
      SELECT TOP 1 @o_gentablesrelationshipdetailkey = gentablesrelationshipdetailkey FROM gentablesrelationshipdetail
         WHERE (gentablesrelationshipkey = @i_gentablesrelationshipkey AND code1 = @v_datacode1 AND code2 = @v_datacode2 
         AND subcode1 = @v_datasubcode1 AND subcode2 = @v_datasubcode2) 
    ELSE IF @v_gentable1level = 1 and @v_gentable2level = 2     
      SELECT TOP 1 @o_gentablesrelationshipdetailkey = gentablesrelationshipdetailkey FROM gentablesrelationshipdetail
         WHERE (gentablesrelationshipkey = @i_gentablesrelationshipkey AND code1 = @v_datacode1 AND code2 = @v_datacode2 
         AND subcode2 = @v_datasubcode2) 
    ELSE
      SELECT TOP 1 @o_gentablesrelationshipdetailkey = gentablesrelationshipdetailkey FROM gentablesrelationshipdetail
         WHERE (gentablesrelationshipkey = @i_gentablesrelationshipkey AND code1 = @v_datacode1 AND code2 = @v_datacode2 
         AND subcode1 = @v_datasubcode1 AND subcode2 = @v_datasubcode2) 
          
       
  IF @o_gentablesrelationshipdetailkey = 0 OR @o_gentablesrelationshipdetailkey is NULL  BEGIN        
    --Value does not exist already on gentablesrelationshipdetails and must be inserted 
    EXEC dbo.get_next_key 'QSIDBA', @o_gentablesrelationshipdetailkey OUT
	
    INSERT INTO gentablesrelationshipdetail
      (gentablesrelationshipkey, code1, gentablesrelationshipdetailkey, code2, defaultind, subcode1, subcode2, lastuserid, lastmaintdate)
    VALUES
      (@i_gentablesrelationshipkey, @v_datacode1, @o_gentablesrelationshipdetailkey, @v_datacode2, @i_defaultind, @v_datasubcode1, @v_datasubcode2,
       'QSIDBA', getdate())
  
    SELECT @v_error = @@ERROR
    IF @v_error <> 0 BEGIN
      SET @o_error_code = -1
      SET @o_error_desc = 'insert to gentablesrelationshipdetails had an error: gentablerelationship key=' + cast(@i_gentablesrelationshipkey AS VARCHAR)+ 
      ', desc= ' + @i_datadesc1 +  ', desc2= ' + @i_datadesc2
    END 
  END

END

GO


