IF EXISTS (SELECT * FROM dbo.sysobjects WHERE id = Object_id('temp_sgt_bisaccodes_2007') AND type = 'U')
  BEGIN
    DROP table temp_sgt_bisaccodes_2007
  END
go


CREATE TABLE temp_sgt_bisaccodes_2007  (
	Code char(255),
	Literal char(255))   
go

/*INSERT INTO temp_sgt_bisaccodes_2007 VALUES (
	'ANT000000',
	'General')
go*/

INSERT INTO temp_sgt_bisaccodes_2007 VALUES (
	'ARC019000',
	'Codes & Standards')
go

INSERT INTO temp_sgt_bisaccodes_2007 VALUES (
	'ARC004000',
	'Design, Drafting, Drawing & Presentation')
go

INSERT INTO temp_sgt_bisaccodes_2007 VALUES (
	'ARC005000',
	'History / General')
go

INSERT INTO temp_sgt_bisaccodes_2007 VALUES (
	'ARC005010',
	'History / Prehistoric & Primitive')
go

INSERT INTO temp_sgt_bisaccodes_2007 VALUES (
	'ARC005020',
	'History / Ancient & Classical')
go

INSERT INTO temp_sgt_bisaccodes_2007 VALUES (
	'ARC005030',
	'History / Medieval')
go

INSERT INTO temp_sgt_bisaccodes_2007 VALUES (
	'ARC005040',
	'History / Renaissance')
go

INSERT INTO temp_sgt_bisaccodes_2007 VALUES (
	'ARC005050',
	'History / Baroque & Rococo')
go

INSERT INTO temp_sgt_bisaccodes_2007 VALUES (
	'ARC005060',
	'History / Romanticism')
go

INSERT INTO temp_sgt_bisaccodes_2007 VALUES (
	'ARC005070',
	'History / Modern (late 19th Century to 1945)')
go

INSERT INTO temp_sgt_bisaccodes_2007 VALUES (
	'ARC005080',
	'History / Contemporary (1945-)')
go

INSERT INTO temp_sgt_bisaccodes_2007 VALUES (
	'ARC020000',
	'Regional')
go

INSERT INTO temp_sgt_bisaccodes_2007 VALUES (
	'ARC003000',
	'Residential')
go

INSERT INTO temp_sgt_bisaccodes_2007 VALUES (
	'ARC021000',
	'Security Design')
go

INSERT INTO temp_sgt_bisaccodes_2007 VALUES (
	'ART041000',
	'Native American')
go

INSERT INTO temp_sgt_bisaccodes_2007 VALUES (
	'BIB001000',
	'Christian Standard Bible / General')
go

INSERT INTO temp_sgt_bisaccodes_2007 VALUES (
	'BIB001010',
	'Christian Standard Bible / Children')
go

INSERT INTO temp_sgt_bisaccodes_2007 VALUES (
	'BIB001020',
	'Christian Standard Bible / Devotional')
go

INSERT INTO temp_sgt_bisaccodes_2007 VALUES (
	'BIB001030',
	'Christian Standard Bible / New Testament & Portions')
go

INSERT INTO temp_sgt_bisaccodes_2007 VALUES (
	'BIB001040',
	'Christian Standard Bible / Reference')
go

INSERT INTO temp_sgt_bisaccodes_2007 VALUES (
	'BIB001050',
	'Christian Standard Bible / Study')
go

INSERT INTO temp_sgt_bisaccodes_2007 VALUES (
	'BIB001060',
	'Christian Standard Bible / Text')
go

INSERT INTO temp_sgt_bisaccodes_2007 VALUES (
	'BIB001070',
	'Christian Standard Bible / Youth & Teen')
go

INSERT INTO temp_sgt_bisaccodes_2007 VALUES (
	'BIB002000',
	'Contemporary English Version / General')
go

INSERT INTO temp_sgt_bisaccodes_2007 VALUES (
	'BIB002010',
	'Contemporary English Version / Children')
go

INSERT INTO temp_sgt_bisaccodes_2007 VALUES (
	'BIB002020',
	'Contemporary English Version / Devotional')
go

INSERT INTO temp_sgt_bisaccodes_2007 VALUES (
	'BIB002030',
	'Contemporary English Version / New Testament & Portions')
go

INSERT INTO temp_sgt_bisaccodes_2007 VALUES (
	'BIB002040',
	'Contemporary English Version / Reference')
go

INSERT INTO temp_sgt_bisaccodes_2007 VALUES (
	'BIB002050',
	'Contemporary English Version / Study')
go

INSERT INTO temp_sgt_bisaccodes_2007 VALUES (
	'BIB002060',
	'Contemporary English Version / Text')
go

INSERT INTO temp_sgt_bisaccodes_2007 VALUES (
	'BIB002070',
	'Contemporary English Version / Youth & Teen')
go

INSERT INTO temp_sgt_bisaccodes_2007 VALUES (
	'BIB003000',
	'English Standard Version / General')
go

INSERT INTO temp_sgt_bisaccodes_2007 VALUES (
	'BIB003010',
	'English Standard Version / Children')
go

INSERT INTO temp_sgt_bisaccodes_2007 VALUES (
	'BIB003020',
	'English Standard Version / Devotional')
go

INSERT INTO temp_sgt_bisaccodes_2007 VALUES (
	'BIB003030',
	'English Standard Version / New Testament & Portions')
go

INSERT INTO temp_sgt_bisaccodes_2007 VALUES (
	'BIB003040',
	'English Standard Version / Reference')
go

INSERT INTO temp_sgt_bisaccodes_2007 VALUES (
	'BIB003050',
	'English Standard Version / Study')
go

INSERT INTO temp_sgt_bisaccodes_2007 VALUES (
	'BIB003060',
	'English Standard Version / Text')
go

INSERT INTO temp_sgt_bisaccodes_2007 VALUES (
	'BIB003070',
	'English Standard Version / Youth & Teen')
go

INSERT INTO temp_sgt_bisaccodes_2007 VALUES (
	'BIB004000',
	'God''s Word / General')
go

INSERT INTO temp_sgt_bisaccodes_2007 VALUES (
	'BIB004010',
	'God''s Word / Children')
go

INSERT INTO temp_sgt_bisaccodes_2007 VALUES (
	'BIB004020',
	'God''s Word / Devotional')
