IF EXISTS (SELECT * FROM dbo.sysobjects WHERE id = Object_id('temp_replacement_codes_2010') AND type = 'U')
  BEGIN
    DROP table temp_replacement_codes_2010
  END
go

CREATE TABLE temp_replacement_codes_2010 (
	Code char(255),
	literalwheninactivated char(255),
	lvcwa float,
	replacementcode char(255))
go

INSERT INTO temp_replacement_codes_2010 VALUES (
	'ANT004000',
	'ANTIQUES & COLLECTIBLES / Baskets',
	2.1,
	'ANT000000')
INSERT INTO temp_replacement_codes_2010 VALUES (
	'ANT013000',
	'ANTIQUES & COLLECTIBLES / Dance',
	2.1,
	'ANT025000')
INSERT INTO temp_replacement_codes_2010 VALUES (
	'ANT014000',
	'ANTIQUES & COLLECTIBLES / Disneyana',
	2.1,
	'ANT001000')
INSERT INTO temp_replacement_codes_2010 VALUES (
	'ANT019000',
	'ANTIQUES & COLLECTIBLES / Gold' ,
	2.1,
	'ANT041000')
INSERT INTO temp_replacement_codes_2010 VALUES (
	'ANT020000',
	'ANTIQUES & COLLECTIBLES / Hummels',
	2.1,
	'ANT052000 or ANT053000')
INSERT INTO temp_replacement_codes_2010 VALUES (
	'ANT026000',
	'ANTIQUES & COLLECTIBLES / Musical Instruments',
	2.1,
	'ANT025000')
INSERT INTO temp_replacement_codes_2010 VALUES (
	'ANT027000',
	'ANTIQUES & COLLECTIBLES / Nautical' ,
	2.1,
	'ANT009000')
INSERT INTO temp_replacement_codes_2010 VALUES (
	'ANT030000',
	'ANTIQUES & COLLECTIBLES / Pewter'   ,
	2.1,
	'ANT041000')
INSERT INTO temp_replacement_codes_2010 VALUES (
	'ANT039000',
	'ANTIQUES & COLLECTIBLES / Royalty',
	2.1,
	'ANT052000')
INSERT INTO temp_replacement_codes_2010 VALUES (
	'ANT046000',
	'ANTIQUES & COLLECTIBLES / Televisions & Television-Related'    ,
	2.1,
	'ANT025000 for works on television-related collectibles; ANT036000 for works on collecting televisions')
INSERT INTO temp_replacement_codes_2010 VALUES (
	'ANT048000',
	'ANTIQUES & COLLECTIBLES / Theater',
	2.1,
	'ANT025000')
INSERT INTO temp_replacement_codes_2010 VALUES (
	'ART001000',
	'ART / Activity' ,
	2.6,
	'appropriate code beginning with ART'   )
INSERT INTO temp_replacement_codes_2010 VALUES (
	'ART005000',
	'ART / Clip Art' ,
	2007,
	'DES002000')
INSERT INTO temp_replacement_codes_2010 VALUES (
	'ART011000',
	'ART / Fashion'  ,
	2007,
	'DES005000')
INSERT INTO temp_replacement_codes_2010 VALUES (
	'ART012000',
	'ART / Fine Arts',
	2.6,
	'appropriate code beginning with ART'   )
INSERT INTO temp_replacement_codes_2010 VALUES (
	'ART014000',
	'ART / Graphic Arts'    ,
	2007,
	'appropriate code beginning with DES007')
INSERT INTO temp_replacement_codes_2010 VALUES (
	'ART022000',
	'ART / Pictorial',
	2.6,
	'appropriate code beginning with ART'   )
INSERT INTO temp_replacement_codes_2010 VALUES (
	'ART030000',
	'ART / Design / General',
	2007,
	'DES000000')
INSERT INTO temp_replacement_codes_2010 VALUES (
	'ART030010',
	'ART / Design / Book'   ,
	2007,
	'DES001000')
INSERT INTO temp_replacement_codes_2010 VALUES (
	'ART030020',
	'ART / Design / Decorative'      ,
	2007,
	'DES003000')
INSERT INTO temp_replacement_codes_2010 VALUES (
	'ART030030',
	'ART / Design / Furniture'       ,
	2007,
	'DES006000')
INSERT INTO temp_replacement_codes_2010 VALUES (
	'ART030040',
	'ART / Design / Textile & Costume'   ,
	2007,
	'DES013000')
INSERT INTO temp_replacement_codes_2010 VALUES (
	'ART030050',
	'ART / Design / Product',
	2007,
	'DES011000')
INSERT INTO temp_replacement_codes_2010 VALUES (
	'ART032000',
	'ART / Commercial / General'     ,
	2007,
	'DES007030')
INSERT INTO temp_replacement_codes_2010 VALUES (
	'ART032010',
	'ART / Commercial / Advertising' ,
	2007,
	'DES007010')
INSERT INTO temp_replacement_codes_2010 VALUES (
	'ART032020',
	'ART / Commercial / Illustration',
	2007,
	'DES007040')
INSERT INTO temp_replacement_codes_2010 VALUES (
	'ART036000',
	'ART / Typography'      ,
	2007,
	'DES007050')
INSERT INTO temp_replacement_codes_2010 VALUES (
	'BUS033030',
	'BUSINESS & ECONOMICS / Insurance / Group'     ,
	2.4,
	'appropriate code beginning with BUS033')
INSERT INTO temp_replacement_codes_2010 VALUES (
	'BUS090020',
	'BUSINESS & ECONOMICS / E-Commerce / Online Banking' ,
     2009,
	'BUS090000')
INSERT INTO temp_replacement_codes_2010 VALUES (
	'CGN002000',
	'COMICS & GRAPHIC NOVELS / Comics & Cartoons'  ,
	2006,
	'HUM001000 or appropriate code beginning with CGN')
INSERT INTO temp_replacement_codes_2010 VALUES (
	'CGN003000',
	'COMICS & GRAPHIC NOVELS / Educational',
	2006,
	'appropriate code beginning with CGN')
INSERT INTO temp_replacement_codes_2010 VALUES (
	'CGN004000',
	'COMICS & GRAPHIC NOVELS / Graphic Novels / General' ,
	2006,
	'CGN000000')
INSERT INTO temp_replacement_codes_2010 VALUES (
	'CGN005000',
	'COMICS & GRAPHIC NOVELS / History & Criticism',
	2007,
	'CGN007000 for works that are nonfiction comics or graphic novels about history; LIT017000 for works on the history and criticism of comics or graphic novels')
INSERT INTO temp_replacement_codes_2010 VALUES (
	'CKB022000',
	'COOKING / Creole',
	2.1,
	'CKB013000')
INSERT INTO temp_replacement_codes_2010 VALUES (
	'CKB027000',
	'COOKING / Dutch',
	2.1,
	'CKB092000')
INSERT INTO temp_replacement_codes_2010 VALUES (
	'CKB028000',
	'COOKING / Eastern European' ,
	2.1,
	'CKB092000')
INSERT INTO temp_replacement_codes_2010 VALUES (
	'CKB053000',
	'COOKING / Low Sugar'   ,
	2.1,
	'CKB025000')
INSERT INTO temp_replacement_codes_2010 VALUES (
	'CKB075000',
	'COOKING / Scottish'    ,
	2.1,
	'CKB011000')
INSERT INTO temp_replacement_codes_2010 VALUES (
	'CKB087000',
	'COOKING / Welsh',
	2.1,
	'CKB011000')
INSERT INTO temp_replacement_codes_2010 VALUES (
	'COM001000',
	'COMPUTERS / Accessories'        ,
	2.4,
	'appropriate code beginning with COM'   )
INSERT INTO temp_replacement_codes_2010 VALUES (
	'COM002000',
	'COMPUTERS / Advanced Applications',
	2.4,
	'appropriate code beginning with COM'   )
INSERT INTO temp_replacement_codes_2010 VALUES (
	'COM003000',
	'COMPUTERS / Application Software / General'   ,
	2.4,
	'appropriate code beginning with COM'   )
INSERT INTO temp_replacement_codes_2010 VALUES (
	'COM003010',
	'COMPUTERS / Application Software / IBM-Compatible'    ,
	2.4,
	'appropriate code beginning with COM'   )
INSERT INTO temp_replacement_codes_2010 VALUES (
	'COM003020',
	'COMPUTERS / Application Software / Macintosh' ,
	2.4,
	'appropriate code beginning with COM'   )
