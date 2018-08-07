



Select (select count(*) * 100 from product) / count(*)
from UNL..BOOK b, UNL..bookdetail bd
where b.bookkey = b.workkey
and b.bookkey = bd.bookkey
and bd.publishtowebind = 1

