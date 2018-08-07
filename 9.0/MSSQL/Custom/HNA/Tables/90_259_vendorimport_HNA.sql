/*SETTING CORRECT VENDOR FLAGS*/
/*PRINTERS*/
--vendors listed as printers that aren't on a po
--select * from vendor where printerind='y' 
--and vendorkey not in (select vendorkey from gpo)
--171 vendors not on a po
update vendor
set printerind='N'
where printerind='y' and vendorkey not in (
select vendorkey from gpo)
go

/*BOOK VENDORS*/
--vendors listed as book vendors that aren't on a po
--select * from vendor where bookvendind='Y' 
--and vendorkey not in (select vendorkey from gpo)
--215 vendors that aren't on a po 
update vendor
set bookvendind='N'
where bookvendind='y' and vendorkey not in (
select vendorkey from gpo)
go

/*AUDIO/VIDEO*/
--select * from vendor where audvidvendind='Y' 
--and vendorkey not in (select vendorkey from gpo)
--98 vendors that aren't on a po 
update vendor
set audvidvendind='N'
where audvidvendind='y' and vendorkey not in (
select vendorkey from gpo)
go

/*MERCHANDISE*/
--select * from vendor where merchvendind='Y' 
--and vendorkey not in (select vendorkey from gpo)
--210 vendors that aren't on a po 
update vendor
set merchvendind='N'
where merchvendind='y' and vendorkey not in (
select vendorkey from gpo)
go

/*PAPER*/
--select * from vendor where papervendind='Y'
update vendor
set papervendind='N'
where papervendind='y' and vendorkey not in (
select vendorkey from gpo)
go

/*FOREIGN VENDOR - controls import po Foreign Vendor dropdown -importkey=1*/
--select * from vendor where foreignvendind='Y' 
--and vendorkey not in (select vendorkey from gpoimportvendors where importkey=1)
--and (country ='USA' or country ='US')
--38
update vendor
set foreignvendind='N' 
where foreignvendind='Y' and vendorkey not in (select vendorkey from gpoimportvendors where importkey=1)
and (country ='USA' or country ='US')
go

/*AGENTS - controls Agent and Packager Dropdowns on Import Pos - importkey =2 and 3 respectively*/
--select * from vendor where agentvendind='Y' 
--and vendorkey not in (select vendorkey from gpoimportvendors where importkey in (2,3))
--152
update vendor
set agentvendind='N' 
where agentvendind='Y' and vendorkey not in (select vendorkey from gpoimportvendors where importkey in (2,3))
go


/*set inactive*/
update vendor
set activeind=0
where vendorkey in (
946308,
2000590,
925548,
10247480,
685881,
686147,
685880,
685882,
686146,
685879,
1902246,
2,
763541,
6396369,
18,
918254,
1742211,
815656,
1,
815658,
2145918,
4887845,
24,
1999255,
685877,
685878,
685876,
30
)
go
update globalcontact
set activeind=0
where conversionkey in (
946308,
2000590,
925548,
10247480,
685881,
686147,
685880,
685882,
686146,
685879,
1902246,
2,
763541,
6396369,
18,
918254,
1742211,
815656,
1,
815658,
2145918,
4887845,
24,
1999255,
685877,
685878,
685876,
30
)
go