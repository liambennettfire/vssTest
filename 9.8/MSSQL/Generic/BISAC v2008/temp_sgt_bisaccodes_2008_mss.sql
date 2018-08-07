IF EXISTS (SELECT * FROM dbo.sysobjects WHERE id = Object_id('temp_sgt_bisaccodes_2008') AND type = 'U')
  BEGIN
    DROP table temp_sgt_bisaccodes_2008
  END
go


CREATE TABLE temp_sgt_bisaccodes_2008  (
	Code char(255),
	Literal char(255))   
go

/*INSERT INTO temp_sgt_bisaccodes_2008 VALUES (
	'ANT000000',
	'General')
go*/

INSERT INTO temp_sgt_bisaccodes_2008 VALUES (
	'ARC022000',
	'Adaptive Reuse & Renovation')
go

INSERT INTO temp_sgt_bisaccodes_2008 VALUES (
	'ARC023000',
	'Annuals')
go

INSERT INTO temp_sgt_bisaccodes_2008 VALUES (
	'ARC024000',
	'Buildings / General')
go

INSERT INTO temp_sgt_bisaccodes_2008 VALUES (
	'ARC024010',
	'Buildings / Landmarks & Monuments')
go

INSERT INTO temp_sgt_bisaccodes_2008 VALUES (
	'ARC011000',
	'Buildings / Public, Commercial & Industrial')
go

INSERT INTO temp_sgt_bisaccodes_2008 VALUES (
	'ARC016000',
	'Buildings / Religious')
go

INSERT INTO temp_sgt_bisaccodes_2008 VALUES (
	'ARC003000',
	'Buildings / Residential')
go


INSERT INTO temp_sgt_bisaccodes_2008 VALUES (
	'ARC014000',
	'Historic Preservation / General')
go

INSERT INTO temp_sgt_bisaccodes_2008 VALUES (
	'ARC014010',
	'Historic Preservation / Restoration Techniques')
go

INSERT INTO temp_sgt_bisaccodes_2008 VALUES (
	'ARC006000',
	'Individual Architects & Firms / General')
go

INSERT INTO temp_sgt_bisaccodes_2008 VALUES (
	'ARC006010',
	'Individual Architects & Firms / Essays')
go

INSERT INTO temp_sgt_bisaccodes_2008 VALUES (
	'ARC006020',
	'Individual Architects & Firms / Monographs')
go

INSERT INTO temp_sgt_bisaccodes_2008 VALUES (
	'ARC018000',
	'Sustainability & Green Design')
go

INSERT INTO temp_sgt_bisaccodes_2008 VALUES (
	'ART054000',
	'Annuals')
go

INSERT INTO temp_sgt_bisaccodes_2008 VALUES (
	'ART055000',
	'Body Art & Tattooing')
go

INSERT INTO temp_sgt_bisaccodes_2008 VALUES (
	'ART006000',
	'Collections, Catalogs, Exhibitions / General')
go

INSERT INTO temp_sgt_bisaccodes_2008 VALUES (
	'ART006010',
	'Collections, Catalogs, Exhibitions / Group Shows')
go

INSERT INTO temp_sgt_bisaccodes_2008 VALUES (
	'ART006020',
	'Collections, Catalogs, Exhibitions / Permanent Collections')
go

INSERT INTO temp_sgt_bisaccodes_2008 VALUES (
	'ART056000',
	'Conservation & Preservation')
go

INSERT INTO temp_sgt_bisaccodes_2008 VALUES (
	'ART009000',
	'Criticism & Theory')
go

INSERT INTO temp_sgt_bisaccodes_2008 VALUES (
	'ART046000',
	'Digital')
go

--INSERT INTO temp_sgt_bisaccodes_2008 VALUES (
--	'ART011000',
--	'Fashion')
--go

INSERT INTO temp_sgt_bisaccodes_2008 VALUES (
	'ART057000',
	'Film & Video')
go

INSERT INTO temp_sgt_bisaccodes_2008 VALUES (
	'ART058000',
	'Graffiti & Street Art')
go

INSERT INTO temp_sgt_bisaccodes_2008 VALUES (
	'ART016000',
	'Individual Artists / General')
go

INSERT INTO temp_sgt_bisaccodes_2008 VALUES (
	'ART016010',
	'Individual Artists / Artists'' Books')
go

INSERT INTO temp_sgt_bisaccodes_2008 VALUES (
	'ART016020',
	'Individual Artists / Essays')
go

INSERT INTO temp_sgt_bisaccodes_2008 VALUES (
	'ART016030',
	'Individual Artists / Monographs')
