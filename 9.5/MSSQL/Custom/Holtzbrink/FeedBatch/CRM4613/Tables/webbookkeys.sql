create table webbookkeys
(
  bookkey integer not null
)
go

create unique index webbookkeys_p on webbookkeys (bookkey)
go

grant all on webbookxmlfeed to public 
go
