if exists (select * from dbo.sysobjects where id = object_id(N'[dbo].[qweb_ecf_get_customerDownloads]') and OBJECTPROPERTY(id, N'IsProcedure') = 1)
drop procedure [dbo].[qweb_ecf_get_customerDownloads]
GO

Create Procedure dbo.qweb_ecf_get_customerDownloads
@Customerid int,
@DownLoadId int
AS
BEGIN

	If @DownLoadId IS NULL
	
			Select p.Name as [Name],
			d.DownloadId as [ID],
			d.Name as [DownloadName],
			v.Version as [Version],
			(Datename(weekday, o.Completed) + ', ' + Convert(varchar(12),v.created,107)) as [VersionCreated],
			v.DownloadsCount as [DownLoadsCount],
			os.skuid as SkuId, 
			(Datename(weekday, DateAdd(year, 1, o.Completed)) + ', ' + Convert(varchar(12),DateAdd(year, 1, o.Completed),107)) as ExpiresOn,
			v.FileUrl as FileUrl,
			v.Description,
			(Datename(weekday, o.Completed) + ', ' + Convert(varchar(12),o.Completed,107)) as [Created],
			Convert(varchar(12),DateAdd(year, 1, o.Completed),110) as [dt_ExpDate]
			FROM [Order] o
			JOIN OrderSku os
			ON o.Orderid = os.OrderId
			JOIN SKU s
			ON os.SkuId = s.SkuId
			JOIN Product p
			ON s.productid = p.productId
			JOIN ObjectDownload od
			ON s.Skuid = od.ObjectId
			JOIN Download d
			ON od.DownLoadId = d.DownLoadId
			JOIN Version v
			ON d.DownLoadId = v.DownLoadId
			WHERE o.OrderStatusID <> 5 --5 rejected, 1=in process 2=Approved
			and o.TextResponse = 'Approved' --do we need this ?
			and  @Customerid = o.CustomerId
		Else
			Select p.Name as [Name],
			d.DownloadId as [ID],
			d.Name as [DownloadName],
			v.Version as [Version],
			(Datename(weekday, o.Completed) + ', ' + Convert(varchar(12),v.created,107)) as [VersionCreated],
			v.DownloadsCount as [DownLoadsCount],
			os.skuid as SkuId, 
			(Datename(weekday, DateAdd(year, 1, o.Completed)) + ', ' + Convert(varchar(12),DateAdd(year, 1, o.Completed),107)) as ExpiresOn,
			v.FileUrl as FileUrl,
			v.Description,
			(Datename(weekday, o.Completed) + ', ' + Convert(varchar(12),o.Completed,107)) as [Created],
			Convert(varchar(12),DateAdd(year, 1, o.Completed),110) as [dt_ExpDate]
			FROM [Order] o
			JOIN OrderSku os
			ON o.Orderid = os.OrderId
			JOIN SKU s
			ON os.SkuId = s.SkuId
			JOIN Product p
			ON s.productid = p.productId
			JOIN ObjectDownload od
			ON s.Skuid = od.ObjectId
			JOIN Download d
			ON od.DownLoadId = d.DownLoadId
			JOIN Version v
			ON d.DownLoadId = v.DownLoadId
			WHERE o.OrderStatusID <> 5 --5 rejected, 1=in process 2=Approved
			and o.TextResponse = 'Approved' --do we need this ?
			and  @Customerid = o.CustomerId
		and d.DownLoadId = @DownLoadId
		
END
GO
Grant execute on dbo.qweb_ecf_get_customerDownloads to Public
GO