/******************************************************************************
**  Name: 
**  Desc: 
**  Auth: 
**  Date: 
*******************************************************************************
**  Change History
*******************************************************************************
**  Date:        Author:     Description:
*   --------     --------    -------------------------------------------
**  04/18/18     OA          Case 50945 - Task 001 Finished
*******************************************************************************/

IF EXISTS (SELECT * FROM sysobjects WHERE id = object_id('dbo.authortopublicity_ins_trig') AND type = 'TR')
	DROP TRIGGER dbo.authortopublicity_ins_trig
GO


IF EXISTS (SELECT * FROM sysobjects WHERE id = object_id('dbo.authortopublicity_ins_trig') AND type = 'TR')
	DROP TRIGGER dbo.authortopublicity_ins_trig
GO
