SET QUOTED_IDENTIFIER OFF 
GO
SET ANSI_NULLS ON 
GO

if exists (select * from dbo.sysobjects where id = object_id(N'[dbo].[printing_best_season_view]') and OBJECTPROPERTY(id, N'IsView') = 1)
drop view [dbo].[printing_best_season_view]
GO


/*******************************************************************************/
/* SIR 1122 KB Added printingkey as a column on the view as well as selecting best seasonkey */
/* IF view already exists for some reason then would have to add following statement                 */
/* DROP VIEW printing_best_season_view                                                                                     */
/* because there is no CREATE OR REPLACE VIEW statement as in Oracle                              */
/* RUN ON GENMSDEV                                                                                                                  */
/*******************************************************************************/

CREATE VIEW printing_best_season_view (bookkey, printingkey,lastuserid, lastmaintdate, seasonkey)
   AS 
SELECT	
	bookkey,
	printingkey,
	lastuserid,
	lastmaintdate,
	seasonkey = 
		CASE 
			WHEN (seasonkey IS NOT NULL AND  seasonkey > 0)
				 THEN seasonkey
			WHEN ((seasonkey IS NULL OR seasonkey = 0) AND (estseasonkey IS NOT NULL AND estseasonkey > 0))
				 THEN  estseasonkey
		 END
	FROM printing
	

GO
SET QUOTED_IDENTIFIER OFF 
GO
SET ANSI_NULLS ON 
GO

GRANT  SELECT  ON [dbo].[printing_best_season_view]  TO [public]
GO