go

INSERT INTO temp_sgt_bisaccodes_2008 VALUES (
	'ART017000',
	'Mixed-Media')
go

INSERT INTO temp_sgt_bisaccodes_2008 VALUES (
	'ART059000',
	'Museum Studies')
go

INSERT INTO temp_sgt_bisaccodes_2008 VALUES (
	'ART060000',
	'Performance')
go

INSERT INTO temp_sgt_bisaccodes_2008 VALUES (
	'ART026000',
	'Sculpture & Installation')
go

INSERT INTO temp_sgt_bisaccodes_2008 VALUES (
	'ART050050',
	'Subjects & Themes / Erotica')
go


INSERT INTO temp_sgt_bisaccodes_2008 VALUES (
	'BUS018000',
	'Customer Relations')
go

INSERT INTO temp_sgt_bisaccodes_2008 VALUES (
	'BUS102000',
	'Outsourcing')
go

INSERT INTO temp_sgt_bisaccodes_2008 VALUES (
	'COM012000',
	'Computer Graphics')
go

INSERT INTO temp_sgt_bisaccodes_2008 VALUES (
	'COM086000',
	'Computerized Home & Entertainment')
go

INSERT INTO temp_sgt_bisaccodes_2008 VALUES (
	'COM018000',
	'Data Processing')
go

INSERT INTO temp_sgt_bisaccodes_2008 VALUES (
	'COM081000',
	'Desktop Applications / Project Management Software')
go

INSERT INTO temp_sgt_bisaccodes_2008 VALUES (
	'COM084030',
	'Desktop Applications / Suites')
go

INSERT INTO temp_sgt_bisaccodes_2008 VALUES (
	'COM087000',
	'Digital Media / General')
go

INSERT INTO temp_sgt_bisaccodes_2008 VALUES (
	'COM087010',
	'Digital Media / Audio')
go

INSERT INTO temp_sgt_bisaccodes_2008 VALUES (
	'COM022000',
	'Digital Media / Desktop Publishing')
go

INSERT INTO temp_sgt_bisaccodes_2008 VALUES (
	'COM087020',
	'Digital Media / Graphics Applications')
go

INSERT INTO temp_sgt_bisaccodes_2008 VALUES (
	'COM087030',
	'Digital Media / Photography (see also PHOTOGRAPY / Techniques / Digital)')
go

INSERT INTO temp_sgt_bisaccodes_2008 VALUES (
	'COM071000',
	'Digital Media / Video & Animation')
go

INSERT INTO temp_sgt_bisaccodes_2008 VALUES (
	'COM005000',
	'Enterprise Applications / General')
go

INSERT INTO temp_sgt_bisaccodes_2008 VALUES (
	'COM005030',
	'Enterprise Applications / Business Intelligence Tools')
go

INSERT INTO temp_sgt_bisaccodes_2008 VALUES (
	'COM066000',
	'Enterprise Applications / Collaboration Software')
go

INSERT INTO temp_sgt_bisaccodes_2008 VALUES (
	'COM074000',
	'Hardware / Handheld Devices')
go

INSERT INTO temp_sgt_bisaccodes_2008 VALUES (
	'COM012050',
	'Image Processing')
go

INSERT INTO temp_sgt_bisaccodes_2008 VALUES (
	'COM004000',
	'Intelligence (Al) & Semantics')
go

INSERT INTO temp_sgt_bisaccodes_2008 VALUES (
	'COM043060',
	'Networking / Vendor Specific')
go

INSERT INTO temp_sgt_bisaccodes_2008 VALUES (
	'COM046090',
	'Operating Systems / Virtualization')
go

INSERT INTO temp_sgt_bisaccodes_2008 VALUES (
	'COM047000',
	'Optical Data Processing')
go

INSERT INTO temp_sgt_bisaccodes_2008 VALUES (
	'COM051370',
	'Programming / Apple Programming')
go

INSERT INTO temp_sgt_bisaccodes_2008 VALUES (
	'COM012040',
	'Programming / Games')
go

INSERT INTO temp_sgt_bisaccodes_2008 VALUES (
	'COM051380',
	'Programming / Microsoft Programming')
go

INSERT INTO temp_sgt_bisaccodes_2008 VALUES (
	'COM051390',
	'Programming / Open Source')
go

INSERT INTO temp_sgt_bisaccodes_2008 VALUES (
	'COM051260',
	'Programming Languages / Java Script')
go

INSERT INTO temp_sgt_bisaccodes_2008 VALUES (
	'COM051400',
	'Programming Languages / PHP')
