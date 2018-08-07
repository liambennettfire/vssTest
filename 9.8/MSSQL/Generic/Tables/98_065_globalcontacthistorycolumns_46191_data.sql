update globalcontacthistorycolumns
set tablename = 'qsicomments', columnname = 'commenthtml'
where tablename = 'globalcontact'
and columnname = 'biography'
go