go

INSERT INTO temp_sgt_bisaccodes_2007 VALUES (
	'BIB004030',
	'God''s Word / New Testament & Portions')
go

INSERT INTO temp_sgt_bisaccodes_2007 VALUES (
	'BIB004400',
	'God''s Word / Reference')
go

INSERT INTO temp_sgt_bisaccodes_2007 VALUES (
	'BIB004050',
	'God''s Word / Study')
go

INSERT INTO temp_sgt_bisaccodes_2007 VALUES (
	'BIB004060',
	'God''s Word / Text')
go

INSERT INTO temp_sgt_bisaccodes_2007 VALUES (
	'BIB004070',
	'God''s Word / Youth & Teen')
go

INSERT INTO temp_sgt_bisaccodes_2007 VALUES (
	'BIB005000',
	'International Children''s Bible / General')
go

INSERT INTO temp_sgt_bisaccodes_2007 VALUES (
	'BIB005010',
	'International Children''s Bible / Children')
go

INSERT INTO temp_sgt_bisaccodes_2007 VALUES (
	'BIB005020',
	'International Children''s Bible / Devotional')
go

INSERT INTO temp_sgt_bisaccodes_2007 VALUES (
	'BIB005030',
	'International Children''s Bible / New Testament & Portions')
go

INSERT INTO temp_sgt_bisaccodes_2007 VALUES (
	'BIB005040',
	'International Children''s Bible / Reference')
go

INSERT INTO temp_sgt_bisaccodes_2007 VALUES (
	'BIB005050',
	'International Children''s Bible / Study')
go

INSERT INTO temp_sgt_bisaccodes_2007 VALUES (
	'BIB005060',
	'International Children''s Bible / Text')
go

INSERT INTO temp_sgt_bisaccodes_2007 VALUES (
	'BIB005070',
	'International Children''s Bible / Youth & Teen')
go

INSERT INTO temp_sgt_bisaccodes_2007 VALUES (
	'BIB006000',
	'King James Version / General')
go

INSERT INTO temp_sgt_bisaccodes_2007 VALUES (
	'BIB006010',
	'King James Version / Children')
go

INSERT INTO temp_sgt_bisaccodes_2007 VALUES (
	'BIB006020',
	'King James Version / Devotional')
go

INSERT INTO temp_sgt_bisaccodes_2007 VALUES (
	'BIB006030',
	'King James Version / New Testament & Portions')
go

INSERT INTO temp_sgt_bisaccodes_2007 VALUES (
	'BIB006040',
	'King James Version / Reference')
go

INSERT INTO temp_sgt_bisaccodes_2007 VALUES (
	'BIB006050',
	'King James Version / Study')
go

INSERT INTO temp_sgt_bisaccodes_2007 VALUES (
	'BIB006060',
	'King James Version / Text')
go

INSERT INTO temp_sgt_bisaccodes_2007 VALUES (
	'BIB006070',
	'King James Version / Youth & Teen')
go

INSERT INTO temp_sgt_bisaccodes_2007 VALUES (
	'BIB007000',
	'La Biblia de las Americas / General')
go

INSERT INTO temp_sgt_bisaccodes_2007 VALUES (
	'BIB007010',
	'La Biblia de las Americas / Children')
go

INSERT INTO temp_sgt_bisaccodes_2007 VALUES (
	'BIB007020',
	'La Biblia de las Americas / Devotional')
go

INSERT INTO temp_sgt_bisaccodes_2007 VALUES (
	'BIB007030',
	'La Biblia de las Americas / New Testament & Portions')
go

INSERT INTO temp_sgt_bisaccodes_2007 VALUES (
	'BIB007040',
	'La Biblia de las Americas / Reference')
go

INSERT INTO temp_sgt_bisaccodes_2007 VALUES (
	'BIB007050',
	'La Biblia de las Americas / Study')
go

INSERT INTO temp_sgt_bisaccodes_2007 VALUES (
	'BIB007060',
	'La Biblia de las Americas / Text')
go

INSERT INTO temp_sgt_bisaccodes_2007 VALUES (
	'BIB007070',
	'La Biblia de las Americas / Youth & Teen')
go

INSERT INTO temp_sgt_bisaccodes_2007 VALUES (
	'BIB008000',
	'Multiple Translations / General')
go

INSERT INTO temp_sgt_bisaccodes_2007 VALUES (
	'BIB008010',
	'Multiple Translations / Children')
go

INSERT INTO temp_sgt_bisaccodes_2007 VALUES (
	'BIB008020',
	'Multiple Translations / Devotional')
go

INSERT INTO temp_sgt_bisaccodes_2007 VALUES (
	'BIB008030',
	'Multiple Translations / New Testament & Portions')
go

INSERT INTO temp_sgt_bisaccodes_2007 VALUES (
	'BIB008040',
	'Multiple Translations / Reference')
go

INSERT INTO temp_sgt_bisaccodes_2007 VALUES (
	'BIB008050',
	'Multiple Translations / Study')
go

INSERT INTO temp_sgt_bisaccodes_2007 VALUES (
	'BIB008060',
	'Multiple Translations / Text')
go

INSERT INTO temp_sgt_bisaccodes_2007 VALUES (
	'BIB008070',
	'Multiple Translations / Youth & Teen')
go

INSERT INTO temp_sgt_bisaccodes_2007 VALUES (
	'BIB009000',
	'New American Bible / General')
go

INSERT INTO temp_sgt_bisaccodes_2007 VALUES (
	'BIB009010',
	'New American Bible / Children')
go

INSERT INTO temp_sgt_bisaccodes_2007 VALUES (
	'BIB009020',
	'New American Bible / Devotional')
go

INSERT INTO temp_sgt_bisaccodes_2007 VALUES (
	'BIB009030',
	'New American Bible / New Testaments & Portions')
go

INSERT INTO temp_sgt_bisaccodes_2007 VALUES (
	'BIB009040',
	'New American Bible / Reference')
go

INSERT INTO temp_sgt_bisaccodes_2007 VALUES (
	'BIB009050',
	'New American Bible / Study')
go

INSERT INTO temp_sgt_bisaccodes_2007 VALUES (
	'BIB009060',
	'New American Bible / Text')
go

