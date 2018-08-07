/**********************************************/
/*                                            */
/*  Rod Hamann                                */
/*  04-27-2004                                */
/*  PSS SIR 3048                              */
/*  Tested on GENMSDEV                        */
/*                                            */
/*                MSSQL Version               */
/*                                            */
/*  This is the stored procedure that will    */
/*  warehouse the book miscellaneous items    */
/*  for a given bookkey.                      */
/*                           		      */
/**********************************************/
 
/* 6-15-04 AA crm 01430 increase columns to 40 and CRM 01434 add calculated fields*/
/* 7-7-04 KB CRM 01369 add functionality for bookmisc gentable entries  */
/*11-11-04 update bookmisc table calculated fields also*/
/* 2-11-05 CRM 2421 AA - move calculated field from qsilargeobjects to  bookmisccalc.calcsql*/
/* 2-16-05 CRM 2478 AA - add yesnoboxes*/

if exists (select * from dbo.sysobjects where id = Object_id('dbo.datawarehouse_bookmisc') and (type = 'P' or type = 'RF'))
begin
 drop proc dbo.datawarehouse_bookmisc
end
GO

CREATE PROC dbo.datawarehouse_bookmisc
   @ware_bookkey INT, @ware_userid VARCHAR(30), @ware_date DATETIME

AS
   DECLARE @ware_number   INT
   DECLARE @ware_float    FLOAT
   DECLARE @ware_text     VARCHAR(255)
   DECLARE @ware_misckey  INT
   DECLARE @ware_misctype INT
   DECLARE @ware_linenum  INT
   DECLARE @ware_orgentrykey   INT
   DECLARE @ware_qsibody   varchar(4000) 
   DECLARE @i_count	  INT
   DECLARE @v_count	  INT
   DECLARE @c_sql 	NVARCHAR(4000)
   DECLARE @i_orglevel	INT
   DECLARE @i_orgentrykey INT
   DECLARE @userkey INT
  
	  
BEGIN

SELECT @v_count = count(*)
  FROM bookmisc
 WHERE bookkey = @ware_bookkey

IF @v_count = 0 
  RETURN 

DECLARE warehousebookmisc CURSOR FOR
      SELECT misckey, columntype, linenumber
      FROM whcbookmisc
	  FOR READ ONLY

DELETE FROM whbookmisc
WHERE bookkey = @ware_bookkey

INSERT INTO whbookmisc (bookkey, lastuserid, lastmaintdate)
VALUES (@ware_bookkey, @ware_userid, @ware_date)


OPEN warehousebookmisc 

FETCH NEXT FROM warehousebookmisc 
INTO @ware_misckey, @ware_misctype, @ware_linenum

