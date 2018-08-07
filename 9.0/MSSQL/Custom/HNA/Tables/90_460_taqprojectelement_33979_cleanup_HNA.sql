delete  from taqprojecttask 
    where bookkey = (select bookkey from coretitleinfo where productnumber = '978-1-4197-2164-9') 
    and taqelementkey in (select taqelementkey from taqprojectelement where bookkey = 15918875
    and taqelementdesc in ('Production #002','Production #003'))
go


delete from taqprojectelement 
 where bookkey = (select bookkey from coretitleinfo where productnumber = '978-1-4197-2164-9') 
   and taqelementdesc in ('Production #002','Production #003')
go


