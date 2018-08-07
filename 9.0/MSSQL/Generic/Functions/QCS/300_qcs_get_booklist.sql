IF  EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[qcs_get_booklist]') AND type in (N'FN', N'IF', N'TF', N'FS', N'FT'))
DROP FUNCTION [dbo].[qcs_get_booklist]
GO
CREATE FUNCTION [dbo].[qcs_get_booklist](@listkey int = NULL, @userkey int = NULL, @bookkey int = NULL, @allworksfortitle tinyint = 0)
RETURNS @books TABLE (bookkey int primary key, customerkey int null, workkey int, eloqcustomerid char(6), csapprovalcode int null)
AS
BEGIN
    IF @listkey IS NOT NULL AND @listkey > 0 BEGIN
        IF @allworksfortitle = 1 BEGIN
            INSERT INTO @books
            SELECT
                b.bookkey,
                c.customerkey,
                b.workkey,
                c.eloqcustomerid,
                bd.csapprovalcode
            FROM book AS b
            JOIN bookdetail AS bd ON b.bookkey=bd.bookkey
            LEFT JOIN customer AS c ON
                b.elocustomerkey = c.customerkey AND
                c.cloudaccesskey IS NOT NULL AND
                c.cloudaccesssecret IS NOT NULL
            WHERE b.workkey IN (
                SELECT DISTINCT b.workkey
                FROM 
                    qse_searchresults AS qr,
                    book AS b 
                WHERE 
                    qr.key1 = b.bookkey AND 
                    qr.listkey = @listkey)
        END
        ELSE BEGIN
            INSERT INTO @books
            SELECT DISTINCT
                b.bookkey,
                c.customerkey,
                b.workkey,
                c.eloqcustomerid,
                bd.csapprovalcode
            FROM qse_searchresults AS qr
            JOIN book AS b ON qr.key1 = b.bookkey
            JOIN bookdetail AS bd ON b.bookkey=bd.bookkey
            LEFT JOIN customer AS c ON
                b.elocustomerkey = c.customerkey AND
                c.cloudaccesskey IS NOT NULL AND
                c.cloudaccesssecret IS NOT NULL	
            WHERE qr.listkey = @listkey
        END
	END
	ELSE IF @bookkey IS NOT NULL AND @bookkey > 0 BEGIN
        IF @allworksfortitle = 1 BEGIN
            DECLARE @workkey INT
            SELECT @workkey=workkey FROM book WHERE bookkey=@bookkey

            INSERT INTO @books
            SELECT
                b.bookkey,
                c.customerkey,
                b.workkey,
                c.eloqcustomerid,
                bd.csapprovalcode
            FROM book AS b
            JOIN bookdetail AS bd ON b.bookkey = bd.bookkey
            LEFT JOIN customer AS c ON
                b.elocustomerkey = c.customerkey AND
                c.cloudaccesskey IS NOT NULL AND
                c.cloudaccesssecret IS NOT NULL
            WHERE
                b.workkey = @workkey
        END
        ELSE BEGIN
            INSERT INTO @books
            SELECT
                b.bookkey,
                c.customerkey,
                b.workkey,
                c.eloqcustomerid,
                bd.csapprovalcode
            FROM book AS b
            JOIN bookdetail AS bd ON b.bookkey = bd.bookkey
            LEFT JOIN customer AS c ON
                b.elocustomerkey = c.customerkey AND
                c.cloudaccesskey IS NOT NULL AND
                c.cloudaccesssecret IS NOT NULL
            WHERE
                b.bookkey = @bookkey
        END
	END
	ELSE BEGIN
		INSERT INTO @books
		SELECT DISTINCT
			b.bookkey,
			c.customerkey,
			b.workkey,
            c.eloqcustomerid,
            bd.csapprovalcode
		FROM qse_searchlist AS ql 
		JOIN qse_searchresults AS qr ON ql.listkey = qr.listkey
		JOIN book AS b ON qr.key1 = b.bookkey
        JOIN bookdetail AS bd ON b.bookkey = bd.bookkey
		LEFT JOIN customer AS c ON
			b.elocustomerkey = c.customerkey AND
			c.cloudaccesskey IS NOT NULL AND
			c.cloudaccesssecret IS NOT NULL	
	  WHERE ql.userkey = @userkey
	    AND ql.searchtypecode = 6
	    AND ql.listtypecode = 1
	END
	RETURN
END
GO

GRANT SELECT ON dbo.qcs_get_booklist TO PUBLIC
GO
