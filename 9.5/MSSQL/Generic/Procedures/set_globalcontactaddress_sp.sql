if exists (select * from dbo.sysobjects where id = Object_id('dbo.set_globalcontactaddress_sp') and (type = 'P' or type = 'RF'))
begin
 drop proc set_globalcontactaddress_sp
end
go

CREATE PROCEDURE set_globalcontactaddress_sp(
  @i_authorkey int,
  @i_scopetag varchar(15),
  @v_defaultaddressnumber int,
  @i_line1 varchar (80),
  @i_line2 varchar (80),
  @i_line3 varchar (80),
  @i_city varchar (80),
  @i_statecode int,
  @i_zipcode varchar(15),
  @i_countrycode int,
  @i_addresstypecode int,
  @i_lastuserid varchar (30) 
  ) AS

  -- this procedure keeps Authro and its related Contact row in sync

begin
  declare @v_rows int
  declare @v_key int

  select @v_rows = count(*)
    from globalcontactauthor
    where masterkey = @i_authorkey 
      and scopetag = @i_scopetag

  if @v_rows=0 or @v_rows is null
    -- insert
    begin
      if (@i_line1 is not null and @i_line1 <> '') or 
         (@i_line2 is not null and @i_line2 <> '') or 
         (@i_line3 is not null and @i_line3 <> '') or 
         (@i_city is not null and @i_city <> '') or 
         (@i_statecode is not null and @i_statecode <> '') or 
         (@i_zipcode is not null and @i_zipcode <> '') or 
         (@i_countrycode is not null and @i_countrycode <> '') 
        begin
          update keys
            set generickey=generickey+1
          select @v_key =  generickey
            from keys
          insert into globalcontactauthor
            values (@i_authorkey,@v_key,@i_scopetag) 
          insert into globalcontactaddress
            (globalcontactaddresskey,globalcontactkey,addresstypecode,primaryind,
             address1,address2,address3,
             city,statecode,zipcode,countrycode,
             lastuserid,lastmaintdate)
            values
            (@v_key,@i_authorkey,@i_addresstypecode,@v_defaultaddressnumber,
             @i_line1,@i_line2,@i_line3,
             @i_city,@i_statecode,@i_zipcode,@i_countrycode,
             @i_lastuserid,getdate())
        end
    end 
  else
    begin
      select @v_key = detailkey
        from globalcontactauthor
         where masterkey = @i_authorkey 
           and scopetag = @i_scopetag
      if (@i_line1 is null or @i_line1 = '') and 
         (@i_line2 is null or @i_line2 = '') and 
         (@i_line3 is null or @i_line3 = '') and 
         (@i_city is null or @i_city = '') and 
         (@i_statecode is null or @i_statecode = '') and 
         (@i_zipcode is null or @i_zipcode = '') and 
         (@i_countrycode is null or @i_countrycode = '')
        begin 
          --delete
           delete globalcontactauthor
             where detailkey=@v_key 
           delete globalcontactaddress
             where globalcontactaddresskey=@v_key 
        end
      else
        begin  
          update globalcontactaddress
            set
              addresstypecode = @i_addresstypecode,
              primaryind = @v_defaultaddressnumber,
              address1 = @i_line1,
              address2 = @i_line2,
              address3 = @i_line3,
              city = @i_city,
              statecode = @i_statecode,
              zipcode = @i_zipcode,
              countrycode = @i_countrycode,
              lastuserid = @i_lastuserid,
              lastmaintdate = getdate()
            where globalcontactaddresskey = @v_key 
        end
    end
end

GO
