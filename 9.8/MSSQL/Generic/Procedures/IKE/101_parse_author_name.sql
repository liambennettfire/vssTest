SET QUOTED_IDENTIFIER ON 
GO
SET ANSI_NULLS ON 
GO

/******************************************************************************
**  Name: parse_author_name
**  Desc: IKE separate author names
**  Auth: Bennett     
**  Date: 5/9/2016
*******************************************************************************
**  Change History
*******************************************************************************
**  Date:        Author:     Description:
*   --------     --------    -------------------------------------------
**  5/9/2016     Bennett     original
*******************************************************************************/

if exists (select * from dbo.sysobjects where id = object_id(N'[dbo].[parse_author_name]') and OBJECTPROPERTY(id, N'IsProcedure') = 1)
drop procedure [dbo].parse_author_name
GO

create procedure parse_author_name
  (@i_name varchar(200),
   @o_firstname varchar(30) output,
   @o_middlename varchar(30) output,
   @o_lastname varchar(30) output,
   @o_title varchar(30) output,
   @o_suffix varchar(30) output,
   @o_degree varchar(30) output,
   @i_calc_middlename int = 0,
   @i_calc_title int = 1,
   @i_calc_suffix int = 1,
   @i_calc_degree int = 1)

AS
DECLARE 
  @v_name varchar(500),
  @v_count int,
  @v_pointer int,
  @v_dataseg varchar(50)
  
begin

  set @v_name=' '+replace(@i_name,',',' ')+' '

  --find title and remove from name if requested
  if @i_calc_title=1
    begin
      declare c_author_title cursor for
        select distinct ' '+rtrim(ltrim(title))+' '
          from author
          where rtrim(ltrim(title))<>''
      open c_author_title
      fetch c_author_title into @v_dataseg
      set @v_pointer=0
      while @@FETCH_STATUS <> -1 and @v_pointer=0
        begin
          set @v_pointer=charindex(@v_dataseg,@v_name)
          if @v_pointer>0
            begin
              set @o_title=rtrim(ltrim(@v_dataseg))
              set @v_name=replace(@v_name,rtrim(ltrim(@v_dataseg)),'')
            end
          fetch c_author_title into @v_dataseg
        end
      close c_author_title
      deallocate c_author_title 
    end

  --find suffix and remove from name if requested
  if @i_calc_suffix=1
    begin
      declare c_author_suffix cursor for
        select distinct ' '+rtrim(ltrim(authorsuffix))+' '
          from author
          where rtrim(ltrim(authorsuffix))<>''
      open c_author_suffix
      fetch c_author_suffix into @v_dataseg
      set @v_pointer=0
      while @@FETCH_STATUS <> -1 and @v_pointer=0
        begin
          set @v_pointer=charindex(@v_dataseg,@v_name)
          if @v_pointer>0
            begin
              set @o_suffix=rtrim(ltrim(@v_dataseg))
              set @v_name=replace(@v_name,rtrim(ltrim(@v_dataseg)),'')
            end
          fetch c_author_suffix into @v_dataseg
        end
      close c_author_suffix
      deallocate c_author_suffix 
    end

  --find degree and remove from name if requested
  if @i_calc_degree=1
    begin
      declare c_author_degree cursor for
        select distinct ' '+rtrim(ltrim(authordegree))+' '
          from author
          where rtrim(ltrim(authordegree))<>''
      open c_author_degree
      fetch c_author_degree into @v_dataseg
      set @v_pointer=0
      while @@FETCH_STATUS <> -1 and @v_pointer=0
        begin
          set @v_pointer=charindex(@v_dataseg,@v_name)
          if @v_pointer>0
            begin
              set @o_degree=rtrim(ltrim(@v_dataseg))
              set @v_name=replace(@v_name,rtrim(ltrim(@v_dataseg)),'')
            end
          fetch c_author_degree into @v_dataseg
        end
      close c_author_degree
      deallocate c_author_degree 
    end


  --remove all double spaces 
  set @v_name=rtrim(ltrim(@v_name))
  while charindex('  ',@v_name)>0
    begin
      set @v_name=replace(@v_name,'  ',' ')
    end

  --remove lastname 
  set @v_pointer=1
  while charindex(' ',@v_name,@v_pointer)>0
    begin
      set @v_pointer=charindex(' ',@v_name,@v_pointer)
      set @v_pointer=@v_pointer+1
    end

  --remove/set middlename 
  set @v_pointer=1
  while charindex(' ',@v_name,@v_pointer)>0
    begin
      set @v_pointer=charindex(' ',@v_name,@v_pointer)
      set @v_pointer=@v_pointer+1
    end
  set @o_lastname=substring(@v_name,@v_pointer,500)
  set @v_name=rtrim(ltrim(substring(@v_name,1,@v_pointer-1)))

  --remove/set middlename 
  if @i_calc_middlename=1
    begin
      set @v_pointer=1
      while charindex(' ',@v_name,@v_pointer)>0
        begin
          set @v_pointer=charindex(' ',@v_name,@v_pointer)
          set @v_pointer=@v_pointer+1
        end
      set @o_middlename=substring(@v_name,@v_pointer,500)
      set @v_name=substring(@v_name,1,@v_pointer-1)
    end

  --set first name
  set @o_firstname=rtrim(ltrim(@v_name))

  if rtrim(ltrim(@o_firstname))='' or @o_firstname is null and @o_middlename is not null
    begin
      set @o_firstname=@o_middlename
      set @o_middlename=null
    end

end


GO
SET QUOTED_IDENTIFIER OFF 
GO
SET ANSI_NULLS ON 
GO

GRANT EXECUTE ON dbo.parse_author_name TO PUBLIC 
GO


