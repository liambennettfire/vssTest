
/****** Object:  StoredProcedure [dbo].[qutl_insert_bookmiscitems]    Script Date: 01/09/2015 11:56:09 ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER OFF
GO

IF EXISTS(SELECT * FROM sys.objects WHERE type = 'p' and name = 'qutl_insert_bookmiscitems' ) 
     DROP PROCEDURE qutl_insert_bookmiscitems  
go

CREATE PROCEDURE [dbo].[qutl_insert_bookmiscitems]
 (@i_miscname			varchar (50),
  @i_misctype			integer,
  @i_datacode			integer,
  @i_qsicode			integer,
  @i_firedistkey		integer,
  @o_misckey            integer output, 
  @o_error_code         integer output,
  @o_error_desc			varchar(2000) output)
AS

/******************************************************************************
**  Name: qutl_insert_bookmiscitems  
**  Desc: This stored procedure searches to see if the bookmiscitem value sent  
**        matches an existing value based on qsicode, firedistkey or decription.  
**        If no existing value is found, it is inserted.  If it is found, 
**        some of the existing values will be updated    
**    Auth: SLB
**    Date: 11 Jan 2015
*******************************************************************************
**    Change History
*******************************************************************************
**    Date:      Author:        Description:
**    --------   --------       -------------------------------------------
**    09/12/16   Colman         Handle @i_firedistkey = 0 the same as @i_firedistkey is null
*******************************************************************************/

  DECLARE 
    @v_count  INT,
    @v_maxkey INT,
    @v_error  INT
     
  SET @o_error_code = 0
  SET @o_error_desc = ''
  SET @o_misckey = 0
    
    
BEGIN

  IF @i_qsicode IS NOT NULL
      SELECT TOP 1 @o_misckey= misckey FROM bookmiscitems
		  WHERE (qsicode = @i_qsicode)
		  
  IF  (@o_misckey = 0 OR @o_misckey is NULL) and @i_firedistkey > 0
   	  SELECT TOP 1 @o_misckey= misckey FROM bookmiscitems
		  WHERE (firedistkey = @i_firedistkey)		  
    
  IF  @o_misckey = 0 OR @o_misckey is NULL
   	  SELECT TOP 1 @o_misckey= misckey FROM bookmiscitems
		  WHERE (LOWER(miscname) = LOWER(@i_miscname)) 
       
  IF @o_misckey = 0 OR @o_misckey is NULL BEGIN        
      SELECT @v_maxkey = MAX(misckey)FROM bookmiscitems
      SET @o_misckey = @v_maxkey + 1
      INSERT INTO bookmiscitems
          (misckey, miscname, misctype, activeind, lastuserid, lastmaintdate, datacode, qsicode, misclabel,
           firedistkey)
         VALUES   (@o_misckey, @i_miscname, @i_misctype, 1, 'QSIDBA', getdate(), @i_datacode, @i_qsicode, @i_miscname,
          @i_firedistkey)
      SELECT @v_error = @@ERROR
      IF @v_error <> 0 BEGIN
	    SET @o_error_code = -1
	    SET @o_error_desc = 'insert to bookmiscitems had an error: misckey=' + cast(@o_misckey AS VARCHAR) + ', name= ' + @i_miscname
	  END
    END
    ELSE BEGIN
    --Update values to existing bookmiscitem row
      
      --Only update qsicode if it is valid 
       IF @i_qsicode IS NOT NULL AND @i_qsicode <> 0 BEGIN
           UPDATE bookmiscitems
           SET qsicode = @i_qsicode, firedistkey = @i_firedistkey, lastuserid = 'QSIDBA', lastmaintdate = getdate(), miscname = @i_miscname, misclabel = @i_miscname
           WHERE misckey = @o_misckey
	      SELECT @v_error = @@ERROR
	      IF @v_error <> 0 BEGIN
		     SET @o_error_code = -1
		     SET @o_error_desc = 'update to bookmiscitems had an error: misckey=' + cast(@o_misckey AS VARCHAR) + ', name= ' + @i_miscname
		  END
		  RETURN 
	   END

		--Only update the firedistkey if it is a valid; always update miscname      
	   IF @i_firedistkey IS NULL BEGIN
          UPDATE bookmiscitems
          SET  miscname = @i_miscname, misclabel = @i_miscname, lastuserid = 'QSIDBA', lastmaintdate = getdate() 
          WHERE misckey = @o_misckey                      
	   END
	   ELSE  BEGIN 
          UPDATE bookmiscitems
          SET firedistkey = @i_firedistkey, miscname = @i_miscname, misclabel = @i_miscname, lastuserid = 'QSIDBA', lastmaintdate = getdate()
          WHERE misckey = @o_misckey
	   END
	END 

 SELECT @v_error = @@ERROR
 IF @v_error <> 0 BEGIN
    SET @o_error_code = -1
	SET @o_error_desc = 'update to bookmiscitems had an error: misckey=' + cast(@o_misckey AS VARCHAR) + ', name= ' + @i_miscname
  END 
END
    
 
GO