go

INSERT INTO temp_sgt_bisaccodes_2008 VALUES (
	'COM051410',
	'Programming Languages / Ruby')
go

INSERT INTO temp_sgt_bisaccodes_2008 VALUES (
	'COM051420',
	'Programming Languages / VBScript')
go

INSERT INTO temp_sgt_bisaccodes_2008 VALUES (
	'COM083000',
	'Security / Cryptography')
go

INSERT INTO temp_sgt_bisaccodes_2008 VALUES (
	'COM051230',
	'Software Development & Engineering / General')
go

INSERT INTO temp_sgt_bisaccodes_2008 VALUES (
	'COM051430',
	'Software Development & Engineering / Project Management')
go

INSERT INTO temp_sgt_bisaccodes_2008 VALUES (
	'COM051330',
	'Software Development & Engineering / Quality Assurance & Testing')
go

INSERT INTO temp_sgt_bisaccodes_2008 VALUES (
	'COM051240',
	'Software Development & Engineering / Systems Analysis & Design')
go

INSERT INTO temp_sgt_bisaccodes_2008 VALUES (
	'COM051440',
	'Software Development & Engineering / Tools')
go

INSERT INTO temp_sgt_bisaccodes_2008 VALUES (
	'COM073000',
	'Speech & Audio Processing')
go

INSERT INTO temp_sgt_bisaccodes_2008 VALUES (
	'COM088000',
	'System Administration / General')
go

INSERT INTO temp_sgt_bisaccodes_2008 VALUES (
	'COM019000',
	'System Administration / Disaster & Recovery')
go

INSERT INTO temp_sgt_bisaccodes_2008 VALUES (
	'COM020020',
	'System Administration / Email Adminstration')
go

INSERT INTO temp_sgt_bisaccodes_2008 VALUES (
	'COM088010',
	'System Administration / Linux & Unix Adminstration')
go

INSERT INTO temp_sgt_bisaccodes_2008 VALUES (
	'COM030000',
	'System Administration / Storage & Retrieval')
go

INSERT INTO temp_sgt_bisaccodes_2008 VALUES (
	'COM088020',
	'System Administration / Windows Adminstration')
go

INSERT INTO temp_sgt_bisaccodes_2008 VALUES (
	'COM011000',
	'Systems Architecture / General')
go

INSERT INTO temp_sgt_bisaccodes_2008 VALUES (
	'COM048000',
	'Systems Architecture / Distributed Systems & Computing')
go

INSERT INTO temp_sgt_bisaccodes_2008 VALUES (
	'COM057000',
	'Virtual Worlds')
go

INSERT INTO temp_sgt_bisaccodes_2008 VALUES (
	'COM060080',
	'Web / General')
go

INSERT INTO temp_sgt_bisaccodes_2008 VALUES (
	'COM060100',
	'Web / Blogs')
go

INSERT INTO temp_sgt_bisaccodes_2008 VALUES (
	'COM060010',
	'Web / Browsers')
go

INSERT INTO temp_sgt_bisaccodes_2008 VALUES (
	'COM060060',
	'Web / Page Design')
go

INSERT INTO temp_sgt_bisaccodes_2008 VALUES (
	'COM060110',
	'Web / Podcasting & Webcasting')
go

INSERT INTO temp_sgt_bisaccodes_2008 VALUES (
	'COM060120',
	'Web / Search Engines')
go

INSERT INTO temp_sgt_bisaccodes_2008 VALUES (
	'COM060130',
	'Web / Site Design')
go

INSERT INTO temp_sgt_bisaccodes_2008 VALUES (
	'COM060070',
	'Web / Site Directories')
go

INSERT INTO temp_sgt_bisaccodes_2008 VALUES (
	'COM060140',
	'Web / Social Networking')
go

INSERT INTO temp_sgt_bisaccodes_2008 VALUES (
	'COM060150',
	'Web / User Generated Content')
go

INSERT INTO temp_sgt_bisaccodes_2008 VALUES (
	'COM060160',
	'Web / Web Programming')
go

INSERT INTO temp_sgt_bisaccodes_2008 VALUES (
	'CKB107000',
	'Baby Food')
go

INSERT INTO temp_sgt_bisaccodes_2008 VALUES (
	'CKB044000',
	'Regional & Ethnic / Indian & South Asian')
go

INSERT INTO temp_sgt_bisaccodes_2008 VALUES (
	'CKB086000',
	'Vegetarian & Vegan')
go

INSERT INTO temp_sgt_bisaccodes_2008 VALUES (
	'DES000000',
	'General')
