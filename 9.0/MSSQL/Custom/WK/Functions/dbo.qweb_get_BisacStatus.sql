IF EXISTS (SELECT *
             FROM dbo.sysobjects
             WHERE id = object_id(N'dbo.[qweb_get_BisacStatus]')
               AND OBJECTPROPERTY(id, N'IsScalarFunction') = 1)
  DROP FUNCTION dbo.[qweb_get_BisacStatus]
GO
CREATE FUNCTION [dbo].[qweb_get_BisacStatus]
(
  @i_bookkey INT,
  @v_column VARCHAR(1)
  )

RETURNS VARCHAR(255)

/*	The purpose of the qweb_get_BisacStatus function is to return a specific description column from gentables for a BisacStatus

	Parameter Options
		D = Data Description
		E = External code
		S = Short Description
		B = BISAC Data Code
		T = Eloquence Field Tag
		1 = Alternative Description 1
		2 = Alternative Deccription 2
		G = Returns gentable DataCode for dropdown filling sake
*/

AS

  BEGIN

    DECLARE @RETURN VARCHAR(255)
    DECLARE @v_desc VARCHAR(255)
    DECLARE @i_BisacStatusCode INT

    SELECT @i_BisacStatusCode = bisacstatuscode
      FROM bookdetail
      WHERE bookkey = @i_bookkey


    IF @v_column = 'D'
      BEGIN
        SELECT @v_desc = LTRIM(RTRIM(datadesc))
          FROM gentables
          WHERE tableid = 314
            AND datacode = @i_BisacStatusCode
      END

    ELSE
    IF @v_column = 'E'
      BEGIN
        SELECT @v_desc = LTRIM(RTRIM(externalcode))
          FROM gentables
          WHERE tableid = 314
            AND datacode = @i_BisacStatusCode
      END

    ELSE
    IF @v_column = 'S'
      BEGIN
        SELECT @v_desc = LTRIM(RTRIM(datadescshort))
          FROM gentables
          WHERE tableid = 314
            AND datacode = @i_BisacStatusCode

      END

    ELSE
    IF @v_column = 'B'
      BEGIN
        SELECT @v_desc = LTRIM(RTRIM(bisacdatacode))
          FROM gentables
          WHERE tableid = 314
            AND datacode = @i_BisacStatusCode
      END

    ELSE
    IF @v_column = '1'
      BEGIN
        SELECT @v_desc = LTRIM(RTRIM(alternatedesc1))
          FROM gentables
          WHERE tableid = 314
            AND datacode = @i_BisacStatusCode
      END

    ELSE
    IF @v_column = '2'
      BEGIN
        SELECT @v_desc = LTRIM(RTRIM(datadesc))
          FROM gentables
          WHERE tableid = 314
            AND datacode = @i_BisacStatusCode
      END

    ELSE
    IF @v_column = 'G'
      BEGIN
        SELECT @v_desc = @i_BisacStatusCode
      END


    IF LEN(@v_desc) > 0
      BEGIN
        SELECT @RETURN = @v_desc
      END
    ELSE
      BEGIN
        SELECT @RETURN = ''
      END


    RETURN @RETURN


  END