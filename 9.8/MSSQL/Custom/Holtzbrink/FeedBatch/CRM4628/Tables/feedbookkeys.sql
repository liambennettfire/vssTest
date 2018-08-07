create table dbo.feedbookkeys
(
bookkey numeric(10, 0) not null
)

go
alter table dbo.feedbookkeys
   add constraint sys_c0024711
      primary key ( bookkey ) 
go
grant all on feedbookkeys to public 
go
