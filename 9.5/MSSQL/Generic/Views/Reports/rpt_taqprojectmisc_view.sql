
/****** Object:  View [dbo].[rpt_taqprojectmisc_view]    Script Date: 03/24/2009 13:39:34 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
if exists (select * from dbo.sysobjects where id = object_id(N'dbo.rpt_taqprojectmisc_view') and xtype in (N'FN', N'IF', N'TF'))
  drop function dbo.rpt_taqprojectmisc_view
GO
create view [dbo].[rpt_taqprojectmisc_view]
as
select tpm.taqprojectkey, tpm.misckey, bmi.miscname, tpm.longvalue, bmi.misctype
from taqprojectmisc tpm, bookmiscitems bmi
where tpm.misckey = bmi.misckey
go
Grant All on dbo.rpt_taqprojectmisc_view to Public
go