WHILE (@@FETCH_STATUS <> - 1)
BEGIN
  IF @ware_misctype = 1  -- Number
  BEGIN

    SET @ware_number = NULL

    SELECT @ware_number = longvalue
    FROM bookmisc
    WHERE bookkey = @ware_bookkey AND misckey = @ware_misckey

    IF @ware_linenum = 1 
      UPDATE whbookmisc SET bookmisclong1 = @ware_number WHERE bookkey = @ware_bookkey
    ELSE IF @ware_linenum = 2 
      UPDATE whbookmisc SET bookmisclong2 = @ware_number WHERE bookkey = @ware_bookkey
    ELSE IF @ware_linenum = 3 
      UPDATE whbookmisc SET bookmisclong3 = @ware_number WHERE bookkey = @ware_bookkey
    ELSE IF @ware_linenum = 4 
      UPDATE whbookmisc SET bookmisclong4 = @ware_number WHERE bookkey = @ware_bookkey
    ELSE IF @ware_linenum = 5 
      UPDATE whbookmisc SET bookmisclong5 = @ware_number WHERE bookkey = @ware_bookkey
    ELSE IF @ware_linenum = 6 
      UPDATE whbookmisc SET bookmisclong6 = @ware_number WHERE bookkey = @ware_bookkey
    ELSE IF @ware_linenum = 7 
      UPDATE whbookmisc SET bookmisclong7 = @ware_number WHERE bookkey = @ware_bookkey
    ELSE IF @ware_linenum = 8 
      UPDATE whbookmisc SET bookmisclong8 = @ware_number WHERE bookkey = @ware_bookkey
    ELSE IF @ware_linenum = 9 
      UPDATE whbookmisc SET bookmisclong9 = @ware_number WHERE bookkey = @ware_bookkey
    ELSE IF @ware_linenum = 10 
      UPDATE whbookmisc SET bookmisclong10 = @ware_number WHERE bookkey = @ware_bookkey
    ELSE IF @ware_linenum = 11 
      UPDATE whbookmisc SET bookmisclong11 = @ware_number WHERE bookkey = @ware_bookkey
    ELSE IF @ware_linenum = 12 
      UPDATE whbookmisc SET bookmisclong12 = @ware_number WHERE bookkey = @ware_bookkey
    ELSE IF @ware_linenum = 13 
      UPDATE whbookmisc SET bookmisclong13 = @ware_number WHERE bookkey = @ware_bookkey
    ELSE IF @ware_linenum = 14 
      UPDATE whbookmisc SET bookmisclong14 = @ware_number WHERE bookkey = @ware_bookkey
    ELSE IF @ware_linenum = 15 
      UPDATE whbookmisc SET bookmisclong15 = @ware_number WHERE bookkey = @ware_bookkey
    ELSE IF @ware_linenum = 16 
      UPDATE whbookmisc SET bookmisclong16 = @ware_number WHERE bookkey = @ware_bookkey
    ELSE IF @ware_linenum = 17 
      UPDATE whbookmisc SET bookmisclong17 = @ware_number WHERE bookkey = @ware_bookkey
    ELSE IF @ware_linenum = 18 
      UPDATE whbookmisc SET bookmisclong18 = @ware_number WHERE bookkey = @ware_bookkey
    ELSE IF @ware_linenum = 19 
      UPDATE whbookmisc SET bookmisclong19 = @ware_number WHERE bookkey = @ware_bookkey
    ELSE IF @ware_linenum = 20 
      UPDATE whbookmisc SET bookmisclong20 = @ware_number WHERE bookkey = @ware_bookkey
    ELSE IF @ware_linenum = 21 
      UPDATE whbookmisc SET bookmisclong21 = @ware_number WHERE bookkey = @ware_bookkey
    ELSE IF @ware_linenum = 22 
      UPDATE whbookmisc SET bookmisclong22 = @ware_number WHERE bookkey = @ware_bookkey
    ELSE IF @ware_linenum = 23 
      UPDATE whbookmisc SET bookmisclong23 = @ware_number WHERE bookkey = @ware_bookkey
    ELSE IF @ware_linenum = 24 
      UPDATE whbookmisc SET bookmisclong24 = @ware_number WHERE bookkey = @ware_bookkey
    ELSE IF @ware_linenum = 25 
      UPDATE whbookmisc SET bookmisclong25 = @ware_number WHERE bookkey = @ware_bookkey
    ELSE IF @ware_linenum = 26 
      UPDATE whbookmisc SET bookmisclong26 = @ware_number WHERE bookkey = @ware_bookkey
    ELSE IF @ware_linenum = 27 
      UPDATE whbookmisc SET bookmisclong27 = @ware_number WHERE bookkey = @ware_bookkey
    ELSE IF @ware_linenum = 28 
      UPDATE whbookmisc SET bookmisclong28 = @ware_number WHERE bookkey = @ware_bookkey
    ELSE IF @ware_linenum = 29 
      UPDATE whbookmisc SET bookmisclong9 = @ware_number WHERE bookkey = @ware_bookkey
    ELSE IF @ware_linenum = 30 
      UPDATE whbookmisc SET bookmisclong30 = @ware_number WHERE bookkey = @ware_bookkey
    ELSE IF @ware_linenum = 31 
      UPDATE whbookmisc SET bookmisclong31 = @ware_number WHERE bookkey = @ware_bookkey
    ELSE IF @ware_linenum = 32 
      UPDATE whbookmisc SET bookmisclong32 = @ware_number WHERE bookkey = @ware_bookkey
    ELSE IF @ware_linenum = 33 
      UPDATE whbookmisc SET bookmisclong33 = @ware_number WHERE bookkey = @ware_bookkey
    ELSE IF @ware_linenum = 34 
      UPDATE whbookmisc SET bookmisclong34 = @ware_number WHERE bookkey = @ware_bookkey
    ELSE IF @ware_linenum = 35 
      UPDATE whbookmisc SET bookmisclong35 = @ware_number WHERE bookkey = @ware_bookkey
    ELSE IF @ware_linenum = 36 
      UPDATE whbookmisc SET bookmisclong36 = @ware_number WHERE bookkey = @ware_bookkey
    ELSE IF @ware_linenum = 37 
      UPDATE whbookmisc SET bookmisclong37 = @ware_number WHERE bookkey = @ware_bookkey
    ELSE IF @ware_linenum = 38 
      UPDATE whbookmisc SET bookmisclong38 = @ware_number WHERE bookkey = @ware_bookkey
    ELSE IF @ware_linenum = 39 
      UPDATE whbookmisc SET bookmisclong39 = @ware_number WHERE bookkey = @ware_bookkey
    ELSE IF @ware_linenum = 40 
      UPDATE whbookmisc SET bookmisclong40 = @ware_number WHERE bookkey = @ware_bookkey
  END --IF @ware_misctype = 1 (Number)


  ELSE IF @ware_misctype = 2  -- Float
  BEGIN

    SET @ware_float = NULL

    SELECT @ware_float = floatvalue
    FROM bookmisc
    WHERE bookkey = @ware_bookkey AND misckey = @ware_misckey

    IF @ware_linenum = 1 
      UPDATE whbookmisc SET bookmiscfloat1 = @ware_float WHERE bookkey = @ware_bookkey
    ELSE IF @ware_linenum = 2 
      UPDATE whbookmisc SET bookmiscfloat2 = @ware_float WHERE bookkey = @ware_bookkey
    ELSE IF @ware_linenum = 3 
      UPDATE whbookmisc SET bookmiscfloat3 = @ware_float WHERE bookkey = @ware_bookkey
    ELSE IF @ware_linenum = 4 
      UPDATE whbookmisc SET bookmiscfloat4 = @ware_float WHERE bookkey = @ware_bookkey
    ELSE IF @ware_linenum = 5 
      UPDATE whbookmisc SET bookmiscfloat5 = @ware_float WHERE bookkey = @ware_bookkey
    ELSE IF @ware_linenum = 6 
      UPDATE whbookmisc SET bookmiscfloat6 = @ware_float WHERE bookkey = @ware_bookkey
    ELSE IF @ware_linenum = 7 
      UPDATE whbookmisc SET bookmiscfloat7 = @ware_float WHERE bookkey = @ware_bookkey
    ELSE IF @ware_linenum = 8 
      UPDATE whbookmisc SET bookmiscfloat8 = @ware_float WHERE bookkey = @ware_bookkey
    ELSE IF @ware_linenum = 9 
      UPDATE whbookmisc SET bookmiscfloat9 = @ware_float WHERE bookkey = @ware_bookkey
    ELSE IF @ware_linenum = 10 
      UPDATE whbookmisc SET bookmiscfloat10 = @ware_float WHERE bookkey = @ware_bookkey
    ELSE IF @ware_linenum = 11 
      UPDATE whbookmisc SET bookmiscfloat11 = @ware_float WHERE bookkey = @ware_bookkey
    ELSE IF @ware_linenum = 12 
      UPDATE whbookmisc SET bookmiscfloat12 = @ware_float WHERE bookkey = @ware_bookkey
    ELSE IF @ware_linenum = 13 
      UPDATE whbookmisc SET bookmiscfloat13 = @ware_float WHERE bookkey = @ware_bookkey
    ELSE IF @ware_linenum = 14 
      UPDATE whbookmisc SET bookmiscfloat14 = @ware_float WHERE bookkey = @ware_bookkey
    ELSE IF @ware_linenum = 15 
      UPDATE whbookmisc SET bookmiscfloat15 = @ware_float WHERE bookkey = @ware_bookkey
    ELSE IF @ware_linenum = 16 
      UPDATE whbookmisc SET bookmiscfloat16 = @ware_float WHERE bookkey = @ware_bookkey
    ELSE IF @ware_linenum = 17 
      UPDATE whbookmisc SET bookmiscfloat17 = @ware_float WHERE bookkey = @ware_bookkey
    ELSE IF @ware_linenum = 18 
      UPDATE whbookmisc SET bookmiscfloat18 = @ware_float WHERE bookkey = @ware_bookkey
    ELSE IF @ware_linenum = 19 
      UPDATE whbookmisc SET bookmiscfloat19 = @ware_float WHERE bookkey = @ware_bookkey
    ELSE IF @ware_linenum = 20 
      UPDATE whbookmisc SET bookmiscfloat20 = @ware_float WHERE bookkey = @ware_bookkey
    ELSE IF  @ware_linenum = 21 
      UPDATE whbookmisc SET bookmiscfloat21 = @ware_float WHERE bookkey = @ware_bookkey
    ELSE IF @ware_linenum = 22 
      UPDATE whbookmisc SET bookmiscfloat22 = @ware_float WHERE bookkey = @ware_bookkey
    ELSE IF @ware_linenum = 23 
      UPDATE whbookmisc SET bookmiscfloat23 = @ware_float WHERE bookkey = @ware_bookkey
    ELSE IF @ware_linenum = 24 
      UPDATE whbookmisc SET bookmiscfloat24 = @ware_float WHERE bookkey = @ware_bookkey
    ELSE IF @ware_linenum = 25 
      UPDATE whbookmisc SET bookmiscfloat25 = @ware_float WHERE bookkey = @ware_bookkey
    ELSE IF @ware_linenum = 26 
      UPDATE whbookmisc SET bookmiscfloat26 = @ware_float WHERE bookkey = @ware_bookkey
    ELSE IF @ware_linenum = 27 
      UPDATE whbookmisc SET bookmiscfloat27 = @ware_float WHERE bookkey = @ware_bookkey
    ELSE IF @ware_linenum = 28 
      UPDATE whbookmisc SET bookmiscfloat28 = @ware_float WHERE bookkey = @ware_bookkey
    ELSE IF @ware_linenum = 29 
      UPDATE whbookmisc SET bookmiscfloat29 = @ware_float WHERE bookkey = @ware_bookkey
    ELSE IF @ware_linenum = 30 
      UPDATE whbookmisc SET bookmiscfloat30 = @ware_float WHERE bookkey = @ware_bookkey
    ELSE IF @ware_linenum = 31 
      UPDATE whbookmisc SET bookmiscfloat31 = @ware_float WHERE bookkey = @ware_bookkey
    ELSE IF @ware_linenum = 32 
      UPDATE whbookmisc SET bookmiscfloat32 = @ware_float WHERE bookkey = @ware_bookkey
    ELSE IF @ware_linenum = 33 
      UPDATE whbookmisc SET bookmiscfloat33 = @ware_float WHERE bookkey = @ware_bookkey
    ELSE IF @ware_linenum = 34 
      UPDATE whbookmisc SET bookmiscfloat34 = @ware_float WHERE bookkey = @ware_bookkey
    ELSE IF @ware_linenum = 35 
      UPDATE whbookmisc SET bookmiscfloat35 = @ware_float WHERE bookkey = @ware_bookkey
    ELSE IF @ware_linenum = 36 
      UPDATE whbookmisc SET bookmiscfloat36 = @ware_float WHERE bookkey = @ware_bookkey
    ELSE IF @ware_linenum = 37 
      UPDATE whbookmisc SET bookmiscfloat37 = @ware_float WHERE bookkey = @ware_bookkey
    ELSE IF @ware_linenum = 38 
      UPDATE whbookmisc SET bookmiscfloat38 = @ware_float WHERE bookkey = @ware_bookkey
    ELSE IF @ware_linenum = 39 
      UPDATE whbookmisc SET bookmiscfloat39 = @ware_float WHERE bookkey = @ware_bookkey
    ELSE IF @ware_linenum = 40 
      UPDATE whbookmisc SET bookmiscfloat40 = @ware_float WHERE bookkey = @ware_bookkey
  END --IF @ware_misctype = 2 (Float)

  ELSE IF @ware_misctype = 3  -- Text
  BEGIN

    SET @ware_text = NULL

    SELECT @ware_text = textvalue
    FROM bookmisc
    WHERE bookkey = @ware_bookkey AND misckey = @ware_misckey

    IF @ware_linenum = 1 
      UPDATE whbookmisc SET bookmisctext1 = @ware_text WHERE bookkey = @ware_bookkey
    ELSE IF @ware_linenum = 2 
      UPDATE whbookmisc SET bookmisctext2 = @ware_text WHERE bookkey = @ware_bookkey
    ELSE IF @ware_linenum = 3 
      UPDATE whbookmisc SET bookmisctext3 = @ware_text WHERE bookkey = @ware_bookkey
    ELSE IF @ware_linenum = 4 
      UPDATE whbookmisc SET bookmisctext4 = @ware_text WHERE bookkey = @ware_bookkey
    ELSE IF @ware_linenum = 5 
      UPDATE whbookmisc SET bookmisctext5 = @ware_text WHERE bookkey = @ware_bookkey
    ELSE IF @ware_linenum = 6 
      UPDATE whbookmisc SET bookmisctext6 = @ware_text WHERE bookkey = @ware_bookkey
    ELSE IF @ware_linenum = 7 
      UPDATE whbookmisc SET bookmisctext7 = @ware_text WHERE bookkey = @ware_bookkey
    ELSE IF @ware_linenum = 8 
      UPDATE whbookmisc SET bookmisctext8 = @ware_text WHERE bookkey = @ware_bookkey
    ELSE IF @ware_linenum = 9 
      UPDATE whbookmisc SET bookmisctext9 = @ware_text WHERE bookkey = @ware_bookkey
    ELSE IF @ware_linenum = 10 
      UPDATE whbookmisc SET bookmisctext10 = @ware_text WHERE bookkey = @ware_bookkey
    ELSE IF @ware_linenum = 11 
      UPDATE whbookmisc SET bookmisctext11 = @ware_text WHERE bookkey = @ware_bookkey
    ELSE IF @ware_linenum = 12 
      UPDATE whbookmisc SET bookmisctext12 = @ware_text WHERE bookkey = @ware_bookkey
    ELSE IF @ware_linenum = 13 
      UPDATE whbookmisc SET bookmisctext13 = @ware_text WHERE bookkey = @ware_bookkey
    ELSE IF @ware_linenum = 14 
      UPDATE whbookmisc SET bookmisctext14 = @ware_text WHERE bookkey = @ware_bookkey
    ELSE IF @ware_linenum = 15 
      UPDATE whbookmisc SET bookmisctext15 = @ware_text WHERE bookkey = @ware_bookkey
    ELSE IF @ware_linenum = 16 
      UPDATE whbookmisc SET bookmisctext16 = @ware_text WHERE bookkey = @ware_bookkey
    ELSE IF @ware_linenum = 17 
      UPDATE whbookmisc SET bookmisctext17 = @ware_text WHERE bookkey = @ware_bookkey
    ELSE IF @ware_linenum = 18 
      UPDATE whbookmisc SET bookmisctext18 = @ware_text WHERE bookkey = @ware_bookkey
    ELSE IF @ware_linenum = 19 
      UPDATE whbookmisc SET bookmisctext19 = @ware_text WHERE bookkey = @ware_bookkey
    ELSE IF @ware_linenum = 20 
      UPDATE whbookmisc SET bookmisctext20 = @ware_text WHERE bookkey = @ware_bookkey
    ELSE IF @ware_linenum = 21 
      UPDATE whbookmisc SET bookmisctext21 = @ware_text WHERE bookkey = @ware_bookkey
    ELSE IF @ware_linenum = 22 
      UPDATE whbookmisc SET bookmisctext22 = @ware_text WHERE bookkey = @ware_bookkey
    ELSE IF @ware_linenum = 23 
      UPDATE whbookmisc SET bookmisctext23 = @ware_text WHERE bookkey = @ware_bookkey
    ELSE IF @ware_linenum = 24 
      UPDATE whbookmisc SET bookmisctext24 = @ware_text WHERE bookkey = @ware_bookkey
    ELSE IF @ware_linenum = 25 
      UPDATE whbookmisc SET bookmisctext25 = @ware_text WHERE bookkey = @ware_bookkey
    ELSE IF @ware_linenum = 26 
      UPDATE whbookmisc SET bookmisctext26 = @ware_text WHERE bookkey = @ware_bookkey
    ELSE IF @ware_linenum = 27 
      UPDATE whbookmisc SET bookmisctext27 = @ware_text WHERE bookkey = @ware_bookkey
    ELSE IF @ware_linenum = 28 
      UPDATE whbookmisc SET bookmisctext28 = @ware_text WHERE bookkey = @ware_bookkey
    ELSE IF @ware_linenum = 29 
      UPDATE whbookmisc SET bookmisctext29 = @ware_text WHERE bookkey = @ware_bookkey
    ELSE IF @ware_linenum = 30 
      UPDATE whbookmisc SET bookmisctext30 = @ware_text WHERE bookkey = @ware_bookkey
    ELSE IF @ware_linenum = 31 
      UPDATE whbookmisc SET bookmisctext31 = @ware_text WHERE bookkey = @ware_bookkey
    ELSE IF @ware_linenum = 32 
      UPDATE whbookmisc SET bookmisctext32 = @ware_text WHERE bookkey = @ware_bookkey
    ELSE IF @ware_linenum = 33 
      UPDATE whbookmisc SET bookmisctext33 = @ware_text WHERE bookkey = @ware_bookkey
    ELSE IF @ware_linenum = 34 
      UPDATE whbookmisc SET bookmisctext34 = @ware_text WHERE bookkey = @ware_bookkey
    ELSE IF @ware_linenum = 35 
      UPDATE whbookmisc SET bookmisctext35 = @ware_text WHERE bookkey = @ware_bookkey
    ELSE IF @ware_linenum = 36 
      UPDATE whbookmisc SET bookmisctext36 = @ware_text WHERE bookkey = @ware_bookkey
    ELSE IF @ware_linenum = 37 
      UPDATE whbookmisc SET bookmisctext37 = @ware_text WHERE bookkey = @ware_bookkey
    ELSE IF @ware_linenum = 38 
      UPDATE whbookmisc SET bookmisctext38 = @ware_text WHERE bookkey = @ware_bookkey
    ELSE IF @ware_linenum = 39 
      UPDATE whbookmisc SET bookmisctext39 = @ware_text WHERE bookkey = @ware_bookkey
    ELSE IF @ware_linenum = 40 
      UPDATE whbookmisc SET bookmisctext40 = @ware_text WHERE bookkey = @ware_bookkey
  END
  
  ELSE IF @ware_misctype = 4  -- checkbox
  BEGIN

    SET @ware_number = NULL
    SET @ware_text = NULL

    SELECT @ware_number = longvalue
    FROM bookmisc
    WHERE bookkey = @ware_bookkey AND misckey = @ware_misckey

    if @ware_number = 1 
      select @ware_text = 'Yes'
    ELSE
      select @ware_text = 'No'

    IF @ware_linenum = 1 
      UPDATE whbookmisc SET bookmiscyesno1 = @ware_text WHERE bookkey = @ware_bookkey
    ELSE IF @ware_linenum = 2 
      UPDATE whbookmisc SET bookmiscyesno2 = @ware_text WHERE bookkey = @ware_bookkey
    ELSE IF @ware_linenum = 3 
      UPDATE whbookmisc SET bookmiscyesno3 = @ware_text WHERE bookkey = @ware_bookkey
    ELSE IF @ware_linenum = 4 
      UPDATE whbookmisc SET bookmiscyesno4 = @ware_text WHERE bookkey = @ware_bookkey
    ELSE IF @ware_linenum = 5 
      UPDATE whbookmisc SET bookmiscyesno5 = @ware_text WHERE bookkey = @ware_bookkey
    ELSE IF @ware_linenum = 6 
      UPDATE whbookmisc SET bookmiscyesno6 = @ware_text WHERE bookkey = @ware_bookkey
    ELSE IF @ware_linenum = 7 
      UPDATE whbookmisc SET bookmiscyesno7 = @ware_text WHERE bookkey = @ware_bookkey
    ELSE IF @ware_linenum = 8 
      UPDATE whbookmisc SET bookmiscyesno8 = @ware_text WHERE bookkey = @ware_bookkey
    ELSE IF @ware_linenum = 9 
      UPDATE whbookmisc SET bookmiscyesno9 = @ware_text WHERE bookkey = @ware_bookkey
    ELSE IF @ware_linenum = 10 
      UPDATE whbookmisc SET bookmiscyesno10 = @ware_text WHERE bookkey = @ware_bookkey
    ELSE IF @ware_linenum = 11 
      UPDATE whbookmisc SET bookmiscyesno11 = @ware_text WHERE bookkey = @ware_bookkey
    ELSE IF @ware_linenum = 12 
      UPDATE whbookmisc SET bookmiscyesno12 = @ware_text WHERE bookkey = @ware_bookkey
    ELSE IF @ware_linenum = 13 
      UPDATE whbookmisc SET bookmiscyesno13 = @ware_text WHERE bookkey = @ware_bookkey
    ELSE IF @ware_linenum = 14 
      UPDATE whbookmisc SET bookmiscyesno14 = @ware_text WHERE bookkey = @ware_bookkey
    ELSE IF @ware_linenum = 15 
      UPDATE whbookmisc SET bookmiscyesno15 = @ware_text WHERE bookkey = @ware_bookkey
    ELSE IF @ware_linenum = 16 
      UPDATE whbookmisc SET bookmiscyesno16 = @ware_text WHERE bookkey = @ware_bookkey
    ELSE IF @ware_linenum = 17 
      UPDATE whbookmisc SET bookmiscyesno17 = @ware_text WHERE bookkey = @ware_bookkey
    ELSE IF @ware_linenum = 18 
      UPDATE whbookmisc SET bookmiscyesno18 = @ware_text WHERE bookkey = @ware_bookkey
    ELSE IF @ware_linenum = 19 
      UPDATE whbookmisc SET bookmiscyesno19 = @ware_text WHERE bookkey = @ware_bookkey
    ELSE IF @ware_linenum = 20 
      UPDATE whbookmisc SET bookmiscyesno20 = @ware_text WHERE bookkey = @ware_bookkey
    ELSE IF @ware_linenum = 21 
      UPDATE whbookmisc SET bookmiscyesno21 = @ware_text WHERE bookkey = @ware_bookkey
    ELSE IF @ware_linenum = 22 
      UPDATE whbookmisc SET bookmiscyesno22 = @ware_text WHERE bookkey = @ware_bookkey
    ELSE IF @ware_linenum = 23 
      UPDATE whbookmisc SET bookmiscyesno23 = @ware_text WHERE bookkey = @ware_bookkey
    ELSE IF @ware_linenum = 24 
      UPDATE whbookmisc SET bookmiscyesno24 = @ware_text WHERE bookkey = @ware_bookkey
    ELSE IF @ware_linenum = 25 
      UPDATE whbookmisc SET bookmiscyesno25 = @ware_text WHERE bookkey = @ware_bookkey
    ELSE IF @ware_linenum = 26 
      UPDATE whbookmisc SET bookmiscyesno26 = @ware_text WHERE bookkey = @ware_bookkey
    ELSE IF @ware_linenum = 27 
      UPDATE whbookmisc SET bookmiscyesno27 = @ware_text WHERE bookkey = @ware_bookkey
    ELSE IF @ware_linenum = 28 
      UPDATE whbookmisc SET bookmiscyesno28 = @ware_text WHERE bookkey = @ware_bookkey
    ELSE IF @ware_linenum = 29 
      UPDATE whbookmisc SET bookmiscyesno29 = @ware_text WHERE bookkey = @ware_bookkey
    ELSE IF @ware_linenum = 30 
      UPDATE whbookmisc SET bookmiscyesno30 = @ware_text WHERE bookkey = @ware_bookkey
    ELSE IF @ware_linenum = 31 
      UPDATE whbookmisc SET bookmiscyesno31 = @ware_text WHERE bookkey = @ware_bookkey
    ELSE IF @ware_linenum = 32 
      UPDATE whbookmisc SET bookmiscyesno32 = @ware_text WHERE bookkey = @ware_bookkey
    ELSE IF @ware_linenum = 33 
      UPDATE whbookmisc SET bookmiscyesno33 = @ware_text WHERE bookkey = @ware_bookkey
    ELSE IF @ware_linenum = 34 
      UPDATE whbookmisc SET bookmiscyesno34 = @ware_text WHERE bookkey = @ware_bookkey
    ELSE IF @ware_linenum = 35 
      UPDATE whbookmisc SET bookmiscyesno35 = @ware_text WHERE bookkey = @ware_bookkey
    ELSE IF @ware_linenum = 36 
      UPDATE whbookmisc SET bookmiscyesno36 = @ware_text WHERE bookkey = @ware_bookkey
    ELSE IF @ware_linenum = 37 
      UPDATE whbookmisc SET bookmiscyesno37 = @ware_text WHERE bookkey = @ware_bookkey
    ELSE IF @ware_linenum = 38 
      UPDATE whbookmisc SET bookmiscyesno38 = @ware_text WHERE bookkey = @ware_bookkey
    ELSE IF @ware_linenum = 39 
      UPDATE whbookmisc SET bookmiscyesno39 = @ware_text WHERE bookkey = @ware_bookkey
    ELSE IF @ware_linenum = 40 
      UPDATE whbookmisc SET bookmiscyesno40 = @ware_text WHERE bookkey = @ware_bookkey
  END --IF @ware_misctype = 4 (Checkbox)
  
  ELSE IF @ware_misctype = 5  -- Gentables
  BEGIN

    SET @ware_number = NULL
    SET @ware_text = NULL

    SELECT @ware_number = longvalue
    FROM bookmisc
    WHERE bookkey = @ware_bookkey AND misckey = @ware_misckey

    SELECT @ware_text = datadesc
    FROM subgentables
    WHERE tableid = 525 AND
          datacode IN (SELECT datacode FROM bookmiscitems WHERE misckey = @ware_misckey) AND
          datasubcode = @ware_number

    IF @ware_linenum = 1 
      UPDATE whbookmisc SET bookmiscgentablecode1 = @ware_number,	bookmiscgentabletext1 = @ware_text 
      WHERE bookkey = @ware_bookkey
    ELSE IF @ware_linenum = 2 
      UPDATE whbookmisc SET bookmiscgentablecode2 = @ware_number,bookmiscgentabletext2 = @ware_text 
      WHERE bookkey = @ware_bookkey
    ELSE IF @ware_linenum = 3 
      UPDATE whbookmisc SET bookmiscgentablecode3 = @ware_number,bookmiscgentabletext3 = @ware_text 
      WHERE bookkey = @ware_bookkey
    ELSE IF @ware_linenum = 4 
      UPDATE whbookmisc SET bookmiscgentablecode4 = @ware_number,bookmiscgentabletext4 = @ware_text 
      WHERE bookkey = @ware_bookkey
    ELSE IF @ware_linenum = 5 
      UPDATE whbookmisc SET bookmiscgentablecode5 = @ware_number,bookmiscgentabletext5 = @ware_text 
      WHERE bookkey = @ware_bookkey
    ELSE IF @ware_linenum = 6 
      UPDATE whbookmisc SET bookmiscgentablecode6 = @ware_number,bookmiscgentabletext6 = @ware_text 
      WHERE bookkey = @ware_bookkey
    ELSE IF @ware_linenum = 7 
      UPDATE whbookmisc SET bookmiscgentablecode7 = @ware_number,bookmiscgentabletext7 = @ware_text 
      WHERE bookkey = @ware_bookkey
    ELSE IF @ware_linenum = 8 
      UPDATE whbookmisc SET bookmiscgentablecode8 = @ware_number,bookmiscgentabletext8 = @ware_text 
      WHERE bookkey = @ware_bookkey
    ELSE IF @ware_linenum = 9 
      UPDATE whbookmisc SET bookmiscgentablecode9 = @ware_number,bookmiscgentabletext9 = @ware_text 
      WHERE bookkey = @ware_bookkey
    ELSE IF @ware_linenum = 10 
      UPDATE whbookmisc SET bookmiscgentablecode10 = @ware_number,bookmiscgentabletext10 = @ware_text 
      WHERE bookkey = @ware_bookkey
    ELSE IF @ware_linenum = 11 
      UPDATE whbookmisc SET bookmiscgentablecode11 = @ware_number,bookmiscgentabletext11 = @ware_text 
      WHERE bookkey = @ware_bookkey
    ELSE IF @ware_linenum = 12 
      UPDATE whbookmisc SET bookmiscgentablecode12 = @ware_number,bookmiscgentabletext12 = @ware_text 
      WHERE bookkey = @ware_bookkey
    ELSE IF @ware_linenum = 13 
      UPDATE whbookmisc SET bookmiscgentablecode13 = @ware_number,bookmiscgentabletext13 = @ware_text 
      WHERE bookkey = @ware_bookkey
    ELSE IF @ware_linenum = 14 
      UPDATE whbookmisc SET bookmiscgentablecode14 = @ware_number,bookmiscgentabletext14 = @ware_text 
      WHERE bookkey = @ware_bookkey
    ELSE IF @ware_linenum = 15 
      UPDATE whbookmisc SET bookmiscgentablecode15 = @ware_number,bookmiscgentabletext15 = @ware_text 
      WHERE bookkey = @ware_bookkey
    ELSE IF @ware_linenum = 16 
      UPDATE whbookmisc SET bookmiscgentablecode16 = @ware_number,bookmiscgentabletext16 = @ware_text 
      WHERE bookkey = @ware_bookkey
    ELSE IF @ware_linenum = 17 
      UPDATE whbookmisc SET bookmiscgentablecode17 = @ware_number,bookmiscgentabletext17 = @ware_text 
      WHERE bookkey = @ware_bookkey
    ELSE IF @ware_linenum = 18 
      UPDATE whbookmisc SET bookmiscgentablecode18 = @ware_number,bookmiscgentabletext18 = @ware_text 
      WHERE bookkey = @ware_bookkey
    ELSE IF @ware_linenum = 19 
      UPDATE whbookmisc SET bookmiscgentablecode19 = @ware_number,bookmiscgentabletext19 = @ware_text 
      WHERE bookkey = @ware_bookkey
    ELSE IF @ware_linenum = 20 
      UPDATE whbookmisc SET bookmiscgentablecode20 = @ware_number,bookmiscgentabletext20 = @ware_text 
      WHERE bookkey = @ware_bookkey
    ELSE IF @ware_linenum = 21 
      UPDATE whbookmisc SET bookmiscgentablecode21 = @ware_number,bookmiscgentabletext21 = @ware_text 
      WHERE bookkey = @ware_bookkey
    ELSE IF @ware_linenum = 22 
      UPDATE whbookmisc SET bookmiscgentablecode22 = @ware_number,bookmiscgentabletext22 = @ware_text 
      WHERE bookkey = @ware_bookkey
    ELSE IF @ware_linenum = 23 
      UPDATE whbookmisc SET bookmiscgentablecode23 = @ware_number,bookmiscgentabletext23 = @ware_text 
      WHERE bookkey = @ware_bookkey
    ELSE IF @ware_linenum = 24 
      UPDATE whbookmisc SET bookmiscgentablecode24 = @ware_number,bookmiscgentabletext24 = @ware_text 
      WHERE bookkey = @ware_bookkey
    ELSE IF @ware_linenum = 25 
      UPDATE whbookmisc SET bookmiscgentablecode25 = @ware_number,bookmiscgentabletext25 = @ware_text 
      WHERE bookkey = @ware_bookkey
    ELSE IF @ware_linenum = 26 
      UPDATE whbookmisc SET bookmiscgentablecode26 = @ware_number,bookmiscgentabletext26 = @ware_text 
      WHERE bookkey = @ware_bookkey
    ELSE IF @ware_linenum = 27 
      UPDATE whbookmisc SET bookmiscgentablecode27 = @ware_number,bookmiscgentabletext27 = @ware_text 
      WHERE bookkey = @ware_bookkey
    ELSE IF @ware_linenum = 28 
      UPDATE whbookmisc SET bookmiscgentablecode28 = @ware_number,bookmiscgentabletext28 = @ware_text 
      WHERE bookkey = @ware_bookkey
    ELSE IF @ware_linenum = 29 
      UPDATE whbookmisc SET bookmiscgentablecode29 = @ware_number,bookmiscgentabletext29 = @ware_text 
      WHERE bookkey = @ware_bookkey
    ELSE IF @ware_linenum = 30 
      UPDATE whbookmisc SET bookmiscgentablecode30 = @ware_number,bookmiscgentabletext30 = @ware_text 
      WHERE bookkey = @ware_bookkey
    ELSE IF @ware_linenum = 31 
      UPDATE whbookmisc SET bookmiscgentablecode31 = @ware_number,bookmiscgentabletext31 = @ware_text 
      WHERE bookkey = @ware_bookkey
    ELSE IF @ware_linenum = 32 
      UPDATE whbookmisc SET bookmiscgentablecode32 = @ware_number,bookmiscgentabletext32 = @ware_text 
      WHERE bookkey = @ware_bookkey
    ELSE IF @ware_linenum = 33 
      UPDATE whbookmisc SET bookmiscgentablecode33 = @ware_number,bookmiscgentabletext33 = @ware_text 
      WHERE bookkey = @ware_bookkey
    ELSE IF @ware_linenum = 34 
      UPDATE whbookmisc SET bookmiscgentablecode34 = @ware_number,bookmiscgentabletext34 = @ware_text 
      WHERE bookkey = @ware_bookkey
    ELSE IF @ware_linenum = 35 
      UPDATE whbookmisc SET bookmiscgentablecode35 = @ware_number,bookmiscgentabletext35 = @ware_text 
      WHERE bookkey = @ware_bookkey
    ELSE IF @ware_linenum = 36 
      UPDATE whbookmisc SET bookmiscgentablecode36 = @ware_number,bookmiscgentabletext36 = @ware_text 
      WHERE bookkey = @ware_bookkey
    ELSE IF @ware_linenum = 37 
      UPDATE whbookmisc SET bookmiscgentablecode37 = @ware_number,bookmiscgentabletext37 = @ware_text 
      WHERE bookkey = @ware_bookkey
    ELSE IF @ware_linenum = 38 
      UPDATE whbookmisc SET bookmiscgentablecode38 = @ware_number,bookmiscgentabletext38 = @ware_text 
      WHERE bookkey = @ware_bookkey
    ELSE IF @ware_linenum = 39 
      UPDATE whbookmisc SET bookmiscgentablecode39 = @ware_number,bookmiscgentabletext39 = @ware_text 
      WHERE bookkey = @ware_bookkey
    ELSE IF @ware_linenum = 40 
      UPDATE whbookmisc SET bookmiscgentablecode40 = @ware_number,bookmiscgentabletext40 = @ware_text 
      WHERE bookkey = @ware_bookkey
  END --IF @ware_misctype = 5 (Gentable)


  FETCH NEXT FROM warehousebookmisc 
  INTO @ware_misckey, @ware_misctype, @ware_linenum
