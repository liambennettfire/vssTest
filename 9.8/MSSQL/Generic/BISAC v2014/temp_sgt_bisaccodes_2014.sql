IF EXISTS (SELECT * FROM dbo.sysobjects WHERE id = Object_id('temp_sgt_bisaccodes_2014') AND type = 'U')
  BEGIN
    DROP table temp_sgt_bisaccodes_2014
  END
go

CREATE TABLE temp_sgt_bisaccodes_2014 (
	Code char(255),
	Literal char(255))
go

--Added
INSERT INTO temp_sgt_bisaccodes_2014 VALUES (
	'ART050060',
	'Subjects & Themes / Science Fiction & Fantasy')
	
--Added
INSERT INTO temp_sgt_bisaccodes_2014 VALUES (
	'BIB023000',
	'The Amplified Bible / General')
	
--Added
INSERT INTO temp_sgt_bisaccodes_2014 VALUES (
	'BIB023010',
	'The Amplified Bible / Children')
	
--Added
INSERT INTO temp_sgt_bisaccodes_2014 VALUES (
	'BIB023020',
	'The Amplified Bible / Devotional')
	
--Added
INSERT INTO temp_sgt_bisaccodes_2014 VALUES (
	'BIB023030',
	'The Amplified Bible / New Testament & Portions')
	
--Added
INSERT INTO temp_sgt_bisaccodes_2014 VALUES (
	'BIB023040',
	'The Amplified Bible / Reference')
	
--Added
INSERT INTO temp_sgt_bisaccodes_2014 VALUES (
	'BIB023050',
	'The Amplified Bible / Study')
	
--Added
INSERT INTO temp_sgt_bisaccodes_2014 VALUES (
	'BIB023060',
	'The Amplified Bible / Text')
	
--Added
INSERT INTO temp_sgt_bisaccodes_2014 VALUES (
	'BIB023070',
	'The Amplified Bible / Youth & Teen')
	
--Added
INSERT INTO temp_sgt_bisaccodes_2014 VALUES (
	'BUS112000',
	'Islamic Banking & Finance')
	
--Added
INSERT INTO temp_sgt_bisaccodes_2014 VALUES (
	'CGN013000',
	'Dystopian')
	
--Added
INSERT INTO temp_sgt_bisaccodes_2014 VALUES (
	'CGN004230',
	'Manga / Dystopian')
	
--Changed
INSERT INTO temp_sgt_bisaccodes_2014 VALUES (
	'CGN004110',
	'Manga / Erotica & Hentai')
	
--Added
INSERT INTO temp_sgt_bisaccodes_2014 VALUES (
	'COM091000',
	'Cloud Computing')
	
--Added
INSERT INTO temp_sgt_bisaccodes_2014 VALUES (
	'CKB118000',
	'Beverages / Juices & Smoothies')
	
--Added
INSERT INTO temp_sgt_bisaccodes_2014 VALUES (
	'CKB119000',
	'Cooking for Kids')
	
--Added
INSERT INTO temp_sgt_bisaccodes_2014 VALUES (
	'CKB120000',
	'Cooking with Kids')
	
--Changed
INSERT INTO temp_sgt_bisaccodes_2014 VALUES (
	'CKB012000',
	'Courses & Dishes / Brunch & Tea Time')
	
--Added
INSERT INTO temp_sgt_bisaccodes_2014 VALUES (
	'CKB121000',
	'Courses & Dishes / Sandwiches')
	
--Added
INSERT INTO temp_sgt_bisaccodes_2014 VALUES (
	'CRA060000',
	'Felting')
	
--Added
INSERT INTO temp_sgt_bisaccodes_2014 VALUES (
	'CRA061000',
	'Fiber Arts & Textiles')
	
--Changed
INSERT INTO temp_sgt_bisaccodes_2014 VALUES (
	'EDU041000',
	'Distance, Open & Online Education')
	
--Changed
INSERT INTO temp_sgt_bisaccodes_2014 VALUES (
	'EDU040000',
	'Philosophy, Theory & Social Aspects')
	
--Changed
INSERT INTO temp_sgt_bisaccodes_2014 VALUES (
	'EDU026050',
	'Special Education / Behavioral, Emotional & Social Disabilities')
	
