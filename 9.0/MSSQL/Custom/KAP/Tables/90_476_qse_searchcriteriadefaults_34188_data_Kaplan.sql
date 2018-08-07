UPDATE qse_searchcriteriadefaults SET numericvalue = NULL 
WHERE searchcriteriakey = 120 and listkey
IN
(select listkey from qse_searchlist WHERE searchtypecode = 6)
AND numericvalue = 1