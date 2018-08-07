  if exists (select * from dbo.sysobjects where id = object_id(N'dbo.qproject_get_project_participant_by_role') and OBJECTPROPERTY(id, N'IsProcedure') = 1)
drop procedure dbo.qproject_get_project_participant_by_role
GO

SET QUOTED_IDENTIFIER ON 
GO
SET ANSI_NULLS ON 
GO

CREATE PROCEDURE qproject_get_project_participant_by_role
 (@i_userkey integer,
  @i_projectkey  integer,
  @i_datacode    integer,
  @i_itemtype    integer,
  @i_usageclass  integer,
  @o_error_code  integer output,
  @o_error_desc  varchar(2000) output)
AS

/******************************************************************************
**  Name: qproject_get_project_participant_by_role
**  Desc: This stored procedure gets the particpant by Role for the project.
**  @i_datacode = 6, for Participant by Role 1
**				= 7, for Participant By Role 2 
**				= 8, for Participant By Role 3
**
**  Auth: Uday A. Khisty
**  Date: 18 August 2014
**
*********************************************************************************************************************
**  Change History
**********************************************************************************************************************
**  Date:      Author:   Description:
**  --------   ------    -------------------------------------------
**  11/17/16   Colman    Case 40069
**  02/12/18   Colman    Case 49712 Don't filter out rows with globalcontactkey = 0 
**  02/15/18   Colman    Case 45775 Add a 2nd ind to gentablesitemtype to default Role to Key based on item/class
**  03/22/18   Colman    Case 50385 Add text field to Participant by Role section
**  04/10/18   Colman    Case 50348 Date not appearing in the Participant by Role section
**  06/27/18   Colman    Case 51811 Moved functionality into a table function 
*******************************************************************************/

SET @o_error_code = 0
SET @o_error_desc = ''
  
SELECT * FROM dbo.qproject_get_participants_by_role_fn(@i_userkey, @i_projectkey, @i_datacode, @i_itemtype, @i_usageclass)

IF @@ERROR <> 0 BEGIN
  SET @o_error_code = -1
  SET @o_error_desc = 'error accessing qproject_get_participants_by_role_fn: taqprojectkey = ' + cast(@i_projectkey AS VARCHAR)
END 
  
GO

GRANT EXEC ON qproject_get_project_participant_by_role TO PUBLIC
GO


