IF EXISTS (SELECT * FROM sysobjects WHERE type = 'P' AND name = 'qutl_update_projects_in_list')
  DROP  Procedure  qutl_update_projects_in_list
GO

SET QUOTED_IDENTIFIER ON 
GO
SET ANSI_NULLS ON 
GO

CREATE PROCEDURE qutl_update_projects_in_list
  (@xmlParameters   ntext,
  @o_error_code     integer output,
  @o_error_desc     varchar(2000) output)
AS

/**********************************************************************************
**  Name: qutl_update_projects_in_list
**  Desc: This stored procedure loops through all projects within the passed list
**        and issues updates for each project based on passed criteria array.
**
**  Auth: Kate J. Wiewiora
**  Date: 23 March 2009
***********************************************************************************
**    Change History
***********************************************************************************
**  Date:       Author:   Description:
**  --------    -------   --------------------------------------
**  05/31/17    Colman    44295 - Support for journal search
***********************************************************************************/

DECLARE
  @SearchType SMALLINT  --gentable 442 (Search Type)
  
-- ***** SearchType must be 21 (Project Search Results Update - gentable 442) *******
SET @SearchType = 21

EXEC qutl_update_projects_in_list_base @xmlParameters, @SearchType, @o_error_code output, @o_error_desc output

GO

GRANT EXEC ON qutl_update_projects_in_list TO PUBLIC
GO
