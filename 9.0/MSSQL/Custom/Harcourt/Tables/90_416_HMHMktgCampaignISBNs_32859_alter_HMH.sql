ALTER TABLE HMHMktgCampaignISBNs
DROP CONSTRAINT HMHMktgCampaignISBNs_qp
GO

ALTER TABLE HMHMktgCampaignISBNs
ADD CONSTRAINT HMHMktgCampaignISBNs_qp PRIMARY KEY (processinstancekey,isbn)
go