INSERT INTO temp_sgt_bisaccodes_2007 VALUES (
	'BIB009070',
	'New American Bible / Youth & Teen')
go

INSERT INTO temp_sgt_bisaccodes_2007 VALUES (
	'BIB010000',
	'New American Standard Bible / General')
go

INSERT INTO temp_sgt_bisaccodes_2007 VALUES (
	'BIB010010',
	'New American Standard Bible / Children')
go

INSERT INTO temp_sgt_bisaccodes_2007 VALUES (
	'BIB010020',
	'New American Standard Bible / Devotional')
go

INSERT INTO temp_sgt_bisaccodes_2007 VALUES (
	'BIB010030',
	'New American Standard Bible / New Testament & Portions')
go

INSERT INTO temp_sgt_bisaccodes_2007 VALUES (
	'BIB010040',
	'New American Standard Bible / Reference')
go

INSERT INTO temp_sgt_bisaccodes_2007 VALUES (
	'BIB010050',
	'New American Standard Bible / Study')
go

INSERT INTO temp_sgt_bisaccodes_2007 VALUES (
	'BIB010060',
	'New American Standard Bible / Text')
go

INSERT INTO temp_sgt_bisaccodes_2007 VALUES (
	'BIB010070',
	'New American Standard Bible / Youth & Teen')
go

INSERT INTO temp_sgt_bisaccodes_2007 VALUES (
	'BIB011000',
	'New Century Version / General')
go

INSERT INTO temp_sgt_bisaccodes_2007 VALUES (
	'BIB011010',
	'New Century Version / Children')
go

INSERT INTO temp_sgt_bisaccodes_2007 VALUES (
	'BIB011020',
	'New Century Version / Devotional')
go

INSERT INTO temp_sgt_bisaccodes_2007 VALUES (
	'BIB011030',
	'New Century Version / New Testament & Portions')
go

INSERT INTO temp_sgt_bisaccodes_2007 VALUES (
	'BIB011040',
	'New Century Version / Reference')
go

INSERT INTO temp_sgt_bisaccodes_2007 VALUES (
	'BIB011050',
	'New Century Version / Study')
go

INSERT INTO temp_sgt_bisaccodes_2007 VALUES (
	'BIB011060',
	'New Century Version / Text')
go

INSERT INTO temp_sgt_bisaccodes_2007 VALUES (
	'BIB011070',
	'New Century Version / Youth & Teen')
go

INSERT INTO temp_sgt_bisaccodes_2007 VALUES (
	'BIB012000',
	'New International Reader''s  Version / General')
go

INSERT INTO temp_sgt_bisaccodes_2007 VALUES (
	'BIB012010',
	'New International Reader''s  Version / Children')
go

INSERT INTO temp_sgt_bisaccodes_2007 VALUES (
	'BIB012020',
	'New International Reader''s  Version / Devotional')
go

INSERT INTO temp_sgt_bisaccodes_2007 VALUES (
	'BIB012030',
	'New International Reader''s  Version / New Testament & Portions')
go

INSERT INTO temp_sgt_bisaccodes_2007 VALUES (
	'BIB012040',
	'New International Reader''s  Version / Reference')
go

INSERT INTO temp_sgt_bisaccodes_2007 VALUES (
	'BIB012050',
	'New International Reader''s  Version / Study')
go

INSERT INTO temp_sgt_bisaccodes_2007 VALUES (
	'BIB012060',
	'New International Reader''s  Version / Text')
go

INSERT INTO temp_sgt_bisaccodes_2007 VALUES (
	'BIB012070',
	'New International Reader''s  Version / Youth & Teen')
go

INSERT INTO temp_sgt_bisaccodes_2007 VALUES (
	'BIB013000',
	'New International Version / General')
go

INSERT INTO temp_sgt_bisaccodes_2007 VALUES (
	'BIB013010',
	'New International Version / Children')
go

INSERT INTO temp_sgt_bisaccodes_2007 VALUES (
	'BIB013020',
	'New International Version / Devotional')
go

INSERT INTO temp_sgt_bisaccodes_2007 VALUES (
	'BIB013030',
	'New International Version / New Testament & Portions')
go

INSERT INTO temp_sgt_bisaccodes_2007 VALUES (
	'BIB013040',
	'New International Version / Reference')
go

INSERT INTO temp_sgt_bisaccodes_2007 VALUES (
	'BIB013050',
	'New International Version / Study')
go

INSERT INTO temp_sgt_bisaccodes_2007 VALUES (
	'BIB013060',
	'New International Version / Text')
go

INSERT INTO temp_sgt_bisaccodes_2007 VALUES (
	'BIB013070',
	'New International Version / Youth & Teen')
go

INSERT INTO temp_sgt_bisaccodes_2007 VALUES (
	'BIB014000',
	'New King James Version / General')
go

INSERT INTO temp_sgt_bisaccodes_2007 VALUES (
	'BIB014010',
	'New King James Version / Children')
go

INSERT INTO temp_sgt_bisaccodes_2007 VALUES (
	'BIB014020',
	'New King James Version / Devotional')
go

INSERT INTO temp_sgt_bisaccodes_2007 VALUES (
	'BIB014030',
	'New King James Version / New Testament & Portions')
go

INSERT INTO temp_sgt_bisaccodes_2007 VALUES (
	'BIB014040',
	'New King James Version / Reference')
go

INSERT INTO temp_sgt_bisaccodes_2007 VALUES (
	'BIB014050',
	'New King James Version / Study')
go

INSERT INTO temp_sgt_bisaccodes_2007 VALUES (
	'BIB014060',
	'New King James Version / Text')
go

INSERT INTO temp_sgt_bisaccodes_2007 VALUES (
	'BIB014070',
	'New King James Version / Youth & Teen')
go

/*INSERT INTO temp_sgt_bisaccodes_2007 VALUES (
	'BIB014000',
	'New King James Version / General')
go  */

INSERT INTO temp_sgt_bisaccodes_2007 VALUES (
	'BIB015000',
	'New Living Translation / General')
go

INSERT INTO temp_sgt_bisaccodes_2007 VALUES (
	'BIB015010',
	'New Living Translation / Children')
go

INSERT INTO temp_sgt_bisaccodes_2007 VALUES (
	'BIB015020',
	'New Living Translation / Devotional')
go