INSERT INTO temp_replacement_codes_2010 VALUES (
	'COM005010',
	'COMPUTERS / Business Software / IBM-Compatible',
	2.4,
	'COM005030')
INSERT INTO temp_replacement_codes_2010 VALUES (
	'COM005020',
	'COMPUTERS / Business Software / Macintosh'    ,
	2.4,
	'COM005030')
INSERT INTO temp_replacement_codes_2010 VALUES (
	'COM007010',
	'COMPUTERS / CAD-CAM / IBM-Compatible',
	2.4,
	'COM007000')
INSERT INTO temp_replacement_codes_2010 VALUES (
	'COM007020',
	'COMPUTERS / CAD-CAM / Macintosh',
	2.4,
	'COM007000')
INSERT INTO temp_replacement_codes_2010 VALUES (
	'COM009010',
	'COMPUTERS / CD-ROM Technology / IBM-Compatible',
	2.4,
	'COM009000')
INSERT INTO temp_replacement_codes_2010 VALUES (
	'COM009020',
	'COMPUTERS / CD-ROM Technology / Macintosh'    ,
	2.4,
	'COM009000')
INSERT INTO temp_replacement_codes_2010 VALUES (
	'COM012010',
	'COMPUTERS / Computer Graphics / IBM-Compatible',
	2.4,
	'COM012000')
INSERT INTO temp_replacement_codes_2010 VALUES (
	'COM012020',
	'COMPUTERS / Computer Graphics / Macintosh'    ,
	2.4,
	'COM012000')
INSERT INTO temp_replacement_codes_2010 VALUES (
	'COM012030',
	'COMPUTERS / Computer Graphics / Design'       ,
	2.8,
	'COM012000')
INSERT INTO temp_replacement_codes_2010 VALUES (
	'COM020030',
	'COMPUTERS / Data Transmission Systems / Facsimile Transmission',
	2.4,
	'COM020000')
INSERT INTO temp_replacement_codes_2010 VALUES (
	'COM020040',
	'COMPUTERS / Data Transmission Systems / Image Transmission'    ,
	2.4,
	'COM020000')
INSERT INTO temp_replacement_codes_2010 VALUES (
	'COM020060',
	'COMPUTERS / Data Transmission Systems / Modems',
	2.4,
	'COM020000')
INSERT INTO temp_replacement_codes_2010 VALUES (
	'COM020070',
	'COMPUTERS / Data Transmission Systems / Videotext Systems'     ,
	2.4,
	'COM020000')
INSERT INTO temp_replacement_codes_2010 VALUES (
	'COM020080',
	'COMPUTERS / Data Transmission Systems / ATM (Asynchronous Transfer Mode)' ,
	2.4,
	'COM020050')
INSERT INTO temp_replacement_codes_2010 VALUES (
	'COM021010',
	'COMPUTERS / Database Management / IBM-Compatible'     ,
	2.4,
	'COM021000')
INSERT INTO temp_replacement_codes_2010 VALUES (
	'COM021020',
	'COMPUTERS / Database Management / Macintosh'  ,
	2.4,
	'COM021000')
INSERT INTO temp_replacement_codes_2010 VALUES (
	'COM022010',
	'COMPUTERS / Desktop Publishing / IBM-Compatible'      ,
	2.4,
	'COM022000')
INSERT INTO temp_replacement_codes_2010 VALUES (
	'COM022020',
	'COMPUTERS / Desktop Publishing / Macintosh'   ,
	2.4,
	'COM022000')
INSERT INTO temp_replacement_codes_2010 VALUES (
	'COM023010',
	'COMPUTERS / Educational Software / IBM-Compatible'    ,
	2.4,
	'COM023000')
INSERT INTO temp_replacement_codes_2010 VALUES (
	'COM023020',
	'COMPUTERS / Educational Software / Macintosh' ,
	2.4,
	'COM023000')
INSERT INTO temp_replacement_codes_2010 VALUES (
	'COM024000',
	'COMPUTERS / Entertainment & Games',
	2.8,
	'GAM013000')
INSERT INTO temp_replacement_codes_2010 VALUES (
	'COM024010',
	'COMPUTERS / Entertainment & Games / IBM-Compatible'   ,
	2.4,
	'GAM013000')
INSERT INTO temp_replacement_codes_2010 VALUES (
	'COM024020',
	'COMPUTERS / Entertainment & Games / Macintosh',
	2.4,
	'GAM013000')
INSERT INTO temp_replacement_codes_2010 VALUES (
	'COM026000',
	'COMPUTERS / Fault-Tolerant Computing',
	2.4,
	'COM018000 or COM051240'                )
INSERT INTO temp_replacement_codes_2010 VALUES (
	'COM027010',
	'COMPUTERS / Financial Applications / IBM-Compatible'  ,
	2.4,
	'COM005030 or COM027000'                )
INSERT INTO temp_replacement_codes_2010 VALUES (
	'COM027020',
	'COMPUTERS / Financial Applications / Macintosh',
	2.4,
	'COM005030 or COM027000'                )
INSERT INTO temp_replacement_codes_2010 VALUES (
	'COM028000',
	'COMPUTERS / Hard Disk Management'   ,
	2.4,
	'COM067000 or appropriate code for the system involved')
INSERT INTO temp_replacement_codes_2010 VALUES (
	'COM029000',
	'COMPUTERS / Hypertext Systems'  ,
	2.4,
	'COM051270')
INSERT INTO temp_replacement_codes_2010 VALUES (
	'COM033000',
	'COMPUTERS / Integrated Software / General'    ,
	2.4,
	'COM084030')
INSERT INTO temp_replacement_codes_2010 VALUES (
	'COM033010',
	'COMPUTERS / Integrated Software / IBM-Compatible'     ,
	2.4,
	'COM084030')
INSERT INTO temp_replacement_codes_2010 VALUES (
	'COM033020',
	'COMPUTERS / Integrated Software / Macintosh'  ,
	2.4,
	'COM084030')
INSERT INTO temp_replacement_codes_2010 VALUES (
	'COM040000',
	'COMPUTERS / Memory Management'  ,
	2.4,
	'COM051000, COM067000, or appropriate code for the language or system involved')
INSERT INTO temp_replacement_codes_2010 VALUES (
	'COM043010',
	'COMPUTERS / Networking / Bulletin Boards'     ,
	2.8,
	'COM043000')
INSERT INTO temp_replacement_codes_2010 VALUES (
	'COM043030',
	'COMPUTERS / Networking / Wide Area Networks (WANs)'   ,
	2.8,
	'COM043000')
INSERT INTO temp_replacement_codes_2010 VALUES (
	'COM045000',
	'COMPUTERS / Online Data Processing' ,
	2.4,
	'COM018000, COM069000, or appropriate code beginning with COM060')
INSERT INTO temp_replacement_codes_2010 VALUES (
	'COM046010',
	'COMPUTERS / Operating Systems / IBM-Compatible',
	2.4,
	'appropriate code beginning with COM046')
INSERT INTO temp_replacement_codes_2010 VALUES (
	'COM050030',
	'COMPUTERS / Personal Computers & Microcomputers / Upgrading'   ,
	2.4,
	'appropriate code beginning with COM050')
INSERT INTO temp_replacement_codes_2010 VALUES (
	'COM051030',
	'COMPUTERS / Programming Languages / ANSI C'   ,
	2.4,
	'COM051060')
INSERT INTO temp_replacement_codes_2010 VALUES (
	'COM051110',
	'COMPUTERS / Programming Languages / Microsoft C'      ,
	2.4,
	'COM051060')
INSERT INTO temp_replacement_codes_2010 VALUES (
	'COM051120',
	'COMPUTERS / Programming Languages / Modula-2' ,
	2.4,
	'COM051010')
INSERT INTO temp_replacement_codes_2010 VALUES (
	'COM051150',
	'COMPUTERS / Programming Languages / Quick C'  ,
	2.4,
	'COM051060')
INSERT INTO temp_replacement_codes_2010 VALUES (
	'COM051180',
	'COMPUTERS / Programming Languages / Turbo C'  ,
	2.4,
	'COM051060')
INSERT INTO temp_replacement_codes_2010 VALUES (
	'COM051190',
	'COMPUTERS / Programming Languages / Turbo Pascal'     ,
	2.4,
	'COM051130')
INSERT INTO temp_replacement_codes_2010 VALUES (
	'COM051250',
	'COMPUTERS / Programming / Visual'   ,
	2.4,
	'COM051000 or COM051200')
