--BASIC Contact Search Criteria - Last Name/Group Name default to 'Contains'
UPDATE qse_searchcriteriadefaults SET defaultoperator = 2 WHERE listkey = 3 AND searchcriteriakey = 65
--BASIC Project Search Criteria - Participant Last Name default to 'Contains'
UPDATE qse_searchcriteriadefaults SET defaultoperator = 2 WHERE listkey = 4 AND searchcriteriakey = 68
