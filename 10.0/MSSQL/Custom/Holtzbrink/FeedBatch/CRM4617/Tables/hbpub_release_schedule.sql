CREATE TABLE hbpub_release_schedule
(release_date 		datetime NOT NULL,
 pub_month    		datetime NOT NULL,
 warehouse_date 	datetime NOT NULL,
 pub_date  			datetime NOT NULL,
 on_sale_date     datetime NOT NULL)

GO

GRANT ALL ON hbpub_release_schedule TO PUBLIC
go