INSERT INTO temp_replacement_codes_2010 VALUES (
	'COM051340',
	'COMPUTERS / Programming Languages / CGI'      ,
	2007,
	'COM043040')
INSERT INTO temp_replacement_codes_2010 VALUES (
	'COM054010',
	'COMPUTERS / Spreadsheets / IBM-Compatible'    ,
	2.4,
	'COM054000')
INSERT INTO temp_replacement_codes_2010 VALUES (
	'COM054020',
	'COMPUTERS / Spreadsheets / Macintosh',
	2.4,
	'COM054000')
INSERT INTO temp_replacement_codes_2010 VALUES (
	'COM058010',
	'COMPUTERS / Word Processing / IBM-Compatible' ,
	2.4,
	'COM058000')
INSERT INTO temp_replacement_codes_2010 VALUES (
	'COM058020',
	'COMPUTERS / Word Processing / Macintosh'      ,
	2.4,
	'COM058000')
INSERT INTO temp_replacement_codes_2010 VALUES (
	'COM060020',
	'COMPUTERS / Internet / Hardware',
	2.8,
	'COM061000 or COM075000'                )
INSERT INTO temp_replacement_codes_2010 VALUES (
	'COM060050',
	'COMPUTERS / Internet / Server Maintenance'    ,
	2.4,
	'COM075000')
INSERT INTO temp_replacement_codes_2010 VALUES (
	'COM068000',
	'COMPUTERS / Multimedia',
	2.4,
	'COM034000')
INSERT INTO temp_replacement_codes_2010 VALUES (
	'COM076000',
	'COMPUTERS / Hardware / Workstations',
	2007,
	'COM067000')
INSERT INTO temp_replacement_codes_2010 VALUES (
	'CRA013000',
	'CRAFTS & HOBBIES / Graphic Arts',
	2.1,
	'appropriate code beginning with DES007')
INSERT INTO temp_replacement_codes_2010 VALUES (
	'CRA038000',
	'CRAFTS & HOBBIES / Tatting'     ,
	2.1,
	'CRA016000')
INSERT INTO temp_replacement_codes_2010 VALUES (
	'CUR000000',
	'CURRENT EVENTS / General'       ,
	2.5,
	'appropriate code beginning with HIS, POL or SOC')
INSERT INTO temp_replacement_codes_2010 VALUES (
	'CUR001000',
	'CURRENT EVENTS / American'      ,
	2.5,
	'appropriate code beginning with HIS036, POL or SOC')
INSERT INTO temp_replacement_codes_2010 VALUES (
	'CUR002000',
	'CURRENT EVENTS / Government'    ,
	2.2,
	'appropriate code beginning with POL'   )
INSERT INTO temp_replacement_codes_2010 VALUES (
	'CUR003000',
	'CURRENT EVENTS / Homelessness'  ,
	2.5,
	'SOC045000')
INSERT INTO temp_replacement_codes_2010 VALUES (
	'CUR004000',
	'CURRENT EVENTS / International' ,
	2.5,
	'appropriate code beginning with HIS, POL or SOC')
INSERT INTO temp_replacement_codes_2010 VALUES (
	'CUR005000',
	'CURRENT EVENTS / Law'  ,
	2.5,
	'appropriate code beginning with LAW'   )
INSERT INTO temp_replacement_codes_2010 VALUES (
	'CUR006000',
	'CURRENT EVENTS / Mass Media'    ,
	2.5,
	'SOC052000')
INSERT INTO temp_replacement_codes_2010 VALUES (
	'CUR007000',
	'CURRENT EVENTS / Military'      ,
	2.5,
	'TEC025000 or appropriate code beginning with HIS027')
INSERT INTO temp_replacement_codes_2010 VALUES (
	'CUR008000',
	'CURRENT EVENTS / Peace',
	2.5,
	'POL034000')
INSERT INTO temp_replacement_codes_2010 VALUES (
	'CUR009000',
	'CURRENT EVENTS / Political'     ,
	2.5,
	'appropriate code beginning with POL'   )
INSERT INTO temp_replacement_codes_2010 VALUES (
	'CUR010000',
	'CURRENT EVENTS / Poverty'       ,
	2.5,
	'SOC045000')
INSERT INTO temp_replacement_codes_2010 VALUES (
	'DRA007000',
	'DRAMA / History & Criticism'    ,
	2.1,
	'LIT013000 (and any other appropriate code beginning with LIT)')
INSERT INTO temp_replacement_codes_2010 VALUES (
	'DRA009000',
	'DRAMA / Reference'     ,
	2.1,
	'LIT012000 and/or LIT013000'            )
INSERT INTO temp_replacement_codes_2010 VALUES (
	'EDU004000',
	'EDUCATION / Aids & Device [sic]',
	2,
	'appropriate code beginning with EDU029')
INSERT INTO temp_replacement_codes_2010 VALUES (
	'EDU019000',
	'EDUCATION / Library & Information Science'    ,
	2,
	'LAN025000')
INSERT INTO temp_replacement_codes_2010 VALUES (
	'EDU035000',
	'EDUCATION / Funding'   ,
	2,
	'EDU013000 for works on funding of an institution; STU031000 for works on funding of an individual')
INSERT INTO temp_replacement_codes_2010 VALUES (
	'FAM009000',
	'FAMILY & RELATIONSHIPS / Breastfeeding'       ,
	2.8,
	'HEA044000')
INSERT INTO temp_replacement_codes_2010 VALUES (
	'FAM023000',
	'FAMILY & RELATIONSHIPS / Health',
	2.8,
	'appropriate code beginning with HEA'   )
INSERT INTO temp_replacement_codes_2010 VALUES (
	'FAM024000',
	'FAMILY & RELATIONSHIPS / Humorous',
	2.1,
	'HUM011000 and/or HUM012000'            )
INSERT INTO temp_replacement_codes_2010 VALUES (
	'FAM026000',
	'FAMILY & RELATIONSHIPS / Infertility',
	2.8,
	'HEA045000')
INSERT INTO temp_replacement_codes_2010 VALUES (
	'FAM036000',
	'FAMILY & RELATIONSHIPS / Pregnancy & Childbirth'      ,
	2.5,
	'HEA041000')
INSERT INTO temp_replacement_codes_2010 VALUES (
	'FAM040000',
	'FAMILY & RELATIONSHIPS / Sexuality' ,
	2.5,
	'HEA042000, REL105000 or SEL034000'     )
INSERT INTO temp_replacement_codes_2010 VALUES (
	'FAM045000',
	'FAMILY & RELATIONSHIPS / Essays',
	2.8,
	'appropriate code beginning with FAM'   )
INSERT INTO temp_replacement_codes_2010 VALUES (
	'FIC001000',
	'FICTION / Action'      ,
	2.1,
	'FIC002000')
INSERT INTO temp_replacement_codes_2010 VALUES (
	'FIC007000',
	'FICTION / Fairy Tales' ,
	2.1,
	'FIC010000')
INSERT INTO temp_replacement_codes_2010 VALUES (
	'FIC013000',
	'FICTION / Graphic Novels'       ,
	2.6,
	'appropriate code beginning with CGN'   )
INSERT INTO temp_replacement_codes_2010 VALUES (
	'FIC017000',
	'FICTION / Interactive' ,
	2.9,
	'FIC000000')
INSERT INTO temp_replacement_codes_2010 VALUES (
	'FIC023000',
	'FICTION / Mythology'   ,
	2.1,
	'FIC010000')
INSERT INTO temp_replacement_codes_2010 VALUES (
	'FIC027060',
	'FICTION / Romance / Regional'   ,
	2.1,
	'appropriate code beginning with FIC027')
INSERT INTO temp_replacement_codes_2010 VALUES (
	'GAM003010',
	'GAMES / Crosswords / Crostic'   ,
	2.7,
	'GAM003000')
INSERT INTO temp_replacement_codes_2010 VALUES (
	'GAM003020',
	'GAMES / Crosswords / Cryptic'   ,
	2.7,
	'GAM003000')
INSERT INTO temp_replacement_codes_2010 VALUES (
	'GAM003030',
	'GAMES / Crosswords / Diagramless'   ,
	2.7,
	'GAM003000')
INSERT INTO temp_replacement_codes_2010 VALUES (
	'GAM004010',
	'GAMES / Gambling / Card Games'  ,
	2.7,
	'appropriate code beginning with GAM002')
INSERT INTO temp_replacement_codes_2010 VALUES (
	'GAM015000',
	'GAMES / Word Search'   ,
	2.7,
	'GAM014000')