go

INSERT INTO temp_sgt_bisaccodes_2008 VALUES (
	'DES001000',
	'Book')
go

INSERT INTO temp_sgt_bisaccodes_2008 VALUES (
	'DES002000',
	'Clip Art')
go

INSERT INTO temp_sgt_bisaccodes_2008 VALUES (
	'DES003000',
	'Decorative Arts')
go

INSERT INTO temp_sgt_bisaccodes_2008 VALUES (
	'DES004000',
	'Essays')
go

INSERT INTO temp_sgt_bisaccodes_2008 VALUES (
	'DES005000',
	'Fashion')
go

INSERT INTO temp_sgt_bisaccodes_2008 VALUES (
	'DES006000',
	'Furniture')
go

INSERT INTO temp_sgt_bisaccodes_2008 VALUES (
	'DES007000',
	'Graphic Arts / General')
go

INSERT INTO temp_sgt_bisaccodes_2008 VALUES (
	'DES007010',
	'Graphic Arts / Advertising')
go

INSERT INTO temp_sgt_bisaccodes_2008 VALUES (
	'DES007020',
	'Graphic Arts / Branding & Logo Design')
go

INSERT INTO temp_sgt_bisaccodes_2008 VALUES (
	'DES007030',
	'Graphic Arts / Commercial & Corporate')
go

INSERT INTO temp_sgt_bisaccodes_2008 VALUES (
	'DES007040',
	'Graphic Arts / Illustration')
go

INSERT INTO temp_sgt_bisaccodes_2008 VALUES (
	'DES007050',
	'Graphic Arts / Typography')
go

INSERT INTO temp_sgt_bisaccodes_2008 VALUES (
	'DES008000',
	'History & Criticism')
go

INSERT INTO temp_sgt_bisaccodes_2008 VALUES (
	'DES009000',
	'Industrial')
go

INSERT INTO temp_sgt_bisaccodes_2008 VALUES (
	'DES010000',
	'Interior Decorating')
go

INSERT INTO temp_sgt_bisaccodes_2008 VALUES (
	'DES011000',
	'Product')
go

INSERT INTO temp_sgt_bisaccodes_2008 VALUES (
	'DES012000',
	'Reference')
go

INSERT INTO temp_sgt_bisaccodes_2008 VALUES (
	'DES013000',
	'Textile & Costume')
go

INSERT INTO temp_sgt_bisaccodes_2008 VALUES (
	'FAM004000',
	'Adoption & Fostering')
go

INSERT INTO temp_sgt_bisaccodes_2008 VALUES (
	'FIC049000',
	'African American / General')
go 

INSERT INTO temp_sgt_bisaccodes_2008 VALUES (
	'FIC049010',
	'African American / Christian')
go

INSERT INTO temp_sgt_bisaccodes_2008 VALUES (
	'FIC049020',
	'African American / Contemporary Women')
go

INSERT INTO temp_sgt_bisaccodes_2008 VALUES (
	'FIC049030',
	'African American / Erotica')
go

INSERT INTO temp_sgt_bisaccodes_2008 VALUES (
	'FIC049040',
	'African American / Historical')
go

INSERT INTO temp_sgt_bisaccodes_2008 VALUES (
	'FIC049050',
	'African American / Mystery & Detective')
go

INSERT INTO temp_sgt_bisaccodes_2008 VALUES (
	'FIC049060',
	'African American / Romance')
go

INSERT INTO temp_sgt_bisaccodes_2008 VALUES (
	'FIC049070',
	'African American / Urban Life')
go

INSERT INTO temp_sgt_bisaccodes_2008 VALUES (
	'FIC050000',
	'Crime')
go

INSERT INTO temp_sgt_bisaccodes_2008 VALUES (
	'FIC051000',
	'Cultural Heritage')
go

INSERT INTO temp_sgt_bisaccodes_2008 VALUES (
	'FIC009050',
	'Fantasy / Paranormal')
go

INSERT INTO temp_sgt_bisaccodes_2008 VALUES (
	'FIC009060',
	'Fantasy / Urban Life')
go

INSERT INTO temp_sgt_bisaccodes_2008 VALUES (
	'FIC028050',
	'Science Fiction / Military')
go

INSERT INTO temp_sgt_bisaccodes_2008 VALUES (
	'HEA046000',
	'Children''s Health')
go

INSERT INTO temp_sgt_bisaccodes_2008 VALUES (
	'HEA035000',
	'Hearing & Speech')
go

