truncate table rtf2htmlbookkeys

select * from bookcommentrtf where bookkey=70721
and printingkey=1 and commenttypecode=3
and commenttypesubcode =8

grant all on rtf2htmltext to public
/** Select the bookkeys to convert (or ignore if converting all rows **/
insert into rtf2htmlbookkeys (bookkey,printingkey,commenttypecode,commenttypesubcode)
values (70721,1,3,8)

insert into rtf2htmlbookkeys (bookkey,printingkey,commenttypecode,commenttypesubcode)
select bookkey,printingkey,commenttypecode,commenttypesubcode from bookcommentrtf
go

insert into rtf2htmlbookkeys (bookkey,printingkey,commenttypecode,commenttypesubcode)
select bookkey,printingkey,commenttypecode,commenttypesubcode from bookcommentrtf
where bookkey not in (select bookkey from bookcommenthtml)
go

create unique clustered index bookcommentrtf_p on bookcommentrff (bookkey,printingkey,commenttypecode,commenttypesubcode)

/** Execute the Bookcommenthtml stored procedure */
/* Send zero for 'allbooksind' parameter to export rows specified
in rtf2htmlbookkeys - this may be used for incremental updates
Send one for 'allbooksind' parameter to build complete bookcommenthtml table */
exec bookcommenthtml_sp 0
go

select count (*) from bookcommenthtml
select * from rtf2htmlbookkeys
select * from bookcommenthtml
select * from rtf2htmltext

truncate table bookcommenthtml
if exists (select * from sysobjects where id = object_id(N'[dbo].[bookcommenthtml]') and OBJECTPROPERTY(id, N'IsUserTable') = 1)
drop table [dbo].[bookcommenthtml]
GO

CREATE TABLE [dbo].[bookcommenthtml] (
	[bookkey] [int] NOT NULL ,
	[printingkey] [int] NOT NULL ,
	[commenttypecode] [int] NOT NULL ,
	[commenttypesubcode] [int] NOT NULL ,
	[commentstring] [varchar] (255) NULL ,
	[commenttext] [text] NULL ,
	[lastuserid] [varchar] (30) NULL ,
	[lastmaintdate] [datetime] NULL ,
	[releasetoeloquenceind] [tinyint] NULL 
) ON [PRIMARY] TEXTIMAGE_ON [PRIMARY]
GO

if exists (select * from sysobjects where id = object_id(N'[dbo].[rtf2htmlbookkeys]') and OBJECTPROPERTY(id, N'IsUserTable') = 1)
drop table [dbo].[rtf2htmlbookkeys]
GO

CREATE TABLE [dbo].[rtf2htmlbookkeys] (
	[bookkey] [int] NOT NULL ,
	[printingkey] [int] NOT NULL ,
	[commenttypecode] [int] NOT NULL ,
	[commenttypesubcode] [int] NOT NULL ,
) ON [PRIMARY]
GO

grant all on rtf2htmlbookkeys to public

if exists (select * from sysobjects where id = object_id(N'[dbo].[rtf2htmltext]') and OBJECTPROPERTY(id, N'IsUserTable') = 1)
drop table [dbo].[rtf2htmltext]
GO

CREATE TABLE [dbo].[rtf2htmltext] (
	[commenttext] [text] NULL
) ON [PRIMARY] TEXTIMAGE_ON [PRIMARY]
GO
grant all on rtf2htmltext to public