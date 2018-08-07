if exists (select * from dbo.sysobjects where id = object_id(N'[dbo].[tmm_field_validation]') and OBJECTPROPERTY(id, N'IsProcedure') = 1)
drop procedure [dbo].[tmm_field_validation]
GO


create procedure tmm_field_validation @v_window_name varchar(50), @v_bookkey integer, @v_userid varchar(50), @v_msg varchar(200) output
AS

DECLARE
@v_string_value varchar(8000), 
@v_long_value integer,
@v_security_ind integer 

BEGIN
set @v_msg = ''

SELECT @v_security_ind = securitywindows.accessind
FROM qsiwindows,   
     securitywindows  
WHERE  qsiwindows.windowid = securitywindows.windowid  and  
      qsiwindows.windowcategoryid not in ( 6, 26, 40, 104, 120  )  AND  
      securitywindows.securitygroupkey in (select securitygroupkey from qsiusers where userid = @v_userid)  and
     windowcategoryid in(select qsiwindows.windowcategoryid from qsiwindows where windowname = 'w_tim_title_details') AND 
     windowind='Y' AND 
     applicationind=8 AND 
     userkey is null AND
     windowname = 'w_tim_title_details' 
     
     

if @v_window_name = 'w_tim_title_details' and @v_security_ind <> 1 begin
	select @v_long_value = canadianrestrictioncode
	from bookdetail
	where bookkey = @v_bookkey
	
	if @v_long_value is null or @v_long_value = 0 begin
		set @v_msg = 'Sales Restriction is a required field.'
	end
end
if @v_window_name = 'w_tim_title_information' and @v_security_ind <> 1 begin
	select @v_long_value = canadianrestrictioncode
	from bookdetail
	where bookkey = @v_bookkey
	
	if @v_long_value is null or @v_long_value = 0 begin
		set @v_msg = 'Sales Restriction is a required field. Please enter the required field on Title Classification.'
	end
end

END
GRANT EXECUTE ON dbo.tmm_field_validation TO PUBLIC
GO