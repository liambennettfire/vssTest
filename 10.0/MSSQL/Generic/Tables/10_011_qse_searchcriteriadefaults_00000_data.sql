BEGIN
  
  select * into #qse_searchlist from qse_searchlist where listkey = 46

  update #qse_searchlist
     set listkey = 87, 
         listdesc = 'Author Search Criteria',
         createddate = getdate(),
         lastuserid = 'Firebrand',
         lastmaintdate = getdate()

  delete from qse_searchlist where listkey = 87

  insert into qse_searchlist
  select * from #qse_searchlist

  drop table #qse_searchlist


  select * into #qse_searchcriteriadefaults from qse_searchcriteriadefaults 
  where listkey = 46 and searchcriteriakey != 152

  update #qse_searchcriteriadefaults
     set listkey = 87, 
         [sequence] = [sequence] - 1,
         lastuserid = 'Firebrand',
         lastmaintdate = getdate()

  delete from qse_searchcriteriadefaults where listkey = 87

  insert into qse_searchcriteriadefaults
  select * from #qse_searchcriteriadefaults

  drop table #qse_searchcriteriadefaults
END

