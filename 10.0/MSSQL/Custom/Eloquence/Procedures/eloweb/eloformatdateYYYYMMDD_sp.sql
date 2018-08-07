SET QUOTED_IDENTIFIER OFF 
GO
SET ANSI_NULLS OFF 
GO

if exists (select * from dbo.sysobjects where id = object_id(N'[dbo].[eloformatdateYYYYMMDD_sp]') and OBJECTPROPERTY(id, N'IsProcedure') = 1)
drop procedure [dbo].[eloformatdateYYYYMMDD_sp]
GO

create proc dbo.eloformatdateYYYYMMDD_sp 
(@d_date datetime)
/*******************************************************/
/*	                                                 */
/*	    Author   : DSL                                    */
/*	    Creation Date : 9/14                               */
/*	    Comments : Takes  Date @d_date */
/*                     and creates row on eloconverteddate to 'YYYYMMDD'  */
/*	                                                 */
/*******************************************************/

AS 


DECLARE @i_year int
DECLARE @i_month int
DECLARE @i_day int
DECLARE @c_month char(2)
DECLARE @c_day char(2)


/*initialize the temporary table */
delete from eloconverteddate

if @d_date is NULL or @d_date='01/01/1900'
begin
insert into eloconverteddate (converteddate) values ('')
return
end

select @c_month=''
select @c_day=''




select @i_year=datepart (year,@d_date)
select @i_month=datepart (month,@d_date)
select @i_day=datepart (day,@d_date)


/** Pad Month and Day with zero if less than 10 (i.e. two digits) */

if @i_month >= 10
select @c_month=convert (char(2),@i_month)
else
select @c_month='0' + convert (char(1),@i_month)

if @i_day >= 10
select @c_day=convert (char(2),@i_day)
else
select @c_day='0' + convert (char(1),@i_day)

insert into eloconverteddate (converteddate)
select convert(char(4),@i_year) + @c_month + @c_day

return



GO
SET QUOTED_IDENTIFIER OFF 
GO
SET ANSI_NULLS ON 
GO

