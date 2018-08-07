if exists (select * from dbo.sysobjects where id = object_id(N'dbo.calc_alarm_clock') and OBJECTPROPERTY(id, N'IsProcedure') = 1)
  drop procedure dbo.calc_alarm_clock
GO

SET QUOTED_IDENTIFIER ON 
GO
SET ANSI_NULLS ON 
GO
CREATE PROCEDURE calc_alarm_clock (  
  @projectkey INT, 
  @result     int OUTPUT)  
AS  
  
/******************************************************************************************  
**  Name: calc_alarm_clock
**  Desc: expiration date - today.  
**  
**  Auth: Olivia 
**  Date: August 30 2017  
*******************************************************************************************/  
    
BEGIN  
declare @expirationdate datetime
  
  select @expirationdate = activedate from taqprojecttask where datetypecode = 497 and taqprojectkey = @projectkey

 if @expirationdate > GetDate()
 (
   select @result = DATEDIFF(DAY, GetDATE(), @expirationdate)
 )

 else
 (
   select @result = 0
 )

END  

GO

GRANT EXEC ON calc_alarm_clock TO PUBLIC
GO
