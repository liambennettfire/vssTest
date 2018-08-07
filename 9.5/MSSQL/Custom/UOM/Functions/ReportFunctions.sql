if exists (select * from dbo.sysobjects where id = object_id(N'[dbo].[reports_calc_EstEditionCost]') and xtype in (N'FN', N'IF', N'TF'))
drop function [dbo].[reports_calc_EstEditionCost]
GO

if exists (select * from dbo.sysobjects where id = object_id(N'[dbo].[reports_calc_EstTotalCost]') and xtype in (N'FN', N'IF', N'TF'))
drop function [dbo].[reports_calc_EstTotalCost]
GO

if exists (select * from dbo.sysobjects where id = object_id(N'[dbo].[reports_get_EstMiscTypes]') and xtype in (N'FN', N'IF', N'TF'))
drop function [dbo].[reports_get_EstMiscTypes]
GO

if exists (select * from dbo.sysobjects where id = object_id(N'[dbo].[reports_get_EstVersionDiscount]') and xtype in (N'FN', N'IF', N'TF'))
drop function [dbo].[reports_get_EstVersionDiscount]
GO

if exists (select * from dbo.sysobjects where id = object_id(N'[dbo].[reports_get_EstVersionListPrice]') and xtype in (N'FN', N'IF', N'TF'))
drop function [dbo].[reports_get_EstVersionListPrice]
GO

if exists (select * from dbo.sysobjects where id = object_id(N'[dbo].[reports_get_EstVersionQty]') and xtype in (N'FN', N'IF', N'TF'))
drop function [dbo].[reports_get_EstVersionQty]
GO

if exists (select * from dbo.sysobjects where id = object_id(N'[dbo].[reports_get_EstVersionRoyalty]') and xtype in (N'FN', N'IF', N'TF'))
drop function [dbo].[reports_get_EstVersionRoyalty]
GO

if exists (select * from dbo.sysobjects where id = object_id(N'[dbo].[ump_reports_get_CompCopies]') and xtype in (N'FN', N'IF', N'TF'))
drop function [dbo].[ump_reports_get_CompCopies]
GO

SET QUOTED_IDENTIFIER ON 
GO
SET ANSI_NULLS ON 
GO


CREATE FUNCTION reports_calc_EstEditionCost(
	@i_estkey INT,
	@i_versiontype	INT,
	@i_simulqty	INT
) 

RETURNS FLOAT
AS
BEGIN
  
	DECLARE @f_editioncost	FLOAT
	DECLARE @f_cfgroupcost	FLOAT
	DECLARE @f_othercosts	FLOAT
	DECLARE @i_versionqty	INT



	SELECT	@f_cfgroupcost = sum(ec.totalcost)
	FROM	estcost ec 
		LEFT OUTER JOIN estspecs es ON ec.versionkey = es.versionkey 
			AND ec.estkey = es.estkey
	WHERE	@i_estkey = ec.estkey
	GROUP BY ec.estkey, ec.versionkey, es.mediatypecode, es.mediatypesubcode
	HAVING	(es.mediatypecode = 0) AND (es.mediatypesubcode = 0)


IF @i_versiontype = 1
BEGIN
	SELECT @f_othercosts = sum(ec.totalcost)
	FROM	estcost ec 
		LEFT OUTER JOIN estspecs es ON ec.versionkey = es.versionkey 
			AND ec.estkey = es.estkey
	WHERE	@i_estkey = ec.estkey
	GROUP BY ec.estkey, ec.versionkey, es.mediatypecode, es.mediatypesubcode
	HAVING	(es.mediatypecode = 2) AND (es.mediatypesubcode in(6,26))


	SELECT	@i_versionqty = e.finishedgoodqty
	FROM	estversion e 
			RIGHT OUTER JOIN estspecs es ON e.estkey = es.estkey AND e.versionkey = es.versionkey 
			LEFT OUTER JOIN estbook eb ON es.estkey = eb.estkey
	WHERE     @i_estkey = e.estkey
			AND (eb.estimatetypecode = 1) 
			AND (e.versiontypecode = 1) 
			AND (es.mediatypecode = 2) 
			AND (es.mediatypesubcode IN (6, 26))


