if exists (select * from dbo.sysobjects where id = object_id(N'dbo.qutl_get_gentables_access_table_multi') and xtype in (N'FN', N'IF', N'TF'))
  drop function dbo.qutl_get_gentables_access_table_multi
GO

CREATE FUNCTION dbo.qutl_get_gentables_access_table_multi
(
  @i_userkey  integer,
  @i_windowname varchar(100),
  @i_tableid integer,
  @i_keys1 varchar(max),
  @i_key2 integer,
  @i_key3 integer
) 
RETURNS @SecurityTable TABLE(
  objectkey INT, 
  accesscode INT, 
  datacode INT
)

/*******************************************************************************************************
**  Name: qutl_get_gentables_access_table_multi
**  Desc: 
**
**  Auth: Colman
**  Date: 1/25/2018
********************************************************************************************************
**    Change History
********************************************************************************************************
**    Date:       Author:      Case #:   Description:
**    --------    --------     -------   --------------------------------------
*******************************************************************************************************/

BEGIN 
  DECLARE @error_var    INT,
          @v_objectkeys VARCHAR(max),
          @v_value VARCHAR(255),
          @v_objectkey INT,
          @v_pos INT,
          @v_len INT

  IF ISNULL(@i_tableid,0) = 0 
    RETURN
  
  IF ISNULL(@i_userkey,-1) = -1
    RETURN

  SET @v_pos = 0
  SET @v_len = 0
  SET @v_objectkeys = @i_keys1 + ','

  WHILE CHARINDEX(',', @v_objectkeys, @v_pos + 1) > 0
  BEGIN
      SET @v_len = CHARINDEX(',', @v_objectkeys, @v_pos + 1) - @v_pos
      SET @v_objectkey = CONVERT(INT, SUBSTRING(@i_keys1, @v_pos, @v_len))
    
      INSERT INTO @SecurityTable (objectkey, accesscode, datacode)    
      SELECT @v_objectkey, accesscode, datacode
      FROM dbo.qutl_get_gentables_access_table(@i_userkey, @i_windowname, @i_tableid, @v_objectkey, @i_key2, @i_key3)

      SET @v_pos = CHARINDEX(',', @v_objectkeys, @v_pos + @v_len) + 1
  END

  RETURN
END
GO

GRANT SELECT ON dbo.qutl_get_gentables_access_table_multi TO public
GO