INSERT INTO temp_sgt_bisaccodes_2007 VALUES (
	'BIB015030',
	'New Living Translation / New Testament & Portions')
go

INSERT INTO temp_sgt_bisaccodes_2007 VALUES (
	'BIB015040',
	'New Living Translation / Reference')
go

INSERT INTO temp_sgt_bisaccodes_2007 VALUES (
	'BIB015050',
	'New Living Translation / Study')
go

INSERT INTO temp_sgt_bisaccodes_2007 VALUES (
	'BIB015060',
	'New Living Translation / Text')
go

INSERT INTO temp_sgt_bisaccodes_2007 VALUES (
	'BIB015070',
	'New Living Translation / Youth & Teen')
go

INSERT INTO temp_sgt_bisaccodes_2007 VALUES (
	'BIB016000',
	'New Revised Standard Version / General')
go

INSERT INTO temp_sgt_bisaccodes_2007 VALUES (
	'BIB016010',
	'New Revised Standard Version / Children')
go

INSERT INTO temp_sgt_bisaccodes_2007 VALUES (
	'BIB016020',
	'New Revised Standard Version / Devotional')
go

INSERT INTO temp_sgt_bisaccodes_2007 VALUES (
	'BIB016030',
	'New Revised Standard Version / New Testament & Portions')
go

INSERT INTO temp_sgt_bisaccodes_2007 VALUES (
	'BIB016040',
	'New Revised Standard Version / Reference')
go

INSERT INTO temp_sgt_bisaccodes_2007 VALUES (
	'BIB016050',
	'New Revised Standard Version / Study')
go

INSERT INTO temp_sgt_bisaccodes_2007 VALUES (
	'BIB016060',
	'New Revised Standard Version / Text')
go

INSERT INTO temp_sgt_bisaccodes_2007 VALUES (
	'BIB016070',
	'New Revised Standard Version / Youth & Teen')
go

INSERT INTO temp_sgt_bisaccodes_2007 VALUES (
	'BIB017000',
	'Nueva Version International / General')
go

INSERT INTO temp_sgt_bisaccodes_2007 VALUES (
	'BIB017010',
	'Nueva Version International / Children')
go

INSERT INTO temp_sgt_bisaccodes_2007 VALUES (
	'BIB017020',
	'Nueva Version International / Devotional')
go

INSERT INTO temp_sgt_bisaccodes_2007 VALUES (
	'BIB017030',
	'Nueva Version International / New Testament and Portions')
go

INSERT INTO temp_sgt_bisaccodes_2007 VALUES (
	'BIB017040',
	'Nueva Version International / Reference')
go

INSERT INTO temp_sgt_bisaccodes_2007 VALUES (
	'BIB017050',
	'Nueva Version International / Study')
go

INSERT INTO temp_sgt_bisaccodes_2007 VALUES (
	'BIB017060',
	'Nueva Version International / Text')
go

INSERT INTO temp_sgt_bisaccodes_2007 VALUES (
	'BIB017070',
	'Nueva Version International / Youth & Teen')
go

INSERT INTO temp_sgt_bisaccodes_2007 VALUES (
	'BIB018000',
	'Other Translations / General')
go

INSERT INTO temp_sgt_bisaccodes_2007 VALUES (
	'BIB018010',
	'Other Translations / Children')
go

INSERT INTO temp_sgt_bisaccodes_2007 VALUES (
	'BIB018020',
	'Other Translations / Devotional')
go

INSERT INTO temp_sgt_bisaccodes_2007 VALUES (
	'BIB018030',
	'Other Translations / New Testament & Portions')
go

INSERT INTO temp_sgt_bisaccodes_2007 VALUES (
	'BIB018040',
	'Other Translations / Reference')
go

INSERT INTO temp_sgt_bisaccodes_2007 VALUES (
	'BIB018050',
	'Other Translations / Study')
go

INSERT INTO temp_sgt_bisaccodes_2007 VALUES (
	'BIB018060',
	'Other Translations / Text')
go

INSERT INTO temp_sgt_bisaccodes_2007 VALUES (
	'BIB018070',
	'Other Translations / Youth & Teen')
go

INSERT INTO temp_sgt_bisaccodes_2007 VALUES (
	'BIB019000',
	'Reina Valera / General')
go

INSERT INTO temp_sgt_bisaccodes_2007 VALUES (
	'BIB019010',
	'Reina Valera / Children')
go

INSERT INTO temp_sgt_bisaccodes_2007 VALUES (
	'BIB019020',
	'Reina Valera / Devotional')
go

INSERT INTO temp_sgt_bisaccodes_2007 VALUES (
	'BIB019030',
	'Reina Valera / New Testament & Portions')
go

INSERT INTO temp_sgt_bisaccodes_2007 VALUES (
	'BIB019040',
	'Reina Valera / Reference')
go

INSERT INTO temp_sgt_bisaccodes_2007 VALUES (
	'BIB019050',
	'Reina Valera / Study')
go

INSERT INTO temp_sgt_bisaccodes_2007 VALUES (
	'BIB019060',
	'Reina Valera / Text')
go

INSERT INTO temp_sgt_bisaccodes_2007 VALUES (
	'BIB019070',
	'Reina Valera / Youth & Teen')
go

INSERT INTO temp_sgt_bisaccodes_2007 VALUES (
	'BIB020000',
	'The Message / General')
go

INSERT INTO temp_sgt_bisaccodes_2007 VALUES (
	'BIB020010',
	'The Message / Children')
go

INSERT INTO temp_sgt_bisaccodes_2007 VALUES (
	'BIB020020',
	'The Message / Devotional')
go

INSERT INTO temp_sgt_bisaccodes_2007 VALUES (
	'BIB020030',
	'The Message / New Testament & Portions')
go

INSERT INTO temp_sgt_bisaccodes_2007 VALUES (
	'BIB020040',
	'The Message / Reference')
go

INSERT INTO temp_sgt_bisaccodes_2007 VALUES (
	'BIB020050',
	'The Message / Study')
go

INSERT INTO temp_sgt_bisaccodes_2007 VALUES (
	'BIB020060',
	'The Message / Text')
go

INSERT INTO temp_sgt_bisaccodes_2007 VALUES (
	'BIB020070',
	'The Message / Youth & Teen')
go

