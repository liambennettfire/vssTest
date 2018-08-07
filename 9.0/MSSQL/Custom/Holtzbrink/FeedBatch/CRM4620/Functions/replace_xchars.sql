IF exists (select * from dbo.sysobjects where id = object_id(N'dbo.REPLACE_XCHARS') and xtype in (N'FN', N'IF', N'TF'))
  DROP FUNCTION dbo.REPLACE_XCHARS

GO

  CREATE FUNCTION dbo.REPLACE_XCHARS 
      (@i_string varchar(8000)) 
      RETURNS varchar(8000)
    AS
      BEGIN

        DECLARE 
          @o_string varchar(8000)        

        BEGIN

          SET @o_string = @i_string

          /* handles convertion to 'A' */

          SET @o_string = replace(@o_string, char(192), 'A')

          SET @o_string = replace(@o_string, char(193), 'A')

          SET @o_string = replace(@o_string, char(194), 'A')

          SET @o_string = replace(@o_string, char(195), 'A')

          SET @o_string = replace(@o_string, char(196), 'A')

          SET @o_string = replace(@o_string, char(197), 'A')

          SET @o_string = replace(@o_string, char(198), 'Ae')

          /* handles convertion to 'E' */

          SET @o_string = replace(@o_string, char(200), 'E')

          SET @o_string = replace(@o_string, char(201), 'E')

          SET @o_string = replace(@o_string, char(202), 'E')

          SET @o_string = replace(@o_string, char(203), 'E')

          /* handles convertion to 'I' */

          SET @o_string = replace(@o_string, char(204), 'I')

          SET @o_string = replace(@o_string, char(205), 'I')

          SET @o_string = replace(@o_string, char(206), 'I')

          SET @o_string = replace(@o_string, char(207), 'I')

          /* handles convertion to 'N' */

          SET @o_string = replace(@o_string, char(209), 'N')

          /* handles convertion to 'O' */

          SET @o_string = replace(@o_string, char(210), 'O')

          SET @o_string = replace(@o_string, char(211), 'O')

          SET @o_string = replace(@o_string, char(212), 'O')

          SET @o_string = replace(@o_string, char(213), 'O')

          SET @o_string = replace(@o_string, char(214), 'O')

          /* handles convertion to 'U' */

          SET @o_string = replace(@o_string, char(217), 'U')

          SET @o_string = replace(@o_string, char(218), 'U')

          SET @o_string = replace(@o_string, char(219), 'U')

          SET @o_string = replace(@o_string, char(220), 'U')

          /* handles convertion to 'Y' */

          SET @o_string = replace(@o_string, char(221), 'Y')

          /* handles convertion to 'a' */

          SET @o_string = replace(@o_string, char(224), 'a')

          SET @o_string = replace(@o_string, char(225), 'a')

          SET @o_string = replace(@o_string, char(226), 'a')

          SET @o_string = replace(@o_string, char(227), 'a')

          SET @o_string = replace(@o_string, char(228), 'a')

          SET @o_string = replace(@o_string, char(229), 'a')

          SET @o_string = replace(@o_string, char(230), 'a')

          /* handles convertion to 'e' */

          SET @o_string = replace(@o_string, char(232), 'e')

          SET @o_string = replace(@o_string, char(233), 'e')

          SET @o_string = replace(@o_string, char(234), 'e')

          SET @o_string = replace(@o_string, char(235), 'e')

          /* handles convertion to 'i' */

          SET @o_string = replace(@o_string, char(236), 'i')

          SET @o_string = replace(@o_string, char(237), 'i')

          SET @o_string = replace(@o_string, char(238), 'i')

          SET @o_string = replace(@o_string, char(239), 'i')

          /* handles convertion to 'n' */

          SET @o_string = replace(@o_string, char(241), 'n')

          /* handles convertion to 'o' */

          SET @o_string = replace(@o_string, char(242), 'o')

          SET @o_string = replace(@o_string, char(243), 'o')

          SET @o_string = replace(@o_string, char(244), 'o')

          SET @o_string = replace(@o_string, char(245), 'o')

          SET @o_string = replace(@o_string, char(245), 'o')

          /* handles convertion to 'u' */

          SET @o_string = replace(@o_string, char(249), 'u')

          SET @o_string = replace(@o_string, char(250), 'u')

          SET @o_string = replace(@o_string, char(251), 'u')

          SET @o_string = replace(@o_string, char(252), 'u')

          /* handles convertion to 'y' */

          SET @o_string = replace(@o_string, char(253), 'y')

          SET @o_string = replace(@o_string, char(255), 'y')

          /* handles convertion to special (blank) */

          SET @o_string = replace(@o_string, char(147), '"')

          SET @o_string = replace(@o_string, char(148), '"')

          SET @o_string = replace(@o_string, char(153), '')

          SET @o_string = replace(@o_string, char(161), '')

          SET @o_string = replace(@o_string, char(174), '')

          SET @o_string = replace(@o_string, char(191), '')

          RETURN @o_string

        END


        RETURN null
      END

GO




