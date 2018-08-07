IF  EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[rpt_Get_TerritoryRights_Exclusivity]'))
DROP FUNCTION [dbo].[rpt_Get_TerritoryRights_Exclusivity]
GO

SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO
CREATE FUNCTION rpt_Get_TerritoryRights_Exclusivity(@i_bookkey int)

/* 2014-10-2 KarenG - return the Exclusivity description (Classification section on web for titles) */

RETURNS varchar(1000)
AS
BEGIN
     DECLARE @return varchar(1000)
     DECLARE @v_territory_Rights_Exclusivity varchar(1000)
	 DECLARE @i_ExclusionCode int

	 SELECT @i_ExclusionCode = exclusivecode 
	   FROM territoryrights 
	  WHERE bookkey=@i_bookkey 

	  IF @i_ExclusionCode = 1
	     BEGIN 
	          SELECT @v_territory_Rights_Exclusivity = 'Exclusive'
        END

	  IF @i_ExclusionCode = 2
	     BEGIN 
	          SELECT @v_territory_Rights_Exclusivity = 'Not Exclusive'
         END

	  IF @i_ExclusionCode = 3
	     BEGIN 
	          SELECT @v_territory_Rights_Exclusivity = 'Not For Sale'
          END

     
	 SELECT @return=@v_territory_Rights_Exclusivity 
 
 RETURN @Return

END
GO
GRANT ALL on rpt_Get_TerritoryRights_Exclusivity to PUBLIC