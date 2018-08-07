IF exists (select * from dbo.sysobjects where id = object_id(N'dbo.qpo_get_gposection_description') )
DROP FUNCTION dbo.qpo_get_gposection_description
GO

SET QUOTED_IDENTIFIER ON 
GO
SET ANSI_NULLS ON 
GO

CREATE FUNCTION dbo.qpo_get_gposection_description 
	(
		@i_gpokey as integer,
		@i_sectionkey as integer,
		@i_subsectionkey as integer
	)
RETURNS varchar(255)

/*******************************************************************************************************
**  Name: [qpo_get_gposection_description]
**  Desc: This function returns the gposection description 
**
**  Auth: Alan Katzen
**  Date: September 30, 2014
*******************************************************************************************************/

BEGIN 
  DECLARE
    @v_description   varchar(255)
    
  SET @v_description = ''
  
  IF @i_sectionkey > 0 AND @i_subsectionkey > 0 BEGIN
    SELECT DISTINCT @v_description =  
	    CASE
	      WHEN s.description IS NULL OR s.description='' THEN
		    CASE
		      WHEN g.description IS NULL OR g.description='' THEN NULL
		      ELSE g.description
		    END
	      WHEN g.description IS NULL OR g.description='' THEN s.description
	      ELSE LTRIM(g.description + ', ' + s.description)
	    END  
      FROM gposection g, gposubsection s
     WHERE g.gpokey = s.gpokey
       and g.sectionkey = s.sectionkey
       and g.gpokey = @i_gpokey
       and g.sectionkey = @i_sectionkey
       and s.subsectionkey = @i_subsectionkey
  END
  ELSE IF @i_sectionkey > 0 BEGIN
    SELECT DISTINCT @v_description = COALESCE(g.description,'') 
      FROM gposection g
     WHERE g.gpokey = @i_gpokey
       and g.sectionkey = @i_sectionkey
  END
      
  RETURN @v_description
  
END
go

grant all on dbo.qpo_get_gposection_description to public
go