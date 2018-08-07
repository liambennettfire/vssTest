if exists (select * from dbo.sysobjects where id = object_id(N'[dbo].[qweb_ecf_email_customer_notifications]') and OBJECTPROPERTY(id, N'IsProcedure') = 1)
drop procedure [dbo].[qweb_ecf_email_customer_notifications]

go

CREATE procedure [dbo].[qweb_ecf_email_customer_notifications] 
(@NavigateUrlRoot varchar(255),@IMAGE_HTTP_ROOT varchar(255),@IMAGE_SERVER_ROOT varchar(255), @profileName varchar(255)) 
as
BEGIN
/*
Stored proc takes 4 arguments

1- NavigateURLROOT: root directory of the http address of book details page
while testing set it to:
http://unlecfqc.qa.qinformation.com/PublicStore/

append NavigateUrl field from customer_notifications to come up with full path. e.g
product/978-0-8032-2097-3-My-Kitchen-Wars,674069.aspx?skuid=11947

2-IMAGE_HTTP_ROOT: root directory of http address of the image location on the server
use following while testing:
http://unlecfqc.qa.qinformation.com/PublicStore/images/temp/
Append the following dynamic string 
212-671091-Product_LargeToMediumImage-thumb.jpeg
where 212 is MetaClassid, 671091 is productid and rest is static text
http://unlecfqc.qa.qinformation.com/PublicStore/images/temp/212-671091-Product_LargeToMediumImage-thumb.jpeg
3-IMAGE_SERVER_ROOT
Need this parameter because we're checking to see if the file exists on the server or not
via the extended proc xp_fileexists
if we pass IMAGE_HTTP_ROOT to this proc it always returns false
if file does not exist show a default image, this way the image link is not broken in the email
\\mcdonald\Websites\UNL_eCF_QC\WebSite\PublicStore\images\temp\


4-ProfileName is the Profile created in DatabaseMail

*/
DECLARE @Skuid int,
		@Name nvarchar(256),
		@CustomerEmail nvarchar(256),
		@NavigateUrl nvarchar(256),
		@uniqueid int,
		@Sku_EAN nvarchar(512),
		@SKU_Full_Title nvarchar(512), 
		@SKU_Format nvarchar(256), 
		@SKU_PubYear nvarchar(256), 
		@SKU_Pagecount nvarchar(256), 
		@SKU_LargeToMediumImage int, 
		@AuthorByLinePrePro nvarchar(max),
		@productid int, 
		@MetaClassid int,
		@FullPrice money,
		@Price money,
		@i_titlefetchstatus int


	DECLARE c_qweb_notifications INSENSITIVE CURSOR
	FOR

	Select cn.skuid, cn.Name, cn.CustomerEmail, cn.NavigateUrl,cn.uniqueid,
	tbf.SKU_EAN, tbf.SKU_Full_Title, tbf.SKU_Format, tbf.SKU_PubYear, tbf.SKU_Pagecount, 
	tbf.SKU_LargeToMediumImage, 
	tbf.AuthorByLinePrePro, sku.productid, sku.MetaClassid,
	tbf.FullPrice, sku.Price
	FROM dbo.skuex_title_by_format tbf
	JOIN dbo.Customer_notification cn
	ON tbf.ObjectId = cn.Skuid
	JOIN SKU sku
	ON tbf.ObjectId = sku.SkuId
	WHERE tbf.Objectid in
	(Select Distinct Skuid FROM dbo.Customer_notification Where cn.NotificationSentInd = 0)
	and tbf.TitleStatus = 'Available- In Stock'

	FOR READ ONLY
			
	OPEN c_qweb_notifications 

	FETCH NEXT FROM c_qweb_notifications 
		INTO @Skuid, @Name,
		@CustomerEmail,@NavigateUrl,@uniqueid ,
		@Sku_EAN,@SKU_Full_Title, @SKU_Format,@SKU_PubYear, 
		@SKU_Pagecount,@SKU_LargeToMediumImage, @AuthorByLinePrePro,@productid, 
		@MetaClassid ,@FullPrice ,@Price


	select  @i_titlefetchstatus  = @@FETCH_STATUS

	 while (@i_titlefetchstatus >-1 )
		begin
			IF (@i_titlefetchstatus <>-2) 
			begin
			
			Declare @tableHTML nvarchar(max)
			Declare @href  nvarchar(1024)
			Declare @imgSrc nvarchar(1024)
			Declare @i_skufileexists_flag int
			SET @imgSrc = @IMAGE_SERVER_ROOT + Cast(@MetaClassid as varchar(20)) + '-'+ Cast(@Skuid as varchar(20)) + '-' + 'SKU_LargeToMediumImage-thumb.Jpeg'
			--xp_fileexist is in System Databases-->master-->Extended Stored Procedures
			exec xp_fileexist  @imgSrc, @i_skufileexists_flag output
			if @i_skufileexists_flag = 0
				--No jpeg found for sku image, try product image, if not found use default and make sure this default image exists on the production server
				Begin
						Print 'SKU FILE EXISTS?=' + Cast(@i_skufileexists_flag as char(1)) + ' ' + @imgSrc
						Declare @i_productfileexists_flag int
						Declare @ProductMetaClassid int
						Select @ProductMetaClassid = MetaClassid from product where productid = @productid
						SET @imgSrc = @IMAGE_SERVER_ROOT + Cast(@ProductMetaClassid as varchar(20)) + '-'+ Cast(@productid as varchar(20)) + '-' + 'Product_LargeToMediumImage-thumb.Jpeg'
						exec xp_fileexist  @imgSrc, @i_productfileexists_flag output
						if @i_productfileexists_flag = 0
							BEGIN
								Print 'PRODUCT FILE EXISTS?=' + Cast(@i_productfileexists_flag as char(1)) + ' ' + @imgSrc
								SET @imgSrc = @IMAGE_HTTP_ROOT + 'cover_placeholder.jpg'
							END
						else
							BEGIN
								SET @imgSrc = @IMAGE_HTTP_ROOT + Cast(@ProductMetaClassid as varchar(20)) + '-'+ Cast(@productid as varchar(20)) + '-' + 'Product_LargeToMediumImage-thumb.Jpeg'
								Print 'PRODUCT FILE EXISTS?=' + Cast(@i_productfileexists_flag as char(1)) + ' ' + @imgSrc
								END

				End
			else
						BEGIN
							SET @imgSrc = @IMAGE_HTTP_ROOT + Cast(@MetaClassid as varchar(20)) + '-'+ Cast(@Skuid as varchar(20)) + '-' + 'SKU_LargeToMediumImage-thumb.Jpeg'
							Print 'SKU FILE EXISTS?=' + Cast(@i_skufileexists_flag as char(1)) + ' ' + @imgSrc
						END
			SET @href = @NavigateUrlRoot + @NavigateUrl


