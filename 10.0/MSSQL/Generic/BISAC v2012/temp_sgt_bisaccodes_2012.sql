IF EXISTS (SELECT * FROM dbo.sysobjects WHERE id = Object_id('temp_sgt_bisaccodes_2012') AND type = 'U')
  BEGIN
    DROP table temp_sgt_bisaccodes_2012
  END
go

CREATE TABLE temp_sgt_bisaccodes_2012 (
	Code char(255),
	Literal char(255))
go

--Added
INSERT INTO temp_sgt_bisaccodes_2012 VALUES (
	'BIO032000',
	'Social Activists')

--Changed
INSERT INTO temp_sgt_bisaccodes_2012 VALUES (
	'BUS070030',
	'Industries / Computers & Information Technology')

--Added
INSERT INTO temp_sgt_bisaccodes_2012 VALUES (
	'BUS070140',
	'Industries / Financial Services') 

--Added
INSERT INTO temp_sgt_bisaccodes_2012 VALUES (
	'BUS070150',
	'Industries / Natural Resource Extraction') 

--Added
INSERT INTO temp_sgt_bisaccodes_2012 VALUES (
	'BUS110000',
	'Conflict Resolution & Mediation') 

--Changed
INSERT INTO temp_sgt_bisaccodes_2012 VALUES (
	'CKB030000',
	'Essays and Narratives')  

--Added
INSERT INTO temp_sgt_bisaccodes_2012 VALUES (
	'CKB112000',
	'Courses & Dishes / Casseroles')

--Added
INSERT INTO temp_sgt_bisaccodes_2012 VALUES (
	'CKB113000',
	'Methods / Low Budget')

--Changed
INSERT INTO temp_sgt_bisaccodes_2012 VALUES (
	'COM015000',
	'Security / Viruses & Malware')

--Changed
INSERT INTO temp_sgt_bisaccodes_2012 VALUES (
	'COM021000',
	'Databases / General')

--Changed
INSERT INTO temp_sgt_bisaccodes_2012 VALUES (
	'COM021030',
	'Databases / Data Mining')

--Changed
INSERT INTO temp_sgt_bisaccodes_2012 VALUES (
	'COM021040',
	'Databases / Data Warehousing')

--Added
INSERT INTO temp_sgt_bisaccodes_2012 VALUES (
	'COM021050',
	'Databases / Servers')

--Changed
INSERT INTO temp_sgt_bisaccodes_2012 VALUES (
	'COM022000',
	'Desktop Applications / Desktop Publishing')

--Changed
INSERT INTO temp_sgt_bisaccodes_2012 VALUES (
	'COM043050',
	'Security / Networking')

--Changed
INSERT INTO temp_sgt_bisaccodes_2012 VALUES (
	'COM046040',
	'Operating Systems / Windows Desktop')

--Changed
INSERT INTO temp_sgt_bisaccodes_2012 VALUES (
	'COM046050',
	'Operating Systems / Windows Server')

--Changed
INSERT INTO temp_sgt_bisaccodes_2012 VALUES (
	'COM051370',
	'Programming / Macintosh')

--Changed
INSERT INTO temp_sgt_bisaccodes_2012 VALUES (
	'COM051380',
	'Programming / Microsoft')

--Changed
INSERT INTO temp_sgt_bisaccodes_2012 VALUES (
	'COM051460',
	'Programming / Mobile Devices')

--Added
INSERT INTO temp_sgt_bisaccodes_2012 VALUES (
	'COM051470',
	'Programming Languages / ASP.NET')

--Changed
INSERT INTO temp_sgt_bisaccodes_2012 VALUES (
	'COM060040',
	'Security / Online Safety & Privacy')

--Changed
INSERT INTO temp_sgt_bisaccodes_2012 VALUES (
	'COM060130',
	'Web / Design')

--Added
INSERT INTO temp_sgt_bisaccodes_2012 VALUES (
	'COM060170',
	'Web / Content Management Systems')

--Added
INSERT INTO temp_sgt_bisaccodes_2012 VALUES (
	'COM060180',
	'Web / Web Services & APIs')

--Changed
INSERT INTO temp_sgt_bisaccodes_2012 VALUES (
	'COM069000',
	'Online Services')

--Changed
INSERT INTO temp_sgt_bisaccodes_2012 VALUES (
	'COM074000',
	'Hardware / Mobile Devices')

--Changed
INSERT INTO temp_sgt_bisaccodes_2012 VALUES (
	'COM075000',
	'Networking / Hardware')

--Changed
INSERT INTO temp_sgt_bisaccodes_2012 VALUES (
	'COM087020',
	'Desktop Applications / Design & Graphics')

--Added
INSERT INTO temp_sgt_bisaccodes_2012 VALUES (
	'COM089000',
	'Data Visualization')

