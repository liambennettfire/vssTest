IF EXISTS (SELECT * FROM dbo.sysobjects WHERE id = object_id(N'dbo.qutl_get_lock_user_displayname') AND xtype in (N'FN', N'IF', N'TF'))
  DROP FUNCTION dbo.qutl_get_lock_user_displayname
GO

CREATE FUNCTION [dbo].[qutl_get_lock_user_displayname]  
(  
  @i_userid as varchar(30)
)  
RETURNS VARCHAR(150)  
  
/****************************************************************************************************************************
**  Name: qutl_get_lock_user_displayname
**  Desc: Gets the best displayname for a given userid on the locks table, initial story: TM-358
**
*****************************************************************************************************************************
**    Change History
*****************************************************************************************************************************
**    Date:        Author:         Description:
**    --------     --------        --------------------------------------------------------------------------------------
**    3/7/2018		JHess			Initial Creation per story TM-358
*****************************************************************************************************************************/
   
BEGIN 
  DECLARE
    @gccUserId_var as VARCHAR(150),
	@qsiusers_first_last_name as varchar(150)
	
	SELECT @gccUserId_var = g.displayname
	FROM qsiusers q
		INNER JOIN globalcontact g ON q.userkey = g.userid 
	where q.userid = @i_userid

	if @gccUserId_var IS NOT NULL AND ltrim(rtrim(@gccUserId_var)) <> '' 
		BEGIN
			return '''' + @gccUserId_var + ''''
		END
	ELSE
	BEGIN
		select 	@qsiusers_first_last_name = q.firstname + ' ' + q.lastname 
		from qsiusers q 
		where q.userid = @i_userid 

		if @qsiusers_first_last_name IS NOT NULL AND ltrim(rtrim(@qsiusers_first_last_name)) <> ''
			BEGIN
				return '''' +  @qsiusers_first_last_name  + ''''
			END
	END
	RETURN '''' +  @i_userid + ''''

END

GO

GRANT EXEC ON dbo.qutl_get_lock_user_displayname TO public
GO