INSERT INTO temp_sgt_bisaccodes_2008 VALUES (
	'HIS027180',
	'Military / Special Forces')
go

INSERT INTO temp_sgt_bisaccodes_2008 VALUES (
	'JUV001020',
	'Action & Adventure / Pirates')
go

INSERT INTO temp_sgt_bisaccodes_2008 VALUES (
	'JUV002020',
	'Animals / Apes, Monkeys, etc.')
go

INSERT INTO temp_sgt_bisaccodes_2008 VALUES (
	'JUV002300',
	'Animals / Butterflies, Moths & Caterpillars')
go

INSERT INTO temp_sgt_bisaccodes_2008 VALUES (
	'JUV002310',
	'Animals / Cows')
go

INSERT INTO temp_sgt_bisaccodes_2008 VALUES (
	'JUV002320',
	'Animals / Giraffes')
go

INSERT INTO temp_sgt_bisaccodes_2008 VALUES (
	'JUV002330',
	'Animals / Hippos & Rhinos')
go

INSERT INTO temp_sgt_bisaccodes_2008 VALUES (
	'JUV002340',
	'Animals / Jungle Animals')
go

INSERT INTO temp_sgt_bisaccodes_2008 VALUES (
	'JUV002350',
	'Animals / Kangaroos')
go

INSERT INTO temp_sgt_bisaccodes_2008 VALUES (
	'JUV002360',
	'Animals / Nocturnal')
go

INSERT INTO temp_sgt_bisaccodes_2008 VALUES (
	'JUV002250',
	'Animals / Wolves & Coyotes')
go

INSERT INTO temp_sgt_bisaccodes_2008 VALUES (
	'JUV037000',
	'Fantasy & Magic')
go

INSERT INTO temp_sgt_bisaccodes_2008 VALUES (
	'JUV017000',
	'Holidays & Celebrations / General (see also Religious / Christian /Holidays & Celebrations)')
go

INSERT INTO temp_sgt_bisaccodes_2008 VALUES (
	'JUV051000',
	'Imagination & Play')
go

INSERT INTO temp_sgt_bisaccodes_2008 VALUES (
	'JUV052000',
	'Monsters')
go


INSERT INTO temp_sgt_bisaccodes_2008 VALUES (
	'JUV033010',
	'Religious / Christian / General')
go

INSERT INTO temp_sgt_bisaccodes_2008 VALUES (
	'JUV033040',
	'Religious / Christian / Action & Adventure')
go

INSERT INTO temp_sgt_bisaccodes_2008 VALUES (
	'JUV033050',
	'Religious / Christian / Animals')
go

INSERT INTO temp_sgt_bisaccodes_2008 VALUES (
	'JUV033060',
	'Religious / Christian / Bedtime & Dreams')
go

INSERT INTO temp_sgt_bisaccodes_2008 VALUES (
	'JUV033070',
	'Religious / Christian / Comics & Graphic Novels')
go

INSERT INTO temp_sgt_bisaccodes_2008 VALUES (
	'JUV033080',
	'Religious / Christian / Early Readers')
go

INSERT INTO temp_sgt_bisaccodes_2008 VALUES (
	'JUV033090',
	'Religious / Christian / Emotions & Feelings')
go

INSERT INTO temp_sgt_bisaccodes_2008 VALUES (
	'JUV033100',
	'Religious / Christian / Family')
go

INSERT INTO temp_sgt_bisaccodes_2008 VALUES (
	'JUV033110',
	'Religious / Christian / Fantasy')
go

INSERT INTO temp_sgt_bisaccodes_2008 VALUES (
	'JUV033120',
	'Religious / Christian / Friendship')
go

INSERT INTO temp_sgt_bisaccodes_2008 VALUES (
	'JUV033130',
	'Religious / Christian / Health & Daily Living')
go

INSERT INTO temp_sgt_bisaccodes_2008 VALUES (
	'JUV033140',
	'Religious / Christian / Historical')
go

INSERT INTO temp_sgt_bisaccodes_2008 VALUES (
	'JUV033150',
	'Religious / Christian / Holidays & Celebrations')
go

INSERT INTO temp_sgt_bisaccodes_2008 VALUES (
	'JUV033160',
	'Religious / Christian / Humorous')
go

INSERT INTO temp_sgt_bisaccodes_2008 VALUES (
	'JUV033170',
	'Religious / Christian / Learning Concepts')
go

INSERT INTO temp_sgt_bisaccodes_2008 VALUES (
	'JUV033180',
	'Religious / Christian / Mystery & Detective Stories')
go