END

IF @i_versiontype = 2
BEGIN
	SELECT @f_othercosts = sum(ec.totalcost)
	FROM	estcost ec 
		LEFT OUTER JOIN estspecs es ON ec.versionkey = es.versionkey 
			AND ec.estkey = es.estkey
	WHERE	@i_estkey = ec.estkey
	GROUP BY ec.estkey, ec.versionkey, es.mediatypecode, es.mediatypesubcode
	HAVING	(es.mediatypecode = 2) AND (es.mediatypesubcode in(20,27))

	
	SELECT  @i_versionqty = e.finishedgoodqty
	FROM	  estversion e 
		 RIGHT OUTER JOIN estspecs es ON e.estkey = es.estkey AND e.versionkey = es.versionkey 
		 LEFT OUTER JOIN estbook eb ON es.estkey = eb.estkey
	WHERE  @i_estkey = e.estkey
			AND (eb.estimatetypecode = 1) 
			AND (e.versiontypecode = 1) 
			AND (es.mediatypecode = 2) 
			AND (es.mediatypesubcode IN (20, 27))
END

	
	SET @f_editioncost = ((@f_cfgroupcost/@i_simulqty) * @i_versionqty) + @f_othercosts

		  
	RETURN @f_editioncost
END











GO
SET QUOTED_IDENTIFIER OFF 
GO
SET ANSI_NULLS ON 
GO

GRANT  REFERENCES ,  EXECUTE  ON [dbo].[reports_calc_EstEditionCost]  TO [public]
GO

SET QUOTED_IDENTIFIER ON 
GO
SET ANSI_NULLS ON 
GO

CREATE FUNCTION reports_calc_EstTotalCost(
	@i_estkey INT
) 

RETURNS FLOAT
AS
BEGIN
  
	DECLARE @f_esttotalcost	FLOAT

	SELECT @f_esttotalcost = sum(totalcost)
	FROM  estcost
	WHERE @i_estkey = estkey
		  
	RETURN @f_esttotalcost
END







GO
SET QUOTED_IDENTIFIER OFF 
GO
SET ANSI_NULLS ON 
GO

GRANT  REFERENCES ,  EXECUTE  ON [dbo].[reports_calc_EstTotalCost]  TO [public]
GO

SET QUOTED_IDENTIFIER ON 
GO
SET ANSI_NULLS ON 
GO


CREATE FUNCTION reports_get_EstMiscTypes(
	@i_estkey INT,
	@i_versionkey INT,
	@i_esttableid INT,
	@i_estdatacode INT,
	@i_estmisctypetableid INT
) 

RETURNS VARCHAR(40)
AS
BEGIN
  
	DECLARE @c_description VARCHAR(40)

	SELECT @c_description = g.datadesc
	FROM  estmiscspecs e, misctypetable m, gentables g
	WHERE @i_estkey = e.estkey
		AND @i_versionkey = e.versionkey
		AND @i_estmisctypetableid = m.tableid 
		AND @i_esttableid = m.datacode
		AND m.tablecode = g.tableid 
		AND @i_estdatacode = g.datacode


  
	RETURN @c_description
END





GO
SET QUOTED_IDENTIFIER OFF 
GO
SET ANSI_NULLS ON 
GO

GRANT  REFERENCES ,  EXECUTE  ON [dbo].[reports_get_EstMiscTypes]  TO [public]
GO

SET QUOTED_IDENTIFIER ON 
GO
SET ANSI_NULLS ON 
GO

CREATE FUNCTION reports_get_EstVersionDiscount(
	@i_estkey INT,
	@i_versiontype INT
) 

