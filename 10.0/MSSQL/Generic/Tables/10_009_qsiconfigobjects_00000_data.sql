DECLARE @v_windowid int

BEGIN
  select @v_windowid = windowid 
  from qsiwindows
  where windowname = 'search'

  update qsiconfigobjects
  set configobjectdesc = 'Product Search',
      defaultlabeldesc = 'Product Search'
  where windowid = @v_windowid

  update qsiconfigdetail
  set labeldesc = 'Product Search'
  where configobjectkey in (select configobjectkey from qsiconfigobjects
                             where windowid = @v_windowid)

END