create table dbo.hb_epl_data
(
	isbn char(10) null,
	init_units integer null,
	init_$ integer null,
	reo_units integer null,
	reo_$ integer null,
	ret_units integer null,
	ret_$ integer null,
	sample_units integer null,
	mayjune_net$ integer null,
	mayjune_roy$ integer null,
	ltd_sales_earnings integer null,
	ltd_subrights_earnings integer null,
	ltd_other_earnings integer null,
	advances integer null,
	marketing_value integer null,
	coop_units integer null,
	coop_value integer null,
	receipt_qty integer null,
	receipt_value integer null,
	closing_inv_units integer null,
	closing_inv_value integer null,
	ppb$ integer null,
	manufacturing$ integer null
)
go
GRANT ALL on hb_epl_data to PUBLIC 
go