/* PARAMETERS
	@i_estkey is from estbook or estversion
	@i_versiontype 	= 1 to retrieve Cloth Text/Trade Cloth Discount
			= 2 to retrieve Paper Text/Trade Paper Discount
*/	 

RETURNS FLOAT
AS
BEGIN
  
DECLARE @f_versiondiscount	FLOAT


IF  @i_versiontype = 1 	
	BEGIN
		SELECT	@f_versiondiscount = ep.discountpercent
		FROM	estplspecs ep 
			RIGHT OUTER JOIN estspecs es ON ep.estkey = es.estkey 
				AND ep.versionkey = es.versionkey 
			LEFT OUTER JOIN estversion e ON es.estkey = e.estkey 
				AND es.versionkey = e.versionkey 
			FULL OUTER JOIN estbook eb ON es.estkey = eb.estkey
		WHERE	@i_estkey = e.estkey
				AND (e.versiontypecode = 1) 
				AND (es.mediatypecode = 2) 
				AND (es.mediatypesubcode IN (6, 26))
	END  

IF  @i_versiontype = 2 	
	BEGIN
		SELECT	@f_versiondiscount = ep.discountpercent
		FROM	estplspecs ep 
			RIGHT OUTER JOIN estspecs es ON ep.estkey = es.estkey 
				AND ep.versionkey = es.versionkey 
			LEFT OUTER JOIN estversion e ON es.estkey = e.estkey 
				AND es.versionkey = e.versionkey 
			FULL OUTER JOIN estbook eb ON es.estkey = eb.estkey
		WHERE	@i_estkey = e.estkey
				AND (e.versiontypecode = 1) 
				AND (es.mediatypecode = 2) 
				AND (es.mediatypesubcode IN (20,27))

  	END

RETURN @f_versiondiscount

END














GO
SET QUOTED_IDENTIFIER OFF 
GO
SET ANSI_NULLS ON 
GO

GRANT  REFERENCES ,  EXECUTE  ON [dbo].[reports_get_EstVersionDiscount]  TO [public]
GO

SET QUOTED_IDENTIFIER ON 
GO
SET ANSI_NULLS ON 
GO

CREATE FUNCTION reports_get_EstVersionListPrice(
	@i_estkey INT,
	@i_versiontype INT
) 

/* PARAMETERS
	@i_estkey is from estbook or estversion
	@i_versiontype 	= 1 to retrieve Cloth Text/Trade Cloth List Price
			= 2 to retrieve Paper Text/Trade Paper List Price
*/	 

RETURNS FLOAT
AS
BEGIN
  
DECLARE @f_versionprice	FLOAT


IF  @i_versiontype = 1 	
	BEGIN
		SELECT	@f_versionprice = ep.listprice
		FROM	estplspecs ep 
			RIGHT OUTER JOIN estspecs es ON ep.estkey = es.estkey 
				AND ep.versionkey = es.versionkey 
			LEFT OUTER JOIN estversion e ON es.estkey = e.estkey 
				AND es.versionkey = e.versionkey 
			FULL OUTER JOIN estbook eb ON es.estkey = eb.estkey
		WHERE	@i_estkey = e.estkey
				AND (e.versiontypecode = 1) 
				AND (es.mediatypecode = 2) 
				AND (es.mediatypesubcode IN (6, 26))
	END  

IF  @i_versiontype = 2 	
	BEGIN
		SELECT	@f_versionprice = ep.listprice
		FROM	estplspecs ep 
			RIGHT OUTER JOIN estspecs es ON ep.estkey = es.estkey 
				AND ep.versionkey = es.versionkey 
			LEFT OUTER JOIN estversion e ON es.estkey = e.estkey 
				AND es.versionkey = e.versionkey 
			FULL OUTER JOIN estbook eb ON es.estkey = eb.estkey
		WHERE	@i_estkey = e.estkey
				AND (e.versiontypecode = 1) 
				AND (es.mediatypecode = 2) 
				AND (es.mediatypesubcode IN (20,27))

  	END

RETURN @f_versionprice