INSERT INTO temp_sgt_bisaccodes_2008 VALUES (
	'JUV033190',
	'Religious / Christian / People & Places')
go

INSERT INTO temp_sgt_bisaccodes_2008 VALUES (
	'JUV033200',
	'Religious / Christian / Relationships')
go

INSERT INTO temp_sgt_bisaccodes_2008 VALUES (
	'JUV033210',
	'Religious / Christian / Science Fiction')
go

INSERT INTO temp_sgt_bisaccodes_2008 VALUES (
	'JUV033220',
	'Religious / Christian / Social Issues')
go

INSERT INTO temp_sgt_bisaccodes_2008 VALUES (
	'JUV033230',
	'Religious / Christian / Sports & Recreation')
go

INSERT INTO temp_sgt_bisaccodes_2008 VALUES (
	'JUV033240',
	'Religious / Christian / Values & Virtues')
go

INSERT INTO temp_sgt_bisaccodes_2008 VALUES (
	'JUV053000',
	'Science Fiction')
go

INSERT INTO temp_sgt_bisaccodes_2008 VALUES (
	'JUV039270',
	'Social Issues / Strangers')
go

INSERT INTO temp_sgt_bisaccodes_2008 VALUES (
	'JUV032010',
	'Sports & Recreation / Baseball & Softball')
go

INSERT INTO temp_sgt_bisaccodes_2008 VALUES (
	'JNF003010',
	'Animals / Apes, Monkeys, etc.')
go

INSERT INTO temp_sgt_bisaccodes_2008 VALUES (
	'JNF003250',
	'Animals / Butterflies, Moths & Caterpillars')
go

INSERT INTO temp_sgt_bisaccodes_2008 VALUES (
	'JNF003260',
	'Animals / Cows')
go

INSERT INTO temp_sgt_bisaccodes_2008 VALUES (
	'JNF003270',
	'Animals / Endangered')
go

INSERT INTO temp_sgt_bisaccodes_2008 VALUES (
	'JNF003280',
	'Animals / Giraffes')
go

INSERT INTO temp_sgt_bisaccodes_2008 VALUES (
	'JNF003290',
	'Animals / Hippos & Rhinos')
go

INSERT INTO temp_sgt_bisaccodes_2008 VALUES (
	'JNF003300',
	'Animals / Jungle Animals')
go

INSERT INTO temp_sgt_bisaccodes_2008 VALUES (
	'JNF003310',
	'Animals / Kangaroos')
go

INSERT INTO temp_sgt_bisaccodes_2008 VALUES (
	'JNF003320',
	'Animals / Nocturnal')
go

INSERT INTO temp_sgt_bisaccodes_2008 VALUES (
	'JNF0032400',
	'Animals / Wolves & Coyotes')
go

INSERT INTO temp_sgt_bisaccodes_2008 VALUES (
	'JNF007080',
	'Biography & Autobiography / Religious (see also Religious/ Christian / Biography & Autobiography)')
go

INSERT INTO temp_sgt_bisaccodes_2008 VALUES (
	'JNF063000',
	'Books & Libraries')
go

INSERT INTO temp_sgt_bisaccodes_2008 VALUES (
	'JNF026000',
	'Holidays & Celebrations / General (see also Religious/ Christian / Holidays & Celebrations)')
go

INSERT INTO temp_sgt_bisaccodes_2008 VALUES (
	'JNF042020',
	'Poetry / Nursery Rhymes')
go

INSERT INTO temp_sgt_bisaccodes_2008 VALUES (
	'JNF049040',
	'Religion / Bible Stories / General')
go

INSERT INTO temp_sgt_bisaccodes_2008 VALUES (
	'JNF049140',
	'Religion / Bible Stories / Old Testament')
go

INSERT INTO temp_sgt_bisaccodes_2008 VALUES (
	'JNF049150',
	'Religion / Bible Stories / New Testament')
go

INSERT INTO temp_sgt_bisaccodes_2008 VALUES (
	'JNF049160',
	'Religion / Biblical History')
go

INSERT INTO temp_sgt_bisaccodes_2008 VALUES (
	'JNF049170',
	'Religion / Biblical Reference')
go

INSERT INTO temp_sgt_bisaccodes_2008 VALUES (
	'JNF049080',
	'Religion / Christianity')
go

INSERT INTO temp_sgt_bisaccodes_2008 VALUES (
	'JNF049130',
	'Religious / Christian / General')
go

INSERT INTO temp_sgt_bisaccodes_2008 VALUES (
	'JNF049180',
	'Religious / Christian / Biography and Autobiography (see also Biography & Autobiography / Religious)')
