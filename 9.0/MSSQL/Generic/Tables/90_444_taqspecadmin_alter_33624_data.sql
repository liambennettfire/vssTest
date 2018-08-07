ALTER TABLE taqspecadmin ADD  CONSTRAINT DF_taqspecadm_showvalidprtgsind  DEFAULT 0 FOR showvalidprtgsind

ALTER TABLE taqspecadmin ADD  CONSTRAINT DF_taqspecadm_prodspecsaccessind  DEFAULT 1 FOR prodspecsaccessind

UPDATE taqspecadmin SET prodspecsaccessind = 1 WHERE prodspecsaccessind IS NULL