--Changed
INSERT INTO temp_sgt_bisaccodes_2014 VALUES (
	'EDU026030',
	'Special Education / Developmental & Intellectual Disabilities')
	
--Added
INSERT INTO temp_sgt_bisaccodes_2014 VALUES (
	'EDU058000',
	'Standards (incl. Common Core)')
	
--Added
INSERT INTO temp_sgt_bisaccodes_2014 VALUES (
	'EDU059000',
	'Teacher & Student Mentoring')
	
--Changed
INSERT INTO temp_sgt_bisaccodes_2014 VALUES (
	'FIC005000',
	'Erotica / General')
	
--Added
INSERT INTO temp_sgt_bisaccodes_2014 VALUES (
	'FIC005010',
	'Erotica / BDSM')
	
--Added
INSERT INTO temp_sgt_bisaccodes_2014 VALUES (
	'FIC005020',
	'Erotica / Collections & Anthologies')
	
--Added
INSERT INTO temp_sgt_bisaccodes_2014 VALUES (
	'FIC005030',
	'Erotica / Gay')
	
--Added
INSERT INTO temp_sgt_bisaccodes_2014 VALUES (
	'FIC005040',
	'Erotica / Lesbian')
	
--Added
INSERT INTO temp_sgt_bisaccodes_2014 VALUES (
	'FIC005050',
	'Erotica / Science Fiction, Fantasy & Horror')
	
--Added
INSERT INTO temp_sgt_bisaccodes_2014 VALUES (
	'FIC005060',
	'Erotica / Traditional Victorian')
	
--Added
INSERT INTO temp_sgt_bisaccodes_2014 VALUES (
	'FIC009080',
	'Fantasy / Humorous')
	
--Added
INSERT INTO temp_sgt_bisaccodes_2014 VALUES (
	'FIC022100',
	'Mystery & Detective / Amateur Sleuth')
	
--Changed
INSERT INTO temp_sgt_bisaccodes_2014 VALUES (
	'FIC022030',
	'Mystery & Detective / Traditional')
	
--Added
INSERT INTO temp_sgt_bisaccodes_2014 VALUES (
	'FIC027260',
	'Romance / Action & Adventure')
	
--Added
INSERT INTO temp_sgt_bisaccodes_2014 VALUES (
	'FIC027270',
	'Romance / Clean & Wholesome')
	
--Added
INSERT INTO temp_sgt_bisaccodes_2014 VALUES (
	'FIC031080',
	'Thrillers / Psychological')
	
--Changed
INSERT INTO temp_sgt_bisaccodes_2014 VALUES (
	'GAM001000',
	'Board Games')
	
--Added
INSERT INTO temp_sgt_bisaccodes_2014 VALUES (
	'GAR029000',
	'Water Gardens')
	
	
--Added
INSERT INTO temp_sgt_bisaccodes_2014 VALUES (
	'HEA049000',
	'Longevity')
	
--Added
INSERT INTO temp_sgt_bisaccodes_2014 VALUES (
	'HIS056000',
	'African American')
	
--Added
INSERT INTO temp_sgt_bisaccodes_2014 VALUES (
	'HIS057000',
	'Maritime History & Piracy')
	
--Added
INSERT INTO temp_sgt_bisaccodes_2014 VALUES (
	'HIS027200',
	'Military / Napoleonic Wars')
	
--Added
INSERT INTO temp_sgt_bisaccodes_2014 VALUES (
	'HIS027210',
	'Military / War of 1812')
	
--Added
INSERT INTO temp_sgt_bisaccodes_2014 VALUES (
	'HIS058000',
	'Women')


--Added
INSERT INTO temp_sgt_bisaccodes_2014 VALUES (
	'JUV012050',
	'Legends, Myths, Fables / African')
	
--Added
INSERT INTO temp_sgt_bisaccodes_2014 VALUES (
	'JUV012060',
	'Legends, Myths, Fables / Asian')
	
--Added
INSERT INTO temp_sgt_bisaccodes_2014 VALUES (
	'JUV012070',
	'Legends, Myths, Fables / Caribbean & Latin American')
	
--Added
INSERT INTO temp_sgt_bisaccodes_2014 VALUES (
	'JUV012080',
	'Legends, Myths, Fables / Native American')
	
