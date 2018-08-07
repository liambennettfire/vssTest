/*
set the autogeneratenameind for all printings
*/

Disable trigger ALL on taqproject
GO

update taqproject
set autogeneratenameind = 1
where usageclasscode = 1 and searchitemcode = 14
GO

Enable trigger ALL on taqproject
GO