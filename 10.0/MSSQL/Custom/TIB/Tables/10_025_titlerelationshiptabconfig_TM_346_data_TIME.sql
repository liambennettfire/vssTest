UPDATE titlerelationshiptabconfig
SET salesunitnetlabel = 'Net Units'
WHERE COALESCE(hidesalesunitind, 0) = 0