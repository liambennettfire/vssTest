IF EXISTS (SELECT 1 FROM qse_searchcriteria WHERE searchcriteriakey = 327)
  UPDATE qse_searchcriteria
  SET description = 'Customer/Partner/Asset Type'
  WHERE searchcriteriakey = 327