--Added
INSERT INTO temp_sgt_bisaccodes_2012 VALUES (
	'COM090000',
	'Hardware / Tablets')

--Added
INSERT INTO temp_sgt_bisaccodes_2012 VALUES (
	'CRA056000',
	'Dollhouses')

--Added
INSERT INTO temp_sgt_bisaccodes_2012 VALUES (
	'CRA057000',
	'Dolls & Doll Clothing')

--Added
INSERT INTO temp_sgt_bisaccodes_2012 VALUES (
	'EDU057000',
	'Arts in Education')

--Added
INSERT INTO temp_sgt_bisaccodes_2012 VALUES (
	'FAM049000',
	'Bullying')

--Changed
INSERT INTO temp_sgt_bisaccodes_2012 VALUES (
	'FIC006000',
	'Thrillers / Espionage') 

--Changed
INSERT INTO temp_sgt_bisaccodes_2012 VALUES (
	'FIC009040',
	'Fantasy / Collections & Anthologies') 

--Changed
INSERT INTO temp_sgt_bisaccodes_2012 VALUES (
	'FIC009060',
	'Fantasy / Urban') 

--Added
INSERT INTO temp_sgt_bisaccodes_2012 VALUES (
	'FIC009070',
	'Fantasy / Dark Fantasy')

--Changed
INSERT INTO temp_sgt_bisaccodes_2012 VALUES (
	'FIC022050',
	'Mystery & Detective / Collections & Anthologies') 

--Added
INSERT INTO temp_sgt_bisaccodes_2012 VALUES (
	'FIC022070',
	'Mystery & Detective / Cozy')

--Added
INSERT INTO temp_sgt_bisaccodes_2012 VALUES (
	'FIC022080',
	'Mystery & Detective / International Mystery & Crime')

--Added
INSERT INTO temp_sgt_bisaccodes_2012 VALUES (
	'FIC022090',
	'Mystery & Detective / Private Investigators')

--Changed
INSERT INTO temp_sgt_bisaccodes_2012 VALUES (
	'FIC027050',
	'Romance / Historical / General')

--Changed
INSERT INTO temp_sgt_bisaccodes_2012 VALUES (
	'FIC027070',
	'Romance / Historical / Regency')

--Changed
INSERT INTO temp_sgt_bisaccodes_2012 VALUES (
	'FIC027080',
	'Romance / Collections & Anthologies')

--Added
INSERT INTO temp_sgt_bisaccodes_2012 VALUES (
	'FIC027140',
	'Romance / Historical / Ancient World')

--Added
INSERT INTO temp_sgt_bisaccodes_2012 VALUES (
	'FIC027150',
	'Romance / Historical / Medieval')

--Added
INSERT INTO temp_sgt_bisaccodes_2012 VALUES (
	'FIC027160',
	'Romance / Historical / Scottish')

--Added
INSERT INTO temp_sgt_bisaccodes_2012 VALUES (
	'FIC027170',
	'Romance / Historical / Victorian')

--Added
INSERT INTO temp_sgt_bisaccodes_2012 VALUES (
	'FIC027180',
	'Romance / Historical / Viking')

--Changed
INSERT INTO temp_sgt_bisaccodes_2012 VALUES (
	'FIC028010',
	'Science Fiction / Action & Adventure')  

--Changed
INSERT INTO temp_sgt_bisaccodes_2012 VALUES (
	'FIC028020',
	'Science Fiction / Hard Science Fiction')  

--Changed
INSERT INTO temp_sgt_bisaccodes_2012 VALUES (
	'FIC028040',
	'Science Fiction / Collections & Anthologies') 

--Added
INSERT INTO temp_sgt_bisaccodes_2012 VALUES (
	'FIC028070',
	'Science Fiction / Apocalyptic & Post-Apocalyptic')

--Added
INSERT INTO temp_sgt_bisaccodes_2012 VALUES (
	'FIC028080',
	'Science Fiction / Time Travel') 

--Changed
INSERT INTO temp_sgt_bisaccodes_2012 VALUES (
	'FIC030000',
	'Thrillers / Suspense') 

--Changed
INSERT INTO temp_sgt_bisaccodes_2012 VALUES (
	'FIC031000',
	'Thrillers / General') 

--Added
INSERT INTO temp_sgt_bisaccodes_2012 VALUES (
	'FIC031010',
	'Thrillers / Crime') 

--Added
INSERT INTO temp_sgt_bisaccodes_2012 VALUES (
	'FIC031020',
	'Thrillers / Historical') 

--Added
INSERT INTO temp_sgt_bisaccodes_2012 VALUES (
	'FIC031030',
	'Thrillers / Legal') 

--Added
INSERT INTO temp_sgt_bisaccodes_2012 VALUES (
	'FIC031040',
	'Thrillers / Medical') 