go

INSERT INTO temp_sgt_bisaccodes_2008 VALUES (
	'JNF049190',
	'Religious / Christian / Comics & Graphic Novels')
go

INSERT INTO temp_sgt_bisaccodes_2008 VALUES (
	'JNF049120',
	'Religious / Christian / Devotional & Prayer')
go

INSERT INTO temp_sgt_bisaccodes_2008 VALUES (
	'JNF049200',
	'Religious / Christian / Early Readers')
go

INSERT INTO temp_sgt_bisaccodes_2008 VALUES (
	'JNF049210',
	'Religious / Christian / Family & Relationships')
go

INSERT INTO temp_sgt_bisaccodes_2008 VALUES (
	'JNF049220',
	'Religious / Christian / Games & Activities')
go

INSERT INTO temp_sgt_bisaccodes_2008 VALUES (
	'JNF049230',
	'Religious / Christian / Health & Daily Living')
go

INSERT INTO temp_sgt_bisaccodes_2008 VALUES (
	'JNF049240',
	'Religious / Christian / Holidays & Celebrations')
go

INSERT INTO temp_sgt_bisaccodes_2008 VALUES (
	'JNF049250',
	'Religious / Christian / Inspirational')
go

INSERT INTO temp_sgt_bisaccodes_2008 VALUES (
	'JNF049260',
	'Religious / Christian / Learning Concepts')
go

INSERT INTO temp_sgt_bisaccodes_2008 VALUES (
	'JNF049270',
	'Religious / Christian / People & Places')
go

INSERT INTO temp_sgt_bisaccodes_2008 VALUES (
	'JNF049280',
	'Religious / Christian / Science & Nature')
go

INSERT INTO temp_sgt_bisaccodes_2008 VALUES (
	'JNF049290',
	'Religious / Christian / Social Issues')
go

INSERT INTO temp_sgt_bisaccodes_2008 VALUES (
	'JNF049300',
	'Religious / Christian / Sports & Recreation')
go

INSERT INTO temp_sgt_bisaccodes_2008 VALUES (
	'JNF049310',
	'Religious / Christian / Values & Virtues')
go

INSERT INTO temp_sgt_bisaccodes_2008 VALUES (
	'JNF053260',
	'Social Issues / Strangers')
go

INSERT INTO temp_sgt_bisaccodes_2008 VALUES (
	'JNF054010',
	'Sports & Recreation / Baseball & Softball')
go

INSERT INTO temp_sgt_bisaccodes_2008 VALUES (
	'LAN006000',
	'Grammar & Punctuation')
go

INSERT INTO temp_sgt_bisaccodes_2008 VALUES (
	'LIT017000',
	'Comics & Graphic Novels')
go

INSERT INTO temp_sgt_bisaccodes_2008 VALUES (
	'LIT018000',
	'Short Stories')
go

INSERT INTO temp_sgt_bisaccodes_2008 VALUES (
	'MED111000',
	'Bariatrics')
go

INSERT INTO temp_sgt_bisaccodes_2008 VALUES (
	'MED112000',
	'Evidence-Based Medicine')
go

INSERT INTO temp_sgt_bisaccodes_2008 VALUES (
	'MED113000',
	'Long-Term Care')
go

INSERT INTO temp_sgt_bisaccodes_2008 VALUES (
	'MUS051000',
	'Genres & Styles / Choral')
go

INSERT INTO temp_sgt_bisaccodes_2008 VALUES (
	'NAT033000',
	'Sky Observation')
go

INSERT INTO temp_sgt_bisaccodes_2008 VALUES (
	'PET004020',
	'Dogs / Training')
go

INSERT INTO temp_sgt_bisaccodes_2008 VALUES (
	'PHO025000',
	'Annuals')
go

INSERT INTO temp_sgt_bisaccodes_2008 VALUES (
	'PHO003000',
	'Business Aspects')
go

INSERT INTO temp_sgt_bisaccodes_2008 VALUES (
	'PHO004000',
	'Collections,Catalogs,Exhibitions / General')
go

INSERT INTO temp_sgt_bisaccodes_2008 VALUES (
	'PHO004010',
	'Collections,Catalogs,Exhibitions / Group Shows')
go

INSERT INTO temp_sgt_bisaccodes_2008 VALUES (
	'PHO004020',
	'Collections,Catalogs,Exhibitions / Permanent Collections')
go

INSERT INTO temp_sgt_bisaccodes_2008 VALUES (
	'PHO011000',
	'Individual Photographers / General')
