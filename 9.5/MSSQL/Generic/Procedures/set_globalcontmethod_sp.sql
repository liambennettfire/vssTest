if exists (select * from dbo.sysobjects where id = Object_id('dbo.set_globalcontactmethod_sp') and (type = 'P' or type = 'RF'))
begin
 drop proc set_globalcontactmethod_sp
end

GO

/******************************************************************************
**  Name: set_globalcontactmethod_sp
**  Desc: 
**  Auth: 
**  Date: 
*******************************************************************************
**  Change History
*******************************************************************************
**  Date:        Author:     Description:
*   --------     --------    -------------------------------------------
**  04/19/2016   UK          Case 37577
*******************************************************************************/

CREATE PROCEDURE set_globalcontactmethod_sp(
  @i_authorkey int,
  @i_scopetag varchar(15),
  @i_method varchar (80),
  @i_lastuserid varchar (30) 
  ) AS

begin
  declare @v_rows int
  declare @v_key int
  declare @v_methodcode int
  declare @v_methodsubcode int

  select @v_rows = count(*)
    from globalcontactauthor
    where masterkey = @i_authorkey 
      and scopetag = @i_scopetag
  
  select @v_methodcode =
    CASE @i_scopetag 
      WHEN 'phone1' THEN 1
      WHEN 'phone2' THEN 1
      WHEN 'phone3' THEN 1
      WHEN 'fax1' THEN 2
      WHEN 'fax2' THEN 2
      WHEN 'fax3' THEN 2
      WHEN 'email1' THEN 3
      WHEN 'email2' THEN 3
      WHEN 'email3' THEN 3
      WHEN 'url' THEN 4
      ELSE 0
    END
  set @v_methodsubcode =
    CASE @i_scopetag 
      WHEN 'phone1' THEN 2
      WHEN 'phone2' THEN 2
      WHEN 'phone3' THEN 2
      WHEN 'fax1' THEN 1
      WHEN 'fax2' THEN 1
      WHEN 'fax3' THEN 1
      WHEN 'email1' THEN 1
      WHEN 'email2' THEN 1
      WHEN 'email3' THEN 1
      WHEN 'url' THEN 2
      ELSE 0
    END

  if @v_rows=0 or @v_rows is null
    begin
      -- insert
      if @i_method is not null and @i_method <> ''
        begin
          update keys
            set generickey=generickey+1
          select @v_key =  generickey
            from keys
          insert into globalcontactauthor
            values (@i_authorkey,@v_key,@i_scopetag) 
            
          insert into globalcontactmethod
            (globalcontactmethodkey,globalcontactkey,primaryind,
             contactmethodcode,contactmethodsubcode,contactmethodvalue,
             lastuserid,lastmaintdate, sortorder)
          select
            @v_key,@i_authorkey,0,
             @v_methodcode,@v_methodsubcode,@i_method,
             @i_lastuserid,getdate(),
             MAX(COALESCE(sortorder, 0)) + 1
          from globalcontactmethod
          where globalcontactkey = @i_authorkey
        end
      end 
    else
      begin
        select @v_key = detailkey
          from globalcontactauthor
          where masterkey = @i_authorkey 
            and scopetag = @i_scopetag
        if @i_method is null or @i_method = ''
          -- delete
          begin
            delete globalcontactauthor
              where detailkey=@v_key 
            delete globalcontactmethod
              where globalcontactmethodkey=@v_key 
          end
        else
          -- update
          begin
            update globalcontactmethod
              set
                contactmethodvalue = @i_method,
                lastuserid = @i_lastuserid,
                lastmaintdate = getdate()
              where globalcontactmethodkey = @v_key 
          end
      end

end
GO