INSERT INTO temp_replacement_codes_2010 VALUES (
	'GAR003000',
	'GARDENING / Flower Arranging'   ,
	2.1,
	'CRA010000')
INSERT INTO temp_replacement_codes_2010 VALUES (
	'GAR004020',
	'GARDENING / Flowers / Azaleas'  ,
	2.3,
	'GAR021000')
INSERT INTO temp_replacement_codes_2010 VALUES (
	'GAR004070',
	'GARDENING / Flowers / Violets'  ,
	2.3,
	'GAR004010')
INSERT INTO temp_replacement_codes_2010 VALUES (
	'GAR011000',
	'GARDENING / Hydroponics'        ,
	2.3,
	'GAR022000')
INSERT INTO temp_replacement_codes_2010 VALUES (
	'GAR012000',
	'GARDENING / Indoor'    ,
	2.3,
	'GAR010000')
INSERT INTO temp_replacement_codes_2010 VALUES (
	'GAR026000',
	'GARDENING / Xeriscaping'        ,
	2.3,
	'GAR022000')
INSERT INTO temp_replacement_codes_2010 VALUES (
	'HEA004000',
	'HEALTH & FITNESS / Calorie-Content Guides'    ,
	2,
	'HEA034000')
INSERT INTO temp_replacement_codes_2010 VALUES (
	'HEA005000',
	'HEALTH & FITNESS / Cholesterol-Content Guides',
	2,
	'HEA034000')
INSERT INTO temp_replacement_codes_2010 VALUES (
	'HEA008000',
	'HEALTH & FITNESS / Fat-Content Guides'        ,
	2,
	'HEA034000')
INSERT INTO temp_replacement_codes_2010 VALUES (
	'HEA022000',
	'HEALTH & FITNESS / Stretching'  ,
	2,
	'HEA007000')
INSERT INTO temp_replacement_codes_2010 VALUES (
	'HEA031000',
	'HEALTH & FITNESS / Hygiene'     ,
	2,
	'HEA000000 (or other appropriate code beginning with HEA)')
INSERT INTO temp_replacement_codes_2010 VALUES (
	'HIS011000',
	'HISTORY / Far East'    ,
	2.6,
	'appropriate code beginning with HIS'   )
INSERT INTO temp_replacement_codes_2010 VALUES (
	'HIS034000',
	'HISTORY / Soviet Union',
	2.6,
	'HIS032000')
INSERT INTO temp_replacement_codes_2010 VALUES (
	'HOM002000',
	'HOUSE & HOME / Contracting'     ,
	2.4,
	'TEC005020')
INSERT INTO temp_replacement_codes_2010 VALUES (
	'HOM007000',
	'HOUSE & HOME / Estimating'      ,
	2.4,
	'TEC005040')
INSERT INTO temp_replacement_codes_2010 VALUES (
	'HUM002000',
	'HUMOR / Comic Books, Strips, etc.',
	2.1,
	'HUM001000')
INSERT INTO temp_replacement_codes_2010 VALUES (
	'JNF018000',
	'JUVENILE NONFICTION / Ethnic / General'       ,
	2.3,
	'JNF038000')
INSERT INTO temp_replacement_codes_2010 VALUES (
	'JNF026040',
	'JUVENILE NONFICTION / Holidays & Festivals / Jewish'  ,
	2.8,
	'JNF026110 for works on Hanukkah; JNF026120 for works on Passover; JNF026090 for works on other Jewish holidays or festivals')
INSERT INTO temp_replacement_codes_2010 VALUES (
	'JNF037000',
	'JUVENILE NONFICTION / Nature / General (see also headings under Animals)',
	2.8,
	'appropriate code beginning with JNF003, JNF037 or JNF051')
INSERT INTO temp_replacement_codes_2010 VALUES (
	'JNF042020',
	'JUVENILE NONFICTION / Poetry / Nursery Rhymes',
	2008,
	'JUV055000')
INSERT INTO temp_replacement_codes_2010 VALUES (
	'JNF049050',
	'JUVENILE NONFICTION / Religion / Bible / Study',
	2.9,
	'JNF049010')
INSERT INTO temp_replacement_codes_2010 VALUES (
	'JNF049060',
	'JUVENILE NONFICTION / Religion / Bibles / General'    ,
	2006,
	'JNF049040 or appropriate code beginning with BIB')
INSERT INTO temp_replacement_codes_2010 VALUES (
	'JNF049070',
	'JUVENILE NONFICTION / Religion / Bibles / Picture'    ,
	2006,
	'JNF049040 or appropriate code beginning with BIB')
INSERT INTO temp_replacement_codes_2010 VALUES (
	'JNF055020',
	'JUVENILE NONFICTION / Study Aids / College Guides'    ,
	2.8,
	'STU010000')
INSERT INTO temp_replacement_codes_2010 VALUES (
	'JUV011000',
	'JUVENILE FICTION / Ethnic / General',
	2.3,
	'JUV030000')
INSERT INTO temp_replacement_codes_2010 VALUES (
	'JUV012010',
	'JUVENILE FICTION / Fairy Tales & Folklore / Collections by a Single Author',
	2.8,
	'appropriate code beginning with JUV012')
INSERT INTO temp_replacement_codes_2010 VALUES (
	'JUV017040',
	'JUVENILE FICTION / Holidays & Festivals / Jewish'     ,
	2.8,
	'JUV017110 for works about Hanukkah; JUV017120 for works about Passover; JUV017090 for works about other Jewish holidays or festivals')
INSERT INTO temp_replacement_codes_2010 VALUES (
	'LAN003000',
	'LANGUAGE ARTS & DISCIPLINES / Braille'        ,
	2008,
	'LAN001000 for works about Braille; appropriate other code for works that are in Braille')
INSERT INTO temp_replacement_codes_2010 VALUES (
	'LAW040000',
	'LAW / Fidelity & Surety'        ,
	2.8,
	'LAW021000, LAW049000 or LAW113000'     )
INSERT INTO temp_replacement_codes_2010 VALUES (
	'LAW042000',
	'LAW / Franchising'     ,
	2.8,
	'LAW009000')
INSERT INTO temp_replacement_codes_2010 VALUES (
	'LAW045000',
	'LAW / Grant'    ,
	2.8,
	'LAW009000')
INSERT INTO temp_replacement_codes_2010 VALUES (
	'LAW048000',
	'LAW / Human Rights'    ,
	2.8,
	'POL035010')
INSERT INTO temp_replacement_codes_2010 VALUES (
	'LAW057000',
	'LAW / Law Office Marketing & Advertising'     ,
	2.8,
	'LAW056000')
INSERT INTO temp_replacement_codes_2010 VALUES (
	'LAW058000',
	'LAW / Law Office Technology'    ,
	2.8,
	'LAW056000')
INSERT INTO temp_replacement_codes_2010 VALUES (
	'LAW065000',
	'LAW / Living Wills'    ,
	2.8,
	'LAW082000')
INSERT INTO temp_replacement_codes_2010 VALUES (
	'LAW072000',
	'LAW / Patent, Trademark, Copyright' ,
	2.8,
	'appropriate code beginning with LAW050')
INSERT INTO temp_replacement_codes_2010 VALUES (
	'LAW073000',
	'LAW / Professional Responsibility',
	2.8,
	'LAW036000')
INSERT INTO temp_replacement_codes_2010 VALUES (
	'LAW085000',
	'LAW / Study & Teaching',
	2009,
	'LAW059000')
INSERT INTO temp_replacement_codes_2010 VALUES (
	'LAW085000',
	'LAW / Study & Teaching',
	2.8,
	'LAW059000')
INSERT INTO temp_replacement_codes_2010 VALUES (
	'LIT001000',
	'LITERARY CRITICISM & COLLECTIONS / Belles Lettres'    ,
	2.1,
	'appropriate code beginning with LCO or LIT')
INSERT INTO temp_replacement_codes_2010 VALUES (
	'LIT002000',
	'LITERARY CRITICISM & COLLECTIONS / Essays'    ,
	2.1,
	'LCO010000 for collections; appropriate code beginning with LIT for criticism')
INSERT INTO temp_replacement_codes_2010 VALUES (
	'LIT004000',
	'LITERARY CRITICISM & COLLECTIONS / History & Criticism'        ,
	2.1,
	'LIT000000 (or any other appropriate code beginning with LIT)') 
