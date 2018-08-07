delete from isbnprefixrange
where eanprefixcode = 1 and isbngroup = 1
go
insert into isbnprefixrange (eanprefixcode, isbngroup, beginrange, endrange, prefixlength)
values (1,1,'0000000','0999999',2)
go
insert into isbnprefixrange (eanprefixcode, isbngroup, beginrange, endrange, prefixlength)
values (1,1,'1000000','3999999',3)
go
insert into isbnprefixrange (eanprefixcode, isbngroup, beginrange, endrange, prefixlength)
values (1,1,'4000000','5499999',4)
go
insert into isbnprefixrange (eanprefixcode, isbngroup, beginrange, endrange, prefixlength)
values (1,1,'5500000','7319999',5)
go
insert into isbnprefixrange (eanprefixcode, isbngroup, beginrange, endrange, prefixlength)
values (1,1,'7320000','7399999',7)
go
insert into isbnprefixrange (eanprefixcode, isbngroup, beginrange, endrange, prefixlength)
values (1,1,'7400000','7749999',5)
go
insert into isbnprefixrange (eanprefixcode, isbngroup, beginrange, endrange, prefixlength)
values (1,1,'7750000','7753999',7)
go
insert into isbnprefixrange (eanprefixcode, isbngroup, beginrange, endrange, prefixlength)
values (1,1,'7754000','8697999',5)
go
insert into isbnprefixrange (eanprefixcode, isbngroup, beginrange, endrange, prefixlength)
values (1,1,'8698000','9729999',6)
go
insert into isbnprefixrange (eanprefixcode, isbngroup, beginrange, endrange, prefixlength)
values (1,1,'9730000','9877999',4)
go
insert into isbnprefixrange (eanprefixcode, isbngroup, beginrange, endrange, prefixlength)
values (1,1,'9878000','9989999',6)
go
insert into isbnprefixrange (eanprefixcode, isbngroup, beginrange, endrange, prefixlength)
values (1,1,'9990000','9999999',7)
go
