IF EXISTS (SELECT * FROM dbo.sysobjects WHERE id = Object_id('temp_sgt_bisaccodes_2010') AND type = 'U')
  BEGIN
    DROP table temp_sgt_bisaccodes_2010
  END
go

CREATE TABLE temp_sgt_bisaccodes_2010 (
	Code char(255),
	Literal char(255))
go


INSERT INTO temp_sgt_bisaccodes_2010 VALUES (
	'ANT000000 ',
	'General')
INSERT INTO temp_sgt_bisaccodes_2010 VALUES (
	'ANT001000 ',
	'Americana')
INSERT INTO temp_sgt_bisaccodes_2010 VALUES (
	'ANT002000',
	'Art')   
INSERT INTO temp_sgt_bisaccodes_2010 VALUES (
	'ANT003000',
	'Autographs')  
INSERT INTO temp_sgt_bisaccodes_2010 VALUES (
	'ANT005000',
	'Books') 
INSERT INTO temp_sgt_bisaccodes_2010 VALUES (
	'ANT006000',
	'Bottles') 
INSERT INTO temp_sgt_bisaccodes_2010 VALUES (
	'ANT007000',
	'Buttons & Pins') 
INSERT INTO temp_sgt_bisaccodes_2010 VALUES (
	'ANT054000',
	'Canadiana') 
INSERT INTO temp_sgt_bisaccodes_2010 VALUES (
	'ANT008000',
	'Care & Restoration')  
INSERT INTO temp_sgt_bisaccodes_2010 VALUES (
	'ANT010000',
	'Clocks & Watches') 
INSERT INTO temp_sgt_bisaccodes_2010 VALUES (
	'ANT011000',
	'Coins, Currency & Medals')  
INSERT INTO temp_sgt_bisaccodes_2010 VALUES (
	'ANT012000',
	'Comics')  
INSERT INTO temp_sgt_bisaccodes_2010 VALUES (
	'ANT015000',
	'Dolls') 
INSERT INTO temp_sgt_bisaccodes_2010 VALUES (
	'ANT053000',
	'Figurines') 
INSERT INTO temp_sgt_bisaccodes_2010 VALUES (
	'ANT016000',
	'Firearms & Weapons')  
INSERT INTO temp_sgt_bisaccodes_2010 VALUES (
	'ANT017000',
	'Furniture') 
INSERT INTO temp_sgt_bisaccodes_2010 VALUES (
	'ANT018000',
	'Glass & Glassware')   
INSERT INTO temp_sgt_bisaccodes_2010 VALUES (
	'ANT021000',
	'Jewelry') 
INSERT INTO temp_sgt_bisaccodes_2010 VALUES (
	'ANT022000',
	'Kitchenware')  
INSERT INTO temp_sgt_bisaccodes_2010 VALUES (
	'ANT023000',
	'Magazines & Newspapers') 
INSERT INTO temp_sgt_bisaccodes_2010 VALUES (
	'ANT024000',
	'Military')  
INSERT INTO temp_sgt_bisaccodes_2010 VALUES (
	'ANT028000',
	'Non-Sports Cards') 
INSERT INTO temp_sgt_bisaccodes_2010 VALUES (
	'ANT029000',
	'Paper Ephemera') 
INSERT INTO temp_sgt_bisaccodes_2010 VALUES (
	'ANT025000',
	'Performing Arts')  
INSERT INTO temp_sgt_bisaccodes_2010 VALUES (
	'ANT031000',
	'Political') 
INSERT INTO temp_sgt_bisaccodes_2010 VALUES (
	'ANT052000',
	'Popular Culture')  
INSERT INTO temp_sgt_bisaccodes_2010 VALUES (
	'ANT032000',
	'Porcelain & China')   
INSERT INTO temp_sgt_bisaccodes_2010 VALUES (
	'ANT033000',
	'Postcards') 
INSERT INTO temp_sgt_bisaccodes_2010 VALUES (
	'ANT034000',
	'Posters') 
INSERT INTO temp_sgt_bisaccodes_2010 VALUES (
	'ANT035000',
	'Pottery & Ceramics')  
INSERT INTO temp_sgt_bisaccodes_2010 VALUES (
	'ANT036000',
	'Radios & Televisions (see also Performing Arts)') 
INSERT INTO temp_sgt_bisaccodes_2010 VALUES (
	'ANT037000',
	'Records') 
INSERT INTO temp_sgt_bisaccodes_2010 VALUES (
	'ANT038000',
	'Reference') 
INSERT INTO temp_sgt_bisaccodes_2010 VALUES (
	'ANT040000',
	'Rugs')  
INSERT INTO temp_sgt_bisaccodes_2010 VALUES (
	'ANT041000',
	'Silver, Gold & Other Metals') 
INSERT INTO temp_sgt_bisaccodes_2010 VALUES (
	'ANT043000',
	'Sports (see also headings under Sports Cards)') 
INSERT INTO temp_sgt_bisaccodes_2010 VALUES (
	'ANT042000',
	'Sports Cards / General') 
INSERT INTO temp_sgt_bisaccodes_2010 VALUES (
	'ANT042010',
	'Sports Cards / Baseball')   
INSERT INTO temp_sgt_bisaccodes_2010 VALUES (
	'ANT042020',
	'Sports Cards / Basketball') 
INSERT INTO temp_sgt_bisaccodes_2010 VALUES (
	'ANT042030',
	'Sports Cards / Football')   
INSERT INTO temp_sgt_bisaccodes_2010 VALUES (
	'ANT042040',
	'Sports Cards / Hockey')  
INSERT INTO temp_sgt_bisaccodes_2010 VALUES (
	'ANT044000',
	'Stamps')  
INSERT INTO temp_sgt_bisaccodes_2010 VALUES (
	'ANT045000',
	'Teddy Bears')  
INSERT INTO temp_sgt_bisaccodes_2010 VALUES (
	'ANT047000',
	'Textiles & Costume')  
INSERT INTO temp_sgt_bisaccodes_2010 VALUES (
	'ANT055000',
	'Tobacco-Related')  
INSERT INTO temp_sgt_bisaccodes_2010 VALUES (
	'ANT049000',
	'Toy Animals')  
INSERT INTO temp_sgt_bisaccodes_2010 VALUES (
	'ANT050000',
	'Toys')  
INSERT INTO temp_sgt_bisaccodes_2010 VALUES (
	'ANT009000',
	'Transportation') 
INSERT INTO temp_sgt_bisaccodes_2010 VALUES (
	'ANT051000',
	'Wine')  
INSERT INTO temp_sgt_bisaccodes_2010 VALUES (
	'ARC000000',
	'General') 
INSERT INTO temp_sgt_bisaccodes_2010 VALUES (
	'ARC022000',
	'Adaptive Reuse & Renovation') 
INSERT INTO temp_sgt_bisaccodes_2010 VALUES (
	'ARC023000',
	'Annuals') 
INSERT INTO temp_sgt_bisaccodes_2010 VALUES (
	'ARC024000',
	'Buildings / General')  
INSERT INTO temp_sgt_bisaccodes_2010 VALUES (
	'ARC024010',
	'Buildings / Landmarks & Monuments') 
INSERT INTO temp_sgt_bisaccodes_2010 VALUES (
	'ARC011000',
	'Buildings / Public, Commercial & Industrial ')  
INSERT INTO temp_sgt_bisaccodes_2010 VALUES (
	'ARC016000',
	'Buildings / Religious')  
INSERT INTO temp_sgt_bisaccodes_2010 VALUES (
	'ARC003000',
	'Buildings / Residential')   
INSERT INTO temp_sgt_bisaccodes_2010 VALUES (
	'ARC019000',
	'Codes & Standards')   
INSERT INTO temp_sgt_bisaccodes_2010 VALUES (
	'ARC001000',
	'Criticism') 
INSERT INTO temp_sgt_bisaccodes_2010 VALUES (
	'ARC002000',
	'Decoration & Ornament')  
INSERT INTO temp_sgt_bisaccodes_2010 VALUES (
	'ARC004000',
	'Design, Drafting, Drawing & Presentation ')  
INSERT INTO temp_sgt_bisaccodes_2010 VALUES (
	'ARC014000',
	'Historic Preservation / General') 
INSERT INTO temp_sgt_bisaccodes_2010 VALUES (
	'ARC014010',
	'Historic Preservation / Restoration Techniques')  
INSERT INTO temp_sgt_bisaccodes_2010 VALUES (
	'ARC005000',
	'History / General')   
INSERT INTO temp_sgt_bisaccodes_2010 VALUES (
	'ARC005010',
	'History / Prehistoric & Primitive') 
INSERT INTO temp_sgt_bisaccodes_2010 VALUES (
	'ARC005020',
	'History / Ancient & Classical ')  
INSERT INTO temp_sgt_bisaccodes_2010 VALUES (
	'ARC005030',
	'History / Medieval')  
INSERT INTO temp_sgt_bisaccodes_2010 VALUES (
	'ARC005040',
	'History / Renaissance')  
INSERT INTO temp_sgt_bisaccodes_2010 VALUES (
	'ARC005050',
	'History / Baroque & Rococo')  
INSERT INTO temp_sgt_bisaccodes_2010 VALUES (
	'ARC005060',
	'History / Romanticism')  
INSERT INTO temp_sgt_bisaccodes_2010 VALUES (
	'ARC005070',
	'History / Modern (late 19th Century to 1945)')  
INSERT INTO temp_sgt_bisaccodes_2010 VALUES (
	'ARC005080',
	'History / Contemporary (1945-)')  
INSERT INTO temp_sgt_bisaccodes_2010 VALUES (
	'ARC006000',
	'Individual Architects & Firms / General  ')  
INSERT INTO temp_sgt_bisaccodes_2010 VALUES (
	'ARC006010',
	'Individual Architects & Firms / Essays') 
INSERT INTO temp_sgt_bisaccodes_2010 VALUES (
	'ARC006020',
	'Individual Architects & Firms / Monographs') 
INSERT INTO temp_sgt_bisaccodes_2010 VALUES (
	'ARC007000',
	'Interior Design / General') 
INSERT INTO temp_sgt_bisaccodes_2010 VALUES (
	'ARC007010',
	'Interior Design / Lighting')  
INSERT INTO temp_sgt_bisaccodes_2010 VALUES (
	'ARC008000',
	'Landscape') 
INSERT INTO temp_sgt_bisaccodes_2010 VALUES (
	'ARC009000',
	'Methods & Materials')  
INSERT INTO temp_sgt_bisaccodes_2010 VALUES (
	'ARC015000',
	'Professional Practice')  
INSERT INTO temp_sgt_bisaccodes_2010 VALUES (
	'ARC017000',
	'Project Management')  
INSERT INTO temp_sgt_bisaccodes_2010 VALUES (
	'ARC012000',
	'Reference') 
INSERT INTO temp_sgt_bisaccodes_2010 VALUES (
	'ARC020000',
	'Regional')  
INSERT INTO temp_sgt_bisaccodes_2010 VALUES (
	'ARC021000',
	'Security Design')  
INSERT INTO temp_sgt_bisaccodes_2010 VALUES (
	'ARC013000',
	'Study & Teaching') 
INSERT INTO temp_sgt_bisaccodes_2010 VALUES (
	'ARC018000',
	'Sustainability & Green Design ')  
INSERT INTO temp_sgt_bisaccodes_2010 VALUES (
	'ARC010000',
	'Urban & Land Use Planning') 
INSERT INTO temp_sgt_bisaccodes_2010 VALUES (
	'ART000000',
	'General') 
INSERT INTO temp_sgt_bisaccodes_2010 VALUES (
	'ART015010',
	'African') 
INSERT INTO temp_sgt_bisaccodes_2010 VALUES (
	'ART015020',
	'American / General')  
INSERT INTO temp_sgt_bisaccodes_2010 VALUES (
	'ART038000',
	'American / African American') 
INSERT INTO temp_sgt_bisaccodes_2010 VALUES (
	'ART039000',
	'American / Asian American') 
INSERT INTO temp_sgt_bisaccodes_2010 VALUES (
	'ART040000',
	'American / Hispanic American') 
INSERT INTO temp_sgt_bisaccodes_2010 VALUES (
	'ART054000',
	'Annuals') 
INSERT INTO temp_sgt_bisaccodes_2010 VALUES (
	'ART037000',
	'Art & Politics') 
INSERT INTO temp_sgt_bisaccodes_2010 VALUES (
	'ART019000',
	'Asian') 
INSERT INTO temp_sgt_bisaccodes_2010 VALUES (
	'ART042000',
	'Australian & Oceanian')  
INSERT INTO temp_sgt_bisaccodes_2010 VALUES (
	'ART055000',
	'Body Art & Tattooing') 
INSERT INTO temp_sgt_bisaccodes_2010 VALUES (
	'ART043000',
	'Business Aspects') 
INSERT INTO temp_sgt_bisaccodes_2010 VALUES (
	'ART015040',
	'Canadian')  
INSERT INTO temp_sgt_bisaccodes_2010 VALUES (
	'ART044000',
	'Caribbean & Latin American')  
INSERT INTO temp_sgt_bisaccodes_2010 VALUES (
	'ART045000',
	'Ceramics')  
INSERT INTO temp_sgt_bisaccodes_2010 VALUES (
	'ART006000',
	'Collections, Catalogs, Exhibitions / General')  
INSERT INTO temp_sgt_bisaccodes_2010 VALUES (
	'ART006010',
	'Collections, Catalogs, Exhibitions / Group Shows')  
INSERT INTO temp_sgt_bisaccodes_2010 VALUES (
	'ART006020',
	'Collections, Catalogs, Exhibitions / Permanent Collections') 
INSERT INTO temp_sgt_bisaccodes_2010 VALUES (
	'ART007000',
	'Color Theory') 
INSERT INTO temp_sgt_bisaccodes_2010 VALUES (
	'ART008000',
	'Conceptual ')  
INSERT INTO temp_sgt_bisaccodes_2010 VALUES (
	'ART056000',
	'Conservation & Preservation') 
INSERT INTO temp_sgt_bisaccodes_2010 VALUES (
	'ART009000',
	'Criticism & Theory')  
INSERT INTO temp_sgt_bisaccodes_2010 VALUES (
	'ART046000',
	'Digital') 
INSERT INTO temp_sgt_bisaccodes_2010 VALUES (
	'ART015030',
	'European')  
INSERT INTO temp_sgt_bisaccodes_2010 VALUES (
	'ART057000',
	'Film & Video') 
INSERT INTO temp_sgt_bisaccodes_2010 VALUES (
	'ART013000',
	'Folk & Outsider Art')  
INSERT INTO temp_sgt_bisaccodes_2010 VALUES (
	'ART058000',
	'Graffiti & Street Art')  
INSERT INTO temp_sgt_bisaccodes_2010 VALUES (
	'ART015000',
	'History / General')   
INSERT INTO temp_sgt_bisaccodes_2010 VALUES (
	'ART015050',
	'History / Prehistoric & Primitive') 
INSERT INTO temp_sgt_bisaccodes_2010 VALUES (
	'ART015060',
	'History / Ancient & Classical ')  
INSERT INTO temp_sgt_bisaccodes_2010 VALUES (
	'ART015070',
	'History / Medieval')  
INSERT INTO temp_sgt_bisaccodes_2010 VALUES (
	'ART015080',
	'History / Renaissance')  
INSERT INTO temp_sgt_bisaccodes_2010 VALUES (
	'ART015090',
	'History / Baroque & Rococo')  
INSERT INTO temp_sgt_bisaccodes_2010 VALUES (
	'ART015120',
	'History / Romanticism')  
INSERT INTO temp_sgt_bisaccodes_2010 VALUES (
	'ART015100',
	'History / Modern (late 19th Century to 1945)')  
INSERT INTO temp_sgt_bisaccodes_2010 VALUES (
	'ART015110',
	'History / Contemporary (1945-)')  
INSERT INTO temp_sgt_bisaccodes_2010 VALUES (
	'ART016000',
	'Individual Artists / General') 
INSERT INTO temp_sgt_bisaccodes_2010 VALUES (
	'ART016010',
	'Individual Artists / Artists'' Books  ') 
INSERT INTO temp_sgt_bisaccodes_2010 VALUES (
	'ART016020',
	'Individual Artists / Essays') 
INSERT INTO temp_sgt_bisaccodes_2010 VALUES (
	'ART016030',
	'Individual Artists / Monographs') 
INSERT INTO temp_sgt_bisaccodes_2010 VALUES (
	'ART047000',
	'Middle Eastern') 
INSERT INTO temp_sgt_bisaccodes_2010 VALUES (
	'ART017000',
	'Mixed Media')  
INSERT INTO temp_sgt_bisaccodes_2010 VALUES (
	'ART059000',
	'Museum Studies') 
INSERT INTO temp_sgt_bisaccodes_2010 VALUES (
	'ART041000',
	'Native American')  
INSERT INTO temp_sgt_bisaccodes_2010 VALUES (
	'ART060000',
	'Performance')  
INSERT INTO temp_sgt_bisaccodes_2010 VALUES (
	'ART023000',
	'Popular Culture')  
INSERT INTO temp_sgt_bisaccodes_2010 VALUES (
	'ART048000',
	'Prints')  
INSERT INTO temp_sgt_bisaccodes_2010 VALUES (
	'ART025000',
	'Reference') 
INSERT INTO temp_sgt_bisaccodes_2010 VALUES (
	'ART049000',
	'Russian & Former Soviet Union ')  
INSERT INTO temp_sgt_bisaccodes_2010 VALUES (
	'ART026000',
	'Sculpture & Installation')  
INSERT INTO temp_sgt_bisaccodes_2010 VALUES (
	'ART027000',
	'Study & Teaching') 
INSERT INTO temp_sgt_bisaccodes_2010 VALUES (
	'ART050000',
	'Subjects & Themes / General') 
INSERT INTO temp_sgt_bisaccodes_2010 VALUES (
	'ART050050',
	'Subjects & Themes / Erotica') 
INSERT INTO temp_sgt_bisaccodes_2010 VALUES (
	'ART050010',
	'Subjects & Themes / Human Figure')  
INSERT INTO temp_sgt_bisaccodes_2010 VALUES (
	'ART050020',
	'Subjects & Themes / Landscapes & Seascapes')  
INSERT INTO temp_sgt_bisaccodes_2010 VALUES (
	'ART050030',
	'Subjects & Themes / Plants & Animals ') 
INSERT INTO temp_sgt_bisaccodes_2010 VALUES (
	'ART050040',
	'Subjects & Themes / Portraits ')  
INSERT INTO temp_sgt_bisaccodes_2010 VALUES (
	'ART035000',
	'Subjects & Themes / Religious ')  
INSERT INTO temp_sgt_bisaccodes_2010 VALUES (
	'ART028000',
	'Techniques / General') 
INSERT INTO temp_sgt_bisaccodes_2010 VALUES (
	'ART031000',
	'Techniques / Acrylic Painting ')  
INSERT INTO temp_sgt_bisaccodes_2010 VALUES (
	'ART002000',
	'Techniques / Airbrush')  
INSERT INTO temp_sgt_bisaccodes_2010 VALUES (
	'ART003000',
	'Techniques / Calligraphy')  
INSERT INTO temp_sgt_bisaccodes_2010 VALUES (
	'ART004000',
	'Techniques / Cartooning')   
INSERT INTO temp_sgt_bisaccodes_2010 VALUES (
	'ART051000',
	'Techniques / Color')  
INSERT INTO temp_sgt_bisaccodes_2010 VALUES (
	'ART010000',
	'Techniques / Drawing') 
INSERT INTO temp_sgt_bisaccodes_2010 VALUES (
	'ART052000',
	'Techniques / Life Drawing') 
INSERT INTO temp_sgt_bisaccodes_2010 VALUES (
	'ART018000',
	'Techniques / Oil Painting') 
INSERT INTO temp_sgt_bisaccodes_2010 VALUES (
	'ART020000',
	'Techniques / Painting')  
INSERT INTO temp_sgt_bisaccodes_2010 VALUES (
	'ART021000',
	'Techniques / Pastel Drawing') 
INSERT INTO temp_sgt_bisaccodes_2010 VALUES (
	'ART033000',
	'Techniques / Pen & Ink Drawing')  
INSERT INTO temp_sgt_bisaccodes_2010 VALUES (
	'ART034000',
	'Techniques / Pencil Drawing') 
INSERT INTO temp_sgt_bisaccodes_2010 VALUES (
	'ART024000',
	'Techniques / Printmaking')  
INSERT INTO temp_sgt_bisaccodes_2010 VALUES (
	'ART053000',
	'Techniques / Sculpting') 
INSERT INTO temp_sgt_bisaccodes_2010 VALUES (
	'ART029000',
	'Techniques / Watercolor Painting')  
INSERT INTO temp_sgt_bisaccodes_2010 VALUES (
	'BIB001000',
	'Christian Standard Bible / General   ') 
INSERT INTO temp_sgt_bisaccodes_2010 VALUES (
	'BIB001010',
	'Christian Standard Bible / Children  ') 
INSERT INTO temp_sgt_bisaccodes_2010 VALUES (
	'BIB001020',
	'Christian Standard Bible / Devotional') 
INSERT INTO temp_sgt_bisaccodes_2010 VALUES (
	'BIB001030',
	'Christian Standard Bible / New Testament & Portions')  
INSERT INTO temp_sgt_bisaccodes_2010 VALUES (
	'BIB001040',
	'Christian Standard Bible / Reference ') 
INSERT INTO temp_sgt_bisaccodes_2010 VALUES (
	'BIB001050',
	'Christian Standard Bible / Study')  
INSERT INTO temp_sgt_bisaccodes_2010 VALUES (
	'BIB001060',
	'Christian Standard Bible / Text') 
INSERT INTO temp_sgt_bisaccodes_2010 VALUES (
	'BIB001070',
	'Christian Standard Bible / Youth & Teen  ')  
INSERT INTO temp_sgt_bisaccodes_2010 VALUES (
	'BIB002000',
	'Contemporary English Version / General') 
INSERT INTO temp_sgt_bisaccodes_2010 VALUES (
	'BIB002010',
	'Contemporary English Version / Children  ')  
INSERT INTO temp_sgt_bisaccodes_2010 VALUES (
	'BIB002020',
	'Contemporary English Version / Devotional')  
INSERT INTO temp_sgt_bisaccodes_2010 VALUES (
	'BIB002030',
	'Contemporary English Version / New Testament & Portions  ') 
INSERT INTO temp_sgt_bisaccodes_2010 VALUES (
	'BIB002040',
	'Contemporary English Version / Reference ')  
INSERT INTO temp_sgt_bisaccodes_2010 VALUES (
	'BIB002050',
	'Contemporary English Version / Study ') 
INSERT INTO temp_sgt_bisaccodes_2010 VALUES (
	'BIB002060',
	'Contemporary English Version / Text  ') 
INSERT INTO temp_sgt_bisaccodes_2010 VALUES (
	'BIB002070',
	'Contemporary English Version / Youth & Teen ')  
INSERT INTO temp_sgt_bisaccodes_2010 VALUES (
	'BIB003000',
	'English Standard Version / General   ') 
INSERT INTO temp_sgt_bisaccodes_2010 VALUES (
	'BIB003010',
	'English Standard Version / Children  ') 
INSERT INTO temp_sgt_bisaccodes_2010 VALUES (
	'BIB003020',
	'English Standard Version / Devotional') 
INSERT INTO temp_sgt_bisaccodes_2010 VALUES (
	'BIB003030',
	'English Standard Version / New Testament & Portions')  
INSERT INTO temp_sgt_bisaccodes_2010 VALUES (
	'BIB003040',
	'English Standard Version / Reference ') 
INSERT INTO temp_sgt_bisaccodes_2010 VALUES (
	'BIB003050',
	'English Standard Version / Study')  
INSERT INTO temp_sgt_bisaccodes_2010 VALUES (
	'BIB003060',
	'English Standard Version / Text') 
INSERT INTO temp_sgt_bisaccodes_2010 VALUES (
	'BIB003070',
	'English Standard Version / Youth & Teen  ')  
INSERT INTO temp_sgt_bisaccodes_2010 VALUES (
	'BIB004000',
	'God''s Word / General') 
INSERT INTO temp_sgt_bisaccodes_2010 VALUES (
	'BIB004010',
	'God''s Word / Children')  
INSERT INTO temp_sgt_bisaccodes_2010 VALUES (
	'BIB004020',
	'God''s Word / Devotional')   
INSERT INTO temp_sgt_bisaccodes_2010 VALUES (
	'BIB004030',
	'God''s Word / New Testament & Portions') 
INSERT INTO temp_sgt_bisaccodes_2010 VALUES (
	'BIB004040',
	'God''s Word / Reference') 
INSERT INTO temp_sgt_bisaccodes_2010 VALUES (
	'BIB004050',
	'God''s Word / Study')  
INSERT INTO temp_sgt_bisaccodes_2010 VALUES (
	'BIB004060',
	'God''s Word / Text')   
INSERT INTO temp_sgt_bisaccodes_2010 VALUES (
	'BIB004070',
	'God''s Word / Youth & Teen') 
INSERT INTO temp_sgt_bisaccodes_2010 VALUES (
	'BIB005000',
	'International Children''s Bible / General ')  
INSERT INTO temp_sgt_bisaccodes_2010 VALUES (
	'BIB005010',
	'International Children''s Bible / Children')  
INSERT INTO temp_sgt_bisaccodes_2010 VALUES (
	'BIB005020',
	'International Children''s Bible / Devotional ')  
INSERT INTO temp_sgt_bisaccodes_2010 VALUES (
	'BIB005030',
	'International Children''s Bible / New Testament & Portions') 
INSERT INTO temp_sgt_bisaccodes_2010 VALUES (
	'BIB005040',
	'International Children''s Bible / Reference') 
INSERT INTO temp_sgt_bisaccodes_2010 VALUES (
	'BIB005050',
	'International Children''s Bible / Study') 
INSERT INTO temp_sgt_bisaccodes_2010 VALUES (
	'BIB005060',
	'International Children''s Bible / Text') 
INSERT INTO temp_sgt_bisaccodes_2010 VALUES (
	'BIB005070',
	'International Children''s Bible / Youth & Teen') 
INSERT INTO temp_sgt_bisaccodes_2010 VALUES (
	'BIB006000',
	'King James Version / General') 
INSERT INTO temp_sgt_bisaccodes_2010 VALUES (
	'BIB006010',
	'King James Version / Children ')  
INSERT INTO temp_sgt_bisaccodes_2010 VALUES (
	'BIB006020',
	'King James Version / Devotional') 
INSERT INTO temp_sgt_bisaccodes_2010 VALUES (
	'BIB006030',
	'King James Version / New Testament & Portions') 
INSERT INTO temp_sgt_bisaccodes_2010 VALUES (
	'BIB006040',
	'King James Version / Reference')  
INSERT INTO temp_sgt_bisaccodes_2010 VALUES (
	'BIB006050',
	'King James Version / Study')  
INSERT INTO temp_sgt_bisaccodes_2010 VALUES (
	'BIB006060',
	'King James Version / Text') 
INSERT INTO temp_sgt_bisaccodes_2010 VALUES (
	'BIB006070',
	'King James Version / Youth & Teen') 
INSERT INTO temp_sgt_bisaccodes_2010 VALUES (
	'BIB007000',
	'La Biblia de las Americas / General  ') 
INSERT INTO temp_sgt_bisaccodes_2010 VALUES (
	'BIB007010',
	'La Biblia de las Americas / Children ') 
INSERT INTO temp_sgt_bisaccodes_2010 VALUES (
	'BIB007020',
	'La Biblia de las Americas / Devotional') 
INSERT INTO temp_sgt_bisaccodes_2010 VALUES (
	'BIB007030',
	'La Biblia de las Americas / New Testament & Portions') 
INSERT INTO temp_sgt_bisaccodes_2010 VALUES (
	'BIB007040',
	'La Biblia de las Americas / Reference') 
INSERT INTO temp_sgt_bisaccodes_2010 VALUES (
	'BIB007050',
	'La Biblia de las Americas / Study') 
INSERT INTO temp_sgt_bisaccodes_2010 VALUES (
	'BIB007060',
	'La Biblia de las Americas / Text')  
INSERT INTO temp_sgt_bisaccodes_2010 VALUES (
	'BIB007070',
	'La Biblia de las Americas / Youth & Teen ')  
INSERT INTO temp_sgt_bisaccodes_2010 VALUES (
	'BIB008000',
	'Multiple Translations / General') 
INSERT INTO temp_sgt_bisaccodes_2010 VALUES (
	'BIB008010',
	'Multiple Translations / Children')  
INSERT INTO temp_sgt_bisaccodes_2010 VALUES (
	'BIB008020',
	'Multiple Translations / Devotional   ') 
INSERT INTO temp_sgt_bisaccodes_2010 VALUES (
	'BIB008030',
	'Multiple Translations / New Testament & Portions')  
INSERT INTO temp_sgt_bisaccodes_2010 VALUES (
	'BIB008040',
	'Multiple Translations / Reference') 
INSERT INTO temp_sgt_bisaccodes_2010 VALUES (
	'BIB008050',
	'Multiple Translations / Study ')  
INSERT INTO temp_sgt_bisaccodes_2010 VALUES (
	'BIB008060',
	'Multiple Translations / Text') 
INSERT INTO temp_sgt_bisaccodes_2010 VALUES (
	'BIB008070',
	'Multiple Translations / Youth & Teen ') 
INSERT INTO temp_sgt_bisaccodes_2010 VALUES (
	'BIB009000',
	'New American Bible / General') 
INSERT INTO temp_sgt_bisaccodes_2010 VALUES (
	'BIB009010',
	'New American Bible / Children ')  
INSERT INTO temp_sgt_bisaccodes_2010 VALUES (
	'BIB009020',
	'New American Bible / Devotional') 
INSERT INTO temp_sgt_bisaccodes_2010 VALUES (
	'BIB009030',
	'New American Bible / New Testament & Portions') 
INSERT INTO temp_sgt_bisaccodes_2010 VALUES (
	'BIB009040',
	'New American Bible / Reference')  
INSERT INTO temp_sgt_bisaccodes_2010 VALUES (
	'BIB009050',
	'New American Bible / Study')  
INSERT INTO temp_sgt_bisaccodes_2010 VALUES (
	'BIB009060',
	'New American Bible / Text') 
INSERT INTO temp_sgt_bisaccodes_2010 VALUES (
	'BIB009070',
	'New American Bible / Youth & Teen') 
INSERT INTO temp_sgt_bisaccodes_2010 VALUES (
	'BIB010000',
	'New American Standard Bible / General') 
INSERT INTO temp_sgt_bisaccodes_2010 VALUES (
	'BIB010010',
	'New American Standard Bible / Children') 
INSERT INTO temp_sgt_bisaccodes_2010 VALUES (
	'BIB010020',
	'New American Standard Bible / Devotional ')  
INSERT INTO temp_sgt_bisaccodes_2010 VALUES (
	'BIB010030',
	'New American Standard Bible / New Testament & Portions   ') 
INSERT INTO temp_sgt_bisaccodes_2010 VALUES (
	'BIB010040',
	'New American Standard Bible / Reference  ')  
INSERT INTO temp_sgt_bisaccodes_2010 VALUES (
	'BIB010050',
	'New American Standard Bible / Study  ') 
INSERT INTO temp_sgt_bisaccodes_2010 VALUES (
	'BIB010060',
	'New American Standard Bible / Text   ') 
INSERT INTO temp_sgt_bisaccodes_2010 VALUES (
	'BIB010070',
	'New American Standard Bible / Youth & Teen') 
INSERT INTO temp_sgt_bisaccodes_2010 VALUES (
	'BIB011000',
	'New Century Version / General ')  
INSERT INTO temp_sgt_bisaccodes_2010 VALUES (
	'BIB011010',
	'New Century Version / Children')  
INSERT INTO temp_sgt_bisaccodes_2010 VALUES (
	'BIB011020',
	'New Century Version / Devotional')  
INSERT INTO temp_sgt_bisaccodes_2010 VALUES (
	'BIB011030',
	'New Century Version / New Testament & Portions')  
INSERT INTO temp_sgt_bisaccodes_2010 VALUES (
	'BIB011040',
	'New Century Version / Reference') 
INSERT INTO temp_sgt_bisaccodes_2010 VALUES (
	'BIB011050',
	'New Century Version / Study') 
INSERT INTO temp_sgt_bisaccodes_2010 VALUES (
	'BIB011060',
	'New Century Version / Text')  
INSERT INTO temp_sgt_bisaccodes_2010 VALUES (
	'BIB011070',
	'New Century Version / Youth & Teen   ') 
INSERT INTO temp_sgt_bisaccodes_2010 VALUES (
	'BIB012000',
	'New International Reader''s Version / General')  
INSERT INTO temp_sgt_bisaccodes_2010 VALUES (
	'BIB012010',
	'New International Reader''s Version / Children') 
INSERT INTO temp_sgt_bisaccodes_2010 VALUES (
	'BIB012020',
	'New International Reader''s Version / Devotional') 
INSERT INTO temp_sgt_bisaccodes_2010 VALUES (
	'BIB012030',
	'New International Reader''s Version / New Testament & Portions')  
INSERT INTO temp_sgt_bisaccodes_2010 VALUES (
	'BIB012040',
	'New International Reader''s Version / Reference')  
INSERT INTO temp_sgt_bisaccodes_2010 VALUES (
	'BIB012050',
	'New International Reader''s Version / Study') 
INSERT INTO temp_sgt_bisaccodes_2010 VALUES (
	'BIB012060',
	'New International Reader''s Version / Text')  
INSERT INTO temp_sgt_bisaccodes_2010 VALUES (
	'BIB012070',
	'New International Reader''s Version / Youth & Teen') 
INSERT INTO temp_sgt_bisaccodes_2010 VALUES (
	'BIB013000',
	'New International Version / General  ') 
INSERT INTO temp_sgt_bisaccodes_2010 VALUES (
	'BIB013010',
	'New International Version / Children ') 
INSERT INTO temp_sgt_bisaccodes_2010 VALUES (
	'BIB013020',
	'New International Version / Devotional') 
INSERT INTO temp_sgt_bisaccodes_2010 VALUES (
	'BIB013030',
	'New International Version / New Testament & Portions') 
INSERT INTO temp_sgt_bisaccodes_2010 VALUES (
	'BIB013040',
	'New International Version / Reference') 
INSERT INTO temp_sgt_bisaccodes_2010 VALUES (
	'BIB013050',
	'New International Version / Study') 
INSERT INTO temp_sgt_bisaccodes_2010 VALUES (
	'BIB013060',
	'New International Version / Text')  
INSERT INTO temp_sgt_bisaccodes_2010 VALUES (
	'BIB013070',
	'New International Version / Youth & Teen ')  
INSERT INTO temp_sgt_bisaccodes_2010 VALUES (
	'BIB014000',
	'New King James Version / General')  
INSERT INTO temp_sgt_bisaccodes_2010 VALUES (
	'BIB014010',
	'New King James Version / Children') 
INSERT INTO temp_sgt_bisaccodes_2010 VALUES (
	'BIB014020',
	'New King James Version / Devotional  ') 
INSERT INTO temp_sgt_bisaccodes_2010 VALUES (
	'BIB014030',
	'New King James Version / New Testament & Portions') 
INSERT INTO temp_sgt_bisaccodes_2010 VALUES (
	'BIB014040',
	'New King James Version / Reference   ') 
INSERT INTO temp_sgt_bisaccodes_2010 VALUES (
	'BIB014050',
	'New King James Version / Study')  
INSERT INTO temp_sgt_bisaccodes_2010 VALUES (
	'BIB014060',
	'New King James Version / Text ')  
INSERT INTO temp_sgt_bisaccodes_2010 VALUES (
	'BIB014070',
	'New King James Version / Youth & Teen') 
INSERT INTO temp_sgt_bisaccodes_2010 VALUES (
	'BIB015000',
	'New Living Translation / General')  
INSERT INTO temp_sgt_bisaccodes_2010 VALUES (
	'BIB015010',
	'New Living Translation / Children') 
INSERT INTO temp_sgt_bisaccodes_2010 VALUES (
	'BIB015020',
	'New Living Translation / Devotional  ') 
INSERT INTO temp_sgt_bisaccodes_2010 VALUES (
	'BIB015030',
	'New Living Translation / New Testament & Portions') 
INSERT INTO temp_sgt_bisaccodes_2010 VALUES (
	'BIB015040',
	'New Living Translation / Reference   ') 
INSERT INTO temp_sgt_bisaccodes_2010 VALUES (
	'BIB015050',
	'New Living Translation / Study')  
INSERT INTO temp_sgt_bisaccodes_2010 VALUES (
	'BIB015060',
	'New Living Translation / Text ')  
INSERT INTO temp_sgt_bisaccodes_2010 VALUES (
	'BIB015070',
	'New Living Translation / Youth & Teen') 
INSERT INTO temp_sgt_bisaccodes_2010 VALUES (
	'BIB016000',
	'New Revised Standard Version / General') 
INSERT INTO temp_sgt_bisaccodes_2010 VALUES (
	'BIB016010',
	'New Revised Standard Version / Children  ')  
INSERT INTO temp_sgt_bisaccodes_2010 VALUES (
	'BIB016020',
	'New Revised Standard Version / Devotional')  
INSERT INTO temp_sgt_bisaccodes_2010 VALUES (
	'BIB016030',
	'New Revised Standard Version / New Testament & Portions  ') 
INSERT INTO temp_sgt_bisaccodes_2010 VALUES (
	'BIB016040',
	'New Revised Standard Version / Reference ')  
INSERT INTO temp_sgt_bisaccodes_2010 VALUES (
	'BIB016050',
	'New Revised Standard Version / Study ') 
INSERT INTO temp_sgt_bisaccodes_2010 VALUES (
	'BIB016060',
	'New Revised Standard Version / Text  ') 
INSERT INTO temp_sgt_bisaccodes_2010 VALUES (
	'BIB016070',
	'New Revised Standard Version / Youth & Teen ')  
INSERT INTO temp_sgt_bisaccodes_2010 VALUES (
	'BIB017000',
	'Nueva Version International / General') 
INSERT INTO temp_sgt_bisaccodes_2010 VALUES (
	'BIB017010',
	'Nueva Version International / Children') 
INSERT INTO temp_sgt_bisaccodes_2010 VALUES (
	'BIB017020',
	'Nueva Version International / Devotional ')  
INSERT INTO temp_sgt_bisaccodes_2010 VALUES (
	'BIB017030',
	'Nueva Version International / New Testament & Portions   ') 
INSERT INTO temp_sgt_bisaccodes_2010 VALUES (
	'BIB017040',
	'Nueva Version International / Reference  ')  
INSERT INTO temp_sgt_bisaccodes_2010 VALUES (
	'BIB017050',
	'Nueva Version International / Study  ') 
INSERT INTO temp_sgt_bisaccodes_2010 VALUES (
	'BIB017060',
	'Nueva Version International / Text   ') 
INSERT INTO temp_sgt_bisaccodes_2010 VALUES (
	'BIB017070',
	'Nueva Version International / Youth & Teen') 
INSERT INTO temp_sgt_bisaccodes_2010 VALUES (
	'BIB018000',
	'Other Translations / General') 
INSERT INTO temp_sgt_bisaccodes_2010 VALUES (
	'BIB018010',
	'Other Translations / Children ')  
INSERT INTO temp_sgt_bisaccodes_2010 VALUES (
	'BIB018020',
	'Other Translations / Devotional') 
INSERT INTO temp_sgt_bisaccodes_2010 VALUES (
	'BIB018030',
	'Other Translations / New Testament & Portions') 
INSERT INTO temp_sgt_bisaccodes_2010 VALUES (
	'BIB018040',
	'Other Translations / Reference')  
INSERT INTO temp_sgt_bisaccodes_2010 VALUES (
	'BIB018050',
	'Other Translations / Study')  
INSERT INTO temp_sgt_bisaccodes_2010 VALUES (
	'BIB018060',
	'Other Translations / Text') 
INSERT INTO temp_sgt_bisaccodes_2010 VALUES (
	'BIB018070',
	'Other Translations / Youth & Teen') 
INSERT INTO temp_sgt_bisaccodes_2010 VALUES (
	'BIB019000',
	'Reina Valera / General') 
INSERT INTO temp_sgt_bisaccodes_2010 VALUES (
	'BIB019010',
	'Reina Valera / Children')   
INSERT INTO temp_sgt_bisaccodes_2010 VALUES (
	'BIB019020',
	'Reina Valera / Devotional') 
INSERT INTO temp_sgt_bisaccodes_2010 VALUES (
	'BIB019030',
	'Reina Valera / New Testament & Portions  ')  
INSERT INTO temp_sgt_bisaccodes_2010 VALUES (
	'BIB019040',
	'Reina Valera / Reference')  
INSERT INTO temp_sgt_bisaccodes_2010 VALUES (
	'BIB019050',
	'Reina Valera / Study') 
INSERT INTO temp_sgt_bisaccodes_2010 VALUES (
	'BIB019060',
	'Reina Valera / Text')  
INSERT INTO temp_sgt_bisaccodes_2010 VALUES (
	'BIB019070',
	'Reina Valera / Youth & Teen') 
INSERT INTO temp_sgt_bisaccodes_2010 VALUES (
	'BIB020000',
	'The Message / General')  
INSERT INTO temp_sgt_bisaccodes_2010 VALUES (
	'BIB020010',
	'The Message / Children') 
INSERT INTO temp_sgt_bisaccodes_2010 VALUES (
	'BIB020020',
	'The Message / Devotional')  
INSERT INTO temp_sgt_bisaccodes_2010 VALUES (
	'BIB020030',
	'The Message / New Testament & Portions') 
INSERT INTO temp_sgt_bisaccodes_2010 VALUES (
	'BIB020040',
	'The Message / Reference')   
INSERT INTO temp_sgt_bisaccodes_2010 VALUES (
	'BIB020050',
	'The Message / Study')  
INSERT INTO temp_sgt_bisaccodes_2010 VALUES (
	'BIB020060',
	'The Message / Text')  
INSERT INTO temp_sgt_bisaccodes_2010 VALUES (
	'BIB020070',
	'The Message / Youth & Teen')  
INSERT INTO temp_sgt_bisaccodes_2010 VALUES (
	'BIB021000',
	'Today''s New International Version / General ')  
INSERT INTO temp_sgt_bisaccodes_2010 VALUES (
	'BIB021010',
	'Today''s New International Version / Children')  
INSERT INTO temp_sgt_bisaccodes_2010 VALUES (
	'BIB021020',
	'Today''s New International Version / Devotional')  
INSERT INTO temp_sgt_bisaccodes_2010 VALUES (
	'BIB021030',
	'Today''s New International Version / New Testament & Portions ')  
INSERT INTO temp_sgt_bisaccodes_2010 VALUES (
	'BIB021040',
	'Today''s New International Version / Reference') 
INSERT INTO temp_sgt_bisaccodes_2010 VALUES (
	'BIB021050',
	'Today''s New International Version / Study')  
INSERT INTO temp_sgt_bisaccodes_2010 VALUES (
	'BIB021060',
	'Today''s New International Version / Text ')  
INSERT INTO temp_sgt_bisaccodes_2010 VALUES (
	'BIB021070',
	'Today''s New International Version / Youth & Teen')  
INSERT INTO temp_sgt_bisaccodes_2010 VALUES (
	'BIO000000',
	'General') 
INSERT INTO temp_sgt_bisaccodes_2010 VALUES (
	'BIO023000',
	'Adventurers & Explorers')   
INSERT INTO temp_sgt_bisaccodes_2010 VALUES (
	'BIO001000',
	'Artists, Architects, Photographers   ') 
INSERT INTO temp_sgt_bisaccodes_2010 VALUES (
	'BIO003000',
	'Business')  
INSERT INTO temp_sgt_bisaccodes_2010 VALUES (
	'BIO004000',
	'Composers & Musicians')  
INSERT INTO temp_sgt_bisaccodes_2010 VALUES (
	'BIO024000',
	'Criminals & Outlaws')  
INSERT INTO temp_sgt_bisaccodes_2010 VALUES (
	'BIO002000',
	'Cultural Heritage')   
INSERT INTO temp_sgt_bisaccodes_2010 VALUES (
	'BIO025000',
	'Editors, Journalists, Publishers')  
INSERT INTO temp_sgt_bisaccodes_2010 VALUES (
	'BIO019000',
	'Educators') 
INSERT INTO temp_sgt_bisaccodes_2010 VALUES (
	'BIO005000',
	'Entertainment & Performing Arts') 
INSERT INTO temp_sgt_bisaccodes_2010 VALUES (
	'BIO006000',
	'Historical ')  
INSERT INTO temp_sgt_bisaccodes_2010 VALUES (
	'BIO027000',
	'Law Enforcement')  
INSERT INTO temp_sgt_bisaccodes_2010 VALUES (
	'BIO020000',
	'Lawyers & Judges') 
INSERT INTO temp_sgt_bisaccodes_2010 VALUES (
	'BIO007000',
	'Literary')  
INSERT INTO temp_sgt_bisaccodes_2010 VALUES (
	'BIO017000',
	'Medical') 
INSERT INTO temp_sgt_bisaccodes_2010 VALUES (
	'BIO008000',
	'Military')  
INSERT INTO temp_sgt_bisaccodes_2010 VALUES (
	'BIO028000',
	'Native Americans') 
INSERT INTO temp_sgt_bisaccodes_2010 VALUES (
	'BIO026000',
	'Personal Memoirs') 
INSERT INTO temp_sgt_bisaccodes_2010 VALUES (
	'BIO009000',
	'Philosophers') 
INSERT INTO temp_sgt_bisaccodes_2010 VALUES (
	'BIO010000',
	'Political') 
INSERT INTO temp_sgt_bisaccodes_2010 VALUES (
	'BIO011000',
	'Presidents & Heads of State') 
INSERT INTO temp_sgt_bisaccodes_2010 VALUES (
	'BIO012000',
	'Reference') 
INSERT INTO temp_sgt_bisaccodes_2010 VALUES (
	'BIO018000',
	'Religious') 
INSERT INTO temp_sgt_bisaccodes_2010 VALUES (
	'BIO013000',
	'Rich & Famous')  
INSERT INTO temp_sgt_bisaccodes_2010 VALUES (
	'BIO014000',
	'Royalty') 
INSERT INTO temp_sgt_bisaccodes_2010 VALUES (
	'BIO015000',
	'Science & Technology') 
INSERT INTO temp_sgt_bisaccodes_2010 VALUES (
	'BIO021000',
	'Social Scientists & Psychologists') 
INSERT INTO temp_sgt_bisaccodes_2010 VALUES (
	'BIO016000',
	'Sports')  
INSERT INTO temp_sgt_bisaccodes_2010 VALUES (
	'BIO022000',
	'Women') 
INSERT INTO temp_sgt_bisaccodes_2010 VALUES (
	'OCC000000',
	'General') 
INSERT INTO temp_sgt_bisaccodes_2010 VALUES (
	'OCC032000',
	'Angels & Spirit Guides') 
INSERT INTO temp_sgt_bisaccodes_2010 VALUES (
	'OCC002000',
	'Astrology / General')  
INSERT INTO temp_sgt_bisaccodes_2010 VALUES (
	'OCC030000',
	'Astrology / Eastern')  
INSERT INTO temp_sgt_bisaccodes_2010 VALUES (
	'OCC009000',
	'Astrology / Horoscopes') 
INSERT INTO temp_sgt_bisaccodes_2010 VALUES (
	'OCC003000',
	'Channeling ')  
INSERT INTO temp_sgt_bisaccodes_2010 VALUES (
	'OCC004000',
	'Crystals')  
INSERT INTO temp_sgt_bisaccodes_2010 VALUES (
	'OCC005000',
	'Divination / General') 
INSERT INTO temp_sgt_bisaccodes_2010 VALUES (
	'OCC008000',
	'Divination / Fortune Telling') 
INSERT INTO temp_sgt_bisaccodes_2010 VALUES (
	'OCC017000',
	'Divination / Palmistry') 
INSERT INTO temp_sgt_bisaccodes_2010 VALUES (
	'OCC024000',
	'Divination / Tarot')  
INSERT INTO temp_sgt_bisaccodes_2010 VALUES (
	'OCC006000',
	'Dreams')  
INSERT INTO temp_sgt_bisaccodes_2010 VALUES (
	'OCC037000',
	'Feng Shui') 
INSERT INTO temp_sgt_bisaccodes_2010 VALUES (
	'OCC033000',
	'Gaia & Earth Energies')  
INSERT INTO temp_sgt_bisaccodes_2010 VALUES (
	'OCC011000',
	'Healing / General')   
INSERT INTO temp_sgt_bisaccodes_2010 VALUES (
	'OCC011010',
	'Healing / Energy (Qigong, Reiki, Polarity)')  
INSERT INTO temp_sgt_bisaccodes_2010 VALUES (
	'OCC011020',
	'Healing / Prayer & Spiritual') 
INSERT INTO temp_sgt_bisaccodes_2010 VALUES (
	'OCC038000',
	'I Ching') 
INSERT INTO temp_sgt_bisaccodes_2010 VALUES (
	'OCC019000',
	'Inspiration & Personal Growth ')  
INSERT INTO temp_sgt_bisaccodes_2010 VALUES (
	'OCC028000',
	'Magick Studies') 
INSERT INTO temp_sgt_bisaccodes_2010 VALUES (
	'OCC010000',
	'Meditation ')  
INSERT INTO temp_sgt_bisaccodes_2010 VALUES (
	'OCC012000',
	'Mysticism') 
INSERT INTO temp_sgt_bisaccodes_2010 VALUES (
	'OCC031000',
	'Ancient Mysteries & Controversial Knowledge') 
INSERT INTO temp_sgt_bisaccodes_2010 VALUES (
	'OCC014000',
	'New Thought')  
INSERT INTO temp_sgt_bisaccodes_2010 VALUES (
	'OCC015000',
	'Numerology ')  
INSERT INTO temp_sgt_bisaccodes_2010 VALUES (
	'OCC016000',
	'Occultism') 
INSERT INTO temp_sgt_bisaccodes_2010 VALUES (
	'OCC018000',
	'Parapsychology / General')  
INSERT INTO temp_sgt_bisaccodes_2010 VALUES (
	'OCC007000',
	'Parapsychology / ESP (Clairvoyance, Precognition, Telepathy) ')  
INSERT INTO temp_sgt_bisaccodes_2010 VALUES (
	'OCC034000',
	'Parapsychology / Near-Death Experience') 
INSERT INTO temp_sgt_bisaccodes_2010 VALUES (
	'OCC035000',
	'Parapsychology / Out-of-Body Experience  ')  
INSERT INTO temp_sgt_bisaccodes_2010 VALUES (
	'OCC020000',
	'Prophecy')  
INSERT INTO temp_sgt_bisaccodes_2010 VALUES (
	'OCC021000',
	'Reference') 
INSERT INTO temp_sgt_bisaccodes_2010 VALUES (
	'OCC022000',
	'Reincarnation')  
INSERT INTO temp_sgt_bisaccodes_2010 VALUES (
	'OCC027000',
	'Spiritualism') 
INSERT INTO temp_sgt_bisaccodes_2010 VALUES (
	'OCC036000',
	'Spirituality / General') 
INSERT INTO temp_sgt_bisaccodes_2010 VALUES (
	'OCC036010',
	'Spirituality / Celtic')  
INSERT INTO temp_sgt_bisaccodes_2010 VALUES (
	'OCC036050',
	'Spirituality / Divine Mother, The Goddess, Quan Yin')  
INSERT INTO temp_sgt_bisaccodes_2010 VALUES (
	'OCC036040',
	'Spirituality / Greco-Roman')  
INSERT INTO temp_sgt_bisaccodes_2010 VALUES (
	'OCC036020',
	'Spirituality / Paganism & Neo-Paganism') 
INSERT INTO temp_sgt_bisaccodes_2010 VALUES (
	'OCC036030',
	'Spirituality / Shamanism')  
INSERT INTO temp_sgt_bisaccodes_2010 VALUES (
	'OCC023000',
	'Supernatural') 
INSERT INTO temp_sgt_bisaccodes_2010 VALUES (
	'OCC025000',
	'UFOs & Extraterrestrials')  
INSERT INTO temp_sgt_bisaccodes_2010 VALUES (
	'OCC029000',
	'Unexplained Phenomena')  
INSERT INTO temp_sgt_bisaccodes_2010 VALUES (
	'OCC026000',
	'Witchcraft & Wicca')  
INSERT INTO temp_sgt_bisaccodes_2010 VALUES (
	'BUS000000',
	'General') 
INSERT INTO temp_sgt_bisaccodes_2010 VALUES (
	'BUS001000',
	'Accounting / General') 
INSERT INTO temp_sgt_bisaccodes_2010 VALUES (
	'BUS001010',
	'Accounting / Financial') 
INSERT INTO temp_sgt_bisaccodes_2010 VALUES (
	'BUS001020',
	'Accounting / Governmental') 
INSERT INTO temp_sgt_bisaccodes_2010 VALUES (
	'BUS001040',
	'Accounting / Managerial')   
INSERT INTO temp_sgt_bisaccodes_2010 VALUES (
	'BUS002000',
	'Advertising & Promotion')   
INSERT INTO temp_sgt_bisaccodes_2010 VALUES (
	'BUS003000',
	'Auditing')  
INSERT INTO temp_sgt_bisaccodes_2010 VALUES (
	'BUS004000',
	'Banks & Banking')  
INSERT INTO temp_sgt_bisaccodes_2010 VALUES (
	'BUS005000',
	'Bookkeeping')  
INSERT INTO temp_sgt_bisaccodes_2010 VALUES (
	'BUS006000',
	'Budgeting') 
INSERT INTO temp_sgt_bisaccodes_2010 VALUES (
	'BUS007000',
	'Business Communication / General')  
INSERT INTO temp_sgt_bisaccodes_2010 VALUES (
	'BUS007010',
	'Business Communication / Meetings & Presentations') 
INSERT INTO temp_sgt_bisaccodes_2010 VALUES (
	'BUS008000',
	'Business Ethics')  
INSERT INTO temp_sgt_bisaccodes_2010 VALUES (
	'BUS009000',
	'Business Etiquette')  
INSERT INTO temp_sgt_bisaccodes_2010 VALUES (
	'BUS010000',
	'Business Law') 
INSERT INTO temp_sgt_bisaccodes_2010 VALUES (
	'BUS091000',
	'Business Mathematics') 
INSERT INTO temp_sgt_bisaccodes_2010 VALUES (
	'BUS011000',
	'Business Writing') 
INSERT INTO temp_sgt_bisaccodes_2010 VALUES (
	'BUS012000',
	'Careers / General')   
INSERT INTO temp_sgt_bisaccodes_2010 VALUES (
	'BUS037020',
	'Careers / Job Hunting')  
INSERT INTO temp_sgt_bisaccodes_2010 VALUES (
	'BUS056030',
	'Careers / Resumes')   
INSERT INTO temp_sgt_bisaccodes_2010 VALUES (
	'BUS073000',
	'Commerce')  
INSERT INTO temp_sgt_bisaccodes_2010 VALUES (
	'BUS013000',
	'Commercial Policy')   
INSERT INTO temp_sgt_bisaccodes_2010 VALUES (
	'BUS014000',
	'Investments & Securities / Commodities')  
INSERT INTO temp_sgt_bisaccodes_2010 VALUES (
	'BUS075000',
	'Consulting ')  
INSERT INTO temp_sgt_bisaccodes_2010 VALUES (
	'BUS016000',
	'Consumer Behavior')   
INSERT INTO temp_sgt_bisaccodes_2010 VALUES (
	'BUS077000',
	'Corporate & Business History') 
INSERT INTO temp_sgt_bisaccodes_2010 VALUES (
	'BUS017000',
	'Corporate Finance')   
INSERT INTO temp_sgt_bisaccodes_2010 VALUES (
	'BUS018000',
	'Customer Relations')  
INSERT INTO temp_sgt_bisaccodes_2010 VALUES (
	'BUS019000',
	'Decision-Making & Problem Solving') 
INSERT INTO temp_sgt_bisaccodes_2010 VALUES (
	'BUS092000',
	'Development / General')  
INSERT INTO temp_sgt_bisaccodes_2010 VALUES (
	'BUS020000',
	'Development / Business Development   ') 
INSERT INTO temp_sgt_bisaccodes_2010 VALUES (
	'BUS068000',
	'Development / Economic Development   ') 
INSERT INTO temp_sgt_bisaccodes_2010 VALUES (
	'BUS072000',
	'Development / Sustainable Development') 
INSERT INTO temp_sgt_bisaccodes_2010 VALUES (
	'BUS078000',
	'Distribution') 
INSERT INTO temp_sgt_bisaccodes_2010 VALUES (
	'BUS090000',
	'E-Commerce / General (see also COMPUTERS / Electronic Commerce) ')  
INSERT INTO temp_sgt_bisaccodes_2010 VALUES (
	'BUS090010',
	'E-Commerce / Internet Marketing') 
INSERT INTO temp_sgt_bisaccodes_2010 VALUES (
	'BUS090020',
	'E-Commerce / Online Banking') 
INSERT INTO temp_sgt_bisaccodes_2010 VALUES (
	'BUS090030',
	'E-Commerce / Online Trading') 
INSERT INTO temp_sgt_bisaccodes_2010 VALUES (
	'BUS021000',
	'Econometrics') 
INSERT INTO temp_sgt_bisaccodes_2010 VALUES (
	'BUS022000',
	'Economic Conditions')  
INSERT INTO temp_sgt_bisaccodes_2010 VALUES (
	'BUS023000',
	'Economic History') 
INSERT INTO temp_sgt_bisaccodes_2010 VALUES (
	'BUS069000',
	'Economics / General')  
INSERT INTO temp_sgt_bisaccodes_2010 VALUES (
	'BUS069010',
	'Economics / Comparative')   
INSERT INTO temp_sgt_bisaccodes_2010 VALUES (
	'BUS039000',
	'Economics / Macroeconomics')  
INSERT INTO temp_sgt_bisaccodes_2010 VALUES (
	'BUS044000',
	'Economics / Microeconomics')  
INSERT INTO temp_sgt_bisaccodes_2010 VALUES (
	'BUS069030',
	'Economics / Theory')  
INSERT INTO temp_sgt_bisaccodes_2010 VALUES (
	'BUS024000',
	'Education') 
INSERT INTO temp_sgt_bisaccodes_2010 VALUES (
	'BUS025000',
	'Entrepreneurship') 
INSERT INTO temp_sgt_bisaccodes_2010 VALUES (
	'BUS099000',
	'Environmental Economics')   
INSERT INTO temp_sgt_bisaccodes_2010 VALUES (
	'BUS026000',
	'Exports & Imports')   
INSERT INTO temp_sgt_bisaccodes_2010 VALUES (
	'BUS093000',
	'Facility Management')  
INSERT INTO temp_sgt_bisaccodes_2010 VALUES (
	'BUS027000',
	'Finance') 
INSERT INTO temp_sgt_bisaccodes_2010 VALUES (
	'BUS086000',
	'Forecasting')  
INSERT INTO temp_sgt_bisaccodes_2010 VALUES (
	'BUS028000',
	'Foreign Exchange') 
INSERT INTO temp_sgt_bisaccodes_2010 VALUES (
	'BUS029000',
	'Free Enterprise')  
INSERT INTO temp_sgt_bisaccodes_2010 VALUES (
	'BUS079000',
	'Government & Business')  
INSERT INTO temp_sgt_bisaccodes_2010 VALUES (
	'BUS094000',
	'Green Business') 
INSERT INTO temp_sgt_bisaccodes_2010 VALUES (
	'BUS080000',
	'Home-Based Businesses')  
INSERT INTO temp_sgt_bisaccodes_2010 VALUES (
	'BUS030000',
	'Human Resources & Personnel Management') 
INSERT INTO temp_sgt_bisaccodes_2010 VALUES (
	'BUS082000',
	'Industrial Management')  
INSERT INTO temp_sgt_bisaccodes_2010 VALUES (
	'BUS070000',
	'Industries / General') 
INSERT INTO temp_sgt_bisaccodes_2010 VALUES (
	'BUS070010',
	'Industries / Agribusiness') 
INSERT INTO temp_sgt_bisaccodes_2010 VALUES (
	'BUS070020',
	'Industries / Automobile Industry')  
INSERT INTO temp_sgt_bisaccodes_2010 VALUES (
	'BUS070030',
	'Industries / Computer Industry')  
INSERT INTO temp_sgt_bisaccodes_2010 VALUES (
	'BUS070040',
	'Industries / Energy')  
INSERT INTO temp_sgt_bisaccodes_2010 VALUES (
	'BUS070090',
	'Industries / Fashion & Textile Industry  ')  
INSERT INTO temp_sgt_bisaccodes_2010 VALUES (
	'BUS081000',
	'Industries / Hospitality, Travel & Tourism') 
INSERT INTO temp_sgt_bisaccodes_2010 VALUES (
	'BUS070050',
	'Industries / Manufacturing') 
INSERT INTO temp_sgt_bisaccodes_2010 VALUES (
	'BUS070060',
	'Industries / Media & Communications')  
INSERT INTO temp_sgt_bisaccodes_2010 VALUES (
	'BUS070070',
	'Industries / Park & Recreation Management')  
INSERT INTO temp_sgt_bisaccodes_2010 VALUES (
	'BUS057000',
	'Industries / Retailing') 
INSERT INTO temp_sgt_bisaccodes_2010 VALUES (
	'BUS070080',
	'Industries / Service') 
INSERT INTO temp_sgt_bisaccodes_2010 VALUES (
	'BUS070100',
	'Industries / Transportation') 
INSERT INTO temp_sgt_bisaccodes_2010 VALUES (
	'BUS031000',
	'Inflation') 
INSERT INTO temp_sgt_bisaccodes_2010 VALUES (
	'BUS083000',
	'Information Management') 
INSERT INTO temp_sgt_bisaccodes_2010 VALUES (
	'BUS032000',
	'Infrastructure') 
INSERT INTO temp_sgt_bisaccodes_2010 VALUES (
	'BUS033000',
	'Insurance / General')  
INSERT INTO temp_sgt_bisaccodes_2010 VALUES (
	'BUS033010',
	'Insurance / Automobile') 
INSERT INTO temp_sgt_bisaccodes_2010 VALUES (
	'BUS033020',
	'Insurance / Casualty') 
INSERT INTO temp_sgt_bisaccodes_2010 VALUES (
	'BUS033040',
	'Insurance / Health')  
INSERT INTO temp_sgt_bisaccodes_2010 VALUES (
	'BUS033050',
	'Insurance / Liability')  
INSERT INTO temp_sgt_bisaccodes_2010 VALUES (
	'BUS033060',
	'Insurance / Life') 
INSERT INTO temp_sgt_bisaccodes_2010 VALUES (
	'BUS033080',
	'Insurance / Property') 
INSERT INTO temp_sgt_bisaccodes_2010 VALUES (
	'BUS033070',
	'Insurance / Risk Assessment & Management ')  
INSERT INTO temp_sgt_bisaccodes_2010 VALUES (
	'BUS034000',
	'Interest')  
INSERT INTO temp_sgt_bisaccodes_2010 VALUES (
	'BUS035000',
	'International / General')   
INSERT INTO temp_sgt_bisaccodes_2010 VALUES (
	'BUS001030',
	'International / Accounting')  
INSERT INTO temp_sgt_bisaccodes_2010 VALUES (
	'BUS069020',
	'International / Economics') 
INSERT INTO temp_sgt_bisaccodes_2010 VALUES (
	'BUS043030',
	'International / Marketing') 
INSERT INTO temp_sgt_bisaccodes_2010 VALUES (
	'BUS064020',
	'International / Taxation')  
INSERT INTO temp_sgt_bisaccodes_2010 VALUES (
	'BUS036000',
	'Investments & Securities / General')  
INSERT INTO temp_sgt_bisaccodes_2010 VALUES (
	'BUS098000',
	'Knowledge Capital')   
INSERT INTO temp_sgt_bisaccodes_2010 VALUES (
	'BUS038000',
	'Labor') 
INSERT INTO temp_sgt_bisaccodes_2010 VALUES (
	'BUS071000',
	'Leadership ')  
INSERT INTO temp_sgt_bisaccodes_2010 VALUES (
	'BUS040000',
	'Mail Order ')  
INSERT INTO temp_sgt_bisaccodes_2010 VALUES (
	'BUS041000',
	'Management ')  
INSERT INTO temp_sgt_bisaccodes_2010 VALUES (
	'BUS042000',
	'Management Science')  
INSERT INTO temp_sgt_bisaccodes_2010 VALUES (
	'BUS043000',
	'Marketing / General')  
INSERT INTO temp_sgt_bisaccodes_2010 VALUES (
	'BUS043010',
	'Marketing / Direct')  
INSERT INTO temp_sgt_bisaccodes_2010 VALUES (
	'BUS043020',
	'Marketing / Industrial') 
INSERT INTO temp_sgt_bisaccodes_2010 VALUES (
	'BUS043040',
	'Marketing / Multilevel') 
INSERT INTO temp_sgt_bisaccodes_2010 VALUES (
	'BUS043060',
	'Marketing / Research') 
INSERT INTO temp_sgt_bisaccodes_2010 VALUES (
	'BUS043050',
	'Marketing / Telemarketing') 
INSERT INTO temp_sgt_bisaccodes_2010 VALUES (
	'BUS015000',
	'Mergers & Acquisitions') 
INSERT INTO temp_sgt_bisaccodes_2010 VALUES (
	'BUS045000',
	'Money & Monetary Policy')   
INSERT INTO temp_sgt_bisaccodes_2010 VALUES (
	'BUS046000',
	'Motivational') 
INSERT INTO temp_sgt_bisaccodes_2010 VALUES (
	'BUS100000',
	'Museum Administration & Museology') 
INSERT INTO temp_sgt_bisaccodes_2010 VALUES (
	'BUS047000',
	'Negotiating')  
INSERT INTO temp_sgt_bisaccodes_2010 VALUES (
	'BUS048000',
	'New Business Enterprises')  
INSERT INTO temp_sgt_bisaccodes_2010 VALUES (
	'BUS074000',
	'Nonprofit Organizations & Charities  ') 
INSERT INTO temp_sgt_bisaccodes_2010 VALUES (
	'BUS084000',
	'Office Automation')   
INSERT INTO temp_sgt_bisaccodes_2010 VALUES (
	'BUS095000',
	'Office Equipment & Supplies') 
INSERT INTO temp_sgt_bisaccodes_2010 VALUES (
	'BUS096000',
	'Office Management')   
INSERT INTO temp_sgt_bisaccodes_2010 VALUES (
	'BUS049000',
	'Operations Research')  
INSERT INTO temp_sgt_bisaccodes_2010 VALUES (
	'BUS085000',
	'Organizational Behavior')   
INSERT INTO temp_sgt_bisaccodes_2010 VALUES (
	'BUS103000',
	'Organizational Development')  
INSERT INTO temp_sgt_bisaccodes_2010 VALUES (
	'BUS102000',
	'Outsourcing')  
INSERT INTO temp_sgt_bisaccodes_2010 VALUES (
	'BUS050000',
	'Personal Finance / General')  
INSERT INTO temp_sgt_bisaccodes_2010 VALUES (
	'BUS050010',
	'Personal Finance / Budgeting') 
INSERT INTO temp_sgt_bisaccodes_2010 VALUES (
	'BUS050020',
	'Personal Finance / Investing') 
INSERT INTO temp_sgt_bisaccodes_2010 VALUES (
	'BUS050030',
	'Personal Finance / Money Management  ') 
INSERT INTO temp_sgt_bisaccodes_2010 VALUES (
	'BUS050040',
	'Personal Finance / Retirement Planning') 
INSERT INTO temp_sgt_bisaccodes_2010 VALUES (
	'BUS050050',
	'Personal Finance / Taxation') 
INSERT INTO temp_sgt_bisaccodes_2010 VALUES (
	'BUS087000',
	'Production & Operations Management   ') 
INSERT INTO temp_sgt_bisaccodes_2010 VALUES (
	'BUS101000',
	'Project Management')  
INSERT INTO temp_sgt_bisaccodes_2010 VALUES (
	'BUS051000',
	'Public Finance') 
INSERT INTO temp_sgt_bisaccodes_2010 VALUES (
	'BUS052000',
	'Public Relations') 
INSERT INTO temp_sgt_bisaccodes_2010 VALUES (
	'BUS076000',
	'Purchasing & Buying')  
INSERT INTO temp_sgt_bisaccodes_2010 VALUES (
	'BUS053000',
	'Quality Control')  
INSERT INTO temp_sgt_bisaccodes_2010 VALUES (
	'BUS054000',
	'Real Estate / General')  
INSERT INTO temp_sgt_bisaccodes_2010 VALUES (
	'BUS055000',
	'Reference') 
INSERT INTO temp_sgt_bisaccodes_2010 VALUES (
	'BUS058000',
	'Sales & Selling / General')  
INSERT INTO temp_sgt_bisaccodes_2010 VALUES (
	'BUS089000',
	'Secretarial Aids & Training') 
INSERT INTO temp_sgt_bisaccodes_2010 VALUES (
	'BUS059000',
	'Skills')  
INSERT INTO temp_sgt_bisaccodes_2010 VALUES (
	'BUS060000',
	'Small Business') 
INSERT INTO temp_sgt_bisaccodes_2010 VALUES (
	'BUS061000',
	'Statistics ')  
INSERT INTO temp_sgt_bisaccodes_2010 VALUES (
	'BUS063000',
	'Strategic Planning')  
INSERT INTO temp_sgt_bisaccodes_2010 VALUES (
	'BUS062000',
	'Structural Adjustment')  
INSERT INTO temp_sgt_bisaccodes_2010 VALUES (
	'BUS064000',
	'Taxation / General')  
INSERT INTO temp_sgt_bisaccodes_2010 VALUES (
	'BUS064010',
	'Taxation / Corporate') 
INSERT INTO temp_sgt_bisaccodes_2010 VALUES (
	'BUS064030',
	'Taxation / Small Business') 
INSERT INTO temp_sgt_bisaccodes_2010 VALUES (
	'BUS088000',
	'Time Management')  
INSERT INTO temp_sgt_bisaccodes_2010 VALUES (
	'BUS065000',
	'Total Quality Management')  
INSERT INTO temp_sgt_bisaccodes_2010 VALUES (
	'BUS066000',
	'Training')  
INSERT INTO temp_sgt_bisaccodes_2010 VALUES (
	'BUS067000',
	'Urban & Regional') 
INSERT INTO temp_sgt_bisaccodes_2010 VALUES (
	'BUS097000',
	'Workplace Culture')   
INSERT INTO temp_sgt_bisaccodes_2010 VALUES (
	'CGN000000',
	'General') 
INSERT INTO temp_sgt_bisaccodes_2010 VALUES (
	'CGN001000',
	'Anthologies')  
INSERT INTO temp_sgt_bisaccodes_2010 VALUES (
	'CGN008000',
	'Contemporary Women')  
INSERT INTO temp_sgt_bisaccodes_2010 VALUES (
	'CGN004010',
	'Crime & Mystery')  
INSERT INTO temp_sgt_bisaccodes_2010 VALUES (
	'CGN004020',
	'Erotica') 
INSERT INTO temp_sgt_bisaccodes_2010 VALUES (
	'CGN004030',
	'Fantasy') 
INSERT INTO temp_sgt_bisaccodes_2010 VALUES (
	'CGN009000',
	'Gay & Lesbian')  
INSERT INTO temp_sgt_bisaccodes_2010 VALUES (
	'CGN004040',
	'Horror')  
INSERT INTO temp_sgt_bisaccodes_2010 VALUES (
	'CGN006000',
	'Literary')  
INSERT INTO temp_sgt_bisaccodes_2010 VALUES (
	'CGN004050',
	'Manga / General')  
INSERT INTO temp_sgt_bisaccodes_2010 VALUES (
	'CGN004100',
	'Manga / Crime & Mystery')   
INSERT INTO temp_sgt_bisaccodes_2010 VALUES (
	'CGN004110',
	'Manga / Erotica')  
INSERT INTO temp_sgt_bisaccodes_2010 VALUES (
	'CGN004120',
	'Manga / Fantasy')  
INSERT INTO temp_sgt_bisaccodes_2010 VALUES (
	'CGN004130',
	'Manga / Gay & Lesbian')  
INSERT INTO temp_sgt_bisaccodes_2010 VALUES (
	'CGN004140',
	'Manga / Historical Fiction')  
INSERT INTO temp_sgt_bisaccodes_2010 VALUES (
	'CGN004150',
	'Manga / Horror') 
INSERT INTO temp_sgt_bisaccodes_2010 VALUES (
	'CGN004160',
	'Manga / Media Tie-In') 
INSERT INTO temp_sgt_bisaccodes_2010 VALUES (
	'CGN004170',
	'Manga / Nonfiction')  
INSERT INTO temp_sgt_bisaccodes_2010 VALUES (
	'CGN004180',
	'Manga / Romance')  
INSERT INTO temp_sgt_bisaccodes_2010 VALUES (
	'CGN004190',
	'Manga / Science Fiction')   
INSERT INTO temp_sgt_bisaccodes_2010 VALUES (
	'CGN004200',
	'Manga / Sports') 
INSERT INTO temp_sgt_bisaccodes_2010 VALUES (
	'CGN004060',
	'Media Tie-In') 
INSERT INTO temp_sgt_bisaccodes_2010 VALUES (
	'CGN007000',
	'Nonfiction ')  
INSERT INTO temp_sgt_bisaccodes_2010 VALUES (
	'CGN004090',
	'Romance') 
INSERT INTO temp_sgt_bisaccodes_2010 VALUES (
	'CGN004070',
	'Science Fiction')  
INSERT INTO temp_sgt_bisaccodes_2010 VALUES (
	'CGN004080',
	'Superheroes')  
INSERT INTO temp_sgt_bisaccodes_2010 VALUES (
	'COM000000',
	'General') 
INSERT INTO temp_sgt_bisaccodes_2010 VALUES (
	'COM082000',
	'Bioinformatics') 
INSERT INTO temp_sgt_bisaccodes_2010 VALUES (
	'COM006000',
	'Buyer''s Guides') 
INSERT INTO temp_sgt_bisaccodes_2010 VALUES (
	'COM007000',
	'CAD-CAM') 
INSERT INTO temp_sgt_bisaccodes_2010 VALUES (
	'COM008000',
	'Calculators')  
INSERT INTO temp_sgt_bisaccodes_2010 VALUES (
	'COM009000',
	'CD-DVD Technology')   
INSERT INTO temp_sgt_bisaccodes_2010 VALUES (
	'COM055000',
	'Certification Guides / General')  
INSERT INTO temp_sgt_bisaccodes_2010 VALUES (
	'COM055010',
	'Certification Guides / A+') 
INSERT INTO temp_sgt_bisaccodes_2010 VALUES (
	'COM055020',
	'Certification Guides / MCSE') 
INSERT INTO temp_sgt_bisaccodes_2010 VALUES (
	'COM061000',
	'Client-Server Computing')   
INSERT INTO temp_sgt_bisaccodes_2010 VALUES (
	'COM010000',
	'Compilers') 
INSERT INTO temp_sgt_bisaccodes_2010 VALUES (
	'COM059000',
	'Computer Engineering') 
INSERT INTO temp_sgt_bisaccodes_2010 VALUES (
	'COM012000',
	'Computer Graphics')   
INSERT INTO temp_sgt_bisaccodes_2010 VALUES (
	'COM013000',
	'Computer Literacy')   
INSERT INTO temp_sgt_bisaccodes_2010 VALUES (
	'COM014000',
	'Computer Science') 
INSERT INTO temp_sgt_bisaccodes_2010 VALUES (
	'COM072000',
	'Computer Simulation')  
INSERT INTO temp_sgt_bisaccodes_2010 VALUES (
	'COM016000',
	'Computer Vision & Pattern Recognition') 
INSERT INTO temp_sgt_bisaccodes_2010 VALUES (
	'COM086000',
	'Computerized Home & Entertainment') 
INSERT INTO temp_sgt_bisaccodes_2010 VALUES (
	'COM017000',
	'Cybernetics')  
INSERT INTO temp_sgt_bisaccodes_2010 VALUES (
	'COM062000',
	'Data Modeling & Design') 
INSERT INTO temp_sgt_bisaccodes_2010 VALUES (
	'COM018000',
	'Data Processing')  
INSERT INTO temp_sgt_bisaccodes_2010 VALUES (
	'COM020000',
	'Data Transmission Systems / General  ') 
INSERT INTO temp_sgt_bisaccodes_2010 VALUES (
	'COM020050',
	'Data Transmission Systems / Broadband') 
INSERT INTO temp_sgt_bisaccodes_2010 VALUES (
	'COM020010',
	'Data Transmission Systems / Electronic Data Interchange') 
INSERT INTO temp_sgt_bisaccodes_2010 VALUES (
	'COM020090',
	'Data Transmission Systems / Wireless') 
INSERT INTO temp_sgt_bisaccodes_2010 VALUES (
	'COM021000',
	'Database Management / General')  
INSERT INTO temp_sgt_bisaccodes_2010 VALUES (
	'COM021030',
	'Database Management / Data Mining') 
INSERT INTO temp_sgt_bisaccodes_2010 VALUES (
	'COM021040',
	'Database Management / Data Warehousing') 
INSERT INTO temp_sgt_bisaccodes_2010 VALUES (
	'COM084000',
	'Desktop Applications / General')  
INSERT INTO temp_sgt_bisaccodes_2010 VALUES (
	'COM084010',
	'Desktop Applications / Databases')  
INSERT INTO temp_sgt_bisaccodes_2010 VALUES (
	'COM084020',
	'Desktop Applications / Email Clients ') 
INSERT INTO temp_sgt_bisaccodes_2010 VALUES (
	'COM027000',
	'Desktop Applications / Personal Finance Applications') 
INSERT INTO temp_sgt_bisaccodes_2010 VALUES (
	'COM078000',
	'Desktop Applications / Presentation Software')  
INSERT INTO temp_sgt_bisaccodes_2010 VALUES (
	'COM081000',
	'Desktop Applications / Project Management Software') 
INSERT INTO temp_sgt_bisaccodes_2010 VALUES (
	'COM054000',
	'Desktop Applications / Spreadsheets  ') 
INSERT INTO temp_sgt_bisaccodes_2010 VALUES (
	'COM084030',
	'Desktop Applications / Suites ')  
INSERT INTO temp_sgt_bisaccodes_2010 VALUES (
	'COM058000',
	'Desktop Applications / Word Processing') 
INSERT INTO temp_sgt_bisaccodes_2010 VALUES (
	'COM087000',
	'Digital Media / General')   
INSERT INTO temp_sgt_bisaccodes_2010 VALUES (
	'COM087010',
	'Digital Media / Audio')  
INSERT INTO temp_sgt_bisaccodes_2010 VALUES (
	'COM022000',
	'Digital Media / Desktop Publishing   ') 
INSERT INTO temp_sgt_bisaccodes_2010 VALUES (
	'COM087020',
	'Digital Media / Graphics Applications') 
INSERT INTO temp_sgt_bisaccodes_2010 VALUES (
	'COM087030',
	'Digital Media / Photography (see also PHOTOGRAPHY / Techniques / Digital)') 
INSERT INTO temp_sgt_bisaccodes_2010 VALUES (
	'COM071000',
	'Digital Media / Video & Animation') 
INSERT INTO temp_sgt_bisaccodes_2010 VALUES (
	'COM063000',
	'Document Management')  
INSERT INTO temp_sgt_bisaccodes_2010 VALUES (
	'COM085000',
	'Documentation & Technical Writing') 
INSERT INTO temp_sgt_bisaccodes_2010 VALUES (
	'COM023000',
	'Educational Software') 
INSERT INTO temp_sgt_bisaccodes_2010 VALUES (
	'COM064000',
	'Electronic Commerce (see also headings under BUSINESS & ECONOMICS / E-Commerce) ') 
INSERT INTO temp_sgt_bisaccodes_2010 VALUES (
	'COM065000',
	'Electronic Publishing')  
INSERT INTO temp_sgt_bisaccodes_2010 VALUES (
	'COM005000',
	'Enterprise Applications / General') 
INSERT INTO temp_sgt_bisaccodes_2010 VALUES (
	'COM005030',
	'Enterprise Applications / Business Intelligence Tools    ') 
INSERT INTO temp_sgt_bisaccodes_2010 VALUES (
	'COM066000',
	'Enterprise Applications / Collaboration Software')  
INSERT INTO temp_sgt_bisaccodes_2010 VALUES (
	'COM025000',
	'Expert Systems') 
INSERT INTO temp_sgt_bisaccodes_2010 VALUES (
	'COM067000',
	'Hardware / General')  
INSERT INTO temp_sgt_bisaccodes_2010 VALUES (
	'COM074000',
	'Hardware / Handheld Devices') 
INSERT INTO temp_sgt_bisaccodes_2010 VALUES (
	'COM038000',
	'Hardware / Mainframes & Minicomputers') 
INSERT INTO temp_sgt_bisaccodes_2010 VALUES (
	'COM075000',
	'Hardware / Network Hardware') 
INSERT INTO temp_sgt_bisaccodes_2010 VALUES (
	'COM049000',
	'Hardware / Peripherals') 
INSERT INTO temp_sgt_bisaccodes_2010 VALUES (
	'COM050000',
	'Hardware / Personal Computers / General  ')  
INSERT INTO temp_sgt_bisaccodes_2010 VALUES (
	'COM050020',
	'Hardware / Personal Computers / Macintosh')  
INSERT INTO temp_sgt_bisaccodes_2010 VALUES (
	'COM050010',
	'Hardware / Personal Computers / PCs  ') 
INSERT INTO temp_sgt_bisaccodes_2010 VALUES (
	'COM080000',
	'History') 
INSERT INTO temp_sgt_bisaccodes_2010 VALUES (
	'COM012050',
	'Image Processing') 
INSERT INTO temp_sgt_bisaccodes_2010 VALUES (
	'COM032000',
	'Information Technology') 
INSERT INTO temp_sgt_bisaccodes_2010 VALUES (
	'COM031000',
	'Information Theory')  
INSERT INTO temp_sgt_bisaccodes_2010 VALUES (
	'COM004000',
	'Intelligence (AI) & Semantics ')  
INSERT INTO temp_sgt_bisaccodes_2010 VALUES (
	'COM034000',
	'Interactive & Multimedia')  
INSERT INTO temp_sgt_bisaccodes_2010 VALUES (
	'COM060000',
	'Internet / General')  
INSERT INTO temp_sgt_bisaccodes_2010 VALUES (
	'COM060090',
	'Internet / Application Development   ') 
INSERT INTO temp_sgt_bisaccodes_2010 VALUES (
	'COM060040',
	'Internet / Security')  
INSERT INTO temp_sgt_bisaccodes_2010 VALUES (
	'COM035000',
	'Keyboarding')  
INSERT INTO temp_sgt_bisaccodes_2010 VALUES (
	'COM036000',
	'Logic Design') 
INSERT INTO temp_sgt_bisaccodes_2010 VALUES (
	'COM037000',
	'Machine Theory') 
INSERT INTO temp_sgt_bisaccodes_2010 VALUES (
	'COM039000',
	'Management Information Systems')  
INSERT INTO temp_sgt_bisaccodes_2010 VALUES (
	'COM077000',
	'Mathematical & Statistical Software  ') 
INSERT INTO temp_sgt_bisaccodes_2010 VALUES (
	'COM041000',
	'Microprocessors')  
INSERT INTO temp_sgt_bisaccodes_2010 VALUES (
	'COM042000',
	'Natural Language Processing') 
INSERT INTO temp_sgt_bisaccodes_2010 VALUES (
	'COM043000',
	'Networking / General') 
INSERT INTO temp_sgt_bisaccodes_2010 VALUES (
	'COM060030',
	'Networking / Intranets & Extranets   ') 
INSERT INTO temp_sgt_bisaccodes_2010 VALUES (
	'COM043020',
	'Networking / Local Area Networks (LANs)  ')  
INSERT INTO temp_sgt_bisaccodes_2010 VALUES (
	'COM043040',
	'Networking / Network Protocols')  
INSERT INTO temp_sgt_bisaccodes_2010 VALUES (
	'COM043050',
	'Networking / Security')  
INSERT INTO temp_sgt_bisaccodes_2010 VALUES (
	'COM043060',
	'Networking / Vendor Specific') 
INSERT INTO temp_sgt_bisaccodes_2010 VALUES (
	'COM044000',
	'Neural Networks')  
INSERT INTO temp_sgt_bisaccodes_2010 VALUES (
	'COM069000',
	'Online Services / General') 
INSERT INTO temp_sgt_bisaccodes_2010 VALUES (
	'COM069010',
	'Online Services / Resource Directories') 
INSERT INTO temp_sgt_bisaccodes_2010 VALUES (
	'COM046000',
	'Operating Systems / General') 
INSERT INTO temp_sgt_bisaccodes_2010 VALUES (
	'COM046060',
	'Operating Systems / DOS')   
INSERT INTO temp_sgt_bisaccodes_2010 VALUES (
	'COM046070',
	'Operating Systems / Linux') 
INSERT INTO temp_sgt_bisaccodes_2010 VALUES (
	'COM046020',
	'Operating Systems / Macintosh ')  
INSERT INTO temp_sgt_bisaccodes_2010 VALUES (
	'COM046080',
	'Operating Systems / Mainframe & Midrange ')  
INSERT INTO temp_sgt_bisaccodes_2010 VALUES (
	'COM046030',
	'Operating Systems / UNIX')  
INSERT INTO temp_sgt_bisaccodes_2010 VALUES (
	'COM046090',
	'Operating Systems / Virtualization   ') 
INSERT INTO temp_sgt_bisaccodes_2010 VALUES (
	'COM046050',
	'Operating Systems / Windows Server & NT  ')  
INSERT INTO temp_sgt_bisaccodes_2010 VALUES (
	'COM046040',
	'Operating Systems / Windows Workstation  ')  
INSERT INTO temp_sgt_bisaccodes_2010 VALUES (
	'COM047000',
	'Optical Data Processing')   
INSERT INTO temp_sgt_bisaccodes_2010 VALUES (
	'COM051000',
	'Programming / General')  
INSERT INTO temp_sgt_bisaccodes_2010 VALUES (
	'COM051300',
	'Programming / Algorithms')  
INSERT INTO temp_sgt_bisaccodes_2010 VALUES (
	'COM051370',
	'Programming / Apple Programming') 
INSERT INTO temp_sgt_bisaccodes_2010 VALUES (
	'COM012040',
	'Programming / Games')  
INSERT INTO temp_sgt_bisaccodes_2010 VALUES (
	'COM051380',
	'Programming / Microsoft Programming  ') 
INSERT INTO temp_sgt_bisaccodes_2010 VALUES (
	'COM051210',
	'Programming / Object Oriented ')  
INSERT INTO temp_sgt_bisaccodes_2010 VALUES (
	'COM051390',
	'Programming / Open Source') 
INSERT INTO temp_sgt_bisaccodes_2010 VALUES (
	'COM051220',
	'Programming / Parallel') 
INSERT INTO temp_sgt_bisaccodes_2010 VALUES (
	'COM051010',
	'Programming Languages / General') 
INSERT INTO temp_sgt_bisaccodes_2010 VALUES (
	'COM051020',
	'Programming Languages / Ada') 
INSERT INTO temp_sgt_bisaccodes_2010 VALUES (
	'COM051040',
	'Programming Languages / Assembly Language')  
INSERT INTO temp_sgt_bisaccodes_2010 VALUES (
	'COM051050',
	'Programming Languages / BASIC ')  
INSERT INTO temp_sgt_bisaccodes_2010 VALUES (
	'COM051060',
	'Programming Languages / C') 
INSERT INTO temp_sgt_bisaccodes_2010 VALUES (
	'COM051070',
	'Programming Languages / C++') 
INSERT INTO temp_sgt_bisaccodes_2010 VALUES (
	'COM051310',
	'Programming Languages / C#')  
INSERT INTO temp_sgt_bisaccodes_2010 VALUES (
	'COM051080',
	'Programming Languages / COBOL ')  
INSERT INTO temp_sgt_bisaccodes_2010 VALUES (
	'COM051090',
	'Programming Languages / FORTRAN') 
INSERT INTO temp_sgt_bisaccodes_2010 VALUES (
	'COM051270',
	'Programming Languages / HTML') 
INSERT INTO temp_sgt_bisaccodes_2010 VALUES (
	'COM051280',
	'Programming Languages / Java') 
INSERT INTO temp_sgt_bisaccodes_2010 VALUES (
	'COM051260',
	'Programming Languages / JavaScript   ') 
INSERT INTO temp_sgt_bisaccodes_2010 VALUES (
	'COM051100',
	'Programming Languages / LISP') 
INSERT INTO temp_sgt_bisaccodes_2010 VALUES (
	'COM051130',
	'Programming Languages / Pascal')  
INSERT INTO temp_sgt_bisaccodes_2010 VALUES (
	'COM051350',
	'Programming Languages / Perl') 
INSERT INTO temp_sgt_bisaccodes_2010 VALUES (
	'COM051400',
	'Programming Languages / PHP') 
INSERT INTO temp_sgt_bisaccodes_2010 VALUES (
	'COM051140',
	'Programming Languages / Prolog')  
INSERT INTO temp_sgt_bisaccodes_2010 VALUES (
	'COM051360',
	'Programming Languages / Python')  
INSERT INTO temp_sgt_bisaccodes_2010 VALUES (
	'COM051290',
	'Programming Languages / RPG') 
INSERT INTO temp_sgt_bisaccodes_2010 VALUES (
	'COM051410',
	'Programming Languages / Ruby') 
INSERT INTO temp_sgt_bisaccodes_2010 VALUES (
	'COM051160',
	'Programming Languages / Smalltalk') 
INSERT INTO temp_sgt_bisaccodes_2010 VALUES (
	'COM051170',
	'Programming Languages / SQL') 
INSERT INTO temp_sgt_bisaccodes_2010 VALUES (
	'COM051420',
	'Programming Languages / VBScript')  
INSERT INTO temp_sgt_bisaccodes_2010 VALUES (
	'COM051200',
	'Programming Languages / Visual BASIC ') 
INSERT INTO temp_sgt_bisaccodes_2010 VALUES (
	'COM051320',
	'Programming Languages / XML') 
INSERT INTO temp_sgt_bisaccodes_2010 VALUES (
	'COM052000',
	'Reference') 
INSERT INTO temp_sgt_bisaccodes_2010 VALUES (
	'COM053000',
	'Security / General')  
INSERT INTO temp_sgt_bisaccodes_2010 VALUES (
	'COM083000',
	'Security / Cryptography')   
INSERT INTO temp_sgt_bisaccodes_2010 VALUES (
	'COM015000',
	'Security / Viruses')  
INSERT INTO temp_sgt_bisaccodes_2010 VALUES (
	'COM079000',
	'Social Aspects / General')  
INSERT INTO temp_sgt_bisaccodes_2010 VALUES (
	'COM079010',
	'Social Aspects / Human-Computer Interaction ')  
INSERT INTO temp_sgt_bisaccodes_2010 VALUES (
	'COM051230',
	'Software Development & Engineering / General')  
INSERT INTO temp_sgt_bisaccodes_2010 VALUES (
	'COM051430',
	'Software Development & Engineering / Project Management  ') 
INSERT INTO temp_sgt_bisaccodes_2010 VALUES (
	'COM051330',
	'Software Development & Engineering / Quality Assurance & Testing')  
INSERT INTO temp_sgt_bisaccodes_2010 VALUES (
	'COM051240',
	'Software Development & Engineering / Systems Analysis & Design') 
INSERT INTO temp_sgt_bisaccodes_2010 VALUES (
	'COM051440',
	'Software Development & Engineering / Tools') 
INSERT INTO temp_sgt_bisaccodes_2010 VALUES (
	'COM073000',
	'Speech & Audio Processing') 
INSERT INTO temp_sgt_bisaccodes_2010 VALUES (
	'COM088000',
	'System Administration / General') 
INSERT INTO temp_sgt_bisaccodes_2010 VALUES (
	'COM019000',
	'System Administration / Disaster & Recovery ')  
INSERT INTO temp_sgt_bisaccodes_2010 VALUES (
	'COM020020',
	'System Administration / Email Administration')  
INSERT INTO temp_sgt_bisaccodes_2010 VALUES (
	'COM088010',
	'System Administration / Linux & UNIX Administration')  
INSERT INTO temp_sgt_bisaccodes_2010 VALUES (
	'COM030000',
	'System Administration / Storage & Retrieval ')  
INSERT INTO temp_sgt_bisaccodes_2010 VALUES (
	'COM088020',
	'System Administration / Windows Administration')  
INSERT INTO temp_sgt_bisaccodes_2010 VALUES (
	'COM011000',
	'Systems Architecture / General')  
INSERT INTO temp_sgt_bisaccodes_2010 VALUES (
	'COM048000',
	'Systems Architecture / Distributed Systems & Computing   ') 
INSERT INTO temp_sgt_bisaccodes_2010 VALUES (
	'COM070000',
	'User Interfaces')  
INSERT INTO temp_sgt_bisaccodes_2010 VALUES (
	'COM056000',
	'Utilities') 
INSERT INTO temp_sgt_bisaccodes_2010 VALUES (
	'COM057000',
	'Virtual Worlds') 
INSERT INTO temp_sgt_bisaccodes_2010 VALUES (
	'COM060080',
	'Web / General')  
INSERT INTO temp_sgt_bisaccodes_2010 VALUES (
	'COM060100',
	'Web / Blogs')  
INSERT INTO temp_sgt_bisaccodes_2010 VALUES (
	'COM060010',
	'Web / Browsers') 
INSERT INTO temp_sgt_bisaccodes_2010 VALUES (
	'COM060060',
	'Web / Page Design')   
INSERT INTO temp_sgt_bisaccodes_2010 VALUES (
	'COM060110',
	'Web / Podcasting & Webcasting ')  
INSERT INTO temp_sgt_bisaccodes_2010 VALUES (
	'COM060120',
	'Web / Search Engines') 
INSERT INTO temp_sgt_bisaccodes_2010 VALUES (
	'COM060130',
	'Web / Site Design')   
INSERT INTO temp_sgt_bisaccodes_2010 VALUES (
	'COM060070',
	'Web / Site Directories') 
INSERT INTO temp_sgt_bisaccodes_2010 VALUES (
	'COM060140',
	'Web / Social Networking')   
INSERT INTO temp_sgt_bisaccodes_2010 VALUES (
	'COM060150',
	'Web / User Generated Content') 
INSERT INTO temp_sgt_bisaccodes_2010 VALUES (
	'COM060160',
	'Web / Web Programming')  
INSERT INTO temp_sgt_bisaccodes_2010 VALUES (
	'CKB000000',
	'General') 
INSERT INTO temp_sgt_bisaccodes_2010 VALUES (
	'CKB107000',
	'Baby Food') 
INSERT INTO temp_sgt_bisaccodes_2010 VALUES (
	'CKB100000',
	'Beverages / General')  
INSERT INTO temp_sgt_bisaccodes_2010 VALUES (
	'CKB006000',
	'Beverages / Bartending') 
INSERT INTO temp_sgt_bisaccodes_2010 VALUES (
	'CKB007000',
	'Beverages / Beer') 
INSERT INTO temp_sgt_bisaccodes_2010 VALUES (
	'CKB019000',
	'Beverages / Coffee & Tea')  
INSERT INTO temp_sgt_bisaccodes_2010 VALUES (
	'CKB008000',
	'Beverages / Non-Alcoholic') 
INSERT INTO temp_sgt_bisaccodes_2010 VALUES (
	'CKB088000',
	'Beverages / Wine & Spirits')  
INSERT INTO temp_sgt_bisaccodes_2010 VALUES (
	'CKB101000',
	'Courses & Dishes / General')  
INSERT INTO temp_sgt_bisaccodes_2010 VALUES (
	'CKB003000',
	'Courses & Dishes / Appetizers ')  
INSERT INTO temp_sgt_bisaccodes_2010 VALUES (
	'CKB009000',
	'Courses & Dishes / Bread')  
INSERT INTO temp_sgt_bisaccodes_2010 VALUES (
	'CKB010000',
	'Courses & Dishes / Breakfast') 
INSERT INTO temp_sgt_bisaccodes_2010 VALUES (
	'CKB012000',
	'Courses & Dishes / Brunch') 
INSERT INTO temp_sgt_bisaccodes_2010 VALUES (
	'CKB014000',
	'Courses & Dishes / Cakes')  
INSERT INTO temp_sgt_bisaccodes_2010 VALUES (
	'CKB018000',
	'Courses & Dishes / Chocolate') 
INSERT INTO temp_sgt_bisaccodes_2010 VALUES (
	'CKB095000',
	'Courses & Dishes / Confectionery')  
INSERT INTO temp_sgt_bisaccodes_2010 VALUES (
	'CKB021000',
	'Courses & Dishes / Cookies')  
INSERT INTO temp_sgt_bisaccodes_2010 VALUES (
	'CKB024000',
	'Courses & Dishes / Desserts') 
INSERT INTO temp_sgt_bisaccodes_2010 VALUES (
	'CKB062000',
	'Courses & Dishes / Pastry') 
INSERT INTO temp_sgt_bisaccodes_2010 VALUES (
	'CKB063000',
	'Courses & Dishes / Pies')   
INSERT INTO temp_sgt_bisaccodes_2010 VALUES (
	'CKB064000',
	'Courses & Dishes / Pizza')  
INSERT INTO temp_sgt_bisaccodes_2010 VALUES (
	'CKB073000',
	'Courses & Dishes / Salads') 
INSERT INTO temp_sgt_bisaccodes_2010 VALUES (
	'CKB102000',
	'Courses & Dishes / Sauces & Dressings') 
INSERT INTO temp_sgt_bisaccodes_2010 VALUES (
	'CKB079000',
	'Courses & Dishes / Soups & Stews')  
INSERT INTO temp_sgt_bisaccodes_2010 VALUES (
	'CKB029000',
	'Entertaining') 
INSERT INTO temp_sgt_bisaccodes_2010 VALUES (
	'CKB030000',
	'Essays')  
INSERT INTO temp_sgt_bisaccodes_2010 VALUES (
	'CKB039000',
	'Health & Healing / General')  
INSERT INTO temp_sgt_bisaccodes_2010 VALUES (
	'CKB106000',
	'Health & Healing / Allergy')  
INSERT INTO temp_sgt_bisaccodes_2010 VALUES (
	'CKB103000',
	'Health & Healing / Cancer') 
INSERT INTO temp_sgt_bisaccodes_2010 VALUES (
	'CKB025000',
	'Health & Healing / Diabetic & Sugar-Free ')  
INSERT INTO temp_sgt_bisaccodes_2010 VALUES (
	'CKB104000',
	'Health & Healing / Heart')  
INSERT INTO temp_sgt_bisaccodes_2010 VALUES (
	'CKB108000',
	'Health & Healing / Low Carbohydrate  ') 
INSERT INTO temp_sgt_bisaccodes_2010 VALUES (
	'CKB050000',
	'Health & Healing / Low Cholesterol   ') 
INSERT INTO temp_sgt_bisaccodes_2010 VALUES (
	'CKB051000',
	'Health & Healing / Low Fat')  
INSERT INTO temp_sgt_bisaccodes_2010 VALUES (
	'CKB052000',
	'Health & Healing / Low Salt') 
INSERT INTO temp_sgt_bisaccodes_2010 VALUES (
	'CKB026000',
	'Health & Healing / Weight Control') 
INSERT INTO temp_sgt_bisaccodes_2010 VALUES (
	'CKB041000',
	'History') 
INSERT INTO temp_sgt_bisaccodes_2010 VALUES (
	'CKB042000',
	'Holiday') 
INSERT INTO temp_sgt_bisaccodes_2010 VALUES (
	'CKB023000',
	'Methods / General')   
INSERT INTO temp_sgt_bisaccodes_2010 VALUES (
	'CKB004000',
	'Methods / Baking') 
INSERT INTO temp_sgt_bisaccodes_2010 VALUES (
	'CKB005000',
	'Methods / Barbecue & Grilling ')  
INSERT INTO temp_sgt_bisaccodes_2010 VALUES (
	'CKB015000',
	'Methods / Canning & Preserving')  
INSERT INTO temp_sgt_bisaccodes_2010 VALUES (
	'CKB020000',
	'Methods / Cookery for One') 
INSERT INTO temp_sgt_bisaccodes_2010 VALUES (
	'CKB033000',
	'Methods / Garnishing') 
INSERT INTO temp_sgt_bisaccodes_2010 VALUES (
	'CKB037000',
	'Methods / Gourmet')   
INSERT INTO temp_sgt_bisaccodes_2010 VALUES (
	'CKB057000',
	'Methods / Microwave')  
INSERT INTO temp_sgt_bisaccodes_2010 VALUES (
	'CKB060000',
	'Methods / Outdoor')   
INSERT INTO temp_sgt_bisaccodes_2010 VALUES (
	'CKB068000',
	'Methods / Professional') 
INSERT INTO temp_sgt_bisaccodes_2010 VALUES (
	'CKB069000',
	'Methods / Quantity')  
INSERT INTO temp_sgt_bisaccodes_2010 VALUES (
	'CKB070000',
	'Methods / Quick & Easy') 
INSERT INTO temp_sgt_bisaccodes_2010 VALUES (
	'CKB109000',
	'Methods / Slow Cooking') 
INSERT INTO temp_sgt_bisaccodes_2010 VALUES (
	'CKB081000',
	'Methods / Special Appliances') 
INSERT INTO temp_sgt_bisaccodes_2010 VALUES (
	'CKB089000',
	'Methods / Wok')  
INSERT INTO temp_sgt_bisaccodes_2010 VALUES (
	'CKB071000',
	'Reference') 
INSERT INTO temp_sgt_bisaccodes_2010 VALUES (
	'CKB031000',
	'Regional & Ethnic / General') 
INSERT INTO temp_sgt_bisaccodes_2010 VALUES (
	'CKB001000',
	'Regional & Ethnic / African') 
INSERT INTO temp_sgt_bisaccodes_2010 VALUES (
	'CKB002000',
	'Regional & Ethnic / American / General') 
INSERT INTO temp_sgt_bisaccodes_2010 VALUES (
	'CKB002010',
	'Regional & Ethnic / American / California Style') 
INSERT INTO temp_sgt_bisaccodes_2010 VALUES (
	'CKB002020',
	'Regional & Ethnic / American / Middle Atlantic States    ') 
INSERT INTO temp_sgt_bisaccodes_2010 VALUES (
	'CKB002030',
	'Regional & Ethnic / American / Middle Western States') 
INSERT INTO temp_sgt_bisaccodes_2010 VALUES (
	'CKB002040',
	'Regional & Ethnic / American / New England') 
INSERT INTO temp_sgt_bisaccodes_2010 VALUES (
	'CKB002050',
	'Regional & Ethnic / American / Northwestern States') 
INSERT INTO temp_sgt_bisaccodes_2010 VALUES (
	'CKB002060',
	'Regional & Ethnic / American / Southern States')  
INSERT INTO temp_sgt_bisaccodes_2010 VALUES (
	'CKB002070',
	'Regional & Ethnic / American / Southwestern States') 
INSERT INTO temp_sgt_bisaccodes_2010 VALUES (
	'CKB002080',
	'Regional & Ethnic / American / Western States') 
INSERT INTO temp_sgt_bisaccodes_2010 VALUES (
	'CKB090000',
	'Regional & Ethnic / Asian') 
INSERT INTO temp_sgt_bisaccodes_2010 VALUES (
	'CKB013000',
	'Regional & Ethnic / Cajun & Creole   ') 
INSERT INTO temp_sgt_bisaccodes_2010 VALUES (
	'CKB091000',
	'Regional & Ethnic / Canadian') 
INSERT INTO temp_sgt_bisaccodes_2010 VALUES (
	'CKB016000',
	'Regional & Ethnic / Caribbean & West Indian ')  
INSERT INTO temp_sgt_bisaccodes_2010 VALUES (
	'CKB099000',
	'Regional & Ethnic / Central American & South American    ') 
INSERT INTO temp_sgt_bisaccodes_2010 VALUES (
	'CKB017000',
	'Regional & Ethnic / Chinese') 
INSERT INTO temp_sgt_bisaccodes_2010 VALUES (
	'CKB011000',
	'Regional & Ethnic / English, Scottish & Welsh') 
INSERT INTO temp_sgt_bisaccodes_2010 VALUES (
	'CKB092000',
	'Regional & Ethnic / European') 
INSERT INTO temp_sgt_bisaccodes_2010 VALUES (
	'CKB034000',
	'Regional & Ethnic / French')  
INSERT INTO temp_sgt_bisaccodes_2010 VALUES (
	'CKB036000',
	'Regional & Ethnic / German')  
INSERT INTO temp_sgt_bisaccodes_2010 VALUES (
	'CKB038000',
	'Regional & Ethnic / Greek') 
INSERT INTO temp_sgt_bisaccodes_2010 VALUES (
	'CKB043000',
	'Regional & Ethnic / Hungarian ')  
INSERT INTO temp_sgt_bisaccodes_2010 VALUES (
	'CKB044000',
	'Regional & Ethnic / Indian & South Asian ')  
INSERT INTO temp_sgt_bisaccodes_2010 VALUES (
	'CKB045000',
	'Regional & Ethnic / International') 
INSERT INTO temp_sgt_bisaccodes_2010 VALUES (
	'CKB046000',
	'Regional & Ethnic / Irish') 
INSERT INTO temp_sgt_bisaccodes_2010 VALUES (
	'CKB047000',
	'Regional & Ethnic / Italian') 
INSERT INTO temp_sgt_bisaccodes_2010 VALUES (
	'CKB048000',
	'Regional & Ethnic / Japanese') 
INSERT INTO temp_sgt_bisaccodes_2010 VALUES (
	'CKB049000',
	'Regional & Ethnic / Jewish & Kosher  ') 
INSERT INTO temp_sgt_bisaccodes_2010 VALUES (
	'CKB055000',
	'Regional & Ethnic / Mediterranean') 
INSERT INTO temp_sgt_bisaccodes_2010 VALUES (
	'CKB056000',
	'Regional & Ethnic / Mexican') 
INSERT INTO temp_sgt_bisaccodes_2010 VALUES (
	'CKB093000',
	'Regional & Ethnic / Middle Eastern   ') 
INSERT INTO temp_sgt_bisaccodes_2010 VALUES (
	'CKB058000',
	'Regional & Ethnic / Native American  ') 
INSERT INTO temp_sgt_bisaccodes_2010 VALUES (
	'CKB097000',
	'Regional & Ethnic / Pacific Rim') 
INSERT INTO temp_sgt_bisaccodes_2010 VALUES (
	'CKB065000',
	'Regional & Ethnic / Polish')  
INSERT INTO temp_sgt_bisaccodes_2010 VALUES (
	'CKB066000',
	'Regional & Ethnic / Portuguese')  
INSERT INTO temp_sgt_bisaccodes_2010 VALUES (
	'CKB072000',
	'Regional & Ethnic / Russian') 
INSERT INTO temp_sgt_bisaccodes_2010 VALUES (
	'CKB074000',
	'Regional & Ethnic / Scandinavian')  
INSERT INTO temp_sgt_bisaccodes_2010 VALUES (
	'CKB078000',
	'Regional & Ethnic / Soul Food ')  
INSERT INTO temp_sgt_bisaccodes_2010 VALUES (
	'CKB080000',
	'Regional & Ethnic / Spanish') 
INSERT INTO temp_sgt_bisaccodes_2010 VALUES (
	'CKB083000',
	'Regional & Ethnic / Thai')  
INSERT INTO temp_sgt_bisaccodes_2010 VALUES (
	'CKB084000',
	'Regional & Ethnic / Turkish') 
INSERT INTO temp_sgt_bisaccodes_2010 VALUES (
	'CKB094000',
	'Regional & Ethnic / Vietnamese')  
INSERT INTO temp_sgt_bisaccodes_2010 VALUES (
	'CKB077000',
	'Seasonal')  
INSERT INTO temp_sgt_bisaccodes_2010 VALUES (
	'CKB105000',
	'Specific Ingredients / General')  
INSERT INTO temp_sgt_bisaccodes_2010 VALUES (
	'CKB096000',
	'Specific Ingredients / Dairy') 
INSERT INTO temp_sgt_bisaccodes_2010 VALUES (
	'CKB035000',
	'Specific Ingredients / Fruit') 
INSERT INTO temp_sgt_bisaccodes_2010 VALUES (
	'CKB032000',
	'Specific Ingredients / Game') 
INSERT INTO temp_sgt_bisaccodes_2010 VALUES (
	'CKB040000',
	'Specific Ingredients / Herbs, Spices, Condiments')  
INSERT INTO temp_sgt_bisaccodes_2010 VALUES (
	'CKB054000',
	'Specific Ingredients / Meat') 
INSERT INTO temp_sgt_bisaccodes_2010 VALUES (
	'CKB059000',
	'Specific Ingredients / Natural Foods ') 
INSERT INTO temp_sgt_bisaccodes_2010 VALUES (
	'CKB061000',
	'Specific Ingredients / Pasta') 
INSERT INTO temp_sgt_bisaccodes_2010 VALUES (
	'CKB067000',
	'Specific Ingredients / Poultry')  
INSERT INTO temp_sgt_bisaccodes_2010 VALUES (
	'CKB098000',
	'Specific Ingredients / Rice & Grains ') 
INSERT INTO temp_sgt_bisaccodes_2010 VALUES (
	'CKB076000',
	'Specific Ingredients / Seafood')  
INSERT INTO temp_sgt_bisaccodes_2010 VALUES (
	'CKB085000',
	'Specific Ingredients / Vegetables') 
INSERT INTO temp_sgt_bisaccodes_2010 VALUES (
	'CKB082000',
	'Tablesetting') 
INSERT INTO temp_sgt_bisaccodes_2010 VALUES (
	'CKB086000',
	'Vegetarian & Vegan')  
INSERT INTO temp_sgt_bisaccodes_2010 VALUES (
	'CRA000000',
	'General') 
INSERT INTO temp_sgt_bisaccodes_2010 VALUES (
	'CRA001000',
	'Applique')  
INSERT INTO temp_sgt_bisaccodes_2010 VALUES (
	'CRA002000',
	'Baskets') 
INSERT INTO temp_sgt_bisaccodes_2010 VALUES (
	'CRA048000',
	'Beadwork')  
INSERT INTO temp_sgt_bisaccodes_2010 VALUES (
	'CRA046000',
	'Book Printing & Binding')   
INSERT INTO temp_sgt_bisaccodes_2010 VALUES (
	'CRA049000',
	'Candle & Soap Making') 
INSERT INTO temp_sgt_bisaccodes_2010 VALUES (
	'CRA003000',
	'Carving') 
INSERT INTO temp_sgt_bisaccodes_2010 VALUES (
	'CRA043000',
	'Crafts for Children')  
INSERT INTO temp_sgt_bisaccodes_2010 VALUES (
	'CRA005000',
	'Decorating ')  
INSERT INTO temp_sgt_bisaccodes_2010 VALUES (
	'CRA006000',
	'Dough') 
INSERT INTO temp_sgt_bisaccodes_2010 VALUES (
	'CRA007000',
	'Dye') 
INSERT INTO temp_sgt_bisaccodes_2010 VALUES (
	'CRA009000',
	'Fashion') 
INSERT INTO temp_sgt_bisaccodes_2010 VALUES (
	'CRA010000',
	'Flower Arranging') 
INSERT INTO temp_sgt_bisaccodes_2010 VALUES (
	'CRA047000',
	'Folkcrafts ')  
INSERT INTO temp_sgt_bisaccodes_2010 VALUES (
	'CRA011000',
	'Framing') 
INSERT INTO temp_sgt_bisaccodes_2010 VALUES (
	'CRA012000',
	'Glass & Glassware')   
INSERT INTO temp_sgt_bisaccodes_2010 VALUES (
	'CRA014000',
	'Jewelry') 
INSERT INTO temp_sgt_bisaccodes_2010 VALUES (
	'CRA050000',
	'Leatherwork')  
INSERT INTO temp_sgt_bisaccodes_2010 VALUES (
	'CRA017000',
	'Metal Work ')  
INSERT INTO temp_sgt_bisaccodes_2010 VALUES (
	'CRA018000',
	'Miniatures ')  
INSERT INTO temp_sgt_bisaccodes_2010 VALUES (
	'CRA054000',
	'Mixed Media')  
INSERT INTO temp_sgt_bisaccodes_2010 VALUES (
	'CRA019000',
	'Mobiles') 
INSERT INTO temp_sgt_bisaccodes_2010 VALUES (
	'CRA045000',
	'Model Railroading')   
INSERT INTO temp_sgt_bisaccodes_2010 VALUES (
	'CRA020000',
	'Models')  
INSERT INTO temp_sgt_bisaccodes_2010 VALUES (
	'CRA053000',
	'Nature Crafts')  
INSERT INTO temp_sgt_bisaccodes_2010 VALUES (
	'CRA022000',
	'Needlework / General') 
INSERT INTO temp_sgt_bisaccodes_2010 VALUES (
	'CRA004000',
	'Needlework / Crocheting')   
INSERT INTO temp_sgt_bisaccodes_2010 VALUES (
	'CRA044000',
	'Needlework / Cross-Stitch') 
INSERT INTO temp_sgt_bisaccodes_2010 VALUES (
	'CRA008000',
	'Needlework / Embroidery')   
INSERT INTO temp_sgt_bisaccodes_2010 VALUES (
	'CRA015000',
	'Needlework / Knitting')  
INSERT INTO temp_sgt_bisaccodes_2010 VALUES (
	'CRA016000',
	'Needlework / Lace & Tatting') 
INSERT INTO temp_sgt_bisaccodes_2010 VALUES (
	'CRA021000',
	'Needlework / Needlepoint')  
INSERT INTO temp_sgt_bisaccodes_2010 VALUES (
	'CRA023000',
	'Origami') 
INSERT INTO temp_sgt_bisaccodes_2010 VALUES (
	'CRA024000',
	'Painting')  
INSERT INTO temp_sgt_bisaccodes_2010 VALUES (
	'CRA025000',
	'Papercrafts')  
INSERT INTO temp_sgt_bisaccodes_2010 VALUES (
	'CRA026000',
	'Patchwork') 
INSERT INTO temp_sgt_bisaccodes_2010 VALUES (
	'CRA051000',
	'Polymer Clay') 
INSERT INTO temp_sgt_bisaccodes_2010 VALUES (
	'CRA027000',
	'Potpourri') 
INSERT INTO temp_sgt_bisaccodes_2010 VALUES (
	'CRA028000',
	'Pottery & Ceramics')  
INSERT INTO temp_sgt_bisaccodes_2010 VALUES (
	'CRA029000',
	'Printmaking')  
INSERT INTO temp_sgt_bisaccodes_2010 VALUES (
	'CRA030000',
	'Puppets & Puppetry')  
INSERT INTO temp_sgt_bisaccodes_2010 VALUES (
	'CRA031000',
	'Quilts & Quilting')   
INSERT INTO temp_sgt_bisaccodes_2010 VALUES (
	'CRA032000',
	'Reference') 
INSERT INTO temp_sgt_bisaccodes_2010 VALUES (
	'CRA033000',
	'Rugs')  
INSERT INTO temp_sgt_bisaccodes_2010 VALUES (
	'CRA052000',
	'Scrapbooking') 
INSERT INTO temp_sgt_bisaccodes_2010 VALUES (
	'CRA034000',
	'Seasonal')  
INSERT INTO temp_sgt_bisaccodes_2010 VALUES (
	'CRA035000',
	'Sewing')  
INSERT INTO temp_sgt_bisaccodes_2010 VALUES (
	'CRA036000',
	'Stenciling ')  
INSERT INTO temp_sgt_bisaccodes_2010 VALUES (
	'CRA037000',
	'Stuffed Animals')  
INSERT INTO temp_sgt_bisaccodes_2010 VALUES (
	'CRA039000',
	'Toymaking') 
INSERT INTO temp_sgt_bisaccodes_2010 VALUES (
	'CRA040000',
	'Weaving') 
INSERT INTO temp_sgt_bisaccodes_2010 VALUES (
	'CRA041000',
	'Wood Toys') 
INSERT INTO temp_sgt_bisaccodes_2010 VALUES (
	'CRA042000',
	'Woodwork')  
INSERT INTO temp_sgt_bisaccodes_2010 VALUES (
	'DES000000',
	'General') 
INSERT INTO temp_sgt_bisaccodes_2010 VALUES (
	'DES001000',
	'Book')  
INSERT INTO temp_sgt_bisaccodes_2010 VALUES (
	'DES002000',
	'Clip Art')  
INSERT INTO temp_sgt_bisaccodes_2010 VALUES (
	'DES003000',
	'Decorative Arts')  
INSERT INTO temp_sgt_bisaccodes_2010 VALUES (
	'DES004000',
	'Essays')  
INSERT INTO temp_sgt_bisaccodes_2010 VALUES (
	'DES005000',
	'Fashion') 
INSERT INTO temp_sgt_bisaccodes_2010 VALUES (
	'DES006000',
	'Furniture') 
INSERT INTO temp_sgt_bisaccodes_2010 VALUES (
	'DES007000',
	'Graphic Arts / General') 
INSERT INTO temp_sgt_bisaccodes_2010 VALUES (
	'DES007010',
	'Graphic Arts / Advertising')  
INSERT INTO temp_sgt_bisaccodes_2010 VALUES (
	'DES007020',
	'Graphic Arts / Branding & Logo Design') 
INSERT INTO temp_sgt_bisaccodes_2010 VALUES (
	'DES007030',
	'Graphic Arts / Commercial & Corporate') 
INSERT INTO temp_sgt_bisaccodes_2010 VALUES (
	'DES007040',
	'Graphic Arts / Illustration') 
INSERT INTO temp_sgt_bisaccodes_2010 VALUES (
	'DES007050',
	'Graphic Arts / Typography') 
INSERT INTO temp_sgt_bisaccodes_2010 VALUES (
	'DES008000',
	'History & Criticism')  
INSERT INTO temp_sgt_bisaccodes_2010 VALUES (
	'DES009000',
	'Industrial ')  
INSERT INTO temp_sgt_bisaccodes_2010 VALUES (
	'DES010000',
	'Interior Decorating')  
INSERT INTO temp_sgt_bisaccodes_2010 VALUES (
	'DES011000',
	'Product') 
INSERT INTO temp_sgt_bisaccodes_2010 VALUES (
	'DES012000',
	'Reference') 
INSERT INTO temp_sgt_bisaccodes_2010 VALUES (
	'DES013000',
	'Textile & Costume')   
INSERT INTO temp_sgt_bisaccodes_2010 VALUES (
	'DRA000000',
	'General') 
INSERT INTO temp_sgt_bisaccodes_2010 VALUES (
	'DRA011000',
	'African') 
INSERT INTO temp_sgt_bisaccodes_2010 VALUES (
	'DRA001000',
	'American')  
INSERT INTO temp_sgt_bisaccodes_2010 VALUES (
	'DRA006000',
	'Ancient, Classical & Medieval ')  
INSERT INTO temp_sgt_bisaccodes_2010 VALUES (
	'DRA002000',
	'Anthologies (multiple authors)')  
INSERT INTO temp_sgt_bisaccodes_2010 VALUES (
	'DRA005000',
	'Asian') 
INSERT INTO temp_sgt_bisaccodes_2010 VALUES (
	'DRA012000',
	'Australian & Oceanian')  
INSERT INTO temp_sgt_bisaccodes_2010 VALUES (
	'DRA013000',
	'Canadian')  
INSERT INTO temp_sgt_bisaccodes_2010 VALUES (
	'DRA014000',
	'Caribbean & Latin American')  
INSERT INTO temp_sgt_bisaccodes_2010 VALUES (
	'DRA004000',
	'Continental European') 
INSERT INTO temp_sgt_bisaccodes_2010 VALUES (
	'DRA003000',
	'English, Irish, Scottish, Welsh') 
INSERT INTO temp_sgt_bisaccodes_2010 VALUES (
	'DRA015000',
	'Middle Eastern') 
INSERT INTO temp_sgt_bisaccodes_2010 VALUES (
	'DRA008000',
	'Religious & Liturgical') 
INSERT INTO temp_sgt_bisaccodes_2010 VALUES (
	'DRA016000',
	'Russian & Former Soviet Union ')  
INSERT INTO temp_sgt_bisaccodes_2010 VALUES (
	'DRA010000',
	'Shakespeare')  
INSERT INTO temp_sgt_bisaccodes_2010 VALUES (
	'EDU000000',
	'General') 
INSERT INTO temp_sgt_bisaccodes_2010 VALUES (
	'EDU001000',
	'Administration / General')  
INSERT INTO temp_sgt_bisaccodes_2010 VALUES (
	'EDU001010',
	'Administration / School Plant Management ')  
INSERT INTO temp_sgt_bisaccodes_2010 VALUES (
	'EDU002000',
	'Adult & Continuing Education') 
INSERT INTO temp_sgt_bisaccodes_2010 VALUES (
	'EDU003000',
	'Aims & Objectives')   
INSERT INTO temp_sgt_bisaccodes_2010 VALUES (
	'EDU005000',
	'Bilingual Education')  
INSERT INTO temp_sgt_bisaccodes_2010 VALUES (
	'EDU044000',
	'Classroom Management') 
INSERT INTO temp_sgt_bisaccodes_2010 VALUES (
	'EDU043000',
	'Comparative')  
INSERT INTO temp_sgt_bisaccodes_2010 VALUES (
	'EDU039000',
	'Computers & Technology') 
INSERT INTO temp_sgt_bisaccodes_2010 VALUES (
	'EDU006000',
	'Counseling / General') 
INSERT INTO temp_sgt_bisaccodes_2010 VALUES (
	'EDU045000',
	'Counseling / Crisis Management')  
INSERT INTO temp_sgt_bisaccodes_2010 VALUES (
	'EDU031000',
	'Counseling / Vocational Guidance')  
INSERT INTO temp_sgt_bisaccodes_2010 VALUES (
	'EDU007000',
	'Curricula') 
INSERT INTO temp_sgt_bisaccodes_2010 VALUES (
	'EDU008000',
	'Decision-Making & Problem Solving') 
INSERT INTO temp_sgt_bisaccodes_2010 VALUES (
	'EDU041000',
	'Distance Education & Learning ')  
INSERT INTO temp_sgt_bisaccodes_2010 VALUES (
	'EDU047000',
	'Driver Education') 
INSERT INTO temp_sgt_bisaccodes_2010 VALUES (
	'EDU034000',
	'Educational Policy & Reform / General') 
INSERT INTO temp_sgt_bisaccodes_2010 VALUES (
	'EDU034010',
	'Educational Policy & Reform / School Safety & Violence   ') 
INSERT INTO temp_sgt_bisaccodes_2010 VALUES (
	'EDU009000',
	'Educational Psychology') 
INSERT INTO temp_sgt_bisaccodes_2010 VALUES (
	'EDU010000',
	'Elementary ')  
INSERT INTO temp_sgt_bisaccodes_2010 VALUES (
	'EDU042000',
	'Essays')  
INSERT INTO temp_sgt_bisaccodes_2010 VALUES (
	'EDU011000',
	'Evaluation ')  
INSERT INTO temp_sgt_bisaccodes_2010 VALUES (
	'EDU012000',
	'Experimental Methods') 
INSERT INTO temp_sgt_bisaccodes_2010 VALUES (
	'EDU013000',
	'Finance') 
INSERT INTO temp_sgt_bisaccodes_2010 VALUES (
	'EDU014000',
	'Guidance & Orientation') 
INSERT INTO temp_sgt_bisaccodes_2010 VALUES (
	'EDU015000',
	'Higher')  
INSERT INTO temp_sgt_bisaccodes_2010 VALUES (
	'EDU016000',
	'History') 
INSERT INTO temp_sgt_bisaccodes_2010 VALUES (
	'EDU017000',
	'Home Schooling') 
INSERT INTO temp_sgt_bisaccodes_2010 VALUES (
	'EDU048000',
	'Inclusive Education')  
INSERT INTO temp_sgt_bisaccodes_2010 VALUES (
	'EDU018000',
	'Language Experience Approach') 
INSERT INTO temp_sgt_bisaccodes_2010 VALUES (
	'EDU032000',
	'Leadership ')  
INSERT INTO temp_sgt_bisaccodes_2010 VALUES (
	'EDU020000',
	'Multicultural Education')   
INSERT INTO temp_sgt_bisaccodes_2010 VALUES (
	'EDU021000',
	'Non-Formal Education') 
INSERT INTO temp_sgt_bisaccodes_2010 VALUES (
	'EDU036000',
	'Organizations & Institutions') 
INSERT INTO temp_sgt_bisaccodes_2010 VALUES (
	'EDU022000',
	'Parent Participation') 
INSERT INTO temp_sgt_bisaccodes_2010 VALUES (
	'EDU040000',
	'Philosophy & Social Aspects') 
INSERT INTO temp_sgt_bisaccodes_2010 VALUES (
	'EDU033000',
	'Physical Education')  
INSERT INTO temp_sgt_bisaccodes_2010 VALUES (
	'EDU023000',
	'Preschool & Kindergarten')  
INSERT INTO temp_sgt_bisaccodes_2010 VALUES (
	'EDU046000',
	'Professional Development')  
INSERT INTO temp_sgt_bisaccodes_2010 VALUES (
	'EDU024000',
	'Reference') 
INSERT INTO temp_sgt_bisaccodes_2010 VALUES (
	'EDU037000',
	'Research')  
INSERT INTO temp_sgt_bisaccodes_2010 VALUES (
	'EDU025000',
	'Secondary') 
INSERT INTO temp_sgt_bisaccodes_2010 VALUES (
	'EDU026000',
	'Special Education / General') 
INSERT INTO temp_sgt_bisaccodes_2010 VALUES (
	'EDU026010',
	'Special Education / Communicative Disorders ')  
INSERT INTO temp_sgt_bisaccodes_2010 VALUES (
	'EDU026060',
	'Special Education / Gifted')  
INSERT INTO temp_sgt_bisaccodes_2010 VALUES (
	'EDU026020',
	'Special Education / Learning Disabilities')  
INSERT INTO temp_sgt_bisaccodes_2010 VALUES (
	'EDU026030',
	'Special Education / Mental Disabilities  ')  
INSERT INTO temp_sgt_bisaccodes_2010 VALUES (
	'EDU026040',
	'Special Education / Physical Disabilities')  
INSERT INTO temp_sgt_bisaccodes_2010 VALUES (
	'EDU026050',
	'Special Education / Social Disabilities  ')  
INSERT INTO temp_sgt_bisaccodes_2010 VALUES (
	'EDU027000',
	'Statistics ')  
INSERT INTO temp_sgt_bisaccodes_2010 VALUES (
	'EDU038000',
	'Students & Student Life')   
INSERT INTO temp_sgt_bisaccodes_2010 VALUES (
	'EDU028000',
	'Study Skills') 
INSERT INTO temp_sgt_bisaccodes_2010 VALUES (
	'EDU029000',
	'Teaching Methods & Materials / General') 
INSERT INTO temp_sgt_bisaccodes_2010 VALUES (
	'EDU029050',
	'Teaching Methods & Materials / Arts & Humanities')  
INSERT INTO temp_sgt_bisaccodes_2010 VALUES (
	'EDU029070',
	'Teaching Methods & Materials / Health & Sexuality') 
INSERT INTO temp_sgt_bisaccodes_2010 VALUES (
	'EDU029060',
	'Teaching Methods & Materials / Library Skills') 
INSERT INTO temp_sgt_bisaccodes_2010 VALUES (
	'EDU029010',
	'Teaching Methods & Materials / Mathematics') 
INSERT INTO temp_sgt_bisaccodes_2010 VALUES (
	'EDU029020',
	'Teaching Methods & Materials / Reading & Phonics')  
INSERT INTO temp_sgt_bisaccodes_2010 VALUES (
	'EDU029030',
	'Teaching Methods & Materials / Science & Technology')  
INSERT INTO temp_sgt_bisaccodes_2010 VALUES (
	'EDU029040',
	'Teaching Methods & Materials / Social Science') 
INSERT INTO temp_sgt_bisaccodes_2010 VALUES (
	'EDU030000',
	'Testing & Measurement')  
INSERT INTO temp_sgt_bisaccodes_2010 VALUES (
	'FAM000000',
	'General') 
INSERT INTO temp_sgt_bisaccodes_2010 VALUES (
	'FAM001000',
	'Abuse / General')  
INSERT INTO temp_sgt_bisaccodes_2010 VALUES (
	'FAM001010',
	'Abuse / Child Abuse')  
INSERT INTO temp_sgt_bisaccodes_2010 VALUES (
	'FAM001030',
	'Abuse / Domestic Partner Abuse')  
INSERT INTO temp_sgt_bisaccodes_2010 VALUES (
	'FAM001020',
	'Abuse / Elder Abuse')  
INSERT INTO temp_sgt_bisaccodes_2010 VALUES (
	'FAM002000',
	'Activities ')  
INSERT INTO temp_sgt_bisaccodes_2010 VALUES (
	'FAM004000',
	'Adoption & Fostering') 
INSERT INTO temp_sgt_bisaccodes_2010 VALUES (
	'FAM005000',
	'Aging') 
INSERT INTO temp_sgt_bisaccodes_2010 VALUES (
	'FAM006000',
	'Alternative Family')  
INSERT INTO temp_sgt_bisaccodes_2010 VALUES (
	'FAM007000',
	'Anger (see also SELF-HELP / Anger Management)') 
INSERT INTO temp_sgt_bisaccodes_2010 VALUES (
	'FAM008000',
	'Baby Names ')  
INSERT INTO temp_sgt_bisaccodes_2010 VALUES (
	'FAM011000',
	'Child Development')   
INSERT INTO temp_sgt_bisaccodes_2010 VALUES (
	'FAM012000',
	'Children with Special Needs') 
INSERT INTO temp_sgt_bisaccodes_2010 VALUES (
	'FAM013000',
	'Conflict Resolution')  
INSERT INTO temp_sgt_bisaccodes_2010 VALUES (
	'FAM014000',
	'Death, Grief, Bereavement') 
INSERT INTO temp_sgt_bisaccodes_2010 VALUES (
	'FAM015000',
	'Divorce & Separation') 
INSERT INTO temp_sgt_bisaccodes_2010 VALUES (
	'FAM016000',
	'Education') 
INSERT INTO temp_sgt_bisaccodes_2010 VALUES (
	'FAM017000',
	'Eldercare') 
INSERT INTO temp_sgt_bisaccodes_2010 VALUES (
	'FAM018000',
	'Emotions')  
INSERT INTO temp_sgt_bisaccodes_2010 VALUES (
	'FAM031000',
	'Ethics & Morals')  
INSERT INTO temp_sgt_bisaccodes_2010 VALUES (
	'FAM019000',
	'Family Relationships') 
INSERT INTO temp_sgt_bisaccodes_2010 VALUES (
	'FAM021000',
	'Friendship ')  
INSERT INTO temp_sgt_bisaccodes_2010 VALUES (
	'FAM027000',
	'Interpersonal Relations')   
INSERT INTO temp_sgt_bisaccodes_2010 VALUES (
	'FAM028000',
	'Learning Disabilities')  
INSERT INTO temp_sgt_bisaccodes_2010 VALUES (
	'FAM046000',
	'Life Stages / General')  
INSERT INTO temp_sgt_bisaccodes_2010 VALUES (
	'FAM003000',
	'Life Stages / Adolescence') 
INSERT INTO temp_sgt_bisaccodes_2010 VALUES (
	'FAM025000',
	'Life Stages / Infants & Toddlers')  
INSERT INTO temp_sgt_bisaccodes_2010 VALUES (
	'FAM039000',
	'Life Stages / School Age')  
INSERT INTO temp_sgt_bisaccodes_2010 VALUES (
	'FAM043000',
	'Life Stages / Teenagers')   
INSERT INTO temp_sgt_bisaccodes_2010 VALUES (
	'FAM029000',
	'Love & Romance') 
INSERT INTO temp_sgt_bisaccodes_2010 VALUES (
	'FAM030000',
	'Marriage')  
INSERT INTO temp_sgt_bisaccodes_2010 VALUES (
	'FAM034000',
	'Parenting / General')  
INSERT INTO temp_sgt_bisaccodes_2010 VALUES (
	'FAM010000',
	'Parenting / Child Rearing') 
INSERT INTO temp_sgt_bisaccodes_2010 VALUES (
	'FAM020000',
	'Parenting / Fatherhood') 
INSERT INTO temp_sgt_bisaccodes_2010 VALUES (
	'FAM022000',
	'Parenting / Grandparenting')  
INSERT INTO temp_sgt_bisaccodes_2010 VALUES (
	'FAM032000',
	'Parenting / Motherhood') 
INSERT INTO temp_sgt_bisaccodes_2010 VALUES (
	'FAM033000',
	'Parenting / Parent & Adult Child')  
INSERT INTO temp_sgt_bisaccodes_2010 VALUES (
	'FAM034010',
	'Parenting / Single Parent') 
INSERT INTO temp_sgt_bisaccodes_2010 VALUES (
	'FAM042000',
	'Parenting / Stepparenting') 
INSERT INTO temp_sgt_bisaccodes_2010 VALUES (
	'FAM035000',
	'Peer Pressure')  
INSERT INTO temp_sgt_bisaccodes_2010 VALUES (
	'FAM037000',
	'Prejudice') 
INSERT INTO temp_sgt_bisaccodes_2010 VALUES (
	'FAM038000',
	'Reference') 
INSERT INTO temp_sgt_bisaccodes_2010 VALUES (
	'FAM041000',
	'Siblings')  
INSERT INTO temp_sgt_bisaccodes_2010 VALUES (
	'FAM044000',
	'Toilet Training')  
INSERT INTO temp_sgt_bisaccodes_2010 VALUES (
	'FIC000000',
	'General') 
INSERT INTO temp_sgt_bisaccodes_2010 VALUES (
	'FIC002000',
	'Action & Adventure')  
INSERT INTO temp_sgt_bisaccodes_2010 VALUES (
	'FIC049000',
	'African American / General')  
INSERT INTO temp_sgt_bisaccodes_2010 VALUES (
	'FIC049010',
	'African American / Christian') 
INSERT INTO temp_sgt_bisaccodes_2010 VALUES (
	'FIC049020',
	'African American / Contemporary Women') 
INSERT INTO temp_sgt_bisaccodes_2010 VALUES (
	'FIC049030',
	'African American / Erotica')  
INSERT INTO temp_sgt_bisaccodes_2010 VALUES (
	'FIC049040',
	'African American / Historical ')  
INSERT INTO temp_sgt_bisaccodes_2010 VALUES (
	'FIC049050',
	'African American / Mystery & Detective') 
INSERT INTO temp_sgt_bisaccodes_2010 VALUES (
	'FIC049060',
	'African American / Romance')  
INSERT INTO temp_sgt_bisaccodes_2010 VALUES (
	'FIC049070',
	'African American / Urban Life ')  
INSERT INTO temp_sgt_bisaccodes_2010 VALUES (
	'FIC040000',
	'Alternative History')  
INSERT INTO temp_sgt_bisaccodes_2010 VALUES (
	'FIC003000',
	'Anthologies (multiple authors)')  
INSERT INTO temp_sgt_bisaccodes_2010 VALUES (
	'FIC041000',
	'Biographical') 
INSERT INTO temp_sgt_bisaccodes_2010 VALUES (
	'FIC042000',
	'Christian / General')  
INSERT INTO temp_sgt_bisaccodes_2010 VALUES (
	'FIC042010',
	'Christian / Classic & Allegory')  
INSERT INTO temp_sgt_bisaccodes_2010 VALUES (
	'FIC042080',
	'Christian / Fantasy')  
INSERT INTO temp_sgt_bisaccodes_2010 VALUES (
	'FIC042020',
	'Christian / Futuristic') 
INSERT INTO temp_sgt_bisaccodes_2010 VALUES (
	'FIC042030',
	'Christian / Historical') 
INSERT INTO temp_sgt_bisaccodes_2010 VALUES (
	'FIC042040',
	'Christian / Romance')  
INSERT INTO temp_sgt_bisaccodes_2010 VALUES (
	'FIC042050',
	'Christian / Short Stories') 
INSERT INTO temp_sgt_bisaccodes_2010 VALUES (
	'FIC042060',
	'Christian / Suspense') 
INSERT INTO temp_sgt_bisaccodes_2010 VALUES (
	'FIC042070',
	'Christian / Western')  
INSERT INTO temp_sgt_bisaccodes_2010 VALUES (
	'FIC004000',
	'Classics')  
INSERT INTO temp_sgt_bisaccodes_2010 VALUES (
	'FIC043000',
	'Coming of Age')  
INSERT INTO temp_sgt_bisaccodes_2010 VALUES (
	'FIC044000',
	'Contemporary Women')  
INSERT INTO temp_sgt_bisaccodes_2010 VALUES (
	'FIC050000',
	'Crime') 
INSERT INTO temp_sgt_bisaccodes_2010 VALUES (
	'FIC051000',
	'Cultural Heritage')   
INSERT INTO temp_sgt_bisaccodes_2010 VALUES (
	'FIC005000',
	'Erotica') 
INSERT INTO temp_sgt_bisaccodes_2010 VALUES (
	'FIC006000',
	'Espionage') 
INSERT INTO temp_sgt_bisaccodes_2010 VALUES (
	'FIC010000',
	'Fairy Tales, Folk Tales, Legends & Mythology')  
INSERT INTO temp_sgt_bisaccodes_2010 VALUES (
	'FIC045000',
	'Family Life')  
INSERT INTO temp_sgt_bisaccodes_2010 VALUES (
	'FIC009000',
	'Fantasy / General')   
INSERT INTO temp_sgt_bisaccodes_2010 VALUES (
	'FIC009010',
	'Fantasy / Contemporary') 
INSERT INTO temp_sgt_bisaccodes_2010 VALUES (
	'FIC009020',
	'Fantasy / Epic') 
INSERT INTO temp_sgt_bisaccodes_2010 VALUES (
	'FIC009030',
	'Fantasy / Historical') 
INSERT INTO temp_sgt_bisaccodes_2010 VALUES (
	'FIC009050',
	'Fantasy / Paranormal') 
INSERT INTO temp_sgt_bisaccodes_2010 VALUES (
	'FIC009040',
	'Fantasy / Short Stories')   
INSERT INTO temp_sgt_bisaccodes_2010 VALUES (
	'FIC009060',
	'Fantasy / Urban Life') 
INSERT INTO temp_sgt_bisaccodes_2010 VALUES (
	'FIC011000',
	'Gay') 
INSERT INTO temp_sgt_bisaccodes_2010 VALUES (
	'FIC012000',
	'Ghost') 
INSERT INTO temp_sgt_bisaccodes_2010 VALUES (
	'FIC014000',
	'Historical ')  
INSERT INTO temp_sgt_bisaccodes_2010 VALUES (
	'FIC015000',
	'Horror')  
INSERT INTO temp_sgt_bisaccodes_2010 VALUES (
	'FIC016000',
	'Humorous')  
INSERT INTO temp_sgt_bisaccodes_2010 VALUES (
	'FIC046000',
	'Jewish')  
INSERT INTO temp_sgt_bisaccodes_2010 VALUES (
	'FIC034000',
	'Legal') 
INSERT INTO temp_sgt_bisaccodes_2010 VALUES (
	'FIC018000',
	'Lesbian') 
INSERT INTO temp_sgt_bisaccodes_2010 VALUES (
	'FIC019000',
	'Literary')  
INSERT INTO temp_sgt_bisaccodes_2010 VALUES (
	'FIC021000',
	'Media Tie-In') 
INSERT INTO temp_sgt_bisaccodes_2010 VALUES (
	'FIC035000',
	'Medical') 
INSERT INTO temp_sgt_bisaccodes_2010 VALUES (
	'FIC020000',
	'Men''s Adventure')  
INSERT INTO temp_sgt_bisaccodes_2010 VALUES (
	'FIC022000',
	'Mystery & Detective / General ')  
INSERT INTO temp_sgt_bisaccodes_2010 VALUES (
	'FIC022010',
	'Mystery & Detective / Hard-Boiled') 
INSERT INTO temp_sgt_bisaccodes_2010 VALUES (
	'FIC022060',
	'Mystery & Detective / Historical')  
INSERT INTO temp_sgt_bisaccodes_2010 VALUES (
	'FIC022020',
	'Mystery & Detective / Police Procedural  ')  
INSERT INTO temp_sgt_bisaccodes_2010 VALUES (
	'FIC022050',
	'Mystery & Detective / Short Stories  ') 
INSERT INTO temp_sgt_bisaccodes_2010 VALUES (
	'FIC022030',
	'Mystery & Detective / Traditional British')  
INSERT INTO temp_sgt_bisaccodes_2010 VALUES (
	'FIC022040',
	'Mystery & Detective / Women Sleuths  ') 
INSERT INTO temp_sgt_bisaccodes_2010 VALUES (
	'FIC024000',
	'Occult & Supernatural')  
INSERT INTO temp_sgt_bisaccodes_2010 VALUES (
	'FIC037000',
	'Political') 
INSERT INTO temp_sgt_bisaccodes_2010 VALUES (
	'FIC025000',
	'Psychological')  
INSERT INTO temp_sgt_bisaccodes_2010 VALUES (
	'FIC026000',
	'Religious') 
INSERT INTO temp_sgt_bisaccodes_2010 VALUES (
	'FIC027000',
	'Romance / General')   
INSERT INTO temp_sgt_bisaccodes_2010 VALUES (
	'FIC027010',
	'Romance / Adult')  
INSERT INTO temp_sgt_bisaccodes_2010 VALUES (
	'FIC027020',
	'Romance / Contemporary') 
INSERT INTO temp_sgt_bisaccodes_2010 VALUES (
	'FIC027030',
	'Romance / Fantasy')   
INSERT INTO temp_sgt_bisaccodes_2010 VALUES (
	'FIC027040',
	'Gothic') 
INSERT INTO temp_sgt_bisaccodes_2010 VALUES (
	'FIC027050',
	'Romance / Historical') 
INSERT INTO temp_sgt_bisaccodes_2010 VALUES (
	'FIC027120',
	'Romance / Paranormal') 
INSERT INTO temp_sgt_bisaccodes_2010 VALUES (
	'FIC027070',
	'Romance / Regency')   
INSERT INTO temp_sgt_bisaccodes_2010 VALUES (
	'FIC027080',
	'Romance / Short Stories')   
INSERT INTO temp_sgt_bisaccodes_2010 VALUES (
	'FIC027110',
	'Romance / Suspense')  
INSERT INTO temp_sgt_bisaccodes_2010 VALUES (
	'FIC027090',
	'Romance / Time Travel')  
INSERT INTO temp_sgt_bisaccodes_2010 VALUES (
	'FIC027100',
	'Romance / Western')   
INSERT INTO temp_sgt_bisaccodes_2010 VALUES (
	'FIC008000',
	'Sagas') 
INSERT INTO temp_sgt_bisaccodes_2010 VALUES (
	'FIC052000',
	'Satire')  
INSERT INTO temp_sgt_bisaccodes_2010 VALUES (
	'FIC028000',
	'Science Fiction / General') 
INSERT INTO temp_sgt_bisaccodes_2010 VALUES (
	'FIC028010',
	'Science Fiction / Adventure') 
INSERT INTO temp_sgt_bisaccodes_2010 VALUES (
	'FIC028020',
	'Science Fiction / High Tech') 
INSERT INTO temp_sgt_bisaccodes_2010 VALUES (
	'FIC028050',
	'Science Fiction / Military')  
INSERT INTO temp_sgt_bisaccodes_2010 VALUES (
	'FIC028040',
	'Science Fiction / Short Stories') 
INSERT INTO temp_sgt_bisaccodes_2010 VALUES (
	'FIC028030',
	'Science Fiction / Space Opera ')  
INSERT INTO temp_sgt_bisaccodes_2010 VALUES (
	'FIC047000',
	'Sea Stories')  
INSERT INTO temp_sgt_bisaccodes_2010 VALUES (
	'FIC029000',
	'Short Stories (single author) ')  
INSERT INTO temp_sgt_bisaccodes_2010 VALUES (
	'FIC038000',
	'Sports')  
INSERT INTO temp_sgt_bisaccodes_2010 VALUES (
	'FIC030000',
	'Suspense')  
INSERT INTO temp_sgt_bisaccodes_2010 VALUES (
	'FIC036000',
	'Technological')  
INSERT INTO temp_sgt_bisaccodes_2010 VALUES (
	'FIC031000',
	'Thrillers') 
INSERT INTO temp_sgt_bisaccodes_2010 VALUES (
	'FIC048000',
	'Urban Life ')  
INSERT INTO temp_sgt_bisaccodes_2010 VALUES (
	'FIC039000',
	'Visionary & Metaphysical')  
INSERT INTO temp_sgt_bisaccodes_2010 VALUES (
	'FIC032000',
	'War & Military') 
INSERT INTO temp_sgt_bisaccodes_2010 VALUES (
	'FIC033000',
	'Westerns')  
INSERT INTO temp_sgt_bisaccodes_2010 VALUES (
	'FOR000000',
	'General') 
INSERT INTO temp_sgt_bisaccodes_2010 VALUES (
	'FOR001000',
	'African Languages (see also Swahili) ') 
INSERT INTO temp_sgt_bisaccodes_2010 VALUES (
	'FOR033000',
	'Ancient Languages (see also Latin)   ') 
INSERT INTO temp_sgt_bisaccodes_2010 VALUES (
	'FOR002000',
	'Arabic')  
INSERT INTO temp_sgt_bisaccodes_2010 VALUES (
	'FOR034000',
	'Baltic Languages') 
INSERT INTO temp_sgt_bisaccodes_2010 VALUES (
	'FOR029000',
	'Celtic Languages') 
INSERT INTO temp_sgt_bisaccodes_2010 VALUES (
	'FOR003000',
	'Chinese') 
INSERT INTO temp_sgt_bisaccodes_2010 VALUES (
	'FOR035000',
	'Creole Languages') 
INSERT INTO temp_sgt_bisaccodes_2010 VALUES (
	'FOR036000',
	'Czech') 
INSERT INTO temp_sgt_bisaccodes_2010 VALUES (
	'FOR004000',
	'Danish')  
INSERT INTO temp_sgt_bisaccodes_2010 VALUES (
	'FOR006000',
	'Dutch') 
INSERT INTO temp_sgt_bisaccodes_2010 VALUES (
	'FOR007000',
	'English as a Second Language') 
INSERT INTO temp_sgt_bisaccodes_2010 VALUES (
	'FOR037000',
	'Finnish') 
INSERT INTO temp_sgt_bisaccodes_2010 VALUES (
	'FOR008000',
	'French')  
INSERT INTO temp_sgt_bisaccodes_2010 VALUES (
	'FOR009000',
	'German')  
INSERT INTO temp_sgt_bisaccodes_2010 VALUES (
	'FOR010000',
	'Greek (Modern)') 
INSERT INTO temp_sgt_bisaccodes_2010 VALUES (
	'FOR011000',
	'Hebrew')  
INSERT INTO temp_sgt_bisaccodes_2010 VALUES (
	'FOR038000',
	'Hindi') 
INSERT INTO temp_sgt_bisaccodes_2010 VALUES (
	'FOR012000',
	'Hungarian') 
INSERT INTO temp_sgt_bisaccodes_2010 VALUES (
	'FOR030000',
	'Indic Languages')  
INSERT INTO temp_sgt_bisaccodes_2010 VALUES (
	'FOR013000',
	'Italian') 
INSERT INTO temp_sgt_bisaccodes_2010 VALUES (
	'FOR014000',
	'Japanese')  
INSERT INTO temp_sgt_bisaccodes_2010 VALUES (
	'FOR015000',
	'Korean')  
INSERT INTO temp_sgt_bisaccodes_2010 VALUES (
	'FOR016000',
	'Latin') 
INSERT INTO temp_sgt_bisaccodes_2010 VALUES (
	'FOR017000',
	'Miscellaneous')  
INSERT INTO temp_sgt_bisaccodes_2010 VALUES (
	'FOR005000',
	'Multi-Language Dictionaries') 
INSERT INTO temp_sgt_bisaccodes_2010 VALUES (
	'FOR018000',
	'Multi-Language Phrasebooks')  
INSERT INTO temp_sgt_bisaccodes_2010 VALUES (
	'FOR031000',
	'Native American Languages') 
INSERT INTO temp_sgt_bisaccodes_2010 VALUES (
	'FOR039000',
	'Norwegian') 
INSERT INTO temp_sgt_bisaccodes_2010 VALUES (
	'FOR032000',
	'Oceanic & Australian Languages')  
INSERT INTO temp_sgt_bisaccodes_2010 VALUES (
	'FOR045000',
	'Old & Middle English') 
INSERT INTO temp_sgt_bisaccodes_2010 VALUES (
	'FOR040000',
	'Persian') 
INSERT INTO temp_sgt_bisaccodes_2010 VALUES (
	'FOR019000',
	'Polish')  
INSERT INTO temp_sgt_bisaccodes_2010 VALUES (
	'FOR020000',
	'Portuguese ')  
INSERT INTO temp_sgt_bisaccodes_2010 VALUES (
	'FOR041000',
	'Romance Languages (Other)') 
INSERT INTO temp_sgt_bisaccodes_2010 VALUES (
	'FOR021000',
	'Russian') 
INSERT INTO temp_sgt_bisaccodes_2010 VALUES (
	'FOR022000',
	'Scandinavian Languages (Other)')  
INSERT INTO temp_sgt_bisaccodes_2010 VALUES (
	'FOR023000',
	'Serbian & Croatian')  
INSERT INTO temp_sgt_bisaccodes_2010 VALUES (
	'FOR024000',
	'Slavic Languages (Other)')  
INSERT INTO temp_sgt_bisaccodes_2010 VALUES (
	'FOR025000',
	'Southeast Asian Languages (see also Vietnamese)') 
INSERT INTO temp_sgt_bisaccodes_2010 VALUES (
	'FOR026000',
	'Spanish') 
INSERT INTO temp_sgt_bisaccodes_2010 VALUES (
	'FOR042000',
	'Swahili') 
INSERT INTO temp_sgt_bisaccodes_2010 VALUES (
	'FOR043000',
	'Swedish') 
INSERT INTO temp_sgt_bisaccodes_2010 VALUES (
	'FOR027000',
	'Turkish & Turkic Languages')  
INSERT INTO temp_sgt_bisaccodes_2010 VALUES (
	'FOR044000',
	'Vietnamese ')  
INSERT INTO temp_sgt_bisaccodes_2010 VALUES (
	'FOR028000',
	'Yiddish') 
INSERT INTO temp_sgt_bisaccodes_2010 VALUES (
	'GAM000000',
	'General') 
INSERT INTO temp_sgt_bisaccodes_2010 VALUES (
	'GAM001010',
	'Backgammon ')  
INSERT INTO temp_sgt_bisaccodes_2010 VALUES (
	'GAM001000',
	'Board') 
INSERT INTO temp_sgt_bisaccodes_2010 VALUES (
	'GAM002000',
	'Card Games / General') 
INSERT INTO temp_sgt_bisaccodes_2010 VALUES (
	'GAM002030',
	'Card Games / Blackjack') 
INSERT INTO temp_sgt_bisaccodes_2010 VALUES (
	'GAM002010',
	'Card Games / Bridge')  
INSERT INTO temp_sgt_bisaccodes_2010 VALUES (
	'GAM002040',
	'Card Games / Poker')  
INSERT INTO temp_sgt_bisaccodes_2010 VALUES (
	'GAM002020',
	'Card Games / Solitaire') 
INSERT INTO temp_sgt_bisaccodes_2010 VALUES (
	'GAM001020',
	'Checkers')  
INSERT INTO temp_sgt_bisaccodes_2010 VALUES (
	'GAM001030',
	'Chess') 
INSERT INTO temp_sgt_bisaccodes_2010 VALUES (
	'GAM003000',
	'Crosswords / General') 
INSERT INTO temp_sgt_bisaccodes_2010 VALUES (
	'GAM003040',
	'Crosswords / Dictionaries') 
INSERT INTO temp_sgt_bisaccodes_2010 VALUES (
	'GAM016000',
	'Fantasy Sports') 
INSERT INTO temp_sgt_bisaccodes_2010 VALUES (
	'GAM004000',
	'Gambling / General')  
INSERT INTO temp_sgt_bisaccodes_2010 VALUES (
	'GAM004020',
	'Gambling / Lotteries') 
INSERT INTO temp_sgt_bisaccodes_2010 VALUES (
	'GAM004050',
	'Gambling / Sports')   
INSERT INTO temp_sgt_bisaccodes_2010 VALUES (
	'GAM004030',
	'Gambling / Table') 
INSERT INTO temp_sgt_bisaccodes_2010 VALUES (
	'GAM004040',
	'Gambling / Track Betting')  
INSERT INTO temp_sgt_bisaccodes_2010 VALUES (
	'GAM005000',
	'Logic & Brain Teasers')  
INSERT INTO temp_sgt_bisaccodes_2010 VALUES (
	'GAM006000',
	'Magic') 
INSERT INTO temp_sgt_bisaccodes_2010 VALUES (
	'GAM007000',
	'Puzzles') 
INSERT INTO temp_sgt_bisaccodes_2010 VALUES (
	'GAM008000',
	'Quizzes') 
INSERT INTO temp_sgt_bisaccodes_2010 VALUES (
	'GAM009000',
	'Reference') 
INSERT INTO temp_sgt_bisaccodes_2010 VALUES (
	'GAM010000',
	'Role Playing & Fantasy') 
INSERT INTO temp_sgt_bisaccodes_2010 VALUES (
	'GAM017000',
	'Sudoku')  
INSERT INTO temp_sgt_bisaccodes_2010 VALUES (
	'GAM011000',
	'Travel Games') 
INSERT INTO temp_sgt_bisaccodes_2010 VALUES (
	'GAM012000',
	'Trivia')  
INSERT INTO temp_sgt_bisaccodes_2010 VALUES (
	'GAM013000',
	'Video & Electronic')  
INSERT INTO temp_sgt_bisaccodes_2010 VALUES (
	'GAM014000',
	'Word & Word Search')  
INSERT INTO temp_sgt_bisaccodes_2010 VALUES (
	'GAR000000',
	'General') 
INSERT INTO temp_sgt_bisaccodes_2010 VALUES (
	'GAR027000',
	'Climatic / General')  
INSERT INTO temp_sgt_bisaccodes_2010 VALUES (
	'GAR027010',
	'Climatic / Desert')   
INSERT INTO temp_sgt_bisaccodes_2010 VALUES (
	'GAR027020',
	'Climatic / Temperate') 
INSERT INTO temp_sgt_bisaccodes_2010 VALUES (
	'GAR027030',
	'Climatic / Tropical')  
INSERT INTO temp_sgt_bisaccodes_2010 VALUES (
	'GAR001000',
	'Container') 
INSERT INTO temp_sgt_bisaccodes_2010 VALUES (
	'GAR002000',
	'Essays')  
INSERT INTO temp_sgt_bisaccodes_2010 VALUES (
	'GAR004000',
	'Flowers / General')   
INSERT INTO temp_sgt_bisaccodes_2010 VALUES (
	'GAR004010',
	'Flowers / Annuals')   
INSERT INTO temp_sgt_bisaccodes_2010 VALUES (
	'GAR004030',
	'Flowers / Bulbs')  
INSERT INTO temp_sgt_bisaccodes_2010 VALUES (
	'GAR004040',
	'Flowers / Orchids')   
INSERT INTO temp_sgt_bisaccodes_2010 VALUES (
	'GAR004050',
	'Flowers / Perennials') 
INSERT INTO temp_sgt_bisaccodes_2010 VALUES (
	'GAR004060',
	'Flowers / Roses')  
INSERT INTO temp_sgt_bisaccodes_2010 VALUES (
	'GAR004080',
	'Flowers / Wildflowers')  
INSERT INTO temp_sgt_bisaccodes_2010 VALUES (
	'GAR005000',
	'Fruit') 
INSERT INTO temp_sgt_bisaccodes_2010 VALUES (
	'GAR006000',
	'Garden Design')  
INSERT INTO temp_sgt_bisaccodes_2010 VALUES (
	'GAR007000',
	'Garden Furnishings')  
INSERT INTO temp_sgt_bisaccodes_2010 VALUES (
	'GAR008000',
	'Greenhouses')  
INSERT INTO temp_sgt_bisaccodes_2010 VALUES (
	'GAR009000',
	'Herbs') 
INSERT INTO temp_sgt_bisaccodes_2010 VALUES (
	'GAR010000',
	'House Plants & Indoor')  
INSERT INTO temp_sgt_bisaccodes_2010 VALUES (
	'GAR013000',
	'Japanese Gardens') 
INSERT INTO temp_sgt_bisaccodes_2010 VALUES (
	'GAR014000',
	'Landscape') 
INSERT INTO temp_sgt_bisaccodes_2010 VALUES (
	'GAR015000',
	'Lawns') 
INSERT INTO temp_sgt_bisaccodes_2010 VALUES (
	'GAR016000',
	'Organic') 
INSERT INTO temp_sgt_bisaccodes_2010 VALUES (
	'GAR017000',
	'Ornamental Plants')   
INSERT INTO temp_sgt_bisaccodes_2010 VALUES (
	'GAR018000',
	'Reference') 
INSERT INTO temp_sgt_bisaccodes_2010 VALUES (
	'GAR019000',
	'Regional / General')  
INSERT INTO temp_sgt_bisaccodes_2010 VALUES (
	'GAR019010',
	'Regional / Canada')   
INSERT INTO temp_sgt_bisaccodes_2010 VALUES (
	'GAR019020',
	'Regional / Middle Atlantic (DC, DE, MD, NJ, NY, PA)')  
INSERT INTO temp_sgt_bisaccodes_2010 VALUES (
	'GAR019030',
	'Regional / Midwest (IA, IL, IN, KS, MI, MN, MO, ND, NE, OH, SD, WI)  ')  
INSERT INTO temp_sgt_bisaccodes_2010 VALUES (
	'GAR019040',
	'Regional / New England (CT, MA, ME, NH, RI, VT)') 
INSERT INTO temp_sgt_bisaccodes_2010 VALUES (
	'GAR019050',
	'Regional / Pacific Northwest (OR, WA)') 
INSERT INTO temp_sgt_bisaccodes_2010 VALUES (
	'GAR019060',
	'Regional / South (AL, AR, FL, GA, KY, LA, MS, NC, SC, TN, VA, WV)') 
INSERT INTO temp_sgt_bisaccodes_2010 VALUES (
	'GAR019070',
	'Regional / Southwest (AZ, NM, OK, TX)') 
INSERT INTO temp_sgt_bisaccodes_2010 VALUES (
	'GAR019080',
	'Regional / West (AK, CA, CO, HI, ID, MT, NV, UT, WY)') 
INSERT INTO temp_sgt_bisaccodes_2010 VALUES (
	'GAR020000',
	'Shade') 
INSERT INTO temp_sgt_bisaccodes_2010 VALUES (
	'GAR021000',
	'Shrubs')  
INSERT INTO temp_sgt_bisaccodes_2010 VALUES (
	'GAR022000',
	'Techniques ')  
INSERT INTO temp_sgt_bisaccodes_2010 VALUES (
	'GAR023000',
	'Topiary') 
INSERT INTO temp_sgt_bisaccodes_2010 VALUES (
	'GAR024000',
	'Trees') 
INSERT INTO temp_sgt_bisaccodes_2010 VALUES (
	'GAR028000',
	'Urban') 
INSERT INTO temp_sgt_bisaccodes_2010 VALUES (
	'GAR025000',
	'Vegetables ')  
INSERT INTO temp_sgt_bisaccodes_2010 VALUES (
	'HEA000000',
	'General') 
INSERT INTO temp_sgt_bisaccodes_2010 VALUES (
	'HEA001000',
	'Acupressure & Acupuncture (see also MEDICAL / Acupuncture)') 
INSERT INTO temp_sgt_bisaccodes_2010 VALUES (
	'HEA002000',
	'Aerobics')  
INSERT INTO temp_sgt_bisaccodes_2010 VALUES (
	'HEA027000',
	'Allergies') 
INSERT INTO temp_sgt_bisaccodes_2010 VALUES (
	'HEA032000',
	'Alternative Therapies')  
INSERT INTO temp_sgt_bisaccodes_2010 VALUES (
	'HEA029000',
	'Aromatherapy') 
INSERT INTO temp_sgt_bisaccodes_2010 VALUES (
	'HEA003000',
	'Beauty & Grooming')   
INSERT INTO temp_sgt_bisaccodes_2010 VALUES (
	'HEA044000',
	'Breastfeeding')  
INSERT INTO temp_sgt_bisaccodes_2010 VALUES (
	'HEA046000',
	'Children''s Health')   
INSERT INTO temp_sgt_bisaccodes_2010 VALUES (
	'HEA006000',
	'Diets') 
INSERT INTO temp_sgt_bisaccodes_2010 VALUES (
	'HEA039000',
	'Diseases / General')  
INSERT INTO temp_sgt_bisaccodes_2010 VALUES (
	'HEA039010',
	'Diseases / Abdominal') 
INSERT INTO temp_sgt_bisaccodes_2010 VALUES (
	'HEA039020',
	'Diseases / AIDS & HIV')  
INSERT INTO temp_sgt_bisaccodes_2010 VALUES (
	'HEA039140',
	'Diseases / Alzheimer''s & Dementia') 
INSERT INTO temp_sgt_bisaccodes_2010 VALUES (
	'HEA039030',
	'Diseases / Cancer')   
INSERT INTO temp_sgt_bisaccodes_2010 VALUES (
	'HEA039150',
	'Diseases / Chronic Fatigue Syndrome  ') 
INSERT INTO temp_sgt_bisaccodes_2010 VALUES (
	'HEA039040',
	'Diseases / Contagious')  
INSERT INTO temp_sgt_bisaccodes_2010 VALUES (
	'HEA039050',
	'Diseases / Diabetes')  
INSERT INTO temp_sgt_bisaccodes_2010 VALUES (
	'HEA039060',
	'Diseases / Genetic')  
INSERT INTO temp_sgt_bisaccodes_2010 VALUES (
	'HEA039070',
	'Diseases / Genitourinary & STDs') 
INSERT INTO temp_sgt_bisaccodes_2010 VALUES (
	'HEA039080',
	'Diseases / Heart') 
INSERT INTO temp_sgt_bisaccodes_2010 VALUES (
	'HEA039090',
	'Diseases / Immune System')  
INSERT INTO temp_sgt_bisaccodes_2010 VALUES (
	'HEA039100',
	'Diseases / Musculoskeletal')  
INSERT INTO temp_sgt_bisaccodes_2010 VALUES (
	'HEA039110',
	'Diseases / Nervous System (incl. Brain)  ')  
INSERT INTO temp_sgt_bisaccodes_2010 VALUES (
	'HEA039120',
	'Diseases / Respiratory') 
INSERT INTO temp_sgt_bisaccodes_2010 VALUES (
	'HEA039130',
	'Diseases / Skin')  
INSERT INTO temp_sgt_bisaccodes_2010 VALUES (
	'HEA007000',
	'Exercise')  
INSERT INTO temp_sgt_bisaccodes_2010 VALUES (
	'HEA033000',
	'First Aid') 
INSERT INTO temp_sgt_bisaccodes_2010 VALUES (
	'HEA034000',
	'Food Content Guides')  
INSERT INTO temp_sgt_bisaccodes_2010 VALUES (
	'HEA009000',
	'Healing') 
INSERT INTO temp_sgt_bisaccodes_2010 VALUES (
	'HEA028000',
	'Health Care Issues')  
INSERT INTO temp_sgt_bisaccodes_2010 VALUES (
	'HEA010000',
	'Healthy Living') 
INSERT INTO temp_sgt_bisaccodes_2010 VALUES (
	'HEA035000',
	'Hearing & Speech') 
INSERT INTO temp_sgt_bisaccodes_2010 VALUES (
	'HEA011000',
	'Herbal Medications')  
INSERT INTO temp_sgt_bisaccodes_2010 VALUES (
	'HEA012000',
	'Holism')  
INSERT INTO temp_sgt_bisaccodes_2010 VALUES (
	'HEA030000',
	'Homeopathy ')  
INSERT INTO temp_sgt_bisaccodes_2010 VALUES (
	'HEA045000',
	'Infertility')  
INSERT INTO temp_sgt_bisaccodes_2010 VALUES (
	'HEA013000',
	'Macrobiotics') 
INSERT INTO temp_sgt_bisaccodes_2010 VALUES (
	'HEA014000',
	'Massage & Reflexotherapy')  
INSERT INTO temp_sgt_bisaccodes_2010 VALUES (
	'HEA015000',
	'Men''s Health') 
INSERT INTO temp_sgt_bisaccodes_2010 VALUES (
	'HEA026000',
	'Naprapathy ')  
INSERT INTO temp_sgt_bisaccodes_2010 VALUES (
	'HEA016000',
	'Naturopathy')  
INSERT INTO temp_sgt_bisaccodes_2010 VALUES (
	'HEA017000',
	'Nutrition') 
INSERT INTO temp_sgt_bisaccodes_2010 VALUES (
	'HEA040000',
	'Oral Health')  
INSERT INTO temp_sgt_bisaccodes_2010 VALUES (
	'HEA036000',
	'Pain Management')  
INSERT INTO temp_sgt_bisaccodes_2010 VALUES (
	'HEA018000',
	'Physical Impairments') 
INSERT INTO temp_sgt_bisaccodes_2010 VALUES (
	'HEA041000',
	'Pregnancy & Childbirth') 
INSERT INTO temp_sgt_bisaccodes_2010 VALUES (
	'HEA020000',
	'Reference') 
INSERT INTO temp_sgt_bisaccodes_2010 VALUES (
	'HEA021000',
	'Safety')  
INSERT INTO temp_sgt_bisaccodes_2010 VALUES (
	'HEA042000',
	'Sexuality') 
INSERT INTO temp_sgt_bisaccodes_2010 VALUES (
	'HEA043000',
	'Sleep & Sleep Disorders')   
INSERT INTO temp_sgt_bisaccodes_2010 VALUES (
	'HEA037000',
	'Vision')  
INSERT INTO temp_sgt_bisaccodes_2010 VALUES (
	'HEA023000',
	'Vitamins')  
INSERT INTO temp_sgt_bisaccodes_2010 VALUES (
	'HEA019000',
	'Weight Loss')  
INSERT INTO temp_sgt_bisaccodes_2010 VALUES (
	'HEA024000',
	'Women''s Health') 
INSERT INTO temp_sgt_bisaccodes_2010 VALUES (
	'HEA038000',
	'Work-Related Health')  
INSERT INTO temp_sgt_bisaccodes_2010 VALUES (
	'HEA025000',
	'Yoga')  
INSERT INTO temp_sgt_bisaccodes_2010 VALUES (
	'HIS000000',
	'General') 
INSERT INTO temp_sgt_bisaccodes_2010 VALUES (
	'HIS001000',
	'Africa / General') 
INSERT INTO temp_sgt_bisaccodes_2010 VALUES (
	'HIS001010',
	'Africa / Central') 
INSERT INTO temp_sgt_bisaccodes_2010 VALUES (
	'HIS001020',
	'Africa / East')  
INSERT INTO temp_sgt_bisaccodes_2010 VALUES (
	'HIS001030',
	'Africa / North') 
INSERT INTO temp_sgt_bisaccodes_2010 VALUES (
	'HIS001040',
	'Africa / South / General')  
INSERT INTO temp_sgt_bisaccodes_2010 VALUES (
	'HIS047000',
	'Africa / South / Republic of South Africa')  
INSERT INTO temp_sgt_bisaccodes_2010 VALUES (
	'HIS001050',
	'Africa / West')  
INSERT INTO temp_sgt_bisaccodes_2010 VALUES (
	'HIS038000',
	'Americas (North, Central, South, West Indies)') 
INSERT INTO temp_sgt_bisaccodes_2010 VALUES (
	'HIS002000',
	'Ancient / General')   
INSERT INTO temp_sgt_bisaccodes_2010 VALUES (
	'HIS002030',
	'Ancient / Egypt')  
INSERT INTO temp_sgt_bisaccodes_2010 VALUES (
	'HIS002010',
	'Ancient / Greece') 
INSERT INTO temp_sgt_bisaccodes_2010 VALUES (
	'HIS002020',
	'Ancient / Rome') 
INSERT INTO temp_sgt_bisaccodes_2010 VALUES (
	'HIS003000',
	'Asia / General') 
INSERT INTO temp_sgt_bisaccodes_2010 VALUES (
	'HIS050000',
	'Asia / Central Asia')  
INSERT INTO temp_sgt_bisaccodes_2010 VALUES (
	'HIS008000',
	'Asia / China') 
INSERT INTO temp_sgt_bisaccodes_2010 VALUES (
	'HIS017000',
	'Asia / India & South Asia') 
INSERT INTO temp_sgt_bisaccodes_2010 VALUES (
	'HIS021000',
	'Asia / Japan') 
INSERT INTO temp_sgt_bisaccodes_2010 VALUES (
	'HIS023000',
	'Asia / Korea') 
INSERT INTO temp_sgt_bisaccodes_2010 VALUES (
	'HIS048000',
	'Asia / Southeast Asia')  
INSERT INTO temp_sgt_bisaccodes_2010 VALUES (
	'HIS004000',
	'Australia & New Zealand')   
INSERT INTO temp_sgt_bisaccodes_2010 VALUES (
	'HIS006000',
	'Canada / General') 
INSERT INTO temp_sgt_bisaccodes_2010 VALUES (
	'HIS006010',
	'Canada / Pre-Confederation (to 1867) ') 
INSERT INTO temp_sgt_bisaccodes_2010 VALUES (
	'HIS006020',
	'Canada / Post-Confederation (1867-)  ') 
INSERT INTO temp_sgt_bisaccodes_2010 VALUES (
	'HIS041000',
	'Caribbean & West Indies / General') 
INSERT INTO temp_sgt_bisaccodes_2010 VALUES (
	'HIS041010',
	'Caribbean & West Indies / Cuba')  
INSERT INTO temp_sgt_bisaccodes_2010 VALUES (
	'HIS039000',
	'Civilization') 
INSERT INTO temp_sgt_bisaccodes_2010 VALUES (
	'HIS049000',
	'Essays')  
INSERT INTO temp_sgt_bisaccodes_2010 VALUES (
	'HIS010000',
	'Europe / General') 
INSERT INTO temp_sgt_bisaccodes_2010 VALUES (
	'HIS040000',
	'Europe / Austria & Hungary')  
INSERT INTO temp_sgt_bisaccodes_2010 VALUES (
	'HIS005000',
	'Europe / Baltic States') 
INSERT INTO temp_sgt_bisaccodes_2010 VALUES (
	'HIS010010',
	'Europe / Eastern') 
INSERT INTO temp_sgt_bisaccodes_2010 VALUES (
	'HIS012000',
	'Europe / Former Soviet Republics')  
INSERT INTO temp_sgt_bisaccodes_2010 VALUES (
	'HIS013000',
	'Europe / France')  
INSERT INTO temp_sgt_bisaccodes_2010 VALUES (
	'HIS014000',
	'Europe / Germany') 
INSERT INTO temp_sgt_bisaccodes_2010 VALUES (
	'HIS015000',
	'Europe / Great Britain') 
INSERT INTO temp_sgt_bisaccodes_2010 VALUES (
	'HIS042000',
	'Europe / Greece (see also Ancient / Greece) ')  
INSERT INTO temp_sgt_bisaccodes_2010 VALUES (
	'HIS018000',
	'Europe / Ireland') 
INSERT INTO temp_sgt_bisaccodes_2010 VALUES (
	'HIS020000',
	'Europe / Italy') 
INSERT INTO temp_sgt_bisaccodes_2010 VALUES (
	'HIS032000',
	'Europe / Russia & the Former Soviet Union')  
INSERT INTO temp_sgt_bisaccodes_2010 VALUES (
	'HIS044000',
	'Europe / Scandinavia') 
INSERT INTO temp_sgt_bisaccodes_2010 VALUES (
	'HIS045000',
	'Europe / Spain & Portugal') 
INSERT INTO temp_sgt_bisaccodes_2010 VALUES (
	'HIS010020',
	'Europe / Western') 
INSERT INTO temp_sgt_bisaccodes_2010 VALUES (
	'HIS051000',
	'Expeditions & Discoveries') 
INSERT INTO temp_sgt_bisaccodes_2010 VALUES (
	'HIS052000',
	'Historical Geography') 
INSERT INTO temp_sgt_bisaccodes_2010 VALUES (
	'HIS016000',
	'Historiography') 
INSERT INTO temp_sgt_bisaccodes_2010 VALUES (
	'HIS043000',
	'Holocaust') 
INSERT INTO temp_sgt_bisaccodes_2010 VALUES (
	'HIS022000',
	'Jewish')  
INSERT INTO temp_sgt_bisaccodes_2010 VALUES (
	'HIS024000',
	'Latin America / General')   
INSERT INTO temp_sgt_bisaccodes_2010 VALUES (
	'HIS007000',
	'Latin America / Central America') 
INSERT INTO temp_sgt_bisaccodes_2010 VALUES (
	'HIS025000',
	'Latin America / Mexico') 
INSERT INTO temp_sgt_bisaccodes_2010 VALUES (
	'HIS033000',
	'Latin America / South America ')  
INSERT INTO temp_sgt_bisaccodes_2010 VALUES (
	'HIS037010',
	'Medieval')  
INSERT INTO temp_sgt_bisaccodes_2010 VALUES (
	'HIS026000',
	'Middle East / General')  
INSERT INTO temp_sgt_bisaccodes_2010 VALUES (
	'HIS009000',
	'Middle East / Egypt (see also Ancient / Egypt)')  
INSERT INTO temp_sgt_bisaccodes_2010 VALUES (
	'HIS019000',
	'Middle East / Israel') 
INSERT INTO temp_sgt_bisaccodes_2010 VALUES (
	'HIS055000',
	'Middle East / Turkey & Ottoman Empire') 
INSERT INTO temp_sgt_bisaccodes_2010 VALUES (
	'HIS027000',
	'Military / General')  
INSERT INTO temp_sgt_bisaccodes_2010 VALUES (
	'HIS027190',
	'Military / Afghan War (2001-) ')  
INSERT INTO temp_sgt_bisaccodes_2010 VALUES (
	'HIS027140',
	'Military / Aviation')  
INSERT INTO temp_sgt_bisaccodes_2010 VALUES (
	'HIS027010',
	'Military / Biological & Chemical Warfare ')  
INSERT INTO temp_sgt_bisaccodes_2010 VALUES (
	'HIS027160',
	'Military / Canada')   
INSERT INTO temp_sgt_bisaccodes_2010 VALUES (
	'HIS027170',
	'Military / Iraq War (2003-)') 
INSERT INTO temp_sgt_bisaccodes_2010 VALUES (
	'HIS027020',
	'Military / Korean War')  
INSERT INTO temp_sgt_bisaccodes_2010 VALUES (
	'HIS027150',
	'Military / Naval') 
INSERT INTO temp_sgt_bisaccodes_2010 VALUES (
	'HIS027030',
	'Military / Nuclear Warfare')  
INSERT INTO temp_sgt_bisaccodes_2010 VALUES (
	'HIS027040',
	'Military / Persian Gulf War (1991)   ') 
INSERT INTO temp_sgt_bisaccodes_2010 VALUES (
	'HIS027050',
	'Military / Pictorial') 
INSERT INTO temp_sgt_bisaccodes_2010 VALUES (
	'HIS027180',
	'Military / Special Forces') 
INSERT INTO temp_sgt_bisaccodes_2010 VALUES (
	'HIS027060',
	'Military / Strategy')  
INSERT INTO temp_sgt_bisaccodes_2010 VALUES (
	'HIS027110',
	'Military / United States')  
INSERT INTO temp_sgt_bisaccodes_2010 VALUES (
	'HIS027120',
	'Military / Veterans')  
INSERT INTO temp_sgt_bisaccodes_2010 VALUES (
	'HIS027070',
	'Military / Vietnam War') 
INSERT INTO temp_sgt_bisaccodes_2010 VALUES (
	'HIS027080',
	'Military / Weapons')  
INSERT INTO temp_sgt_bisaccodes_2010 VALUES (
	'HIS027090',
	'Military / World War I') 
INSERT INTO temp_sgt_bisaccodes_2010 VALUES (
	'HIS027100',
	'Military / World War II')   
INSERT INTO temp_sgt_bisaccodes_2010 VALUES (
	'HIS027130',
	'Military / Other') 
INSERT INTO temp_sgt_bisaccodes_2010 VALUES (
	'HIS037030',
	'Modern / General') 
INSERT INTO temp_sgt_bisaccodes_2010 VALUES (
	'HIS037090',
	'Modern / 16th Century')  
INSERT INTO temp_sgt_bisaccodes_2010 VALUES (
	'HIS037040',
	'Modern / 17th Century')  
INSERT INTO temp_sgt_bisaccodes_2010 VALUES (
	'HIS037050',
	'Modern / 18th Century')  
INSERT INTO temp_sgt_bisaccodes_2010 VALUES (
	'HIS037060',
	'Modern / 19th Century')  
INSERT INTO temp_sgt_bisaccodes_2010 VALUES (
	'HIS037070',
	'Modern / 20th Century')  
INSERT INTO temp_sgt_bisaccodes_2010 VALUES (
	'HIS037080',
	'Modern / 21st Century')  
INSERT INTO temp_sgt_bisaccodes_2010 VALUES (
	'HIS028000',
	'Native American')  
INSERT INTO temp_sgt_bisaccodes_2010 VALUES (
	'HIS029000',
	'North America')  
INSERT INTO temp_sgt_bisaccodes_2010 VALUES (
	'HIS053000',
	'Oceania') 
INSERT INTO temp_sgt_bisaccodes_2010 VALUES (
	'HIS046000',
	'Polar Regions')  
INSERT INTO temp_sgt_bisaccodes_2010 VALUES (
	'HIS030000',
	'Reference') 
INSERT INTO temp_sgt_bisaccodes_2010 VALUES (
	'HIS037020',
	'Renaissance')  
INSERT INTO temp_sgt_bisaccodes_2010 VALUES (
	'HIS031000',
	'Revolutionary')  
INSERT INTO temp_sgt_bisaccodes_2010 VALUES (
	'HIS054000',
	'Social History') 
INSERT INTO temp_sgt_bisaccodes_2010 VALUES (
	'HIS035000',
	'Study & Teaching') 
INSERT INTO temp_sgt_bisaccodes_2010 VALUES (
	'HIS036000',
	'United States / General')   
INSERT INTO temp_sgt_bisaccodes_2010 VALUES (
	'HIS036020',
	'United States / Colonial Period (1600-1775) ')  
INSERT INTO temp_sgt_bisaccodes_2010 VALUES (
	'HIS036030',
	'United States / Revolutionary Period (1775-1800)')  
INSERT INTO temp_sgt_bisaccodes_2010 VALUES (
	'HIS036040',
	'United States / 19th Century') 
INSERT INTO temp_sgt_bisaccodes_2010 VALUES (
	'HIS036050',
	'United States / Civil War Period (1850-1877)')  
INSERT INTO temp_sgt_bisaccodes_2010 VALUES (
	'HIS036060',
	'United States / 20th Century') 
INSERT INTO temp_sgt_bisaccodes_2010 VALUES (
	'HIS036070',
	'United States / 21st Century') 
INSERT INTO temp_sgt_bisaccodes_2010 VALUES (
	'HIS036010',
	'United States / State & Local / General  ')  
INSERT INTO temp_sgt_bisaccodes_2010 VALUES (
	'HIS036080',
	'United States / State & Local / Middle Atlantic (DC, DE, MD, NJ, NY, PA)')  
INSERT INTO temp_sgt_bisaccodes_2010 VALUES (
	'HIS036090',
	'United States / State & Local / Midwest (IA, IL, IN, KS, MI, MN, MO, ND, NE, OH, SD, WI)') 
INSERT INTO temp_sgt_bisaccodes_2010 VALUES (
	'HIS036100',
	'United States / State & Local / New England (CT, MA, ME, NH, RI, VT) ')  
INSERT INTO temp_sgt_bisaccodes_2010 VALUES (
	'HIS036110',
	'United States / State & Local / Pacific Northwest (OR, WA)') 
INSERT INTO temp_sgt_bisaccodes_2010 VALUES (
	'HIS036120',
	'United States / State & Local / South (AL, AR, FL, GA, KY, LA, MS, NC, SC, TN, VA, WV) ')  
INSERT INTO temp_sgt_bisaccodes_2010 VALUES (
	'HIS036130',
	'United States / State & Local / Southwest (AZ, NM, OK, TX)') 
INSERT INTO temp_sgt_bisaccodes_2010 VALUES (
	'HIS036140',
	'United States / State & Local / West (AK, CA, CO, HI, ID, MT, NV, UT, WY)') 
INSERT INTO temp_sgt_bisaccodes_2010 VALUES (
	'HIS037000',
	'World') 
INSERT INTO temp_sgt_bisaccodes_2010 VALUES (
	'HOM000000',
	'General') 
INSERT INTO temp_sgt_bisaccodes_2010 VALUES (
	'HOM019000',
	'Cleaning & Caretaking')  
INSERT INTO temp_sgt_bisaccodes_2010 VALUES (
	'HOM003000',
	'Decorating ')  
INSERT INTO temp_sgt_bisaccodes_2010 VALUES (
	'HOM004000',
	'Design & Construction')  
INSERT INTO temp_sgt_bisaccodes_2010 VALUES (
	'HOM005000',
	'Do-It-Yourself / General')  
INSERT INTO temp_sgt_bisaccodes_2010 VALUES (
	'HOM001000',
	'Do-It-Yourself / Carpentry')  
INSERT INTO temp_sgt_bisaccodes_2010 VALUES (
	'HOM006000',
	'Do-It-Yourself / Electrical') 
INSERT INTO temp_sgt_bisaccodes_2010 VALUES (
	'HOM012000',
	'Do-It-Yourself / Masonry')  
INSERT INTO temp_sgt_bisaccodes_2010 VALUES (
	'HOM014000',
	'Do-It-Yourself / Plumbing') 
INSERT INTO temp_sgt_bisaccodes_2010 VALUES (
	'HOM020000',
	'Equipment, Appliances & Supplies')  
INSERT INTO temp_sgt_bisaccodes_2010 VALUES (
	'HOM008000',
	'Furniture') 
INSERT INTO temp_sgt_bisaccodes_2010 VALUES (
	'HOM009000',
	'Hand Tools ')  
INSERT INTO temp_sgt_bisaccodes_2010 VALUES (
	'HOM011000',
	'House Plans')  
INSERT INTO temp_sgt_bisaccodes_2010 VALUES (
	'HOM013000',
	'Outdoor & Recreational Areas') 
INSERT INTO temp_sgt_bisaccodes_2010 VALUES (
	'HOM015000',
	'Power Tools')  
INSERT INTO temp_sgt_bisaccodes_2010 VALUES (
	'HOM016000',
	'Reference') 
INSERT INTO temp_sgt_bisaccodes_2010 VALUES (
	'HOM017000',
	'Remodeling & Renovation')   
INSERT INTO temp_sgt_bisaccodes_2010 VALUES (
	'HOM010000',
	'Repair')  
INSERT INTO temp_sgt_bisaccodes_2010 VALUES (
	'HOM021000',
	'Security')  
INSERT INTO temp_sgt_bisaccodes_2010 VALUES (
	'HOM022000',
	'Sustainable Living')  
INSERT INTO temp_sgt_bisaccodes_2010 VALUES (
	'HOM018000',
	'Woodworking')  
INSERT INTO temp_sgt_bisaccodes_2010 VALUES (
	'HUM000000',
	'General') 
INSERT INTO temp_sgt_bisaccodes_2010 VALUES (
	'HUM015000',
	'Form / Anecdotes & Quotations') 
INSERT INTO temp_sgt_bisaccodes_2010 VALUES (
	'HUM001000',
	'Form / Comic Strips & Cartoons')  
INSERT INTO temp_sgt_bisaccodes_2010 VALUES (
	'HUM003000',
	'Form / Essays')  
INSERT INTO temp_sgt_bisaccodes_2010 VALUES (
	'HUM004000',
	'Form / Jokes & Riddles') 
INSERT INTO temp_sgt_bisaccodes_2010 VALUES (
	'HUM005000',
	'Form / Limericks & Verse')  
INSERT INTO temp_sgt_bisaccodes_2010 VALUES (
	'HUM007000',
	'Form / Parodies')  
INSERT INTO temp_sgt_bisaccodes_2010 VALUES (
	'HUM008000',
	'Topic / Adult')  
INSERT INTO temp_sgt_bisaccodes_2010 VALUES (
	'HUM009000',
	'Topic / Animals')  
INSERT INTO temp_sgt_bisaccodes_2010 VALUES (
	'HUM010000',
	'Topic / Business & Professional') 
INSERT INTO temp_sgt_bisaccodes_2010 VALUES (
	'HUM011000',
	'Topic / Marriage & Family') 
INSERT INTO temp_sgt_bisaccodes_2010 VALUES (
	'HUM006000',
	'Topic / Political')   
INSERT INTO temp_sgt_bisaccodes_2010 VALUES (
	'HUM012000',
	'Topic / Relationships')  
INSERT INTO temp_sgt_bisaccodes_2010 VALUES (
	'HUM014000',
	'Topic / Religion') 
INSERT INTO temp_sgt_bisaccodes_2010 VALUES (
	'HUM013000',
	'Topic / Sports') 
INSERT INTO temp_sgt_bisaccodes_2010 VALUES (
	'JUV000000',
	'General') 
INSERT INTO temp_sgt_bisaccodes_2010 VALUES (
	'JUV001000',
	'Action & Adventure / General') 
INSERT INTO temp_sgt_bisaccodes_2010 VALUES (
	'JUV001020',
	'Action & Adventure / Pirates') 
INSERT INTO temp_sgt_bisaccodes_2010 VALUES (
	'JUV001010',
	'Action & Adventure / Survival Stories') 
INSERT INTO temp_sgt_bisaccodes_2010 VALUES (
	'JUV054000',
	'Activity Books') 
INSERT INTO temp_sgt_bisaccodes_2010 VALUES (
	'JUV002000',
	'Animals / General')   
INSERT INTO temp_sgt_bisaccodes_2010 VALUES (
	'JUV002010',
	'Animals / Alligators & Crocodiles') 
INSERT INTO temp_sgt_bisaccodes_2010 VALUES (
	'JUV002020',
	'Animals / Apes, Monkeys, etc. ')  
INSERT INTO temp_sgt_bisaccodes_2010 VALUES (
	'JUV002030',
	'Animals / Bears')  
INSERT INTO temp_sgt_bisaccodes_2010 VALUES (
	'JUV002040',
	'Animals / Birds')  
INSERT INTO temp_sgt_bisaccodes_2010 VALUES (
	'JUV002300',
	'Animals / Butterflies, Moths & Caterpillars ')  
INSERT INTO temp_sgt_bisaccodes_2010 VALUES (
	'JUV002050',
	'Animals / Cats') 
INSERT INTO temp_sgt_bisaccodes_2010 VALUES (
	'JUV002310',
	'Animals / Cows') 
INSERT INTO temp_sgt_bisaccodes_2010 VALUES (
	'JUV002290',
	'Animals / Deer, Moose & Caribou') 
INSERT INTO temp_sgt_bisaccodes_2010 VALUES (
	'JUV002060',
	'Animals / Dinosaurs & Prehistoric Creatures ')  
INSERT INTO temp_sgt_bisaccodes_2010 VALUES (
	'JUV002070',
	'Animals / Dogs') 
INSERT INTO temp_sgt_bisaccodes_2010 VALUES (
	'JUV002280',
	'Animals / Ducks, Geese, etc.') 
INSERT INTO temp_sgt_bisaccodes_2010 VALUES (
	'JUV002080',
	'Animals / Elephants')  
INSERT INTO temp_sgt_bisaccodes_2010 VALUES (
	'JUV002090',
	'Animals / Farm Animals') 
INSERT INTO temp_sgt_bisaccodes_2010 VALUES (
	'JUV002100',
	'Animals / Fishes') 
INSERT INTO temp_sgt_bisaccodes_2010 VALUES (
	'JUV002110',
	'Animals / Foxes')  
INSERT INTO temp_sgt_bisaccodes_2010 VALUES (
	'JUV002120',
	'Animals / Frogs & Toads')   
INSERT INTO temp_sgt_bisaccodes_2010 VALUES (
	'JUV002320',
	'Animals / Giraffes')  
INSERT INTO temp_sgt_bisaccodes_2010 VALUES (
	'JUV002330',
	'Animals / Hippos & Rhinos') 
INSERT INTO temp_sgt_bisaccodes_2010 VALUES (
	'JUV002130',
	'Animals / Horses') 
INSERT INTO temp_sgt_bisaccodes_2010 VALUES (
	'JUV002140',
	'Animals / Insects, Spiders, etc.')  
INSERT INTO temp_sgt_bisaccodes_2010 VALUES (
	'JUV002340',
	'Animals / Jungle Animals')  
INSERT INTO temp_sgt_bisaccodes_2010 VALUES (
	'JUV002350',
	'Animals / Kangaroos')  
INSERT INTO temp_sgt_bisaccodes_2010 VALUES (
	'JUV002150',
	'Animals / Lions, Tigers, Leopards, etc.  ')  
INSERT INTO temp_sgt_bisaccodes_2010 VALUES (
	'JUV002160',
	'Animals / Mammals')   
INSERT INTO temp_sgt_bisaccodes_2010 VALUES (
	'JUV002170',
	'Animals / Marine Life')  
INSERT INTO temp_sgt_bisaccodes_2010 VALUES (
	'JUV002180',
	'Animals / Mice, Hamsters, Guinea Pigs, etc. ')  
INSERT INTO temp_sgt_bisaccodes_2010 VALUES (
	'JUV002270',
	'Animals / Dragons, Unicorns & Mythical')  
INSERT INTO temp_sgt_bisaccodes_2010 VALUES (
	'JUV002360',
	'Animals / Nocturnal')  
INSERT INTO temp_sgt_bisaccodes_2010 VALUES (
	'JUV002190',
	'Animals / Pets') 
INSERT INTO temp_sgt_bisaccodes_2010 VALUES (
	'JUV002200',
	'Animals / Pigs') 
INSERT INTO temp_sgt_bisaccodes_2010 VALUES (
	'JUV002210',
	'Animals / Rabbits')   
INSERT INTO temp_sgt_bisaccodes_2010 VALUES (
	'JUV002220',
	'Animals / Reptiles & Amphibians') 
INSERT INTO temp_sgt_bisaccodes_2010 VALUES (
	'JUV002230',
	'Animals / Squirrels')  
INSERT INTO temp_sgt_bisaccodes_2010 VALUES (
	'JUV002240',
	'Animals / Turtles')   
INSERT INTO temp_sgt_bisaccodes_2010 VALUES (
	'JUV002250',
	'Animals / Wolves & Coyotes')  
INSERT INTO temp_sgt_bisaccodes_2010 VALUES (
	'JUV002260',
	'Animals / Zoos') 
INSERT INTO temp_sgt_bisaccodes_2010 VALUES (
	'JUV003000',
	'Art & Architecture')  
INSERT INTO temp_sgt_bisaccodes_2010 VALUES (
	'JUV010000',
	'Bedtime & Dreams') 
INSERT INTO temp_sgt_bisaccodes_2010 VALUES (
	'JUV004000',
	'Biographical / General') 
INSERT INTO temp_sgt_bisaccodes_2010 VALUES (
	'JUV004040',
	'Biographical / Canada')  
INSERT INTO temp_sgt_bisaccodes_2010 VALUES (
	'JUV004010',
	'Biographical / European')   
INSERT INTO temp_sgt_bisaccodes_2010 VALUES (
	'JUV004020',
	'Biographical / United States') 
INSERT INTO temp_sgt_bisaccodes_2010 VALUES (
	'JUV004030',
	'Biographical / Other') 
INSERT INTO temp_sgt_bisaccodes_2010 VALUES (
	'JUV047000',
	'Books & Libraries')   
INSERT INTO temp_sgt_bisaccodes_2010 VALUES (
	'JUV005000',
	'Boys & Men ')  
INSERT INTO temp_sgt_bisaccodes_2010 VALUES (
	'JUV006000',
	'Business, Careers, Occupations')  
INSERT INTO temp_sgt_bisaccodes_2010 VALUES (
	'JUV007000',
	'Classics')  
INSERT INTO temp_sgt_bisaccodes_2010 VALUES (
	'JUV048000',
	'Clothing & Dress') 
INSERT INTO temp_sgt_bisaccodes_2010 VALUES (
	'JUV008000',
	'Comics & Graphic Novels / General') 
INSERT INTO temp_sgt_bisaccodes_2010 VALUES (
	'JUV008010',
	'Comics & Graphic Novels / Manga') 
INSERT INTO temp_sgt_bisaccodes_2010 VALUES (
	'JUV008030',
	'Comics & Graphic Novels / Media Tie-In') 
INSERT INTO temp_sgt_bisaccodes_2010 VALUES (
	'JUV008020',
	'Comics & Graphic Novels / Superheroes') 
INSERT INTO temp_sgt_bisaccodes_2010 VALUES (
	'JUV049000',
	'Computers') 
INSERT INTO temp_sgt_bisaccodes_2010 VALUES (
	'JUV009000',
	'Concepts / General')  
INSERT INTO temp_sgt_bisaccodes_2010 VALUES (
	'JUV009010',
	'Concepts / Alphabet')  
INSERT INTO temp_sgt_bisaccodes_2010 VALUES (
	'JUV009120',
	'Concepts / Body')  
INSERT INTO temp_sgt_bisaccodes_2010 VALUES (
	'JUV009020',
	'Concepts / Colors')   
INSERT INTO temp_sgt_bisaccodes_2010 VALUES (
	'JUV009030',
	'Concepts / Counting & Numbers ')  
INSERT INTO temp_sgt_bisaccodes_2010 VALUES (
	'JUV009070',
	'Concepts / Date & Time') 
INSERT INTO temp_sgt_bisaccodes_2010 VALUES (
	'JUV009090',
	'Concepts / Money') 
INSERT INTO temp_sgt_bisaccodes_2010 VALUES (
	'JUV009040',
	'Concepts / Opposites') 
INSERT INTO temp_sgt_bisaccodes_2010 VALUES (
	'JUV009100',
	'Concepts / Seasons')  
INSERT INTO temp_sgt_bisaccodes_2010 VALUES (
	'JUV009050',
	'Concepts / Senses & Sensation ')  
INSERT INTO temp_sgt_bisaccodes_2010 VALUES (
	'JUV009060',
	'Concepts / Size & Shape')   
INSERT INTO temp_sgt_bisaccodes_2010 VALUES (
	'JUV009110',
	'Concepts / Sounds')   
INSERT INTO temp_sgt_bisaccodes_2010 VALUES (
	'JUV009080',
	'Concepts / Words') 
INSERT INTO temp_sgt_bisaccodes_2010 VALUES (
	'JUV050000',
	'Cooking & Food') 
INSERT INTO temp_sgt_bisaccodes_2010 VALUES (
	'JUV012030',
	'Fairy Tales & Folklore / General')  
INSERT INTO temp_sgt_bisaccodes_2010 VALUES (
	'JUV012040',
	'Fairy Tales & Folklore / Adaptations ') 
INSERT INTO temp_sgt_bisaccodes_2010 VALUES (
	'JUV012000',
	'Fairy Tales & Folklore / Anthologies ') 
INSERT INTO temp_sgt_bisaccodes_2010 VALUES (
	'JUV012020',
	'Fairy Tales & Folklore / Country & Ethnic')  
INSERT INTO temp_sgt_bisaccodes_2010 VALUES (
	'JUV013000',
	'Family / General (see also headings under Social Issues) ') 
INSERT INTO temp_sgt_bisaccodes_2010 VALUES (
	'JUV013010',
	'Family / Adoption')   
INSERT INTO temp_sgt_bisaccodes_2010 VALUES (
	'JUV013090',
	'Family / Alternative Family') 
INSERT INTO temp_sgt_bisaccodes_2010 VALUES (
	'JUV013020',
	'Family / Marriage & Divorce') 
INSERT INTO temp_sgt_bisaccodes_2010 VALUES (
	'JUV013030',
	'Family / Multigenerational')  
INSERT INTO temp_sgt_bisaccodes_2010 VALUES (
	'JUV013040',
	'Family / New Baby')   
INSERT INTO temp_sgt_bisaccodes_2010 VALUES (
	'JUV013050',
	'Family / Orphans & Foster Homes') 
INSERT INTO temp_sgt_bisaccodes_2010 VALUES (
	'JUV013060',
	'Family / Parents') 
INSERT INTO temp_sgt_bisaccodes_2010 VALUES (
	'JUV013070',
	'Family / Siblings')   
INSERT INTO temp_sgt_bisaccodes_2010 VALUES (
	'JUV013080',
	'Family / Stepfamilies')  
INSERT INTO temp_sgt_bisaccodes_2010 VALUES (
	'JUV037000',
	'Fantasy & Magic')  
INSERT INTO temp_sgt_bisaccodes_2010 VALUES (
	'JUV014000',
	'Girls & Women')  
INSERT INTO temp_sgt_bisaccodes_2010 VALUES (
	'JUV015000',
	'Health & Daily Living / General') 
INSERT INTO temp_sgt_bisaccodes_2010 VALUES (
	'JUV015010',
	'Health & Daily Living / Daily Activities ')  
INSERT INTO temp_sgt_bisaccodes_2010 VALUES (
	'JUV015020',
	'Health & Daily Living / Diseases, Illnesses & Injuries   ') 
INSERT INTO temp_sgt_bisaccodes_2010 VALUES (
	'JUV039170',
	'Health & Daily Living / Toilet Training  ')  
INSERT INTO temp_sgt_bisaccodes_2010 VALUES (
	'JUV016000',
	'Historical / General') 
INSERT INTO temp_sgt_bisaccodes_2010 VALUES (
	'JUV016010',
	'Historical / Africa')  
INSERT INTO temp_sgt_bisaccodes_2010 VALUES (
	'JUV016020',
	'Historical / Ancient Civilizations   ') 
INSERT INTO temp_sgt_bisaccodes_2010 VALUES (
	'JUV016030',
	'Historical / Asia')   
INSERT INTO temp_sgt_bisaccodes_2010 VALUES (
	'JUV016160',
	'Historical / Canada / General ')  
INSERT INTO temp_sgt_bisaccodes_2010 VALUES (
	'JUV016170',
	'Historical / Canada / Pre-Confederation (to 1867)') 
INSERT INTO temp_sgt_bisaccodes_2010 VALUES (
	'JUV016180',
	'Historical / Canada / Post-Confederation (1867-)')  
INSERT INTO temp_sgt_bisaccodes_2010 VALUES (
	'JUV016040',
	'Historical / Europe')  
INSERT INTO temp_sgt_bisaccodes_2010 VALUES (
	'JUV016050',
	'Historical / Exploration & Discovery ') 
INSERT INTO temp_sgt_bisaccodes_2010 VALUES (
	'JUV016060',
	'Historical / Holocaust') 
INSERT INTO temp_sgt_bisaccodes_2010 VALUES (
	'JUV016070',
	'Historical / Medieval')  
INSERT INTO temp_sgt_bisaccodes_2010 VALUES (
	'JUV016210',
	'Historical / Middle East')  
INSERT INTO temp_sgt_bisaccodes_2010 VALUES (
	'JUV016080',
	'Historical / Military & Wars') 
INSERT INTO temp_sgt_bisaccodes_2010 VALUES (
	'JUV016090',
	'Historical / Prehistory')   
INSERT INTO temp_sgt_bisaccodes_2010 VALUES (
	'JUV016100',
	'Historical / Renaissance')  
INSERT INTO temp_sgt_bisaccodes_2010 VALUES (
	'JUV016110',
	'Historical / United States / General ') 
INSERT INTO temp_sgt_bisaccodes_2010 VALUES (
	'JUV016120',
	'Historical / United States / Colonial & Revolutionary Periods')  
INSERT INTO temp_sgt_bisaccodes_2010 VALUES (
	'JUV016140',
	'Historical / United States / 19th Century')  
INSERT INTO temp_sgt_bisaccodes_2010 VALUES (
	'JUV016200',
	'Historical / United States / Civil War Period (1850-1877)') 
INSERT INTO temp_sgt_bisaccodes_2010 VALUES (
	'JUV016150',
	'Historical / United States / 20th Century')  
INSERT INTO temp_sgt_bisaccodes_2010 VALUES (
	'JUV016190',
	'Historical / United States / 21st Century')  
INSERT INTO temp_sgt_bisaccodes_2010 VALUES (
	'JUV016130',
	'Historical / Other')  
INSERT INTO temp_sgt_bisaccodes_2010 VALUES (
	'JUV017000',
	'Holidays & Celebrations / General (see also Religious / Christian / Holidays & Celebrations)  ') 
INSERT INTO temp_sgt_bisaccodes_2010 VALUES (
	'JUV017100',
	'Holidays & Celebrations / Birthdays  ') 
INSERT INTO temp_sgt_bisaccodes_2010 VALUES (
	'JUV017010',
	'Holidays & Celebrations / Christmas & Advent')  
INSERT INTO temp_sgt_bisaccodes_2010 VALUES (
	'JUV017020',
	'Holidays & Celebrations / Easter & Lent  ')  
INSERT INTO temp_sgt_bisaccodes_2010 VALUES (
	'JUV017030',
	'Holidays & Celebrations / Halloween  ') 
INSERT INTO temp_sgt_bisaccodes_2010 VALUES (
	'JUV017110',
	'Holidays & Celebrations / Hanukkah   ') 
INSERT INTO temp_sgt_bisaccodes_2010 VALUES (
	'JUV017050',
	'Holidays & Celebrations / Kwanzaa') 
INSERT INTO temp_sgt_bisaccodes_2010 VALUES (
	'JUV017120',
	'Holidays & Celebrations / Passover   ') 
INSERT INTO temp_sgt_bisaccodes_2010 VALUES (
	'JUV017130',
	'Holidays & Celebrations / Patriotic Holidays')  
INSERT INTO temp_sgt_bisaccodes_2010 VALUES (
	'JUV017060',
	'Holidays & Celebrations / Thanksgiving') 
INSERT INTO temp_sgt_bisaccodes_2010 VALUES (
	'JUV017070',
	'Holidays & Celebrations / Valentine''s Day')  
INSERT INTO temp_sgt_bisaccodes_2010 VALUES (
	'JUV017080',
	'Holidays & Celebrations / Other, Non-Religious')  
INSERT INTO temp_sgt_bisaccodes_2010 VALUES (
	'JUV017090',
	'Holidays & Celebrations / Other, Religious') 
INSERT INTO temp_sgt_bisaccodes_2010 VALUES (
	'JUV018000',
	'Horror & Ghost Stories') 
INSERT INTO temp_sgt_bisaccodes_2010 VALUES (
	'JUV019000',
	'Humorous Stories') 
INSERT INTO temp_sgt_bisaccodes_2010 VALUES (
	'JUV051000',
	'Imagination & Play')  
INSERT INTO temp_sgt_bisaccodes_2010 VALUES (
	'JUV020000',
	'Interactive Adventures') 
INSERT INTO temp_sgt_bisaccodes_2010 VALUES (
	'JUV021000',
	'Law & Crime')  
INSERT INTO temp_sgt_bisaccodes_2010 VALUES (
	'JUV022000',
	'Legends, Myths, Fables / General')  
INSERT INTO temp_sgt_bisaccodes_2010 VALUES (
	'JUV022010',
	'Legends, Myths, Fables / Arthurian   ') 
INSERT INTO temp_sgt_bisaccodes_2010 VALUES (
	'JUV022020',
	'Legends, Myths, Fables / Greek & Roman') 
INSERT INTO temp_sgt_bisaccodes_2010 VALUES (
	'JUV022030',
	'Legends, Myths, Fables / Norse')  
INSERT INTO temp_sgt_bisaccodes_2010 VALUES (
	'JUV022040',
	'Legends, Myths, Fables / Other')  
INSERT INTO temp_sgt_bisaccodes_2010 VALUES (
	'JUV023000',
	'Lifestyles / City & Town Life ')  
INSERT INTO temp_sgt_bisaccodes_2010 VALUES (
	'JUV024000',
	'Lifestyles / Country Life') 
INSERT INTO temp_sgt_bisaccodes_2010 VALUES (
	'JUV025000',
	'Lifestyles / Farm & Ranch Life')  
INSERT INTO temp_sgt_bisaccodes_2010 VALUES (
	'JUV026000',
	'Love & Romance') 
INSERT INTO temp_sgt_bisaccodes_2010 VALUES (
	'JUV027000',
	'Media Tie-In') 
INSERT INTO temp_sgt_bisaccodes_2010 VALUES (
	'JUV052000',
	'Monsters')  
INSERT INTO temp_sgt_bisaccodes_2010 VALUES (
	'JUV028000',
	'Mysteries & Detective Stories ')  
INSERT INTO temp_sgt_bisaccodes_2010 VALUES (
	'JUV029000',
	'Nature & the Natural World / General (see also headings under Animals)') 
INSERT INTO temp_sgt_bisaccodes_2010 VALUES (
	'JUV029010',
	'Nature & the Natural World / Environment ')  
INSERT INTO temp_sgt_bisaccodes_2010 VALUES (
	'JUV029020',
	'Nature & the Natural World / Weather ') 
INSERT INTO temp_sgt_bisaccodes_2010 VALUES (
	'JUV055000',
	'Nursery Rhymes') 
INSERT INTO temp_sgt_bisaccodes_2010 VALUES (
	'JUV030000',
	'People & Places / General') 
INSERT INTO temp_sgt_bisaccodes_2010 VALUES (
	'JUV030010',
	'People & Places / Africa')  
INSERT INTO temp_sgt_bisaccodes_2010 VALUES (
	'JUV030020',
	'People & Places / Asia') 
INSERT INTO temp_sgt_bisaccodes_2010 VALUES (
	'JUV030080',
	'People & Places / Australia & Oceania') 
INSERT INTO temp_sgt_bisaccodes_2010 VALUES (
	'JUV030030',
	'People & Places / Canada / General   ') 
INSERT INTO temp_sgt_bisaccodes_2010 VALUES (
	'JUV030090',
	'People & Places / Canada / Native Canadian') 
INSERT INTO temp_sgt_bisaccodes_2010 VALUES (
	'JUV030040',
	'People & Places / Caribbean & Latin America ')  
INSERT INTO temp_sgt_bisaccodes_2010 VALUES (
	'JUV030050',
	'People & Places / Europe')  
INSERT INTO temp_sgt_bisaccodes_2010 VALUES (
	'JUV030100',
	'People & Places / Mexico')  
INSERT INTO temp_sgt_bisaccodes_2010 VALUES (
	'JUV030110',
	'People & Places / Middle East ')  
INSERT INTO temp_sgt_bisaccodes_2010 VALUES (
	'JUV030120',
	'People & Places / Polar Regions') 
INSERT INTO temp_sgt_bisaccodes_2010 VALUES (
	'JUV030060',
	'People & Places / United States / General')  
INSERT INTO temp_sgt_bisaccodes_2010 VALUES (
	'JUV011010',
	'People & Places / United States / African American') 
INSERT INTO temp_sgt_bisaccodes_2010 VALUES (
	'JUV011020',
	'People & Places / United States / Asian American')  
INSERT INTO temp_sgt_bisaccodes_2010 VALUES (
	'JUV011030',
	'People & Places / United States / Hispanic & Latino')  
INSERT INTO temp_sgt_bisaccodes_2010 VALUES (
	'JUV011040',
	'People & Places / United States / Native American') 
INSERT INTO temp_sgt_bisaccodes_2010 VALUES (
	'JUV011050',
	'People & Places / United States / Other  ')  
INSERT INTO temp_sgt_bisaccodes_2010 VALUES (
	'JUV030070',
	'People & Places / Other')   
INSERT INTO temp_sgt_bisaccodes_2010 VALUES (
	'JUV031000',
	'Performing Arts / General') 
INSERT INTO temp_sgt_bisaccodes_2010 VALUES (
	'JUV031010',
	'Performing Arts / Circus')  
INSERT INTO temp_sgt_bisaccodes_2010 VALUES (
	'JUV031020',
	'Performing Arts / Dance')   
INSERT INTO temp_sgt_bisaccodes_2010 VALUES (
	'JUV031030',
	'Performing Arts / Film') 
INSERT INTO temp_sgt_bisaccodes_2010 VALUES (
	'JUV031040',
	'Performing Arts / Music')   
INSERT INTO temp_sgt_bisaccodes_2010 VALUES (
	'JUV031050',
	'Performing Arts / Television & Radio ') 
INSERT INTO temp_sgt_bisaccodes_2010 VALUES (
	'JUV031060',
	'Performing Arts / Theater') 
INSERT INTO temp_sgt_bisaccodes_2010 VALUES (
	'JUV043000',
	'Readers / Beginner')  
INSERT INTO temp_sgt_bisaccodes_2010 VALUES (
	'JUV044000',
	'Readers / Intermediate') 
INSERT INTO temp_sgt_bisaccodes_2010 VALUES (
	'JUV045000',
	'Readers / Chapter Books')   
INSERT INTO temp_sgt_bisaccodes_2010 VALUES (
	'JUV033000',
	'Religious / General')  
INSERT INTO temp_sgt_bisaccodes_2010 VALUES (
	'JUV033010',
	'Religious / Christian / General') 
INSERT INTO temp_sgt_bisaccodes_2010 VALUES (
	'JUV033040',
	'Religious / Christian / Action & Adventure') 
INSERT INTO temp_sgt_bisaccodes_2010 VALUES (
	'JUV033050',
	'Religious / Christian / Animals') 
INSERT INTO temp_sgt_bisaccodes_2010 VALUES (
	'JUV033060',
	'Religious / Christian / Bedtime & Dreams ')  
INSERT INTO temp_sgt_bisaccodes_2010 VALUES (
	'JUV033070',
	'Religious / Christian / Comics & Graphic Novels') 
INSERT INTO temp_sgt_bisaccodes_2010 VALUES (
	'JUV033080',
	'Religious / Christian / Early Readers') 
INSERT INTO temp_sgt_bisaccodes_2010 VALUES (
	'JUV033090',
	'Religious / Christian / Emotions & Feelings ')  
INSERT INTO temp_sgt_bisaccodes_2010 VALUES (
	'JUV033100',
	'Religious / Christian / Family')  
INSERT INTO temp_sgt_bisaccodes_2010 VALUES (
	'JUV033110',
	'Religious / Christian / Fantasy') 
INSERT INTO temp_sgt_bisaccodes_2010 VALUES (
	'JUV033120',
	'Religious / Christian / Friendship   ') 
INSERT INTO temp_sgt_bisaccodes_2010 VALUES (
	'JUV033130',
	'Religious / Christian / Health & Daily Living') 
INSERT INTO temp_sgt_bisaccodes_2010 VALUES (
	'JUV033140',
	'Religious / Christian / Historical   ') 
INSERT INTO temp_sgt_bisaccodes_2010 VALUES (
	'JUV033150',
	'Religious / Christian / Holidays & Celebrations') 
INSERT INTO temp_sgt_bisaccodes_2010 VALUES (
	'JUV033160',
	'Religious / Christian / Humorous')  
INSERT INTO temp_sgt_bisaccodes_2010 VALUES (
	'JUV033170',
	'Religious / Christian / Learning Concepts')  
INSERT INTO temp_sgt_bisaccodes_2010 VALUES (
	'JUV033180',
	'Religious / Christian / Mysteries & Detective Stories    ') 
INSERT INTO temp_sgt_bisaccodes_2010 VALUES (
	'JUV033190',
	'Religious / Christian / People & Places  ')  
INSERT INTO temp_sgt_bisaccodes_2010 VALUES (
	'JUV033200',
	'Religious / Christian / Relationships') 
INSERT INTO temp_sgt_bisaccodes_2010 VALUES (
	'JUV033210',
	'Religious / Christian / Science Fiction  ')  
INSERT INTO temp_sgt_bisaccodes_2010 VALUES (
	'JUV033220',
	'Religious / Christian / Social Issues') 
INSERT INTO temp_sgt_bisaccodes_2010 VALUES (
	'JUV033230',
	'Religious / Christian / Sports & Recreation ')  
INSERT INTO temp_sgt_bisaccodes_2010 VALUES (
	'JUV033240',
	'Religious / Christian / Values & Virtues ')  
INSERT INTO temp_sgt_bisaccodes_2010 VALUES (
	'JUV033020',
	'Religious / Jewish')  
INSERT INTO temp_sgt_bisaccodes_2010 VALUES (
	'JUV033030',
	'Religious / Other')   
INSERT INTO temp_sgt_bisaccodes_2010 VALUES (
	'JUV056000',
	'Robots')  
INSERT INTO temp_sgt_bisaccodes_2010 VALUES (
	'JUV034000',
	'Royalty') 
INSERT INTO temp_sgt_bisaccodes_2010 VALUES (
	'JUV035000',
	'School & Education')  
INSERT INTO temp_sgt_bisaccodes_2010 VALUES (
	'JUV036000',
	'Science & Technology') 
INSERT INTO temp_sgt_bisaccodes_2010 VALUES (
	'JUV053000',
	'Science Fiction')  
INSERT INTO temp_sgt_bisaccodes_2010 VALUES (
	'JUV038000',
	'Short Stories')  
INSERT INTO temp_sgt_bisaccodes_2010 VALUES (
	'JUV039000',
	'Social Issues / General (see also headings under Family) ') 
INSERT INTO temp_sgt_bisaccodes_2010 VALUES (
	'JUV039020',
	'Social Issues / Adolescence') 
INSERT INTO temp_sgt_bisaccodes_2010 VALUES (
	'JUV039230',
	'Social Issues / Bullying')  
INSERT INTO temp_sgt_bisaccodes_2010 VALUES (
	'JUV039190',
	'Social Issues / Dating & Sex') 
INSERT INTO temp_sgt_bisaccodes_2010 VALUES (
	'JUV039030',
	'Social Issues / Death & Dying ')  
INSERT INTO temp_sgt_bisaccodes_2010 VALUES (
	'JUV039240',
	'Social Issues / Depression & Mental Illness ')  
INSERT INTO temp_sgt_bisaccodes_2010 VALUES (
	'JUV039040',
	'Social Issues / Drugs, Alcohol, Substance Abuse') 
INSERT INTO temp_sgt_bisaccodes_2010 VALUES (
	'JUV039250',
	'Social Issues / Emigration & Immigration ')  
INSERT INTO temp_sgt_bisaccodes_2010 VALUES (
	'JUV039050',
	'Social Issues / Emotions & Feelings  ') 
INSERT INTO temp_sgt_bisaccodes_2010 VALUES (
	'JUV039060',
	'Social Issues / Friendship')  
INSERT INTO temp_sgt_bisaccodes_2010 VALUES (
	'JUV039070',
	'Social Issues / Homelessness & Poverty') 
INSERT INTO temp_sgt_bisaccodes_2010 VALUES (
	'JUV039080',
	'Social Issues / Homosexuality ')  
INSERT INTO temp_sgt_bisaccodes_2010 VALUES (
	'JUV039200',
	'Social Issues / Manners & Etiquette  ') 
INSERT INTO temp_sgt_bisaccodes_2010 VALUES (
	'JUV039090',
	'Social Issues / New Experience')  
INSERT INTO temp_sgt_bisaccodes_2010 VALUES (
	'JUV039100',
	'Social Issues / Peer Pressure ')  
INSERT INTO temp_sgt_bisaccodes_2010 VALUES (
	'JUV039010',
	'Social Issues / Physical & Emotional Abuse (see also Social Issues / Sexual Abuse)  ')  
INSERT INTO temp_sgt_bisaccodes_2010 VALUES (
	'JUV039110',
	'Social Issues / Pregnancy') 
INSERT INTO temp_sgt_bisaccodes_2010 VALUES (
	'JUV039120',
	'Social Issues / Prejudice & Racism   ') 
INSERT INTO temp_sgt_bisaccodes_2010 VALUES (
	'JUV039130',
	'Social Issues / Runaways')  
INSERT INTO temp_sgt_bisaccodes_2010 VALUES (
	'JUV039140',
	'Social Issues / Self-Esteem & Self-Reliance ')  
INSERT INTO temp_sgt_bisaccodes_2010 VALUES (
	'JUV039260',
	'Social Issues / Self-Mutilation') 
INSERT INTO temp_sgt_bisaccodes_2010 VALUES (
	'JUV039210',
	'Social Issues / Sexual Abuse') 
INSERT INTO temp_sgt_bisaccodes_2010 VALUES (
	'JUV039150',
	'Social Issues / Special Needs ')  
INSERT INTO temp_sgt_bisaccodes_2010 VALUES (
	'JUV039270',
	'Social Issues / Strangers') 
INSERT INTO temp_sgt_bisaccodes_2010 VALUES (
	'JUV039160',
	'Social Issues / Suicide')   
INSERT INTO temp_sgt_bisaccodes_2010 VALUES (
	'JUV039220',
	'Social Issues / Values & Virtues')  
INSERT INTO temp_sgt_bisaccodes_2010 VALUES (
	'JUV039180',
	'Social Issues / Violence')  
INSERT INTO temp_sgt_bisaccodes_2010 VALUES (
	'JUV032000',
	'Sports & Recreation / General ')  
INSERT INTO temp_sgt_bisaccodes_2010 VALUES (
	'JUV032010',
	'Sports & Recreation / Baseball & Softball')  
INSERT INTO temp_sgt_bisaccodes_2010 VALUES (
	'JUV032020',
	'Sports & Recreation / Basketball')  
INSERT INTO temp_sgt_bisaccodes_2010 VALUES (
	'JUV032170',
	'Sports & Recreation / Camping & Outdoor Activities') 
INSERT INTO temp_sgt_bisaccodes_2010 VALUES (
	'JUV032180',
	'Sports & Recreation / Cycling ')  
INSERT INTO temp_sgt_bisaccodes_2010 VALUES (
	'JUV032090',
	'Sports & Recreation / Equestrian')  
INSERT INTO temp_sgt_bisaccodes_2010 VALUES (
	'JUV032100',
	'Sports & Recreation / Extreme Sports ') 
INSERT INTO temp_sgt_bisaccodes_2010 VALUES (
	'JUV032030',
	'Sports & Recreation / Football')  
INSERT INTO temp_sgt_bisaccodes_2010 VALUES (
	'JUV032040',
	'Sports & Recreation / Games') 
INSERT INTO temp_sgt_bisaccodes_2010 VALUES (
	'JUV032190',
	'Sports & Recreation / Golf')  
INSERT INTO temp_sgt_bisaccodes_2010 VALUES (
	'JUV032110',
	'Sports & Recreation / Hockey') 
INSERT INTO temp_sgt_bisaccodes_2010 VALUES (
	'JUV032120',
	'Sports & Recreation / Ice Skating') 
INSERT INTO temp_sgt_bisaccodes_2010 VALUES (
	'JUV032070',
	'Sports & Recreation / Martial Arts   ') 
INSERT INTO temp_sgt_bisaccodes_2010 VALUES (
	'JUV032050',
	'Sports & Recreation / Miscellaneous  ') 
INSERT INTO temp_sgt_bisaccodes_2010 VALUES (
	'JUV032130',
	'Sports & Recreation / Roller & In-Line Skating')  
INSERT INTO temp_sgt_bisaccodes_2010 VALUES (
	'JUV032140',
	'Sports & Recreation / Skateboarding  ') 
INSERT INTO temp_sgt_bisaccodes_2010 VALUES (
	'JUV032150',
	'Sports & Recreation / Soccer') 
INSERT INTO temp_sgt_bisaccodes_2010 VALUES (
	'JUV032060',
	'Sports & Recreation / Water Sports   ') 
INSERT INTO temp_sgt_bisaccodes_2010 VALUES (
	'JUV032080',
	'Sports & Recreation / Winter Sports  ') 
INSERT INTO temp_sgt_bisaccodes_2010 VALUES (
	'JUV032160',
	'Sports & Recreation / Wrestling') 
INSERT INTO temp_sgt_bisaccodes_2010 VALUES (
	'JUV057000',
	'Stories in Verse') 
INSERT INTO temp_sgt_bisaccodes_2010 VALUES (
	'JUV040000',
	'Toys, Dolls, Puppets') 
INSERT INTO temp_sgt_bisaccodes_2010 VALUES (
	'JUV041000',
	'Transportation / General')  
INSERT INTO temp_sgt_bisaccodes_2010 VALUES (
	'JUV041010',
	'Transportation / Aviation') 
INSERT INTO temp_sgt_bisaccodes_2010 VALUES (
	'JUV041020',
	'Transportation / Boats, Ships & Underwater Craft')  
INSERT INTO temp_sgt_bisaccodes_2010 VALUES (
	'JUV041030',
	'Transportation / Cars & Trucks')  
INSERT INTO temp_sgt_bisaccodes_2010 VALUES (
	'JUV041040',
	'Transportation / Motorcycles') 
INSERT INTO temp_sgt_bisaccodes_2010 VALUES (
	'JUV041050',
	'Transportation / Railroads & Trains  ') 
INSERT INTO temp_sgt_bisaccodes_2010 VALUES (
	'JUV046000',
	'Visionary & Metaphysical')  
INSERT INTO temp_sgt_bisaccodes_2010 VALUES (
	'JUV042000',
	'Westerns')  
INSERT INTO temp_sgt_bisaccodes_2010 VALUES (
	'JNF000000',
	'General') 
INSERT INTO temp_sgt_bisaccodes_2010 VALUES (
	'JNF001000',
	'Activity Books') 
INSERT INTO temp_sgt_bisaccodes_2010 VALUES (
	'JNF002000',
	'Adventure & Adventurers')   
INSERT INTO temp_sgt_bisaccodes_2010 VALUES (
	'JNF003000',
	'Animals / General')   
INSERT INTO temp_sgt_bisaccodes_2010 VALUES (
	'JNF003220',
	'Animals / Animal Welfare')  
INSERT INTO temp_sgt_bisaccodes_2010 VALUES (
	'JNF003010',
	'Animals / Apes, Monkeys, etc. ')  
INSERT INTO temp_sgt_bisaccodes_2010 VALUES (
	'JNF003020',
	'Animals / Bears')  
INSERT INTO temp_sgt_bisaccodes_2010 VALUES (
	'JNF003030',
	'Animals / Birds')  
INSERT INTO temp_sgt_bisaccodes_2010 VALUES (
	'JNF003250',
	'Animals / Butterflies, Moths & Caterpillars ')  
INSERT INTO temp_sgt_bisaccodes_2010 VALUES (
	'JNF003040',
	'Animals / Cats') 
INSERT INTO temp_sgt_bisaccodes_2010 VALUES (
	'JNF003260',
	'Animals / Cows') 
INSERT INTO temp_sgt_bisaccodes_2010 VALUES (
	'JNF003230',
	'Animals / Deer, Moose & Caribou') 
INSERT INTO temp_sgt_bisaccodes_2010 VALUES (
	'JNF003050',
	'Animals / Dinosaurs & Prehistoric Creatures ')  
INSERT INTO temp_sgt_bisaccodes_2010 VALUES (
	'JNF003060',
	'Animals / Dogs') 
INSERT INTO temp_sgt_bisaccodes_2010 VALUES (
	'JNF003210',
	'Animals / Ducks, Geese, etc.') 
INSERT INTO temp_sgt_bisaccodes_2010 VALUES (
	'JNF003070',
	'Animals / Elephants')  
INSERT INTO temp_sgt_bisaccodes_2010 VALUES (
	'JNF003270',
	'Animals / Endangered') 
INSERT INTO temp_sgt_bisaccodes_2010 VALUES (
	'JNF003080',
	'Animals / Farm Animals') 
INSERT INTO temp_sgt_bisaccodes_2010 VALUES (
	'JNF003090',
	'Animals / Fishes') 
INSERT INTO temp_sgt_bisaccodes_2010 VALUES (
	'JNF003100',
	'Animals / Foxes')  
INSERT INTO temp_sgt_bisaccodes_2010 VALUES (
	'JNF003280',
	'Animals / Giraffes')  
INSERT INTO temp_sgt_bisaccodes_2010 VALUES (
	'JNF003290',
	'Animals / Hippos & Rhinos') 
INSERT INTO temp_sgt_bisaccodes_2010 VALUES (
	'JNF003110',
	'Animals / Horses') 
INSERT INTO temp_sgt_bisaccodes_2010 VALUES (
	'JNF003120',
	'Animals / Insects, Spiders, etc.')  
INSERT INTO temp_sgt_bisaccodes_2010 VALUES (
	'JNF003300',
	'Animals / Jungle Animals')  
INSERT INTO temp_sgt_bisaccodes_2010 VALUES (
	'JNF003310',
	'Animals / Kangaroos')  
INSERT INTO temp_sgt_bisaccodes_2010 VALUES (
	'JNF003130',
	'Animals / Lions, Tigers, Leopards, etc.  ')  
INSERT INTO temp_sgt_bisaccodes_2010 VALUES (
	'JNF003140',
	'Animals / Mammals')   
INSERT INTO temp_sgt_bisaccodes_2010 VALUES (
	'JNF003150',
	'Animals / Marine Life')  
INSERT INTO temp_sgt_bisaccodes_2010 VALUES (
	'JNF003160',
	'Animals / Mice, Hamsters, Guinea Pigs, Squirrels, etc.   ') 
INSERT INTO temp_sgt_bisaccodes_2010 VALUES (
	'JNF003320',
	'Animals / Nocturnal')  
INSERT INTO temp_sgt_bisaccodes_2010 VALUES (
	'JNF003170',
	'Animals / Pets') 
INSERT INTO temp_sgt_bisaccodes_2010 VALUES (
	'JNF003180',
	'Animals / Rabbits')   
INSERT INTO temp_sgt_bisaccodes_2010 VALUES (
	'JNF003190',
	'Animals / Reptiles & Amphibians') 
INSERT INTO temp_sgt_bisaccodes_2010 VALUES (
	'JNF003240',
	'Animals / Wolves & Coyotes')  
INSERT INTO temp_sgt_bisaccodes_2010 VALUES (
	'JNF003200',
	'Animals / Zoos') 
INSERT INTO temp_sgt_bisaccodes_2010 VALUES (
	'JNF004000',
	'Antiques & Collectibles')   
INSERT INTO temp_sgt_bisaccodes_2010 VALUES (
	'JNF005000',
	'Architecture') 
INSERT INTO temp_sgt_bisaccodes_2010 VALUES (
	'JNF006000',
	'Art / General')  
INSERT INTO temp_sgt_bisaccodes_2010 VALUES (
	'JNF006010',
	'Art / Cartooning') 
INSERT INTO temp_sgt_bisaccodes_2010 VALUES (
	'JNF006020',
	'Art / Drawing')  
INSERT INTO temp_sgt_bisaccodes_2010 VALUES (
	'JNF006030',
	'Art / Fashion')  
INSERT INTO temp_sgt_bisaccodes_2010 VALUES (
	'JNF006040',
	'Art / History')  
INSERT INTO temp_sgt_bisaccodes_2010 VALUES (
	'JNF006050',
	'Art / Painting') 
INSERT INTO temp_sgt_bisaccodes_2010 VALUES (
	'JNF006060',
	'Art / Sculpture')  
INSERT INTO temp_sgt_bisaccodes_2010 VALUES (
	'JNF006070',
	'Art / Techniques') 
INSERT INTO temp_sgt_bisaccodes_2010 VALUES (
	'JNF007000',
	'Biography & Autobiography / General  ') 
INSERT INTO temp_sgt_bisaccodes_2010 VALUES (
	'JNF007010',
	'Biography & Autobiography / Art') 
INSERT INTO temp_sgt_bisaccodes_2010 VALUES (
	'JNF007050',
	'Biography & Autobiography / Cultural Heritage') 
INSERT INTO temp_sgt_bisaccodes_2010 VALUES (
	'JNF007020',
	'Biography & Autobiography / Historical') 
INSERT INTO temp_sgt_bisaccodes_2010 VALUES (
	'JNF007030',
	'Biography & Autobiography / Literary ') 
INSERT INTO temp_sgt_bisaccodes_2010 VALUES (
	'JNF007040',
	'Biography & Autobiography / Music') 
INSERT INTO temp_sgt_bisaccodes_2010 VALUES (
	'JNF007060',
	'Biography & Autobiography / Performing Arts ')  
INSERT INTO temp_sgt_bisaccodes_2010 VALUES (
	'JNF007070',
	'Biography & Autobiography / Political') 
INSERT INTO temp_sgt_bisaccodes_2010 VALUES (
	'JNF007080',
	'Biography & Autobiography / Religious (see also Religious / Christian / Biography & Autobiography)')  
INSERT INTO temp_sgt_bisaccodes_2010 VALUES (
	'JNF007090',
	'Biography & Autobiography / Science & Technology')  
INSERT INTO temp_sgt_bisaccodes_2010 VALUES (
	'JNF007110',
	'Biography & Autobiography / Social Activists')  
INSERT INTO temp_sgt_bisaccodes_2010 VALUES (
	'JNF007100',
	'Biography & Autobiography / Sports & Recreation') 
INSERT INTO temp_sgt_bisaccodes_2010 VALUES (
	'JNF007120',
	'Biography & Autobiography / Women') 
INSERT INTO temp_sgt_bisaccodes_2010 VALUES (
	'JNF008000',
	'Body, Mind & Spirit')  
INSERT INTO temp_sgt_bisaccodes_2010 VALUES (
	'JNF063000',
	'Books & Libraries')   
INSERT INTO temp_sgt_bisaccodes_2010 VALUES (
	'JNF009000',
	'Boys & Men ')  
INSERT INTO temp_sgt_bisaccodes_2010 VALUES (
	'JNF010000',
	'Business & Economics') 
INSERT INTO temp_sgt_bisaccodes_2010 VALUES (
	'JNF011000',
	'Careers') 
INSERT INTO temp_sgt_bisaccodes_2010 VALUES (
	'JNF059000',
	'Clothing & Dress') 
INSERT INTO temp_sgt_bisaccodes_2010 VALUES (
	'JNF062000',
	'Comics & Graphic Novels / General') 
INSERT INTO temp_sgt_bisaccodes_2010 VALUES (
	'JNF062010',
	'Comics & Graphic Novels / Biography  ') 
INSERT INTO temp_sgt_bisaccodes_2010 VALUES (
	'JNF062020',
	'Comics & Graphic Novels / History') 
INSERT INTO temp_sgt_bisaccodes_2010 VALUES (
	'JNF012000',
	'Computers / General')  
INSERT INTO temp_sgt_bisaccodes_2010 VALUES (
	'JNF012010',
	'Computers / Entertainment & Games') 
INSERT INTO temp_sgt_bisaccodes_2010 VALUES (
	'JNF012020',
	'Computers / Hardware') 
INSERT INTO temp_sgt_bisaccodes_2010 VALUES (
	'JNF012030',
	'Computers / Internet') 
INSERT INTO temp_sgt_bisaccodes_2010 VALUES (
	'JNF012040',
	'Computers / Programming')   
INSERT INTO temp_sgt_bisaccodes_2010 VALUES (
	'JNF012050',
	'Computers / Software') 
INSERT INTO temp_sgt_bisaccodes_2010 VALUES (
	'JNF013000',
	'Concepts / General')  
INSERT INTO temp_sgt_bisaccodes_2010 VALUES (
	'JNF013010',
	'Concepts / Alphabet')  
INSERT INTO temp_sgt_bisaccodes_2010 VALUES (
	'JNF013110',
	'Concepts / Body')  
INSERT INTO temp_sgt_bisaccodes_2010 VALUES (
	'JNF013020',
	'Concepts / Colors')   
INSERT INTO temp_sgt_bisaccodes_2010 VALUES (
	'JNF013030',
	'Concepts / Counting & Numbers ')  
INSERT INTO temp_sgt_bisaccodes_2010 VALUES (
	'JNF013080',
	'Concepts / Date & Time') 
INSERT INTO temp_sgt_bisaccodes_2010 VALUES (
	'JNF013040',
	'Concepts / Money') 
INSERT INTO temp_sgt_bisaccodes_2010 VALUES (
	'JNF013050',
	'Concepts / Opposites') 
INSERT INTO temp_sgt_bisaccodes_2010 VALUES (
	'JNF013090',
	'Concepts / Seasons')  
INSERT INTO temp_sgt_bisaccodes_2010 VALUES (
	'JNF013060',
	'Concepts / Sense & Sensation') 
INSERT INTO temp_sgt_bisaccodes_2010 VALUES (
	'JNF013070',
	'Concepts / Size & Shape')   
INSERT INTO temp_sgt_bisaccodes_2010 VALUES (
	'JNF013100',
	'Concepts / Sounds')   
INSERT INTO temp_sgt_bisaccodes_2010 VALUES (
	'JNF014000',
	'Cooking & Food') 
INSERT INTO temp_sgt_bisaccodes_2010 VALUES (
	'JNF015000',
	'Crafts & Hobbies') 
INSERT INTO temp_sgt_bisaccodes_2010 VALUES (
	'JNF016000',
	'Curiosities & Wonders')  
INSERT INTO temp_sgt_bisaccodes_2010 VALUES (
	'JNF017000',
	'Drama') 
INSERT INTO temp_sgt_bisaccodes_2010 VALUES (
	'JNF019000',
	'Family / General (see also headings under Social Issues) ') 
INSERT INTO temp_sgt_bisaccodes_2010 VALUES (
	'JNF019010',
	'Family / Adoption')   
INSERT INTO temp_sgt_bisaccodes_2010 VALUES (
	'JNF019090',
	'Family / Alternative Family') 
INSERT INTO temp_sgt_bisaccodes_2010 VALUES (
	'JNF019020',
	'Family / Marriage & Divorce') 
INSERT INTO temp_sgt_bisaccodes_2010 VALUES (
	'JNF019030',
	'Family / Multigenerational')  
INSERT INTO temp_sgt_bisaccodes_2010 VALUES (
	'JNF019040',
	'Family / New Baby')   
INSERT INTO temp_sgt_bisaccodes_2010 VALUES (
	'JNF019050',
	'Family / Orphans & Foster Homes') 
INSERT INTO temp_sgt_bisaccodes_2010 VALUES (
	'JNF019060',
	'Family / Parents') 
INSERT INTO temp_sgt_bisaccodes_2010 VALUES (
	'JNF019070',
	'Family / Siblings')   
INSERT INTO temp_sgt_bisaccodes_2010 VALUES (
	'JNF019080',
	'Family / Stepfamilies')  
INSERT INTO temp_sgt_bisaccodes_2010 VALUES (
	'JNF020000',
	'Foreign Language Study / General')  
INSERT INTO temp_sgt_bisaccodes_2010 VALUES (
	'JNF020010',
	'Foreign Language Study / English as a Second Language    ') 
INSERT INTO temp_sgt_bisaccodes_2010 VALUES (
	'JNF020020',
	'Foreign Language Study / French') 
INSERT INTO temp_sgt_bisaccodes_2010 VALUES (
	'JNF020030',
	'Foreign Language Study / Spanish')  
INSERT INTO temp_sgt_bisaccodes_2010 VALUES (
	'JNF021000',
	'Games & Activities / General') 
INSERT INTO temp_sgt_bisaccodes_2010 VALUES (
	'JNF021010',
	'Games & Activities / Board Games')  
INSERT INTO temp_sgt_bisaccodes_2010 VALUES (
	'JNF021020',
	'Games & Activities / Card Games') 
INSERT INTO temp_sgt_bisaccodes_2010 VALUES (
	'JNF021030',
	'Games & Activities / Magic')  
INSERT INTO temp_sgt_bisaccodes_2010 VALUES (
	'JNF021040',
	'Games & Activities / Puzzles') 
INSERT INTO temp_sgt_bisaccodes_2010 VALUES (
	'JNF021050',
	'Games & Activities / Questions & Answers ')  
INSERT INTO temp_sgt_bisaccodes_2010 VALUES (
	'JNF021060',
	'Games & Activities / Video & Electronic Games') 
INSERT INTO temp_sgt_bisaccodes_2010 VALUES (
	'JNF021070',
	'Games & Activities / Word Games') 
INSERT INTO temp_sgt_bisaccodes_2010 VALUES (
	'JNF022000',
	'Gardening') 
INSERT INTO temp_sgt_bisaccodes_2010 VALUES (
	'JNF023000',
	'Girls & Women')  
INSERT INTO temp_sgt_bisaccodes_2010 VALUES (
	'JNF024000',
	'Health & Daily Living / General') 
INSERT INTO temp_sgt_bisaccodes_2010 VALUES (
	'JNF024120',
	'Health & Daily Living / Daily Activities ')  
INSERT INTO temp_sgt_bisaccodes_2010 VALUES (
	'JNF024010',
	'Health & Daily Living / Diet & Nutrition ')  
INSERT INTO temp_sgt_bisaccodes_2010 VALUES (
	'JNF024020',
	'Health & Daily Living / Diseases, Illnesses & Injuries   ') 
INSERT INTO temp_sgt_bisaccodes_2010 VALUES (
	'JNF024030',
	'Health & Daily Living / First Aid') 
INSERT INTO temp_sgt_bisaccodes_2010 VALUES (
	'JNF024040',
	'Health & Daily Living / Fitness & Exercise') 
INSERT INTO temp_sgt_bisaccodes_2010 VALUES (
	'JNF024050',
	'Health & Daily Living / Maturing')  
INSERT INTO temp_sgt_bisaccodes_2010 VALUES (
	'JNF024060',
	'Health & Daily Living / Personal Hygiene ')  
INSERT INTO temp_sgt_bisaccodes_2010 VALUES (
	'JNF024070',
	'Health & Daily Living / Physical Impairments')  
INSERT INTO temp_sgt_bisaccodes_2010 VALUES (
	'JNF024080',
	'Health & Daily Living / Safety')  
INSERT INTO temp_sgt_bisaccodes_2010 VALUES (
	'JNF024090',
	'Health & Daily Living / Sexuality & Pregnancy') 
INSERT INTO temp_sgt_bisaccodes_2010 VALUES (
	'JNF024100',
	'Health & Daily Living / Substance Abuse  ')  
INSERT INTO temp_sgt_bisaccodes_2010 VALUES (
	'JNF024110',
	'Health & Daily Living / Toilet Training  ')  
INSERT INTO temp_sgt_bisaccodes_2010 VALUES (
	'JNF025000',
	'History / General')   
INSERT INTO temp_sgt_bisaccodes_2010 VALUES (
	'JNF025010',
	'History / Africa') 
INSERT INTO temp_sgt_bisaccodes_2010 VALUES (
	'JNF025020',
	'History / Ancient')   
INSERT INTO temp_sgt_bisaccodes_2010 VALUES (
	'JNF025030',
	'History / Asia') 
INSERT INTO temp_sgt_bisaccodes_2010 VALUES (
	'JNF025040',
	'History / Australia & Oceania ')  
INSERT INTO temp_sgt_bisaccodes_2010 VALUES (
	'JNF025050',
	'History / Canada / General')  
INSERT INTO temp_sgt_bisaccodes_2010 VALUES (
	'JNF025230',
	'History / Canada / Pre-Confederation (to 1867)')  
INSERT INTO temp_sgt_bisaccodes_2010 VALUES (
	'JNF025240',
	'History / Canada / Post-Confederation (1867-)') 
INSERT INTO temp_sgt_bisaccodes_2010 VALUES (
	'JNF025060',
	'History / Central & South America') 
INSERT INTO temp_sgt_bisaccodes_2010 VALUES (
	'JNF025070',
	'History / Europe') 
INSERT INTO temp_sgt_bisaccodes_2010 VALUES (
	'JNF025080',
	'History / Exploration & Discovery') 
INSERT INTO temp_sgt_bisaccodes_2010 VALUES (
	'JNF025090',
	'History / Holocaust')  
INSERT INTO temp_sgt_bisaccodes_2010 VALUES (
	'JNF025100',
	'History / Medieval')  
INSERT INTO temp_sgt_bisaccodes_2010 VALUES (
	'JNF025110',
	'History / Mexico') 
INSERT INTO temp_sgt_bisaccodes_2010 VALUES (
	'JNF025120',
	'History / Middle East')  
INSERT INTO temp_sgt_bisaccodes_2010 VALUES (
	'JNF025130',
	'History / Military & Wars') 
INSERT INTO temp_sgt_bisaccodes_2010 VALUES (
	'JNF025140',
	'History / Modern') 
INSERT INTO temp_sgt_bisaccodes_2010 VALUES (
	'JNF025150',
	'History / Prehistoric')  
INSERT INTO temp_sgt_bisaccodes_2010 VALUES (
	'JNF025160',
	'History / Renaissance')  
INSERT INTO temp_sgt_bisaccodes_2010 VALUES (
	'JNF025260',
	'History / Symbols, Monuments, National Parks, etc.') 
INSERT INTO temp_sgt_bisaccodes_2010 VALUES (
	'JNF025170',
	'History / United States / General') 
INSERT INTO temp_sgt_bisaccodes_2010 VALUES (
	'JNF025180',
	'History / United States / State & Local  ')  
INSERT INTO temp_sgt_bisaccodes_2010 VALUES (
	'JNF025190',
	'History / United States / Colonial & Revolutionary Periods') 
INSERT INTO temp_sgt_bisaccodes_2010 VALUES (
	'JNF025200',
	'History / United States / 19th Century') 
INSERT INTO temp_sgt_bisaccodes_2010 VALUES (
	'JNF025270',
	'History / United States / Civil War Period (1850-1877)   ') 
INSERT INTO temp_sgt_bisaccodes_2010 VALUES (
	'JNF025210',
	'History / United States / 20th Century') 
INSERT INTO temp_sgt_bisaccodes_2010 VALUES (
	'JNF025250',
	'History / United States / 21st Century') 
INSERT INTO temp_sgt_bisaccodes_2010 VALUES (
	'JNF025220',
	'History / Other')  
INSERT INTO temp_sgt_bisaccodes_2010 VALUES (
	'JNF026000',
	'Holidays & Celebrations / General (see also Religious / Christian / Holidays & Celebrations)  ') 
INSERT INTO temp_sgt_bisaccodes_2010 VALUES (
	'JNF026100',
	'Holidays & Celebrations / Birthdays  ') 
INSERT INTO temp_sgt_bisaccodes_2010 VALUES (
	'JNF026010',
	'Holidays & Celebrations / Christmas & Advent')  
INSERT INTO temp_sgt_bisaccodes_2010 VALUES (
	'JNF026020',
	'Holidays & Celebrations / Easter & Lent  ')  
INSERT INTO temp_sgt_bisaccodes_2010 VALUES (
	'JNF026030',
	'Holidays & Celebrations / Halloween  ') 
INSERT INTO temp_sgt_bisaccodes_2010 VALUES (
	'JNF026110',
	'Holidays & Celebrations / Hanukkah   ') 
INSERT INTO temp_sgt_bisaccodes_2010 VALUES (
	'JNF026050',
	'Holidays & Celebrations / Kwanzaa') 
INSERT INTO temp_sgt_bisaccodes_2010 VALUES (
	'JNF026120',
	'Holidays & Celebrations / Passover   ') 
INSERT INTO temp_sgt_bisaccodes_2010 VALUES (
	'JNF026130',
	'Holidays & Celebrations / Patriotic Holidays')  
INSERT INTO temp_sgt_bisaccodes_2010 VALUES (
	'JNF026060',
	'Holidays & Celebrations / Thanksgiving') 
INSERT INTO temp_sgt_bisaccodes_2010 VALUES (
	'JNF026070',
	'Holidays & Celebrations / Valentine''s Day')  
INSERT INTO temp_sgt_bisaccodes_2010 VALUES (
	'JNF026080',
	'Holidays & Celebrations / Other, Non-Religious')  
INSERT INTO temp_sgt_bisaccodes_2010 VALUES (
	'JNF026090',
	'Holidays & Celebrations / Other, Religious') 
INSERT INTO temp_sgt_bisaccodes_2010 VALUES (
	'JNF027000',
	'House & Home') 
INSERT INTO temp_sgt_bisaccodes_2010 VALUES (
	'JNF028000',
	'Humor / General')  
INSERT INTO temp_sgt_bisaccodes_2010 VALUES (
	'JNF028010',
	'Humor / Comic Strips & Cartoons') 
INSERT INTO temp_sgt_bisaccodes_2010 VALUES (
	'JNF028020',
	'Humor / Jokes & Riddles')   
INSERT INTO temp_sgt_bisaccodes_2010 VALUES (
	'JNF029000',
	'Language Arts / General')   
INSERT INTO temp_sgt_bisaccodes_2010 VALUES (
	'JNF029010',
	'Language Arts / Composition & Creative Writing')  
INSERT INTO temp_sgt_bisaccodes_2010 VALUES (
	'JNF029020',
	'Language Arts / Grammar')   
INSERT INTO temp_sgt_bisaccodes_2010 VALUES (
	'JNF029030',
	'Language Arts / Handwriting') 
INSERT INTO temp_sgt_bisaccodes_2010 VALUES (
	'JNF029050',
	'Language Arts / Sign Language ')  
INSERT INTO temp_sgt_bisaccodes_2010 VALUES (
	'JNF029040',
	'Language Arts / Vocabulary & Spelling') 
INSERT INTO temp_sgt_bisaccodes_2010 VALUES (
	'JNF030000',
	'Law & Crime')  
INSERT INTO temp_sgt_bisaccodes_2010 VALUES (
	'JNF031000',
	'Lifestyles / City & Town Life ')  
INSERT INTO temp_sgt_bisaccodes_2010 VALUES (
	'JNF032000',
	'Lifestyles / Country Life') 
INSERT INTO temp_sgt_bisaccodes_2010 VALUES (
	'JNF033000',
	'Lifestyles / Farm & Ranch Life')  
INSERT INTO temp_sgt_bisaccodes_2010 VALUES (
	'JNF034000',
	'Literary Criticism & Collections')  
INSERT INTO temp_sgt_bisaccodes_2010 VALUES (
	'JNF035000',
	'Mathematics / General')  
INSERT INTO temp_sgt_bisaccodes_2010 VALUES (
	'JNF035010',
	'Mathematics / Advanced') 
INSERT INTO temp_sgt_bisaccodes_2010 VALUES (
	'JNF035020',
	'Mathematics / Algebra')  
INSERT INTO temp_sgt_bisaccodes_2010 VALUES (
	'JNF035030',
	'Mathematics / Arithmetic')  
INSERT INTO temp_sgt_bisaccodes_2010 VALUES (
	'JNF035040',
	'Mathematics / Fractions')   
INSERT INTO temp_sgt_bisaccodes_2010 VALUES (
	'JNF035050',
	'Mathematics / Geometry') 
INSERT INTO temp_sgt_bisaccodes_2010 VALUES (
	'JNF060000',
	'Media Studies')  
INSERT INTO temp_sgt_bisaccodes_2010 VALUES (
	'JNF064000',
	'Media Tie-In') 
INSERT INTO temp_sgt_bisaccodes_2010 VALUES (
	'JNF036000',
	'Music / General')  
INSERT INTO temp_sgt_bisaccodes_2010 VALUES (
	'JNF036010',
	'Music / Classical')   
INSERT INTO temp_sgt_bisaccodes_2010 VALUES (
	'JNF036020',
	'Music / History')  
INSERT INTO temp_sgt_bisaccodes_2010 VALUES (
	'JNF036030',
	'Music / Instruction & Study') 
INSERT INTO temp_sgt_bisaccodes_2010 VALUES (
	'JNF036090',
	'Music / Instruments')  
INSERT INTO temp_sgt_bisaccodes_2010 VALUES (
	'JNF036040',
	'Music / Jazz') 
INSERT INTO temp_sgt_bisaccodes_2010 VALUES (
	'JNF036050',
	'Music / Popular')  
INSERT INTO temp_sgt_bisaccodes_2010 VALUES (
	'JNF036060',
	'Music / Rap & Hip Hop')  
INSERT INTO temp_sgt_bisaccodes_2010 VALUES (
	'JNF036070',
	'Music / Rock') 
INSERT INTO temp_sgt_bisaccodes_2010 VALUES (
	'JNF036080',
	'Music / Songbooks')   
INSERT INTO temp_sgt_bisaccodes_2010 VALUES (
	'JNF038000',
	'People & Places / General') 
INSERT INTO temp_sgt_bisaccodes_2010 VALUES (
	'JNF038010',
	'People & Places / Africa')  
INSERT INTO temp_sgt_bisaccodes_2010 VALUES (
	'JNF038020',
	'People & Places / Asia') 
INSERT INTO temp_sgt_bisaccodes_2010 VALUES (
	'JNF038030',
	'People & Places / Australia & Oceania') 
INSERT INTO temp_sgt_bisaccodes_2010 VALUES (
	'JNF038040',
	'People & Places / Canada / General   ') 
INSERT INTO temp_sgt_bisaccodes_2010 VALUES (
	'JNF038120',
	'People & Places / Canada / Native Canadian') 
INSERT INTO temp_sgt_bisaccodes_2010 VALUES (
	'JNF038050',
	'People & Places / Caribbean & Latin America ')  
INSERT INTO temp_sgt_bisaccodes_2010 VALUES (
	'JNF038060',
	'People & Places / Europe')  
INSERT INTO temp_sgt_bisaccodes_2010 VALUES (
	'JNF038070',
	'People & Places / Mexico')  
INSERT INTO temp_sgt_bisaccodes_2010 VALUES (
	'JNF038080',
	'People & Places / Middle East ')  
INSERT INTO temp_sgt_bisaccodes_2010 VALUES (
	'JNF038090',
	'People & Places / Polar Regions') 
INSERT INTO temp_sgt_bisaccodes_2010 VALUES (
	'JNF038100',
	'People & Places / United States / General')  
INSERT INTO temp_sgt_bisaccodes_2010 VALUES (
	'JNF018010',
	'People & Places / United States / African American') 
INSERT INTO temp_sgt_bisaccodes_2010 VALUES (
	'JNF018020',
	'People & Places / United States / Asian American')  
INSERT INTO temp_sgt_bisaccodes_2010 VALUES (
	'JNF018030',
	'People & Places / United States / Hispanic & Latino')  
INSERT INTO temp_sgt_bisaccodes_2010 VALUES (
	'JNF018040',
	'People & Places / United States / Native American') 
INSERT INTO temp_sgt_bisaccodes_2010 VALUES (
	'JNF018050',
	'People & Places / United States / Other  ')  
INSERT INTO temp_sgt_bisaccodes_2010 VALUES (
	'JNF038110',
	'People & Places / Other')   
INSERT INTO temp_sgt_bisaccodes_2010 VALUES (
	'JNF039000',
	'Performing Arts / General') 
INSERT INTO temp_sgt_bisaccodes_2010 VALUES (
	'JNF039010',
	'Performing Arts / Circus')  
INSERT INTO temp_sgt_bisaccodes_2010 VALUES (
	'JNF039020',
	'Performing Arts / Dance')   
INSERT INTO temp_sgt_bisaccodes_2010 VALUES (
	'JNF039030',
	'Performing Arts / Film') 
INSERT INTO temp_sgt_bisaccodes_2010 VALUES (
	'JNF039040',
	'Performing Arts / Television & Radio ') 
INSERT INTO temp_sgt_bisaccodes_2010 VALUES (
	'JNF039050',
	'Performing Arts / Theater') 
INSERT INTO temp_sgt_bisaccodes_2010 VALUES (
	'JNF040000',
	'Philosophy ')  
INSERT INTO temp_sgt_bisaccodes_2010 VALUES (
	'JNF041000',
	'Photography')  
INSERT INTO temp_sgt_bisaccodes_2010 VALUES (
	'JNF042000',
	'Poetry / General') 
INSERT INTO temp_sgt_bisaccodes_2010 VALUES (
	'JNF042010',
	'Poetry / Humorous')   
INSERT INTO temp_sgt_bisaccodes_2010 VALUES (
	'JNF045000',
	'Readers / Beginner')  
INSERT INTO temp_sgt_bisaccodes_2010 VALUES (
	'JNF046000',
	'Readers / Intermediate') 
INSERT INTO temp_sgt_bisaccodes_2010 VALUES (
	'JNF047000',
	'Readers / Chapter Books')   
INSERT INTO temp_sgt_bisaccodes_2010 VALUES (
	'JNF048000',
	'Reference / General')  
INSERT INTO temp_sgt_bisaccodes_2010 VALUES (
	'JNF048010',
	'Reference / Almanacs') 
INSERT INTO temp_sgt_bisaccodes_2010 VALUES (
	'JNF048020',
	'Reference / Atlases')  
INSERT INTO temp_sgt_bisaccodes_2010 VALUES (
	'JNF048030',
	'Reference / Dictionaries')  
INSERT INTO temp_sgt_bisaccodes_2010 VALUES (
	'JNF048040',
	'Reference / Encyclopedias') 
INSERT INTO temp_sgt_bisaccodes_2010 VALUES (
	'JNF048050',
	'Reference / Thesauri') 
INSERT INTO temp_sgt_bisaccodes_2010 VALUES (
	'JNF049000',
	'Religion / General')  
INSERT INTO temp_sgt_bisaccodes_2010 VALUES (
	'JNF049040',
	'Religion / Bible Stories / General   ') 
INSERT INTO temp_sgt_bisaccodes_2010 VALUES (
	'JNF049140',
	'Religion / Bible Stories / Old Testament ')  
INSERT INTO temp_sgt_bisaccodes_2010 VALUES (
	'JNF049150',
	'Religion / Bible Stories / New Testament ')  
INSERT INTO temp_sgt_bisaccodes_2010 VALUES (
	'JNF049020',
	'Religion / Biblical Biography ')  
INSERT INTO temp_sgt_bisaccodes_2010 VALUES (
	'JNF049030',
	'Religion / Biblical Commentaries & Interpretation') 
INSERT INTO temp_sgt_bisaccodes_2010 VALUES (
	'JNF049160',
	'Religion / Biblical History') 
INSERT INTO temp_sgt_bisaccodes_2010 VALUES (
	'JNF049170',
	'Religion / Biblical Reference ')  
INSERT INTO temp_sgt_bisaccodes_2010 VALUES (
	'JNF049010',
	'Religion / Biblical Studies') 
INSERT INTO temp_sgt_bisaccodes_2010 VALUES (
	'JNF049080',
	'Religion / Christianity')   
INSERT INTO temp_sgt_bisaccodes_2010 VALUES (
	'JNF049090',
	'Religion / Eastern')  
INSERT INTO temp_sgt_bisaccodes_2010 VALUES (
	'JNF049100',
	'Religion / Islam') 
INSERT INTO temp_sgt_bisaccodes_2010 VALUES (
	'JNF049110',
	'Religion / Judaism')  
INSERT INTO temp_sgt_bisaccodes_2010 VALUES (
	'JNF049130',
	'Religious / Christian / General') 
INSERT INTO temp_sgt_bisaccodes_2010 VALUES (
	'JNF049180',
	'Religious / Christian / Biography & Autobiography (see also Biography & Autobiography / Religious)')  
INSERT INTO temp_sgt_bisaccodes_2010 VALUES (
	'JNF049190',
	'Religious / Christian / Comics & Graphic Novels') 
INSERT INTO temp_sgt_bisaccodes_2010 VALUES (
	'JNF049120',
	'Religious / Christian / Devotional & Prayer ')  
INSERT INTO temp_sgt_bisaccodes_2010 VALUES (
	'JNF049200',
	'Religious / Christian / Early Readers') 
INSERT INTO temp_sgt_bisaccodes_2010 VALUES (
	'JNF049210',
	'Religious / Christian / Family & Relationships')  
INSERT INTO temp_sgt_bisaccodes_2010 VALUES (
	'JNF049220',
	'Religious / Christian / Games & Activities') 
INSERT INTO temp_sgt_bisaccodes_2010 VALUES (
	'JNF049230',
	'Religious / Christian / Health & Daily Living') 
INSERT INTO temp_sgt_bisaccodes_2010 VALUES (
	'JNF049240',
	'Religious / Christian / Holidays & Celebrations') 
INSERT INTO temp_sgt_bisaccodes_2010 VALUES (
	'JNF049250',
	'Religious / Christian / Inspirational') 
INSERT INTO temp_sgt_bisaccodes_2010 VALUES (
	'JNF049260',
	'Religious / Christian / Learning Concepts')  
INSERT INTO temp_sgt_bisaccodes_2010 VALUES (
	'JNF049270',
	'Religious / Christian / People & Places  ')  
INSERT INTO temp_sgt_bisaccodes_2010 VALUES (
	'JNF049280',
	'Religious / Christian / Science & Nature ')  
INSERT INTO temp_sgt_bisaccodes_2010 VALUES (
	'JNF049290',
	'Religious / Christian / Social Issues') 
INSERT INTO temp_sgt_bisaccodes_2010 VALUES (
	'JNF049300',
	'Religious / Christian / Sports & Recreation ')  
INSERT INTO temp_sgt_bisaccodes_2010 VALUES (
	'JNF049310',
	'Religious / Christian / Values & Virtues ')  
INSERT INTO temp_sgt_bisaccodes_2010 VALUES (
	'JNF050000',
	'School & Education')  
INSERT INTO temp_sgt_bisaccodes_2010 VALUES (
	'JNF051000',
	'Science & Nature / General (see also headings under Animals or Technology)')  
INSERT INTO temp_sgt_bisaccodes_2010 VALUES (
	'JNF051030',
	'Science & Nature / Anatomy & Physiology  ')  
INSERT INTO temp_sgt_bisaccodes_2010 VALUES (
	'JNF051040',
	'Science & Nature / Astronomy') 
INSERT INTO temp_sgt_bisaccodes_2010 VALUES (
	'JNF051050',
	'Science & Nature / Biology')  
INSERT INTO temp_sgt_bisaccodes_2010 VALUES (
	'JNF051060',
	'Science & Nature / Botany') 
INSERT INTO temp_sgt_bisaccodes_2010 VALUES (
	'JNF051070',
	'Science & Nature / Chemistry') 
INSERT INTO temp_sgt_bisaccodes_2010 VALUES (
	'JNF051160',
	'Science & Nature / Disasters') 
INSERT INTO temp_sgt_bisaccodes_2010 VALUES (
	'JNF051170',
	'Science & Nature / Discoveries')  
INSERT INTO temp_sgt_bisaccodes_2010 VALUES (
	'JNF051080',
	'Science & Nature / Earth Sciences / General ')  
INSERT INTO temp_sgt_bisaccodes_2010 VALUES (
	'JNF037010',
	'Science & Nature / Earth Sciences / Earthquakes & Volcanoes  ')  
INSERT INTO temp_sgt_bisaccodes_2010 VALUES (
	'JNF051180',
	'Science & Nature / Earth Sciences / Geography') 
INSERT INTO temp_sgt_bisaccodes_2010 VALUES (
	'JNF037060',
	'Science & Nature / Earth Sciences / Rocks & Minerals') 
INSERT INTO temp_sgt_bisaccodes_2010 VALUES (
	'JNF037070',
	'Science & Nature / Earth Sciences / Water (Oceans, Lakes, etc.) ')  
INSERT INTO temp_sgt_bisaccodes_2010 VALUES (
	'JNF037080',
	'Science & Nature / Earth Sciences / Weather ')  
INSERT INTO temp_sgt_bisaccodes_2010 VALUES (
	'JNF037020',
	'Science & Nature / Environmental Conservation & Protection') 
INSERT INTO temp_sgt_bisaccodes_2010 VALUES (
	'JNF051100',
	'Science & Nature / Environmental Science & Ecosystems    ') 
INSERT INTO temp_sgt_bisaccodes_2010 VALUES (
	'JNF051110',
	'Science & Nature / Experiments & Projects')  
INSERT INTO temp_sgt_bisaccodes_2010 VALUES (
	'JNF037030',
	'Science & Nature / Flowers & Plants  ') 
INSERT INTO temp_sgt_bisaccodes_2010 VALUES (
	'JNF037050',
	'Science & Nature / Fossils')  
INSERT INTO temp_sgt_bisaccodes_2010 VALUES (
	'JNF051190',
	'Science & Nature / History of Science') 
INSERT INTO temp_sgt_bisaccodes_2010 VALUES (
	'JNF051140',
	'Science & Nature / Physics')  
INSERT INTO temp_sgt_bisaccodes_2010 VALUES (
	'JNF037040',
	'Science & Nature / Trees & Forests   ') 
INSERT INTO temp_sgt_bisaccodes_2010 VALUES (
	'JNF051150',
	'Science & Nature / Zoology')  
INSERT INTO temp_sgt_bisaccodes_2010 VALUES (
	'JNF053000',
	'Social Issues / General (see also headings under Family) ') 
INSERT INTO temp_sgt_bisaccodes_2010 VALUES (
	'JNF053010',
	'Social Issues / Adolescence') 
INSERT INTO temp_sgt_bisaccodes_2010 VALUES (
	'JNF053220',
	'Social Issues / Bullying')  
INSERT INTO temp_sgt_bisaccodes_2010 VALUES (
	'JNF053020',
	'Social Issues / Dating & Sex') 
INSERT INTO temp_sgt_bisaccodes_2010 VALUES (
	'JNF053030',
	'Social Issues / Death & Dying ')  
INSERT INTO temp_sgt_bisaccodes_2010 VALUES (
	'JNF053230',
	'Social Issues / Depression & Mental Illness ')  
INSERT INTO temp_sgt_bisaccodes_2010 VALUES (
	'JNF053040',
	'Social Issues / Drugs, Alcohol, Substance Abuse') 
INSERT INTO temp_sgt_bisaccodes_2010 VALUES (
	'JNF053240',
	'Social Issues / Emigration & Immigration ')  
INSERT INTO temp_sgt_bisaccodes_2010 VALUES (
	'JNF053050',
	'Social Issues / Emotions & Feelings  ') 
INSERT INTO temp_sgt_bisaccodes_2010 VALUES (
	'JNF053060',
	'Social Issues / Friendship')  
INSERT INTO temp_sgt_bisaccodes_2010 VALUES (
	'JNF053070',
	'Social Issues / Homelessness & Poverty') 
INSERT INTO temp_sgt_bisaccodes_2010 VALUES (
	'JNF053080',
	'Social Issues / Homosexuality ')  
INSERT INTO temp_sgt_bisaccodes_2010 VALUES (
	'JNF053090',
	'Social Issues / Manners & Etiquette  ') 
INSERT INTO temp_sgt_bisaccodes_2010 VALUES (
	'JNF053100',
	'Social Issues / New Experience')  
INSERT INTO temp_sgt_bisaccodes_2010 VALUES (
	'JNF053110',
	'Social Issues / Peer Pressure ')  
INSERT INTO temp_sgt_bisaccodes_2010 VALUES (
	'JNF053120',
	'Social Issues / Physical & Emotional Abuse (see also Social Issues / Sexual Abuse)  ')  
INSERT INTO temp_sgt_bisaccodes_2010 VALUES (
	'JNF053130',
	'Social Issues / Pregnancy') 
INSERT INTO temp_sgt_bisaccodes_2010 VALUES (
	'JNF053140',
	'Social Issues / Prejudice & Racism   ') 
INSERT INTO temp_sgt_bisaccodes_2010 VALUES (
	'JNF053150',
	'Social Issues / Runaways')  
INSERT INTO temp_sgt_bisaccodes_2010 VALUES (
	'JNF053160',
	'Social Issues / Self-Esteem & Self-Reliance ')  
INSERT INTO temp_sgt_bisaccodes_2010 VALUES (
	'JNF053250',
	'Social Issues / Self-Mutilation') 
INSERT INTO temp_sgt_bisaccodes_2010 VALUES (
	'JNF053170',
	'Social Issues / Sexual Abuse') 
INSERT INTO temp_sgt_bisaccodes_2010 VALUES (
	'JNF053180',
	'Social Issues / Special Needs ')  
INSERT INTO temp_sgt_bisaccodes_2010 VALUES (
	'JNF053260',
	'Social Issues / Strangers') 
INSERT INTO temp_sgt_bisaccodes_2010 VALUES (
	'JNF053190',
	'Social Issues / Suicide')   
INSERT INTO temp_sgt_bisaccodes_2010 VALUES (
	'JNF053200',
	'Social Issues / Values & Virtues')  
INSERT INTO temp_sgt_bisaccodes_2010 VALUES (
	'JNF053210',
	'Social Issues / Violence')  
INSERT INTO temp_sgt_bisaccodes_2010 VALUES (
	'JNF052000',
	'Social Science / General')  
INSERT INTO temp_sgt_bisaccodes_2010 VALUES (
	'JNF052010',
	'Social Science / Archaeology') 
INSERT INTO temp_sgt_bisaccodes_2010 VALUES (
	'JNF052020',
	'Social Science / Customs, Traditions, Anthropology') 
INSERT INTO temp_sgt_bisaccodes_2010 VALUES (
	'JNF052030',
	'Social Science / Folklore & Mythology') 
INSERT INTO temp_sgt_bisaccodes_2010 VALUES (
	'JNF043000',
	'Social Science / Politics & Government') 
INSERT INTO temp_sgt_bisaccodes_2010 VALUES (
	'JNF044000',
	'Social Science / Psychology') 
INSERT INTO temp_sgt_bisaccodes_2010 VALUES (
	'JNF052040',
	'Social Science / Sociology')  
INSERT INTO temp_sgt_bisaccodes_2010 VALUES (
	'JNF054000',
	'Sports & Recreation / General ')  
INSERT INTO temp_sgt_bisaccodes_2010 VALUES (
	'JNF054010',
	'Sports & Recreation / Baseball & Softball')  
INSERT INTO temp_sgt_bisaccodes_2010 VALUES (
	'JNF054020',
	'Sports & Recreation / Basketball')  
INSERT INTO temp_sgt_bisaccodes_2010 VALUES (
	'JNF054030',
	'Sports & Recreation / Camping & Outdoor Activities') 
INSERT INTO temp_sgt_bisaccodes_2010 VALUES (
	'JNF054040',
	'Sports & Recreation / Cycling ')  
INSERT INTO temp_sgt_bisaccodes_2010 VALUES (
	'JNF054170',
	'Sports & Recreation / Equestrian')  
INSERT INTO temp_sgt_bisaccodes_2010 VALUES (
	'JNF054180',
	'Sports & Recreation / Extreme Sports ') 
INSERT INTO temp_sgt_bisaccodes_2010 VALUES (
	'JNF054050',
	'Sports & Recreation / Football')  
INSERT INTO temp_sgt_bisaccodes_2010 VALUES (
	'JNF054230',
	'Sports & Recreation / Golf')  
INSERT INTO temp_sgt_bisaccodes_2010 VALUES (
	'JNF054060',
	'Sports & Recreation / Gymnastics')  
INSERT INTO temp_sgt_bisaccodes_2010 VALUES (
	'JNF054070',
	'Sports & Recreation / Hockey') 
INSERT INTO temp_sgt_bisaccodes_2010 VALUES (
	'JNF054190',
	'Sports & Recreation / Ice Skating') 
INSERT INTO temp_sgt_bisaccodes_2010 VALUES (
	'JNF054080',
	'Sports & Recreation / Martial Arts   ') 
INSERT INTO temp_sgt_bisaccodes_2010 VALUES (
	'JNF054090',
	'Sports & Recreation / Miscellaneous  ') 
INSERT INTO temp_sgt_bisaccodes_2010 VALUES (
	'JNF054100',
	'Sports & Recreation / Motor Sports   ') 
INSERT INTO temp_sgt_bisaccodes_2010 VALUES (
	'JNF054110',
	'Sports & Recreation / Olympics')  
INSERT INTO temp_sgt_bisaccodes_2010 VALUES (
	'JNF054120',
	'Sports & Recreation / Racket Sports  ') 
INSERT INTO temp_sgt_bisaccodes_2010 VALUES (
	'JNF054200',
	'Sports & Recreation / Roller & In-Line Skating')  
INSERT INTO temp_sgt_bisaccodes_2010 VALUES (
	'JNF054210',
	'Sports & Recreation / Skateboarding  ') 
INSERT INTO temp_sgt_bisaccodes_2010 VALUES (
	'JNF054130',
	'Sports & Recreation / Soccer') 
INSERT INTO temp_sgt_bisaccodes_2010 VALUES (
	'JNF054140',
	'Sports & Recreation / Track & Field  ') 
INSERT INTO temp_sgt_bisaccodes_2010 VALUES (
	'JNF054150',
	'Sports & Recreation / Water Sports   ') 
INSERT INTO temp_sgt_bisaccodes_2010 VALUES (
	'JNF054160',
	'Sports & Recreation / Winter Sports  ') 
INSERT INTO temp_sgt_bisaccodes_2010 VALUES (
	'JNF054220',
	'Sports & Recreation / Wrestling') 
INSERT INTO temp_sgt_bisaccodes_2010 VALUES (
	'JNF055000',
	'Study Aids / General') 
INSERT INTO temp_sgt_bisaccodes_2010 VALUES (
	'JNF055010',
	'Study Aids / Book Notes (see also STUDY AIDS / Book Notes)') 
INSERT INTO temp_sgt_bisaccodes_2010 VALUES (
	'JNF055030',
	'Study Aids / Test Preparation ')  
INSERT INTO temp_sgt_bisaccodes_2010 VALUES (
	'JNF061000',
	'Technology / General') 
INSERT INTO temp_sgt_bisaccodes_2010 VALUES (
	'JNF051010',
	'Technology / Aeronautics, Astronautics & Space Science   ') 
INSERT INTO temp_sgt_bisaccodes_2010 VALUES (
	'JNF051020',
	'Technology / Agriculture')  
INSERT INTO temp_sgt_bisaccodes_2010 VALUES (
	'JNF051090',
	'Technology / Electricity & Electronics') 
INSERT INTO temp_sgt_bisaccodes_2010 VALUES (
	'JNF051120',
	'Technology / How Things Work-Are Made') 
INSERT INTO temp_sgt_bisaccodes_2010 VALUES (
	'JNF061010',
	'Technology / Inventions')   
INSERT INTO temp_sgt_bisaccodes_2010 VALUES (
	'JNF051130',
	'Technology / Machinery & Tools')  
INSERT INTO temp_sgt_bisaccodes_2010 VALUES (
	'JNF056000',
	'Toys, Dolls & Puppets')  
INSERT INTO temp_sgt_bisaccodes_2010 VALUES (
	'JNF057000',
	'Transportation / General')  
INSERT INTO temp_sgt_bisaccodes_2010 VALUES (
	'JNF057010',
	'Transportation / Aviation') 
INSERT INTO temp_sgt_bisaccodes_2010 VALUES (
	'JNF057020',
	'Transportation / Boats, Ships & Underwater Craft')  
INSERT INTO temp_sgt_bisaccodes_2010 VALUES (
	'JNF057030',
	'Transportation / Cars & Trucks')  
INSERT INTO temp_sgt_bisaccodes_2010 VALUES (
	'JNF057040',
	'Transportation / Motorcycles') 
INSERT INTO temp_sgt_bisaccodes_2010 VALUES (
	'JNF057050',
	'Transportation / Railroads & Trains  ') 
INSERT INTO temp_sgt_bisaccodes_2010 VALUES (
	'JNF058000',
	'Travel')  
INSERT INTO temp_sgt_bisaccodes_2010 VALUES (
	'LAN000000',
	'General') 
INSERT INTO temp_sgt_bisaccodes_2010 VALUES (
	'LAN001000',
	'Alphabets & Writing Systems') 
INSERT INTO temp_sgt_bisaccodes_2010 VALUES (
	'LAN002000',
	'Authorship ')  
INSERT INTO temp_sgt_bisaccodes_2010 VALUES (
	'LAN004000',
	'Communication Studies')  
INSERT INTO temp_sgt_bisaccodes_2010 VALUES (
	'LAN005000',
	'Composition & Creative Writing')  
INSERT INTO temp_sgt_bisaccodes_2010 VALUES (
	'LAN022000',
	'Editing & Proofreading') 
INSERT INTO temp_sgt_bisaccodes_2010 VALUES (
	'LAN006000',
	'Grammar & Punctuation')  
INSERT INTO temp_sgt_bisaccodes_2010 VALUES (
	'LAN007000',
	'Handwriting')  
INSERT INTO temp_sgt_bisaccodes_2010 VALUES (
	'LAN008000',
	'Journalism ')  
INSERT INTO temp_sgt_bisaccodes_2010 VALUES (
	'LAN025000',
	'Library & Information Science / General  ')  
INSERT INTO temp_sgt_bisaccodes_2010 VALUES (
	'LAN025010',
	'Library & Information Science / Administration & Management  ')  
INSERT INTO temp_sgt_bisaccodes_2010 VALUES (
	'LAN025020',
	'Library & Information Science / Archives & Special Libraries ')  
INSERT INTO temp_sgt_bisaccodes_2010 VALUES (
	'LAN025030',
	'Library & Information Science / Cataloging & Classification  ')  
INSERT INTO temp_sgt_bisaccodes_2010 VALUES (
	'LAN025040',
	'Library & Information Science / Collection Development   ') 
INSERT INTO temp_sgt_bisaccodes_2010 VALUES (
	'LAN025050',
	'Library & Information Science / School Media')  
INSERT INTO temp_sgt_bisaccodes_2010 VALUES (
	'LAN009000',
	'Linguistics / General')  
INSERT INTO temp_sgt_bisaccodes_2010 VALUES (
	'LAN024000',
	'Linguistics / Etymology')   
INSERT INTO temp_sgt_bisaccodes_2010 VALUES (
	'LAN009010',
	'Linguistics / Historical & Comparative') 
INSERT INTO temp_sgt_bisaccodes_2010 VALUES (
	'LAN009020',
	'Linguistics / Morphology')  
INSERT INTO temp_sgt_bisaccodes_2010 VALUES (
	'LAN011000',
	'Linguistics / Phonetics & Phonology  ') 
INSERT INTO temp_sgt_bisaccodes_2010 VALUES (
	'LAN009030',
	'Linguistics / Pragmatics')  
INSERT INTO temp_sgt_bisaccodes_2010 VALUES (
	'LAN009040',
	'Linguistics / Psycholinguistics') 
INSERT INTO temp_sgt_bisaccodes_2010 VALUES (
	'LAN016000',
	'Linguistics / Semantics')   
INSERT INTO temp_sgt_bisaccodes_2010 VALUES (
	'LAN009050',
	'Linguistics / Sociolinguistics')  
INSERT INTO temp_sgt_bisaccodes_2010 VALUES (
	'LAN009060',
	'Linguistics / Syntax') 
INSERT INTO temp_sgt_bisaccodes_2010 VALUES (
	'LAN010000',
	'Literacy')  
INSERT INTO temp_sgt_bisaccodes_2010 VALUES (
	'LAN026000',
	'Public Speaking')  
INSERT INTO temp_sgt_bisaccodes_2010 VALUES (
	'LAN027000',
	'Publishing ')  
INSERT INTO temp_sgt_bisaccodes_2010 VALUES (
	'LAN012000',
	'Readers') 
INSERT INTO temp_sgt_bisaccodes_2010 VALUES (
	'LAN013000',
	'Reading Skills') 
INSERT INTO temp_sgt_bisaccodes_2010 VALUES (
	'LAN014000',
	'Reference') 
INSERT INTO temp_sgt_bisaccodes_2010 VALUES (
	'LAN015000',
	'Rhetoric')  
INSERT INTO temp_sgt_bisaccodes_2010 VALUES (
	'LAN017000',
	'Sign Language')  
INSERT INTO temp_sgt_bisaccodes_2010 VALUES (
	'LAN018000',
	'Speech')  
INSERT INTO temp_sgt_bisaccodes_2010 VALUES (
	'LAN019000',
	'Spelling')  
INSERT INTO temp_sgt_bisaccodes_2010 VALUES (
	'LAN020000',
	'Study & Teaching') 
INSERT INTO temp_sgt_bisaccodes_2010 VALUES (
	'LAN028000',
	'Style Manuals')  
INSERT INTO temp_sgt_bisaccodes_2010 VALUES (
	'LAN023000',
	'Translating & Interpreting')  
INSERT INTO temp_sgt_bisaccodes_2010 VALUES (
	'LAN021000',
	'Vocabulary ')  
INSERT INTO temp_sgt_bisaccodes_2010 VALUES (
	'LAW000000',
	'General') 
INSERT INTO temp_sgt_bisaccodes_2010 VALUES (
	'LAW001000',
	'Administrative Law & Regulatory Practice ')  
INSERT INTO temp_sgt_bisaccodes_2010 VALUES (
	'LAW102000',
	'Agricultural') 
INSERT INTO temp_sgt_bisaccodes_2010 VALUES (
	'LAW002000',
	'Air & Space')  
INSERT INTO temp_sgt_bisaccodes_2010 VALUES (
	'LAW003000',
	'Alternative Dispute Resolution')  
INSERT INTO temp_sgt_bisaccodes_2010 VALUES (
	'LAW004000',
	'Annotations & Citations')   
INSERT INTO temp_sgt_bisaccodes_2010 VALUES (
	'LAW005000',
	'Antitrust') 
INSERT INTO temp_sgt_bisaccodes_2010 VALUES (
	'LAW006000',
	'Arbitration, Negotiation, Mediation  ') 
INSERT INTO temp_sgt_bisaccodes_2010 VALUES (
	'LAW007000',
	'Banking') 
INSERT INTO temp_sgt_bisaccodes_2010 VALUES (
	'LAW008000',
	'Bankruptcy & Insolvency')   
INSERT INTO temp_sgt_bisaccodes_2010 VALUES (
	'LAW009000',
	'Business & Financial') 
INSERT INTO temp_sgt_bisaccodes_2010 VALUES (
	'LAW010000',
	'Child Advocacy') 
INSERT INTO temp_sgt_bisaccodes_2010 VALUES (
	'LAW011000',
	'Civil Law') 
INSERT INTO temp_sgt_bisaccodes_2010 VALUES (
	'LAW012000',
	'Civil Procedure')  
INSERT INTO temp_sgt_bisaccodes_2010 VALUES (
	'LAW013000',
	'Civil Rights') 
INSERT INTO temp_sgt_bisaccodes_2010 VALUES (
	'LAW014000',
	'Commercial / General') 
INSERT INTO temp_sgt_bisaccodes_2010 VALUES (
	'LAW014010',
	'Commercial / International Trade')  
INSERT INTO temp_sgt_bisaccodes_2010 VALUES (
	'LAW103000',
	'Common')  
INSERT INTO temp_sgt_bisaccodes_2010 VALUES (
	'LAW015000',
	'Communications') 
INSERT INTO temp_sgt_bisaccodes_2010 VALUES (
	'LAW016000',
	'Comparative')  
INSERT INTO temp_sgt_bisaccodes_2010 VALUES (
	'LAW104000',
	'Computer & Internet')  
INSERT INTO temp_sgt_bisaccodes_2010 VALUES (
	'LAW017000',
	'Conflict of Laws') 
INSERT INTO temp_sgt_bisaccodes_2010 VALUES (
	'LAW018000',
	'Constitutional') 
INSERT INTO temp_sgt_bisaccodes_2010 VALUES (
	'LAW019000',
	'Construction') 
INSERT INTO temp_sgt_bisaccodes_2010 VALUES (
	'LAW020000',
	'Consumer')  
INSERT INTO temp_sgt_bisaccodes_2010 VALUES (
	'LAW021000',
	'Contracts') 
INSERT INTO temp_sgt_bisaccodes_2010 VALUES (
	'LAW022000',
	'Corporate') 
INSERT INTO temp_sgt_bisaccodes_2010 VALUES (
	'LAW105000',
	'Corporate Governance') 
INSERT INTO temp_sgt_bisaccodes_2010 VALUES (
	'LAW023000',
	'Court Records')  
INSERT INTO temp_sgt_bisaccodes_2010 VALUES (
	'LAW024000',
	'Court Rules')  
INSERT INTO temp_sgt_bisaccodes_2010 VALUES (
	'LAW025000',
	'Courts')  
INSERT INTO temp_sgt_bisaccodes_2010 VALUES (
	'LAW026000',
	'Criminal Law / General') 
INSERT INTO temp_sgt_bisaccodes_2010 VALUES (
	'LAW026010',
	'Criminal Law / Juvenile Offenders') 
INSERT INTO temp_sgt_bisaccodes_2010 VALUES (
	'LAW026020',
	'Criminal Law / Sentencing') 
INSERT INTO temp_sgt_bisaccodes_2010 VALUES (
	'LAW027000',
	'Criminal Procedure')  
INSERT INTO temp_sgt_bisaccodes_2010 VALUES (
	'LAW028000',
	'Customary') 
INSERT INTO temp_sgt_bisaccodes_2010 VALUES (
	'LAW106000',
	'Defamation ')  
INSERT INTO temp_sgt_bisaccodes_2010 VALUES (
	'LAW029000',
	'Depositions')  
INSERT INTO temp_sgt_bisaccodes_2010 VALUES (
	'LAW030000',
	'Dictionaries & Terminology')  
INSERT INTO temp_sgt_bisaccodes_2010 VALUES (
	'LAW031000',
	'Disability ')  
INSERT INTO temp_sgt_bisaccodes_2010 VALUES (
	'LAW094000',
	'Discrimination') 
INSERT INTO temp_sgt_bisaccodes_2010 VALUES (
	'LAW092000',
	'Educational Law & Legislation ')  
INSERT INTO temp_sgt_bisaccodes_2010 VALUES (
	'LAW107000',
	'Elder Law') 
INSERT INTO temp_sgt_bisaccodes_2010 VALUES (
	'LAW108000',
	'Election Law') 
INSERT INTO temp_sgt_bisaccodes_2010 VALUES (
	'LAW032000',
	'Emigration & Immigration')  
INSERT INTO temp_sgt_bisaccodes_2010 VALUES (
	'LAW033000',
	'Entertainment')  
INSERT INTO temp_sgt_bisaccodes_2010 VALUES (
	'LAW034000',
	'Environmental')  
INSERT INTO temp_sgt_bisaccodes_2010 VALUES (
	'LAW101000',
	'Essays')  
INSERT INTO temp_sgt_bisaccodes_2010 VALUES (
	'LAW035000',
	'Estates & Trusts') 
INSERT INTO temp_sgt_bisaccodes_2010 VALUES (
	'LAW036000',
	'Ethics & Professional Responsibility ') 
INSERT INTO temp_sgt_bisaccodes_2010 VALUES (
	'LAW037000',
	'Evidence')  
INSERT INTO temp_sgt_bisaccodes_2010 VALUES (
	'LAW038000',
	'Family Law / General') 
INSERT INTO temp_sgt_bisaccodes_2010 VALUES (
	'LAW038010',
	'Family Law / Children')  
INSERT INTO temp_sgt_bisaccodes_2010 VALUES (
	'LAW038020',
	'Family Law / Divorce & Separation') 
INSERT INTO temp_sgt_bisaccodes_2010 VALUES (
	'LAW038030',
	'Family Law / Marriage')  
INSERT INTO temp_sgt_bisaccodes_2010 VALUES (
	'LAW041000',
	'Forensic Science') 
INSERT INTO temp_sgt_bisaccodes_2010 VALUES (
	'LAW043000',
	'Gender & the Law') 
INSERT INTO temp_sgt_bisaccodes_2010 VALUES (
	'LAW044000',
	'General Practice') 
INSERT INTO temp_sgt_bisaccodes_2010 VALUES (
	'LAW109000',
	'Government / General') 
INSERT INTO temp_sgt_bisaccodes_2010 VALUES (
	'LAW039000',
	'Government / Federal') 
INSERT INTO temp_sgt_bisaccodes_2010 VALUES (
	'LAW089000',
	'Government / State, Provincial & Municipal') 
INSERT INTO temp_sgt_bisaccodes_2010 VALUES (
	'LAW046000',
	'Health')  
INSERT INTO temp_sgt_bisaccodes_2010 VALUES (
	'LAW047000',
	'Housing & Urban Development') 
INSERT INTO temp_sgt_bisaccodes_2010 VALUES (
	'LAW110000',
	'Indigenous Peoples')  
INSERT INTO temp_sgt_bisaccodes_2010 VALUES (
	'LAW049000',
	'Insurance') 
INSERT INTO temp_sgt_bisaccodes_2010 VALUES (
	'LAW050000',
	'Intellectual Property / General') 
INSERT INTO temp_sgt_bisaccodes_2010 VALUES (
	'LAW050010',
	'Intellectual Property / Copyright') 
INSERT INTO temp_sgt_bisaccodes_2010 VALUES (
	'LAW050020',
	'Intellectual Property / Patent')  
INSERT INTO temp_sgt_bisaccodes_2010 VALUES (
	'LAW050030',
	'Intellectual Property / Trademark') 
INSERT INTO temp_sgt_bisaccodes_2010 VALUES (
	'LAW051000',
	'International')  
INSERT INTO temp_sgt_bisaccodes_2010 VALUES (
	'LAW111000',
	'Judicial Power') 
INSERT INTO temp_sgt_bisaccodes_2010 VALUES (
	'LAW052000',
	'Jurisprudence')  
INSERT INTO temp_sgt_bisaccodes_2010 VALUES (
	'LAW053000',
	'Jury')  
INSERT INTO temp_sgt_bisaccodes_2010 VALUES (
	'LAW054000',
	'Labor & Employment')  
INSERT INTO temp_sgt_bisaccodes_2010 VALUES (
	'LAW055000',
	'Land Use')  
INSERT INTO temp_sgt_bisaccodes_2010 VALUES (
	'LAW112000',
	'Landlord & Tenant')   
INSERT INTO temp_sgt_bisaccodes_2010 VALUES (
	'LAW056000',
	'Law Office Management')  
INSERT INTO temp_sgt_bisaccodes_2010 VALUES (
	'LAW059000',
	'Legal Education')  
INSERT INTO temp_sgt_bisaccodes_2010 VALUES (
	'LAW060000',
	'Legal History')  
INSERT INTO temp_sgt_bisaccodes_2010 VALUES (
	'LAW061000',
	'Legal Profession') 
INSERT INTO temp_sgt_bisaccodes_2010 VALUES (
	'LAW062000',
	'Legal Services') 
INSERT INTO temp_sgt_bisaccodes_2010 VALUES (
	'LAW063000',
	'Legal Writing')  
INSERT INTO temp_sgt_bisaccodes_2010 VALUES (
	'LAW113000',
	'Liability') 
INSERT INTO temp_sgt_bisaccodes_2010 VALUES (
	'LAW064000',
	'Litigation ')  
INSERT INTO temp_sgt_bisaccodes_2010 VALUES (
	'LAW100000',
	'Living Trusts')  
INSERT INTO temp_sgt_bisaccodes_2010 VALUES (
	'LAW095000',
	'Malpractice')  
INSERT INTO temp_sgt_bisaccodes_2010 VALUES (
	'LAW066000',
	'Maritime')  
INSERT INTO temp_sgt_bisaccodes_2010 VALUES (
	'LAW096000',
	'Media & the Law')  
INSERT INTO temp_sgt_bisaccodes_2010 VALUES (
	'LAW093000',
	'Medical Law & Legislation') 
INSERT INTO temp_sgt_bisaccodes_2010 VALUES (
	'LAW067000',
	'Mental Health')  
INSERT INTO temp_sgt_bisaccodes_2010 VALUES (
	'LAW114000',
	'Mergers & Acquisitions') 
INSERT INTO temp_sgt_bisaccodes_2010 VALUES (
	'LAW068000',
	'Military')  
INSERT INTO temp_sgt_bisaccodes_2010 VALUES (
	'LAW069000',
	'Natural Law')  
INSERT INTO temp_sgt_bisaccodes_2010 VALUES (
	'LAW070000',
	'Natural Resources')   
INSERT INTO temp_sgt_bisaccodes_2010 VALUES (
	'LAW071000',
	'Paralegals & Paralegalism') 
INSERT INTO temp_sgt_bisaccodes_2010 VALUES (
	'LAW115000',
	'Pension Law')  
INSERT INTO temp_sgt_bisaccodes_2010 VALUES (
	'LAW097000',
	'Personal Injury')  
INSERT INTO temp_sgt_bisaccodes_2010 VALUES (
	'LAW098000',
	'Practical Guides') 
INSERT INTO temp_sgt_bisaccodes_2010 VALUES (
	'LAW116000',
	'Privacy') 
INSERT INTO temp_sgt_bisaccodes_2010 VALUES (
	'LAW074000',
	'Property')  
INSERT INTO temp_sgt_bisaccodes_2010 VALUES (
	'LAW075000',
	'Public')  
INSERT INTO temp_sgt_bisaccodes_2010 VALUES (
	'LAW076000',
	'Public Contract')  
INSERT INTO temp_sgt_bisaccodes_2010 VALUES (
	'LAW077000',
	'Public Utilities') 
INSERT INTO temp_sgt_bisaccodes_2010 VALUES (
	'LAW078000',
	'Real Estate')  
INSERT INTO temp_sgt_bisaccodes_2010 VALUES (
	'LAW079000',
	'Reference') 
INSERT INTO temp_sgt_bisaccodes_2010 VALUES (
	'LAW080000',
	'Remedies & Damages')  
INSERT INTO temp_sgt_bisaccodes_2010 VALUES (
	'LAW081000',
	'Research')  
INSERT INTO temp_sgt_bisaccodes_2010 VALUES (
	'LAW082000',
	'Right to Die') 
INSERT INTO temp_sgt_bisaccodes_2010 VALUES (
	'LAW099000',
	'Science & Technology') 
INSERT INTO temp_sgt_bisaccodes_2010 VALUES (
	'LAW083000',
	'Securities ')  
INSERT INTO temp_sgt_bisaccodes_2010 VALUES (
	'LAW084000',
	'Sports')  
INSERT INTO temp_sgt_bisaccodes_2010 VALUES (
	'LAW086000',
	'Taxation')  
INSERT INTO temp_sgt_bisaccodes_2010 VALUES (
	'LAW087000',
	'Torts') 
INSERT INTO temp_sgt_bisaccodes_2010 VALUES (
	'LAW088000',
	'Trial Practice') 
INSERT INTO temp_sgt_bisaccodes_2010 VALUES (
	'LAW090000',
	'Wills') 
INSERT INTO temp_sgt_bisaccodes_2010 VALUES (
	'LAW091000',
	'Witnesses') 
INSERT INTO temp_sgt_bisaccodes_2010 VALUES (
	'LCO000000',
	'General') 
INSERT INTO temp_sgt_bisaccodes_2010 VALUES (
	'LCO001000',
	'African') 
INSERT INTO temp_sgt_bisaccodes_2010 VALUES (
	'LCO002000',
	'American / General')  
INSERT INTO temp_sgt_bisaccodes_2010 VALUES (
	'LCO002010',
	'American / African American') 
INSERT INTO temp_sgt_bisaccodes_2010 VALUES (
	'LCO003000',
	'Ancient, Classical & Medieval ')  
INSERT INTO temp_sgt_bisaccodes_2010 VALUES (
	'LCO004000',
	'Asian') 
INSERT INTO temp_sgt_bisaccodes_2010 VALUES (
	'LCO005000',
	'Australian & Oceanian')  
INSERT INTO temp_sgt_bisaccodes_2010 VALUES (
	'LCO006000',
	'Canadian')  
INSERT INTO temp_sgt_bisaccodes_2010 VALUES (
	'LCO007000',
	'Caribbean & Latin American')  
INSERT INTO temp_sgt_bisaccodes_2010 VALUES (
	'LCO008000',
	'Continental European') 
INSERT INTO temp_sgt_bisaccodes_2010 VALUES (
	'LCO009000',
	'English, Irish, Scottish, Welsh') 
INSERT INTO temp_sgt_bisaccodes_2010 VALUES (
	'LCO010000',
	'Essays')  
INSERT INTO temp_sgt_bisaccodes_2010 VALUES (
	'LCO011000',
	'Letters') 
INSERT INTO temp_sgt_bisaccodes_2010 VALUES (
	'LCO012000',
	'Middle Eastern') 
INSERT INTO temp_sgt_bisaccodes_2010 VALUES (
	'LCO013000',
	'Native American')  
INSERT INTO temp_sgt_bisaccodes_2010 VALUES (
	'LCO014000',
	'Russian & Former Soviet Union ')  
INSERT INTO temp_sgt_bisaccodes_2010 VALUES (
	'LIT000000',
	'General') 
INSERT INTO temp_sgt_bisaccodes_2010 VALUES (
	'LIT004010',
	'African') 
INSERT INTO temp_sgt_bisaccodes_2010 VALUES (
	'LIT004020',
	'American / General')  
INSERT INTO temp_sgt_bisaccodes_2010 VALUES (
	'LIT004040',
	'American / African American') 
INSERT INTO temp_sgt_bisaccodes_2010 VALUES (
	'LIT004030',
	'American / Asian American') 
INSERT INTO temp_sgt_bisaccodes_2010 VALUES (
	'LIT004050',
	'American / Hispanic American') 
INSERT INTO temp_sgt_bisaccodes_2010 VALUES (
	'LIT004190',
	'Ancient & Classical')  
INSERT INTO temp_sgt_bisaccodes_2010 VALUES (
	'LIT008000',
	'Asian / General')  
INSERT INTO temp_sgt_bisaccodes_2010 VALUES (
	'LIT008010',
	'Asian / Chinese')  
INSERT INTO temp_sgt_bisaccodes_2010 VALUES (
	'LIT008020',
	'Asian / Indic')  
INSERT INTO temp_sgt_bisaccodes_2010 VALUES (
	'LIT008030',
	'Asian / Japanese') 
INSERT INTO temp_sgt_bisaccodes_2010 VALUES (
	'LIT004070',
	'Australian & Oceanian')  
INSERT INTO temp_sgt_bisaccodes_2010 VALUES (
	'LIT007000',
	'Books & Reading')  
INSERT INTO temp_sgt_bisaccodes_2010 VALUES (
	'LIT004080',
	'Canadian')  
INSERT INTO temp_sgt_bisaccodes_2010 VALUES (
	'LIT004100',
	'Caribbean & Latin American')  
INSERT INTO temp_sgt_bisaccodes_2010 VALUES (
	'LIT009000',
	'Children''s Literature')  
INSERT INTO temp_sgt_bisaccodes_2010 VALUES (
	'LIT017000',
	'Comics & Graphic Novels')   
INSERT INTO temp_sgt_bisaccodes_2010 VALUES (
	'LIT013000',
	'Drama') 
INSERT INTO temp_sgt_bisaccodes_2010 VALUES (
	'LIT004130',
	'European / General')  
INSERT INTO temp_sgt_bisaccodes_2010 VALUES (
	'LIT004110',
	'European / Eastern (see also Russian & Former Soviet Union)  ')  
INSERT INTO temp_sgt_bisaccodes_2010 VALUES (
	'LIT004120',
	'European / English, Irish, Scottish, Welsh') 
INSERT INTO temp_sgt_bisaccodes_2010 VALUES (
	'LIT004150',
	'European / French')   
INSERT INTO temp_sgt_bisaccodes_2010 VALUES (
	'LIT004170',
	'European / German')   
INSERT INTO temp_sgt_bisaccodes_2010 VALUES (
	'LIT004200',
	'European / Italian')  
INSERT INTO temp_sgt_bisaccodes_2010 VALUES (
	'LIT004250',
	'European / Scandinavian')   
INSERT INTO temp_sgt_bisaccodes_2010 VALUES (
	'LIT004280',
	'European / Spanish & Portuguese') 
INSERT INTO temp_sgt_bisaccodes_2010 VALUES (
	'LIT003000',
	'Feminist')  
INSERT INTO temp_sgt_bisaccodes_2010 VALUES (
	'LIT004160',
	'Gay & Lesbian')  
INSERT INTO temp_sgt_bisaccodes_2010 VALUES (
	'LIT004180',
	'Gothic & Romance') 
INSERT INTO temp_sgt_bisaccodes_2010 VALUES (
	'LIT016000',
	'Humor') 
INSERT INTO temp_sgt_bisaccodes_2010 VALUES (
	'LIT004210',
	'Jewish')  
INSERT INTO temp_sgt_bisaccodes_2010 VALUES (
	'LIT011000',
	'Medieval')  
INSERT INTO temp_sgt_bisaccodes_2010 VALUES (
	'LIT004220',
	'Middle Eastern') 
INSERT INTO temp_sgt_bisaccodes_2010 VALUES (
	'LIT004230',
	'Mystery & Detective')  
INSERT INTO temp_sgt_bisaccodes_2010 VALUES (
	'LIT004060',
	'Native American')  
INSERT INTO temp_sgt_bisaccodes_2010 VALUES (
	'LIT014000',
	'Poetry')  
INSERT INTO temp_sgt_bisaccodes_2010 VALUES (
	'LIT012000',
	'Reference') 
INSERT INTO temp_sgt_bisaccodes_2010 VALUES (
	'LIT019000',
	'Renaissance')  
INSERT INTO temp_sgt_bisaccodes_2010 VALUES (
	'LIT004240',
	'Russian & Former Soviet Union ')  
INSERT INTO temp_sgt_bisaccodes_2010 VALUES (
	'LIT004260',
	'Science Fiction & Fantasy') 
INSERT INTO temp_sgt_bisaccodes_2010 VALUES (
	'LIT006000',
	'Semiotics & Theory')  
INSERT INTO temp_sgt_bisaccodes_2010 VALUES (
	'LIT015000',
	'Shakespeare')  
INSERT INTO temp_sgt_bisaccodes_2010 VALUES (
	'LIT018000',
	'Short Stories')  
INSERT INTO temp_sgt_bisaccodes_2010 VALUES (
	'LIT004290',
	'Women Authors')  
INSERT INTO temp_sgt_bisaccodes_2010 VALUES (
	'MAT000000',
	'General') 
INSERT INTO temp_sgt_bisaccodes_2010 VALUES (
	'MAT001000',
	'Advanced')  
INSERT INTO temp_sgt_bisaccodes_2010 VALUES (
	'MAT002000',
	'Algebra / General')   
INSERT INTO temp_sgt_bisaccodes_2010 VALUES (
	'MAT002010',
	'Algebra / Abstract')  
INSERT INTO temp_sgt_bisaccodes_2010 VALUES (
	'MAT002030',
	'Algebra / Elementary') 
INSERT INTO temp_sgt_bisaccodes_2010 VALUES (
	'MAT002040',
	'Algebra / Intermediate') 
INSERT INTO temp_sgt_bisaccodes_2010 VALUES (
	'MAT002050',
	'Algebra / Linear') 
INSERT INTO temp_sgt_bisaccodes_2010 VALUES (
	'MAT003000',
	'Applied') 
INSERT INTO temp_sgt_bisaccodes_2010 VALUES (
	'MAT004000',
	'Arithmetic ')  
INSERT INTO temp_sgt_bisaccodes_2010 VALUES (
	'MAT005000',
	'Calculus')  
INSERT INTO temp_sgt_bisaccodes_2010 VALUES (
	'MAT036000',
	'Combinatorics')  
INSERT INTO temp_sgt_bisaccodes_2010 VALUES (
	'MAT006000',
	'Counting & Numeration')  
INSERT INTO temp_sgt_bisaccodes_2010 VALUES (
	'MAT007000',
	'Differential Equations / General') 
INSERT INTO temp_sgt_bisaccodes_2010 VALUES (
	'MAT008000',
	'Discrete Mathematics') 
INSERT INTO temp_sgt_bisaccodes_2010 VALUES (
	'MAT039000',
	'Essays')  
INSERT INTO temp_sgt_bisaccodes_2010 VALUES (
	'MAT009000',
	'Finite Mathematics')  
INSERT INTO temp_sgt_bisaccodes_2010 VALUES (
	'MAT037000',
	'Functional Analysis')  
INSERT INTO temp_sgt_bisaccodes_2010 VALUES (
	'MAT011000',
	'Game Theory')  
INSERT INTO temp_sgt_bisaccodes_2010 VALUES (
	'MAT012000',
	'Geometry / General')  
INSERT INTO temp_sgt_bisaccodes_2010 VALUES (
	'MAT012010',
	'Geometry / Algebraic') 
INSERT INTO temp_sgt_bisaccodes_2010 VALUES (
	'MAT012020',
	'Geometry / Analytic')  
INSERT INTO temp_sgt_bisaccodes_2010 VALUES (
	'MAT012030',
	'Geometry / Differential')   
INSERT INTO temp_sgt_bisaccodes_2010 VALUES (
	'MAT012040',
	'Geometry / Non-Euclidean')  
INSERT INTO temp_sgt_bisaccodes_2010 VALUES (
	'MAT013000',
	'Graphic Methods')  
INSERT INTO temp_sgt_bisaccodes_2010 VALUES (
	'MAT014000',
	'Group Theory') 
INSERT INTO temp_sgt_bisaccodes_2010 VALUES (
	'MAT015000',
	'History & Philosophy') 
INSERT INTO temp_sgt_bisaccodes_2010 VALUES (
	'MAT016000',
	'Infinity')  
INSERT INTO temp_sgt_bisaccodes_2010 VALUES (
	'MAT017000',
	'Linear & Nonlinear Programming')  
INSERT INTO temp_sgt_bisaccodes_2010 VALUES (
	'MAT018000',
	'Logic') 
INSERT INTO temp_sgt_bisaccodes_2010 VALUES (
	'MAT034000',
	'Mathematical Analysis')  
INSERT INTO temp_sgt_bisaccodes_2010 VALUES (
	'MAT019000',
	'Matrices')  
INSERT INTO temp_sgt_bisaccodes_2010 VALUES (
	'MAT020000',
	'Measurement')  
INSERT INTO temp_sgt_bisaccodes_2010 VALUES (
	'MAT021000',
	'Number Systems') 
INSERT INTO temp_sgt_bisaccodes_2010 VALUES (
	'MAT022000',
	'Number Theory')  
INSERT INTO temp_sgt_bisaccodes_2010 VALUES (
	'MAT023000',
	'Pre-Calculus') 
INSERT INTO temp_sgt_bisaccodes_2010 VALUES (
	'MAT029000',
	'Probability & Statistics / General   ') 
INSERT INTO temp_sgt_bisaccodes_2010 VALUES (
	'MAT029010',
	'Probability & Statistics / Bayesian Analysis')  
INSERT INTO temp_sgt_bisaccodes_2010 VALUES (
	'MAT029020',
	'Probability & Statistics / Multivariate Analysis')  
INSERT INTO temp_sgt_bisaccodes_2010 VALUES (
	'MAT029030',
	'Probability & Statistics / Regression Analysis')  
INSERT INTO temp_sgt_bisaccodes_2010 VALUES (
	'MAT025000',
	'Recreations & Games')  
INSERT INTO temp_sgt_bisaccodes_2010 VALUES (
	'MAT026000',
	'Reference') 
INSERT INTO temp_sgt_bisaccodes_2010 VALUES (
	'MAT027000',
	'Research')  
INSERT INTO temp_sgt_bisaccodes_2010 VALUES (
	'MAT028000',
	'Set Theory ')  
INSERT INTO temp_sgt_bisaccodes_2010 VALUES (
	'MAT030000',
	'Study & Teaching') 
INSERT INTO temp_sgt_bisaccodes_2010 VALUES (
	'MAT038000',
	'Topology')  
INSERT INTO temp_sgt_bisaccodes_2010 VALUES (
	'MAT031000',
	'Transformations')  
INSERT INTO temp_sgt_bisaccodes_2010 VALUES (
	'MAT032000',
	'Trigonometry') 
INSERT INTO temp_sgt_bisaccodes_2010 VALUES (
	'MAT033000',
	'Vector Analysis')  
INSERT INTO temp_sgt_bisaccodes_2010 VALUES (
	'MED000000',
	'General') 
INSERT INTO temp_sgt_bisaccodes_2010 VALUES (
	'MED001000',
	'Acupuncture')  
INSERT INTO temp_sgt_bisaccodes_2010 VALUES (
	'MED002000',
	'Administration') 
INSERT INTO temp_sgt_bisaccodes_2010 VALUES (
	'MED022020',
	'AIDS & HIV ')  
INSERT INTO temp_sgt_bisaccodes_2010 VALUES (
	'MED003000',
	'Allied Health Services / General')  
INSERT INTO temp_sgt_bisaccodes_2010 VALUES (
	'MED003010',
	'Allied Health Services / Emergency Medical Services')  
INSERT INTO temp_sgt_bisaccodes_2010 VALUES (
	'MED003020',
	'Allied Health Services / Hypnotherapy') 
INSERT INTO temp_sgt_bisaccodes_2010 VALUES (
	'MED003090',
	'Allied Health Services / Massage Therapy ')  
INSERT INTO temp_sgt_bisaccodes_2010 VALUES (
	'MED003030',
	'Allied Health Services / Medical Assistants ')  
INSERT INTO temp_sgt_bisaccodes_2010 VALUES (
	'MED003040',
	'Allied Health Services / Medical Technology ')  
INSERT INTO temp_sgt_bisaccodes_2010 VALUES (
	'MED003050',
	'Allied Health Services / Occupational Therapy') 
INSERT INTO temp_sgt_bisaccodes_2010 VALUES (
	'MED003060',
	'Allied Health Services / Physical Therapy')  
INSERT INTO temp_sgt_bisaccodes_2010 VALUES (
	'MED003070',
	'Allied Health Services / Radiological & Ultrasound Technology')  
INSERT INTO temp_sgt_bisaccodes_2010 VALUES (
	'MED003080',
	'Allied Health Services / Respiratory Therapy')  
INSERT INTO temp_sgt_bisaccodes_2010 VALUES (
	'MED004000',
	'Alternative Medicine') 
INSERT INTO temp_sgt_bisaccodes_2010 VALUES (
	'MED005000',
	'Anatomy') 
INSERT INTO temp_sgt_bisaccodes_2010 VALUES (
	'MED006000',
	'Anesthesiology') 
INSERT INTO temp_sgt_bisaccodes_2010 VALUES (
	'MED101000',
	'Atlases') 
INSERT INTO temp_sgt_bisaccodes_2010 VALUES (
	'MED007000',
	'Audiology & Speech Pathology') 
INSERT INTO temp_sgt_bisaccodes_2010 VALUES (
	'MED111000',
	'Bariatrics ')  
INSERT INTO temp_sgt_bisaccodes_2010 VALUES (
	'MED008000',
	'Biochemistry') 
INSERT INTO temp_sgt_bisaccodes_2010 VALUES (
	'MED090000',
	'Biostatistics')  
INSERT INTO temp_sgt_bisaccodes_2010 VALUES (
	'MED009000',
	'Biotechnology')  
INSERT INTO temp_sgt_bisaccodes_2010 VALUES (
	'MED010000',
	'Cardiology ')  
INSERT INTO temp_sgt_bisaccodes_2010 VALUES (
	'MED011000',
	'Caregiving ')  
INSERT INTO temp_sgt_bisaccodes_2010 VALUES (
	'MED012000',
	'Chemotherapy') 
INSERT INTO temp_sgt_bisaccodes_2010 VALUES (
	'MED013000',
	'Chiropractic') 
INSERT INTO temp_sgt_bisaccodes_2010 VALUES (
	'MED014000',
	'Clinical Medicine')   
INSERT INTO temp_sgt_bisaccodes_2010 VALUES (
	'MED015000',
	'Critical Care')  
INSERT INTO temp_sgt_bisaccodes_2010 VALUES (
	'MED016000',
	'Dentistry / General')  
INSERT INTO temp_sgt_bisaccodes_2010 VALUES (
	'MED016010',
	'Dentistry / Dental Assisting') 
INSERT INTO temp_sgt_bisaccodes_2010 VALUES (
	'MED016020',
	'Dentistry / Dental Hygiene')  
INSERT INTO temp_sgt_bisaccodes_2010 VALUES (
	'MED016050',
	'Dentistry / Oral Surgery')  
INSERT INTO temp_sgt_bisaccodes_2010 VALUES (
	'MED016030',
	'Dentistry / Orthodontics')  
INSERT INTO temp_sgt_bisaccodes_2010 VALUES (
	'MED016040',
	'Dentistry / Periodontics')  
INSERT INTO temp_sgt_bisaccodes_2010 VALUES (
	'MED017000',
	'Dermatology')  
INSERT INTO temp_sgt_bisaccodes_2010 VALUES (
	'MED018000',
	'Diagnosis') 
INSERT INTO temp_sgt_bisaccodes_2010 VALUES (
	'MED019000',
	'Diagnostic Imaging')  
INSERT INTO temp_sgt_bisaccodes_2010 VALUES (
	'MED020000',
	'Dictionaries & Terminology')  
INSERT INTO temp_sgt_bisaccodes_2010 VALUES (
	'MED021000',
	'Diet Therapy') 
INSERT INTO temp_sgt_bisaccodes_2010 VALUES (
	'MED022000',
	'Diseases')  
INSERT INTO temp_sgt_bisaccodes_2010 VALUES (
	'MED023000',
	'Drug Guides')  
INSERT INTO temp_sgt_bisaccodes_2010 VALUES (
	'MED024000',
	'Education & Training') 
INSERT INTO temp_sgt_bisaccodes_2010 VALUES (
	'MED025000',
	'Embryology ')  
INSERT INTO temp_sgt_bisaccodes_2010 VALUES (
	'MED026000',
	'Emergency Medicine')  
INSERT INTO temp_sgt_bisaccodes_2010 VALUES (
	'MED027000',
	'Endocrinology & Metabolism')  
INSERT INTO temp_sgt_bisaccodes_2010 VALUES (
	'MED028000',
	'Epidemiology') 
INSERT INTO temp_sgt_bisaccodes_2010 VALUES (
	'MED109000',
	'Essays')  
INSERT INTO temp_sgt_bisaccodes_2010 VALUES (
	'MED050000',
	'Ethics')  
INSERT INTO temp_sgt_bisaccodes_2010 VALUES (
	'MED112000',
	'Evidence-Based Medicine')   
INSERT INTO temp_sgt_bisaccodes_2010 VALUES (
	'MED029000',
	'Family & General Practice') 
INSERT INTO temp_sgt_bisaccodes_2010 VALUES (
	'MED030000',
	'Forensic Medicine')   
INSERT INTO temp_sgt_bisaccodes_2010 VALUES (
	'MED031000',
	'Gastroenterology') 
INSERT INTO temp_sgt_bisaccodes_2010 VALUES (
	'MED107000',
	'Genetics')  
INSERT INTO temp_sgt_bisaccodes_2010 VALUES (
	'MED032000',
	'Geriatrics ')  
INSERT INTO temp_sgt_bisaccodes_2010 VALUES (
	'MED033000',
	'Gynecology & Obstetrics')   
INSERT INTO temp_sgt_bisaccodes_2010 VALUES (
	'MED034000',
	'Healing') 
INSERT INTO temp_sgt_bisaccodes_2010 VALUES (
	'MED035000',
	'Health Care Delivery') 
INSERT INTO temp_sgt_bisaccodes_2010 VALUES (
	'MED036000',
	'Health Policy')  
INSERT INTO temp_sgt_bisaccodes_2010 VALUES (
	'MED037000',
	'Health Risk Assessment') 
INSERT INTO temp_sgt_bisaccodes_2010 VALUES (
	'MED038000',
	'Hematology ')  
INSERT INTO temp_sgt_bisaccodes_2010 VALUES (
	'MED110000',
	'Histology') 
INSERT INTO temp_sgt_bisaccodes_2010 VALUES (
	'MED039000',
	'History') 
INSERT INTO temp_sgt_bisaccodes_2010 VALUES (
	'MED040000',
	'Holistic Medicine')   
INSERT INTO temp_sgt_bisaccodes_2010 VALUES (
	'MED041000',
	'Home Care') 
INSERT INTO temp_sgt_bisaccodes_2010 VALUES (
	'MED043000',
	'Hospital Administration & Care')  
INSERT INTO temp_sgt_bisaccodes_2010 VALUES (
	'MED044000',
	'Immunology ')  
INSERT INTO temp_sgt_bisaccodes_2010 VALUES (
	'MED022090',
	'Infectious Diseases')  
INSERT INTO temp_sgt_bisaccodes_2010 VALUES (
	'MED108000',
	'Instruments & Supplies') 
INSERT INTO temp_sgt_bisaccodes_2010 VALUES (
	'MED045000',
	'Internal Medicine')   
INSERT INTO temp_sgt_bisaccodes_2010 VALUES (
	'MED047000',
	'Laboratory Medicine')  
INSERT INTO temp_sgt_bisaccodes_2010 VALUES (
	'MED048000',
	'Lasers in Medicine')  
INSERT INTO temp_sgt_bisaccodes_2010 VALUES (
	'MED113000',
	'Long-Term Care') 
INSERT INTO temp_sgt_bisaccodes_2010 VALUES (
	'MED049000',
	'Medicaid & Medicare')  
INSERT INTO temp_sgt_bisaccodes_2010 VALUES (
	'MED051000',
	'Medical History & Records') 
INSERT INTO temp_sgt_bisaccodes_2010 VALUES (
	'MED102000',
	'Mental Health')  
INSERT INTO temp_sgt_bisaccodes_2010 VALUES (
	'MED052000',
	'Microbiology') 
INSERT INTO temp_sgt_bisaccodes_2010 VALUES (
	'MED055000',
	'Nephrology ')  
INSERT INTO temp_sgt_bisaccodes_2010 VALUES (
	'MED056000',
	'Neurology') 
INSERT INTO temp_sgt_bisaccodes_2010 VALUES (
	'MED057000',
	'Neuroscience') 
INSERT INTO temp_sgt_bisaccodes_2010 VALUES (
	'MED091000',
	'Nosology')  
INSERT INTO temp_sgt_bisaccodes_2010 VALUES (
	'MED058000',
	'Nursing / General')   
INSERT INTO temp_sgt_bisaccodes_2010 VALUES (
	'MED058010',
	'Nursing / Anesthesia') 
INSERT INTO temp_sgt_bisaccodes_2010 VALUES (
	'MED058020',
	'Nursing / Assessment & Diagnosis')  
INSERT INTO temp_sgt_bisaccodes_2010 VALUES (
	'MED058030',
	'Nursing / Critical & Intensive Care  ') 
INSERT INTO temp_sgt_bisaccodes_2010 VALUES (
	'MED058040',
	'Nursing / Emergency')  
INSERT INTO temp_sgt_bisaccodes_2010 VALUES (
	'MED058050',
	'Nursing / Fundamentals & Skills') 
INSERT INTO temp_sgt_bisaccodes_2010 VALUES (
	'MED058060',
	'Nursing / Gerontology')  
INSERT INTO temp_sgt_bisaccodes_2010 VALUES (
	'MED058070',
	'Nursing / Home & Community Care') 
INSERT INTO temp_sgt_bisaccodes_2010 VALUES (
	'MED058090',
	'Nursing / Issues') 
INSERT INTO temp_sgt_bisaccodes_2010 VALUES (
	'MED058100',
	'Nursing / LPN & LVN')  
INSERT INTO temp_sgt_bisaccodes_2010 VALUES (
	'MED058110',
	'Nursing / Management & Leadership') 
INSERT INTO temp_sgt_bisaccodes_2010 VALUES (
	'MED058120',
	'Nursing / Maternity, Perinatal, Women''s Health')  
INSERT INTO temp_sgt_bisaccodes_2010 VALUES (
	'MED058220',
	'Nursing / Medical & Surgical') 
INSERT INTO temp_sgt_bisaccodes_2010 VALUES (
	'MED058130',
	'Nursing / Mental Health')   
INSERT INTO temp_sgt_bisaccodes_2010 VALUES (
	'MED058140',
	'Nursing / Nurse & Patient') 
INSERT INTO temp_sgt_bisaccodes_2010 VALUES (
	'MED058150',
	'Nursing / Nutrition')  
INSERT INTO temp_sgt_bisaccodes_2010 VALUES (
	'MED058160',
	'Nursing / Oncology & Cancer') 
INSERT INTO temp_sgt_bisaccodes_2010 VALUES (
	'MED058080',
	'Nursing / Pediatric & Neonatal')  
INSERT INTO temp_sgt_bisaccodes_2010 VALUES (
	'MED058170',
	'Nursing / Pharmacology') 
INSERT INTO temp_sgt_bisaccodes_2010 VALUES (
	'MED058180',
	'Nursing / Psychiatric')  
INSERT INTO temp_sgt_bisaccodes_2010 VALUES (
	'MED058190',
	'Nursing / Reference')  
INSERT INTO temp_sgt_bisaccodes_2010 VALUES (
	'MED058200',
	'Nursing / Research & Theory') 
INSERT INTO temp_sgt_bisaccodes_2010 VALUES (
	'MED058210',
	'Nursing / Test Preparation & Review  ') 
INSERT INTO temp_sgt_bisaccodes_2010 VALUES (
	'MED059000',
	'Nursing Home Care')   
INSERT INTO temp_sgt_bisaccodes_2010 VALUES (
	'MED060000',
	'Nutrition') 
INSERT INTO temp_sgt_bisaccodes_2010 VALUES (
	'MED061000',
	'Occupational & Industrial Medicine   ') 
INSERT INTO temp_sgt_bisaccodes_2010 VALUES (
	'MED062000',
	'Oncology')  
INSERT INTO temp_sgt_bisaccodes_2010 VALUES (
	'MED063000',
	'Ophthalmology')  
INSERT INTO temp_sgt_bisaccodes_2010 VALUES (
	'MED064000',
	'Optometry') 
INSERT INTO temp_sgt_bisaccodes_2010 VALUES (
	'MED065000',
	'Orthopedics')  
INSERT INTO temp_sgt_bisaccodes_2010 VALUES (
	'MED092000',
	'Osteopathy ')  
INSERT INTO temp_sgt_bisaccodes_2010 VALUES (
	'MED066000',
	'Otorhinolaryngology')  
INSERT INTO temp_sgt_bisaccodes_2010 VALUES (
	'MED093000',
	'Pain Medicine')  
INSERT INTO temp_sgt_bisaccodes_2010 VALUES (
	'MED103000',
	'Parasitology') 
INSERT INTO temp_sgt_bisaccodes_2010 VALUES (
	'MED067000',
	'Pathology') 
INSERT INTO temp_sgt_bisaccodes_2010 VALUES (
	'MED068000',
	'Pathophysiology')  
INSERT INTO temp_sgt_bisaccodes_2010 VALUES (
	'MED094000',
	'Pediatric Emergencies')  
INSERT INTO temp_sgt_bisaccodes_2010 VALUES (
	'MED069000',
	'Pediatrics ')  
INSERT INTO temp_sgt_bisaccodes_2010 VALUES (
	'MED070000',
	'Perinatology & Neonatology')  
INSERT INTO temp_sgt_bisaccodes_2010 VALUES (
	'MED071000',
	'Pharmacology') 
INSERT INTO temp_sgt_bisaccodes_2010 VALUES (
	'MED072000',
	'Pharmacy')  
INSERT INTO temp_sgt_bisaccodes_2010 VALUES (
	'MED073000',
	'Physical Medicine & Rehabilitation   ') 
INSERT INTO temp_sgt_bisaccodes_2010 VALUES (
	'MED074000',
	'Physician & Patient')  
INSERT INTO temp_sgt_bisaccodes_2010 VALUES (
	'MED104000',
	'Physicians ')  
INSERT INTO temp_sgt_bisaccodes_2010 VALUES (
	'MED075000',
	'Physiology ')  
INSERT INTO temp_sgt_bisaccodes_2010 VALUES (
	'MED100000',
	'Podiatry')  
INSERT INTO temp_sgt_bisaccodes_2010 VALUES (
	'MED095000',
	'Practice Management & Reimbursement  ') 
INSERT INTO temp_sgt_bisaccodes_2010 VALUES (
	'MED076000',
	'Preventive Medicine')  
INSERT INTO temp_sgt_bisaccodes_2010 VALUES (
	'MED077000',
	'Prosthesis ')  
INSERT INTO temp_sgt_bisaccodes_2010 VALUES (
	'MED105000',
	'Psychiatry / General') 
INSERT INTO temp_sgt_bisaccodes_2010 VALUES (
	'MED105010',
	'Psychiatry / Child & Adolescent') 
INSERT INTO temp_sgt_bisaccodes_2010 VALUES (
	'MED105020',
	'Psychiatry / Psychopharmacology') 
INSERT INTO temp_sgt_bisaccodes_2010 VALUES (
	'MED078000',
	'Public Health')  
INSERT INTO temp_sgt_bisaccodes_2010 VALUES (
	'MED079000',
	'Pulmonary & Thoracic Medicine ')  
INSERT INTO temp_sgt_bisaccodes_2010 VALUES (
	'MED080000',
	'Radiology & Nuclear Medicine') 
INSERT INTO temp_sgt_bisaccodes_2010 VALUES (
	'MED081000',
	'Reference') 
INSERT INTO temp_sgt_bisaccodes_2010 VALUES (
	'MED082000',
	'Reproductive Medicine & Technology   ') 
INSERT INTO temp_sgt_bisaccodes_2010 VALUES (
	'MED106000',
	'Research')  
INSERT INTO temp_sgt_bisaccodes_2010 VALUES (
	'MED083000',
	'Rheumatology') 
INSERT INTO temp_sgt_bisaccodes_2010 VALUES (
	'MED084000',
	'Sports Medicine')  
INSERT INTO temp_sgt_bisaccodes_2010 VALUES (
	'MED085000',
	'Surgery / General')   
INSERT INTO temp_sgt_bisaccodes_2010 VALUES (
	'MED085060',
	'Surgery / Colon & Rectal')  
INSERT INTO temp_sgt_bisaccodes_2010 VALUES (
	'MED085010',
	'Surgery / Neurosurgery') 
INSERT INTO temp_sgt_bisaccodes_2010 VALUES (
	'MED085020',
	'Surgery / Oral & Maxillofacial')  
INSERT INTO temp_sgt_bisaccodes_2010 VALUES (
	'MED085030',
	'Surgery / Plastic & Cosmetic') 
INSERT INTO temp_sgt_bisaccodes_2010 VALUES (
	'MED085040',
	'Surgery / Thoracic')  
INSERT INTO temp_sgt_bisaccodes_2010 VALUES (
	'MED085050',
	'Surgery / Vascular')  
INSERT INTO temp_sgt_bisaccodes_2010 VALUES (
	'MED042000',
	'Terminal Care')  
INSERT INTO temp_sgt_bisaccodes_2010 VALUES (
	'MED086000',
	'Test Preparation & Review') 
INSERT INTO temp_sgt_bisaccodes_2010 VALUES (
	'MED096000',
	'Toxicology ')  
INSERT INTO temp_sgt_bisaccodes_2010 VALUES (
	'MED087000',
	'Transportation') 
INSERT INTO temp_sgt_bisaccodes_2010 VALUES (
	'MED097000',
	'Tropical Medicine')   
INSERT INTO temp_sgt_bisaccodes_2010 VALUES (
	'MED098000',
	'Ultrasonography')  
INSERT INTO temp_sgt_bisaccodes_2010 VALUES (
	'MED088000',
	'Urology') 
INSERT INTO temp_sgt_bisaccodes_2010 VALUES (
	'MED089000',
	'Veterinary Medicine / General ')  
INSERT INTO temp_sgt_bisaccodes_2010 VALUES (
	'MED089010',
	'Veterinary Medicine / Equine') 
INSERT INTO temp_sgt_bisaccodes_2010 VALUES (
	'MED089020',
	'Veterinary Medicine / Food Animal') 
INSERT INTO temp_sgt_bisaccodes_2010 VALUES (
	'MED089030',
	'Veterinary Medicine / Small Animal   ') 
INSERT INTO temp_sgt_bisaccodes_2010 VALUES (
	'MUS000000',
	'General') 
INSERT INTO temp_sgt_bisaccodes_2010 VALUES (
	'MUS004000',
	'Business Aspects') 
INSERT INTO temp_sgt_bisaccodes_2010 VALUES (
	'MUS012000',
	'Discography & Buyer''s Guides') 
INSERT INTO temp_sgt_bisaccodes_2010 VALUES (
	'MUS014000',
	'Ethnic')  
INSERT INTO temp_sgt_bisaccodes_2010 VALUES (
	'MUS015000',
	'Ethnomusicology')  
INSERT INTO temp_sgt_bisaccodes_2010 VALUES (
	'MUS049000',
	'Genres & Styles / General') 
INSERT INTO temp_sgt_bisaccodes_2010 VALUES (
	'MUS002000',
	'Genres & Styles / Ballet')  
INSERT INTO temp_sgt_bisaccodes_2010 VALUES (
	'MUS003000',
	'Genres & Styles / Blues')   
INSERT INTO temp_sgt_bisaccodes_2010 VALUES (
	'MUS005000',
	'Genres & Styles / Chamber') 
INSERT INTO temp_sgt_bisaccodes_2010 VALUES (
	'MUS026000',
	'Genres & Styles / Children''s') 
INSERT INTO temp_sgt_bisaccodes_2010 VALUES (
	'MUS051000',
	'Genres & Styles / Choral')  
INSERT INTO temp_sgt_bisaccodes_2010 VALUES (
	'MUS006000',
	'Genres & Styles / Classical') 
INSERT INTO temp_sgt_bisaccodes_2010 VALUES (
	'MUS010000',
	'Genres & Styles / Country & Bluegrass') 
INSERT INTO temp_sgt_bisaccodes_2010 VALUES (
	'MUS011000',
	'Genres & Styles / Dance')   
INSERT INTO temp_sgt_bisaccodes_2010 VALUES (
	'MUS013000',
	'Genres & Styles / Electronic') 
INSERT INTO temp_sgt_bisaccodes_2010 VALUES (
	'MUS017000',
	'Genres & Styles / Folk & Traditional ') 
INSERT INTO temp_sgt_bisaccodes_2010 VALUES (
	'MUS019000',
	'Genres & Styles / Heavy Metal ')  
INSERT INTO temp_sgt_bisaccodes_2010 VALUES (
	'MUS024000',
	'Genres & Styles / International') 
INSERT INTO temp_sgt_bisaccodes_2010 VALUES (
	'MUS025000',
	'Genres & Styles / Jazz') 
INSERT INTO temp_sgt_bisaccodes_2010 VALUES (
	'MUS036000',
	'Genres & Styles / Latin')   
INSERT INTO temp_sgt_bisaccodes_2010 VALUES (
	'MUS045000',
	'Genres & Styles / Military & Marches ') 
INSERT INTO temp_sgt_bisaccodes_2010 VALUES (
	'MUS046000',
	'Genres & Styles / Musicals')  
INSERT INTO temp_sgt_bisaccodes_2010 VALUES (
	'MUS027000',
	'Genres & Styles / New Age') 
INSERT INTO temp_sgt_bisaccodes_2010 VALUES (
	'MUS028000',
	'Genres & Styles / Opera')   
INSERT INTO temp_sgt_bisaccodes_2010 VALUES (
	'MUS029000',
	'Genres & Styles / Pop Vocal') 
INSERT INTO temp_sgt_bisaccodes_2010 VALUES (
	'MUS030000',
	'Genres & Styles / Punk') 
INSERT INTO temp_sgt_bisaccodes_2010 VALUES (
	'MUS031000',
	'Genres & Styles / Rap & Hip Hop') 
INSERT INTO temp_sgt_bisaccodes_2010 VALUES (
	'MUS047000',
	'Genres & Styles / Reggae')  
INSERT INTO temp_sgt_bisaccodes_2010 VALUES (
	'MUS035000',
	'Genres & Styles / Rock') 
INSERT INTO temp_sgt_bisaccodes_2010 VALUES (
	'MUS039000',
	'Genres & Styles / Soul & R ''n B') 
INSERT INTO temp_sgt_bisaccodes_2010 VALUES (
	'MUS020000',
	'History & Criticism')  
INSERT INTO temp_sgt_bisaccodes_2010 VALUES (
	'MUS050000',
	'Individual Composer & Musician')  
INSERT INTO temp_sgt_bisaccodes_2010 VALUES (
	'MUS022000',
	'Instruction & Study / General ')  
INSERT INTO temp_sgt_bisaccodes_2010 VALUES (
	'MUS001000',
	'Instruction & Study / Appreciation   ') 
INSERT INTO temp_sgt_bisaccodes_2010 VALUES (
	'MUS007000',
	'Instruction & Study / Composition') 
INSERT INTO temp_sgt_bisaccodes_2010 VALUES (
	'MUS008000',
	'Instruction & Study / Conducting')  
INSERT INTO temp_sgt_bisaccodes_2010 VALUES (
	'MUS016000',
	'Instruction & Study / Exercises') 
INSERT INTO temp_sgt_bisaccodes_2010 VALUES (
	'MUS038000',
	'Instruction & Study / Songwriting') 
INSERT INTO temp_sgt_bisaccodes_2010 VALUES (
	'MUS040000',
	'Instruction & Study / Techniques')  
INSERT INTO temp_sgt_bisaccodes_2010 VALUES (
	'MUS041000',
	'Instruction & Study / Theory') 
INSERT INTO temp_sgt_bisaccodes_2010 VALUES (
	'MUS042000',
	'Instruction & Study / Voice') 
INSERT INTO temp_sgt_bisaccodes_2010 VALUES (
	'MUS052000',
	'Lyrics')  
INSERT INTO temp_sgt_bisaccodes_2010 VALUES (
	'MUS023000',
	'Musical Instruments / General ')  
INSERT INTO temp_sgt_bisaccodes_2010 VALUES (
	'MUS023010',
	'Musical Instruments / Brass') 
INSERT INTO temp_sgt_bisaccodes_2010 VALUES (
	'MUS023060',
	'Musical Instruments / Guitar') 
INSERT INTO temp_sgt_bisaccodes_2010 VALUES (
	'MUS023020',
	'Musical Instruments / Percussion')  
INSERT INTO temp_sgt_bisaccodes_2010 VALUES (
	'MUS023030',
	'Musical Instruments / Piano & Keyboard') 
INSERT INTO temp_sgt_bisaccodes_2010 VALUES (
	'MUS023040',
	'Musical Instruments / Strings ')  
INSERT INTO temp_sgt_bisaccodes_2010 VALUES (
	'MUS023050',
	'Musical Instruments / Woodwinds') 
INSERT INTO temp_sgt_bisaccodes_2010 VALUES (
	'MUS037000',
	'Printed Music / General')   
INSERT INTO temp_sgt_bisaccodes_2010 VALUES (
	'MUS037010',
	'Printed Music / Artist Specific') 
INSERT INTO temp_sgt_bisaccodes_2010 VALUES (
	'MUS037020',
	'Printed Music / Band & Orchestra')  
INSERT INTO temp_sgt_bisaccodes_2010 VALUES (
	'MUS037030',
	'Printed Music / Choral') 
INSERT INTO temp_sgt_bisaccodes_2010 VALUES (
	'MUS037040',
	'Printed Music / Guitar & Fretted Instruments')  
INSERT INTO temp_sgt_bisaccodes_2010 VALUES (
	'MUS037050',
	'Printed Music / Mixed Collections') 
INSERT INTO temp_sgt_bisaccodes_2010 VALUES (
	'MUS037060',
	'Printed Music / Musicals, Film & TV  ') 
INSERT INTO temp_sgt_bisaccodes_2010 VALUES (
	'MUS037070',
	'Printed Music / Opera & Classical Scores ')  
INSERT INTO temp_sgt_bisaccodes_2010 VALUES (
	'MUS037080',
	'Printed Music / Percussion')  
INSERT INTO temp_sgt_bisaccodes_2010 VALUES (
	'MUS037090',
	'Printed Music / Piano & Keyboard Repertoire ')  
INSERT INTO temp_sgt_bisaccodes_2010 VALUES (
	'MUS037100',
	'Printed Music / Piano-Vocal-Guitar   ') 
INSERT INTO temp_sgt_bisaccodes_2010 VALUES (
	'MUS037110',
	'Printed Music / Vocal')  
INSERT INTO temp_sgt_bisaccodes_2010 VALUES (
	'MUS032000',
	'Recording & Reproduction')  
INSERT INTO temp_sgt_bisaccodes_2010 VALUES (
	'MUS033000',
	'Reference') 
INSERT INTO temp_sgt_bisaccodes_2010 VALUES (
	'MUS048000',
	'Religious / General')  
INSERT INTO temp_sgt_bisaccodes_2010 VALUES (
	'MUS048010',
	'Religious / Christian')  
INSERT INTO temp_sgt_bisaccodes_2010 VALUES (
	'MUS009000',
	'Religious / Contemporary Christian   ') 
INSERT INTO temp_sgt_bisaccodes_2010 VALUES (
	'MUS018000',
	'Religious / Gospel')  
INSERT INTO temp_sgt_bisaccodes_2010 VALUES (
	'MUS021000',
	'Religious / Hymns')   
INSERT INTO temp_sgt_bisaccodes_2010 VALUES (
	'MUS048020',
	'Religious / Jewish')  
INSERT INTO temp_sgt_bisaccodes_2010 VALUES (
	'MUS048030',
	'Religious / Muslim')  
INSERT INTO temp_sgt_bisaccodes_2010 VALUES (
	'NAT000000',
	'General') 
INSERT INTO temp_sgt_bisaccodes_2010 VALUES (
	'NAT039000',
	'Animal Rights')  
INSERT INTO temp_sgt_bisaccodes_2010 VALUES (
	'NAT001000',
	'Animals / General')   
INSERT INTO temp_sgt_bisaccodes_2010 VALUES (
	'NAT003000',
	'Animals / Bears')  
INSERT INTO temp_sgt_bisaccodes_2010 VALUES (
	'NAT042000',
	'Animals / Big Cats')  
INSERT INTO temp_sgt_bisaccodes_2010 VALUES (
	'NAT043000',
	'Animals / Birds')  
INSERT INTO temp_sgt_bisaccodes_2010 VALUES (
	'NAT005000',
	'Animals / Butterflies & Moths ')  
INSERT INTO temp_sgt_bisaccodes_2010 VALUES (
	'NAT007000',
	'Animals / Dinosaurs & Prehistoric Creatures ')  
INSERT INTO temp_sgt_bisaccodes_2010 VALUES (
	'NAT012000',
	'Animals / Fish') 
INSERT INTO temp_sgt_bisaccodes_2010 VALUES (
	'NAT016000',
	'Animals / Horses') 
INSERT INTO temp_sgt_bisaccodes_2010 VALUES (
	'NAT017000',
	'Animals / Insects & Spiders') 
INSERT INTO temp_sgt_bisaccodes_2010 VALUES (
	'NAT019000',
	'Animals / Mammals')   
INSERT INTO temp_sgt_bisaccodes_2010 VALUES (
	'NAT020000',
	'Animals / Marine Life')  
INSERT INTO temp_sgt_bisaccodes_2010 VALUES (
	'NAT002000',
	'Animals / Primates')  
INSERT INTO temp_sgt_bisaccodes_2010 VALUES (
	'NAT028000',
	'Animals / Reptiles & Amphibians') 
INSERT INTO temp_sgt_bisaccodes_2010 VALUES (
	'NAT037000',
	'Animals / Wildlife')  
INSERT INTO temp_sgt_bisaccodes_2010 VALUES (
	'NAT044000',
	'Animals / Wolves') 
INSERT INTO temp_sgt_bisaccodes_2010 VALUES (
	'NAT004000',
	'Birdwatching Guides')  
INSERT INTO temp_sgt_bisaccodes_2010 VALUES (
	'NAT009000',
	'Earthquakes & Volcanoes')   
INSERT INTO temp_sgt_bisaccodes_2010 VALUES (
	'NAT010000',
	'Ecology') 
INSERT INTO temp_sgt_bisaccodes_2010 VALUES (
	'NAT045000',
	'Ecosystems & Habitats / General') 
INSERT INTO temp_sgt_bisaccodes_2010 VALUES (
	'NAT045010',
	'Ecosystems & Habitats / Deserts') 
INSERT INTO temp_sgt_bisaccodes_2010 VALUES (
	'NAT014000',
	'Ecosystems & Habitats / Forests & Rainforests') 
INSERT INTO temp_sgt_bisaccodes_2010 VALUES (
	'NAT018000',
	'Ecosystems & Habitats / Lakes, Ponds & Swamps') 
INSERT INTO temp_sgt_bisaccodes_2010 VALUES (
	'NAT041000',
	'Ecosystems & Habitats / Mountains') 
INSERT INTO temp_sgt_bisaccodes_2010 VALUES (
	'NAT025000',
	'Ecosystems & Habitats / Oceans & Seas') 
INSERT INTO temp_sgt_bisaccodes_2010 VALUES (
	'NAT045020',
	'Ecosystems & Habitats / Plains & Prairies')  
INSERT INTO temp_sgt_bisaccodes_2010 VALUES (
	'NAT045030',
	'Ecosystems & Habitats / Polar Regions') 
INSERT INTO temp_sgt_bisaccodes_2010 VALUES (
	'NAT029000',
	'Ecosystems & Habitats / Rivers')  
INSERT INTO temp_sgt_bisaccodes_2010 VALUES (
	'NAT045040',
	'Ecosystems & Habitats / Wilderness   ') 
INSERT INTO temp_sgt_bisaccodes_2010 VALUES (
	'NAT046000',
	'Endangered Species')  
INSERT INTO temp_sgt_bisaccodes_2010 VALUES (
	'NAT011000',
	'Environmental Conservation & Protection  ')  
INSERT INTO temp_sgt_bisaccodes_2010 VALUES (
	'NAT024000',
	'Essays')  
INSERT INTO temp_sgt_bisaccodes_2010 VALUES (
	'NAT015000',
	'Fossils') 
INSERT INTO temp_sgt_bisaccodes_2010 VALUES (
	'NAT023000',
	'Natural Disasters')   
INSERT INTO temp_sgt_bisaccodes_2010 VALUES (
	'NAT038000',
	'Natural Resources')   
INSERT INTO temp_sgt_bisaccodes_2010 VALUES (
	'NAT026000',
	'Plants / General') 
INSERT INTO temp_sgt_bisaccodes_2010 VALUES (
	'NAT047000',
	'Plants / Aquatic') 
INSERT INTO temp_sgt_bisaccodes_2010 VALUES (
	'NAT048000',
	'Plants / Cacti & Succulents') 
INSERT INTO temp_sgt_bisaccodes_2010 VALUES (
	'NAT013000',
	'Plants / Flowers') 
INSERT INTO temp_sgt_bisaccodes_2010 VALUES (
	'NAT022000',
	'Plants / Mushrooms')  
INSERT INTO temp_sgt_bisaccodes_2010 VALUES (
	'NAT034000',
	'Plants / Trees') 
INSERT INTO temp_sgt_bisaccodes_2010 VALUES (
	'NAT027000',
	'Reference') 
INSERT INTO temp_sgt_bisaccodes_2010 VALUES (
	'NAT049000',
	'Regional')  
INSERT INTO temp_sgt_bisaccodes_2010 VALUES (
	'NAT030000',
	'Rocks & Minerals') 
INSERT INTO temp_sgt_bisaccodes_2010 VALUES (
	'NAT031000',
	'Seashells') 
INSERT INTO temp_sgt_bisaccodes_2010 VALUES (
	'NAT032000',
	'Seasons') 
INSERT INTO temp_sgt_bisaccodes_2010 VALUES (
	'NAT033000',
	'Sky Observation')  
INSERT INTO temp_sgt_bisaccodes_2010 VALUES (
	'NAT036000',
	'Weather') 
INSERT INTO temp_sgt_bisaccodes_2010 VALUES (
	'PER000000',
	'General') 
INSERT INTO temp_sgt_bisaccodes_2010 VALUES (
	'PER001000',
	'Acting & Auditioning') 
INSERT INTO temp_sgt_bisaccodes_2010 VALUES (
	'PER017000',
	'Animation') 
INSERT INTO temp_sgt_bisaccodes_2010 VALUES (
	'PER014000',
	'Business Aspects') 
INSERT INTO temp_sgt_bisaccodes_2010 VALUES (
	'PER002000',
	'Circus')  
INSERT INTO temp_sgt_bisaccodes_2010 VALUES (
	'PER015000',
	'Comedy')  
INSERT INTO temp_sgt_bisaccodes_2010 VALUES (
	'PER003000',
	'Dance / General')  
INSERT INTO temp_sgt_bisaccodes_2010 VALUES (
	'PER003010',
	'Dance / Classical & Ballet')  
INSERT INTO temp_sgt_bisaccodes_2010 VALUES (
	'PER003020',
	'Dance / Folk') 
INSERT INTO temp_sgt_bisaccodes_2010 VALUES (
	'PER003030',
	'Dance / Jazz') 
INSERT INTO temp_sgt_bisaccodes_2010 VALUES (
	'PER003040',
	'Dance / Modern') 
INSERT INTO temp_sgt_bisaccodes_2010 VALUES (
	'PER003050',
	'Dance / Notation') 
INSERT INTO temp_sgt_bisaccodes_2010 VALUES (
	'PER003060',
	'Dance / Popular')  
INSERT INTO temp_sgt_bisaccodes_2010 VALUES (
	'PER003070',
	'Dance / Reference')   
INSERT INTO temp_sgt_bisaccodes_2010 VALUES (
	'PER003080',
	'Dance / Tap')  
INSERT INTO temp_sgt_bisaccodes_2010 VALUES (
	'PER004000',
	'Film & Video / General') 
INSERT INTO temp_sgt_bisaccodes_2010 VALUES (
	'PER004010',
	'Film & Video / Direction & Production') 
INSERT INTO temp_sgt_bisaccodes_2010 VALUES (
	'PER004020',
	'Film & Video / Guides & Reviews') 
INSERT INTO temp_sgt_bisaccodes_2010 VALUES (
	'PER004030',
	'Film & Video / History & Criticism   ') 
INSERT INTO temp_sgt_bisaccodes_2010 VALUES (
	'PER004040',
	'Film & Video / Reference')  
INSERT INTO temp_sgt_bisaccodes_2010 VALUES (
	'PER004050',
	'Film & Video / Screenwriting') 
INSERT INTO temp_sgt_bisaccodes_2010 VALUES (
	'PER018000',
	'Individual Director (see also BIOGRAPHY & AUTOBIOGRAPHY / Entertainment & Performing Arts)') 
INSERT INTO temp_sgt_bisaccodes_2010 VALUES (
	'PER007000',
	'Puppets & Puppetry')  
INSERT INTO temp_sgt_bisaccodes_2010 VALUES (
	'PER008000',
	'Radio / General')  
INSERT INTO temp_sgt_bisaccodes_2010 VALUES (
	'PER008010',
	'Radio / History & Criticism') 
INSERT INTO temp_sgt_bisaccodes_2010 VALUES (
	'PER008020',
	'Radio / Reference')   
INSERT INTO temp_sgt_bisaccodes_2010 VALUES (
	'PER009000',
	'Reference') 
INSERT INTO temp_sgt_bisaccodes_2010 VALUES (
	'PER016000',
	'Screenplays')  
INSERT INTO temp_sgt_bisaccodes_2010 VALUES (
	'PER019000',
	'Storytelling') 
INSERT INTO temp_sgt_bisaccodes_2010 VALUES (
	'PER010000',
	'Television / General') 
INSERT INTO temp_sgt_bisaccodes_2010 VALUES (
	'PER010010',
	'Television / Direction & Production  ') 
INSERT INTO temp_sgt_bisaccodes_2010 VALUES (
	'PER010020',
	'Television / Guides & Reviews ')  
INSERT INTO temp_sgt_bisaccodes_2010 VALUES (
	'PER010030',
	'Television / History & Criticism')  
INSERT INTO temp_sgt_bisaccodes_2010 VALUES (
	'PER010040',
	'Television / Reference') 
INSERT INTO temp_sgt_bisaccodes_2010 VALUES (
	'PER010050',
	'Television / Screenwriting')  
INSERT INTO temp_sgt_bisaccodes_2010 VALUES (
	'PER011000',
	'Theater / General')   
INSERT INTO temp_sgt_bisaccodes_2010 VALUES (
	'PER013000',
	'Theater / Broadway & Musical Revue   ') 
INSERT INTO temp_sgt_bisaccodes_2010 VALUES (
	'PER011010',
	'Theater / Direction & Production')  
INSERT INTO temp_sgt_bisaccodes_2010 VALUES (
	'PER011020',
	'Theater / History & Criticism ')  
INSERT INTO temp_sgt_bisaccodes_2010 VALUES (
	'PER006000',
	'Theater / Miming') 
INSERT INTO temp_sgt_bisaccodes_2010 VALUES (
	'PER011030',
	'Theater / Playwriting')  
INSERT INTO temp_sgt_bisaccodes_2010 VALUES (
	'PER011040',
	'Theater / Stagecraft') 
INSERT INTO temp_sgt_bisaccodes_2010 VALUES (
	'PET000000',
	'General') 
INSERT INTO temp_sgt_bisaccodes_2010 VALUES (
	'PET002000',
	'Birds') 
INSERT INTO temp_sgt_bisaccodes_2010 VALUES (
	'PET003000',
	'Cats / General') 
INSERT INTO temp_sgt_bisaccodes_2010 VALUES (
	'PET003010',
	'Cats / Breeds')  
INSERT INTO temp_sgt_bisaccodes_2010 VALUES (
	'PET004000',
	'Dogs / General') 
INSERT INTO temp_sgt_bisaccodes_2010 VALUES (
	'PET004010',
	'Dogs / Breeds')  
INSERT INTO temp_sgt_bisaccodes_2010 VALUES (
	'PET004020',
	'Dogs / Training')  
INSERT INTO temp_sgt_bisaccodes_2010 VALUES (
	'PET010000',
	'Essays')  
INSERT INTO temp_sgt_bisaccodes_2010 VALUES (
	'PET005000',
	'Fish & Aquariums') 
INSERT INTO temp_sgt_bisaccodes_2010 VALUES (
	'PET006000',
	'Horses / General') 
INSERT INTO temp_sgt_bisaccodes_2010 VALUES (
	'PET006010',
	'Horses / Riding')  
INSERT INTO temp_sgt_bisaccodes_2010 VALUES (
	'PET011000',
	'Rabbits, Mice, Hamsters, Guinea Pigs, etc.') 
INSERT INTO temp_sgt_bisaccodes_2010 VALUES (
	'PET008000',
	'Reference') 
INSERT INTO temp_sgt_bisaccodes_2010 VALUES (
	'PET009000',
	'Reptiles, Amphibians & Terrariums') 
INSERT INTO temp_sgt_bisaccodes_2010 VALUES (
	'PHI000000',
	'General') 
INSERT INTO temp_sgt_bisaccodes_2010 VALUES (
	'PHI001000',
	'Aesthetics ')  
INSERT INTO temp_sgt_bisaccodes_2010 VALUES (
	'PHI028000',
	'Buddhist')  
INSERT INTO temp_sgt_bisaccodes_2010 VALUES (
	'PHI026000',
	'Criticism') 
INSERT INTO temp_sgt_bisaccodes_2010 VALUES (
	'PHI003000',
	'Eastern') 
INSERT INTO temp_sgt_bisaccodes_2010 VALUES (
	'PHI004000',
	'Epistemology') 
INSERT INTO temp_sgt_bisaccodes_2010 VALUES (
	'PHI035000',
	'Essays')  
INSERT INTO temp_sgt_bisaccodes_2010 VALUES (
	'PHI005000',
	'Ethics & Moral Philosophy') 
INSERT INTO temp_sgt_bisaccodes_2010 VALUES (
	'PHI007000',
	'Free Will & Determinism')   
INSERT INTO temp_sgt_bisaccodes_2010 VALUES (
	'PHI008000',
	'Good & Evil')  
INSERT INTO temp_sgt_bisaccodes_2010 VALUES (
	'PHI033000',
	'Hindu') 
INSERT INTO temp_sgt_bisaccodes_2010 VALUES (
	'PHI009000',
	'History & Surveys / General') 
INSERT INTO temp_sgt_bisaccodes_2010 VALUES (
	'PHI002000',
	'History & Surveys / Ancient & Classical  ')  
INSERT INTO temp_sgt_bisaccodes_2010 VALUES (
	'PHI012000',
	'History & Surveys / Medieval') 
INSERT INTO temp_sgt_bisaccodes_2010 VALUES (
	'PHI016000',
	'History & Surveys / Modern')  
INSERT INTO temp_sgt_bisaccodes_2010 VALUES (
	'PHI011000',
	'Logic') 
INSERT INTO temp_sgt_bisaccodes_2010 VALUES (
	'PHI013000',
	'Metaphysics')  
INSERT INTO temp_sgt_bisaccodes_2010 VALUES (
	'PHI014000',
	'Methodology')  
INSERT INTO temp_sgt_bisaccodes_2010 VALUES (
	'PHI015000',
	'Mind & Body')  
INSERT INTO temp_sgt_bisaccodes_2010 VALUES (
	'PHI031000',
	'Movements / General')  
INSERT INTO temp_sgt_bisaccodes_2010 VALUES (
	'PHI027000',
	'Movements / Deconstruction')  
INSERT INTO temp_sgt_bisaccodes_2010 VALUES (
	'PHI006000',
	'Movements / Existentialism')  
INSERT INTO temp_sgt_bisaccodes_2010 VALUES (
	'PHI010000',
	'Movements / Humanism') 
INSERT INTO temp_sgt_bisaccodes_2010 VALUES (
	'PHI018000',
	'Movements / Phenomenology') 
INSERT INTO temp_sgt_bisaccodes_2010 VALUES (
	'PHI020000',
	'Movements / Pragmatism') 
INSERT INTO temp_sgt_bisaccodes_2010 VALUES (
	'PHI032000',
	'Movements / Rationalism')   
INSERT INTO temp_sgt_bisaccodes_2010 VALUES (
	'PHI029000',
	'Movements / Structuralism') 
INSERT INTO temp_sgt_bisaccodes_2010 VALUES (
	'PHI030000',
	'Movements / Utilitarianism')  
INSERT INTO temp_sgt_bisaccodes_2010 VALUES (
	'PHI019000',
	'Political') 
INSERT INTO temp_sgt_bisaccodes_2010 VALUES (
	'PHI021000',
	'Reference') 
INSERT INTO temp_sgt_bisaccodes_2010 VALUES (
	'PHI022000',
	'Religious') 
INSERT INTO temp_sgt_bisaccodes_2010 VALUES (
	'PHI034000',
	'Social')  
INSERT INTO temp_sgt_bisaccodes_2010 VALUES (
	'PHI023000',
	'Taoist')  
INSERT INTO temp_sgt_bisaccodes_2010 VALUES (
	'PHI025000',
	'Zen') 
INSERT INTO temp_sgt_bisaccodes_2010 VALUES (
	'PHO000000',
	'General') 
INSERT INTO temp_sgt_bisaccodes_2010 VALUES (
	'PHO025000',
	'Annuals') 
INSERT INTO temp_sgt_bisaccodes_2010 VALUES (
	'PHO003000',
	'Business Aspects') 
INSERT INTO temp_sgt_bisaccodes_2010 VALUES (
	'PHO004000',
	'Collections, Catalogs, Exhibitions / General')  
INSERT INTO temp_sgt_bisaccodes_2010 VALUES (
	'PHO004010',
	'Collections, Catalogs, Exhibitions / Group Shows')  
INSERT INTO temp_sgt_bisaccodes_2010 VALUES (
	'PHO004020',
	'Collections, Catalogs, Exhibitions / Permanent Collections') 
INSERT INTO temp_sgt_bisaccodes_2010 VALUES (
	'PHO021000',
	'Commercial ')  
INSERT INTO temp_sgt_bisaccodes_2010 VALUES (
	'PHO005000',
	'Criticism') 
INSERT INTO temp_sgt_bisaccodes_2010 VALUES (
	'PHO010000',
	'History') 
INSERT INTO temp_sgt_bisaccodes_2010 VALUES (
	'PHO011000',
	'Individual Photographers / General   ') 
INSERT INTO temp_sgt_bisaccodes_2010 VALUES (
	'PHO011010',
	'Individual Photographers / Artists'' Books')  
INSERT INTO temp_sgt_bisaccodes_2010 VALUES (
	'PHO011020',
	'Individual Photographers / Essays') 
INSERT INTO temp_sgt_bisaccodes_2010 VALUES (
	'PHO011030',
	'Individual Photographers / Monographs') 
INSERT INTO temp_sgt_bisaccodes_2010 VALUES (
	'PHO014000',
	'Photoessays & Documentaries') 
INSERT INTO temp_sgt_bisaccodes_2010 VALUES (
	'PHO015000',
	'Photojournalism')  
INSERT INTO temp_sgt_bisaccodes_2010 VALUES (
	'PHO017000',
	'Reference') 
INSERT INTO temp_sgt_bisaccodes_2010 VALUES (
	'PHO023000',
	'Subjects & Themes / General') 
INSERT INTO temp_sgt_bisaccodes_2010 VALUES (
	'PHO023010',
	'Subjects & Themes / Aerial')  
INSERT INTO temp_sgt_bisaccodes_2010 VALUES (
	'PHO001000',
	'Subjects & Themes / Architectural & Industrial')  
INSERT INTO temp_sgt_bisaccodes_2010 VALUES (
	'PHO023070',
	'Subjects & Themes / Celebrations & Events')  
INSERT INTO temp_sgt_bisaccodes_2010 VALUES (
	'PHO023080',
	'Subjects & Themes / Celebrity ')  
INSERT INTO temp_sgt_bisaccodes_2010 VALUES (
	'PHO023020',
	'Subjects & Themes / Children') 
INSERT INTO temp_sgt_bisaccodes_2010 VALUES (
	'PHO023030',
	'Subjects & Themes / Erotica') 
INSERT INTO temp_sgt_bisaccodes_2010 VALUES (
	'PHO009000',
	'Subjects & Themes / Fashion') 
INSERT INTO temp_sgt_bisaccodes_2010 VALUES (
	'PHO023100',
	'Subjects & Themes / Historical')  
INSERT INTO temp_sgt_bisaccodes_2010 VALUES (
	'PHO023040',
	'Subjects & Themes / Landscapes')  
INSERT INTO temp_sgt_bisaccodes_2010 VALUES (
	'PHO023090',
	'Subjects & Themes / Lifestyles')  
INSERT INTO temp_sgt_bisaccodes_2010 VALUES (
	'PHO023050',
	'Subjects & Themes / Nudes') 
INSERT INTO temp_sgt_bisaccodes_2010 VALUES (
	'PHO013000',
	'Subjects & Themes / Plants & Animals ') 
INSERT INTO temp_sgt_bisaccodes_2010 VALUES (
	'PHO016000',
	'Subjects & Themes / Portraits ')  
INSERT INTO temp_sgt_bisaccodes_2010 VALUES (
	'PHO019000',
	'Subjects & Themes / Regional (see also TRAVEL / Pictorials)  ')  
INSERT INTO temp_sgt_bisaccodes_2010 VALUES (
	'PHO023060',
	'Subjects & Themes / Sports')  
INSERT INTO temp_sgt_bisaccodes_2010 VALUES (
	'PHO018000',
	'Techniques / General') 
INSERT INTO temp_sgt_bisaccodes_2010 VALUES (
	'PHO022000',
	'Techniques / Cinematography & Videography')  
INSERT INTO temp_sgt_bisaccodes_2010 VALUES (
	'PHO020000',
	'Techniques / Color')  
INSERT INTO temp_sgt_bisaccodes_2010 VALUES (
	'PHO006000',
	'Techniques / Darkroom')  
INSERT INTO temp_sgt_bisaccodes_2010 VALUES (
	'PHO024000',
	'Techniques / Digital (see also COMPUTERS / Digital Media / Photography) ')  
INSERT INTO temp_sgt_bisaccodes_2010 VALUES (
	'PHO007000',
	'Techniques / Equipment') 
INSERT INTO temp_sgt_bisaccodes_2010 VALUES (
	'PHO012000',
	'Techniques / Lighting')  
INSERT INTO temp_sgt_bisaccodes_2010 VALUES (
	'POE000000',
	'General') 
INSERT INTO temp_sgt_bisaccodes_2010 VALUES (
	'POE007000',
	'African') 
INSERT INTO temp_sgt_bisaccodes_2010 VALUES (
	'POE005010',
	'American / General')  
INSERT INTO temp_sgt_bisaccodes_2010 VALUES (
	'POE005050',
	'American / African American') 
INSERT INTO temp_sgt_bisaccodes_2010 VALUES (
	'POE005060',
	'American / Asian American') 
INSERT INTO temp_sgt_bisaccodes_2010 VALUES (
	'POE005070',
	'American / Hispanic American') 
INSERT INTO temp_sgt_bisaccodes_2010 VALUES (
	'POE008000',
	'Ancient, Classical & Medieval ')  
INSERT INTO temp_sgt_bisaccodes_2010 VALUES (
	'POE001000',
	'Anthologies (multiple authors)')  
INSERT INTO temp_sgt_bisaccodes_2010 VALUES (
	'POE009000',
	'Asian') 
INSERT INTO temp_sgt_bisaccodes_2010 VALUES (
	'POE010000',
	'Australian & Oceanian')  
INSERT INTO temp_sgt_bisaccodes_2010 VALUES (
	'POE011000',
	'Canadian')  
INSERT INTO temp_sgt_bisaccodes_2010 VALUES (
	'POE012000',
	'Caribbean & Latin American')  
INSERT INTO temp_sgt_bisaccodes_2010 VALUES (
	'POE005030',
	'Continental European') 
INSERT INTO temp_sgt_bisaccodes_2010 VALUES (
	'POE005020',
	'English, Irish, Scottish, Welsh') 
INSERT INTO temp_sgt_bisaccodes_2010 VALUES (
	'POE014000',
	'Epic')  
INSERT INTO temp_sgt_bisaccodes_2010 VALUES (
	'POE003000',
	'Inspirational & Religious') 
INSERT INTO temp_sgt_bisaccodes_2010 VALUES (
	'POE013000',
	'Middle Eastern') 
INSERT INTO temp_sgt_bisaccodes_2010 VALUES (
	'POE015000',
	'Native American')  
INSERT INTO temp_sgt_bisaccodes_2010 VALUES (
	'POE016000',
	'Russian & Former Soviet Union ')  
INSERT INTO temp_sgt_bisaccodes_2010 VALUES (
	'POL000000',
	'General') 
INSERT INTO temp_sgt_bisaccodes_2010 VALUES (
	'POL039000',
	'Censorship ')  
INSERT INTO temp_sgt_bisaccodes_2010 VALUES (
	'POL003000',
	'Civics & Citizenship') 
INSERT INTO temp_sgt_bisaccodes_2010 VALUES (
	'POL045000',
	'Colonialism & Post-Colonialism')  
INSERT INTO temp_sgt_bisaccodes_2010 VALUES (
	'POL022000',
	'Constitutions')  
INSERT INTO temp_sgt_bisaccodes_2010 VALUES (
	'POL023000',
	'Economic Conditions')  
INSERT INTO temp_sgt_bisaccodes_2010 VALUES (
	'POL032000',
	'Essays')  
INSERT INTO temp_sgt_bisaccodes_2010 VALUES (
	'POL033000',
	'Globalization')  
INSERT INTO temp_sgt_bisaccodes_2010 VALUES (
	'POL040000',
	'Government / General') 
INSERT INTO temp_sgt_bisaccodes_2010 VALUES (
	'POL009000',
	'Government / Comparative')  
INSERT INTO temp_sgt_bisaccodes_2010 VALUES (
	'POL040010',
	'Government / Executive Branch ')  
INSERT INTO temp_sgt_bisaccodes_2010 VALUES (
	'POL040020',
	'Government / International')  
INSERT INTO temp_sgt_bisaccodes_2010 VALUES (
	'POL040030',
	'Government / Judicial Branch') 
INSERT INTO temp_sgt_bisaccodes_2010 VALUES (
	'POL006000',
	'Government / Legislative Branch') 
INSERT INTO temp_sgt_bisaccodes_2010 VALUES (
	'POL040040',
	'Government / Local')  
INSERT INTO temp_sgt_bisaccodes_2010 VALUES (
	'POL030000',
	'Government / National')  
INSERT INTO temp_sgt_bisaccodes_2010 VALUES (
	'POL020000',
	'Government / State & Provincial') 
INSERT INTO temp_sgt_bisaccodes_2010 VALUES (
	'POL010000',
	'History & Theory') 
INSERT INTO temp_sgt_bisaccodes_2010 VALUES (
	'POL011000',
	'International Relations / General') 
INSERT INTO temp_sgt_bisaccodes_2010 VALUES (
	'POL001000',
	'International Relations / Arms Control') 
INSERT INTO temp_sgt_bisaccodes_2010 VALUES (
	'POL011010',
	'International Relations / Diplomacy  ') 
INSERT INTO temp_sgt_bisaccodes_2010 VALUES (
	'POL011020',
	'International Relations / Trade & Tariffs')  
INSERT INTO temp_sgt_bisaccodes_2010 VALUES (
	'POL021000',
	'International Relations / Treaties   ') 
INSERT INTO temp_sgt_bisaccodes_2010 VALUES (
	'POL013000',
	'Labor & Industrial Relations') 
INSERT INTO temp_sgt_bisaccodes_2010 VALUES (
	'POL041000',
	'NGOs (Non-Governmental Organizations)') 
INSERT INTO temp_sgt_bisaccodes_2010 VALUES (
	'POL034000',
	'Peace') 
INSERT INTO temp_sgt_bisaccodes_2010 VALUES (
	'POL035000',
	'Political Freedom & Security / General') 
INSERT INTO temp_sgt_bisaccodes_2010 VALUES (
	'POL004000',
	'Political Freedom & Security / Civil Rights ')  
INSERT INTO temp_sgt_bisaccodes_2010 VALUES (
	'POL035010',
	'Political Freedom & Security / Human Rights ')  
INSERT INTO temp_sgt_bisaccodes_2010 VALUES (
	'POL036000',
	'Political Freedom & Security / Intelligence ')  
INSERT INTO temp_sgt_bisaccodes_2010 VALUES (
	'POL012000',
	'Political Freedom & Security / International Security    ') 
INSERT INTO temp_sgt_bisaccodes_2010 VALUES (
	'POL014000',
	'Political Freedom & Security / Law Enforcement')  
INSERT INTO temp_sgt_bisaccodes_2010 VALUES (
	'POL037000',
	'Political Freedom & Security / Terrorism ')  
INSERT INTO temp_sgt_bisaccodes_2010 VALUES (
	'POL042000',
	'Political Ideologies / General')  
INSERT INTO temp_sgt_bisaccodes_2010 VALUES (
	'POL042010',
	'Political Ideologies / Anarchism')  
INSERT INTO temp_sgt_bisaccodes_2010 VALUES (
	'POL005000',
	'Political Ideologies / Communism & Socialism')  
INSERT INTO temp_sgt_bisaccodes_2010 VALUES (
	'POL042020',
	'Political Ideologies / Conservatism & Liberalism')  
INSERT INTO temp_sgt_bisaccodes_2010 VALUES (
	'POL007000',
	'Political Ideologies / Democracy')  
INSERT INTO temp_sgt_bisaccodes_2010 VALUES (
	'POL042030',
	'Political Ideologies / Fascism & Totalitarianism')  
INSERT INTO temp_sgt_bisaccodes_2010 VALUES (
	'POL031000',
	'Political Ideologies / Nationalism   ') 
INSERT INTO temp_sgt_bisaccodes_2010 VALUES (
	'POL016000',
	'Political Process / General') 
INSERT INTO temp_sgt_bisaccodes_2010 VALUES (
	'POL008000',
	'Political Process / Elections ')  
INSERT INTO temp_sgt_bisaccodes_2010 VALUES (
	'POL025000',
	'Political Process / Leadership')  
INSERT INTO temp_sgt_bisaccodes_2010 VALUES (
	'POL043000',
	'Political Process / Political Advocacy') 
INSERT INTO temp_sgt_bisaccodes_2010 VALUES (
	'POL015000',
	'Political Process / Political Parties') 
INSERT INTO temp_sgt_bisaccodes_2010 VALUES (
	'POL017000',
	'Public Affairs & Administration') 
INSERT INTO temp_sgt_bisaccodes_2010 VALUES (
	'POL028000',
	'Public Policy / General')   
INSERT INTO temp_sgt_bisaccodes_2010 VALUES (
	'POL002000',
	'Public Policy / City Planning & Urban Development') 
INSERT INTO temp_sgt_bisaccodes_2010 VALUES (
	'POL038000',
	'Public Policy / Cultural Policy') 
INSERT INTO temp_sgt_bisaccodes_2010 VALUES (
	'POL024000',
	'Public Policy / Economic Policy') 
INSERT INTO temp_sgt_bisaccodes_2010 VALUES (
	'POL044000',
	'Public Policy / Environmental Policy ') 
INSERT INTO temp_sgt_bisaccodes_2010 VALUES (
	'POL026000',
	'Public Policy / Regional Planning') 
INSERT INTO temp_sgt_bisaccodes_2010 VALUES (
	'POL029000',
	'Public Policy / Social Policy ')  
INSERT INTO temp_sgt_bisaccodes_2010 VALUES (
	'POL027000',
	'Public Policy / Social Security') 
INSERT INTO temp_sgt_bisaccodes_2010 VALUES (
	'POL019000',
	'Public Policy / Social Services & Welfare')  
INSERT INTO temp_sgt_bisaccodes_2010 VALUES (
	'POL018000',
	'Reference') 
INSERT INTO temp_sgt_bisaccodes_2010 VALUES (
	'PSY000000',
	'General') 
INSERT INTO temp_sgt_bisaccodes_2010 VALUES (
	'PSY003000',
	'Applied Psychology')  
INSERT INTO temp_sgt_bisaccodes_2010 VALUES (
	'PSY042000',
	'Assessment, Testing & Measurement') 
INSERT INTO temp_sgt_bisaccodes_2010 VALUES (
	'PSY007000',
	'Clinical Psychology')  
INSERT INTO temp_sgt_bisaccodes_2010 VALUES (
	'PSY008000',
	'Cognitive Psychology') 
INSERT INTO temp_sgt_bisaccodes_2010 VALUES (
	'PSY034000',
	'Creative Ability') 
INSERT INTO temp_sgt_bisaccodes_2010 VALUES (
	'PSY039000',
	'Developmental / General')   
INSERT INTO temp_sgt_bisaccodes_2010 VALUES (
	'PSY002000',
	'Developmental / Adolescent')  
INSERT INTO temp_sgt_bisaccodes_2010 VALUES (
	'PSY043000',
	'Developmental / Adulthood & Aging') 
INSERT INTO temp_sgt_bisaccodes_2010 VALUES (
	'PSY004000',
	'Developmental / Child')  
INSERT INTO temp_sgt_bisaccodes_2010 VALUES (
	'PSY044000',
	'Developmental / Lifespan Development ') 
INSERT INTO temp_sgt_bisaccodes_2010 VALUES (
	'PSY012000',
	'Education & Training') 
INSERT INTO temp_sgt_bisaccodes_2010 VALUES (
	'PSY013000',
	'Emotions')  
INSERT INTO temp_sgt_bisaccodes_2010 VALUES (
	'PSY050000',
	'Ethnopsychology')  
INSERT INTO temp_sgt_bisaccodes_2010 VALUES (
	'PSY040000',
	'Experimental Psychology')   
INSERT INTO temp_sgt_bisaccodes_2010 VALUES (
	'PSY014000',
	'Forensic Psychology')  
INSERT INTO temp_sgt_bisaccodes_2010 VALUES (
	'PSY015000',
	'History') 
INSERT INTO temp_sgt_bisaccodes_2010 VALUES (
	'PSY016000',
	'Human Sexuality')  
INSERT INTO temp_sgt_bisaccodes_2010 VALUES (
	'PSY035000',
	'Hypnotism') 
INSERT INTO temp_sgt_bisaccodes_2010 VALUES (
	'PSY021000',
	'Industrial & Organizational Psychology') 
INSERT INTO temp_sgt_bisaccodes_2010 VALUES (
	'PSY017000',
	'Interpersonal Relations')   
INSERT INTO temp_sgt_bisaccodes_2010 VALUES (
	'PSY036000',
	'Mental Health')  
INSERT INTO temp_sgt_bisaccodes_2010 VALUES (
	'PSY018000',
	'Mental Illness') 
INSERT INTO temp_sgt_bisaccodes_2010 VALUES (
	'PSY045000',
	'Movements / General')  
INSERT INTO temp_sgt_bisaccodes_2010 VALUES (
	'PSY045010',
	'Movements / Behaviorism')   
INSERT INTO temp_sgt_bisaccodes_2010 VALUES (
	'PSY045040',
	'Movements / Existential')   
INSERT INTO temp_sgt_bisaccodes_2010 VALUES (
	'PSY045050',
	'Movements / Gestalt')  
INSERT INTO temp_sgt_bisaccodes_2010 VALUES (
	'PSY045020',
	'Movements / Humanism') 
INSERT INTO temp_sgt_bisaccodes_2010 VALUES (
	'PSY045060',
	'Movements / Jungian')  
INSERT INTO temp_sgt_bisaccodes_2010 VALUES (
	'PSY026000',
	'Movements / Psychoanalysis')  
INSERT INTO temp_sgt_bisaccodes_2010 VALUES (
	'PSY045030',
	'Movements / Transpersonal') 
INSERT INTO temp_sgt_bisaccodes_2010 VALUES (
	'PSY020000',
	'Neuropsychology')  
INSERT INTO temp_sgt_bisaccodes_2010 VALUES (
	'PSY023000',
	'Personality')  
INSERT INTO temp_sgt_bisaccodes_2010 VALUES (
	'PSY024000',
	'Physiological Psychology')  
INSERT INTO temp_sgt_bisaccodes_2010 VALUES (
	'PSY046000',
	'Practice Management')  
INSERT INTO temp_sgt_bisaccodes_2010 VALUES (
	'PSY022000',
	'Psychopathology / General') 
INSERT INTO temp_sgt_bisaccodes_2010 VALUES (
	'PSY038000',
	'Psychopathology / Addiction') 
INSERT INTO temp_sgt_bisaccodes_2010 VALUES (
	'PSY022060',
	'Psychopathology / Anxieties & Phobias') 
INSERT INTO temp_sgt_bisaccodes_2010 VALUES (
	'PSY022010',
	'Psychopathology / Attention-Deficit Disorder (ADD-ADHD)  ') 
INSERT INTO temp_sgt_bisaccodes_2010 VALUES (
	'PSY022020',
	'Psychopathology / Autism Spectrum Disorders ')  
INSERT INTO temp_sgt_bisaccodes_2010 VALUES (
	'PSY022030',
	'Psychopathology / Bipolar Disorder   ') 
INSERT INTO temp_sgt_bisaccodes_2010 VALUES (
	'PSY009000',
	'Psychopathology / Compulsive Behavior') 
INSERT INTO temp_sgt_bisaccodes_2010 VALUES (
	'PSY049000',
	'Psychopathology / Depression') 
INSERT INTO temp_sgt_bisaccodes_2010 VALUES (
	'PSY022070',
	'Psychopathology / Dissociative Identity Disorder')  
INSERT INTO temp_sgt_bisaccodes_2010 VALUES (
	'PSY011000',
	'Psychopathology / Eating Disorders   ') 
INSERT INTO temp_sgt_bisaccodes_2010 VALUES (
	'PSY022040',
	'Psychopathology / Post-Traumatic Stress Disorder (PTSD)  ') 
INSERT INTO temp_sgt_bisaccodes_2010 VALUES (
	'PSY022050',
	'Psychopathology / Schizophrenia') 
INSERT INTO temp_sgt_bisaccodes_2010 VALUES (
	'PSY028000',
	'Psychotherapy / General')   
INSERT INTO temp_sgt_bisaccodes_2010 VALUES (
	'PSY006000',
	'Psychotherapy / Child & Adolescent   ') 
INSERT INTO temp_sgt_bisaccodes_2010 VALUES (
	'PSY010000',
	'Psychotherapy / Counseling')  
INSERT INTO temp_sgt_bisaccodes_2010 VALUES (
	'PSY041000',
	'Psychotherapy / Couples & Family')  
INSERT INTO temp_sgt_bisaccodes_2010 VALUES (
	'PSY048000',
	'Psychotherapy / Group')  
INSERT INTO temp_sgt_bisaccodes_2010 VALUES (
	'PSY029000',
	'Reference') 
INSERT INTO temp_sgt_bisaccodes_2010 VALUES (
	'PSY030000',
	'Research & Methodology') 
INSERT INTO temp_sgt_bisaccodes_2010 VALUES (
	'PSY031000',
	'Social Psychology')   
INSERT INTO temp_sgt_bisaccodes_2010 VALUES (
	'PSY032000',
	'Statistics ')  
INSERT INTO temp_sgt_bisaccodes_2010 VALUES (
	'PSY037000',
	'Suicide') 
INSERT INTO temp_sgt_bisaccodes_2010 VALUES (
	'REF000000',
	'General') 
INSERT INTO temp_sgt_bisaccodes_2010 VALUES (
	'REF001000',
	'Almanacs')  
INSERT INTO temp_sgt_bisaccodes_2010 VALUES (
	'REF002000',
	'Atlases & Gazetteers') 
INSERT INTO temp_sgt_bisaccodes_2010 VALUES (
	'REF004000',
	'Bibliographies & Indexes')  
INSERT INTO temp_sgt_bisaccodes_2010 VALUES (
	'REF006000',
	'Catalogs')  
INSERT INTO temp_sgt_bisaccodes_2010 VALUES (
	'REF030000',
	'Consumer Guides')  
INSERT INTO temp_sgt_bisaccodes_2010 VALUES (
	'REF007000',
	'Curiosities & Wonders')  
INSERT INTO temp_sgt_bisaccodes_2010 VALUES (
	'REF008000',
	'Dictionaries') 
INSERT INTO temp_sgt_bisaccodes_2010 VALUES (
	'REF009000',
	'Directories')  
INSERT INTO temp_sgt_bisaccodes_2010 VALUES (
	'REF010000',
	'Encyclopedias')  
INSERT INTO temp_sgt_bisaccodes_2010 VALUES (
	'REF011000',
	'Etiquette') 
INSERT INTO temp_sgt_bisaccodes_2010 VALUES (
	'REF013000',
	'Genealogy & Heraldry') 
INSERT INTO temp_sgt_bisaccodes_2010 VALUES (
	'REF028000',
	'Handbooks & Manuals')  
INSERT INTO temp_sgt_bisaccodes_2010 VALUES (
	'REF015000',
	'Personal & Practical Guides') 
INSERT INTO temp_sgt_bisaccodes_2010 VALUES (
	'REF029000',
	'Problems & Exercises') 
INSERT INTO temp_sgt_bisaccodes_2010 VALUES (
	'REF018000',
	'Questions & Answers')  
INSERT INTO temp_sgt_bisaccodes_2010 VALUES (
	'REF019000',
	'Quotations ')  
INSERT INTO temp_sgt_bisaccodes_2010 VALUES (
	'REF020000',
	'Research')  
INSERT INTO temp_sgt_bisaccodes_2010 VALUES (
	'REF022000',
	'Thesauri')  
INSERT INTO temp_sgt_bisaccodes_2010 VALUES (
	'REF023000',
	'Trivia')  
INSERT INTO temp_sgt_bisaccodes_2010 VALUES (
	'REF024000',
	'Weddings')  
INSERT INTO temp_sgt_bisaccodes_2010 VALUES (
	'REF025000',
	'Word Lists ')  
INSERT INTO temp_sgt_bisaccodes_2010 VALUES (
	'REF026000',
	'Writing Skills') 
INSERT INTO temp_sgt_bisaccodes_2010 VALUES (
	'REF027000',
	'Yearbooks & Annuals')  
INSERT INTO temp_sgt_bisaccodes_2010 VALUES (
	'REL000000',
	'General') 
INSERT INTO temp_sgt_bisaccodes_2010 VALUES (
	'REL001000',
	'Agnosticism')  
INSERT INTO temp_sgt_bisaccodes_2010 VALUES (
	'REL114000',
	'Ancient') 
INSERT INTO temp_sgt_bisaccodes_2010 VALUES (
	'REL072000',
	'Antiquities & Archaeology') 
INSERT INTO temp_sgt_bisaccodes_2010 VALUES (
	'REL004000',
	'Atheism') 
INSERT INTO temp_sgt_bisaccodes_2010 VALUES (
	'REL005000',
	'Baha''i')  
INSERT INTO temp_sgt_bisaccodes_2010 VALUES (
	'REL006020',
	'Biblical Biography / General') 
INSERT INTO temp_sgt_bisaccodes_2010 VALUES (
	'REL006030',
	'Biblical Biography / Old Testament   ') 
INSERT INTO temp_sgt_bisaccodes_2010 VALUES (
	'REL006040',
	'Biblical Biography / New Testament   ') 
INSERT INTO temp_sgt_bisaccodes_2010 VALUES (
	'REL006050',
	'Biblical Commentary / General ')  
INSERT INTO temp_sgt_bisaccodes_2010 VALUES (
	'REL006060',
	'Biblical Commentary / Old Testament  ') 
INSERT INTO temp_sgt_bisaccodes_2010 VALUES (
	'REL006070',
	'Biblical Commentary / New Testament  ') 
INSERT INTO temp_sgt_bisaccodes_2010 VALUES (
	'REL006080',
	'Biblical Criticism & Interpretation / General') 
INSERT INTO temp_sgt_bisaccodes_2010 VALUES (
	'REL006090',
	'Biblical Criticism & Interpretation / Old Testament')  
INSERT INTO temp_sgt_bisaccodes_2010 VALUES (
	'REL006100',
	'Biblical Criticism & Interpretation / New Testament')  
INSERT INTO temp_sgt_bisaccodes_2010 VALUES (
	'REL006110',
	'Biblical Meditations / General')  
INSERT INTO temp_sgt_bisaccodes_2010 VALUES (
	'REL006120',
	'Biblical Meditations / Old Testament ') 
INSERT INTO temp_sgt_bisaccodes_2010 VALUES (
	'REL006130',
	'Biblical Meditations / New Testament ') 
INSERT INTO temp_sgt_bisaccodes_2010 VALUES (
	'REL006160',
	'Biblical Reference / General') 
INSERT INTO temp_sgt_bisaccodes_2010 VALUES (
	'REL006650',
	'Biblical Reference / Atlases') 
INSERT INTO temp_sgt_bisaccodes_2010 VALUES (
	'REL006660',
	'Biblical Reference / Concordances') 
INSERT INTO temp_sgt_bisaccodes_2010 VALUES (
	'REL006670',
	'Biblical Reference / Dictionaries & Encyclopedias') 
INSERT INTO temp_sgt_bisaccodes_2010 VALUES (
	'REL006680',
	'Biblical Reference / Handbooks')  
INSERT INTO temp_sgt_bisaccodes_2010 VALUES (
	'REL006410',
	'Biblical Reference / Language Study  ') 
INSERT INTO temp_sgt_bisaccodes_2010 VALUES (
	'REL006150',
	'Biblical Reference / Quotations') 
INSERT INTO temp_sgt_bisaccodes_2010 VALUES (
	'REL006000',
	'Biblical Studies / General')  
INSERT INTO temp_sgt_bisaccodes_2010 VALUES (
	'REL006700',
	'Biblical Studies / Bible Study Guides') 
INSERT INTO temp_sgt_bisaccodes_2010 VALUES (
	'REL006400',
	'Biblical Studies / Exegesis & Hermeneutics') 
INSERT INTO temp_sgt_bisaccodes_2010 VALUES (
	'REL006630',
	'Biblical Studies / History & Culture ') 
INSERT INTO temp_sgt_bisaccodes_2010 VALUES (
	'REL006710',
	'Biblical Studies / Jesus, the Gospels & Acts')  
INSERT INTO temp_sgt_bisaccodes_2010 VALUES (
	'REL006210',
	'Biblical Studies / Old Testament')  
INSERT INTO temp_sgt_bisaccodes_2010 VALUES (
	'REL006220',
	'Biblical Studies / New Testament')  
INSERT INTO temp_sgt_bisaccodes_2010 VALUES (
	'REL006720',
	'Biblical Studies / Paul''s Letters') 
INSERT INTO temp_sgt_bisaccodes_2010 VALUES (
	'REL006140',
	'Biblical Studies / Prophecy') 
INSERT INTO temp_sgt_bisaccodes_2010 VALUES (
	'REL006730',
	'Biblical Studies / Prophets') 
INSERT INTO temp_sgt_bisaccodes_2010 VALUES (
	'REL006740',
	'Biblical Studies / Wisdom Literature ') 
INSERT INTO temp_sgt_bisaccodes_2010 VALUES (
	'REL007000',
	'Buddhism / General (see also PHILOSOPHY / Buddhist)')  
INSERT INTO temp_sgt_bisaccodes_2010 VALUES (
	'REL007010',
	'Buddhism / History')  
INSERT INTO temp_sgt_bisaccodes_2010 VALUES (
	'REL007020',
	'Buddhism / Rituals & Practice ')  
INSERT INTO temp_sgt_bisaccodes_2010 VALUES (
	'REL007030',
	'Buddhism / Sacred Writings')  
INSERT INTO temp_sgt_bisaccodes_2010 VALUES (
	'REL007040',
	'Buddhism / Theravada') 
INSERT INTO temp_sgt_bisaccodes_2010 VALUES (
	'REL007050',
	'Buddhism / Tibetan')  
INSERT INTO temp_sgt_bisaccodes_2010 VALUES (
	'REL092000',
	'Buddhism / Zen (see also PHILOSOPHY / Zen)') 
INSERT INTO temp_sgt_bisaccodes_2010 VALUES (
	'REL108000',
	'Christian Church / General')  
INSERT INTO temp_sgt_bisaccodes_2010 VALUES (
	'REL014000',
	'Christian Church / Administration') 
INSERT INTO temp_sgt_bisaccodes_2010 VALUES (
	'REL008000',
	'Christian Church / Canon & Ecclesiastical Law') 
INSERT INTO temp_sgt_bisaccodes_2010 VALUES (
	'REL108010',
	'Christian Church / Growth') 
INSERT INTO temp_sgt_bisaccodes_2010 VALUES (
	'REL108020',
	'Christian Church / History')  
INSERT INTO temp_sgt_bisaccodes_2010 VALUES (
	'REL108030',
	'Christian Church / Leadership ')  
INSERT INTO temp_sgt_bisaccodes_2010 VALUES (
	'REL011000',
	'Christian Education / General ')  
INSERT INTO temp_sgt_bisaccodes_2010 VALUES (
	'REL095000',
	'Christian Education / Adult') 
INSERT INTO temp_sgt_bisaccodes_2010 VALUES (
	'REL091000',
	'Christian Education / Children & Youth') 
INSERT INTO temp_sgt_bisaccodes_2010 VALUES (
	'REL012000',
	'Christian Life / General')  
INSERT INTO temp_sgt_bisaccodes_2010 VALUES (
	'REL012010',
	'Christian Life / Death, Grief, Bereavement') 
INSERT INTO temp_sgt_bisaccodes_2010 VALUES (
	'REL012020',
	'Christian Life / Devotional') 
INSERT INTO temp_sgt_bisaccodes_2010 VALUES (
	'REL012030',
	'Christian Life / Family')   
INSERT INTO temp_sgt_bisaccodes_2010 VALUES (
	'REL012040',
	'Christian Life / Inspirational')  
INSERT INTO temp_sgt_bisaccodes_2010 VALUES (
	'REL012050',
	'Christian Life / Love & Marriage')  
INSERT INTO temp_sgt_bisaccodes_2010 VALUES (
	'REL012060',
	'Christian Life / Men''s Issues ')  
INSERT INTO temp_sgt_bisaccodes_2010 VALUES (
	'REL012070',
	'Christian Life / Personal Growth')  
INSERT INTO temp_sgt_bisaccodes_2010 VALUES (
	'REL012080',
	'Christian Life / Prayer')   
INSERT INTO temp_sgt_bisaccodes_2010 VALUES (
	'REL012090',
	'Christian Life / Professional Growth ') 
INSERT INTO temp_sgt_bisaccodes_2010 VALUES (
	'REL012100',
	'Christian Life / Relationships')  
INSERT INTO temp_sgt_bisaccodes_2010 VALUES (
	'REL012110',
	'Christian Life / Social Issues')  
INSERT INTO temp_sgt_bisaccodes_2010 VALUES (
	'REL012120',
	'Christian Life / Spiritual Growth') 
INSERT INTO temp_sgt_bisaccodes_2010 VALUES (
	'REL099000',
	'Christian Life / Spiritual Warfare   ') 
INSERT INTO temp_sgt_bisaccodes_2010 VALUES (
	'REL063000',
	'Christian Life / Stewardship & Giving') 
INSERT INTO temp_sgt_bisaccodes_2010 VALUES (
	'REL012130',
	'Christian Life / Women''s Issues') 
INSERT INTO temp_sgt_bisaccodes_2010 VALUES (
	'REL109000',
	'Christian Ministry / General') 
INSERT INTO temp_sgt_bisaccodes_2010 VALUES (
	'REL109010',
	'Christian Ministry / Adult')  
INSERT INTO temp_sgt_bisaccodes_2010 VALUES (
	'REL109020',
	'Christian Ministry / Children ')  
INSERT INTO temp_sgt_bisaccodes_2010 VALUES (
	'REL050000',
	'Christian Ministry / Counseling & Recovery') 
INSERT INTO temp_sgt_bisaccodes_2010 VALUES (
	'REL023000',
	'Christian Ministry / Discipleship') 
INSERT INTO temp_sgt_bisaccodes_2010 VALUES (
	'REL030000',
	'Christian Ministry / Evangelism') 
INSERT INTO temp_sgt_bisaccodes_2010 VALUES (
	'REL045000',
	'Christian Ministry / Missions ')  
INSERT INTO temp_sgt_bisaccodes_2010 VALUES (
	'REL074000',
	'Christian Ministry / Pastoral Resources  ')  
INSERT INTO temp_sgt_bisaccodes_2010 VALUES (
	'REL080000',
	'Christian Ministry / Preaching')  
INSERT INTO temp_sgt_bisaccodes_2010 VALUES (
	'REL109030',
	'Christian Ministry / Youth')  
INSERT INTO temp_sgt_bisaccodes_2010 VALUES (
	'REL055000',
	'Christian Rituals & Practice / General') 
INSERT INTO temp_sgt_bisaccodes_2010 VALUES (
	'REL055010',
	'Christian Rituals & Practice / Sacraments')  
INSERT INTO temp_sgt_bisaccodes_2010 VALUES (
	'REL055020',
	'Christian Rituals & Practice / Worship & Liturgy')  
INSERT INTO temp_sgt_bisaccodes_2010 VALUES (
	'REL067000',
	'Christian Theology / General') 
INSERT INTO temp_sgt_bisaccodes_2010 VALUES (
	'REL067010',
	'Christian Theology / Angelology & Demonology')  
INSERT INTO temp_sgt_bisaccodes_2010 VALUES (
	'REL067020',
	'Christian Theology / Anthropology') 
INSERT INTO temp_sgt_bisaccodes_2010 VALUES (
	'REL067030',
	'Christian Theology / Apologetics')  
INSERT INTO temp_sgt_bisaccodes_2010 VALUES (
	'REL067040',
	'Christian Theology / Christology')  
INSERT INTO temp_sgt_bisaccodes_2010 VALUES (
	'REL067050',
	'Christian Theology / Ecclesiology') 
INSERT INTO temp_sgt_bisaccodes_2010 VALUES (
	'REL067060',
	'Christian Theology / Eschatology')  
INSERT INTO temp_sgt_bisaccodes_2010 VALUES (
	'REL067070',
	'Christian Theology / Ethics') 
INSERT INTO temp_sgt_bisaccodes_2010 VALUES (
	'REL067080',
	'Christian Theology / History') 
INSERT INTO temp_sgt_bisaccodes_2010 VALUES (
	'REL067120',
	'Christian Theology / Liberation') 
INSERT INTO temp_sgt_bisaccodes_2010 VALUES (
	'REL104000',
	'Christian Theology / Mariology')  
INSERT INTO temp_sgt_bisaccodes_2010 VALUES (
	'REL067090',
	'Christian Theology / Pneumatology') 
INSERT INTO temp_sgt_bisaccodes_2010 VALUES (
	'REL067130',
	'Christian Theology / Process') 
INSERT INTO temp_sgt_bisaccodes_2010 VALUES (
	'REL067100',
	'Christian Theology / Soteriology')  
INSERT INTO temp_sgt_bisaccodes_2010 VALUES (
	'REL067110',
	'Christian Theology / Systematic') 
INSERT INTO temp_sgt_bisaccodes_2010 VALUES (
	'REL070000',
	'Christianity / General') 
INSERT INTO temp_sgt_bisaccodes_2010 VALUES (
	'REL002000',
	'Christianity / Amish') 
INSERT INTO temp_sgt_bisaccodes_2010 VALUES (
	'REL003000',
	'Christianity / Anglican')   
INSERT INTO temp_sgt_bisaccodes_2010 VALUES (
	'REL073000',
	'Christianity / Baptist') 
INSERT INTO temp_sgt_bisaccodes_2010 VALUES (
	'REL093000',
	'Christianity / Calvinist')  
INSERT INTO temp_sgt_bisaccodes_2010 VALUES (
	'REL009000',
	'Christianity / Catechisms') 
INSERT INTO temp_sgt_bisaccodes_2010 VALUES (
	'REL010000',
	'Christianity / Catholic')   
INSERT INTO temp_sgt_bisaccodes_2010 VALUES (
	'REL083000',
	'Christianity / Christian Science')  
INSERT INTO temp_sgt_bisaccodes_2010 VALUES (
	'REL046000',
	'Christianity / Church of Jesus Christ of Latter-day Saints (Mormon)  ')  
INSERT INTO temp_sgt_bisaccodes_2010 VALUES (
	'REL094000',
	'Christianity / Denominations') 
INSERT INTO temp_sgt_bisaccodes_2010 VALUES (
	'REL027000',
	'Christianity / Episcopalian') 
INSERT INTO temp_sgt_bisaccodes_2010 VALUES (
	'REL015000',
	'Christianity / History') 
INSERT INTO temp_sgt_bisaccodes_2010 VALUES (
	'REL096000',
	'Christianity / Jehovah''s Witnesses   ') 
INSERT INTO temp_sgt_bisaccodes_2010 VALUES (
	'REL013000',
	'Christianity / Literature & the Arts ') 
INSERT INTO temp_sgt_bisaccodes_2010 VALUES (
	'REL082000',
	'Christianity / Lutheran')   
INSERT INTO temp_sgt_bisaccodes_2010 VALUES (
	'REL043000',
	'Christianity / Mennonite')  
INSERT INTO temp_sgt_bisaccodes_2010 VALUES (
	'REL044000',
	'Christianity / Methodist')  
INSERT INTO temp_sgt_bisaccodes_2010 VALUES (
	'REL049000',
	'Christianity / Orthodox')   
INSERT INTO temp_sgt_bisaccodes_2010 VALUES (
	'REL079000',
	'Christianity / Pentecostal & Charismatic ')  
INSERT INTO temp_sgt_bisaccodes_2010 VALUES (
	'REL097000',
	'Christianity / Presbyterian') 
INSERT INTO temp_sgt_bisaccodes_2010 VALUES (
	'REL053000',
	'Christianity / Protestant') 
INSERT INTO temp_sgt_bisaccodes_2010 VALUES (
	'REL088000',
	'Christianity / Quaker')  
INSERT INTO temp_sgt_bisaccodes_2010 VALUES (
	'REL110000',
	'Christianity / Saints & Sainthood') 
INSERT INTO temp_sgt_bisaccodes_2010 VALUES (
	'REL098000',
	'Christianity / Seventh-Day Adventist ') 
INSERT INTO temp_sgt_bisaccodes_2010 VALUES (
	'REL059000',
	'Christianity / Shaker')  
INSERT INTO temp_sgt_bisaccodes_2010 VALUES (
	'REL111000',
	'Christianity / United Church of Christ') 
INSERT INTO temp_sgt_bisaccodes_2010 VALUES (
	'REL081000',
	'Clergy')  
INSERT INTO temp_sgt_bisaccodes_2010 VALUES (
	'REL017000',
	'Comparative Religion') 
INSERT INTO temp_sgt_bisaccodes_2010 VALUES (
	'REL018000',
	'Confucianism') 
INSERT INTO temp_sgt_bisaccodes_2010 VALUES (
	'REL019000',
	'Counseling ')  
INSERT INTO temp_sgt_bisaccodes_2010 VALUES (
	'REL020000',
	'Cults') 
INSERT INTO temp_sgt_bisaccodes_2010 VALUES (
	'REL021000',
	'Deism') 
INSERT INTO temp_sgt_bisaccodes_2010 VALUES (
	'REL100000',
	'Demonology & Satanism')  
INSERT INTO temp_sgt_bisaccodes_2010 VALUES (
	'REL022000',
	'Devotional ')  
INSERT INTO temp_sgt_bisaccodes_2010 VALUES (
	'REL024000',
	'Eastern') 
INSERT INTO temp_sgt_bisaccodes_2010 VALUES (
	'REL107000',
	'Eckankar')  
INSERT INTO temp_sgt_bisaccodes_2010 VALUES (
	'REL025000',
	'Ecumenism') 
INSERT INTO temp_sgt_bisaccodes_2010 VALUES (
	'REL026000',
	'Education') 
INSERT INTO temp_sgt_bisaccodes_2010 VALUES (
	'REL085000',
	'Eschatology')  
INSERT INTO temp_sgt_bisaccodes_2010 VALUES (
	'REL113000',
	'Essays')  
INSERT INTO temp_sgt_bisaccodes_2010 VALUES (
	'REL028000',
	'Ethics')  
INSERT INTO temp_sgt_bisaccodes_2010 VALUES (
	'REL029000',
	'Ethnic & Tribal')  
INSERT INTO temp_sgt_bisaccodes_2010 VALUES (
	'REL077000',
	'Faith') 
INSERT INTO temp_sgt_bisaccodes_2010 VALUES (
	'REL078000',
	'Fundamentalism') 
INSERT INTO temp_sgt_bisaccodes_2010 VALUES (
	'REL112000',
	'Gnosticism ')  
INSERT INTO temp_sgt_bisaccodes_2010 VALUES (
	'REL032000',
	'Hinduism / General')  
INSERT INTO temp_sgt_bisaccodes_2010 VALUES (
	'REL032010',
	'Hinduism / History')  
INSERT INTO temp_sgt_bisaccodes_2010 VALUES (
	'REL032020',
	'Hinduism / Rituals & Practice ')  
INSERT INTO temp_sgt_bisaccodes_2010 VALUES (
	'REL032030',
	'Hinduism / Sacred Writings')  
INSERT INTO temp_sgt_bisaccodes_2010 VALUES (
	'REL032040',
	'Hinduism / Theology')  
INSERT INTO temp_sgt_bisaccodes_2010 VALUES (
	'REL033000',
	'History') 
INSERT INTO temp_sgt_bisaccodes_2010 VALUES (
	'REL034000',
	'Holidays / General')  
INSERT INTO temp_sgt_bisaccodes_2010 VALUES (
	'REL034010',
	'Holidays / Christian') 
INSERT INTO temp_sgt_bisaccodes_2010 VALUES (
	'REL034020',
	'Holidays / Christmas & Advent ')  
INSERT INTO temp_sgt_bisaccodes_2010 VALUES (
	'REL034030',
	'Holidays / Easter & Lent')  
INSERT INTO temp_sgt_bisaccodes_2010 VALUES (
	'REL034040',
	'Holidays / Jewish')   
INSERT INTO temp_sgt_bisaccodes_2010 VALUES (
	'REL034050',
	'Holidays / Other') 
INSERT INTO temp_sgt_bisaccodes_2010 VALUES (
	'REL036000',
	'Inspirational')  
INSERT INTO temp_sgt_bisaccodes_2010 VALUES (
	'REL016000',
	'Institutions & Organizations') 
INSERT INTO temp_sgt_bisaccodes_2010 VALUES (
	'REL037000',
	'Islam / General')  
INSERT INTO temp_sgt_bisaccodes_2010 VALUES (
	'REL037010',
	'Islam / History')  
INSERT INTO temp_sgt_bisaccodes_2010 VALUES (
	'REL041000',
	'Islam / Koran & Sacred Writings') 
INSERT INTO temp_sgt_bisaccodes_2010 VALUES (
	'REL037020',
	'Islam / Law')  
INSERT INTO temp_sgt_bisaccodes_2010 VALUES (
	'REL037030',
	'Islam / Rituals & Practice')  
INSERT INTO temp_sgt_bisaccodes_2010 VALUES (
	'REL037040',
	'Islam / Shi''a')  
INSERT INTO temp_sgt_bisaccodes_2010 VALUES (
	'REL090000',
	'Islam / Sufi') 
INSERT INTO temp_sgt_bisaccodes_2010 VALUES (
	'REL037050',
	'Islam / Sunni')  
INSERT INTO temp_sgt_bisaccodes_2010 VALUES (
	'REL037060',
	'Islam / Theology') 
INSERT INTO temp_sgt_bisaccodes_2010 VALUES (
	'REL038000',
	'Jainism') 
INSERT INTO temp_sgt_bisaccodes_2010 VALUES (
	'REL040000',
	'Judaism / General')   
INSERT INTO temp_sgt_bisaccodes_2010 VALUES (
	'REL040050',
	'Judaism / Conservative') 
INSERT INTO temp_sgt_bisaccodes_2010 VALUES (
	'REL040030',
	'Judaism / History')   
INSERT INTO temp_sgt_bisaccodes_2010 VALUES (
	'REL040060',
	'Judaism / Kabbalah & Mysticism')  
INSERT INTO temp_sgt_bisaccodes_2010 VALUES (
	'REL040070',
	'Judaism / Orthodox')  
INSERT INTO temp_sgt_bisaccodes_2010 VALUES (
	'REL040080',
	'Judaism / Reform') 
INSERT INTO temp_sgt_bisaccodes_2010 VALUES (
	'REL040010',
	'Judaism / Rituals & Practice') 
INSERT INTO temp_sgt_bisaccodes_2010 VALUES (
	'REL040040',
	'Judaism / Sacred Writings') 
INSERT INTO temp_sgt_bisaccodes_2010 VALUES (
	'REL064000',
	'Judaism / Talmud') 
INSERT INTO temp_sgt_bisaccodes_2010 VALUES (
	'REL040090',
	'Judaism / Theology')  
INSERT INTO temp_sgt_bisaccodes_2010 VALUES (
	'REL071000',
	'Leadership ')  
INSERT INTO temp_sgt_bisaccodes_2010 VALUES (
	'REL042000',
	'Meditations')  
INSERT INTO temp_sgt_bisaccodes_2010 VALUES (
	'REL101000',
	'Messianic Judaism')   
INSERT INTO temp_sgt_bisaccodes_2010 VALUES (
	'REL086000',
	'Monasticism')  
INSERT INTO temp_sgt_bisaccodes_2010 VALUES (
	'REL047000',
	'Mysticism') 
INSERT INTO temp_sgt_bisaccodes_2010 VALUES (
	'REL051000',
	'Philosophy ')  
INSERT INTO temp_sgt_bisaccodes_2010 VALUES (
	'REL087000',
	'Prayer')  
INSERT INTO temp_sgt_bisaccodes_2010 VALUES (
	'REL052000',
	'Prayerbooks / General')  
INSERT INTO temp_sgt_bisaccodes_2010 VALUES (
	'REL052010',
	'Prayerbooks / Christian')   
INSERT INTO temp_sgt_bisaccodes_2010 VALUES (
	'REL052030',
	'Prayerbooks / Islamic')  
INSERT INTO temp_sgt_bisaccodes_2010 VALUES (
	'REL052020',
	'Prayerbooks / Jewish') 
INSERT INTO temp_sgt_bisaccodes_2010 VALUES (
	'REL075000',
	'Psychology of Religion') 
INSERT INTO temp_sgt_bisaccodes_2010 VALUES (
	'REL054000',
	'Reference') 
INSERT INTO temp_sgt_bisaccodes_2010 VALUES (
	'REL106000',
	'Religion & Science')  
INSERT INTO temp_sgt_bisaccodes_2010 VALUES (
	'REL084000',
	'Religion, Politics & State')  
INSERT INTO temp_sgt_bisaccodes_2010 VALUES (
	'REL057000',
	'Rosicrucianism') 
INSERT INTO temp_sgt_bisaccodes_2010 VALUES (
	'REL089000',
	'Scientology')  
INSERT INTO temp_sgt_bisaccodes_2010 VALUES (
	'REL058000',
	'Sermons / General')   
INSERT INTO temp_sgt_bisaccodes_2010 VALUES (
	'REL058010',
	'Sermons / Christian')  
INSERT INTO temp_sgt_bisaccodes_2010 VALUES (
	'REL058020',
	'Sermons / Jewish') 
INSERT INTO temp_sgt_bisaccodes_2010 VALUES (
	'REL105000',
	'Sexuality & Gender Studies')  
INSERT INTO temp_sgt_bisaccodes_2010 VALUES (
	'REL060000',
	'Shintoism') 
INSERT INTO temp_sgt_bisaccodes_2010 VALUES (
	'REL061000',
	'Sikhism') 
INSERT INTO temp_sgt_bisaccodes_2010 VALUES (
	'REL062000',
	'Spirituality') 
INSERT INTO temp_sgt_bisaccodes_2010 VALUES (
	'REL065000',
	'Taoism (see also PHILOSOPHY / Taoist)') 
INSERT INTO temp_sgt_bisaccodes_2010 VALUES (
	'REL066000',
	'Theism')  
INSERT INTO temp_sgt_bisaccodes_2010 VALUES (
	'REL102000',
	'Theology')  
INSERT INTO temp_sgt_bisaccodes_2010 VALUES (
	'REL068000',
	'Theosophy') 
INSERT INTO temp_sgt_bisaccodes_2010 VALUES (
	'REL103000',
	'Unitarian Universalism') 
INSERT INTO temp_sgt_bisaccodes_2010 VALUES (
	'REL069000',
	'Zoroastrianism') 
INSERT INTO temp_sgt_bisaccodes_2010 VALUES (
	'SCI000000',
	'General') 
INSERT INTO temp_sgt_bisaccodes_2010 VALUES (
	'SCI001000',
	'Acoustics & Sound')   
INSERT INTO temp_sgt_bisaccodes_2010 VALUES (
	'SCI003000',
	'Applied Sciences') 
INSERT INTO temp_sgt_bisaccodes_2010 VALUES (
	'SCI004000',
	'Astronomy') 
INSERT INTO temp_sgt_bisaccodes_2010 VALUES (
	'SCI005000',
	'Physics / Astrophysics') 
INSERT INTO temp_sgt_bisaccodes_2010 VALUES (
	'SCI010000',
	'Biotechnology')  
INSERT INTO temp_sgt_bisaccodes_2010 VALUES (
	'SCI012000',
	'Chaotic Behavior in Systems') 
INSERT INTO temp_sgt_bisaccodes_2010 VALUES (
	'SCI013000',
	'Chemistry / General')  
INSERT INTO temp_sgt_bisaccodes_2010 VALUES (
	'SCI013010',
	'Chemistry / Analytic') 
INSERT INTO temp_sgt_bisaccodes_2010 VALUES (
	'SCI013020',
	'Chemistry / Clinical') 
INSERT INTO temp_sgt_bisaccodes_2010 VALUES (
	'SCI013060',
	'Chemistry / Industrial & Technical   ') 
INSERT INTO temp_sgt_bisaccodes_2010 VALUES (
	'SCI013030',
	'Chemistry / Inorganic')  
INSERT INTO temp_sgt_bisaccodes_2010 VALUES (
	'SCI013040',
	'Chemistry / Organic')  
INSERT INTO temp_sgt_bisaccodes_2010 VALUES (
	'SCI013050',
	'Chemistry / Physical & Theoretical   ') 
INSERT INTO temp_sgt_bisaccodes_2010 VALUES (
	'SCI015000',
	'Cosmology') 
INSERT INTO temp_sgt_bisaccodes_2010 VALUES (
	'SCI016000',
	'Physics / Crystallography')  
INSERT INTO temp_sgt_bisaccodes_2010 VALUES (
	'SCI019000',
	'Earth Sciences / General')  
INSERT INTO temp_sgt_bisaccodes_2010 VALUES (
	'SCI030000',
	'Earth Sciences / Geography')  
INSERT INTO temp_sgt_bisaccodes_2010 VALUES (
	'SCI031000',
	'Earth Sciences / Geology')  
INSERT INTO temp_sgt_bisaccodes_2010 VALUES (
	'SCI081000',
	'Earth Sciences / Hydrology')  
INSERT INTO temp_sgt_bisaccodes_2010 VALUES (
	'SCI042000',
	'Earth Sciences / Meteorology & Climatology') 
INSERT INTO temp_sgt_bisaccodes_2010 VALUES (
	'SCI048000',
	'Earth Sciences / Mineralogy') 
INSERT INTO temp_sgt_bisaccodes_2010 VALUES (
	'SCI052000',
	'Earth Sciences / Oceanography ')  
INSERT INTO temp_sgt_bisaccodes_2010 VALUES (
	'SCI082000',
	'Earth Sciences / Seismology & Volcanism  ')  
INSERT INTO temp_sgt_bisaccodes_2010 VALUES (
	'SCI021000',
	'Physics / Electricity')  
INSERT INTO temp_sgt_bisaccodes_2010 VALUES (
	'SCI022000',
	'Physics / Electromagnetism') 
INSERT INTO temp_sgt_bisaccodes_2010 VALUES (
	'SCI023000',
	'Electron Microscopes & Microscopy') 
INSERT INTO temp_sgt_bisaccodes_2010 VALUES (
	'SCI024000',
	'Energy')  
INSERT INTO temp_sgt_bisaccodes_2010 VALUES (
	'SCI026000',
	'Environmental Science (see also Chemistry / Environmental)')  
INSERT INTO temp_sgt_bisaccodes_2010 VALUES (
	'SCI080000',
	'Essays')  
INSERT INTO temp_sgt_bisaccodes_2010 VALUES (
	'SCI028000',
	'Experiments & Projects') 
INSERT INTO temp_sgt_bisaccodes_2010 VALUES (
	'SCI032000',
	'Physics / Geophysics ')  
INSERT INTO temp_sgt_bisaccodes_2010 VALUES (
	'SCI033000',
	'Gravity') 
INSERT INTO temp_sgt_bisaccodes_2010 VALUES (
	'SCI034000',
	'History') 
INSERT INTO temp_sgt_bisaccodes_2010 VALUES (
	'SCI086000',
	'Life Sciences / General')   
INSERT INTO temp_sgt_bisaccodes_2010 VALUES (
	'SCI056000',
	'Life Sciences / Anatomy & Physiology (see also Life Sciences / Human Anatomy & Physiology)') 
INSERT INTO temp_sgt_bisaccodes_2010 VALUES (
	'SCI006000',
	'Life Sciences / Bacteriology') 
INSERT INTO temp_sgt_bisaccodes_2010 VALUES (
	'SCI007000',
	'Life Sciences / Biochemistry') 
INSERT INTO temp_sgt_bisaccodes_2010 VALUES (
	'SCI088000',
	'Life Sciences / Biological Diversity ') 
INSERT INTO temp_sgt_bisaccodes_2010 VALUES (
	'SCI008000',
	'Life Sciences / Biology') 
INSERT INTO temp_sgt_bisaccodes_2010 VALUES (
	'SCI072000',
	'Life Sciences / Developmental Biology') 
INSERT INTO temp_sgt_bisaccodes_2010 VALUES (
	'SCI039000',
	'Life Sciences / Marine Biology ')  
INSERT INTO temp_sgt_bisaccodes_2010 VALUES (
	'SCI045000',
	'Life Sciences / Microbiology') 
INSERT INTO temp_sgt_bisaccodes_2010 VALUES (
	'SCI049000',
	'Life Sciences / Molecular Biology ')  
INSERT INTO temp_sgt_bisaccodes_2010 VALUES (
	'SCI009000',
	'Life Sciences / Biophysics')  
INSERT INTO temp_sgt_bisaccodes_2010 VALUES (
	'SCI011000',
	'Life Sciences / Botany') 
INSERT INTO temp_sgt_bisaccodes_2010 VALUES (
	'SCI017000',
	'Life Sciences / Cell Biology')  
INSERT INTO temp_sgt_bisaccodes_2010 VALUES (
	'SCI020000',
	'Life Sciences / Ecology')   
INSERT INTO temp_sgt_bisaccodes_2010 VALUES (
	'SCI027000',
	'Life Sciences / Evolution') 
INSERT INTO temp_sgt_bisaccodes_2010 VALUES (
	'SCI029000',
	'Life Sciences / Genetics & Genomics  ') 
INSERT INTO temp_sgt_bisaccodes_2010 VALUES (
	'SCI073000',
	'Life Sciences / Horticulture') 
INSERT INTO temp_sgt_bisaccodes_2010 VALUES (
	'SCI036000',
	'Life Sciences / Human Anatomy & Physiology') 
INSERT INTO temp_sgt_bisaccodes_2010 VALUES (
	'SCI089000',
	'Life Sciences / Neuroscience') 
INSERT INTO temp_sgt_bisaccodes_2010 VALUES (
	'SCI087000',
	'Life Sciences / Taxonomy')  
INSERT INTO temp_sgt_bisaccodes_2010 VALUES (
	'SCI070000',
	'Life Sciences / Zoology / General') 
INSERT INTO temp_sgt_bisaccodes_2010 VALUES (
	'SCI025000',
	'Life Sciences / Zoology / Entomology ') 
INSERT INTO temp_sgt_bisaccodes_2010 VALUES (
	'SCI070010',
	'Life Sciences / Zoology / Ichthyology & Herpetology') 
INSERT INTO temp_sgt_bisaccodes_2010 VALUES (
	'SCI070020',
	'Life Sciences / Zoology / Invertebrates  ')  
INSERT INTO temp_sgt_bisaccodes_2010 VALUES (
	'SCI070030',
	'Life Sciences / Zoology / Mammals') 
INSERT INTO temp_sgt_bisaccodes_2010 VALUES (
	'SCI070040',
	'Life Sciences / Zoology / Ornithology') 
INSERT INTO temp_sgt_bisaccodes_2010 VALUES (
	'SCI070050',
	'Life Sciences / Zoology / Primatology') 
INSERT INTO temp_sgt_bisaccodes_2010 VALUES (
	'SCI037000',
	'Light') 
INSERT INTO temp_sgt_bisaccodes_2010 VALUES (
	'SCI083000',
	'Earth Sciences / Limnology') 
INSERT INTO temp_sgt_bisaccodes_2010 VALUES (
	'SCI038000',
	'Physics / Magnetism') 
INSERT INTO temp_sgt_bisaccodes_2010 VALUES (
	'SCI040000',
	'Physics / Mathematical & Computational') 
INSERT INTO temp_sgt_bisaccodes_2010 VALUES (
	'SCI041000',
	'Mechanics / General')  
INSERT INTO temp_sgt_bisaccodes_2010 VALUES (
	'SCI018000',
	'Mechanics / Dynamics')  
INSERT INTO temp_sgt_bisaccodes_2010 VALUES (
	'SCI084000',
	'Mechanics / Aerodynamics  ') 
INSERT INTO temp_sgt_bisaccodes_2010 VALUES (
	'SCI085000',
	'Mechanics / Fluids') 
INSERT INTO temp_sgt_bisaccodes_2010 VALUES (
	'SCI065000',
	'Mechanics / Thermodynamics') 
INSERT INTO temp_sgt_bisaccodes_2010 VALUES (
	'SCI079000',
	'Mechanics / Statics')  
INSERT INTO temp_sgt_bisaccodes_2010 VALUES (
	'SCI044000',
	'Metric System')  
INSERT INTO temp_sgt_bisaccodes_2010 VALUES (
	'SCI047000',
	'Microscopes & Microscopy')  
INSERT INTO temp_sgt_bisaccodes_2010 VALUES (
	'SCI074000',
	'Physics / Atomic & Molecular')   
INSERT INTO temp_sgt_bisaccodes_2010 VALUES (
	'SCI050000',
	'Nanoscience') 
INSERT INTO temp_sgt_bisaccodes_2010 VALUES (
	'SCI051000',
	'Physics / Nuclear')  
INSERT INTO temp_sgt_bisaccodes_2010 VALUES (
	'SCI053000',
	'Physics / Optics & Light')  
INSERT INTO temp_sgt_bisaccodes_2010 VALUES (
	'SCI054000',
	'Paleontology') 
INSERT INTO temp_sgt_bisaccodes_2010 VALUES (
	'SCI075000',
	'Philosophy & Social Aspects') 
INSERT INTO temp_sgt_bisaccodes_2010 VALUES (
	'SCI055000',
	'Physics / General') 
INSERT INTO temp_sgt_bisaccodes_2010 VALUES (
	'SCI057000',
	'Physics / Quantum Theory') 
INSERT INTO temp_sgt_bisaccodes_2010 VALUES (
	'SCI058000',
	'Radiation') 
INSERT INTO temp_sgt_bisaccodes_2010 VALUES (
	'SCI059000',
	'Radiology') 
INSERT INTO temp_sgt_bisaccodes_2010 VALUES (
	'SCI060000',
	'Reference') 
INSERT INTO temp_sgt_bisaccodes_2010 VALUES (
	'SCI061000',
	'Physics / Relativity ')  
INSERT INTO temp_sgt_bisaccodes_2010 VALUES (
	'SCI043000',
	'Research & Methodology') 
INSERT INTO temp_sgt_bisaccodes_2010 VALUES (
	'SCI076000',
	'Scientific Instruments') 
INSERT INTO temp_sgt_bisaccodes_2010 VALUES (
	'SCI077000',
	'Physics / Condensed Matter')  
INSERT INTO temp_sgt_bisaccodes_2010 VALUES (
	'SCI078000',
	'Spectroscopy & Spectrum Analysis')  
INSERT INTO temp_sgt_bisaccodes_2010 VALUES (
	'SCI063000',
	'Study & Teaching') 
INSERT INTO temp_sgt_bisaccodes_2010 VALUES (
	'SCI064000',
	'System Theory')  
INSERT INTO temp_sgt_bisaccodes_2010 VALUES (
	'SCI066000',
	'Time')  
INSERT INTO temp_sgt_bisaccodes_2010 VALUES (
	'SCI067000',
	'Waves & Wave Mechanics') 
INSERT INTO temp_sgt_bisaccodes_2010 VALUES (
	'SCI068000',
	'Weights & Measures')  
INSERT INTO temp_sgt_bisaccodes_2010 VALUES (
	'SEL000000',
	'General') 
INSERT INTO temp_sgt_bisaccodes_2010 VALUES (
	'SEL001000',
	'Abuse') 
INSERT INTO temp_sgt_bisaccodes_2010 VALUES (
	'SEL003000',
	'Adult Children of Substance Abusers  ') 
INSERT INTO temp_sgt_bisaccodes_2010 VALUES (
	'SEL004000',
	'Affirmations') 
INSERT INTO temp_sgt_bisaccodes_2010 VALUES (
	'SEL005000',
	'Aging') 
INSERT INTO temp_sgt_bisaccodes_2010 VALUES (
	'SEL033000',
	'Anger Management (see also FAMILY & RELATIONSHIPS / Anger)') 
INSERT INTO temp_sgt_bisaccodes_2010 VALUES (
	'SEL036000',
	'Anxieties & Phobias')  
INSERT INTO temp_sgt_bisaccodes_2010 VALUES (
	'SEL008000',
	'Codependency') 
INSERT INTO temp_sgt_bisaccodes_2010 VALUES (
	'SEL009000',
	'Creativity ')  
INSERT INTO temp_sgt_bisaccodes_2010 VALUES (
	'SEL010000',
	'Death, Grief, Bereavement') 
INSERT INTO temp_sgt_bisaccodes_2010 VALUES (
	'SEL011000',
	'Depression ')  
INSERT INTO temp_sgt_bisaccodes_2010 VALUES (
	'SEL012000',
	'Dreams')  
INSERT INTO temp_sgt_bisaccodes_2010 VALUES (
	'SEL014000',
	'Eating Disorders') 
INSERT INTO temp_sgt_bisaccodes_2010 VALUES (
	'SEL015000',
	'Handwriting Analysis') 
INSERT INTO temp_sgt_bisaccodes_2010 VALUES (
	'SEL018000',
	'Inner Child')  
INSERT INTO temp_sgt_bisaccodes_2010 VALUES (
	'SEL019000',
	'Meditations')  
INSERT INTO temp_sgt_bisaccodes_2010 VALUES (
	'SEL020000',
	'Mood Disorders') 
INSERT INTO temp_sgt_bisaccodes_2010 VALUES (
	'SEL021000',
	'Motivational & Inspirational') 
INSERT INTO temp_sgt_bisaccodes_2010 VALUES (
	'SEL031000',
	'Personal Growth / General') 
INSERT INTO temp_sgt_bisaccodes_2010 VALUES (
	'SEL016000',
	'Personal Growth / Happiness') 
INSERT INTO temp_sgt_bisaccodes_2010 VALUES (
	'SEL030000',
	'Personal Growth / Memory Improvement ') 
INSERT INTO temp_sgt_bisaccodes_2010 VALUES (
	'SEL023000',
	'Personal Growth / Self-Esteem ')  
INSERT INTO temp_sgt_bisaccodes_2010 VALUES (
	'SEL027000',
	'Personal Growth / Success') 
INSERT INTO temp_sgt_bisaccodes_2010 VALUES (
	'SEL017000',
	'Self-Hypnosis')  
INSERT INTO temp_sgt_bisaccodes_2010 VALUES (
	'SEL034000',
	'Sexual Instruction')  
INSERT INTO temp_sgt_bisaccodes_2010 VALUES (
	'SEL032000',
	'Spiritual') 
INSERT INTO temp_sgt_bisaccodes_2010 VALUES (
	'SEL024000',
	'Stress Management')   
INSERT INTO temp_sgt_bisaccodes_2010 VALUES (
	'SEL026000',
	'Substance Abuse & Addictions / General') 
INSERT INTO temp_sgt_bisaccodes_2010 VALUES (
	'SEL006000',
	'Substance Abuse & Addictions / Alcoholism')  
INSERT INTO temp_sgt_bisaccodes_2010 VALUES (
	'SEL013000',
	'Substance Abuse & Addictions / Drug Dependence')  
INSERT INTO temp_sgt_bisaccodes_2010 VALUES (
	'SEL026010',
	'Substance Abuse & Addictions / Tobacco') 
INSERT INTO temp_sgt_bisaccodes_2010 VALUES (
	'SEL035000',
	'Time Management')  
INSERT INTO temp_sgt_bisaccodes_2010 VALUES (
	'SEL029000',
	'Twelve-Step Programs') 
INSERT INTO temp_sgt_bisaccodes_2010 VALUES (
	'SOC000000',
	'General') 
INSERT INTO temp_sgt_bisaccodes_2010 VALUES (
	'SOC046000',
	'Abortion & Birth Control')  
INSERT INTO temp_sgt_bisaccodes_2010 VALUES (
	'SOC055000',
	'Agriculture & Food')  
INSERT INTO temp_sgt_bisaccodes_2010 VALUES (
	'SOC002000',
	'Anthropology / General') 
INSERT INTO temp_sgt_bisaccodes_2010 VALUES (
	'SOC002010',
	'Anthropology / Cultural')   
INSERT INTO temp_sgt_bisaccodes_2010 VALUES (
	'SOC002020',
	'Anthropology / Physical')   
INSERT INTO temp_sgt_bisaccodes_2010 VALUES (
	'SOC003000',
	'Archaeology')  
INSERT INTO temp_sgt_bisaccodes_2010 VALUES (
	'SOC056000',
	'Black Studies (Global)') 
INSERT INTO temp_sgt_bisaccodes_2010 VALUES (
	'SOC047000',
	'Children''s Studies')  
INSERT INTO temp_sgt_bisaccodes_2010 VALUES (
	'SOC004000',
	'Criminology')  
INSERT INTO temp_sgt_bisaccodes_2010 VALUES (
	'SOC005000',
	'Customs & Traditions') 
INSERT INTO temp_sgt_bisaccodes_2010 VALUES (
	'SOC036000',
	'Death & Dying')  
INSERT INTO temp_sgt_bisaccodes_2010 VALUES (
	'SOC006000',
	'Demography ')  
INSERT INTO temp_sgt_bisaccodes_2010 VALUES (
	'SOC042000',
	'Developing & Emerging Countries') 
INSERT INTO temp_sgt_bisaccodes_2010 VALUES (
	'SOC040000',
	'Disasters & Disaster Relief') 
INSERT INTO temp_sgt_bisaccodes_2010 VALUES (
	'SOC057000',
	'Disease & Health Issues')   
INSERT INTO temp_sgt_bisaccodes_2010 VALUES (
	'SOC031000',
	'Discrimination & Race Relations') 
INSERT INTO temp_sgt_bisaccodes_2010 VALUES (
	'SOC007000',
	'Emigration & Immigration')  
INSERT INTO temp_sgt_bisaccodes_2010 VALUES (
	'SOC041000',
	'Essays')  
INSERT INTO temp_sgt_bisaccodes_2010 VALUES (
	'SOC008000',
	'Ethnic Studies / General')  
INSERT INTO temp_sgt_bisaccodes_2010 VALUES (
	'SOC001000',
	'Ethnic Studies / African American Studies')  
INSERT INTO temp_sgt_bisaccodes_2010 VALUES (
	'SOC043000',
	'Ethnic Studies / Asian American Studies  ')  
INSERT INTO temp_sgt_bisaccodes_2010 VALUES (
	'SOC044000',
	'Ethnic Studies / Hispanic American Studies') 
INSERT INTO temp_sgt_bisaccodes_2010 VALUES (
	'SOC021000',
	'Ethnic Studies / Native American Studies ')  
INSERT INTO temp_sgt_bisaccodes_2010 VALUES (
	'SOC010000',
	'Feminism & Feminist Theory')  
INSERT INTO temp_sgt_bisaccodes_2010 VALUES (
	'SOC011000',
	'Folklore & Mythology') 
INSERT INTO temp_sgt_bisaccodes_2010 VALUES (
	'SOC038000',
	'Freemasonry & Secret Societies')  
INSERT INTO temp_sgt_bisaccodes_2010 VALUES (
	'SOC037000',
	'Future Studies') 
INSERT INTO temp_sgt_bisaccodes_2010 VALUES (
	'SOC012000',
	'Gay Studies')  
INSERT INTO temp_sgt_bisaccodes_2010 VALUES (
	'SOC032000',
	'Gender Studies') 
INSERT INTO temp_sgt_bisaccodes_2010 VALUES (
	'SOC013000',
	'Gerontology')  
INSERT INTO temp_sgt_bisaccodes_2010 VALUES (
	'SOC014000',
	'Holidays (non-religious)')  
INSERT INTO temp_sgt_bisaccodes_2010 VALUES (
	'SOC015000',
	'Human Geography')  
INSERT INTO temp_sgt_bisaccodes_2010 VALUES (
	'SOC016000',
	'Human Services') 
INSERT INTO temp_sgt_bisaccodes_2010 VALUES (
	'SOC048000',
	'Islamic Studies')  
INSERT INTO temp_sgt_bisaccodes_2010 VALUES (
	'SOC049000',
	'Jewish Studies') 
INSERT INTO temp_sgt_bisaccodes_2010 VALUES (
	'SOC017000',
	'Lesbian Studies')  
INSERT INTO temp_sgt_bisaccodes_2010 VALUES (
	'SOC052000',
	'Media Studies')  
INSERT INTO temp_sgt_bisaccodes_2010 VALUES (
	'SOC018000',
	'Men''s Studies')  
INSERT INTO temp_sgt_bisaccodes_2010 VALUES (
	'SOC019000',
	'Methodology')  
INSERT INTO temp_sgt_bisaccodes_2010 VALUES (
	'SOC020000',
	'Minority Studies') 
INSERT INTO temp_sgt_bisaccodes_2010 VALUES (
	'SOC030000',
	'Penology')  
INSERT INTO temp_sgt_bisaccodes_2010 VALUES (
	'SOC029000',
	'People with Disabilities')  
INSERT INTO temp_sgt_bisaccodes_2010 VALUES (
	'SOC033000',
	'Philanthropy & Charity') 
INSERT INTO temp_sgt_bisaccodes_2010 VALUES (
	'SOC022000',
	'Popular Culture')  
INSERT INTO temp_sgt_bisaccodes_2010 VALUES (
	'SOC034000',
	'Pornography')  
INSERT INTO temp_sgt_bisaccodes_2010 VALUES (
	'SOC045000',
	'Poverty & Homelessness') 
INSERT INTO temp_sgt_bisaccodes_2010 VALUES (
	'SOC023000',
	'Reference') 
INSERT INTO temp_sgt_bisaccodes_2010 VALUES (
	'SOC053000',
	'Regional Studies') 
INSERT INTO temp_sgt_bisaccodes_2010 VALUES (
	'SOC024000',
	'Research')  
INSERT INTO temp_sgt_bisaccodes_2010 VALUES (
	'SOC054000',
	'Slavery') 
INSERT INTO temp_sgt_bisaccodes_2010 VALUES (
	'SOC050000',
	'Social Classes') 
INSERT INTO temp_sgt_bisaccodes_2010 VALUES (
	'SOC025000',
	'Social Work')  
INSERT INTO temp_sgt_bisaccodes_2010 VALUES (
	'SOC026000',
	'Sociology / General')  
INSERT INTO temp_sgt_bisaccodes_2010 VALUES (
	'SOC026010',
	'Sociology / Marriage & Family ')  
INSERT INTO temp_sgt_bisaccodes_2010 VALUES (
	'SOC026020',
	'Sociology / Rural')   
INSERT INTO temp_sgt_bisaccodes_2010 VALUES (
	'SOC026030',
	'Sociology / Urban')   
INSERT INTO temp_sgt_bisaccodes_2010 VALUES (
	'SOC039000',
	'Sociology of Religion')  
INSERT INTO temp_sgt_bisaccodes_2010 VALUES (
	'SOC027000',
	'Statistics ')  
INSERT INTO temp_sgt_bisaccodes_2010 VALUES (
	'SOC051000',
	'Violence in Society')  
INSERT INTO temp_sgt_bisaccodes_2010 VALUES (
	'SOC035000',
	'Volunteer Work') 
INSERT INTO temp_sgt_bisaccodes_2010 VALUES (
	'SOC028000',
	'Women''s Studies')  
INSERT INTO temp_sgt_bisaccodes_2010 VALUES (
	'SPO000000',
	'General') 
INSERT INTO temp_sgt_bisaccodes_2010 VALUES (
	'SPO001000',
	'Air Sports ')  
INSERT INTO temp_sgt_bisaccodes_2010 VALUES (
	'SPO002000',
	'Archery') 
INSERT INTO temp_sgt_bisaccodes_2010 VALUES (
	'SPO003000',
	'Baseball / General')  
INSERT INTO temp_sgt_bisaccodes_2010 VALUES (
	'SPO003020',
	'Baseball / Essays & Writings') 
INSERT INTO temp_sgt_bisaccodes_2010 VALUES (
	'SPO003030',
	'Baseball / History')  
INSERT INTO temp_sgt_bisaccodes_2010 VALUES (
	'SPO003040',
	'Baseball / Statistics')  
INSERT INTO temp_sgt_bisaccodes_2010 VALUES (
	'SPO004000',
	'Basketball ')  
INSERT INTO temp_sgt_bisaccodes_2010 VALUES (
	'SPO005000',
	'Boating') 
INSERT INTO temp_sgt_bisaccodes_2010 VALUES (
	'SPO006000',
	'Bodybuilding & Weight Training')  
INSERT INTO temp_sgt_bisaccodes_2010 VALUES (
	'SPO007000',
	'Bowling') 
INSERT INTO temp_sgt_bisaccodes_2010 VALUES (
	'SPO008000',
	'Boxing')  
INSERT INTO temp_sgt_bisaccodes_2010 VALUES (
	'SPO068000',
	'Business Aspects') 
INSERT INTO temp_sgt_bisaccodes_2010 VALUES (
	'SPO009000',
	'Camping') 
INSERT INTO temp_sgt_bisaccodes_2010 VALUES (
	'SPO010000',
	'Canoeing')  
INSERT INTO temp_sgt_bisaccodes_2010 VALUES (
	'SPO070000',
	'Cheerleading') 
INSERT INTO temp_sgt_bisaccodes_2010 VALUES (
	'SPO061000',
	'Coaching / General')  
INSERT INTO temp_sgt_bisaccodes_2010 VALUES (
	'SPO003010',
	'Coaching / Baseball')  
INSERT INTO temp_sgt_bisaccodes_2010 VALUES (
	'SPO061010',
	'Coaching / Basketball')  
INSERT INTO temp_sgt_bisaccodes_2010 VALUES (
	'SPO061020',
	'Coaching / Football')  
INSERT INTO temp_sgt_bisaccodes_2010 VALUES (
	'SPO061030',
	'Coaching / Soccer')   
INSERT INTO temp_sgt_bisaccodes_2010 VALUES (
	'SPO054000',
	'Cricket') 
INSERT INTO temp_sgt_bisaccodes_2010 VALUES (
	'SPO011000',
	'Cycling') 
INSERT INTO temp_sgt_bisaccodes_2010 VALUES (
	'SPO062000',
	'Dog Racing ')  
INSERT INTO temp_sgt_bisaccodes_2010 VALUES (
	'SPO057000',
	'Equestrian ')  
INSERT INTO temp_sgt_bisaccodes_2010 VALUES (
	'SPO063000',
	'Equipment & Supplies') 
INSERT INTO temp_sgt_bisaccodes_2010 VALUES (
	'SPO012000',
	'Essays')  
INSERT INTO temp_sgt_bisaccodes_2010 VALUES (
	'SPO064000',
	'Extreme Sports') 
INSERT INTO temp_sgt_bisaccodes_2010 VALUES (
	'SPO071000',
	'Fencing') 
INSERT INTO temp_sgt_bisaccodes_2010 VALUES (
	'SPO013000',
	'Field Sports') 
INSERT INTO temp_sgt_bisaccodes_2010 VALUES (
	'SPO014000',
	'Fishing') 
INSERT INTO temp_sgt_bisaccodes_2010 VALUES (
	'SPO015000',
	'Football')  
INSERT INTO temp_sgt_bisaccodes_2010 VALUES (
	'SPO016000',
	'Golf')  
INSERT INTO temp_sgt_bisaccodes_2010 VALUES (
	'SPO017000',
	'Gymnastics ')  
INSERT INTO temp_sgt_bisaccodes_2010 VALUES (
	'SPO018000',
	'Hiking')  
INSERT INTO temp_sgt_bisaccodes_2010 VALUES (
	'SPO019000',
	'History') 
INSERT INTO temp_sgt_bisaccodes_2010 VALUES (
	'SPO020000',
	'Hockey')  
INSERT INTO temp_sgt_bisaccodes_2010 VALUES (
	'SPO021000',
	'Horse Racing') 
INSERT INTO temp_sgt_bisaccodes_2010 VALUES (
	'SPO022000',
	'Hunting') 
INSERT INTO temp_sgt_bisaccodes_2010 VALUES (
	'SPO023000',
	'Ice & Figure Skating') 
INSERT INTO temp_sgt_bisaccodes_2010 VALUES (
	'SPO024000',
	'Juggling')  
INSERT INTO temp_sgt_bisaccodes_2010 VALUES (
	'SPO025000',
	'Kayaking')  
INSERT INTO temp_sgt_bisaccodes_2010 VALUES (
	'SPO026000',
	'Lacrosse')  
INSERT INTO temp_sgt_bisaccodes_2010 VALUES (
	'SPO027000',
	'Martial Arts & Self-Defense') 
INSERT INTO temp_sgt_bisaccodes_2010 VALUES (
	'SPO028000',
	'Motor Sports') 
INSERT INTO temp_sgt_bisaccodes_2010 VALUES (
	'SPO029000',
	'Mountaineering') 
INSERT INTO temp_sgt_bisaccodes_2010 VALUES (
	'SPO058000',
	'Olympics')  
INSERT INTO temp_sgt_bisaccodes_2010 VALUES (
	'SPO030000',
	'Outdoor Skills') 
INSERT INTO temp_sgt_bisaccodes_2010 VALUES (
	'SPO055000',
	'Polo')  
INSERT INTO temp_sgt_bisaccodes_2010 VALUES (
	'SPO060000',
	'Pool, Billiards, Snooker')  
INSERT INTO temp_sgt_bisaccodes_2010 VALUES (
	'SPO031000',
	'Racket Sports')  
INSERT INTO temp_sgt_bisaccodes_2010 VALUES (
	'SPO032000',
	'Racquetball')  
INSERT INTO temp_sgt_bisaccodes_2010 VALUES (
	'SPO033000',
	'Reference') 
INSERT INTO temp_sgt_bisaccodes_2010 VALUES (
	'SPO065000',
	'Rodeos')  
INSERT INTO temp_sgt_bisaccodes_2010 VALUES (
	'SPO034000',
	'Roller & In-Line Skating')  
INSERT INTO temp_sgt_bisaccodes_2010 VALUES (
	'SPO056000',
	'Rugby') 
INSERT INTO temp_sgt_bisaccodes_2010 VALUES (
	'SPO035000',
	'Running & Jogging')   
INSERT INTO temp_sgt_bisaccodes_2010 VALUES (
	'SPO036000',
	'Sailing') 
INSERT INTO temp_sgt_bisaccodes_2010 VALUES (
	'SPO059000',
	'Scuba & Snorkeling')  
INSERT INTO temp_sgt_bisaccodes_2010 VALUES (
	'SPO037000',
	'Shooting')  
INSERT INTO temp_sgt_bisaccodes_2010 VALUES (
	'SPO038000',
	'Skateboarding')  
INSERT INTO temp_sgt_bisaccodes_2010 VALUES (
	'SPO039000',
	'Skiing')  
INSERT INTO temp_sgt_bisaccodes_2010 VALUES (
	'SPO072000',
	'Snowboarding') 
INSERT INTO temp_sgt_bisaccodes_2010 VALUES (
	'SPO040000',
	'Soccer')  
INSERT INTO temp_sgt_bisaccodes_2010 VALUES (
	'SPO066000',
	'Sociology of Sports')  
INSERT INTO temp_sgt_bisaccodes_2010 VALUES (
	'SPO067000',
	'Softball')  
INSERT INTO temp_sgt_bisaccodes_2010 VALUES (
	'SPO041000',
	'Sports Psychology')   
INSERT INTO temp_sgt_bisaccodes_2010 VALUES (
	'SPO042000',
	'Squash')  
INSERT INTO temp_sgt_bisaccodes_2010 VALUES (
	'SPO069000',
	'Surfing') 
INSERT INTO temp_sgt_bisaccodes_2010 VALUES (
	'SPO043000',
	'Swimming & Diving')   
INSERT INTO temp_sgt_bisaccodes_2010 VALUES (
	'SPO044000',
	'Table Tennis') 
INSERT INTO temp_sgt_bisaccodes_2010 VALUES (
	'SPO045000',
	'Tennis')  
INSERT INTO temp_sgt_bisaccodes_2010 VALUES (
	'SPO046000',
	'Track & Field')  
INSERT INTO temp_sgt_bisaccodes_2010 VALUES (
	'SPO047000',
	'Training')  
INSERT INTO temp_sgt_bisaccodes_2010 VALUES (
	'SPO048000',
	'Triathlon') 
INSERT INTO temp_sgt_bisaccodes_2010 VALUES (
	'SPO049000',
	'Volleyball ')  
INSERT INTO temp_sgt_bisaccodes_2010 VALUES (
	'SPO050000',
	'Walking') 
INSERT INTO temp_sgt_bisaccodes_2010 VALUES (
	'SPO051000',
	'Water Sports') 
INSERT INTO temp_sgt_bisaccodes_2010 VALUES (
	'SPO052000',
	'Winter Sports')  
INSERT INTO temp_sgt_bisaccodes_2010 VALUES (
	'SPO053000',
	'Wrestling') 
INSERT INTO temp_sgt_bisaccodes_2010 VALUES (
	'STU000000',
	'General') 
INSERT INTO temp_sgt_bisaccodes_2010 VALUES (
	'STU001000',
	'ACT') 
INSERT INTO temp_sgt_bisaccodes_2010 VALUES (
	'STU002000',
	'Advanced Placement')  
INSERT INTO temp_sgt_bisaccodes_2010 VALUES (
	'STU003000',
	'Armed Forces') 
INSERT INTO temp_sgt_bisaccodes_2010 VALUES (
	'STU004000',
	'Book Notes (see also JUVENILE NONFICTION / Study Aids / Book Notes)  ')  
INSERT INTO temp_sgt_bisaccodes_2010 VALUES (
	'STU006000',
	'Citizenship')  
INSERT INTO temp_sgt_bisaccodes_2010 VALUES (
	'STU007000',
	'Civil Service')  
INSERT INTO temp_sgt_bisaccodes_2010 VALUES (
	'STU008000',
	'CLEP (College-Level Examination Program) ')  
INSERT INTO temp_sgt_bisaccodes_2010 VALUES (
	'STU009000',
	'College Entrance') 
INSERT INTO temp_sgt_bisaccodes_2010 VALUES (
	'STU010000',
	'College Guides') 
INSERT INTO temp_sgt_bisaccodes_2010 VALUES (
	'STU011000',
	'CPA (Certified Public Accountant)') 
INSERT INTO temp_sgt_bisaccodes_2010 VALUES (
	'STU031000',
	'Financial Aid')  
INSERT INTO temp_sgt_bisaccodes_2010 VALUES (
	'STU012000',
	'GED (General Educational Development Tests) ')  
INSERT INTO temp_sgt_bisaccodes_2010 VALUES (
	'STU013000',
	'GMAT (Graduate Management Admission Test)')  
INSERT INTO temp_sgt_bisaccodes_2010 VALUES (
	'STU014000',
	'Graduate Preparation') 
INSERT INTO temp_sgt_bisaccodes_2010 VALUES (
	'STU015000',
	'Graduate School Guides') 
INSERT INTO temp_sgt_bisaccodes_2010 VALUES (
	'STU016000',
	'GRE (Graduate Record Examination)') 
INSERT INTO temp_sgt_bisaccodes_2010 VALUES (
	'STU025000',
	'High School Entrance') 
INSERT INTO temp_sgt_bisaccodes_2010 VALUES (
	'STU017000',
	'LSAT (Law School Admission Test)')  
INSERT INTO temp_sgt_bisaccodes_2010 VALUES (
	'STU018000',
	'MAT (Miller Analogies Test)') 
INSERT INTO temp_sgt_bisaccodes_2010 VALUES (
	'STU032000',
	'MCAT (Medical College Admission Test)') 
INSERT INTO temp_sgt_bisaccodes_2010 VALUES (
	'STU019000',
	'NTE (National Teacher Examinations)  ') 
INSERT INTO temp_sgt_bisaccodes_2010 VALUES (
	'STU021000',
	'Professional') 
INSERT INTO temp_sgt_bisaccodes_2010 VALUES (
	'STU033000',
	'PSAT & NMSQT (National Merit Scholarship Qualifying Test)') 
INSERT INTO temp_sgt_bisaccodes_2010 VALUES (
	'STU022000',
	'Regents') 
INSERT INTO temp_sgt_bisaccodes_2010 VALUES (
	'STU024000',
	'SAT') 
INSERT INTO temp_sgt_bisaccodes_2010 VALUES (
	'STU026000',
	'Study Guides') 
INSERT INTO temp_sgt_bisaccodes_2010 VALUES (
	'STU027000',
	'Tests') 
INSERT INTO temp_sgt_bisaccodes_2010 VALUES (
	'STU028000',
	'TOEFL (Test of English as a Foreign Language)') 
INSERT INTO temp_sgt_bisaccodes_2010 VALUES (
	'STU029000',
	'Vocational ')  
INSERT INTO temp_sgt_bisaccodes_2010 VALUES (
	'STU030000',
	'Workbooks') 
INSERT INTO temp_sgt_bisaccodes_2010 VALUES (
	'TEC000000',
	'General') 
INSERT INTO temp_sgt_bisaccodes_2010 VALUES (
	'TEC001000',
	'Acoustics & Sound')   
INSERT INTO temp_sgt_bisaccodes_2010 VALUES (
	'TEC002000',
	'Aeronautics & Astronautics')  
INSERT INTO temp_sgt_bisaccodes_2010 VALUES (
	'TEC003000',
	'Agriculture / General')  
INSERT INTO temp_sgt_bisaccodes_2010 VALUES (
	'TEC003080',
	'Agriculture / Agronomy / General')  
INSERT INTO temp_sgt_bisaccodes_2010 VALUES (
	'TEC003030',
	'Agriculture / Agronomy / Crop Science') 
INSERT INTO temp_sgt_bisaccodes_2010 VALUES (
	'TEC003060',
	'Agriculture / Agronomy / Soil Science') 
INSERT INTO temp_sgt_bisaccodes_2010 VALUES (
	'TEC003020',
	'Agriculture / Animal Husbandry')  
INSERT INTO temp_sgt_bisaccodes_2010 VALUES (
	'TEC003040',
	'Agriculture / Forestry') 
INSERT INTO temp_sgt_bisaccodes_2010 VALUES (
	'TEC003050',
	'Agriculture / Irrigation')  
INSERT INTO temp_sgt_bisaccodes_2010 VALUES (
	'TEC003090',
	'Agriculture / Organic')  
INSERT INTO temp_sgt_bisaccodes_2010 VALUES (
	'TEC003070',
	'Agriculture / Sustainable Agriculture') 
INSERT INTO temp_sgt_bisaccodes_2010 VALUES (
	'TEC003010',
	'Agriculture / Tropical Agriculture   ') 
INSERT INTO temp_sgt_bisaccodes_2010 VALUES (
	'TEC004000',
	'Automation ')  
INSERT INTO temp_sgt_bisaccodes_2010 VALUES (
	'TEC009090',
	'Automotive ')  
INSERT INTO temp_sgt_bisaccodes_2010 VALUES (
	'TEC059000',
	'Biomedical ')  
INSERT INTO temp_sgt_bisaccodes_2010 VALUES (
	'TEC048000',
	'Cartography')  
INSERT INTO temp_sgt_bisaccodes_2010 VALUES (
	'TEC009010',
	'Chemical & Biochemical') 
INSERT INTO temp_sgt_bisaccodes_2010 VALUES (
	'TEC009020',
	'Civil / General')  
INSERT INTO temp_sgt_bisaccodes_2010 VALUES (
	'TEC009100',
	'Civil / Bridges')  
INSERT INTO temp_sgt_bisaccodes_2010 VALUES (
	'TEC009110',
	'Civil / Dams & Reservoirs') 
INSERT INTO temp_sgt_bisaccodes_2010 VALUES (
	'TEC009120',
	'Civil / Earthquake')  
INSERT INTO temp_sgt_bisaccodes_2010 VALUES (
	'TEC009130',
	'Civil / Flood Control')  
INSERT INTO temp_sgt_bisaccodes_2010 VALUES (
	'TEC009140',
	'Civil / Highway & Traffic') 
INSERT INTO temp_sgt_bisaccodes_2010 VALUES (
	'TEC009150',
	'Civil / Soil & Rock')  
INSERT INTO temp_sgt_bisaccodes_2010 VALUES (
	'TEC009160',
	'Civil / Transport')   
INSERT INTO temp_sgt_bisaccodes_2010 VALUES (
	'TEC005000',
	'Construction / General') 
INSERT INTO temp_sgt_bisaccodes_2010 VALUES (
	'TEC005010',
	'Construction / Carpentry')  
INSERT INTO temp_sgt_bisaccodes_2010 VALUES (
	'TEC005020',
	'Construction / Contracting')  
INSERT INTO temp_sgt_bisaccodes_2010 VALUES (
	'TEC005030',
	'Construction / Electrical') 
INSERT INTO temp_sgt_bisaccodes_2010 VALUES (
	'TEC005040',
	'Construction / Estimating') 
INSERT INTO temp_sgt_bisaccodes_2010 VALUES (
	'TEC005050',
	'Construction / Heating, Ventilation & Air Conditioning   ') 
INSERT INTO temp_sgt_bisaccodes_2010 VALUES (
	'TEC005060',
	'Construction / Masonry') 
INSERT INTO temp_sgt_bisaccodes_2010 VALUES (
	'TEC005070',
	'Construction / Plumbing')   
INSERT INTO temp_sgt_bisaccodes_2010 VALUES (
	'TEC005080',
	'Construction / Roofing') 
INSERT INTO temp_sgt_bisaccodes_2010 VALUES (
	'TEC006000',
	'Drafting & Mechanical Drawing ')  
INSERT INTO temp_sgt_bisaccodes_2010 VALUES (
	'TEC007000',
	'Electrical ')  
INSERT INTO temp_sgt_bisaccodes_2010 VALUES (
	'TEC008000',
	'Electronics / General')  
INSERT INTO temp_sgt_bisaccodes_2010 VALUES (
	'TEC008010',
	'Electronics / Circuits / General')  
INSERT INTO temp_sgt_bisaccodes_2010 VALUES (
	'TEC008020',
	'Electronics / Circuits / Integrated  ') 
INSERT INTO temp_sgt_bisaccodes_2010 VALUES (
	'TEC008030',
	'Electronics / Circuits / Logic')  
INSERT INTO temp_sgt_bisaccodes_2010 VALUES (
	'TEC008050',
	'Electronics / Circuits / VLSI & ULSI ') 
INSERT INTO temp_sgt_bisaccodes_2010 VALUES (
	'TEC008060',
	'Electronics / Digital')  
INSERT INTO temp_sgt_bisaccodes_2010 VALUES (
	'TEC008070',
	'Electronics / Microelectronics')  
INSERT INTO temp_sgt_bisaccodes_2010 VALUES (
	'TEC008080',
	'Electronics / Optoelectronics ')  
INSERT INTO temp_sgt_bisaccodes_2010 VALUES (
	'TEC008090',
	'Electronics / Semiconductors') 
INSERT INTO temp_sgt_bisaccodes_2010 VALUES (
	'TEC008100',
	'Electronics / Solid State') 
INSERT INTO temp_sgt_bisaccodes_2010 VALUES (
	'TEC008110',
	'Electronics / Transistors') 
INSERT INTO temp_sgt_bisaccodes_2010 VALUES (
	'TEC009000',
	'Engineering (General)')  
INSERT INTO temp_sgt_bisaccodes_2010 VALUES (
	'TEC010000',
	'Environmental / General')   
INSERT INTO temp_sgt_bisaccodes_2010 VALUES (
	'TEC010010',
	'Environmental / Pollution Control') 
INSERT INTO temp_sgt_bisaccodes_2010 VALUES (
	'TEC010020',
	'Environmental / Waste Management')  
INSERT INTO temp_sgt_bisaccodes_2010 VALUES (
	'TEC010030',
	'Environmental / Water Supply') 
INSERT INTO temp_sgt_bisaccodes_2010 VALUES (
	'TEC011000',
	'Fiber Optics') 
INSERT INTO temp_sgt_bisaccodes_2010 VALUES (
	'TEC045000',
	'Fire Science') 
INSERT INTO temp_sgt_bisaccodes_2010 VALUES (
	'TEC049000',
	'Fisheries & Aquaculture')   
INSERT INTO temp_sgt_bisaccodes_2010 VALUES (
	'TEC012000',
	'Food Science') 
INSERT INTO temp_sgt_bisaccodes_2010 VALUES (
	'TEC013000',
	'Fracture Mechanics')  
INSERT INTO temp_sgt_bisaccodes_2010 VALUES (
	'TEC056000',
	'History') 
INSERT INTO temp_sgt_bisaccodes_2010 VALUES (
	'TEC050000',
	'Holography ')  
INSERT INTO temp_sgt_bisaccodes_2010 VALUES (
	'TEC014000',
	'Hydraulics ')  
INSERT INTO temp_sgt_bisaccodes_2010 VALUES (
	'TEC015000',
	'Imaging Systems')  
INSERT INTO temp_sgt_bisaccodes_2010 VALUES (
	'TEC016000',
	'Industrial Design / General') 
INSERT INTO temp_sgt_bisaccodes_2010 VALUES (
	'TEC016010',
	'Industrial Design / Packaging ')  
INSERT INTO temp_sgt_bisaccodes_2010 VALUES (
	'TEC016020',
	'Industrial Design / Product') 
INSERT INTO temp_sgt_bisaccodes_2010 VALUES (
	'TEC009060',
	'Industrial Engineering') 
INSERT INTO temp_sgt_bisaccodes_2010 VALUES (
	'TEC017000',
	'Industrial Health & Safety')  
INSERT INTO temp_sgt_bisaccodes_2010 VALUES (
	'TEC018000',
	'Industrial Technology')  
INSERT INTO temp_sgt_bisaccodes_2010 VALUES (
	'TEC057000',
	'Inventions ')  
INSERT INTO temp_sgt_bisaccodes_2010 VALUES (
	'TEC019000',
	'Lasers & Photonics')  
INSERT INTO temp_sgt_bisaccodes_2010 VALUES (
	'TEC046000',
	'Machinery') 
INSERT INTO temp_sgt_bisaccodes_2010 VALUES (
	'TEC020000',
	'Manufacturing')  
INSERT INTO temp_sgt_bisaccodes_2010 VALUES (
	'TEC060000',
	'Marine & Naval') 
INSERT INTO temp_sgt_bisaccodes_2010 VALUES (
	'TEC021000',
	'Material Science') 
INSERT INTO temp_sgt_bisaccodes_2010 VALUES (
	'TEC009070',
	'Mechanical ')  
INSERT INTO temp_sgt_bisaccodes_2010 VALUES (
	'TEC022000',
	'Measurement')  
INSERT INTO temp_sgt_bisaccodes_2010 VALUES (
	'TEC023000',
	'Metallurgy ')  
INSERT INTO temp_sgt_bisaccodes_2010 VALUES (
	'TEC024000',
	'Microwaves ')  
INSERT INTO temp_sgt_bisaccodes_2010 VALUES (
	'TEC025000',
	'Military Science') 
INSERT INTO temp_sgt_bisaccodes_2010 VALUES (
	'TEC026000',
	'Mining')  
INSERT INTO temp_sgt_bisaccodes_2010 VALUES (
	'TEC061000',
	'Mobile & Wireless Communications')  
INSERT INTO temp_sgt_bisaccodes_2010 VALUES (
	'TEC027000',
	'Nanotechnology & MEMS')  
INSERT INTO temp_sgt_bisaccodes_2010 VALUES (
	'TEC029000',
	'Operations Research')  
INSERT INTO temp_sgt_bisaccodes_2010 VALUES (
	'TEC030000',
	'Optics')  
INSERT INTO temp_sgt_bisaccodes_2010 VALUES (
	'TEC058000',
	'Pest Control') 
INSERT INTO temp_sgt_bisaccodes_2010 VALUES (
	'TEC047000',
	'Petroleum') 
INSERT INTO temp_sgt_bisaccodes_2010 VALUES (
	'TEC031000',
	'Power Resources / General') 
INSERT INTO temp_sgt_bisaccodes_2010 VALUES (
	'TEC031010',
	'Power Resources / Alternative & Renewable')  
INSERT INTO temp_sgt_bisaccodes_2010 VALUES (
	'TEC031020',
	'Power Resources / Electrical') 
INSERT INTO temp_sgt_bisaccodes_2010 VALUES (
	'TEC031030',
	'Power Resources / Fossil Fuels')  
INSERT INTO temp_sgt_bisaccodes_2010 VALUES (
	'TEC028000',
	'Power Resources / Nuclear') 
INSERT INTO temp_sgt_bisaccodes_2010 VALUES (
	'TEC062000',
	'Project Management')  
INSERT INTO temp_sgt_bisaccodes_2010 VALUES (
	'TEC032000',
	'Quality Control')  
INSERT INTO temp_sgt_bisaccodes_2010 VALUES (
	'TEC033000',
	'Radar') 
INSERT INTO temp_sgt_bisaccodes_2010 VALUES (
	'TEC034000',
	'Radio') 
INSERT INTO temp_sgt_bisaccodes_2010 VALUES (
	'TEC035000',
	'Reference') 
INSERT INTO temp_sgt_bisaccodes_2010 VALUES (
	'TEC036000',
	'Remote Sensing & Geographic Information Systems') 
INSERT INTO temp_sgt_bisaccodes_2010 VALUES (
	'TEC037000',
	'Robotics')  
INSERT INTO temp_sgt_bisaccodes_2010 VALUES (
	'TEC064000',
	'Sensors') 
INSERT INTO temp_sgt_bisaccodes_2010 VALUES (
	'TEC052000',
	'Social Aspects') 
INSERT INTO temp_sgt_bisaccodes_2010 VALUES (
	'TEC063000',
	'Structural ')  
INSERT INTO temp_sgt_bisaccodes_2010 VALUES (
	'TEC039000',
	'Superconductors & Superconductivity  ') 
INSERT INTO temp_sgt_bisaccodes_2010 VALUES (
	'TEC054000',
	'Surveying') 
INSERT INTO temp_sgt_bisaccodes_2010 VALUES (
	'TEC040000',
	'Technical & Manufacturing Industries & Trades') 
INSERT INTO temp_sgt_bisaccodes_2010 VALUES (
	'TEC044000',
	'Technical Writing')   
INSERT INTO temp_sgt_bisaccodes_2010 VALUES (
	'TEC041000',
	'Telecommunications')  
INSERT INTO temp_sgt_bisaccodes_2010 VALUES (
	'TEC043000',
	'Television & Video')  
INSERT INTO temp_sgt_bisaccodes_2010 VALUES (
	'TEC055000',
	'Textiles & Polymers')  
INSERT INTO temp_sgt_bisaccodes_2010 VALUES (
	'TRA000000',
	'General') 
INSERT INTO temp_sgt_bisaccodes_2010 VALUES (
	'TRA001000',
	'Automotive / General') 
INSERT INTO temp_sgt_bisaccodes_2010 VALUES (
	'TRA001010',
	'Automotive / Antique & Classic')  
INSERT INTO temp_sgt_bisaccodes_2010 VALUES (
	'TRA001020',
	'Automotive / Buyer''s Guides') 
INSERT INTO temp_sgt_bisaccodes_2010 VALUES (
	'TRA001030',
	'Automotive / Customizing')  
INSERT INTO temp_sgt_bisaccodes_2010 VALUES (
	'TRA001050',
	'Automotive / History') 
INSERT INTO temp_sgt_bisaccodes_2010 VALUES (
	'TRA001060',
	'Automotive / Pictorial') 
INSERT INTO temp_sgt_bisaccodes_2010 VALUES (
	'TRA001140',
	'Automotive / Repair & Maintenance') 
INSERT INTO temp_sgt_bisaccodes_2010 VALUES (
	'TRA001150',
	'Automotive / Trucks')  
INSERT INTO temp_sgt_bisaccodes_2010 VALUES (
	'TRA002000',
	'Aviation / General')  
INSERT INTO temp_sgt_bisaccodes_2010 VALUES (
	'TRA002040',
	'Aviation / Commercial')  
INSERT INTO temp_sgt_bisaccodes_2010 VALUES (
	'TRA002010',
	'Aviation / History')  
INSERT INTO temp_sgt_bisaccodes_2010 VALUES (
	'TRA002050',
	'Aviation / Piloting & Flight Instruction ')  
INSERT INTO temp_sgt_bisaccodes_2010 VALUES (
	'TRA002030',
	'Aviation / Repair & Maintenance') 
INSERT INTO temp_sgt_bisaccodes_2010 VALUES (
	'TRA003000',
	'Motorcycles / General')  
INSERT INTO temp_sgt_bisaccodes_2010 VALUES (
	'TRA003010',
	'Motorcycles / History')  
INSERT INTO temp_sgt_bisaccodes_2010 VALUES (
	'TRA003020',
	'Motorcycles / Pictorial')   
INSERT INTO temp_sgt_bisaccodes_2010 VALUES (
	'TRA003030',
	'Motorcycles / Repair & Maintenance   ') 
INSERT INTO temp_sgt_bisaccodes_2010 VALUES (
	'TRA008000',
	'Navigation ')  
INSERT INTO temp_sgt_bisaccodes_2010 VALUES (
	'TRA009000',
	'Public Transportation')  
INSERT INTO temp_sgt_bisaccodes_2010 VALUES (
	'TRA004000',
	'Railroads / General')  
INSERT INTO temp_sgt_bisaccodes_2010 VALUES (
	'TRA004010',
	'Railroads / History')  
INSERT INTO temp_sgt_bisaccodes_2010 VALUES (
	'TRA004020',
	'Railroads / Pictorial')  
INSERT INTO temp_sgt_bisaccodes_2010 VALUES (
	'TRA006000',
	'Ships & Shipbuilding / General')  
INSERT INTO temp_sgt_bisaccodes_2010 VALUES (
	'TRA006010',
	'Ships & Shipbuilding / History')  
INSERT INTO temp_sgt_bisaccodes_2010 VALUES (
	'TRA006020',
	'Ships & Shipbuilding / Pictorial')  
INSERT INTO temp_sgt_bisaccodes_2010 VALUES (
	'TRA006030',
	'Ships & Shipbuilding / Repair & Maintenance ')  
INSERT INTO temp_sgt_bisaccodes_2010 VALUES (
	'TRV000000',
	'General') 
INSERT INTO temp_sgt_bisaccodes_2010 VALUES (
	'TRV002000',
	'Africa / General') 
INSERT INTO temp_sgt_bisaccodes_2010 VALUES (
	'TRV002010',
	'Africa / Central') 
INSERT INTO temp_sgt_bisaccodes_2010 VALUES (
	'TRV002020',
	'Africa / East')  
INSERT INTO temp_sgt_bisaccodes_2010 VALUES (
	'TRV002030',
	'Africa / Kenya') 
INSERT INTO temp_sgt_bisaccodes_2010 VALUES (
	'TRV002040',
	'Africa / Morocco') 
INSERT INTO temp_sgt_bisaccodes_2010 VALUES (
	'TRV002050',
	'Africa / North') 
INSERT INTO temp_sgt_bisaccodes_2010 VALUES (
	'TRV002060',
	'Africa / Republic of South Africa') 
INSERT INTO temp_sgt_bisaccodes_2010 VALUES (
	'TRV002070',
	'Africa / South') 
INSERT INTO temp_sgt_bisaccodes_2010 VALUES (
	'TRV002080',
	'Africa / West')  
INSERT INTO temp_sgt_bisaccodes_2010 VALUES (
	'TRV029000',
	'Amusement & Theme Parks')   
INSERT INTO temp_sgt_bisaccodes_2010 VALUES (
	'TRV003000',
	'Asia / General') 
INSERT INTO temp_sgt_bisaccodes_2010 VALUES (
	'TRV003010',
	'Asia / Central') 
INSERT INTO temp_sgt_bisaccodes_2010 VALUES (
	'TRV003020',
	'Asia / China') 
INSERT INTO temp_sgt_bisaccodes_2010 VALUES (
	'TRV003030',
	'Asia / Far East')  
INSERT INTO temp_sgt_bisaccodes_2010 VALUES (
	'TRV003040',
	'Asia / India') 
INSERT INTO temp_sgt_bisaccodes_2010 VALUES (
	'TRV003050',
	'Asia / Japan') 
INSERT INTO temp_sgt_bisaccodes_2010 VALUES (
	'TRV003060',
	'Asia / Southeast') 
INSERT INTO temp_sgt_bisaccodes_2010 VALUES (
	'TRV003070',
	'Asia / Southwest') 
INSERT INTO temp_sgt_bisaccodes_2010 VALUES (
	'TRV004000',
	'Australia & Oceania')  
INSERT INTO temp_sgt_bisaccodes_2010 VALUES (
	'TRV005000',
	'Bed & Breakfast')  
INSERT INTO temp_sgt_bisaccodes_2010 VALUES (
	'TRV033000',
	'Budget')  
INSERT INTO temp_sgt_bisaccodes_2010 VALUES (
	'TRV006000',
	'Canada / General') 
INSERT INTO temp_sgt_bisaccodes_2010 VALUES (
	'TRV006010',
	'Canada / Atlantic Provinces (NB, NF, NS, PE)')  
INSERT INTO temp_sgt_bisaccodes_2010 VALUES (
	'TRV006020',
	'Canada / Ontario (ON)')  
INSERT INTO temp_sgt_bisaccodes_2010 VALUES (
	'TRV006030',
	'Canada / Prairie Provinces (MB, SK)  ') 
INSERT INTO temp_sgt_bisaccodes_2010 VALUES (
	'TRV006060',
	'Canada / Quebec (QC)') 
INSERT INTO temp_sgt_bisaccodes_2010 VALUES (
	'TRV006040',
	'Canada / Territories & Nunavut (NT, NU, YT) ')  
INSERT INTO temp_sgt_bisaccodes_2010 VALUES (
	'TRV006050',
	'Canada / Western Provinces (AB, BC)  ') 
INSERT INTO temp_sgt_bisaccodes_2010 VALUES (
	'TRV007000',
	'Caribbean & West Indies')   
INSERT INTO temp_sgt_bisaccodes_2010 VALUES (
	'TRV008000',
	'Central America')  
INSERT INTO temp_sgt_bisaccodes_2010 VALUES (
	'TRV028000',
	'Cruises') 
INSERT INTO temp_sgt_bisaccodes_2010 VALUES (
	'TRV010000',
	'Essays & Travelogues') 
INSERT INTO temp_sgt_bisaccodes_2010 VALUES (
	'TRV009000',
	'Europe / General') 
INSERT INTO temp_sgt_bisaccodes_2010 VALUES (
	'TRV009010',
	'Europe / Austria') 
INSERT INTO temp_sgt_bisaccodes_2010 VALUES (
	'TRV009020',
	'Europe / Benelux Countries (Belgium, Netherlands, Luxembourg)')  
INSERT INTO temp_sgt_bisaccodes_2010 VALUES (
	'TRV009030',
	'Europe / Denmark') 
INSERT INTO temp_sgt_bisaccodes_2010 VALUES (
	'TRV009040',
	'Europe / Eastern') 
INSERT INTO temp_sgt_bisaccodes_2010 VALUES (
	'TRV009050',
	'Europe / France')  
INSERT INTO temp_sgt_bisaccodes_2010 VALUES (
	'TRV009060',
	'Europe / Germany') 
INSERT INTO temp_sgt_bisaccodes_2010 VALUES (
	'TRV009070',
	'Europe / Great Britain') 
INSERT INTO temp_sgt_bisaccodes_2010 VALUES (
	'TRV009080',
	'Europe / Greece') 
INSERT INTO temp_sgt_bisaccodes_2010 VALUES (
	'TRV009090',
	'Europe / Iceland & Greenland') 
INSERT INTO temp_sgt_bisaccodes_2010 VALUES (
	'TRV009100',
	'Europe / Ireland') 
INSERT INTO temp_sgt_bisaccodes_2010 VALUES (
	'TRV009110',
	'Europe / Italy') 
INSERT INTO temp_sgt_bisaccodes_2010 VALUES (
	'TRV009120',
	'Europe / Scandinavia') 
INSERT INTO temp_sgt_bisaccodes_2010 VALUES (
	'TRV009130',
	'Europe / Spain & Portugal') 
INSERT INTO temp_sgt_bisaccodes_2010 VALUES (
	'TRV009140',
	'Europe / Switzerland') 
INSERT INTO temp_sgt_bisaccodes_2010 VALUES (
	'TRV009150',
	'Europe / Western') 
INSERT INTO temp_sgt_bisaccodes_2010 VALUES (
	'TRV012000',
	'Former Soviet Republics')   
INSERT INTO temp_sgt_bisaccodes_2010 VALUES (
	'TRV034000',
	'Hikes & Walks')  
INSERT INTO temp_sgt_bisaccodes_2010 VALUES (
	'TRV013000',
	'Hotels, Inns & Hostels') 
INSERT INTO temp_sgt_bisaccodes_2010 VALUES (
	'TRV027000',
	'Maps & Road Atlases')  
INSERT INTO temp_sgt_bisaccodes_2010 VALUES (
	'TRV014000',
	'Mexico')  
INSERT INTO temp_sgt_bisaccodes_2010 VALUES (
	'TRV015000',
	'Middle East / General')  
INSERT INTO temp_sgt_bisaccodes_2010 VALUES (
	'TRV015010',
	'Middle East / Egypt')  
INSERT INTO temp_sgt_bisaccodes_2010 VALUES (
	'TRV015020',
	'Middle East / Israel') 
INSERT INTO temp_sgt_bisaccodes_2010 VALUES (
	'TRV015030',
	'Middle East / Turkey') 
INSERT INTO temp_sgt_bisaccodes_2010 VALUES (
	'TRV016000',
	'Museums, Tours, Points of Interest   ') 
INSERT INTO temp_sgt_bisaccodes_2010 VALUES (
	'TRV018000',
	'Parks & Campgrounds')  
INSERT INTO temp_sgt_bisaccodes_2010 VALUES (
	'TRV019000',
	'Pictorials (see also PHOTOGRAPHY / Subjects & Themes / Regional)')  
INSERT INTO temp_sgt_bisaccodes_2010 VALUES (
	'TRV020000',
	'Polar Regions')  
INSERT INTO temp_sgt_bisaccodes_2010 VALUES (
	'TRV021000',
	'Reference') 
INSERT INTO temp_sgt_bisaccodes_2010 VALUES (
	'TRV030000',
	'Resorts & Spas') 
INSERT INTO temp_sgt_bisaccodes_2010 VALUES (
	'TRV022000',
	'Restaurants')  
INSERT INTO temp_sgt_bisaccodes_2010 VALUES (
	'TRV031000',
	'Road Travel')  
INSERT INTO temp_sgt_bisaccodes_2010 VALUES (
	'TRV023000',
	'Russia')  
INSERT INTO temp_sgt_bisaccodes_2010 VALUES (
	'TRV032000',
	'Shopping')  
INSERT INTO temp_sgt_bisaccodes_2010 VALUES (
	'TRV024000',
	'South America / General')   
INSERT INTO temp_sgt_bisaccodes_2010 VALUES (
	'TRV024010',
	'South America / Argentina') 
INSERT INTO temp_sgt_bisaccodes_2010 VALUES (
	'TRV024020',
	'South America / Brazil') 
INSERT INTO temp_sgt_bisaccodes_2010 VALUES (
	'TRV024030',
	'South America / Chile & Easter Island') 
INSERT INTO temp_sgt_bisaccodes_2010 VALUES (
	'TRV024040',
	'South America / Ecuador & Galapagos Islands ')  
INSERT INTO temp_sgt_bisaccodes_2010 VALUES (
	'TRV024050',
	'South America / Peru') 
INSERT INTO temp_sgt_bisaccodes_2010 VALUES (
	'TRV026000',
	'Special Interest / General')  
INSERT INTO temp_sgt_bisaccodes_2010 VALUES (
	'TRV001000',
	'Special Interest / Adventure') 
INSERT INTO temp_sgt_bisaccodes_2010 VALUES (
	'TRV026010',
	'Special Interest / Business') 
INSERT INTO temp_sgt_bisaccodes_2010 VALUES (
	'TRV026020',
	'Special Interest / Ecotourism ')  
INSERT INTO temp_sgt_bisaccodes_2010 VALUES (
	'TRV011000',
	'Special Interest / Family') 
INSERT INTO temp_sgt_bisaccodes_2010 VALUES (
	'TRV026070',
	'Special Interest / Gay & Lesbian')  
INSERT INTO temp_sgt_bisaccodes_2010 VALUES (
	'TRV026030',
	'Special Interest / Handicapped')  
INSERT INTO temp_sgt_bisaccodes_2010 VALUES (
	'TRV026090',
	'Special Interest / Literary') 
INSERT INTO temp_sgt_bisaccodes_2010 VALUES (
	'TRV026040',
	'Special Interest / Pets')   
INSERT INTO temp_sgt_bisaccodes_2010 VALUES (
	'TRV026060',
	'Special Interest / Religious') 
INSERT INTO temp_sgt_bisaccodes_2010 VALUES (
	'TRV026050',
	'Special Interest / Senior') 
INSERT INTO temp_sgt_bisaccodes_2010 VALUES (
	'TRV026080',
	'Special Interest / Sports') 
INSERT INTO temp_sgt_bisaccodes_2010 VALUES (
	'TRV025000',
	'United States / General')   
INSERT INTO temp_sgt_bisaccodes_2010 VALUES (
	'TRV025010',
	'United States / Midwest / General') 
INSERT INTO temp_sgt_bisaccodes_2010 VALUES (
	'TRV025020',
	'United States / Midwest / East North Central (IL, IN, MI, OH, WI)') 
INSERT INTO temp_sgt_bisaccodes_2010 VALUES (
	'TRV025030',
	'United States / Midwest / West North Central (IA, KS, MN, MO, ND, NE, SD)') 
INSERT INTO temp_sgt_bisaccodes_2010 VALUES (
	'TRV025040',
	'United States / Northeast / General') 
INSERT INTO temp_sgt_bisaccodes_2010 VALUES (
	'TRV025050',
	'United States / Northeast / Middle Atlantic (NJ, NY, PA) ') 
INSERT INTO temp_sgt_bisaccodes_2010 VALUES (
	'TRV025060',
	'United States / Northeast / New England (CT, MA, ME, NH, RI, VT)')  
INSERT INTO temp_sgt_bisaccodes_2010 VALUES (
	'TRV025070',
	'United States / South / General') 
INSERT INTO temp_sgt_bisaccodes_2010 VALUES (
	'TRV025080',
	'United States / South / East South Central (AL, KY, MS, TN)') 
INSERT INTO temp_sgt_bisaccodes_2010 VALUES (
	'TRV025090',
	'United States / South / South Atlantic (DC, DE, FL, GA, MD, NC, SC, VA, WV)') 
INSERT INTO temp_sgt_bisaccodes_2010 VALUES (
	'TRV025100',
	'United States / South / West South Central (AR, LA, OK, TX)') 
INSERT INTO temp_sgt_bisaccodes_2010 VALUES (
	'TRV025110',
	'United States / West / General')  
INSERT INTO temp_sgt_bisaccodes_2010 VALUES (
	'TRV025120',
	'United States / West / Mountain (AZ, CO, ID, MT, NM, UT, WY)') 
INSERT INTO temp_sgt_bisaccodes_2010 VALUES (
	'TRV025130',
	'United States / West / Pacific (AK, CA, HI, NV, OR, WA)') 
INSERT INTO temp_sgt_bisaccodes_2010 VALUES (
	'TRU000000',
	'General') 
INSERT INTO temp_sgt_bisaccodes_2010 VALUES (
	'TRU001000',
	'Espionage') 
INSERT INTO temp_sgt_bisaccodes_2010 VALUES (
	'TRU002000',
	'Murder / General') 
INSERT INTO temp_sgt_bisaccodes_2010 VALUES (
	'TRU002010',
	'Murder / Serial Killers')   
INSERT INTO temp_sgt_bisaccodes_2010 VALUES (
	'TRU003000',
	'Organized Crime')  
INSERT INTO temp_sgt_bisaccodes_2010 VALUES (
	'NON000000',
	'NON-CLASSIFIABLE') 

INSERT INTO temp_sgt_bisaccodes_2010 VALUES (
	'BIB000000',
	'General')
INSERT INTO temp_sgt_bisaccodes_2010 VALUES (
	'BIB022000',
	'Common English Bible / General')
INSERT INTO temp_sgt_bisaccodes_2010 VALUES (
	'BIB022010',
	'Common English Bible / Children');
INSERT INTO temp_sgt_bisaccodes_2010 VALUES (
	'BIB022020',
	'Common English Bible / Devotional')
INSERT INTO temp_sgt_bisaccodes_2010 VALUES (
	'BIB022030',
	'Common English Bible / New Testament & Portions')
INSERT INTO temp_sgt_bisaccodes_2010 VALUES (
	'BIB022040',
	'Common English Bible / Reference')
INSERT INTO temp_sgt_bisaccodes_2010 VALUES (
	'BIB022050',
	'Common English Bible / Study')
INSERT INTO temp_sgt_bisaccodes_2010 VALUES (
	'BIB022060',
	'Common English Bible / Text')
INSERT INTO temp_sgt_bisaccodes_2010 VALUES (
	'BIB022070',
	'Common English Bible / Youth & Teen')
INSERT INTO temp_sgt_bisaccodes_2010 VALUES (
	'BIO029000',
	'Culinary')
INSERT INTO temp_sgt_bisaccodes_2010 VALUES (
	'BIO030000',
	'Environmentalists & Naturalists')
INSERT INTO temp_sgt_bisaccodes_2010 VALUES (
	'BIO031000',
	'Gay & Lesbian')
INSERT INTO temp_sgt_bisaccodes_2010 VALUES (
	'OCC039000',
	'Entheogens & Visionary Substances')
INSERT INTO temp_sgt_bisaccodes_2010 VALUES (
	'OCC040000',
	'Hermetism & Rosicrucianism')
INSERT INTO temp_sgt_bisaccodes_2010 VALUES (
	'OCC041000',
	'Sacred Sexuality')
INSERT INTO temp_sgt_bisaccodes_2010 VALUES (
	'BUS001050',
	'Accounting / Standards (GAAP, IFRS, etc.)')
INSERT INTO temp_sgt_bisaccodes_2010 VALUES (
	'BUS012010',
	'Careers / Internships')
INSERT INTO temp_sgt_bisaccodes_2010 VALUES (
	'BUS104000',
	'Corporate Governance')
INSERT INTO temp_sgt_bisaccodes_2010 VALUES (
	'BUS090040',
	'E-Commerce / Auctions & Small Business')
INSERT INTO temp_sgt_bisaccodes_2010 VALUES (
	'BUS105000',
	'Franchises')
INSERT INTO temp_sgt_bisaccodes_2010 VALUES (
	'BUS070110',
	'Industries / Entertainment')
INSERT INTO temp_sgt_bisaccodes_2010 VALUES (
	'BUS070120',
	'Industries / Food Industry')
INSERT INTO temp_sgt_bisaccodes_2010 VALUES (
	'BUS070130',
	'Industries / Pharmaceutical & Biotechnology')
INSERT INTO temp_sgt_bisaccodes_2010 VALUES (
	'BUS036010',
	'Investments & Securities / Bonds')
INSERT INTO temp_sgt_bisaccodes_2010 VALUES (
	'BUS036020',
	'Investments & Securities / Futures')
INSERT INTO temp_sgt_bisaccodes_2010 VALUES (
	'BUS036030',
	'Investments & Securities / Mutual Funds')
INSERT INTO temp_sgt_bisaccodes_2010 VALUES (
	'BUS036040',
	'Investments & Securities / Options')
INSERT INTO temp_sgt_bisaccodes_2010 VALUES (
	'BUS036050',
	'Investments & Securities / Real Estate')
INSERT INTO temp_sgt_bisaccodes_2010 VALUES (
	'BUS036060',
	'Investments & Securities / Stocks')
INSERT INTO temp_sgt_bisaccodes_2010 VALUES (
	'BUS106000',
	'Mentoring & Coaching')
INSERT INTO temp_sgt_bisaccodes_2010 VALUES (
	'BUS107000',
	'Personal Success')
INSERT INTO temp_sgt_bisaccodes_2010 VALUES (
	'BUS054010',
	'Real Estate / Buying & Selling Homes')
INSERT INTO temp_sgt_bisaccodes_2010 VALUES (
	'BUS054020',
	'Real Estate / Commercial')
INSERT INTO temp_sgt_bisaccodes_2010 VALUES (
	'BUS054030',
	'Real Estate / Mortgages')
INSERT INTO temp_sgt_bisaccodes_2010 VALUES (
	'BUS108000',
	'Research & Development')
INSERT INTO temp_sgt_bisaccodes_2010 VALUES (
	'BUS058010',
	'Sales & Selling / Management')
INSERT INTO temp_sgt_bisaccodes_2010 VALUES (
	'BUS109000',
	'Women in Business')
INSERT INTO temp_sgt_bisaccodes_2010 VALUES (
	'CGN010000',
	'Historical Fiction')
INSERT INTO temp_sgt_bisaccodes_2010 VALUES (
	'CGN004210',
	'Manga / Yaoi')
INSERT INTO temp_sgt_bisaccodes_2010 VALUES (
	'COM051450',
	'Programming Languages / UML')
INSERT INTO temp_sgt_bisaccodes_2010 VALUES (
	'CKB110000',
	'Methods / Raw Food')
INSERT INTO temp_sgt_bisaccodes_2010 VALUES (
	'CRA055000',
	'Knots, Macrame & Rope Work')
INSERT INTO temp_sgt_bisaccodes_2010 VALUES (
	'GAM018000',
	'Optical Illusions')
INSERT INTO temp_sgt_bisaccodes_2010 VALUES (
	'JUV058000',
	'Paranormal')
INSERT INTO temp_sgt_bisaccodes_2010 VALUES (
	'JNF051200',
	'Science & Nature / Weights & Measures')
INSERT INTO temp_sgt_bisaccodes_2010 VALUES (
	'LAW117000',
	'Transportation')
INSERT INTO temp_sgt_bisaccodes_2010 VALUES (
	'MAT040000',
	'Complex Analysis')
INSERT INTO temp_sgt_bisaccodes_2010 VALUES (
	'MAT007010',
	'Differential Equations / Ordinary')
INSERT INTO temp_sgt_bisaccodes_2010 VALUES (
	'MAT007020',
	'Differential Equations / Partial')
INSERT INTO temp_sgt_bisaccodes_2010 VALUES (
	'MAT041000',
	'Numerical Analysis')
INSERT INTO temp_sgt_bisaccodes_2010 VALUES (
	'MAT042000',
	'Optimization')
INSERT INTO temp_sgt_bisaccodes_2010 VALUES (
	'MAT029040',
	'Probability & Statistics / Stochastic Processes')
INSERT INTO temp_sgt_bisaccodes_2010 VALUES (
	'MAT029050',
	'Probability & Statistics / Time Series')
INSERT INTO temp_sgt_bisaccodes_2010 VALUES (
	'MED016060',
	'Dentistry / Endodontics')
INSERT INTO temp_sgt_bisaccodes_2010 VALUES (
	'MED016070',
	'Dentistry / Prosthodontics')
INSERT INTO temp_sgt_bisaccodes_2010 VALUES (
	'MED114000',
	'Hepatology')
INSERT INTO temp_sgt_bisaccodes_2010 VALUES (
	'MED085070',
	'Surgery / Transplant')
INSERT INTO temp_sgt_bisaccodes_2010 VALUES (
	'MUS053000',
	'Genres & Styles / Big Band & Swing')
INSERT INTO temp_sgt_bisaccodes_2010 VALUES (
	'NAT045050',
	'Ecosystems & Habitats / Coastal Regions & Shorelines')
INSERT INTO temp_sgt_bisaccodes_2010 VALUES (
	'PHI036000',
	'Hermeneutics')
INSERT INTO temp_sgt_bisaccodes_2010 VALUES (
	'PHI037000',
	'History & Surveys / Renaissance')
INSERT INTO temp_sgt_bisaccodes_2010 VALUES (
	'PHI038000',
	'Language')
INSERT INTO temp_sgt_bisaccodes_2010 VALUES (
	'PHI039000',
	'Movements / Analytic')
INSERT INTO temp_sgt_bisaccodes_2010 VALUES (
	'PHI040000',
	'Movements / Critical Theory')
INSERT INTO temp_sgt_bisaccodes_2010 VALUES (
	'PHI041000',
	'Movements / Empiricism')
INSERT INTO temp_sgt_bisaccodes_2010 VALUES (
	'PHI042000',
	'Movements / Idealism')
INSERT INTO temp_sgt_bisaccodes_2010 VALUES (
	'PHI043000',
	'Movements / Post-Structuralism')
INSERT INTO temp_sgt_bisaccodes_2010 VALUES (
	'PHI044000',
	'Movements / Realism')
INSERT INTO temp_sgt_bisaccodes_2010 VALUES (
	'REL115000',
	'Blasphemy, Heresy & Apostasy')
INSERT INTO temp_sgt_bisaccodes_2010 VALUES (
	'REL116000',
	'Religious Intolerance, Persecution & Conflict')
INSERT INTO temp_sgt_bisaccodes_2010 VALUES (
	'SCI013070',
	'Chemistry / Computational & Molecular Modeling')
INSERT INTO temp_sgt_bisaccodes_2010 VALUES (
	'SCI013080',
	'Chemistry / Environmental (see also Environmental Science)')
INSERT INTO temp_sgt_bisaccodes_2010 VALUES (
	'SCI013090',
	'Chemistry / Toxicology')
INSERT INTO temp_sgt_bisaccodes_2010 VALUES (
	'SCI090000',
	'Cognitive Science')
INSERT INTO temp_sgt_bisaccodes_2010 VALUES (
	'SCI091000',
	'Earth Sciences / Sedimentology & Stratigraphy')
INSERT INTO temp_sgt_bisaccodes_2010 VALUES (
	'SCI092000',
	'Global Warming & Climate Change')
INSERT INTO temp_sgt_bisaccodes_2010 VALUES (
	'SCI093000',
	'Laboratory Techniques')
INSERT INTO temp_sgt_bisaccodes_2010 VALUES (
	'SCI094000',
	'Life Sciences / Mycology')
INSERT INTO temp_sgt_bisaccodes_2010 VALUES (
	'SCI095000',
	'Mechanics / Hydrodynamics')
INSERT INTO temp_sgt_bisaccodes_2010 VALUES (
	'SCI096000',
	'Mechanics / Solids')
INSERT INTO temp_sgt_bisaccodes_2010 VALUES (
	'SCI097000',
	'Physics / Polymer')
INSERT INTO temp_sgt_bisaccodes_2010 VALUES (
	'SCI098000',
	'Space Science')
INSERT INTO temp_sgt_bisaccodes_2010 VALUES (
	'SEL037000',
	'Neuro-Linguistic Programming (NLP)')
INSERT INTO temp_sgt_bisaccodes_2010 VALUES (
	'SOC058000',
	'Conspiracy Theories')
INSERT INTO temp_sgt_bisaccodes_2010 VALUES (
	'SOC059000',
	'Prostitution & Sex Trade')
INSERT INTO temp_sgt_bisaccodes_2010 VALUES (
	'SOC060000',
	'Sexual Abuse & Harassment')
INSERT INTO temp_sgt_bisaccodes_2010 VALUES (
	'STU034000',
	'Bar Exam')
INSERT INTO temp_sgt_bisaccodes_2010 VALUES (
	'TEC065000',
	'Emergency Management')
INSERT INTO temp_sgt_bisaccodes_2010 VALUES (
	'TEC066000',
	'Research')
INSERT INTO temp_sgt_bisaccodes_2010 VALUES (
	'TEC067000',
	'Signals & Signal Processing')
INSERT INTO temp_sgt_bisaccodes_2010 VALUES (
	'TEC068000',
	'Tribology')
INSERT INTO temp_sgt_bisaccodes_2010 VALUES (
	'TRU004000',
	'Hoaxes & Deceptions')
INSERT INTO temp_sgt_bisaccodes_2010 VALUES (
	'TRU005000',
	'White Collar Crime')
go
