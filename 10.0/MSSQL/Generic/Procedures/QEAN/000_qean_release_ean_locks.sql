SET QUOTED_IDENTIFIER ON 
GO
SET ANSI_NULLS ON 
GO

IF EXISTS (SELECT * FROM sysobjects WHERE type = 'P' AND name = 'qean_release_ean_locks')
BEGIN
  DROP PROCEDURE  qean_release_ean_locks
END
GO

CREATE PROCEDURE dbo.qean_release_ean_locks
  @o_error_code INT OUTPUT,
  @o_error_desc VARCHAR(2000) OUTPUT
AS

/* AH 08/02/04 Initial development
   Description: Procedure check if there are old isbnnumbers that are 
		siting in reuseisbns table and make them avaible to users.
*/

DECLARE	
  @OPTION_ID	int,
  @number_of_days	int,
  @isbn		varchar(40),
  @lastmaintdate  datetime,
  @rowcount	int,	
  @error		int

DECLARE c_refres_status CURSOR FOR
select isbn, lastmaintdate
from reuseisbns
where locked = 'Y'

BEGIN
  --set option id for to get number of days 
  select @OPTION_ID = 33

  --get number of days 
  select @number_of_days = optionvalue
  from clientoptions
  where optionid = @OPTION_ID

  select @rowcount = @@rowcount
  select @error = @@error
  -- raise db error
  if @error <> 0 begin
    select @o_error_code = -1
    select @o_error_desc = 'Could not access clientoptions table (@@error=' + CONVERT(VARCHAR, @error) + ').'
    return
  end
  --raise error if not found
  if @rowcount = 0 begin
    select @o_error_code = -1 
    select @o_error_desc = 'Could not select optionvalue from clientoptions table (optionid=33).' 
    return
  end 

  --loop through isb numbers that have locked status set to 'Y' and if thay are older
  --then @number_of_days set status to 'N' so they can be reused.
  OPEN c_refres_status

  FETCH NEXT FROM c_refres_status
  INTO @isbn, @lastmaintdate

  if DATEDIFF (dd , @lastmaintdate , getdate()) > @number_of_days
  begin
    update reuseisbns
    set locked = 'N' , lastuserid = suser_sname(), lastmaintdate = getdate()
    where isbn = @isbn

    select @error = @@error
    -- raise db error
    if @error <> 0
    begin
      select @o_error_code = -1
      select @o_error_desc = 'Could not update reuseisbns table (@@error=' + CONVERT(VARCHAR, @error) + ').'
      return
    end
  end 

  WHILE (@@FETCH_STATUS= 0) 
  BEGIN

    FETCH NEXT FROM c_refres_status
    INTO  @isbn, @lastmaintdate

    if DATEDIFF (dd , @lastmaintdate , getdate()) > @number_of_days
    begin
      update reuseisbns
      set locked = 'N' , lastuserid = suser_sname(), lastmaintdate = getdate()
      where isbn = @isbn
      
      select @error = @@error
      -- raise db error
      if @error <> 0
      begin
        select @o_error_code = -1
        select @o_error_desc = 'Could not update reuseisbns table (@@error=' + CONVERT(VARCHAR, @error) + ').'
        return
      end
    end 

  END
  CLOSE c_refres_status
  DEALLOCATE c_refres_status

END
GO

SET QUOTED_IDENTIFIER OFF 
GO
SET ANSI_NULLS ON 
GO

grant execute on qean_release_ean_locks  to public
go