END

CLOSE warehousebookmisc
DEALLOCATE warehousebookmisc



/* Get all Calculated fields for this title */
DECLARE warehousebookmisc2 CURSOR FOR
  SELECT w.misckey, linenumber, c.orgentrykey
  FROM whcbookmisc w, miscitemcalc c 
  WHERE w.misckey = c.misckey AND
        c.orgentrykey IN (SELECT orgentrykey FROM bookorgentry WHERE bookkey = @ware_bookkey)
FOR READ ONLY
  
OPEN warehousebookmisc2

FETCH NEXT FROM warehousebookmisc2
INTO @ware_misckey, @ware_linenum, @ware_orgentrykey

WHILE (@@FETCH_STATUS <> - 1)
BEGIN
 
  SET @c_sql = ''
  SET @ware_float = 0

  /* check to see if more than 1 orglevel row exits for bookkey and misckey */
  SELECT @i_count = COUNT(*) 
  FROM whcbookmisc w, miscitemcalc c 
  WHERE w.misckey = c.misckey AND
        w.misckey = @ware_misckey AND
        c.orgentrykey IN (SELECT orgentrykey FROM bookorgentry WHERE bookkey = @ware_bookkey)
		
  if @i_count > 1  /*yes more than 1 row so get lowest orglevel--MAKE SURE NOT SAME ORGLEVEL*/
    SELECT @i_orglevel = MAX(orglevelkey) 
    FROM whcbookmisc w, miscitemcalc c 
    WHERE w.misckey = c.misckey AND
          w.misckey = @ware_misckey AND
          c.orgentrykey IN (SELECT orgentrykey FROM bookorgentry WHERE bookkey = @ware_bookkey)
  ELSE
    SET @i_orglevel = 0
		
  IF @i_orglevel > 0 
    SELECT @i_orgentrykey = orgentrykey
    FROM whcbookmisc w, miscitemcalc c 
    WHERE w.misckey = c.misckey AND
          w.misckey = @ware_misckey AND
          c.orglevelkey = @i_orglevel AND
          c.orgentrykey IN (SELECT orgentrykey FROM bookorgentry WHERE bookkey = @ware_bookkey)
  ELSE
    SET @i_orgentrykey = @ware_orgentrykey

  SELECT @ware_qsibody = calcsql
  FROM miscitemcalc
  WHERE misckey = @ware_misckey AND orgentrykey = @i_orgentrykey
      
  IF len(@ware_qsibody) > 0 
  BEGIN
    SELECT @i_count = COUNT(*)
    FROM qsiusers
    WHERE userid = @ware_userid
    
    IF @i_count > 0
      SELECT @userkey = userkey
      FROM qsiusers
      WHERE userid = @ware_userid
    ELSE
      SET @userkey = 0
  
    SET @ware_qsibody = REPLACE(@ware_qsibody, '@bookkey', CONVERT(VARCHAR, @ware_bookkey))
    SET @ware_qsibody = REPLACE(@ware_qsibody, '@printingkey', '1')
    SET @ware_qsibody = REPLACE(@ware_qsibody, '@userid', @ware_userid)
    SET @ware_qsibody = REPLACE(@ware_qsibody, '@userkey', CONVERT(VARCHAR, @userkey))

    SET @ware_float = NULL
    
    SET @c_sql = @ware_qsibody
    
    EXECUTE execute_calcsql @c_sql, @ware_float OUTPUT

    IF @ware_linenum = 1 
      UPDATE whbookmisc SET bookmisccalc1 = @ware_float WHERE bookkey = @ware_bookkey
    ELSE IF @ware_linenum = 2 
      UPDATE whbookmisc SET bookmisccalc2 = @ware_float WHERE bookkey = @ware_bookkey
    ELSE IF @ware_linenum = 3 
      UPDATE whbookmisc SET bookmisccalc3 = @ware_float WHERE bookkey = @ware_bookkey
    ELSE IF @ware_linenum = 4 
      UPDATE whbookmisc SET bookmisccalc4 = @ware_float WHERE bookkey = @ware_bookkey
    ELSE IF @ware_linenum = 5 
      UPDATE whbookmisc SET bookmisccalc5 = @ware_float WHERE bookkey = @ware_bookkey
    ELSE IF @ware_linenum = 6 
      UPDATE whbookmisc SET bookmisccalc6 = @ware_float WHERE bookkey = @ware_bookkey
    ELSE IF @ware_linenum = 7 
      UPDATE whbookmisc SET bookmisccalc7 = @ware_float WHERE bookkey = @ware_bookkey
    ELSE IF @ware_linenum = 8 
      UPDATE whbookmisc SET bookmisccalc8 = @ware_float WHERE bookkey = @ware_bookkey
    ELSE IF @ware_linenum = 9 
      UPDATE whbookmisc SET bookmisccalc9 = @ware_float WHERE bookkey = @ware_bookkey
    ELSE IF @ware_linenum = 10 
      UPDATE whbookmisc SET bookmisccalc10 = @ware_float WHERE bookkey = @ware_bookkey
    ELSE IF @ware_linenum = 11 
      UPDATE whbookmisc SET bookmisccalc11 = @ware_float WHERE bookkey = @ware_bookkey
    ELSE IF @ware_linenum = 12 
      UPDATE whbookmisc SET bookmisccalc12 = @ware_float WHERE bookkey = @ware_bookkey
    ELSE IF @ware_linenum = 13 
      UPDATE whbookmisc SET bookmisccalc13 = @ware_float WHERE bookkey = @ware_bookkey
    ELSE IF @ware_linenum = 14 
      UPDATE whbookmisc SET bookmisccalc14 = @ware_float WHERE bookkey = @ware_bookkey
    ELSE IF @ware_linenum = 15 
      UPDATE whbookmisc SET bookmisccalc15 = @ware_float WHERE bookkey = @ware_bookkey
    ELSE IF @ware_linenum = 16 
      UPDATE whbookmisc SET bookmisccalc16 = @ware_float WHERE bookkey = @ware_bookkey
    ELSE IF @ware_linenum = 17 
      UPDATE whbookmisc SET bookmisccalc17 = @ware_float WHERE bookkey = @ware_bookkey
    ELSE IF @ware_linenum = 18 
      UPDATE whbookmisc SET bookmisccalc18 = @ware_float WHERE bookkey = @ware_bookkey
    ELSE IF @ware_linenum = 19 
      UPDATE whbookmisc SET bookmisccalc19 = @ware_float WHERE bookkey = @ware_bookkey
    ELSE IF @ware_linenum = 20 
      UPDATE whbookmisc SET bookmisccalc20 = @ware_float WHERE bookkey = @ware_bookkey
    ELSE IF  @ware_linenum = 21 
      UPDATE whbookmisc SET bookmisccalc21 = @ware_float WHERE bookkey = @ware_bookkey
    ELSE IF @ware_linenum = 22 
      UPDATE whbookmisc SET bookmisccalc22 = @ware_float WHERE bookkey = @ware_bookkey
    ELSE IF @ware_linenum = 23 
      UPDATE whbookmisc SET bookmisccalc23 = @ware_float WHERE bookkey = @ware_bookkey
    ELSE IF @ware_linenum = 24 
      UPDATE whbookmisc SET bookmisccalc24 = @ware_float WHERE bookkey = @ware_bookkey
    ELSE IF @ware_linenum = 25 
      UPDATE whbookmisc SET bookmisccalc25 = @ware_float WHERE bookkey = @ware_bookkey
    ELSE IF @ware_linenum = 26 
      UPDATE whbookmisc SET bookmisccalc26 = @ware_float WHERE bookkey = @ware_bookkey
    ELSE IF @ware_linenum = 27 
      UPDATE whbookmisc SET bookmisccalc27 = @ware_float WHERE bookkey = @ware_bookkey
    ELSE IF @ware_linenum = 28 
      UPDATE whbookmisc SET bookmisccalc28 = @ware_float WHERE bookkey = @ware_bookkey
    ELSE IF @ware_linenum = 29 
      UPDATE whbookmisc SET bookmisccalc29 = @ware_float WHERE bookkey = @ware_bookkey
    ELSE IF @ware_linenum = 30 
      UPDATE whbookmisc SET bookmisccalc30 = @ware_float WHERE bookkey = @ware_bookkey
    ELSE IF @ware_linenum = 31 
      UPDATE whbookmisc SET bookmisccalc31 = @ware_float WHERE bookkey = @ware_bookkey
    ELSE IF @ware_linenum = 32 
      UPDATE whbookmisc SET bookmisccalc32 = @ware_float WHERE bookkey = @ware_bookkey
    ELSE IF @ware_linenum = 33 
      UPDATE whbookmisc SET bookmisccalc33 = @ware_float WHERE bookkey = @ware_bookkey
    ELSE IF @ware_linenum = 34 
      UPDATE whbookmisc SET bookmisccalc34 = @ware_float WHERE bookkey = @ware_bookkey
    ELSE IF @ware_linenum = 35 
      UPDATE whbookmisc SET bookmisccalc35 = @ware_float WHERE bookkey = @ware_bookkey
    ELSE IF @ware_linenum = 36 
      UPDATE whbookmisc SET bookmisccalc36 = @ware_float WHERE bookkey = @ware_bookkey
    ELSE IF @ware_linenum = 37 
      UPDATE whbookmisc SET bookmisccalc37 = @ware_float WHERE bookkey = @ware_bookkey
    ELSE IF @ware_linenum = 38 
      UPDATE whbookmisc SET bookmisccalc38 = @ware_float WHERE bookkey = @ware_bookkey
    ELSE IF @ware_linenum = 39 
      UPDATE whbookmisc SET bookmisccalc39 = @ware_float WHERE bookkey = @ware_bookkey
    ELSE IF @ware_linenum = 40 
      UPDATE whbookmisc SET bookmisccalc40 = @ware_float WHERE bookkey = @ware_bookkey
  END  --IF len(@c_sql) > 0
  
  FETCH NEXT FROM warehousebookmisc2 
  INTO @ware_misckey, @ware_linenum,@ware_orgentrykey

END
      
CLOSE warehousebookmisc2
DEALLOCATE warehousebookmisc2

END
GO

GRANT EXECUTE ON  dbo.datawarehouse_bookmisc TO PUBLIC
GO