END















GO
SET QUOTED_IDENTIFIER OFF 
GO
SET ANSI_NULLS ON 
GO

GRANT  REFERENCES ,  EXECUTE  ON [dbo].[reports_get_EstVersionListPrice]  TO [public]
GO

SET QUOTED_IDENTIFIER ON 
GO
SET ANSI_NULLS ON 
GO


CREATE FUNCTION reports_get_EstVersionQty(
	@i_estkey INT,
	@i_versiontype INT
) 

/* PARAMETERS
	@i_estkey is from estbook or estversion
	@i_versiontype 	= 1 to retrieve Cloth Text/Trade Cloth Quantity
			= 2 to retrieve Paper Text/Trade Paper Quantity
*/	 

RETURNS INT
AS
BEGIN
  
DECLARE @i_versionqty	INT


IF  @i_versiontype = 1 	
	BEGIN
		SELECT	@i_versionqty = e.finishedgoodqty
		FROM	estversion e 
				RIGHT OUTER JOIN estspecs es ON e.estkey = es.estkey AND e.versionkey = es.versionkey 
				LEFT OUTER JOIN estbook eb ON es.estkey = eb.estkey
		WHERE     @i_estkey = e.estkey
				AND (eb.estimatetypecode = 1) 
				AND (e.versiontypecode = 1) 
				AND (es.mediatypecode = 2) 
				AND (es.mediatypesubcode IN (6, 26))
	END  

IF  @i_versiontype = 2 	
	BEGIN
		SELECT	@i_versionqty = e.finishedgoodqty
		FROM	estversion e 
				RIGHT OUTER JOIN estspecs es ON e.estkey = es.estkey AND e.versionkey = es.versionkey 
				LEFT OUTER JOIN estbook eb ON es.estkey = eb.estkey
		WHERE     @i_estkey = e.estkey
				AND (eb.estimatetypecode = 1) 
				AND (e.versiontypecode = 1) 
				AND (es.mediatypecode = 2) 
				AND (es.mediatypesubcode IN (20, 27))
  	END

RETURN @i_versionqty

END


















GO
SET QUOTED_IDENTIFIER OFF 
GO
SET ANSI_NULLS ON 
GO

GRANT  REFERENCES ,  EXECUTE  ON [dbo].[reports_get_EstVersionQty]  TO [public]
GO

SET QUOTED_IDENTIFIER ON 
GO
SET ANSI_NULLS ON 
GO

CREATE FUNCTION reports_get_EstVersionRoyalty(
	@i_estkey INT,
	@i_versiontype INT,
	@i_versionkey INT
) 

/* PARAMETERS
	@i_estkey is from estbook or estversion
	@i_versiontype 	= 0 to pass versionkey and get either edition royalty - used for Single Edition P&Ls
			= 1 to retrieve Cloth Text/Trade Cloth List Price - - used for Dual Edition P&Ls
			= 2 to retrieve Paper Text/Trade Paper List Price- - used for Dual Edition P&Ls
	@i_versionkey is the versionkey from estversion or estpecs.  You can pass a NULL Value if you are doing a Dual Edition P&L
*/	 

RETURNS FLOAT
AS
BEGIN
  
DECLARE @f_versionroyalty	FLOAT

IF  @i_versiontype = 0 	
	BEGIN
		SELECT	@f_versionroyalty = ep.totalroyalty
		FROM	estplspecs ep 
			RIGHT OUTER JOIN estspecs es ON ep.estkey = es.estkey 
				AND ep.versionkey = es.versionkey 
			LEFT OUTER JOIN estversion e ON es.estkey = e.estkey 
				AND es.versionkey = e.versionkey 
			FULL OUTER JOIN estbook eb ON es.estkey = eb.estkey
		WHERE	@i_estkey = e.estkey
				AND @i_versionkey = e.versionkey
				AND (e.versiontypecode is NULL) 
				
	END  