INSERT INTO temp_sgt_bisaccodes_2007 VALUES (
	'BIB021000',
	'Today''s New International Version / General')
go

INSERT INTO temp_sgt_bisaccodes_2007 VALUES (
	'BIB021010',
	'Today''s New International Version / Children')
go

INSERT INTO temp_sgt_bisaccodes_2007 VALUES (
	'BIB021020',
	'Today''s New International Version / Devotional')
go

INSERT INTO temp_sgt_bisaccodes_2007 VALUES (
	'BIB021030',
	'Today''s New International Version / New Testament & Portions')
go

INSERT INTO temp_sgt_bisaccodes_2007 VALUES (
	'BIB021040',
	'Today''s New International Version / Reference')
go

INSERT INTO temp_sgt_bisaccodes_2007 VALUES (
	'BIB021050',
	'Today''s New International Version / Study')
go

INSERT INTO temp_sgt_bisaccodes_2007 VALUES (
	'BIB021060',
	'Today''s New International Version / Text')
go

INSERT INTO temp_sgt_bisaccodes_2007 VALUES (
	'BIB021070',
	'Today''s New International Version / Youth & Teen')
go

INSERT INTO temp_sgt_bisaccodes_2007 VALUES (
	'BIO02000',
	'Cultural Heritage')
go

INSERT INTO temp_sgt_bisaccodes_2007 VALUES (
	'BUS070090',
	'Industries / Fashion & Textile Industry')
go

INSERT INTO temp_sgt_bisaccodes_2007 VALUES (
	'CGN008000',
	'Contemporary Women')
go

INSERT INTO temp_sgt_bisaccodes_2007 VALUES (
	'CGN004010',
	'Crime & Mystery')
go

INSERT INTO temp_sgt_bisaccodes_2007 VALUES (
	'CGN004020',
	'Erotica')
go

INSERT INTO temp_sgt_bisaccodes_2007 VALUES (
	'CGN004030',
	'Fantasy')
go

INSERT INTO temp_sgt_bisaccodes_2007 VALUES (
	'CGN009000',
	'Gay & Lesbian')
go

INSERT INTO temp_sgt_bisaccodes_2007 VALUES (
	'CGN004040',
	'Horror')
go

INSERT INTO temp_sgt_bisaccodes_2007 VALUES (
	'CGN004050',
	'Manga / General')
go

INSERT INTO temp_sgt_bisaccodes_2007 VALUES (
	'CGN004100',
	'Manga / Crime & Mystery')
go

INSERT INTO temp_sgt_bisaccodes_2007 VALUES (
	'CGN004110',
	'Manga / Erotica')
go

INSERT INTO temp_sgt_bisaccodes_2007 VALUES (
	'CGN004120',
	'Manga / Fantasy')
go

INSERT INTO temp_sgt_bisaccodes_2007 VALUES (
	'CGN004130',
	'Manga / Gay & Lesbian')
go

INSERT INTO temp_sgt_bisaccodes_2007 VALUES (
	'CGN004140',
	'Manga / Historical Fiction')
go

INSERT INTO temp_sgt_bisaccodes_2007 VALUES (
	'CGN004150',
	'Manga / Horror')
go

INSERT INTO temp_sgt_bisaccodes_2007 VALUES (
	'CGN004160',
	'Manga / Media Tie-in')
go 

INSERT INTO temp_sgt_bisaccodes_2007 VALUES (
	'CGN004170',
	'Manga / Nonfiction')
go
 
INSERT INTO temp_sgt_bisaccodes_2007 VALUES (
	'CGN004180',
	'Manga / Romance')
go

INSERT INTO temp_sgt_bisaccodes_2007 VALUES (
	'CGN004190',
	'Manga / Science Fiction')
go

INSERT INTO temp_sgt_bisaccodes_2007 VALUES (
	'CGN004200',
	'Manga / Sports')
go

INSERT INTO temp_sgt_bisaccodes_2007 VALUES (
	'CGN004060',
	'Media Tie-in')
go

INSERT INTO temp_sgt_bisaccodes_2007 VALUES (
	'CGN004090',
	'Romance')
go

INSERT INTO temp_sgt_bisaccodes_2007 VALUES (
	'CGN004070',
	'Science Fiction')
go

INSERT INTO temp_sgt_bisaccodes_2007 VALUES (
	'CGN004080',
	'Superheroes')
go

INSERT INTO temp_sgt_bisaccodes_2007 VALUES (
	'CRA046000',
	'Book Printing & Binding')
go

INSERT INTO temp_sgt_bisaccodes_2007 VALUES (
	'CRA053000',
	'Nature Crafts')
go

INSERT INTO temp_sgt_bisaccodes_2007 VALUES (
	'EDU048000',
	'Inclusive Education')
go

INSERT INTO temp_sgt_bisaccodes_2007 VALUES (
	'FIC042080',
	'Christian / Fantasy')
go 

INSERT INTO temp_sgt_bisaccodes_2007 VALUES (
	'FIC021000',
	'Media Tie-In')
go

INSERT INTO temp_sgt_bisaccodes_2007 VALUES (
	'FIC022060',
	'Mystery & Detective / Historical')
go

INSERT INTO temp_sgt_bisaccodes_2007 VALUES (
	'HIS047000',
	'Africa / South / Republic of South Africa')
go

INSERT INTO temp_sgt_bisaccodes_2007 VALUES (
	'HOM022000',
	'Sustainable Living')
go

INSERT INTO temp_sgt_bisaccodes_2007 VALUES (
	'HUM001000',
	'Form / Comic Strips & Cartoons')
go

INSERT INTO temp_sgt_bisaccodes_2007 VALUES (
	'JUV008030',
	'Comics & Graphics Novels / Media Tie-In')
go

INSERT INTO temp_sgt_bisaccodes_2007 VALUES (
	'JUV009070',
	'Concepts / Date & Time')
go

INSERT INTO temp_sgt_bisaccodes_2007 VALUES (
	'JUV027000',
	'Media Tie-In')
go

INSERT INTO temp_sgt_bisaccodes_2007 VALUES (
	'JNF062000',
	'Comics & Graphic Novels / General')
go

INSERT INTO temp_sgt_bisaccodes_2007 VALUES (
	'JNF062010',
	'Comics & Graphic Novels / Biography')
