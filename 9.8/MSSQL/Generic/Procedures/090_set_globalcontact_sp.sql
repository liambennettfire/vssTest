if exists (select * from dbo.sysobjects where id = Object_id('dbo.set_globalcontact_sp') and (type = 'P' or type = 'RF'))
begin
 drop proc dbo.set_globalcontact_sp
end

GO

/******************************************************************************
**    Change History
*******************************************************************************
**  Date        Who      Change
**  ----------  -------  ------------------------------------------------------
**  10/11/2017  Colman   Case 47714 - Purge SSN references
*******************************************************************************/

CREATE PROCEDURE set_globalcontact_sp(
  @i_authorkey int,
  @i_displayname varchar (80),
  @i_firstname varchar (75) ,
  @i_lastname varchar (75) ,
  @i_middlename varchar (75) ,
  @i_ssn varchar (15) ,
  @i_uscitizenind int ,
  @i_degree varchar(25) ,
  @i_suffix varchar(75) ,
  @i_accreditationcode int,
  @i_notes varchar(255) ,
  @i_corparateind int,
  @i_lastuserid varchar (30),
  @i_activeind int 
  ) AS

  -- this procedure keeps Author and its related Contact row in sync

begin
  declare @v_rows int
  declare @v_key int
  declare @v_searchname varchar(80)
  declare @v_groupname varchar(80)
  declare @v_lastname varchar(80)


  if @i_authorkey is null begin
    return
  end

  -- update or insert comment rows
  select @v_rows = count(*)
    from globalcontactauthor
    where detailkey = @i_authorkey 

  if @v_rows=0 or @v_rows is null
    begin
      update keys
        set generickey=generickey+1
        
      select @v_key =  generickey
        from keys
        
      insert into globalcontactauthor
        values
        (@i_authorkey,@i_authorkey,'contact') 
        
      IF (@i_corparateind = 1)
        BEGIN
          insert into globalcontact
           (globalcontactkey,displayname,searchname,firstname,lastname,middlename,ssn,degree,suffix,accreditationcode,uscitizenind,lastuserid,lastmaintdate,individualind,privateind,grouptypecode,groupname,activeind)
          values
           (@i_authorkey,@i_displayname,upper(@i_lastname),@i_firstname,@i_lastname,@i_middlename,NULL,@i_degree,@i_suffix,@i_accreditationcode,@i_uscitizenind,@i_lastuserid,getdate(),0,0,0,@i_lastname,@i_activeind)      
        END
      ELSE
        BEGIN
          insert into globalcontact
            (globalcontactkey,displayname,searchname,firstname,lastname,middlename,ssn,degree,suffix,accreditationcode,uscitizenind,lastuserid,lastmaintdate,individualind,privateind,grouptypecode,activeind)
          values
            (@i_authorkey,@i_displayname,upper(@i_lastname),@i_firstname,@i_lastname,@i_middlename,NULL,@i_degree,@i_suffix,@i_accreditationcode,@i_uscitizenind,@i_lastuserid,getdate(),1,0,0,@i_activeind)        
        END
    end 
  else
    begin
      IF (@i_corparateind = 1)
        BEGIN
          update globalcontact
          set
            displayname = @i_displayname,
            searchname = upper(@i_lastname),
            groupname = @i_lastname,
            individualind = 0,
            firstname = @i_firstname,
            lastname = @i_lastname,
            middlename = @i_middlename,
            ssn = NULL,
            degree=@i_degree,
            suffix=@i_suffix,
            accreditationcode=@i_accreditationcode,
            uscitizenind = @i_uscitizenind,
            lastuserid = @i_lastuserid,
            lastmaintdate = getdate(),
            activeind = @i_activeind
          where globalcontactkey = @i_authorkey 
        END
      ELSE
        BEGIN
          update globalcontact
          set
            displayname = @i_displayname,
            searchname = upper(@i_lastname),
            groupname = NULL,
            individualind = 1,
            firstname = @i_firstname,
            lastname = @i_lastname,
            middlename = @i_middlename,
            ssn = NULL,
            degree=@i_degree,
            suffix=@i_suffix,
            accreditationcode=@i_accreditationcode,
            uscitizenind = @i_uscitizenind,
            lastuserid = @i_lastuserid,
            lastmaintdate = getdate(),
            activeind = @i_activeind
          where globalcontactkey = @i_authorkey         
        END    
    end

end

GO
