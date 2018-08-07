if exists (select * from dbo.sysobjects where id = object_id(N'dbo.qproject_rel_gentable_datadesc') and xtype in (N'FN', N'IF', N'TF'))
  drop function dbo.qproject_rel_gentable_datadesc
GO

CREATE FUNCTION dbo.qproject_rel_gentable_datadesc
(
  @i_projectkey as integer,
  @i_tableid as integer,
  @i_datacode as integer
) 
RETURNS VARCHAR(40)

/*******************************************************************************************************
**  Name: qproject_rel_gentable_datadesc
**  Desc: This function returns value equivalent to gentable descriptions
**        example: primary title's season description for Works.
**
**  Auth: Kate Wiewiora
**  Date: April 2 2012
*******************************************************************************************************/

BEGIN 
  DECLARE
    @v_datadesc VARCHAR(40),
    @v_itemtype INT
    
  SELECT @v_itemtype = searchitemcode
  FROM taqproject
  WHERE taqprojectkey = @i_projectkey    

  IF @v_itemtype = 9 AND @i_tableid = 329 
    SELECT @v_datadesc = t.seasondesc
    FROM taqproject p, coretitleinfo t
    WHERE t.bookkey = p.workkey AND 
      t.printingkey = 1 AND
      p.taqprojectkey = @i_projectkey      
  ELSE
    SELECT @v_datadesc = dbo.get_gentables_desc(@i_tableid, @i_datacode, 'long')
  
  RETURN @v_datadesc

END
GO

GRANT EXEC ON dbo.qproject_rel_gentable_datadesc TO public
GO