USE [BARBOUR_ECF]
GO
/****** Object:  StoredProcedure [dbo].[ProductSearchByAdvancedFilterNew]    Script Date: 03/24/2011 12:56:54 ******/

IF  EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[qweb_ecf_get_AuthorRange]') AND type in (N'P', N'PC'))
DROP PROCEDURE [dbo].[qweb_ecf_get_AuthorRange]
GO

SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

Create PROCEDURE [dbo].[qweb_ecf_get_AuthorRange]
@Range nvarchar(10)

AS

BEGIN
	SET NOCOUNT ON
	DECLARE @Err int

IF @Range = 'Search_A_F'
  BEGIN
    SELECT ObjectID, Contributor_Display_Name
    FROM   ProductEx_Contributors 
    WHERE 
       Contributor_Last_Name like 'A%'
    OR Contributor_Last_Name like 'B%'
    OR Contributor_Last_Name like 'C%'
    OR Contributor_Last_Name like 'D%'
    OR Contributor_Last_Name like 'E%'
    OR Contributor_Last_Name like 'F%'
    ORDER BY Contributor_Last_Name ASC
  END

IF @Range = 'Search_G_L'
  BEGIN
    SELECT ObjectID, Contributor_Display_Name
    FROM   ProductEx_Contributors 
    WHERE 
       Contributor_Last_Name like 'G%'
    OR Contributor_Last_Name like 'H%'
    OR Contributor_Last_Name like 'I%'
    OR Contributor_Last_Name like 'J%'
    OR Contributor_Last_Name like 'K%'
    OR Contributor_Last_Name like 'L%'
    ORDER BY Contributor_Last_Name ASC
  END

IF @Range = 'Search_M_R'
  BEGIN
    SELECT ObjectID, Contributor_Display_Name
    FROM   ProductEx_Contributors 
    WHERE 
       Contributor_Last_Name like 'M%'
    OR Contributor_Last_Name like 'N%'
    OR Contributor_Last_Name like 'O%'
    OR Contributor_Last_Name like 'P%'
    OR Contributor_Last_Name like 'Q%'
    OR Contributor_Last_Name like 'R%'
    ORDER BY Contributor_Last_Name ASC
  END
  
  IF @Range = 'Search_S_Z'
  BEGIN
    SELECT ObjectID, Contributor_Display_Name 
    FROM   ProductEx_Contributors 
    WHERE 
       Contributor_Last_Name like 'S%'
    OR Contributor_Last_Name like 'T%'
    OR Contributor_Last_Name like 'U%'
    OR Contributor_Last_Name like 'V%'
    OR Contributor_Last_Name like 'W%'
    OR Contributor_Last_Name like 'X%'
    OR Contributor_Last_Name like 'Y%'
    OR Contributor_Last_Name like 'Z%'
    ORDER BY Contributor_Last_Name ASC
  END
  

END