--Added
INSERT INTO temp_sgt_bisaccodes_2014 VALUES (
	'JUV065000',
	'Light Novel (Ranobe)')
	
--Added
INSERT INTO temp_sgt_bisaccodes_2014 VALUES (
	'JUV066000',
	'Mermaids')
	
--Added
INSERT INTO temp_sgt_bisaccodes_2014 VALUES (
	'JUV067000',
	'Thrillers & Suspense')
	
--Added
INSERT INTO temp_sgt_bisaccodes_2014 VALUES (
	'JUV068000',
	'Travel')

--Added
INSERT INTO temp_sgt_bisaccodes_2014 VALUES (
	'JNF066000',
	'Pirates')
	
--Added
INSERT INTO temp_sgt_bisaccodes_2014 VALUES (
	'LIT023000',
	'American / Regional')
	
--Changed
INSERT INTO temp_sgt_bisaccodes_2014 VALUES (
	'LIT009000',
	'Children''s & Young Adult Literature')
	
--Added
INSERT INTO temp_sgt_bisaccodes_2014 VALUES (
	'LIT024000',
	'Modern / General')
	
--Added
INSERT INTO temp_sgt_bisaccodes_2014 VALUES (
	'LIT024010',
	'Modern / 16th Century')
	
--Added
INSERT INTO temp_sgt_bisaccodes_2014 VALUES (
	'LIT024020',
	'Modern / 17th Century')
	
--Added
INSERT INTO temp_sgt_bisaccodes_2014 VALUES (
	'LIT024030',
	'Modern / 18th Century')
	
--Added
INSERT INTO temp_sgt_bisaccodes_2014 VALUES (
	'LIT024040',
	'Modern / 19th Century')
	
--Added
INSERT INTO temp_sgt_bisaccodes_2014 VALUES (
	'LIT024050',
	'Modern / 20th Century')
	
--Added
INSERT INTO temp_sgt_bisaccodes_2014 VALUES (
	'LIT024060',
	'Modern / 21st Century')
	
--Added
INSERT INTO temp_sgt_bisaccodes_2014 VALUES (
	'LIT025000',
	'Subjects & Themes / General')
	
--Added
INSERT INTO temp_sgt_bisaccodes_2014 VALUES (
	'LIT025010',
	'Subjects & Themes / Historical Events')
	
--Added
INSERT INTO temp_sgt_bisaccodes_2014 VALUES (
	'LIT025020',
	'Subjects & Themes / Nature')
	
--Added
INSERT INTO temp_sgt_bisaccodes_2014 VALUES (
	'LIT025030',
	'Subjects & Themes / Politics')
	
--Added
INSERT INTO temp_sgt_bisaccodes_2014 VALUES (
	'LIT025040',
	'Subjects & Themes / Religion')
	
--Added
INSERT INTO temp_sgt_bisaccodes_2014 VALUES (
	'LIT025050',
	'Subjects & Themes / Women')
	
--Changed
INSERT INTO temp_sgt_bisaccodes_2014 VALUES (
	'MED003070',
	'Allied Health Services / Imaging Technologies')
	
--Changed
INSERT INTO temp_sgt_bisaccodes_2014 VALUES (
	'MED019000',
	'Diagnostic Imaging / General')
	
--Added
INSERT INTO temp_sgt_bisaccodes_2014 VALUES (
	'MED019010',
	'Diagnostic Imaging / Radiography')

--Changed
INSERT INTO temp_sgt_bisaccodes_2014 VALUES (
	'MED098000',
	'Diagnostic Imaging / Ultrasonography')
	
--Changed
INSERT INTO temp_sgt_bisaccodes_2014 VALUES (
	'MED080000',
	'Radiology, Radiotherapy & Nuclear Medicine')
	
--Added
INSERT INTO temp_sgt_bisaccodes_2014 VALUES (
	'PHI045000',
	'Movements / Transcendentalism')
	
--Changed
INSERT INTO temp_sgt_bisaccodes_2014 VALUES (
	'POE023020',
	'Subjects & Themes / Love & Erotica')
	
--Added
INSERT INTO temp_sgt_bisaccodes_2014 VALUES (
	'POL064000',
	'Corruption & Misconduct')
	
--Added
INSERT INTO temp_sgt_bisaccodes_2014 VALUES (
	'POL042050',
	'Political Ideologies / Libertarianism')
	