go

INSERT INTO temp_sgt_bisaccodes_2008 VALUES (
	'PHO011010',
	'Individual Photographers / Artists'' Books')
go

INSERT INTO temp_sgt_bisaccodes_2008 VALUES (
	'PHO011020',
	'Individual Photographers / Essays')
go

INSERT INTO temp_sgt_bisaccodes_2008 VALUES (
	'PHO011030',
	'Individual Photographers / Monographs')
go

INSERT INTO temp_sgt_bisaccodes_2008 VALUES (
	'PHO023070',
	'Subjects & Themes / Celebrations & Events')
go

INSERT INTO temp_sgt_bisaccodes_2008 VALUES (
	'PHO023080',
	'Subjects & Themes / Celebrity')
go

INSERT INTO temp_sgt_bisaccodes_2008 VALUES (
	'PHO023090',
	'Subjects & Themes / Lifestyles')
go

INSERT INTO temp_sgt_bisaccodes_2008 VALUES (
	'PHO022000',
	'Techniques / Cinematography & Videography')
go

INSERT INTO temp_sgt_bisaccodes_2008 VALUES (
	'PHO024000',
	'Techniques / Digital (see also COMPUTERS / Digital Media / Photography)')
go


INSERT INTO temp_sgt_bisaccodes_2008 VALUES (
	'POE005060',
	'American / Asian American')
go

INSERT INTO temp_sgt_bisaccodes_2008 VALUES (
	'POE005070',
	'American / Hispanic American')
go

INSERT INTO temp_sgt_bisaccodes_2008 VALUES (
	'POE014000',
	'Epic')
go

INSERT INTO temp_sgt_bisaccodes_2008 VALUES (
	'POE015000',
	'Native-American')
go

INSERT INTO temp_sgt_bisaccodes_2008 VALUES (
	'POL045000',
	'Colonialism & Post-Colonialism')
go

INSERT INTO temp_sgt_bisaccodes_2008 VALUES (
	'PSY022060',
	'Psychopathology / Anxieties & Phobias')
go

INSERT INTO temp_sgt_bisaccodes_2008 VALUES (
	'PSY022020',
	'Psychopathology / Autism Spectrum Disorders')
go

INSERT INTO temp_sgt_bisaccodes_2008 VALUES (
	'PSY022030',
	'Psychopathology / Bipolar Disorders')
go

INSERT INTO temp_sgt_bisaccodes_2008 VALUES (
	'PSY049000',
	'Psychopathology / Depression')
go

INSERT INTO temp_sgt_bisaccodes_2008 VALUES (
	'PSY022070',
	'Psychopathology / Dissociative Identity Disorder')
go

INSERT INTO temp_sgt_bisaccodes_2008 VALUES (
	'REF013000',
	'Genealogy & Heraldry')
go

INSERT INTO temp_sgt_bisaccodes_2008 VALUES (
	'REL067130',
	'Christian Theology / Process')
go

INSERT INTO temp_sgt_bisaccodes_2008 VALUES (
	'REL113000',
	'Essays')
go

INSERT INTO temp_sgt_bisaccodes_2008 VALUES (
	'SEL036000',
	'Anxieties & Phobias')
go

INSERT INTO temp_sgt_bisaccodes_2008 VALUES (
	'SEL026010',
	'Substance Abuse & Addictions / Tobacco')
go

INSERT INTO temp_sgt_bisaccodes_2008 VALUES (
	'SOC055000',
	'Agriculture & Food')
go

INSERT INTO temp_sgt_bisaccodes_2008 VALUES (
	'SOC056000',
	'Black Studies (Global)')
go

INSERT INTO temp_sgt_bisaccodes_2008 VALUES (
	'SOC057000',
	'Disease & Health Issues')
go

INSERT INTO temp_sgt_bisaccodes_2008 VALUES (
	'SOC045000',
	'Poverty & Homelessness')
go

INSERT INTO temp_sgt_bisaccodes_2008 VALUES (
	'SPO069000',
	'Surfing')
go

INSERT INTO temp_sgt_bisaccodes_2008 VALUES (
	'STU001000',
	'ACT')
go

INSERT INTO temp_sgt_bisaccodes_2008 VALUES (
	'STU025000',
	'High School Entrance')
go

INSERT INTO temp_sgt_bisaccodes_2008 VALUES (
	'STU033000',
	'PSAT & NMSQT (National Merit Scholarship Qualifying Test')
go

INSERT INTO temp_sgt_bisaccodes_2008 VALUES (
	'STU024000',  
	'SAT')
go
