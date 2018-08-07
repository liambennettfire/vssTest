IF EXISTS (SELECT * FROM dbo.sysobjects WHERE id = Object_id('dbo.BT_SalesRights_PopulateAll') AND (type = 'P' OR type = 'RF'))
BEGIN
  DROP PROC dbo.BT_SalesRights_PopulateAll
END
GO

/****** Object:  StoredProcedure [dbo].[BT_SalesRights_PopulateAll]    Script Date: 04/16/2013 14:30:04 ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO



CREATE proc [dbo].[BT_SalesRights_PopulateAll]
@bookkey int 
AS
/*
Select TOP 100 * FROM book
where territoriescode IS NOT NULL
and territoriescode <> 290
and bookkey = 10958516

SElect * FROM isbn
where bookkey = 10958630

Select * FROm book
where bookkey = 10958630

Select * FROM gentables
where tableid = 131 and datacode = 271

Select Count(*) FROM book
where territoriescode =  290


Select g.eloquencefieldtag FROM gentablesrelationshipdetail gtr
JOIN gentables g
ON gtr.code2 = g.datacode
WHERE gtr.gentablesrelationshipkey = 4 and gtr.code1 =  280
and g.tableid = 114
and (g.eloquencefieldtag IS NOT NULL AND LEN(g.eloquencefieldtag) > 0 AND g.eloquencefieldtag <> 'N/A') 
and acceptedbyeloquenceind = 1 and g.exporteloquenceind = 1
ORDER BY g.eloquencefieldtag


EXEC dbo.BT_SalesRights 10958772

Select * FROM bookcomments
where commenttypecode = 4 and commenttypesubcode = 40


*/
BEGIN
	DECLARE @countrylist varchar(max)
	SET @countrylist = ''

	DECLARE @commenttext varchar(max)
	DECLARE @comment_html varchar(max)


	DECLARE @territoriescode int
	DECLARE @externalcode varchar(30)
	SET @territoriescode = NULL
	SET @externalcode = ''

	Select @territoriescode = territoriescode, @externalcode = g.externalcode
	from book b join gentables g
	ON b.territoriescode = g.datacode
	where bookkey = @bookkey and g.tableid = 131

	If (@territoriescode IS NULL OR @territoriescode = '') OR (@externalcode IS NULL or @externalcode = '')
		BEGIN
			RETURN
		END

	Select @countrylist = country_list FROM BT_RestCountries where final_code = @externalcode

	

--			Declare @countrycode varchar(20)
--			DECLARE @i_titlefetchstatus int
--				
--
--
--			DECLARE c_selling_rights  CURSOR LOCAL
--				FOR
--				
--				Select g.eloquencefieldtag FROM gentablesrelationshipdetail gtr
--				JOIN gentables g
--				ON gtr.code2 = g.datacode
--				WHERE gtr.gentablesrelationshipkey = 4 and gtr.code1 = @territoriescode
--				and g.tableid = 114
--				and (g.eloquencefieldtag IS NOT NULL AND LEN(g.eloquencefieldtag) > 0 AND g.eloquencefieldtag <> 'N/A') 
--				and acceptedbyeloquenceind = 1 and g.exporteloquenceind = 1
--				ORDER BY g.eloquencefieldtag
--				
--
--				FOR READ ONLY
--						
--				OPEN c_selling_rights 
--
--				FETCH NEXT FROM c_selling_rights 
--					INTO @countrycode
--					select  @i_titlefetchstatus  = @@FETCH_STATUS
--							 while (@i_titlefetchstatus >-1 )
--								begin
--									IF (@i_titlefetchstatus <>-2) 
--										begin
--											
----											Print @countrylist
----											SET @countrylist = @countrylist + Cast(@countrycode as varchar(max)) + ' '
--											SET @countrylist = @countrylist + @countrycode + ' '	
--
----											Print @countrylist
--										end
--									FETCH NEXT FROM c_selling_rights
--										INTO @countrycode
--											select  @i_titlefetchstatus  = @@FETCH_STATUS
--								end
--						
--
--			close c_selling_rights
--			deallocate c_selling_rights





		--If gentable relationship setup has not been done yet, exit
		IF @countrylist = '' OR @countrylist IS NULL
			BEGIN
				RETURN
			END

		
		--Get rid of the final space
		SET @countrylist = RTRIM(@countrylist)

		SET @commenttext = '<salesrights><b089>01</b089><b090>' + @countrylist + '</b090></salesrights>'	

/*
<div>
<p class="MsoNormal">&lt;salesrights&gt;<b><br />
&lt;b089&gt;</b><b>01</b><b>&lt;/b089&gt;<br />
&lt;b090&gt;<br />
AD AE AF AG AI AL AM AN AO AQ AR AS <br />
&lt;/b090&gt;</b><br />
&lt;/salesrights&gt;</p>
</div>

*/

--		SET @comment_html = '<DIV><salesrights><br /><b089>01</b089><br /><b090><br />' + @countrylist + '<br /></b090><br /></salesrights></DIV>'
		SET @comment_html = '<DIV>&lt;salesrights&gt;<br />&lt;b089&gt;01&lt;/b089&gt;<br />&lt;b090&gt;<br />' + @countrylist + '<br />&lt;/b090&gt;<br />&lt;/salesrights&gt;</DIV>'



		IF EXISTS (Select * FROM bookcomments where bookkey = @bookkey and commenttypecode = 4 and commenttypesubcode = 40)
			BEGIN
				Update bookcomments
				SET commentstring = @commenttext,
					commenttext = @commenttext,
					lastuserid = 'qsiadmin', lastmaintdate = getdate(),
					commenthtml = @comment_html, commenthtmllite = @comment_html
				WHERE bookkey = @bookkey and commenttypecode = 4 and commenttypesubcode = 40

			END
		ELSE
			BEGIN
				INSERT INTO bookcomments
				SElect @bookkey, 1, 4, 40, @commenttext, @commenttext, 'qsiadmin', getdate(), NULL, @comment_html, @comment_html, 0, NULL

			END


END

GO


GRANT EXEC ON BT_SalesRights_PopulateAll TO PUBLIC
GO
