--update 
update taqversionspecitems 
set description = b.endpapercolor
from bindingspecs b
inner join taqprojecttitle t on b.bookkey=t.bookkey and b.printingkey=t.printingkey and t.titlerolecode=9 and t.projectrolecode=5
inner join taqversionspeccategory s on t.taqprojectkey=s.taqprojectkey and s.itemcategorycode=17
inner join taqversionspecitems i on s.taqversionspecategorykey = i.taqversionspecategorykey and i.itemcode=1
where coalesce(b.endpapercolor,'')<>''
and coalesce(description,'')=''