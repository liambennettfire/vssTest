if exists (select * from dbo.sysobjects where id = object_id(N'[dbo].get_countries_from_territory') and xtype in (N'FN', N'IF', N'TF'))
drop function [dbo].get_countries_from_territory
GO


CREATE FUNCTION dbo.get_countries_from_territory (@i_currentterritorycode INT ,
 @i_singlecountrycode INT,
 @i_singlecountrygroup INT,
 @i_exclusivecode INT)

RETURNS @countriestable TABLE(
    countrycode INT,
    forsaleind  INT,
    exclusivity INT,
    datadesc		VARCHAR(40)
	)
AS
BEGIN

DECLARE
  @v_count	INT,
  @v_code   INT,
  @v_forsaleind INT,
  @v_contractexclusiveind INT,
  @v_currentexclusiveind  INT,
  @v_datadesc	VARCHAR(40)


  

   IF COALESCE(@i_currentterritorycode,0) = 0 BEGIN
    return
   END

   IF COALESCE(@i_exclusivecode,0) = 0 BEGIN
    return
   END

   IF (@i_exclusivecode > 2) BEGIN
    return
   END
   
   IF @i_currentterritorycode = 1 BEGIN ----World
      IF @i_exclusivecode = 1 BEGIN    --Exclusive
				INSERT INTO @countriestable
        SELECT gentables.datacode,1,1,gentables.datadesc
          FROM gentables
         WHERE gentables.tableid = 114
           AND (gentables.deletestatus = 'N' OR gentables.deletestatus = 'n')
         ORDER BY datadesc ASC
             

      END
      ELSE IF @i_exclusivecode = 2 BEGIN    --Not Exclusive
				INSERT INTO @countriestable
        SELECT gentables.datacode,1,0,gentables.datadesc
          FROM gentables
         WHERE gentables.tableid = 114
           AND (gentables.deletestatus = 'N' OR gentables.deletestatus = 'n')
         ORDER BY datadesc ASC
             
      END
   END

   IF @i_currentterritorycode = 2 BEGIN ----Single Country
      IF @i_exclusivecode = 1 BEGIN    --Exclusive
				INSERT INTO @countriestable
        SELECT gentables.datacode,1,1,gentables.datadesc
          FROM gentables
         WHERE gentables.tableid = 114
           AND (gentables.deletestatus = 'N' OR gentables.deletestatus = 'n')
           AND gentables.datacode = @i_singlecountrycode
         UNION 
        SELECT gentables.datacode,0,NULL,gentables.datadesc
          FROM gentables
         WHERE gentables.tableid = 114
           AND (gentables.deletestatus = 'N' OR gentables.deletestatus = 'n')
           AND gentables.datacode <> @i_singlecountrycode
         ORDER BY datadesc ASC

      END
      ELSE IF @i_exclusivecode = 2 BEGIN    --Not Exclusive
				INSERT INTO @countriestable
        SELECT gentables.datacode,1,0,gentables.datadesc
          FROM gentables
         WHERE gentables.tableid = 114
           AND (gentables.deletestatus = 'N' OR gentables.deletestatus = 'n')
           AND gentables.datacode = @i_singlecountrycode
         UNION 
        SELECT gentables.datacode,0,NULL,gentables.datadesc
          FROM gentables
         WHERE gentables.tableid = 114
           AND (gentables.deletestatus = 'N' OR gentables.deletestatus = 'n')
           AND gentables.datacode <> @i_singlecountrycode
         ORDER BY datadesc ASC
      END
   END

   IF @i_currentterritorycode = 4 BEGIN ----Single Country Group
      IF @i_exclusivecode = 1 BEGIN    --Exclusive
				INSERT INTO @countriestable
        SELECT r.code2,1,1,g.datadesc
          FROM gentablesrelationshipdetail r, gentables g
         WHERE r.gentablesrelationshipkey = 23
           AND r.code1 = @i_singlecountrygroup
           AND g.tableid = 114
           AND g.datacode = r.code2
         UNION 
        SELECT datacode,0,NULL,gentables.datadesc
          FROM gentables
         WHERE gentables.tableid = 114
           AND (gentables.deletestatus = 'N' OR gentables.deletestatus = 'n')
           AND datacode NOT IN (SELECT code2
                FROM gentablesrelationshipdetail
               WHERE gentablesrelationshipkey = 23
                 AND code1 = @i_singlecountrygroup)
         ORDER BY datadesc ASC

      END
      ELSE IF @i_exclusivecode = 2 BEGIN    --Not Exclusive
				INSERT INTO @countriestable
        SELECT r.code2,1,0,g.datadesc
          FROM gentablesrelationshipdetail r, gentables g
         WHERE r.gentablesrelationshipkey = 23
           AND r.code1 = @i_singlecountrygroup
           AND g.tableid = 114
           AND g.datacode = r.code2
         UNION 
        SELECT datacode,0,NULL,gentables.datadesc
          FROM gentables
         WHERE gentables.tableid = 114
           AND (gentables.deletestatus = 'N' OR gentables.deletestatus = 'n')
           AND datacode NOT IN (SELECT code2
                FROM gentablesrelationshipdetail
               WHERE gentablesrelationshipkey = 23
                 AND code1 = @i_singlecountrygroup)
         ORDER BY datadesc ASC
      END
   END

   IF @i_currentterritorycode = 5  BEGIN ----World Excluding Single Country
      IF @i_exclusivecode = 1 BEGIN    --Exclusive
				INSERT INTO @countriestable
        SELECT gentables.datacode,0,NULL,gentables.datadesc
          FROM gentables
         WHERE gentables.tableid = 114
           AND (gentables.deletestatus = 'N' OR gentables.deletestatus = 'n')
           AND gentables.datacode = @i_singlecountrycode
         UNION 
        SELECT gentables.datacode,1,1,gentables.datadesc
          FROM gentables
         WHERE gentables.tableid = 114
           AND (gentables.deletestatus = 'N' OR gentables.deletestatus = 'n')
           AND gentables.datacode <> @i_singlecountrycode
         ORDER BY datadesc ASC

      END
      ELSE IF @i_exclusivecode = 2 BEGIN    --Not Exclusive
				INSERT INTO @countriestable
        SELECT gentables.datacode,0,NULL,gentables.datadesc
          FROM gentables
         WHERE gentables.tableid = 114
           AND (gentables.deletestatus = 'N' OR gentables.deletestatus = 'n')
           AND gentables.datacode = @i_singlecountrycode
         UNION 
        SELECT gentables.datacode,1,0,gentables.datadesc
          FROM gentables
         WHERE gentables.tableid = 114
           AND (gentables.deletestatus = 'N' OR gentables.deletestatus = 'n')
           AND gentables.datacode <> @i_singlecountrycode
         ORDER BY datadesc ASC
      END
   END

   IF @i_currentterritorycode = 6 BEGIN ----World Excluding Single Country Group
      IF @i_exclusivecode = 1 BEGIN    --Exclusive
				INSERT INTO @countriestable
        SELECT r.code2,0,NULL,g.datadesc
          FROM gentablesrelationshipdetail r, gentables g
         WHERE r.gentablesrelationshipkey = 23
           AND r.code1 = @i_singlecountrygroup
           AND g.tableid = 114
           AND g.datacode = r.code2
         UNION 
        SELECT datacode,1,1,gentables.datadesc
          FROM gentables
         WHERE gentables.tableid = 114
           AND (gentables.deletestatus = 'N' OR gentables.deletestatus = 'n')
           AND datacode NOT IN (SELECT code2
                FROM gentablesrelationshipdetail
               WHERE gentablesrelationshipkey = 23
                 AND code1 = @i_singlecountrygroup)
         ORDER BY datadesc ASC

      END
      ELSE IF @i_exclusivecode = 2 BEGIN    --Not Exclusive
				INSERT INTO @countriestable
        SELECT r.code2,0,NULL,g.datadesc
          FROM gentablesrelationshipdetail r, gentables g
         WHERE r.gentablesrelationshipkey = 23
           AND r.code1 = @i_singlecountrygroup
           AND g.tableid = 114
           AND g.datacode = r.code2
         UNION 
        SELECT datacode,1,0,gentables.datadesc
          FROM gentables
         WHERE gentables.tableid = 114
           AND (gentables.deletestatus = 'N' OR gentables.deletestatus = 'n')
           AND datacode NOT IN (SELECT code2
                FROM gentablesrelationshipdetail
               WHERE gentablesrelationshipkey = 23
                 AND code1 = @i_singlecountrygroup)
         ORDER BY datadesc ASC
      END
   END

	 RETURN
END