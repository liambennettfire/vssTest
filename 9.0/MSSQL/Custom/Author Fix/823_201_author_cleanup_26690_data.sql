-- backup author and globalcontactauthor tables
SELECT * INTO author_bak FROM author 
go
SELECT * INTO globalcontactauthor_bak FROM globalcontactauthor 
go
 
-- disable triggers
DISABLE TRIGGER set_globalcontact_tr ON dbo.author
go
DISABLE TRIGGER set_globalcontactaddress_tr ON dbo.author
go
DISABLE TRIGGER set_globalcontmethod_tr ON dbo.author
go
DISABLE TRIGGER maintainwhsandelo ON dbo.author
go

---- disable send to eloquence outbox (PGI has all author fields as resend to elo)
--update titlehistorycolumns
--set exporteloquenceind = 0
--where lower(tablename) like '%author%'
--go

declare
  @v_count int,
  @v_masterkey int,
  @v_detailkey int,
  @v_scopetag varchar(20),
  @v_address1 varchar(200),
  @v_address2 varchar(200),
  @v_address3 varchar(200),
  @v_city varchar(200),
  @v_zipcode varchar(20),
  @v_statecode int,
  @v_countrycode int,
  @o_error_code int,
  @o_error_desc varchar(500),
  @minauthorkey INT,
  @numrows INT,
  @counter INT,
  @v_roletype_author INT,
  @v_authortype INT,
  @count_var INT

BEGIN
  SELECT @v_roletype_author = datacode
    FROM gentables
   WHERE tableid = 285
     and qsicode = 4
  
  --gather all globalcontactkeys for authors 
  create  table #tmp_authorkeys
  (authorkey	int)

  insert into #tmp_authorkeys
    SELECT DISTINCT authorkey 
      FROM author a, globalcontact gc    
     WHERE a.authorkey=gc.globalcontactkey
       and a.authorkey not in (select masterkey from globalcontactauthor)
    ORDER BY a.authorkey

  select @numrows = count(*), @minauthorkey = min(authorkey) 
  from #tmp_authorkeys

  set @counter = 1
  while @counter < = @numrows
  begin
    set @v_masterkey = @minauthorkey
     