INSERT INTO temp_replacement_codes_2010 VALUES (
	'LIT004090',
	'LITERARY CRITICISM & COLLECTIONS / Caribbean & West Indian'    ,
	2.1,
	'LCO007000 for collections; LIT004100 for criticism')
INSERT INTO temp_replacement_codes_2010 VALUES (
	'LIT004140',
	'LITERARY CRITICISM & COLLECTIONS / Far Eastern',
	2.1,
	'LCO004000 for collections; appropriate code beginning with LIT008 for criticism')
INSERT INTO temp_replacement_codes_2010 VALUES (
	'LIT004270',
	'LITERARY CRITICISM & COLLECTIONS / South & Southeast Asian'    ,
	2.1,
	'LCO004000 for collections; appropriate code beginning with LIT008 for criticism')
INSERT INTO temp_replacement_codes_2010 VALUES (
	'LIT005000',
	'LITERARY CRITICISM & COLLECTIONS / Semiotics' ,
	2.1,
	'LIT006000')
INSERT INTO temp_replacement_codes_2010 VALUES (
	'LIT010000',
	'LITERARY CRITICISM & COLLECTIONS / Letters'   ,
	2.1,
	'LCO011000 for collections; appropriate code beginning with LIT for criticism')
INSERT INTO temp_replacement_codes_2010 VALUES (
	'MAT001000',
	'MATHEMATICS / Advanced'   ,
	2.1,
	'LCO011000 for collections; appropriate code beginning with LIT for criticism')
INSERT INTO temp_replacement_codes_2010 VALUES (
	'MAT002020',
	'MATHEMATICS / Algebra / Boolean',
	2009,
	'appropriate code beginning with MAT')
INSERT INTO temp_replacement_codes_2010 VALUES (
	'MAT010000',
	'MATHEMATICS / Fractions'        ,
	2.5,
	'MAT004000')
INSERT INTO temp_replacement_codes_2010 VALUES (
	'MAT024000',
	'MATHEMATICS / Probability'      ,
	2.5,
	'MAT029000')
INSERT INTO temp_replacement_codes_2010 VALUES (
	'MAT035000',
	'MATHEMATICS / Computer Mathematics' ,
	2.5,
	'MAT008000')
INSERT INTO temp_replacement_codes_2010 VALUES (
	'MED022010',
	'MEDICAL / Diseases / Abdominal' ,
	2,
	'MED031000 for scholarly works or works aimed at professionals; HEA039010 for popular works')
INSERT INTO temp_replacement_codes_2010 VALUES (
	'MED022030',
	'MEDICAL / Diseases / Bacterial' ,
	2,
	'MED022090 for scholarly works or works aimed at professionals; HEA039040 for popular works')
INSERT INTO temp_replacement_codes_2010 VALUES (
	'MED022040',
	'MEDICAL / Diseases / Cancer'    ,
	2,
	'MED062000 for scholarly works or works aimed at professionals; HEA039030 for popular works')
INSERT INTO temp_replacement_codes_2010 VALUES (
	'MED022050',
	'MEDICAL / Diseases / Cardiovascular',
	2,
	'MED010000 for scholarly works or works aimed at professionals; HEA039080 for popular works')
INSERT INTO temp_replacement_codes_2010 VALUES (
	'MED022060',
	'MEDICAL / Diseases / Cardiopulmonary',
	2,
	'MED010000 for scholarly works or works aimed at professionals; HEA039080 for popular works')
INSERT INTO temp_replacement_codes_2010 VALUES (
	'MED022070',
	'MEDICAL / Diseases / Brain'     ,
	2,
	'MED056000 for scholarly works or works aimed at professionals; HEA039110 for popular works')
INSERT INTO temp_replacement_codes_2010 VALUES (
	'MED022080',
	'MEDICAL / Diseases / Chronic'   ,
	2,
	'MED022000 for scholarly works or works aimed at professionals; HEA039000 for popular works')
INSERT INTO temp_replacement_codes_2010 VALUES (
	'MED022100',
	'MEDICAL / Diseases / Cutaneous' ,
	2,
	'MED017000 for scholarly works or works aimed at professionals; HEA039130 for popular works')
INSERT INTO temp_replacement_codes_2010 VALUES (
	'MED022110',
	'MEDICAL / Diseases / Digestive Organs'        ,
	2,
	'MED031000 for scholarly works or works aimed at professionals; HEA039010 for popular works')
INSERT INTO temp_replacement_codes_2010 VALUES (
	'MED022120',
	'MEDICAL / Diseases / Endocrine Glands'        ,
	2,
	'MED027000 for scholarly works or works aimed at professionals; HEA039000 for popular works')
INSERT INTO temp_replacement_codes_2010 VALUES (
	'MED022130',
	'MEDICAL / Diseases / Extremities'   ,
	2,
	'MED005000, MED073000 or MED075000 as appropriate for scholarly works or works aimed at professionals; HEA039100 for popular works')
INSERT INTO temp_replacement_codes_2010 VALUES (
	'MED022140',
	'MEDICAL / Diseases / Gastrointestinal'        ,
	2,
	'MED031000 for scholarly works or works aimed at professionals; HEA039010 for popular works')
INSERT INTO temp_replacement_codes_2010 VALUES (
	'MED022150',
	'MEDICAL / Diseases / Genitourinary' ,
	2,
	'MED088000 for scholarly works or works aimed at professionals; HEA039070 for popular works')
INSERT INTO temp_replacement_codes_2010 VALUES (
	'MED022160',
	'MEDICAL / Diseases / Immunological' ,
	2,
	'MED044000 for scholarly works or works aimed at professionals; HEA039090 for popular works')
INSERT INTO temp_replacement_codes_2010 VALUES (
	'MED022170',
	'MEDICAL / Diseases / Viral'     ,
	2,
	'MED022090 for scholarly works or works aimed at professionals; HEA039040 for popular works')
INSERT INTO temp_replacement_codes_2010 VALUES (
	'MED022180',
	'MEDICAL / Diseases / Diabetes'  ,
	2,
	'MED027000 for scholarly works or works aimed at professionals; HEA039050 for popular works')
INSERT INTO temp_replacement_codes_2010 VALUES (
	'MED022190',
	'MEDICAL / Diseases / Genetic'   ,
	2,
	'MED107000 for scholarly works or works aimed at professionals; HEA039060 for popular works')
INSERT INTO temp_replacement_codes_2010 VALUES (
	'MED022200',
	'MEDICAL / Diseases / Neuromuscular' ,
	2,
	'MED005000, MED056000, MED073000 or MED075000 as appropriate for scholarly works or works aimed at professionals; HEA039100 or HEA039110 as appropriate for popular works')
INSERT INTO temp_replacement_codes_2010 VALUES (
	'MED022210',
	'MEDICAL / Diseases / Nutritional'   ,
	2,
	'MED060000 for scholarly works or works aimed at professionals; HEA017000 for popular works')
INSERT INTO temp_replacement_codes_2010 VALUES (
	'MED022220',
	'MEDICAL / Diseases / Respiratory'   ,
	2,
	'MED079000 for scholarly works or works aimed at professionals; HEA039120 for popular works')
INSERT INTO temp_replacement_codes_2010 VALUES (
	'MED046000',
	'MEDICAL / Iridology'   ,
	2,
	'MED004000')
INSERT INTO temp_replacement_codes_2010 VALUES (
	'MED053000',
	'MEDICAL / Mind-Body Medicine (Psychoneuroimmunology)' ,
	2,
	'MED004000')
INSERT INTO temp_replacement_codes_2010 VALUES (
	'MED054000',
	'MEDICAL / Naturopathy' ,
	2,
	'HEA016000')
INSERT INTO temp_replacement_codes_2010 VALUES (
	'MED099000',
	'MEDICAL / Vascular Medicine'    ,
	2,
	'MED005000, MED075000 or MED085050'     )
INSERT INTO temp_replacement_codes_2010 VALUES (
	'MUS034000',
	'MUSIC / Rhythm & Blues',
	2.7,
	'MUS039000')
INSERT INTO temp_replacement_codes_2010 VALUES (
	'MUS043000',
	'MUSIC / World Beat'    ,
	2.7,
	'MUS024000')
INSERT INTO temp_replacement_codes_2010 VALUES (
	'MUS044000',
	'MUSIC / Bluegrass'     ,
	2.7,
	'MUS010000')
INSERT INTO temp_replacement_codes_2010 VALUES (
	'NAT006000',
	'NATURE / Cats'  ,
	2.5,
	'NAT019000 or appropriate code beginning with PET003')
