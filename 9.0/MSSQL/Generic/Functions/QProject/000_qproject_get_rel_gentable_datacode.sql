if exists (select * from dbo.sysobjects where id = object_id(N'dbo.qproject_rel_gentable_datacode') and xtype in (N'FN', N'IF', N'TF'))
  drop function dbo.qproject_rel_gentable_datacode
GO

CREATE FUNCTION dbo.qproject_rel_gentable_datacode
(
  @i_projectkey as integer,
  @i_tableid as integer,
  @i_datacode as integer
) 
RETURNS INT

/*******************************************************************************************************
**  Name: qproject_rel_gentable_datacode
**  Desc: This function returns value equivalent to gentable datacode - ex: primary title's 
**        season key for Works.
**
**  Auth: Kate Wiewiora
**  Date: April 2 2012
*******************************************************************************************************/

BEGIN 
  DECLARE
    @v_datacode INT,
    @v_itemtype INT
    
  SELECT @v_itemtype = searchitemcode
  FROM taqproject
  WHERE taqprojectkey = @i_projectkey    

  IF @v_itemtype = 9 AND @i_tableid = 329 
    SELECT @v_datacode = t.bestseasonkey
    FROM taqproject p, coretitleinfo t
    WHERE t.bookkey = p.workkey AND 
      t.printingkey = 1 AND
      p.taqprojectkey = @i_projectkey      
  ELSE
    SELECT @v_datacode = @i_datacode
  
  RETURN @v_datacode

END
GO

GRANT EXEC ON dbo.qproject_rel_gentable_datacode TO public
GO