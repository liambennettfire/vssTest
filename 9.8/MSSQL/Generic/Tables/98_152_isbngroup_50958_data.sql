DECLARE @v_datacode int, @v_count int

select @v_datacode = datacode 
from gentables
where tableid = 138 
and datadesc = '979'

if @v_datacode > 0 begin
  select @v_count = count(*) from isbngroup where eanprefixcode = @v_datacode and isbngroup = 10
  if @v_count = 0 begin
    insert into isbngroup (eanprefixcode, isbngroup, groupdesc, groupdescdetail)
    values (@v_datacode, 10, 'France', null)
  end

  select @v_count = count(*) from isbngroup where eanprefixcode = @v_datacode and isbngroup = 11
  if @v_count = 0 begin
    insert into isbngroup (eanprefixcode, isbngroup, groupdesc, groupdescdetail)
    values (@v_datacode, 11, 'Republic of Korea', null)
  end

  select @v_count = count(*) from isbngroup where eanprefixcode = @v_datacode and isbngroup = 12
  if @v_count = 0 begin
    insert into isbngroup (eanprefixcode, isbngroup, groupdesc, groupdescdetail)
    values (@v_datacode, 12, 'Italy', null)
  end
end
