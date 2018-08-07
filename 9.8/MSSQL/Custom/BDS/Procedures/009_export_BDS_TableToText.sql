SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO


IF EXISTS (SELECT * FROM sysobjects WHERE type = 'P' AND name = 'export_BDS_TableToText')
BEGIN
  DROP  Procedure  dbo.export_BDS_TableToText
END
GO

CREATE PROCEDURE [dbo].[export_BDS_TableToText](@database	VARCHAR(100),
					@server		VARCHAR(100),
					@userid		VARCHAR(30))
AS
BEGIN
/* BCP table outs		*/

		execute create_tmmtocispub_file  @database,'bds_tmm_cispub_feed','TMM2CISPUB','E:\TestData\BDS\',@server,'qsidba','qsidba'
END