INSERT INTO temp_replacement_codes_2010 VALUES (
	'NAT008000',
	'NATURE / Dogs'  ,
	2006,
	'appropriate code beginning with PET004')
INSERT INTO temp_replacement_codes_2010 VALUES (
	'NAT021000',
	'NATURE / Mice'  ,
	2.5,
	'NAT019000 or PET011000'                )
INSERT INTO temp_replacement_codes_2010 VALUES (
	'NAT035000',
	'NATURE / Volcanoes'    ,
	2.5,
	'NAT009000 or SCI082000'                )
INSERT INTO temp_replacement_codes_2010 VALUES (
	'NAT040000',
	'NATURE / Water Supply' ,
	2006,
	'appropriate code beginning with NAT, POL, or TEC.')
INSERT INTO temp_replacement_codes_2010 VALUES (
	'OCC001000',
	'BODY, MIND & SPIRIT / Analysis' ,
	2.2,
	'appropriate code beginning with OCC'   )
INSERT INTO temp_replacement_codes_2010 VALUES (
	'OCC013000',
	'BODY, MIND & SPIRIT / New Age'  ,
	2.2,
	'OCC000000 (or other appropriate code beginning with OCC)')
INSERT INTO temp_replacement_codes_2010 VALUES (
	'OCC036040',
	'BODY, MIND & SPIRIT / Spirituality / Greco-Roman'  ,
	2009,
	'OCC036000')
INSERT INTO temp_replacement_codes_2010 VALUES (
	'PER005000',
	'PERFORMING ARTS / Mass Media'   ,
	2.7,
	'SOC052000')
INSERT INTO temp_replacement_codes_2010 VALUES (
	'PER012000',
	'PERFORMING ARTS / Video / General',
	2.7,
	'PER004000')
INSERT INTO temp_replacement_codes_2010 VALUES (
	'PER012010',
	'PERFORMING ARTS / Video / Direction & Production'     ,
	2.7,
	'PER004010')
INSERT INTO temp_replacement_codes_2010 VALUES (
	'PER012020',
	'PERFORMING ARTS / Video / Guides & Reviews'   ,
	2.7,
	'PER004020')
INSERT INTO temp_replacement_codes_2010 VALUES (
	'PER012030',
	'PERFORMING ARTS / Video / Reference',
	2.7,
	'PER004040')
INSERT INTO temp_replacement_codes_2010 VALUES (
	'PET001000',
	'PETS / Aquarium',
	2.5,
	'PET005000')
INSERT INTO temp_replacement_codes_2010 VALUES (
	'PET007000',
	'PETS / Pigs'    ,
	2.5,
	'PET000000')
INSERT INTO temp_replacement_codes_2010 VALUES (
	'PHI017000',
	'PHILOSOPHY / Mysticism',
	2.3,
	'OCC012000 or REL047000'                )
INSERT INTO temp_replacement_codes_2010 VALUES (
	'PHI024000',
	'PHILOSOPHY / Western'  ,
	2.3,
	'appropriate code beginning with PHI'   )
INSERT INTO temp_replacement_codes_2010 VALUES (
	'PHO002000',
	'PHOTOGRAPHY / Camera Specific'  ,
	2.6,
	'PHO007000')
INSERT INTO temp_replacement_codes_2010 VALUES (
	'PHO008000',
	'PHOTOGRAPHY / Essays'  ,
	2.6,
	'appropriate code beginning with PHO'   )
INSERT INTO temp_replacement_codes_2010 VALUES (
	'POE002000',
	'POETRY / History & Criticism'   ,
	2.1,
	'LIT014000 (and any other appropriate code beginning with LIT)')
INSERT INTO temp_replacement_codes_2010 VALUES (
	'POE004000',
	'POETRY / Nursery Rhymes'        ,
	2,
	'JUV055000')
INSERT INTO temp_replacement_codes_2010 VALUES (
	'POE005000',
	'POETRY / Single Author / General'   ,
	2.1,
	'POE000000 (but note that geographic subheadings in the POE section can now be used for single-author or multiple-author collections)')
INSERT INTO temp_replacement_codes_2010 VALUES (
	'POE005040',
	'POETRY / Single Author / Other' ,
	2.1,
	'POE000000 (but note that geographic subheadings in the POE section can now be used for single-author or multiple-author collections)') 
INSERT INTO temp_replacement_codes_2010 VALUES (
	'POE006000',
	'POETRY / Reference'    ,
	2.1,
	'LIT012000 and/or LIT014000'            )
INSERT INTO temp_replacement_codes_2010 VALUES (
	'PSY001000',
	'PSYCHOLOGY & PSYCHIATRY / Adolescent Psychiatry'      ,
	2.3,
	'MED105010')
INSERT INTO temp_replacement_codes_2010 VALUES (
	'PSY005000',
	'PSYCHOLOGY & PSYCHIATRY / Child Psychiatry'   ,
	2.3,
	'MED105010')
INSERT INTO temp_replacement_codes_2010 VALUES (
	'PSY019000',
	'PSYCHOLOGY & PSYCHIATRY / Methodology'        ,
	2.3,
	'PSY030000 for works on psychological methodology; MED105000 for works on psychiatric methodology')
INSERT INTO temp_replacement_codes_2010 VALUES (
	'PSY025000',
	'PSYCHOLOGY & PSYCHIATRY / Psychiatry',
	2.3,
	'MED105000')
INSERT INTO temp_replacement_codes_2010 VALUES (
	'PSY027000',
	'PSYCHOLOGY & PSYCHIATRY / Psychopharmacology' ,
	2.3,
	'MED105020')
INSERT INTO temp_replacement_codes_2010 VALUES (
	'PSY033000',
	'PSYCHOLOGY & PSYCHIATRY / Substance Abuse'    ,
	2.3,
	'PSY038000')
INSERT INTO temp_replacement_codes_2010 VALUES (
	'PSY047000',
	'PSYCHOLOGY / Psychopathology / Abnormal',
	2.8,
	'PSY022000 or other appropriate code beginning with PSY')
INSERT INTO temp_replacement_codes_2010 VALUES (
	'REF003000',
	'REFERENCE / Basic Skills'       ,
	2,
	'REF015000')
INSERT INTO temp_replacement_codes_2010 VALUES (
	'REF005000',
	'REFERENCE / Business Skills'    ,
	2,
	'BUS059000')
INSERT INTO temp_replacement_codes_2010 VALUES (
	'REF012000',
	'REFERENCE / Etymology' ,
	2,
	'LAN024000')
INSERT INTO temp_replacement_codes_2010 VALUES (
	'REF014000',
	'REFERENCE / Maps'      ,
	2.8,
	'TRV027000')
INSERT INTO temp_replacement_codes_2010 VALUES (
	'REF016000',
	'REFERENCE / Public Speaking'    ,
	2,
	'LAN026000')
INSERT INTO temp_replacement_codes_2010 VALUES (
	'REF017000',
	'REFERENCE / Publishing',
	2,
	'LAN027000')
INSERT INTO temp_replacement_codes_2010 VALUES (
	'REF021000',
	'REFERENCE / Secretarial Aids & Training'      ,
	2,
	'BUS089000')
INSERT INTO temp_replacement_codes_2010 VALUES (
	'REF029000',
	'REFERENCE / Problems & Exercises'      ,
	2009,
	'code from appropriate section')
INSERT INTO temp_replacement_codes_2010 VALUES (
	'REL006010',
	'RELIGION / Bible / Accessories' ,
	2.3,
	'REL006000')
INSERT INTO temp_replacement_codes_2010 VALUES (
	'REL006170',
	'RELIGION / Bible / Stories / General',
	2.9,
	'JNF049040 for juvenile stories; REL006000 (or other appropriate code beginning with REL) for adult')
INSERT INTO temp_replacement_codes_2010 VALUES (
	'REL006180',
	'RELIGION / Bible / Stories / Old Testament'   ,
	2.9,
	'JNF049140 for juvenile stories; REL006000 (or other appropriate code beginning with REL) for adult')
INSERT INTO temp_replacement_codes_2010 VALUES (
	'REL006190',
	'RELIGION / Bible / Stories / New Testament'   ,
	2.9,
	'JNF049150 for juvenile stories; REL006000 (or other appropriate code beginning with REL) for adult')
INSERT INTO temp_replacement_codes_2010 VALUES (
	'REL006200',
	'RELIGION / Bible / Study / General' ,
	2.9,
	'REL006000')