go

INSERT INTO temp_sgt_bisaccodes_2007 VALUES (
	'JNF062020',
	'Comics & Graphic Novels / History')
go

INSERT INTO temp_sgt_bisaccodes_2007 VALUES (
	'JNF013080',
	'Concepts / Date & Time')
go

INSERT INTO temp_sgt_bisaccodes_2007 VALUES (
	'JNF028010',
	'Humor / Comic Strips & Cartoons')
go

INSERT INTO temp_sgt_bisaccodes_2007 VALUES (
	'LIT004060',
	'Native American')
go

INSERT INTO temp_sgt_bisaccodes_2007 VALUES (
	'PHI034000',
	'Social')
go

INSERT INTO temp_sgt_bisaccodes_2007 VALUES (
	'POE005010',
	'American / General')
go

INSERT INTO temp_sgt_bisaccodes_2007 VALUES (
	'POE005050',
	'American / African American')
go

INSERT INTO temp_sgt_bisaccodes_2007 VALUES (
	'REL046000',
	'Christianity / Church of Jesus Christ of Latter-day Saints (Mormon)')
go

INSERT INTO temp_sgt_bisaccodes_2007 VALUES (
	'REL112000',
	'Gnosticism')
go

INSERT INTO temp_sgt_bisaccodes_2007 VALUES (
	'SOC053000',
	'Regional Studies')
go

INSERT INTO temp_sgt_bisaccodes_2007 VALUES (
	'SOC054000',
	'Slavery')
go

INSERT INTO temp_sgt_bisaccodes_2007 VALUES (
	'SPO068000',
	'Business Aspects')
go

INSERT INTO temp_sgt_bisaccodes_2007 VALUES (
	'TEC000000',
	'General')
go

INSERT INTO temp_sgt_bisaccodes_2007 VALUES (
	'TEC001000',
	'Acoustics & Sound')
go

INSERT INTO temp_sgt_bisaccodes_2007 VALUES (
	'TEC002000',
	'Aeronautics & Astronautics')
go

INSERT INTO temp_sgt_bisaccodes_2007 VALUES (
	'TEC003000',
	'Agriculture / General')
go

INSERT INTO temp_sgt_bisaccodes_2007 VALUES (
	'TEC003080',
	'Agriculture / Agronomy / General')
go

INSERT INTO temp_sgt_bisaccodes_2007 VALUES (
	'TEC003030',
	'Agriculture / Agronomy / Crop Science')
go

INSERT INTO temp_sgt_bisaccodes_2007 VALUES (
	'TEC003060',
	'Agriculture / Agronomy / Soil Science')
go

INSERT INTO temp_sgt_bisaccodes_2007 VALUES (
	'TEC003020',
	'Agriculture / Animal Husbandry')
go

INSERT INTO temp_sgt_bisaccodes_2007 VALUES (
	'TEC003040',
	'Agriculture / Forestry')
go

INSERT INTO temp_sgt_bisaccodes_2007 VALUES (
	'TEC003050',
	'Agriculture / Irrigation')
go

INSERT INTO temp_sgt_bisaccodes_2007 VALUES (
	'TEC003090',
	'Agriculture / Organic')
go

INSERT INTO temp_sgt_bisaccodes_2007 VALUES (
	'TEC003070',
	'Agriculture / Sustainable Agriculture')
go

INSERT INTO temp_sgt_bisaccodes_2007 VALUES (
	'TEC003010',
	'Agriculture / Tropical Agriculture')
go

INSERT INTO temp_sgt_bisaccodes_2007 VALUES (
	'TEC004000',
	'Automation')
go

INSERT INTO temp_sgt_bisaccodes_2007 VALUES (
	'TEC009090',
	'Automotive')
go

INSERT INTO temp_sgt_bisaccodes_2007 VALUES (
	'TEC059000',
	'Biomedical')
go

INSERT INTO temp_sgt_bisaccodes_2007 VALUES (
	'TEC048000',
	'Cartography')
go

INSERT INTO temp_sgt_bisaccodes_2007 VALUES (
	'TEC009010',
	'Chemical & Biochemical')
go

INSERT INTO temp_sgt_bisaccodes_2007 VALUES (
	'TEC009020',
	'Civil / General')
go

INSERT INTO temp_sgt_bisaccodes_2007 VALUES (
	'TEC009100',
	'Civil / Bridges')
go

INSERT INTO temp_sgt_bisaccodes_2007 VALUES (
	'TEC009110',
	'Civil / Dams & Reservoirs')
go

INSERT INTO temp_sgt_bisaccodes_2007 VALUES (
	'TEC009120',
	'Civil / Earthquake')
go

INSERT INTO temp_sgt_bisaccodes_2007 VALUES (
	'TEC009130',
	'Civil / Flood Control')
go

INSERT INTO temp_sgt_bisaccodes_2007 VALUES (
	'TEC009140',
	'Civil / Highway & Traffic')
go

INSERT INTO temp_sgt_bisaccodes_2007 VALUES (
	'TEC009150',
	'Civil / Soil & Rock')
go

INSERT INTO temp_sgt_bisaccodes_2007 VALUES (
	'TEC009160',
	'Civil / Transport')
go

INSERT INTO temp_sgt_bisaccodes_2007 VALUES (
	'TEC005000',
	'Construction / General')
go

INSERT INTO temp_sgt_bisaccodes_2007 VALUES (
	'TEC005010',
	'Construction / Carpentry')
go

INSERT INTO temp_sgt_bisaccodes_2007 VALUES (
	'TEC005020',
	'Construction / Contracting')
go

INSERT INTO temp_sgt_bisaccodes_2007 VALUES (
	'TEC005030',
	'Construction / Electrical')
go

INSERT INTO temp_sgt_bisaccodes_2007 VALUES (
	'TEC005040',
	'Construction / Estimating')
go

INSERT INTO temp_sgt_bisaccodes_2007 VALUES (
	'TEC005050',
	'Construction / Heating, Ventilation & Air Conditioning')
go

INSERT INTO temp_sgt_bisaccodes_2007 VALUES (
	'TEC005060',
	'Construction / Masonry')
go

INSERT INTO temp_sgt_bisaccodes_2007 VALUES (
	'TEC005070',
	'Construction / Plumbing')
go

