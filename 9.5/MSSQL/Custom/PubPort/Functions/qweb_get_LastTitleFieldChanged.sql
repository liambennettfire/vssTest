SET QUOTED_IDENTIFIER ON 
GO
SET ANSI_NULLS ON 
GO

if exists (select * from dbo.sysobjects where id = object_id(N'[dbo].[qweb_get_LastTitleFieldChanged]') and xtype in (N'FN', N'IF', N'TF'))
drop function [dbo].[qweb_get_LastTitleFieldChanged]
GO




CREATE FUNCTION dbo.qweb_get_LastTitleFieldChanged (
		@bookkey INT, 
		@printingkey INT,
		@i_columnkey INT)
	RETURNS DATETIME
AS
BEGIN
	DECLARE @return DATETIME
	SELECT @return = MAX(lastmaintdate)
		FROM titlehistory
		WHERE bookkey = @bookkey
			AND printingkey = @printingkey
			AND columnkey = @i_columnkey
  RETURN @return
END

/*  History Column Key
	1	Title
	2	Internal Status
	3	Subtitle
	4	BISAC Status
	6	Author
	7	Price Type
	8	Estimated Price
	9	Actual Price
	10	Media
	11	Format
	12	Estimated Season
	13	Actual Season
	15	Estimated Page Count
	16	Actual Page Count
	17	Estimated Quantity
	18	Actual Quantity
	19	Estimated Trim Size Width
	20	Estimated Trim Size Length
	21	Trim Size Width
	22	Trim Size Length
	23	Group Level
	24	Task Estimated Date
	25	Task Actual Date
	26	Jacket Vendor
	27	Binding Vendor
	28	Language
	29	Grade Low
	30	Grade High
	31	Currency
	32	Age Low
	33	Age High
	34	Restriction Code
	35	Return Code
	36	Active Date
	37	Estimated Date
	38	Bisac Heading
	39	Bisac Sub Heading
	40	Author Type
	41	Short Title
	42	Title Prefix
	43	ISBN
	44	UPC
	45	EAN
	46	LCCN
	47	Edition
	48	Sales Division
	49	Origin
	50	Series
	51	User Level
	52	Volume
	53	Software Platform
	54	Type
	55	Territory
	56	Author Display Name
	57	Author Last Name
	58	Author First Name
	59	Author Middle Name
	60	Author Primary Ind
	61	Age High 'and up' Ind
	62	Age Low 'and up' Ind
	63	Grade High 'and up' Ind
	64	Grade Low 'and up' Ind
	65	Personnel
	66	Personnel Type
	67	Citation Source
	68	Citation Author
	69	Citation Date
	70	Comment
	71	Author Citation
	72	Author Biography
	73	File Type
	74	File Format
	75	File and Path Name
	76	Pub Month
	80	Estimated Announced First Ptg
	81	Actual Announced First Ptg
	82	Estimated Insert/Illus
	83	Actual Insert/Illus
	84	Publish To Web
	85	TMM Sales Forecast
	86	TMM Actual Trim Width
	87	TMM Actual Trim Length
	88	TMM Page Count
	90	Discount Code
	91	Audience Code
	92	All Ages Indicator
	96	Book Weight
	97	Release to Eloquence
	100	Price Effective Date
	101	Full Author Display Name
	102	Budget Forecast
	103	Book Category
	104	Send To Eloquence
	105	Set Type
	106	Set Available Date
	107	Set Prefix
	108	Set Name	
	109	Set Subtitle
	110	Set Short Title
	111	Set Media
	112	Set Format
	113	Title Verification
	114	Number of Cassettes
	115	Total Run Time
	116	Citation Note
	117	Citation Proofed.
	118	Citation Web
	119	Citation Send to Elo
	124	Canadian Restriction

*/




GO
SET QUOTED_IDENTIFIER OFF 
GO
SET ANSI_NULLS ON 
GO

