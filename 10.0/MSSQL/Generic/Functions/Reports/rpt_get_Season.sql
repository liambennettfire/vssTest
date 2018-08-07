
/****** Object:  UserDefinedFunction [dbo].[rpt_get_Season]    Script Date: 03/24/2009 13:15:38 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER OFF
GO
if exists (select * from dbo.sysobjects where id = object_id(N'dbo.rpt_get_Season') and xtype in (N'FN', N'IF', N'TF'))
  drop function dbo.rpt_get_Season
GO
CREATE FUNCTION [dbo].[rpt_get_Season] 
            	(@i_bookkey 	INT,
				@c_EstActBest char (1))
		

 
/*      The rpt_get_season function will return the Season + Year based on the bookkey passed 
for the first printing.
Estimated, Actual or Best will be returned based on the parameter.


The parameters are:
book key, 
@c_EstActBest: Estimated Season = 'E', Actual Season ='A', Best Season='B'
*/

RETURNS VARCHAR(100)

AS  

BEGIN 

DECLARE @i_estseasonkey int
DECLARE @i_actseasonkey int
DECLARE @RETURN       		VARCHAR(100)

 

SELECT @i_estseasonkey = estseasonkey,
	@i_actseasonkey = seasonkey
FROM printing
WHERE bookkey = @i_bookkey 
	AND printingkey = 1

if @c_EstActBest = 'B' /* Return Best Season */
begin
	if coalesce (@i_actseasonkey,0) > 0
	begin
		select @RETURN = seasondesc
		from season 
		where seasonkey = @i_actseasonkey
	end
	else if coalesce (@i_estseasonkey,0) > 0 /*Act doesn't exist */
	begin
		select @RETURN = seasondesc
		from season 
		where seasonkey = @i_estseasonkey
	end
 	ELSE -- IF both est and act are null
		BEGIN
			SELECT @RETURN = ''
		END	
end
else if @c_EstActBest = 'E' /* Return Est Season */
begin
	if coalesce (@i_estseasonkey,0) > 0 
	begin
		select @RETURN = seasondesc
		from season 
		where seasonkey = @i_estseasonkey
	end
 	ELSE -- estseason is null
	BEGIN
			SELECT @RETURN = ''
	END
end	
else if @c_EstActBest = 'A' /* Return Act Season */
begin  
	if coalesce (@i_actseasonkey,0) > 0
	begin
		select @RETURN = seasondesc
		from season 
		where seasonkey = @i_actseasonkey
	end
 	ELSE -- actseason is null
	BEGIN
			SELECT @RETURN = ''
	END
end
else /** Invalid paramater - not B, A, or E **/
BEGIN
		SELECT @RETURN = 'invalid parameter'
END	



RETURN @RETURN

END

go
Grant All on dbo.rpt_get_Season to Public
go