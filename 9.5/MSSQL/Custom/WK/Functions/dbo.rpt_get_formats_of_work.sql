if exists (select * from dbo.sysobjects where id = object_id(N'dbo.[rpt_get_formats_of_work]') and OBJECTPROPERTY(id, N'IsScalarFunction') = 1)
drop function dbo.[rpt_get_formats_of_work]
GO
CREATE function [dbo].[rpt_get_formats_of_work] 
(@bookkey int,
@i_isbn_type	INT,
@seperator char(1))

/*	PARAMETER @i_isbn_type
		10 = ISBN10
		13 = ISBN 13
		16 = EAN
		17 = EAN (no dashes)
		18 = GTIN
		19 = GTIN (no dashes)
		20 = LCCN
		21 = UPC
*/
RETURNS varchar(512)

BEGIN
	DECLARE @bkey int
	DECLARE @RETURN varchar(512)
	DECLARE @i_titlefetchstatus int

	SET @RETURN = ''

	DECLARE c_formatsofwork CURSOR
		FOR
		Select bookkey from book where workkey in
		(Select workkey from book where bookkey = @bookkey)


		FOR READ ONLY
				
		OPEN c_formatsofwork
		
		FETCH NEXT FROM c_formatsofwork
			INTO @bkey

			select  @i_titlefetchstatus  = @@FETCH_STATUS

			 while (@i_titlefetchstatus >-1 )
				begin
					IF (@i_titlefetchstatus <>-2) 
						begin
							IF (Case WHEN dbo.rpt_get_isbn(@bkey, @i_isbn_type) = '' OR dbo.rpt_get_isbn(@bkey, @i_isbn_type) IS NULL THEN (Select itemnumber from isbn where bookkey = @bkey)
								 ELSE dbo.rpt_get_isbn(@bkey, @i_isbn_type) END) <> ''
								BEGIN
									SET	@RETURN = @RETURN + (Case WHEN dbo.rpt_get_isbn(@bkey, @i_isbn_type) = '' OR dbo.rpt_get_isbn(@bkey, @i_isbn_type) IS NULL THEN (Select itemnumber from isbn where bookkey = @bkey) ELSE dbo.rpt_get_isbn(@bkey, @i_isbn_type) END) + @seperator
								END
							
						end


		FETCH NEXT FROM c_formatsofwork
		INTO @bkey
				select  @i_titlefetchstatus  = @@FETCH_STATUS
			end

	close c_formatsofwork
	deallocate c_formatsofwork

IF LEN(@RETURN) > 0
	SET @RETURN = SUBSTRING(@RETURN,1 , LEN(@RETURN) -1)

RETURN @RETURN
END