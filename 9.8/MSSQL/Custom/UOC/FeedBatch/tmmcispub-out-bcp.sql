/*  tmmcispub-out-bcp.sql **/
/** This SQL will bcp out the data **/


Print 'BCP titles'
go


set nocount on
go

DECLARE @c_datestamp varchar (20)
DECLARE @cmd sysname,@var sysname

select @c_datestamp = replace(convert(varchar,getdate(),101),'/','') + ltrim(replace(substring (convert(varchar,getdate(),109),13,5) ,':',''))

set @var = 'PSS5..feedout_titles out c:\' + 'tmmtocispub_title' + @c_datestamp + '.txt -SPSS5  -Uqsidba -Pqsidba -c -t"	"'
set @cmd = 'bcp ' + @var

exec master..xp_cmdshell  @cmd
go


Print 'BCP authors'
go


set nocount on
go

DECLARE @c_datestamp varchar (20)
DECLARE @cmd sysname,@var sysname

select @c_datestamp = replace(convert(varchar,getdate(),101),'/','') + ltrim(replace(substring (convert(varchar,getdate(),109),13,5) ,':',''))

set @var = 'PSS5..feedout_authors out c:\' + 'tmmtocispub_auth' + @c_datestamp + '.txt -SPSS5  -Uqsidba -Pqsidba -c -t"	"'
set @cmd = 'bcp ' + @var

exec master..xp_cmdshell  @cmd
go


Print 'BCP Subjects'
go


set nocount on
go

DECLARE @c_datestamp varchar (20)
DECLARE @cmd sysname,@var sysname

select @c_datestamp = replace(convert(varchar,getdate(),101),'/','') + ltrim(replace(substring (convert(varchar,getdate(),109),13,5) ,':',''))

set @var = 'PSS5..feedout_majorsubj out c:\' + 'tmmtocispub_subj' + @c_datestamp + '.txt -SPSS5  -Uqsidba -Pqsidba -c -t"	"'
set @cmd = 'bcp ' + @var

exec master..xp_cmdshell  @cmd
go