IF  @i_versiontype = 1 	
	BEGIN
		SELECT	@f_versionroyalty = ep.totalroyalty
		FROM	estplspecs ep 
			RIGHT OUTER JOIN estspecs es ON ep.estkey = es.estkey 
				AND ep.versionkey = es.versionkey 
			LEFT OUTER JOIN estversion e ON es.estkey = e.estkey 
				AND es.versionkey = e.versionkey 
			FULL OUTER JOIN estbook eb ON es.estkey = eb.estkey
		WHERE	@i_estkey = e.estkey
				AND (e.versiontypecode = 1) 
				AND (es.mediatypecode = 2) 
				AND (es.mediatypesubcode IN (6, 26))
	END  

IF  @i_versiontype = 2 	
	BEGIN
		SELECT	@f_versionroyalty = ep.totalroyalty
		FROM	estplspecs ep 
			RIGHT OUTER JOIN estspecs es ON ep.estkey = es.estkey 
				AND ep.versionkey = es.versionkey 
			LEFT OUTER JOIN estversion e ON es.estkey = e.estkey 
				AND es.versionkey = e.versionkey 
			FULL OUTER JOIN estbook eb ON es.estkey = eb.estkey
		WHERE	@i_estkey = e.estkey
				AND (e.versiontypecode = 1) 
				AND (es.mediatypecode = 2) 
				AND (es.mediatypesubcode IN (20,27))

  	END

RETURN @f_versionroyalty

END


















GO
SET QUOTED_IDENTIFIER OFF 
GO
SET ANSI_NULLS ON 
GO

GRANT  REFERENCES ,  EXECUTE  ON [dbo].[reports_get_EstVersionRoyalty]  TO [public]
GO

SET QUOTED_IDENTIFIER ON 
GO
SET ANSI_NULLS ON 
GO

CREATE FUNCTION ump_reports_get_CompCopies(
	@i_estkey INT,
	@i_versiontype INT,
	@i_versionkey INT
	) 

RETURNS INT
AS
BEGIN
  
	DECLARE @i_compcopies	INT


IF @i_versiontype = 0
	BEGIN
		SELECT     @i_compcopies = em.quantity
		FROM       estmiscspecs em 
				LEFT OUTER JOIN estspecs es ON em.estkey = es.estkey 
					AND em.versionkey = es.versionkey
		WHERE       @i_estkey = em.estkey 
				AND @i_versionkey = em.versionkey
				AND em.compkey = 2 
				AND (em.tableid = 10) AND (em.datacode = 3) 
				AND (em.misctypetableid = 51)

	END


IF @i_versiontype = 1
	BEGIN
		SELECT     @i_compcopies = em.quantity
		FROM       estmiscspecs em 
				LEFT OUTER JOIN estspecs es ON em.estkey = es.estkey 
					AND em.versionkey = es.versionkey
		WHERE     @i_estkey = em.estkey
				AND em.compkey = 2 
				AND (es.mediatypecode = 2) 
				AND (es.mediatypesubcode IN (6, 26)) 
				AND (em.tableid = 10) AND (em.datacode = 3) 
				AND (em.misctypetableid = 51)

	END

IF @i_versiontype = 2
	BEGIN
		SELECT      @i_compcopies = em.quantity
		FROM       estmiscspecs em 
				LEFT OUTER JOIN estspecs es ON em.estkey = es.estkey 
					AND em.versionkey = es.versionkey
		WHERE      @i_estkey = em.estkey
				AND em.compkey = 2
				AND (es.mediatypecode = 2) 
				AND (es.mediatypesubcode IN (20,27)) 
				AND (em.tableid = 12) AND (em.datacode = 2) 
				AND (em.misctypetableid = 51)

	END

RETURN @i_compcopies

END




GO
SET QUOTED_IDENTIFIER OFF 
GO
SET ANSI_NULLS ON 
GO

GRANT  REFERENCES ,  EXECUTE  ON [dbo].[ump_reports_get_CompCopies]  TO [public]
GO

