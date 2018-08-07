if exists (select * from dbo.sysobjects where id = object_id(N'dbo.qutl_get_daterange_for_currentuser_tasks') and xtype in (N'FN', N'IF', N'TF'))
  drop function dbo.qutl_get_daterange_for_currentuser_tasks
GO

CREATE FUNCTION qutl_get_daterange_for_currentuser_tasks(
  @i_numDaysfilter	integer  -- 6 (see gentables)
  )
  
RETURNS @fromtodates TABLE(
  fromdate datetime, 
  todate datetime
)

AS
BEGIN
  DECLARE @error_var    INT,
		  @rowcount_var INT,
		  @CurrDate		datetime,
		  @sqlCmd		varchar(max),
		  @finalSQLCmd	varchar(max),
		  @forSQL		varchar(max),
		  @asSQL		varchar(max),
		  @FromDate		varchar(30),
		  @ToDate		varchar(30),
		  @tempDate		datetime,
		  @ToDays		int,
		  @KeyList      varchar(max), -- output list of globalcontactkeys valid when "My User Group" was selected
		  @Numkeys      int,
		  @RowCount     int,
		  @v_quote      VARCHAR(2)          
		          
          
  SET @v_quote = ''''

  -- Deal with the date range
  -- Get a default, this should never happen, the user should always select a number of days filter
  if ( @i_numDaysfilter is null ) select @i_numDaysfilter = ( select datacode from gentables where tableid = 589 and datadesc = 'Overdue' )

  select @CurrDate = getDate()
  select @FromDate = (SELECT DATEADD(day, (select numericdesc1 from gentables where tableid = 589 and datacode = @i_numDaysfilter), getdate())  )
  select @ToDays = (select numericdesc2 from gentables where tableid = 589 and datacode = @i_numDaysfilter)
  select @ToDate = (SELECT DATEADD(day, @ToDays, getdate())  )

  -- swap dates for 'between' usage below
  if ( @ToDays <= 0 )
  begin
	select @tempDate = @FromDate
	select @FromDate = @ToDate
	select @ToDate = @tempDate
  end

  select @FromDate =  (select Convert(varchar(3), Datepart(mm, @FromDate)) + '/' +
							Convert(varchar(3), DatePart(dd, @FromDate)) + '/' +
							Convert(varchar(4), Datepart(yyyy, @FromDate)) + ' 00:00')

  select @ToDate = (select Convert(varchar(3), Datepart(mm, @ToDate)) + '/' +
							Convert(varchar(3), DatePart(dd, @ToDate)) + '/' +
							Convert(varchar(4), Datepart(yyyy, @ToDate)) + ' 12:59')
							
  --DECLARE @accessList TABLE (  RowID int IDENTITY(1, 1), fromdate datetime, todate datetime)							
  --INSERT INTO @accessList ( fromdate, todate) values (@FromDate, @ToDate)
  
  INSERT INTO @fromtodates	( fromdate, todate) values (@FromDate, @ToDate)					
							
  RETURN
END
GO

GRANT SELECT ON dbo.qutl_get_daterange_for_currentuser_tasks TO public
GO
