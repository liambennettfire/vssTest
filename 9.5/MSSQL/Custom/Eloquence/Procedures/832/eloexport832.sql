delete from eloflatbookkeys

insert into eloflatbookkeys select distinct (bookkey) from isbn
where isbn in ('0-15-602860-3','0-15-201220-6')

SET NOCOUNT ON

exec eloflatout_sp

exec elo832out_sp

select * from elo832feed

select convert (varchar (10), count (*)) from elo832feed where feedtext like 'LIN%'

select convert (char (8),convert (datetime,'3/1/1999'),112)
select * from eloflatfeed


select convert (char (6),getdate(),8) 

+ 
convert (char (2),month (getdate())) + 
convert (char (2),day (getdate()))

select bookkey from isbn where 