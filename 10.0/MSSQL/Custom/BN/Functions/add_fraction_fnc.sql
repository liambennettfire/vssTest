if exists (select * from dbo.sysobjects where id = object_id(N'[dbo].[add_fraction]') and xtype in (N'FN', N'IF', N'TF'))
drop function [dbo].[add_fraction]
GO

SET QUOTED_IDENTIFIER ON 
GO
SET ANSI_NULLS ON 
GO

CREATE FUNCTION dbo.add_fraction(
			@c_fraction varchar(10),
			@c_add_fraction varchar(10))

RETURNS VARCHAR(10)

AS
BEGIN
	DECLARE @RETURN VARCHAR(10)
	DECLARE @i_wholenumber int
	DECLARE @i_addtowholenumber int
	DECLARE @i_numerator int
	DECLARE @i_denominator int
	DECLARE @i_addnumerator int
	DECLARE @i_adddenominator int
	DECLARE @i_answernumerator int
	DECLARE @i_answerdenominator int
	DECLARE @i_answerfraction VARCHAR(10)


/*PARSE WHOLENUMBER*/
select @i_wholenumber = substring(rtrim(ltrim(@c_fraction)),1,2) 

/*PARSE NUMERATOR*/
select @i_numerator = ltrim(substring(@c_fraction,(charindex('/',@c_fraction)-2),2))

/*PARSE DENOMINATOR*/
select @i_denominator = rtrim(substring(@c_fraction,(charindex('/',@c_fraction)+1),2)) 

/*PARSE ADD NUMERATOR*/
select @i_addnumerator = ltrim(substring(@c_add_fraction,(charindex('/',@c_add_fraction)-2),2))

/*PARSE ADD DENOMINATOR*/
select @i_adddenominator = rtrim(substring(@c_add_fraction,(charindex('/',@c_add_fraction)+1),2))

select @i_answernumerator = (@i_numerator * @i_adddenominator)+ (@i_addnumerator * @i_denominator)

select @i_answerdenominator = (@i_denominator * @i_adddenominator)


	declare @I int
	set @I = @i_answerdenominator - 1
	while 1=1
	begin
	  set @I = @I - 1
		If (@i_answernumerator % @I = 0 and @i_answerdenominator % @I = 0)
		   BREAK
		Else
		   CONTINUE
        end

	select @i_answernumerator = @i_answernumerator / @I
	select @i_answerdenominator = @i_answerdenominator / @I



-- Normal fraction leave alone
	If @i_answernumerator < @i_answerdenominator
	   begin
		select @i_answerfraction = Cast(@i_wholenumber AS varchar(10)) + ' ' + Cast(@i_answernumerator AS varchar(10)) + '/' + Cast(@i_answerdenominator AS varchar(10))
	   end

-- Fraction equals 1 so just add it to whole number
	If @i_answernumerator = @i_answerdenominator
	   begin
		select 	@i_answerfraction = @i_wholenumber + 1
		
	   end
-- Fraction is greater than 1 so subtract and add to whole number
	If @i_answernumerator > @i_answerdenominator
	   begin
		select @i_answernumerator =  @i_answernumerator - @i_answerdenominator
		-- Needs work for now den/num - remainder should be new numerator
		select 	@i_wholenumber = @i_wholenumber + 1
		select @i_answerfraction = Cast(@i_wholenumber AS varchar(10)) + ' ' + Cast(@i_answernumerator AS varchar(10)) + '/' + Cast(@i_answerdenominator AS varchar(10))
	   end
		

select @RETURN = @i_answerfraction


	RETURN @RETURN
END
GO 
GRANT EXECUTE on [dbo].[add_fraction] to PUBLIC

GO
SET QUOTED_IDENTIFIER OFF 
GO
SET ANSI_NULLS ON 
GO