--Changed
INSERT INTO temp_sgt_bisaccodes_2014 VALUES (
	'POL008000',
	'Political Process / Campaigns & Elections')
	
--Added
INSERT INTO temp_sgt_bisaccodes_2014 VALUES (
	'POL065000',
	'Political Process / Media & Internet')
	
--Added
INSERT INTO temp_sgt_bisaccodes_2014 VALUES (
	'POL066000',
	'Privacy & Surveillance (see also SOCIAL SCIENCE / Privacy & Surveillance)')
	
--Added
INSERT INTO temp_sgt_bisaccodes_2014 VALUES (
	'POL067000',
	'Public Policy / Agriculture & Food Policy (see also SOCIAL SCIENCE / Agriculture & Food)')
	
--Changed
INSERT INTO temp_sgt_bisaccodes_2014 VALUES (
	'SCI059000',
	'Radiography')
	
--Added
INSERT INTO temp_sgt_bisaccodes_2014 VALUES (
	'SEL045000',
	'Journaling')
	
--Changed
INSERT INTO temp_sgt_bisaccodes_2014 VALUES (
	'SOC055000',
	'Agriculture & Food (see also POLITICAL SCIENCE / Public Policy / Agriculture & Food Policy)')
	
--Added
INSERT INTO temp_sgt_bisaccodes_2014 VALUES (
	'SOC063000',
	'Privacy & Surveillance (see also POLITICAL SCIENCE / Privacy & Surveillance)')
	
--Added
INSERT INTO temp_sgt_bisaccodes_2014 VALUES (
	'SPO076000',
	'Disability Sports')
	
--Changed
INSERT INTO temp_sgt_bisaccodes_2014 VALUES (
	'SPO058000',
	'Olympics & Paralympics')
	
--Changed
INSERT INTO temp_sgt_bisaccodes_2014 VALUES (
	'TRV006010',
	'Canada / Atlantic Provinces (NB, NL, NS, PE)')
	
--Added
INSERT INTO temp_sgt_bisaccodes_2014 VALUES (
	'TRV036000',
	'Food, Lodging & Transportation / General')
	
--Changed
INSERT INTO temp_sgt_bisaccodes_2014 VALUES (
	'TRV005000',
	'Food, Lodging & Transportation / Bed & Breakfast')
	
--Changed
INSERT INTO temp_sgt_bisaccodes_2014 VALUES (
	'TRV028000',
	'Food, Lodging & Transportation / Cruises')
	
--Changed
INSERT INTO temp_sgt_bisaccodes_2014 VALUES (
	'TRV013000',
	'Food, Lodging & Transportation / Hotels, Inns & Hostels')
	
--Changed
INSERT INTO temp_sgt_bisaccodes_2014 VALUES (
	'TRV035000',
	'Food, Lodging & Transportation / Rail Travel')
	
--Changed
INSERT INTO temp_sgt_bisaccodes_2014 VALUES (
	'TRV030000',
	'Food, Lodging & Transportation / Resorts & Spas')
	
--Changed
INSERT INTO temp_sgt_bisaccodes_2014 VALUES (
	'TRV022000',
	'Food, Lodging & Transportation / Restaurants')
	

--Changed
INSERT INTO temp_sgt_bisaccodes_2014 VALUES (
	'TRV031000',
	'Food, Lodging & Transportation / Road Travel')
	
--Changed
INSERT INTO temp_sgt_bisaccodes_2014 VALUES (
	'TRV029000',
	'Special Interest / Amusement & Theme Parks')
	
--Added
INSERT INTO temp_sgt_bisaccodes_2014 VALUES (
	'TRV026100',
	'Special Interest / Bicycling')
	
--Changed
INSERT INTO temp_sgt_bisaccodes_2014 VALUES (
	'TRV033000',
	'Special Interest / Budget')
	
--Changed
INSERT INTO temp_sgt_bisaccodes_2014 VALUES (
	'TRV034000',
	'Special Interest / Hikes & Walks')
	
--Added
INSERT INTO temp_sgt_bisaccodes_2014 VALUES (
	'TRV026110',
	'Special Interest / Military')
	
--Changed
INSERT INTO temp_sgt_bisaccodes_2014 VALUES (
	'TRV032000',
	'Special Interest / Shopping')
go