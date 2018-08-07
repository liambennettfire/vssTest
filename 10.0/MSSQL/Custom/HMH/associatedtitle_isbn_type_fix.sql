-- Correct ISBN-13 associated titles with the wrong productidtype

UPDATE associatedtitles SET productidtype=2 where len(isbn) = 17 and isbn LIKE '978%' AND productidtype <> 2