INSERT INTO temp_sgt_bisaccodes_2007 VALUES (
	'TEC005080',
	'Construction / Roofing')
go

INSERT INTO temp_sgt_bisaccodes_2007 VALUES (
	'TEC006000',
	'Drafting & Mechanical Drawing')
go

INSERT INTO temp_sgt_bisaccodes_2007 VALUES (
	'TEC007000',
	'Electrical')
go

INSERT INTO temp_sgt_bisaccodes_2007 VALUES (
	'TEC008000',
	'Electronics / General')
go

INSERT INTO temp_sgt_bisaccodes_2007 VALUES (
	'TEC008010',
	'Electronics / Circuits / General')
go

INSERT INTO temp_sgt_bisaccodes_2007 VALUES (
	'TEC008020',
	'Electronics / Circuits / Integrated')
go

INSERT INTO temp_sgt_bisaccodes_2007 VALUES (
	'TEC008030',
	'Electronics / Circuits / Logic')
go

INSERT INTO temp_sgt_bisaccodes_2007 VALUES (
	'TEC008050',
	'Electronics / Circuits / VLSI & ULSI')
go

INSERT INTO temp_sgt_bisaccodes_2007 VALUES (
	'TEC008060',
	'Electronics / Digital')
go

INSERT INTO temp_sgt_bisaccodes_2007 VALUES (
	'TEC008070',
	'Electronics / Microelectronics')
go

INSERT INTO temp_sgt_bisaccodes_2007 VALUES (
	'TEC008080',
	'Electronics / Optoelectronics')
go

INSERT INTO temp_sgt_bisaccodes_2007 VALUES (
	'TEC008090',
	'Electronics / Semiconductors')
go

INSERT INTO temp_sgt_bisaccodes_2007 VALUES (
	'TEC008100',
	'Electronics / Solid State')
go
INSERT INTO temp_sgt_bisaccodes_2007 VALUES (
	'TEC008110',
	'Electronics / Transistors')
go

INSERT INTO temp_sgt_bisaccodes_2007 VALUES (
	'TEC009000',
	'Engineering (General)')
go

INSERT INTO temp_sgt_bisaccodes_2007 VALUES (
	'TEC010000',
	'Environmental / General')
go

INSERT INTO temp_sgt_bisaccodes_2007 VALUES (
	'TEC010010',
	'Environmental / Pollution Control')
go

INSERT INTO temp_sgt_bisaccodes_2007 VALUES (
	'TEC010020',
	'Environmental / Waste Management')
go

INSERT INTO temp_sgt_bisaccodes_2007 VALUES (
	'TEC010030',
	'Environmental / Water Supply')
go

INSERT INTO temp_sgt_bisaccodes_2007 VALUES (
	'TEC011000',
	'Fiber Optics')
go

INSERT INTO temp_sgt_bisaccodes_2007 VALUES (
	'TEC045000',
	'Fire Science')
go

INSERT INTO temp_sgt_bisaccodes_2007 VALUES (
	'TEC049000',
	'Fisheries & Aquaculture')
go

INSERT INTO temp_sgt_bisaccodes_2007 VALUES (
	'TEC012000',
	'Food Science')
go

INSERT INTO temp_sgt_bisaccodes_2007 VALUES (
	'TEC013000',
	'Fracture Mechanics')
go

INSERT INTO temp_sgt_bisaccodes_2007 VALUES (
	'TEC056000',
	'History')
go

INSERT INTO temp_sgt_bisaccodes_2007 VALUES (
	'TEC050000',
	'Holography')
go

INSERT INTO temp_sgt_bisaccodes_2007 VALUES (
	'TEC014000',
	'Hydraulics')
go

INSERT INTO temp_sgt_bisaccodes_2007 VALUES (
	'TEC015000',
	'Imaging Systems')
go

INSERT INTO temp_sgt_bisaccodes_2007 VALUES (
	'TEC016000',
	'Industry Design / General')
go

INSERT INTO temp_sgt_bisaccodes_2007 VALUES (
	'TEC016010',
	'Industry Design / Packaging')
go

INSERT INTO temp_sgt_bisaccodes_2007 VALUES (
	'TEC016020',
	'Industry Design / Product')
go

INSERT INTO temp_sgt_bisaccodes_2007 VALUES (
	'TEC009060',
	'Industrial Engineering')
go

INSERT INTO temp_sgt_bisaccodes_2007 VALUES (
	'TEC017000',
	'Industrial Health & Safety')
go

INSERT INTO temp_sgt_bisaccodes_2007 VALUES (
	'TEC018000',
	'Industrial Technology')
go

INSERT INTO temp_sgt_bisaccodes_2007 VALUES (
	'TEC057000',
	'Inventions')
go

INSERT INTO temp_sgt_bisaccodes_2007 VALUES (
	'TEC019000',
	'Lasers & Photonics')
go

INSERT INTO temp_sgt_bisaccodes_2007 VALUES (
	'TEC046000',
	'Machinery')
go

INSERT INTO temp_sgt_bisaccodes_2007 VALUES (
	'TEC020000',
	'Manufacturing')
go

INSERT INTO temp_sgt_bisaccodes_2007 VALUES (
	'TEC060000',
	'Marine & Naval')
go

INSERT INTO temp_sgt_bisaccodes_2007 VALUES (
	'TEC021000',
	'Material Science')
go

INSERT INTO temp_sgt_bisaccodes_2007 VALUES (
	'TEC009070',
	'Mechanical')
go

INSERT INTO temp_sgt_bisaccodes_2007 VALUES (
	'TEC022000',
	'Mensuration')
go

INSERT INTO temp_sgt_bisaccodes_2007 VALUES (
	'TEC023000',
	'Metallurgy')
go

INSERT INTO temp_sgt_bisaccodes_2007 VALUES (
	'TEC024000',
	'Microwaves')
go

INSERT INTO temp_sgt_bisaccodes_2007 VALUES (
	'TEC025000',
	'Military Science')
go

INSERT INTO temp_sgt_bisaccodes_2007 VALUES (
	'TEC026000',
	'Mining')
go

INSERT INTO temp_sgt_bisaccodes_2007 VALUES (
	'TEC061000',
	'Mobile & Wireless Communication')
go