--Added
INSERT INTO temp_sgt_bisaccodes_2012 VALUES (
	'FIC031050',
	'Thrillers / Military') 

--Added
INSERT INTO temp_sgt_bisaccodes_2012 VALUES (
	'FIC031060',
	'Thrillers / Political') 

--Changed
INSERT INTO temp_sgt_bisaccodes_2012 VALUES (
	'FIC036000',
	'Thrillers / Technological')

--Changed
INSERT INTO temp_sgt_bisaccodes_2012 VALUES (
	'FIC042050',
	'Christian / Collections & Anthologies')

--Changed
INSERT INTO temp_sgt_bisaccodes_2012 VALUES (
	'FIC048000',
	'Urban')

--Changed
INSERT INTO temp_sgt_bisaccodes_2012 VALUES (
	'FIC049060',
	'Romance / African American')

--Changed
INSERT INTO temp_sgt_bisaccodes_2012 VALUES (
	'FIC049070',
	'African American / Urban')

--Added
INSERT INTO temp_sgt_bisaccodes_2012 VALUES (
	'FIC058000',
	'Holidays') 

--Added
INSERT INTO temp_sgt_bisaccodes_2012 VALUES (
	'FIC059000',
	'Native American & Aboriginal') 

--Changed
INSERT INTO temp_sgt_bisaccodes_2012 VALUES (
	'GAR002000',
	'Essays & Narratives') 

--Changed
INSERT INTO temp_sgt_bisaccodes_2012 VALUES (
	'HEA006000',
	'Diet & Nutrition / Diets') 

--Changed
INSERT INTO temp_sgt_bisaccodes_2012 VALUES (
	'HEA013000',
	'Diet & Nutrition / Macrobiotics') 

--Changed
INSERT INTO temp_sgt_bisaccodes_2012 VALUES (
	'HEA017000',
	'Diet & Nutrition / Nutrition') 

--Changed
INSERT INTO temp_sgt_bisaccodes_2012 VALUES (
	'HEA019000',
	'Diet & Nutrition / Weight Loss') 

--Changed
INSERT INTO temp_sgt_bisaccodes_2012 VALUES (
	'HEA023000',
	'Diet & Nutrition / Vitamins') 

--Changed
INSERT INTO temp_sgt_bisaccodes_2012 VALUES (
	'HEA034000',
	'Diet & Nutrition / Food Content Guides') 

--Added
INSERT INTO temp_sgt_bisaccodes_2012 VALUES (
	'HEA048000',
	'Diet & Nutrition / General') 

--Changed
INSERT INTO temp_sgt_bisaccodes_2012 VALUES (
	'HIS019000',
	'Middle East / Israel & Palestine') 

--Added
INSERT INTO temp_sgt_bisaccodes_2012 VALUES (
	'HIS026010',
	'Middle East / Arabian Peninsula')

--Added
INSERT INTO temp_sgt_bisaccodes_2012 VALUES (
	'HIS026020',
	'Middle East / Iran')

--Added
INSERT INTO temp_sgt_bisaccodes_2012 VALUES (
	'HIS026030',
	'Middle East / Iraq')

--Changed
INSERT INTO temp_sgt_bisaccodes_2012 VALUES (
	'HIS027170',
	'Military / Iraq War (2003-2011)') 

--Added
INSERT INTO temp_sgt_bisaccodes_2012 VALUES (
	'HUM017000',
	'Form / Pictorial') 

--Added
INSERT INTO temp_sgt_bisaccodes_2012 VALUES (
	'JUV060000',
	'Gay & Lesbian') 

--Added
INSERT INTO temp_sgt_bisaccodes_2012 VALUES (
	'JUV061000',
	'Politics & Government') 

--Added
INSERT INTO temp_sgt_bisaccodes_2012 VALUES (
	'JUV062000',
	'Steampunk') 

--Added
INSERT INTO temp_sgt_bisaccodes_2012 VALUES (
	'LAN025060',
	'Library & Information Science / Digital & Online Resources') 

--Added
INSERT INTO temp_sgt_bisaccodes_2012 VALUES (
	'LIT020000',
	'Comparative Literature') 

--Added
INSERT INTO temp_sgt_bisaccodes_2012 VALUES (
	'LIT021000',
	'Horror & Supernatural') 

--Changed
INSERT INTO temp_sgt_bisaccodes_2012 VALUES (
	'MED004000',
	'Alternative & Complementary Medicine') 

--Added
INSERT INTO temp_sgt_bisaccodes_2012 VALUES (
	'MED016080',
	'Dentistry / Dental Implants')

--Added
INSERT INTO temp_sgt_bisaccodes_2012 VALUES (
	'MED016090',
	'Dentistry / Practice Management')

