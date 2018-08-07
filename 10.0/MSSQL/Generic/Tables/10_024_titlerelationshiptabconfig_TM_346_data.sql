UPDATE titlerelationshiptabconfig
SET salesunitnetlabel = 'Sales Units'
WHERE COALESCE(hidesalesunitind, 0) = 0

UPDATE titlerelationshiptabconfig
SET salesunitgrosslabel = 'Gross Units'
WHERE COALESCE(hidegrossunitind, 0) = 0