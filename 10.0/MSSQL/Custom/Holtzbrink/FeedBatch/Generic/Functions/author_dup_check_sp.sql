if exists (select * from dbo.sysobjects where id = object_id(N'dbo.author_dup_check_sp') and xtype in (N'FN', N'IF', N'TF'))
drop function dbo.author_dup_check_sp
GO
  CREATE 
    FUNCTION dbo.author_dup_check_sp 
      (
        @c_name1 varchar(255),
        @c_newstring varchar(255)
      ) 
      RETURNS integer
    AS
      BEGIN

        DECLARE 
          @i_dupyesno integer,
          @lv_count integer        
        SET @lv_count = 0
        BEGIN
          /*
           -- See if duplicate author on same title by checking displayname, safest way to use only
           -- one column..
           --*/

          SET @lv_count = charindex(@c_newstring, @c_name1)

          IF (@lv_count > 0)
            SET @i_dupyesno = 1
          ELSE 
            SET @i_dupyesno = 0

          RETURN @i_dupyesno

        END


        RETURN null
      END
GO

GRANT EXEC ON dbo.author_dup_check_sp TO public
GO

