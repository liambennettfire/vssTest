SET QUOTED_IDENTIFIER ON 
GO
SET ANSI_NULLS ON 
GO

if exists (select * from dbo.sysobjects where id = object_id(N'[dbo].[title_verification_setup]') and OBJECTPROPERTY(id, N'IsProcedure') = 1)
drop procedure [dbo].title_verification_setup
GO

create procedure title_verification_setup
  (@i_bookkey int,@i_userid varchar(80))
AS
DECLARE 
  @v_count int,
  @v_datacode int
  
begin
  declare c_verfs cursor for
    select datacode
      from gentables
      where tableid=556
  open c_verfs
  fetch c_verfs into @v_datacode
  while @@FETCH_STATUS <> -1
    begin
      select @v_count = count(*)
        from bookverification
        where bookkey = @i_bookkey
          and verificationtypecode = @v_datacode
      if @v_count = 0 
        begin  
          insert into bookverification
            (bookkey,verificationtypecode,lastuserid,lastmaintdate)
            values
            (@i_bookkey, @v_datacode, @i_userid, getdate())
        end 
      fetch c_verfs into @v_datacode
    end
  close c_verfs
  deallocate c_verfs 

end


GO
SET QUOTED_IDENTIFIER OFF 
GO
SET ANSI_NULLS ON 
GO

GRANT EXECUTE ON dbo.title_verification_setup TO PUBLIC 
GO