/*

<p style="font-size:20pt;">HTML font code is done using CSS.</p>
<p style="color:orange;">HTML font code is done using CSS.</p>
<p style="font-weight:bold;">HTML font code is done using CSS.</p>
<p>You can bold <span style="font-weight:bold">parts</span> of your text using the HTML 'span' tag.</p>
<p style="font-family:Garamond, Georgia, serif;">HTML font code is done using CSS.</p>

*/



			SET @tableHTML =
			N'<H1>Email Test</H1>' +
			N'<table width="600">' +
			N'<tr><td colspan="2">Dear ' + @Name + ',<br />As per your request, we are contacting you to ' +
			N'let you know that the following title is now available in stock!<br />' +
			N'Please <a href="' + @href + '">click here.</a> to route to this title''s page on our website<br />' +
			N'</td></tr>' + 
			N'<tr><td><img src="' + @imgsrc  + '"></td>' +
			N'<td><b>'+ @SKU_Full_Title + '</b>' +
			N'<br>' + @AuthorByLinePrePro +
			N'<br>' + @SKU_Format + ' (' +@SKU_PubYear+')' +
			N'<br>' + @Sku_EAN +
			N'<br><p sytle="color:red;">$' + Cast(@Price as varchar(20)) + '</p>' +
			N'</td></tr>' + 
			N'<tr><td colspan="2"><br>Thanks !<br>Your friends at University of Nebraska Press' +
			N'</tr></table>'

			Declare @subjectline nvarchar(256)
			Declare @mailitemid int
			SET @subjectline = @SKU_Full_Title + N'is now AVAILABLE IN STOCK!'

			EXEC msdb.dbo.sp_send_dbmail
			@profile_name = @profileName,
			@recipients = @CustomerEmail,
			@body = @tableHTML,
			@subject = @subjectline,
			@body_format = 'HTML', 
			@mailitem_id = @mailitemid OUTPUT;

			Print Cast(@mailitemid as varchar(20)) + ' is the mailitemid for ' + @CustomerEmail

			If @mailitemid > 1 --SUCCESS
				BEGIN
					--Select * FROM  Customer_notification table
					Update dbo.Customer_notification
					SET SkuStatus = 'Available- In Stock',
					NotificationSentInd = 1,
					NotificationSentDate = getdate(),
					lastuserid = 'dbMail'
					WHERE uniqueid = @uniqueid
				END
			ELSE
				BEGIN 	--Just update lastuserid and date. This way we can tell which notifications were not updated 
					Update dbo.Customer_notification
					SET lastuserid = 'dbMail'
					WHERE uniqueid = @uniqueid
				END




			end

			FETCH NEXT FROM c_qweb_notifications
			INTO @Skuid, @Name,
			@CustomerEmail,@NavigateUrl,@uniqueid ,
			@Sku_EAN,@SKU_Full_Title, @SKU_Format,@SKU_PubYear, 
			@SKU_Pagecount,@SKU_LargeToMediumImage, @AuthorByLinePrePro,@productid, 
			@MetaClassid ,@FullPrice ,@Price
			select  @i_titlefetchstatus  = @@FETCH_STATUS
		end

close c_qweb_notifications
deallocate c_qweb_notifications

END

GO
Grant execute on dbo.qweb_ecf_email_customer_notifications to Public
GO