--Added
INSERT INTO temp_sgt_bisaccodes_2012 VALUES (
	'MED115000',
	'Infection Control')

--Added
INSERT INTO temp_sgt_bisaccodes_2012 VALUES (
	'MUS037120',
	'Printed Music / Brass')

--Added
INSERT INTO temp_sgt_bisaccodes_2012 VALUES (
	'MUS037130',
	'Printed Music / Strings')

--Added
INSERT INTO temp_sgt_bisaccodes_2012 VALUES (
	'MUS037140',
	'Printed Music / Woodwinds')

--Changed
INSERT INTO temp_sgt_bisaccodes_2012 VALUES (
	'OCC026000',
	'Witchcraft (see also RELIGION / Wicca)')  

--Added
INSERT INTO temp_sgt_bisaccodes_2012 VALUES (
	'PER003090',
	'Dance / Ballroom') 

--Added
INSERT INTO temp_sgt_bisaccodes_2012 VALUES (
	'PER003100',
	'Dance / History & Criticism') 

--Changed
INSERT INTO temp_sgt_bisaccodes_2012 VALUES (
	'PET006000',
	'Horses')

--Changed
INSERT INTO temp_sgt_bisaccodes_2012 VALUES (
	'PET010000',
	'Essays & Narratives')

--Added
INSERT INTO temp_sgt_bisaccodes_2012 VALUES (
	'POL061000',
	'Genocide & War Crimes') 

--Added
INSERT INTO temp_sgt_bisaccodes_2012 VALUES (
	'POL062000',
	'Geopolitics') 

--Added
INSERT INTO temp_sgt_bisaccodes_2012 VALUES (
	'POL063000',
	'Public Policy / Science & Technology Policy') 

--Changed
INSERT INTO temp_sgt_bisaccodes_2012 VALUES (
	'REF002000',
	'Atlases, Gazetteers & Maps (see also TRAVEL / Maps & Road Atlases)') 

--Added
INSERT INTO temp_sgt_bisaccodes_2012 VALUES (
	'REL117000',
	'Paganism & Neo-Paganism') 

--Added
INSERT INTO temp_sgt_bisaccodes_2012 VALUES (
	'REL118000',
	'Wicca (see also BODY, MIND & SPIRIT / Witchcraft)') 

--Added
INSERT INTO temp_sgt_bisaccodes_2012 VALUES (
	'SCI099000',
	'Life Sciences / Virology') 

--Added
INSERT INTO temp_sgt_bisaccodes_2012 VALUES (
	'SCI100000',
	'Natural History') 

--Added
INSERT INTO temp_sgt_bisaccodes_2012 VALUES (
	'SEL038000',
	'Fashion & Style') 

--Added
INSERT INTO temp_sgt_bisaccodes_2012 VALUES (
	'SEL039000',
	'Green Lifestyle') 

--Added
INSERT INTO temp_sgt_bisaccodes_2012 VALUES (
	'SOC061000',
	'Body Language & Nonverbal Communication') 

--Added
INSERT INTO temp_sgt_bisaccodes_2012 VALUES (
	'SOC062000',
	'Indigenous Studies') 

--Added
INSERT INTO temp_sgt_bisaccodes_2012 VALUES (
	'SPO073000',
	'Field Hockey') 

--Added
INSERT INTO temp_sgt_bisaccodes_2012 VALUES (
	'TEC003100',
	'Agriculture / Beekeeping') 

--Added
INSERT INTO temp_sgt_bisaccodes_2012 VALUES (
	'TRA010000',
	'Bicycles') 

--Changed
INSERT INTO temp_sgt_bisaccodes_2012 VALUES (
	'TRV003040',
	'Asia / India & South Asia') 

--Changed
INSERT INTO temp_sgt_bisaccodes_2012 VALUES (
	'TRV009120',
	'Europe / Scandinavia (Finland, Norway, Sweden)') 

--Added
INSERT INTO temp_sgt_bisaccodes_2012 VALUES (
	'TRV009160',
	'Europe / Cyprus')

--Changed
INSERT INTO temp_sgt_bisaccodes_2012 VALUES (
	'TRV025120',
	'United States / West / Mountain (AZ, CO, ID, MT, NM, NV, UT, WY)')  

--Changed
INSERT INTO temp_sgt_bisaccodes_2012 VALUES (
	'TRV025130',
	'United States / West / Pacific (AK, CA, HI, OR, WA)')  

--Changed
INSERT INTO temp_sgt_bisaccodes_2012 VALUES (
	'TRV027000',
	'Maps & Road Atlases (see also REFERENCE / Atlases, Gazetteers & Maps)')

--Added
INSERT INTO temp_sgt_bisaccodes_2012 VALUES (
	'TRV035000',
	'Rail Travel')    
go