--print '..................'
--print @v_masterkey
    -- check to see if contact has author roles - add if not
    SELECT @count_var=count(*)
      FROM globalcontactrole r
     WHERE r.globalcontactkey = @v_masterkey and
           r.rolecode in (SELECT code2 FROM gentablesrelationshipdetail 
                           WHERE gentablesrelationshipkey = 1) 

    IF @count_var <= 0 BEGIN
      -- check to see if any author roles already exist for author
      SELECT @count_var=count(*)
        FROM bookauthor ba, gentablesrelationshipdetail gd
       WHERE ba.authorkey = @v_masterkey
         AND ba.authortypecode > 0
         AND ba.authortypecode = gd.code1  
         AND gd.gentablesrelationshipkey = 1   
               
      IF @count_var > 0 BEGIN
        -- author roles already exist for author
        INSERT INTO globalcontactrole (globalcontactkey,rolecode,keyind,lastuserid,lastmaintdate,sortorder)
        SELECT DISTINCT @v_masterkey,gd.code2,0,'firebrand',getdate(),1
          FROM bookauthor ba, gentablesrelationshipdetail gd
         WHERE ba.authorkey = @v_masterkey
           AND ba.authortypecode > 0
           AND ba.authortypecode = gd.code1  
           AND gd.gentablesrelationshipkey = 1         
      END
      ELSE BEGIN
        -- no author roles for the author - insert author role for globalcontact
        INSERT INTO globalcontactrole (globalcontactkey,rolecode,keyind,lastuserid,lastmaintdate,sortorder)
        VALUES (@v_masterkey,@v_roletype_author,0,'firebrand',getdate(),1)
      END
    END

    -- check for contact row
    set @o_error_code = null
    set @o_error_desc = null
    exec qcontact_update_author @v_masterkey,@v_masterkey,'firebrand','globalcontact',@o_error_code output,@o_error_desc output
    if @o_error_code<>0
      begin
        print 'Error (masterkey='+cast(@v_masterkey as varchar)+') '+cast(coalesce(@o_error_code,0) as varchar)+' '+coalesce(@o_error_desc,'n/a')
      end

    -- check for addr1-3 
    declare addresses cursor fast_forward for
      select globalcontactaddresskey
        from globalcontactaddress
        where globalcontactkey=@v_masterkey
    open addresses
    -- addressline 1
    fetch addresses into @v_detailkey
    if @@fetch_status=0
      begin
        set @o_error_code = null
        set @o_error_desc = null
        exec qcontact_update_author @v_masterkey,@v_detailkey,'firebrand','globalcontactaddress',@o_error_code output,@o_error_desc output
        if @o_error_code<>0
          begin
            print 'Error (masterkey='+cast(@v_masterkey as varchar)+', detailkey='+cast(@v_detailkey as varchar)+') '+cast(coalesce(@o_error_code,0) as varchar)+' '+coalesce(@o_error_desc,'n/a')
          end
      end
    -- addressline 1
    fetch addresses into @v_detailkey
    if @@fetch_status=0
      begin
        set @o_error_code = null
        set @o_error_desc = null
        exec qcontact_update_author @v_masterkey,@v_detailkey,'firebrand','globalcontactaddress',@o_error_code output,@o_error_desc output
        if @o_error_code<>0
          begin
            print 'Error (masterkey='+cast(@v_masterkey as varchar)+', detailkey='+cast(@v_detailkey as varchar)+') '+cast(coalesce(@o_error_code,0) as varchar)+' '+coalesce(@o_error_desc,'n/a')
          end
      end
    -- addressline 1
    fetch addresses into @v_detailkey
    if @@fetch_status=0
      begin
        set @o_error_code = null
        set @o_error_desc = null
        exec qcontact_update_author @v_masterkey,@v_detailkey,'firebrand','globalcontactaddress',@o_error_code output,@o_error_desc output
        if @o_error_code<>0
          begin
            print 'Error (masterkey='+cast(@v_masterkey as varchar)+', detailkey='+cast(@v_detailkey as varchar)+') '+cast(coalesce(@o_error_code,0) as varchar)+' '+coalesce(@o_error_desc,'n/a')
          end
      end
    close addresses
    deallocate addresses

    -- check for phone 1-3
    declare methods cursor fast_forward for
      select globalcontactmethodkey
        from globalcontactmethod
        where globalcontactkey=@v_masterkey
          and contactmethodcode=1
    open methods
    -- phone 1
    fetch methods into @v_detailkey
    if @@fetch_status=0
      begin
        set @o_error_code = null
        set @o_error_desc = null
        exec qcontact_update_author @v_masterkey,@v_detailkey,'firebrand','globalcontmethod',@o_error_code output,@o_error_desc output
        if @o_error_code<>0
          begin
            print 'Error (masterkey='+cast(@v_masterkey as varchar)+', detailkey='+cast(@v_detailkey as varchar)+') '+cast(coalesce(@o_error_code,0) as varchar)+' '+coalesce(@o_error_desc,'n/a')
          end
      end
    -- phone 2
    fetch methods into @v_detailkey
    if @@fetch_status=0
      begin
        set @o_error_code = null
        set @o_error_desc = null
        exec qcontact_update_author @v_masterkey,@v_detailkey,'firebrand','globalcontmethod',@o_error_code output,@o_error_desc output
        if @o_error_code<>0
          begin
            print 'Error (masterkey='+cast(@v_masterkey as varchar)+', detailkey='+cast(@v_detailkey as varchar)+') '+cast(coalesce(@o_error_code,0) as varchar)+' '+coalesce(@o_error_desc,'n/a')
          end
      end
    -- phone 3
    fetch methods into @v_detailkey
    if @@fetch_status=0
      begin
        set @o_error_code = null
        set @o_error_desc = null
        exec qcontact_update_author @v_masterkey,@v_detailkey,'firebrand','globalcontmethod',@o_error_code output,@o_error_desc output
        if @o_error_code<>0
          begin
            print 'Error (masterkey='+cast(@v_masterkey as varchar)+', detailkey='+cast(@v_detailkey as varchar)+') '+cast(coalesce(@o_error_code,0) as varchar)+' '+coalesce(@o_error_desc,'n/a')
          end
      end
    close methods
    deallocate methods

    -- check for fax 1-3
    declare methods cursor fast_forward for
      select globalcontactmethodkey
        from globalcontactmethod
        where globalcontactkey=@v_masterkey
          and contactmethodcode=2
    open methods
    -- fax 1
    fetch methods into @v_detailkey
    if @@fetch_status=0
      begin
        set @o_error_code = null
        set @o_error_desc = null
        exec qcontact_update_author @v_masterkey,@v_detailkey,'firebrand','globalcontmethod',@o_error_code output,@o_error_desc output
        if @o_error_code<>0
          begin
            print 'Error (masterkey='+cast(@v_masterkey as varchar)+', detailkey='+cast(@v_detailkey as varchar)+') '+cast(coalesce(@o_error_code,0) as varchar)+' '+coalesce(@o_error_desc,'n/a')
          end
      end
    -- fax 2
    fetch methods into @v_detailkey
    if @@fetch_status=0
      begin
        set @o_error_code = null
        set @o_error_desc = null
        exec qcontact_update_author @v_masterkey,@v_detailkey,'firebrand','globalcontmethod',@o_error_code output,@o_error_desc output
        if @o_error_code<>0
          begin
            print 'Error (masterkey='+cast(@v_masterkey as varchar)+', detailkey='+cast(@v_detailkey as varchar)+') '+cast(coalesce(@o_error_code,0) as varchar)+' '+coalesce(@o_error_desc,'n/a')
          end
      end
    -- fax 3
    fetch methods into @v_detailkey
    if @@fetch_status=0
      begin
        set @o_error_code = null
        set @o_error_desc = null
        exec qcontact_update_author @v_masterkey,@v_detailkey,'firebrand','globalcontmethod',@o_error_code output,@o_error_desc output
        if @o_error_code<>0
          begin
            print 'Error (masterkey='+cast(@v_masterkey as varchar)+', detailkey='+cast(@v_detailkey as varchar)+') '+cast(coalesce(@o_error_code,0) as varchar)+' '+coalesce(@o_error_desc,'n/a')
          end
      end
    close methods
    deallocate methods

    -- check for email 1-3
    declare methods cursor fast_forward for
      select globalcontactmethodkey
        from globalcontactmethod
        where globalcontactkey=@v_masterkey
          and contactmethodcode=3
    open methods
    -- email 1
    fetch methods into @v_detailkey
    if @@fetch_status=0
      begin
        set @o_error_code = null
        set @o_error_desc = null
        exec qcontact_update_author @v_masterkey,@v_detailkey,'firebrand','globalcontmethod',@o_error_code output,@o_error_desc output
        if @o_error_code<>0
          begin
            print 'Error (masterkey='+cast(@v_masterkey as varchar)+', detailkey='+cast(@v_detailkey as varchar)+') '+cast(coalesce(@o_error_code,0) as varchar)+' '+coalesce(@o_error_desc,'n/a')
          end
      end
    -- email 2
    fetch methods into @v_detailkey
    if @@fetch_status=0
      begin
        set @o_error_code = null
        set @o_error_desc = null
        exec qcontact_update_author @v_masterkey,@v_detailkey,'firebrand','globalcontmethod',@o_error_code output,@o_error_desc output
        if @o_error_code<>0
          begin
            print 'Error (masterkey='+cast(@v_masterkey as varchar)+', detailkey='+cast(@v_detailkey as varchar)+') '+cast(coalesce(@o_error_code,0) as varchar)+' '+coalesce(@o_error_desc,'n/a')
          end
      end
    -- email 3
    fetch methods into @v_detailkey
    if @@fetch_status=0
      begin
        set @o_error_code = null
        set @o_error_desc = null
        exec qcontact_update_author @v_masterkey,@v_detailkey,'firebrand','globalcontmethod',@o_error_code output,@o_error_desc output
        if @o_error_code<>0
          begin
            print 'Error (masterkey='+cast(@v_masterkey as varchar)+', detailkey='+cast(@v_detailkey as varchar)+') '+cast(coalesce(@o_error_code,0) as varchar)+' '+coalesce(@o_error_desc,'n/a')
          end
      end
    close methods
    deallocate methods

    -- check for URL row
    select @v_detailkey=globalcontactmethodkey
      from globalcontactmethod
      where globalcontactkey=@v_masterkey
        and contactmethodcode=4
    set @o_error_code = null
    set @o_error_desc = null
    exec qcontact_update_author @v_masterkey,@v_detailkey,'firebrand','globalcontmethod',@o_error_code output,@o_error_desc output
    if @o_error_code<>0
      begin
        print 'Error (masterkey='+cast(@v_masterkey as varchar)+', detailkey='+cast(@v_detailkey as varchar)+') '+cast(coalesce(@o_error_code,0) as varchar)+' '+coalesce(@o_error_desc,'n/a')
      end

    -- check for biogr row
    set @o_error_code = null
    set @o_error_desc = null
    exec qcontact_update_author @v_masterkey,@v_masterkey,'firebrand','qsicomments',@o_error_code output,@o_error_desc output
    if @o_error_code<>0
      begin
        print 'Error (masterkey='+cast(@v_masterkey as varchar)+') '+cast(coalesce(@o_error_code,0) as varchar)+' '+coalesce(@o_error_desc,'n/a')
      end

    select @counter = @counter + 1

	  select @minauthorkey = min(authorkey)
	  from #tmp_authorkeys
	  where authorkey > @minauthorkey	
  end
  drop table #tmp_authorkeys
END
go

---- enable send to eloquence outbox (PGI has all author fields as resend to elo)
--update titlehistorycolumns
--set exporteloquenceind = 1
--where lower(tablename) like '%author%'
--go

-- enable triggers
ENABLE TRIGGER set_globalcontact_tr ON dbo.author
go
ENABLE TRIGGER set_globalcontactaddress_tr ON dbo.author
go
ENABLE TRIGGER set_globalcontmethod_tr ON dbo.author
go
ENABLE TRIGGER maintainwhsandelo ON dbo.author
go

