
if exists (select * from dbo.sysobjects where id = object_id(N'[dbo].[rpt_oup_get_latest_taqtaskkey]') and xtype in (N'FN', N'IF', N'TF'))
drop function [dbo].[rpt_oup_get_latest_taqtaskkey]


GO


CREATE FUNCTION [dbo].[rpt_oup_get_latest_taqtaskkey] 
            	(@i_taqprojectkey 	INT,
            	@i_datetypecode int,
            	@i_rolecode int,
				@i_globalcontactkey int)
		

 /** Returns the max taqprojecttaskkey from taqprojecttask based on parameters:
 
 taqprojectkey, datetypecode, rolecode, globalcontactkey
 
**/

RETURNS int

AS  



BEGIN 


DECLARE @i_taqtaskkey as int
DECLARE @RETURN as int

Select @i_taqtaskkey = max(taqtaskkey)
FROM taqprojecttask
WHERE taqprojectkey = @i_taqprojectkey 
	AND datetypecode = @i_datetypecode
	AND rolecode = @i_rolecode
	AND globalcontactkey = @i_globalcontactkey
	AND activedate is not null

If @i_taqtaskkey is null
		BEGIN
			SELECT @RETURN = ''
		END	
Else 
		BEGIN
			SELECT @RETURN = @i_taqtaskkey
		END
		

RETURN @RETURN

END

Go
Grant all on rpt_oup_get_latest_taqtaskkey to Public