INSERT INTO temp_sgt_bisaccodes_2007 VALUES (
	'TEC027000',
	'Nanotechnology & MEMS')
go

INSERT INTO temp_sgt_bisaccodes_2007 VALUES (
	'TEC029000',
	'Operations Research')
go

INSERT INTO temp_sgt_bisaccodes_2007 VALUES (
	'TEC030000',
	'Optics')
go

INSERT INTO temp_sgt_bisaccodes_2007 VALUES (
	'TEC058000',
	'Pest Control')
go

INSERT INTO temp_sgt_bisaccodes_2007 VALUES (
	'TEC047000',
	'Petroleum')
go

INSERT INTO temp_sgt_bisaccodes_2007 VALUES (
	'TEC031000',
	'Power Resources / General')
go

INSERT INTO temp_sgt_bisaccodes_2007 VALUES (
	'TEC031010',
	'Power Resources/ Alternative & Renewals')
go

INSERT INTO temp_sgt_bisaccodes_2007 VALUES (
	'TEC031020',
	'Power Resources / Electrical')
go

INSERT INTO temp_sgt_bisaccodes_2007 VALUES (
	'TEC031030',
	'Power Resources / Fossil Fuels')
go

INSERT INTO temp_sgt_bisaccodes_2007 VALUES (
	'TEC028000',
	'Power Resources / Nuclear')
go

INSERT INTO temp_sgt_bisaccodes_2007 VALUES (
	'TEC062000',
	'Project Management')
go

INSERT INTO temp_sgt_bisaccodes_2007 VALUES (
	'TEC032000',
	'Quality Control')
go

INSERT INTO temp_sgt_bisaccodes_2007 VALUES (
	'TEC033000',
	'Radar')
go

INSERT INTO temp_sgt_bisaccodes_2007 VALUES (
	'TEC034000',
	'Radio')
go

INSERT INTO temp_sgt_bisaccodes_2007 VALUES (
	'TEC035000',
	'Reference')
go

INSERT INTO temp_sgt_bisaccodes_2007 VALUES (
	'TEC036000',
	'Remote Sensing & Geographic Information Systems')
go

INSERT INTO temp_sgt_bisaccodes_2007 VALUES (
	'TEC037000',
	'Robotics')
go

INSERT INTO temp_sgt_bisaccodes_2007 VALUES (
	'TEC052000',
	'Social Aspects')
go

INSERT INTO temp_sgt_bisaccodes_2007 VALUES (
	'TEC063000',
	'Structural')
go

INSERT INTO temp_sgt_bisaccodes_2007 VALUES (
	'TEC039000',
	'Superconductors & Superconductivity')
go

INSERT INTO temp_sgt_bisaccodes_2007 VALUES (
	'TEC054000',
	'Surveying')
go

INSERT INTO temp_sgt_bisaccodes_2007 VALUES (
	'TEC040000',
	'Technical & Manufacturing Industries & Trades')
go

INSERT INTO temp_sgt_bisaccodes_2007 VALUES (
	'TEC044000',
	'Technical Writing')
go

INSERT INTO temp_sgt_bisaccodes_2007 VALUES (
	'TEC041000',
	'Telecommunications')
go

INSERT INTO temp_sgt_bisaccodes_2007 VALUES (
	'TEC043000',
	'Television & Video')
go

INSERT INTO temp_sgt_bisaccodes_2007 VALUES (
	'TEC055000',
	'Textiles & Polymers')
go

INSERT INTO temp_sgt_bisaccodes_2007 VALUES (
	'TRV002000',
	'Africa / General')
go

INSERT INTO temp_sgt_bisaccodes_2007 VALUES (
	'TRV002010',
	'Africa / Central')
go

INSERT INTO temp_sgt_bisaccodes_2007 VALUES (
	'TRV002020',
	'Africa / East')
go

INSERT INTO temp_sgt_bisaccodes_2007 VALUES (
	'TRV002030',
	'Africa / Kenya')
go

INSERT INTO temp_sgt_bisaccodes_2007 VALUES (
	'TRV002040',
	'Africa / Morocco')
go

INSERT INTO temp_sgt_bisaccodes_2007 VALUES (
	'TRV002050',
	'Africa / North')
go

INSERT INTO temp_sgt_bisaccodes_2007 VALUES (
	'TRV002060',
	'Africa / Republic of South Africa')
go

INSERT INTO temp_sgt_bisaccodes_2007 VALUES (
	'TRV002070',
	'Africa / South')
go

INSERT INTO temp_sgt_bisaccodes_2007 VALUES (
	'TRV002080',
	'Africa / West')
go

INSERT INTO temp_sgt_bisaccodes_2007 VALUES (
	'TRV029000',
	'Amusement & Theme Parks')
go

INSERT INTO temp_sgt_bisaccodes_2007 VALUES (
	'TRV013000',
	'Hotels, Inns & Hostels')
go

INSERT INTO temp_sgt_bisaccodes_2007 VALUES (
	'TRV030000',
	'Resorts & Spas')
go

INSERT INTO temp_sgt_bisaccodes_2007 VALUES (
	'TRV031000',
	'Road Travel')
go

INSERT INTO temp_sgt_bisaccodes_2007 VALUES (
	'TRV032000',
	'Shopping')
go

INSERT INTO temp_sgt_bisaccodes_2007 VALUES (
	'TRV024000',
	'South America / General')
go

INSERT INTO temp_sgt_bisaccodes_2007 VALUES (
	'TRV024010',
	'South America / Argentina')
go

INSERT INTO temp_sgt_bisaccodes_2007 VALUES (
	'TRV024020',
	'South America / Brazil')
go

INSERT INTO temp_sgt_bisaccodes_2007 VALUES (
	'TRV024030',
	'South America / Chile & Easter Island')
go

INSERT INTO temp_sgt_bisaccodes_2007 VALUES (
	'TRV024040',
	'South America / Ecuador & Galapagos Islands')
go

INSERT INTO temp_sgt_bisaccodes_2007 VALUES (
	'TRV024050',
	'South America / Peru')
go

INSERT INTO temp_sgt_bisaccodes_2007 VALUES (
	'TRV026070',
	'Special Interest / Gay & Lesbian')
go

INSERT INTO temp_sgt_bisaccodes_2007 VALUES (
	'TRV026080',
	'Special Interest / Sports')
go