INSERT INTO temp_replacement_codes_2010 VALUES (
	'REL006420',
	'RELIGION / Bible / Theology / General'        ,
	2.3,
	'appropriate code beginning with REL006 or REL067')
INSERT INTO temp_replacement_codes_2010 VALUES (
	'REL006430',
	'RELIGION / Bible / Theology / Old Testament'  ,
	2.3,
	'appropriate code beginning with REL006 or REL067' )
INSERT INTO temp_replacement_codes_2010 VALUES (
	'REL006440',
	'RELIGION / Bible / Theology / New Testament'  ,
	2.3,
	'appropriate code beginning with REL006 or REL067' )
INSERT INTO temp_replacement_codes_2010 VALUES (
	'REL006450',
	'RELIGION / Bibles / American Standard'        ,
	2.3,
	'appropriate code beginning with BIB'   )
INSERT INTO temp_replacement_codes_2010 VALUES (
	'REL006460',
	'RELIGION / Bibles / Amplified'  ,
	2006,
	'appropriate code beginning with BIB'   )
INSERT INTO temp_replacement_codes_2010 VALUES (
	'REL006470',
	'RELIGION / Bibles / Basic English',
	2006,
	'appropriate code beginning with BIB'   )
INSERT INTO temp_replacement_codes_2010 VALUES (
	'REL006230',
	'RELIGION / Bibles / Catholic'   ,
	2006,
	'appropriate code beginning with BIB'   )
INSERT INTO temp_replacement_codes_2010 VALUES (
	'REL006480',
	'RELIGION / Bibles / Clear Word Translation'   ,
	2.3,
	'appropriate code beginning with BIB'   )
INSERT INTO temp_replacement_codes_2010 VALUES (
	'REL006240',
	'RELIGION / Bibles / Contemporary English'     ,
	2006,
	'appropriate code beginning with BIB002')
INSERT INTO temp_replacement_codes_2010 VALUES (
	'REL006490',
	'RELIGION / Bibles / Douay'      ,
	2.3,
	'appropriate code beginning with BIB'   )
INSERT INTO temp_replacement_codes_2010 VALUES (
	'REL006250',
	'RELIGION / Bibles / Evangelical',
	2006,
	'appropriate code beginning with BIB'   )
INSERT INTO temp_replacement_codes_2010 VALUES (
	'REL006500',
	'RELIGION / Bibles / God''s Word' ,
	2006,
	'appropriate code beginning with BIB004')
INSERT INTO temp_replacement_codes_2010 VALUES (
	'REL006260',
	'RELIGION / Bibles / Greek'      ,
	2006,
	'appropriate code beginning with BIB'   )
INSERT INTO temp_replacement_codes_2010 VALUES (
	'REL006270',
	'RELIGION / Bibles / Hebrew'     ,
	2006,
	'appropriate code beginning with BIB'   )
INSERT INTO temp_replacement_codes_2010 VALUES (
	'REL006510',
	'RELIGION / Bibles / International Children''s' ,
	2006,
	'appropriate code beginning with BIB005')
INSERT INTO temp_replacement_codes_2010 VALUES (
	'REL006520',
	'RELIGION / Bibles / Jerusalem'  ,
	2.3,
	'appropriate code beginning with BIB'   )
INSERT INTO temp_replacement_codes_2010 VALUES (
	'REL006280',
	'RELIGION / Bibles / King James' ,
	2006,
	'appropriate code beginning with BIB006')
INSERT INTO temp_replacement_codes_2010 VALUES (
	'REL006290',
	'RELIGION / Bibles / Living'     ,
	2006,
	'appropriate code beginning with BIB'   )
INSERT INTO temp_replacement_codes_2010 VALUES (
	'REL006530',
	'RELIGION / Bibles / Message'    ,
	2.3,
	'appropriate code beginning with BIB020')
INSERT INTO temp_replacement_codes_2010 VALUES (
	'REL006540',
	'RELIGION / Bibles / New American'   ,
	2006,
	'appropriate code beginning with BIB009')
INSERT INTO temp_replacement_codes_2010 VALUES (
	'REL006300',
	'RELIGION / Bibles / New American Standard'    ,
	2006,
	'appropriate code beginning with BIB010')
INSERT INTO temp_replacement_codes_2010 VALUES (
	'REL006550',
	'RELIGION / Bibles / New American Standard Update'     ,
	2006,
	'appropriate code beginning with BIB010')
INSERT INTO temp_replacement_codes_2010 VALUES (
	'REL006310',
	'RELIGION / Bibles / New Century',
	2.3,
	'appropriate code beginning with BIB011')
INSERT INTO temp_replacement_codes_2010 VALUES (
	'REL006640',
	'RELIGION / Bibles / New Century',
	2006,
	'appropriate code beginning with BIB011')
INSERT INTO temp_replacement_codes_2010 VALUES (
	'REL006560',
	'RELIGION / Bibles / New English',
	2.3,
	'appropriate code beginning with BIB'   )
INSERT INTO temp_replacement_codes_2010 VALUES (
	'REL006320',
	'RELIGION / Bibles / New International'        ,
	2006,
	'appropriate code beginning with BIB013')
INSERT INTO temp_replacement_codes_2010 VALUES (
	'REL006570',
	'RELIGION / Bibles / New International Readers',
	2006,
	'appropriate code beginning with BIB012')
INSERT INTO temp_replacement_codes_2010 VALUES (
	'REL006330',
	'RELIGION / Bibles / New Jerusalem',
	2.3,
	'appropriate code beginning with BIB'   )
INSERT INTO temp_replacement_codes_2010 VALUES (
	'REL006340',
	'RELIGION / Bibles / New King James' ,
	2006,
	'appropriate code beginning with BIB014')
INSERT INTO temp_replacement_codes_2010 VALUES (
	'REL006580',
	'RELIGION / Bibles / New Living' ,
	2.3,
	'appropriate code beginning with BIB'   )
INSERT INTO temp_replacement_codes_2010 VALUES (
	'REL006590',
	'RELIGION / Bibles / New Living Translation'   ,
	2006,
	'appropriate code beginning with BIB015')
INSERT INTO temp_replacement_codes_2010 VALUES (
	'REL006350',
	'RELIGION / Bibles / New Revised Standard'     ,
	2006,
	'appropriate code beginning with BIB016')
INSERT INTO temp_replacement_codes_2010 VALUES (
	'REL006390',
	'RELIGION / Bibles / Other'      ,
	2006,
	'appropriate code beginning with BIB018')
INSERT INTO temp_replacement_codes_2010 VALUES (
	'REL006360',
	'RELIGION / Bibles / Parallel Editions'        ,
	2006,
	'appropriate code beginning with BIB008')
INSERT INTO temp_replacement_codes_2010 VALUES (
	'REL006600',
	'RELIGION / Bibles / Phillips Paraphrase'      ,
	2.3,
	'appropriate code beginning with BIB'   )
INSERT INTO temp_replacement_codes_2010 VALUES (
	'REL006610',
	'RELIGION / Bibles / Revised English',
	2006,
	'appropriate code beginning with BIB'   )
INSERT INTO temp_replacement_codes_2010 VALUES (
	'REL006370',
	'RELIGION / Bibles / Revised Standard',
	2006,
	'appropriate code beginning with BIB016')
INSERT INTO temp_replacement_codes_2010 VALUES (
	'REL006380',
	'RELIGION / Bibles / Today''s English',
	2006,
	'appropriate code beginning with BIB'   )
INSERT INTO temp_replacement_codes_2010 VALUES (
	'REL006620',
	'RELIGION / Bibles / 21st Century King James'  ,
	2.3,
	'appropriate code beginning with BIB'   )
INSERT INTO temp_replacement_codes_2010 VALUES (
	'REL031000',
	'RELIGION / Freemasonry',
	2.3,
	'SOC038000')
INSERT INTO temp_replacement_codes_2010 VALUES (
	'REL035000',
	'RELIGION / I Ching'    ,
	2.2,
	'OCC038000')
INSERT INTO temp_replacement_codes_2010 VALUES (
	'REL039000',
	'RELIGION / Jewish Life',
	NULL,
	'REL040010')
INSERT INTO temp_replacement_codes_2010 VALUES (
	'REL040020',
	'RELIGION / Judaism / Movements' ,
	2.3,
	'appropriate code beginning with REL040')
INSERT INTO temp_replacement_codes_2010 VALUES (
	'REL048000',
	'RELIGION / New Parish Ministry' ,
	2.3,
	'REL010000')
