if exists (select * from dbo.sysobjects where id = object_id(N'dbo.qtitle_get_authors_from_qsicomments') and xtype in (N'FN', N'IF', N'TF'))
  drop function dbo.qtitle_get_authors_from_qsicomments
GO

CREATE FUNCTION dbo.qtitle_get_authors_from_qsicomments
(
  @i_bookkey as integer
) 
RETURNS varchar(max)

/*******************************************************************************************************
**  Name: qtitle_get_authors_from_qsicomments
**  Desc: This function returns the authors from qsicomments based on the fullauthordisplaykey
**        on bookdetail.
**
**  Auth: Alan Katzen
**  Date: September 11 2008
*******************************************************************************************************/

BEGIN 
  DECLARE
    @v_count  INT,
    @v_fullauthordisplaykey  INT,
    @v_authors varchar(max)
    
  SET @v_authors = null  
  SET @v_fullauthordisplaykey = 0
  
  SELECT @v_fullauthordisplaykey = COALESCE(fullauthordisplaykey,0),
         @v_authors = fullauthordisplayname
  FROM bookdetail
  WHERE bookkey = @i_bookkey
  
  IF @v_fullauthordisplaykey > 0 BEGIN
    SELECT @v_authors = commenttext
    FROM qsicomments
    WHERE commentkey = @v_fullauthordisplaykey
  END
  
  RETURN @v_authors
END
GO

GRANT EXEC ON dbo.qtitle_get_authors_from_qsicomments TO public
GO
