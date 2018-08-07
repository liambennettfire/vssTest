if exists (select * from dbo.sysobjects where id = object_id(N'dbo.qutl_allow_additional_role') and xtype in (N'FN', N'IF', N'TF'))
drop function dbo.qutl_allow_additional_role
GO

CREATE FUNCTION qutl_allow_additional_role
    ( @i_bookkey as integer,
	  @i_printingkey as integer,
      @i_projectkey as integer,
      @i_rolecode as integer) 

RETURNS int

/******************************************************************************
**  File: 
**  Name: qutl_allow_additional_role
**  Desc: This function returns 1 when we allow the role to be added for a contact
**        0 if we are not to allow the role for add
**        and -1 for an error.  This needs to be done to 
**        prevent the addition of a role.
**
**    Auth: Uday Khisty
**    Date: 15 August 2014
*******************************************************************************
**    Change History
*******************************************************************************
**    Date:       Author:        Description:
**    --------    --------       -------------------------------------------
**    
*******************************************************************************/

BEGIN 
  DECLARE @v_itemtypecode	INT,
		  @v_usageclasscode	INT,
          @v_count          INT,
          @error_var        INT,
          @v_rowcount_var   INT,
          @v_return_value   INT
          
          
  SET @v_itemtypecode = 0
  SET @v_usageclasscode = 0
  SET @v_rowcount_var = 0
  SET @v_count = 0
  SET @v_return_value = 1
  
  IF ((COALESCE(@i_bookkey, 0) <= 0) AND (COALESCE(@i_projectkey, 0) <= 0) OR COALESCE(@i_rolecode, 0) <=0) BEGIN
    RETURN -1
  END  
                     
  IF @i_bookkey > 0 BEGIN
	SELECT @v_itemtypecode = itemtypecode, @v_usageclasscode = usageclasscode 
	FROM coretitleinfo 
	WHERE bookkey = @i_bookkey AND printingkey = @i_printingkey
	
	SELECT @v_rowcount_var = COUNT(*) 
	FROM bookcontactrole r 
		INNER JOIN bookcontact b ON b.bookcontactkey = r.bookcontactkey 
		AND b.bookkey = @i_bookkey AND b.printingkey = @i_printingkey  
	WHERE  r.rolecode = @i_rolecode 
  END
  ELSE IF @i_projectkey > 0 BEGIN
    SELECT @v_rowcount_var = COUNT(*) 
	FROM taqprojectcontactrole 
	WHERE taqprojectkey = @i_projectkey AND rolecode = @i_rolecode 	 
	  
	SELECT @v_itemtypecode = searchitemcode, @v_usageclasscode = usageclasscode 
	FROM coreprojectinfo 
	WHERE projectkey = @i_projectkey	  							
  END
  
  IF @v_itemtypecode > 0 BEGIN
	 SELECT @v_count = COUNT(*) FROM gentablesitemtype 
	 WHERE tableid = 285 
		AND itemtypecode = @v_itemtypecode AND itemtypesubcode IN (0, @v_usageclasscode) AND datacode = @i_rolecode AND indicator1 = 1  
	
	IF @v_rowcount_var > 0 AND @v_count > 0	BEGIN
		SET @v_return_value = 0
	END	  	
  END
		
  RETURN @v_return_value		
END
GO

GRANT EXEC ON dbo.qutl_allow_additional_role TO public
GO