INSERT INTO temp_replacement_codes_2010 VALUES (
	'REL056000',
	'RELIGION / Roman Catholicism'   ,
	2.3,
	'REL010000')
INSERT INTO temp_replacement_codes_2010 VALUES (
	'REL057000',
	'RELIGION / Rosicrucianism'   ,
	2009,
	'OCC040000')
INSERT INTO temp_replacement_codes_2010 VALUES (
	'REL076000',
	'RELIGION / Sociology of Religion'   ,
	2.3,
	'SOC039000')
INSERT INTO temp_replacement_codes_2010 VALUES (
	'SCI002000',
	'SCIENCE / Anatomy (see also Human Anatomy)'   ,
	2.5,
	'SCI056000')
INSERT INTO temp_replacement_codes_2010 VALUES (
	'SCI006000',
	'SCIENCE / Life Sciences / Bacteriology'   ,
	2009,
	'SCI045000')
INSERT INTO temp_replacement_codes_2010 VALUES (
	'SCI014000',
	'SCIENCE / Clinical Science'     ,
	2.5,
	'SCI013020 or appropriate code beginning with MED')
INSERT INTO temp_replacement_codes_2010 VALUES (
	'SCI035000',
	'SCIENCE / Human Anatomy'        ,
	2.5,
	'SCI036000')
INSERT INTO temp_replacement_codes_2010 VALUES (
	'SCI037000',
	'SCIENCE / Light'        ,
	2009,
	'SCI053000')
INSERT INTO temp_replacement_codes_2010 VALUES (
	'SCI035000',
	'SCIENCE / Human Anatomy'        ,
	2.5,
	'SCI036000')
INSERT INTO temp_replacement_codes_2010 VALUES (
	'SCI044000',
	'SCIENCE / Metric System'       ,
	2009,
	'SCI068000')
INSERT INTO temp_replacement_codes_2010 VALUES (
	'SCI062000',
	'SCIENCE / Research'    ,
	2.5,
	'SCI043000')
INSERT INTO temp_replacement_codes_2010 VALUES (
	'SCI069000',
	'SCIENCE / Xenobiotics' ,
	2.5,
	'appropriate code beginning with MED or SCI')
INSERT INTO temp_replacement_codes_2010 VALUES (
	'SCI071000',
	'SCIENCE / Cellular Biology'     ,
	2,
	'SCI017000')
INSERT INTO temp_replacement_codes_2010 VALUES (
	'SEL002000',
	'SELF-HELP / Addiction' ,
	2.3,
	'SEL026000, SEL006000 or SEL013000'     )
INSERT INTO temp_replacement_codes_2010 VALUES (
	'SEL007000',
	'SELF-HELP / Chemical Dependence',
	2.3,
	'SEL026000, SEL006000 or SEL013000'     )
INSERT INTO temp_replacement_codes_2010 VALUES (
	'SEL022000',
	'SELF-HELP / Recovery'  ,
	2.3,
	'appropriate code beginning with SEL'   )
INSERT INTO temp_replacement_codes_2010 VALUES (
	'SEL025000',
	'SELF-HELP / Subliminal',
	2.3,
	'appropriate code beginning with SEL'   )
INSERT INTO temp_replacement_codes_2010 VALUES (
	'SEL028000',
	'SELF-HELP / Treatment' ,
	2.3,
	'appropriate code beginning with SEL'   )
INSERT INTO temp_replacement_codes_2010 VALUES (
	'SOC009000',
	'SOCIAL SCIENCE / Ethnology'     ,
	2.6,
	'SOC002010')
INSERT INTO temp_replacement_codes_2010 VALUES (
	'STU005000',
	'STUDY AIDS / CBAT'     ,
	2,
	'STU009000')
INSERT INTO temp_replacement_codes_2010 VALUES (
	'STU014000',
	'STUDY AIDS / Graduate Preparation'     ,
	2009,
	'code from appropriate section')
INSERT INTO temp_replacement_codes_2010 VALUES (
	'STU020000',
	'STUDY AIDS / Outlines' ,
	2,
	'code from appropriate section'         )
INSERT INTO temp_replacement_codes_2010 VALUES (
	'STU023000',
	'STUDY AIDS / Remedial' ,
	2,
	'code from appropriate section'         )
INSERT INTO temp_replacement_codes_2010 VALUES (
	'STU030000',
	'STUDY AIDS / Workbooks' ,
	2009,
	'code from appropriate section'         )
INSERT INTO temp_replacement_codes_2010 VALUES (
	'TEC008040',
	'TECHNOLOGY / Electronics / Circuits / Printed',
	2006,
	'TEC008010')
INSERT INTO temp_replacement_codes_2010 VALUES (
	'TEC009030',
	'TECHNOLOGY / Engineering / Electrical'        ,
	2006,
	'TEC007000')
INSERT INTO temp_replacement_codes_2010 VALUES (
	'TEC009040',
	'TECHNOLOGY / Engineering / Environmental'     ,
	2.5,
	'TEC010000')
INSERT INTO temp_replacement_codes_2010 VALUES (
	'TEC009050',
	'TECHNOLOGY / Engineering / Hydraulic',
	2006,
	'TEC014000')
INSERT INTO temp_replacement_codes_2010 VALUES (
	'TEC009080',
	'TECHNOLOGY / Engineering / Nuclear' ,
	2006,
	'TEC028000')
INSERT INTO temp_replacement_codes_2010 VALUES (
	'TEC042000',
	'TECHNOLOGY / Telephone Systems' ,
	2.5,
	'TEC041000')
INSERT INTO temp_replacement_codes_2010 VALUES (
	'TEC051000',
	'TECHNOLOGY / Hydrology',
	2.5,
	'SCI081000')
INSERT INTO temp_replacement_codes_2010 VALUES (
	'TEC038000',
	'TECHNOLOGY / Scanning Systems'  ,
	2006,
	'TEC008080 or TEC015000'                )
INSERT INTO temp_replacement_codes_2010 VALUES (
	'TEC053000',
	'TECHNOLOGY / Spectroscopy'      ,
	2.5,
	'SCI078000')
INSERT INTO temp_replacement_codes_2010 VALUES (
	'TRA001040',
	'TRANSPORTATION / Automotive / Domestic / General'     ,
	2.5,
	'TRA001000')
INSERT INTO temp_replacement_codes_2010 VALUES (
	'TRA001070',
	'TRANSPORTATION / Automotive / Domestic / Repair & Maintenance' ,
	2.5,
	'TRA001140')
INSERT INTO temp_replacement_codes_2010 VALUES (
	'TRA001080',
	'TRANSPORTATION / Automotive / Driver Education',
	2.5,
	'EDU047000')
INSERT INTO temp_replacement_codes_2010 VALUES (
	'TRA001090',
	'TRANSPORTATION / Automotive / Foreign / General'      ,
	2.5,
	'TRA001000')
INSERT INTO temp_replacement_codes_2010 VALUES (
	'TRA001100',
	'TRANSPORTATION / Automotive / Foreign / History'      ,
	2.5,
	'TRA001050')
INSERT INTO temp_replacement_codes_2010 VALUES (
	'TRA001110',
	'TRANSPORTATION / Automotive / Foreign / Pictorial'    ,
	2.5,
	'TRA001060')
INSERT INTO temp_replacement_codes_2010 VALUES (
	'TRA001120',
	'TRANSPORTATION / Automotive / Foreign / Repair & Maintenance'  ,
	2.5,
	'TRA001140')
INSERT INTO temp_replacement_codes_2010 VALUES (
	'TRA001130',
	'TRANSPORTATION / Automotive / High Performance & Engine Rebuilding',
	2.5,
	'TRA001030')
INSERT INTO temp_replacement_codes_2010 VALUES (
	'TRA002020',
	'TRANSPORTATION / Aviation / Pictorial'        ,
	2.5,
	'appropriate code beginning with TRA002')
INSERT INTO temp_replacement_codes_2010 VALUES (
	'TRA005000',
	'TRANSPORTATION / Reference'     ,
	2.5,
	'appropriate code beginning with TRA'   )
INSERT INTO temp_replacement_codes_2010 VALUES (
	'TRA007000',
	'TRANSPORTATION / Commercial'    ,
	2.6,
	'BUS070100')
INSERT INTO temp_replacement_codes_2010 VALUES (
	'TRV017000',
	'TRAVEL / North America',
	2006,
	'appropriate code beginning with TRV006 or TRV025 or code related to specific aspect of travel')
go
