if exists (select * from dbo.sysobjects where id = object_id(N'dbo.qproject_is_sent_to_tmm') and xtype in (N'FN', N'IF', N'TF'))
drop function dbo.qproject_is_sent_to_tmm
GO

CREATE FUNCTION qproject_is_sent_to_tmm
    ( @i_desc as varchar(50),
      @i_tableid as integer,
      @i_code1 as integer,
      @i_code2 as integer) 

RETURNS integer

/******************************************************************************
**  File: qproject_is_sent_to_tmm.sql
**  Name: qproject_is_sent_to_tmm
**  Desc: This function returns 1 if item is sent to tmm from TAQ,
**        0 if item is not sent to tmm from TAQ,
**        and -1 for an error. 
**
**
**    Auth: Alan Katzen
**    Date: 07 April 2005
*******************************************************************************
**    Change History
*******************************************************************************
**    Date:    Author:        Description:
**    --------    --------        -------------------------------------------
**    
*******************************************************************************/

BEGIN 
  DECLARE @i_count      INT
  DECLARE @i_count1     INT
  DECLARE @i_count2     INT
  DECLARE @error_var    INT
  DECLARE @rowcount_var INT
  DECLARE @desc_var     VARCHAR(50)

  SET @i_count = 0
  SET @desc_var = lower(rtrim(ltrim(@i_desc)))

  IF @desc_var = 'date' BEGIN
    -- look at taqtotmmind on datetype table
    SELECT @i_count = count(*)
      FROM datetype
     WHERE datetypecode = @i_code1 and
           taqtotmmind = 1 

    SELECT @error_var = @@ERROR, @rowcount_var = @@ROWCOUNT
    IF @error_var <> 0 BEGIN
      SET @i_count = -1
    END 

    -- return 1 or 0 so that object can set params 
    IF @i_count > 0 BEGIN
      SET @i_count = 1
    END    
  END

  IF @desc_var = 'subjectcategory' BEGIN
    -- gentablesitemtype - 1 means TMM and 3 means Project
    -- MUST have BOTH 1 and 3 to be able to be sent to TMM
    -- NOTE: may or may not have a usageclass (@i_code1 (TMM)/@i_code2 (Project))
    SET @i_count1 = 0
    SET @i_count2 = 0
    IF @i_code1 > 0 BEGIN
      SELECT @i_count1 = count(*)
        FROM gentablesitemtype
       WHERE tableid = @i_tableid and
             itemtypecode = 1 and
             itemtypesubcode = @i_code1

      SELECT @error_var = @@ERROR, @rowcount_var = @@ROWCOUNT
      IF @error_var <> 0 BEGIN
        SET @i_count = -1
      END 
   END

    IF @i_count1 = 0 BEGIN
      SELECT @i_count1 = count(*)
        FROM gentablesitemtype
       WHERE tableid = @i_tableid and
             itemtypecode = 1 and
             COALESCE(itemtypesubcode,0) = 0

      SELECT @error_var = @@ERROR, @rowcount_var = @@ROWCOUNT
      IF @error_var <> 0 BEGIN
        SET @i_count = -1
      END 
    END

    IF @i_count1 > 0 BEGIN
      IF @i_code2 > 0 BEGIN
        SELECT @i_count2 = count(*)
          FROM gentablesitemtype
         WHERE tableid = @i_tableid and
               itemtypecode = 3 and
               itemtypesubcode = @i_code2

        SELECT @error_var = @@ERROR, @rowcount_var = @@ROWCOUNT
        IF @error_var <> 0 BEGIN
          SET @i_count = -1
        END 
      END
  
      IF @i_count2 = 0 BEGIN
        SELECT @i_count2 = count(*)
          FROM gentablesitemtype
         WHERE tableid = @i_tableid and
               itemtypecode = 3 and
               COALESCE(itemtypesubcode,0) = 0

        SELECT @error_var = @@ERROR, @rowcount_var = @@ROWCOUNT
        IF @error_var <> 0 BEGIN
          SET @i_count = -1
        END 
      END
    END

    -- return 1 or 0 so that object can set params 
    IF @i_count1 > 0 AND @i_count2 > 0 BEGIN
      SET @i_count = 1
    END
    ELSE BEGIN
      SET @i_count = 0
    END    
  END

  IF @desc_var = 'gentables' BEGIN
    -- gentables
    SELECT @i_count = count(*)
      FROM gentables
     WHERE tableid = @i_tableid and
           datacode = @i_code1 and
           gen2ind = 1

    SELECT @error_var = @@ERROR, @rowcount_var = @@ROWCOUNT
    IF @error_var <> 0 BEGIN
      SET @i_count = -1
    END 

    -- return 1 or 0 so that object can set params 
    IF @i_count > 0 BEGIN
      SET @i_count = 1
    END
  END

  IF @desc_var = 'subgentables' BEGIN
    -- subgentables
    SELECT @i_count = count(*)
      FROM subgentables
     WHERE tableid = @i_tableid and
           datacode = @i_code1 and
           datasubcode = @i_code2 and
           subgen2ind = 1

    SELECT @error_var = @@ERROR, @rowcount_var = @@ROWCOUNT
    IF @error_var <> 0 BEGIN
      SET @i_count = -1
    END 

    -- return 1 or 0 so that object can set params 
    IF @i_count > 0 BEGIN
      SET @i_count = 1
    END
  END

  RETURN @i_count
END
GO

GRANT EXEC ON dbo.qproject_is_sent_to_tmm TO public
GO
