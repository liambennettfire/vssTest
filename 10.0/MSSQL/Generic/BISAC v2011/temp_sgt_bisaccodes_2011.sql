IF EXISTS (SELECT * FROM dbo.sysobjects WHERE id = Object_id('temp_sgt_bisaccodes_2011') AND type = 'U')
  BEGIN
    DROP table temp_sgt_bisaccodes_2011
  END
go

CREATE TABLE temp_sgt_bisaccodes_2011 (
	Code char(255),
	Literal char(255))
go


--Changed
INSERT INTO temp_sgt_bisaccodes_2011 VALUES (
	'OCC022000',
	'Afterlife & Reincarnation')  

--Changed
INSERT INTO temp_sgt_bisaccodes_2011 VALUES (
	'OCC003000',
	'Channeling & Mediumship')  

--Added
INSERT INTO temp_sgt_bisaccodes_2011 VALUES (
	'CGN004220',
	'Manga / Religious') 

--Added
INSERT INTO temp_sgt_bisaccodes_2011 VALUES (
	'CGN011000',
	'Religious') 

--Added
INSERT INTO temp_sgt_bisaccodes_2011 VALUES (
	'CKB111000',
	'Health & Healing / Gluten-Free') 

--Changed
INSERT INTO temp_sgt_bisaccodes_2011 VALUES (
	'DRA001000',
	'American / General')  

--Added
INSERT INTO temp_sgt_bisaccodes_2011 VALUES (
	'DRA001010',
	'American / African American')  

--Changed
INSERT INTO temp_sgt_bisaccodes_2011 VALUES (
	'DRA006000',
	'Ancient & Classical')  

--Changed
INSERT INTO temp_sgt_bisaccodes_2011 VALUES (
	'DRA005000',
	'Asian / General') 

-- Added
INSERT INTO temp_sgt_bisaccodes_2011 VALUES (
	'DRA005010',
	'Asian / Japanese') 

--Changed
INSERT INTO temp_sgt_bisaccodes_2011 VALUES (
	'DRA004000',
	'European / General') 

--Changed
INSERT INTO temp_sgt_bisaccodes_2011 VALUES (
	'DRA003000',
	'European / English, Irish, Scottish, Welsh') 

--Added
INSERT INTO temp_sgt_bisaccodes_2011 VALUES (
	'DRA004010',
	'European / French') 

--Added
INSERT INTO temp_sgt_bisaccodes_2011 VALUES (
	'DRA004020',
	'European / German') 

--Added
INSERT INTO temp_sgt_bisaccodes_2011 VALUES (
	'DRA004030',
	'European / Italian') 

--Added
INSERT INTO temp_sgt_bisaccodes_2011 VALUES (
	'DRA004040',
	'European / Spanish & Portuguese') 

--Added
INSERT INTO temp_sgt_bisaccodes_2011 VALUES (
	'DRA017000',
	'Gay & Lesbian') 

--Added
INSERT INTO temp_sgt_bisaccodes_2011 VALUES (
	'DRA018000',
	'Medieval') 

--Added
INSERT INTO temp_sgt_bisaccodes_2011 VALUES (
	'DRA019000',
	'Women Authors') 

--Added
INSERT INTO temp_sgt_bisaccodes_2011 VALUES (
	'EDU001020',
	'Administration / Elementary & Secondary')  

--Changed
INSERT INTO temp_sgt_bisaccodes_2011 VALUES (
	'EDU001010',
	'Administration / Facility Management')  

--Added
INSERT INTO temp_sgt_bisaccodes_2011 VALUES (
	'EDU001030',
	'Administration / Higher')  

--Added
INSERT INTO temp_sgt_bisaccodes_2011 VALUES (
	'EDU001040',
	' Administration / School Superintendents & Principals') 

--Added
INSERT INTO temp_sgt_bisaccodes_2011 VALUES (
	'EDU049000',
	'Behavioral Management') 

--Added
INSERT INTO temp_sgt_bisaccodes_2011 VALUES (
	'EDU050000',
	'Collaborative & Team Teaching') 

--Changed
INSERT INTO temp_sgt_bisaccodes_2011 VALUES (
	'EDU014000',
	'Counseling / Academic Development') 

--Changed
INSERT INTO temp_sgt_bisaccodes_2011 VALUES (
	'EDU031000',
	'Counseling / Career Development') 

--Changed
INSERT INTO temp_sgt_bisaccodes_2011 VALUES (
	'EDU041000',
	'Distance & Online Education') 

--Added
INSERT INTO temp_sgt_bisaccodes_2011 VALUES (
	'EDU034020',
	'Educational Policy & Reform / Charter Schools') 

--Added
INSERT INTO temp_sgt_bisaccodes_2011 VALUES (
	'EDU034030',
	'Educational Policy & Reform / Federal Legislation') 

--Changed
INSERT INTO temp_sgt_bisaccodes_2011 VALUES (
	'EDU034010',
	'Educational Policy & Reform / School Safety') 

--Changed
INSERT INTO temp_sgt_bisaccodes_2011 VALUES (
	'EDU011000',
	'Evaluation & Assessment') 

--Added
INSERT INTO temp_sgt_bisaccodes_2011 VALUES (
	'EDU051000',
	'Learning Styles')  

--Added
INSERT INTO temp_sgt_bisaccodes_2011 VALUES (
	'EDU052000',
	'Rural')  

--Changed
INSERT INTO temp_sgt_bisaccodes_2011 VALUES (
	'EDU038000',
	'Student Life & Student Affairs') 

--Added
INSERT INTO temp_sgt_bisaccodes_2011 VALUES (
	'EDU029080',
	'Teaching Methods & Materials / Language Arts') 

--Added
INSERT INTO temp_sgt_bisaccodes_2011 VALUES (
	'EDU053000',
	'Training & Certification') 

--Added
INSERT INTO temp_sgt_bisaccodes_2011 VALUES (
	'EDU054000',
	'Urban') 

--Added
INSERT INTO temp_sgt_bisaccodes_2011 VALUES (
	'EDU055000',
	'Violence & Harassment') 

--Added
INSERT INTO temp_sgt_bisaccodes_2011 VALUES (
	'EDU056000',
	'Vocational')

--Added
INSERT INTO temp_sgt_bisaccodes_2011 VALUES (
	'FAM047000',
	'Attention Deficit Disorder (ADD-ADHD)')

--Added
INSERT INTO temp_sgt_bisaccodes_2011 VALUES (
	'FAM048000',
	'Autism Spectrum Disorders')

--Added
INSERT INTO temp_sgt_bisaccodes_2011 VALUES (
	'FIC053000',
	'Amish & Mennonite')

--Added
INSERT INTO temp_sgt_bisaccodes_2011 VALUES (
	'FIC054000',
	'Asian American')

--Added
INSERT INTO temp_sgt_bisaccodes_2011 VALUES (
	'FIC055000',
	'Dystopian')

--Added
INSERT INTO temp_sgt_bisaccodes_2011 VALUES (
	'FIC056000',
	'Hispanic & Latino')

--Added
INSERT INTO temp_sgt_bisaccodes_2011 VALUES (
	'FIC057000',
	'Mashups')

--Changed
INSERT INTO temp_sgt_bisaccodes_2011 VALUES (
	'FIC027010',
	'Romance / Erotica') 

--Added
INSERT INTO temp_sgt_bisaccodes_2011 VALUES (
	'FIC027130',
	'Romance / Science Fiction')

--Added
INSERT INTO temp_sgt_bisaccodes_2011 VALUES (
	'FIC028060',
	'Science Fiction / Steampunk')

--Added
INSERT INTO temp_sgt_bisaccodes_2011 VALUES (
	'HEA047000',
	'Body Cleansing & Detoxification')

--Changed
INSERT INTO temp_sgt_bisaccodes_2011 VALUES (
	'HEA039010',
	'Diseases / Gastrointestinal') 

--Added
INSERT INTO temp_sgt_bisaccodes_2011 VALUES (
	'HUM016000',
	'Form / Trivia')

--Added
INSERT INTO temp_sgt_bisaccodes_2011 VALUES (
	'JUV002370',
	'Animals / Baby Animals')

--Added
INSERT INTO temp_sgt_bisaccodes_2011 VALUES (
	'JUV059000',
	'Dystopian')

--Added
INSERT INTO temp_sgt_bisaccodes_2011 VALUES (
	'JNF003330',
	'Animals / Baby Animals')

--Added
INSERT INTO temp_sgt_bisaccodes_2011 VALUES (
	'JNF007130',
	'Biography & Autobiography / Presidents & First Families (U.S.)')

--Added
INSERT INTO temp_sgt_bisaccodes_2011 VALUES (
	'JNF007140',
	'Biography & Autobiography / Royalty')

--Changed
INSERT INTO temp_sgt_bisaccodes_2011 VALUES (
	'LCO003000',
	'Ancient & Classical') 

--Changed
INSERT INTO temp_sgt_bisaccodes_2011 VALUES (
	'LCO004000',
	'Asian / General') 

--Added
INSERT INTO temp_sgt_bisaccodes_2011 VALUES (
	'LCO004010',
	'Asian / Chinese') 

--Added
INSERT INTO temp_sgt_bisaccodes_2011 VALUES (
	'LCO004020',
	'Asian / Indic') 

--Added
INSERT INTO temp_sgt_bisaccodes_2011 VALUES (
	'LCO004030',
	'Asian / Japanese') 

--Added
INSERT INTO temp_sgt_bisaccodes_2011 VALUES (
	'LCO015000',
	'Diaries & Journals') 

--Changed
INSERT INTO temp_sgt_bisaccodes_2011 VALUES (
	'LCO008000',
	'European / General') 

--Added
INSERT INTO temp_sgt_bisaccodes_2011 VALUES (
	'LCO008010',
	'European / Eastern (see also Russian & Former Soviet Union)') 

--Changed
INSERT INTO temp_sgt_bisaccodes_2011 VALUES (
	'LCO009000',
	'European / English, Irish, Scottish, Welsh')

--Added
INSERT INTO temp_sgt_bisaccodes_2011 VALUES (
	'LCO008020',
	'European / French') 

--Added
INSERT INTO temp_sgt_bisaccodes_2011 VALUES (
	'LCO008030',
	'European / German') 

--Added
INSERT INTO temp_sgt_bisaccodes_2011 VALUES (
	'LCO008040',
	'European / Italian') 

--Added
INSERT INTO temp_sgt_bisaccodes_2011 VALUES (
	'LCO008050',
	'European / Scandinavian') 

--Added
INSERT INTO temp_sgt_bisaccodes_2011 VALUES (
	'LCO008060',
	'European / Spanish & Portuguese') 

--Added
INSERT INTO temp_sgt_bisaccodes_2011 VALUES (
	'LCO016000',
	'Gay & Lesbian') 

--Added
INSERT INTO temp_sgt_bisaccodes_2011 VALUES (
	'LCO017000',
	'Medieval') 


--Added
INSERT INTO temp_sgt_bisaccodes_2011 VALUES (
	'LCO018000',
	'Speeches') 

--Added
INSERT INTO temp_sgt_bisaccodes_2011 VALUES (
	'LCO019000',
	'Women Authors') 

--Changed
INSERT INTO temp_sgt_bisaccodes_2011 VALUES (
	'PER020000',
	'Monologues & Scenes')


--Changed
INSERT INTO temp_sgt_bisaccodes_2011 VALUES (
	'POE008000',
	'Ancient & Classical')

--Changed
INSERT INTO temp_sgt_bisaccodes_2011 VALUES (
	'POE009000',
	'Asian / General') 

--Added
INSERT INTO temp_sgt_bisaccodes_2011 VALUES (
	'POE009010',
	'Asian / Chinese') 

--Added
INSERT INTO temp_sgt_bisaccodes_2011 VALUES (
	'POE009020',
	'Asian / Japanese') 

--Changed
INSERT INTO temp_sgt_bisaccodes_2011 VALUES (
	'POE005030',
	'European / General') 


--Changed
INSERT INTO temp_sgt_bisaccodes_2011 VALUES (
	'POE005020',
	'European / English, Irish, Scottish, Welsh')

--Added
INSERT INTO temp_sgt_bisaccodes_2011 VALUES (
	'POE017000',
	'European / French') 

--Added
INSERT INTO temp_sgt_bisaccodes_2011 VALUES (
	'POE018000',
	'European / German') 

--Added
INSERT INTO temp_sgt_bisaccodes_2011 VALUES (
	'POE019000',
	'European / Italian') 

--Added
INSERT INTO temp_sgt_bisaccodes_2011 VALUES (
	'POE020000',
	'European / Spanish & Portuguese') 

--Added
INSERT INTO temp_sgt_bisaccodes_2011 VALUES (
	'POE021000',
	'Gay & Lesbian') 

--Added
INSERT INTO temp_sgt_bisaccodes_2011 VALUES (
	'POE022000',
	'Medieval') 

--Added
INSERT INTO temp_sgt_bisaccodes_2011 VALUES (
	'POE023000',
	'Subjects & Themes / General') 

--Added
INSERT INTO temp_sgt_bisaccodes_2011 VALUES (
	'POE023010',
	'Subjects & Themes / Death') 

--Changed
INSERT INTO temp_sgt_bisaccodes_2011 VALUES (
	'POE003000',
	'Subjects & Themes / Inspirational & Religious') 

--Added
INSERT INTO temp_sgt_bisaccodes_2011 VALUES (
	'POE023020',
	'Subjects & Themes / Love') 

--Added
INSERT INTO temp_sgt_bisaccodes_2011 VALUES (
	'POE023030',
	'Subjects & Themes / Nature') 

--Added
INSERT INTO temp_sgt_bisaccodes_2011 VALUES (
	'POE023040',
	'Subjects & Themes / Places') 

--Added
INSERT INTO temp_sgt_bisaccodes_2011 VALUES (
	'POE024000',
	'Women Authors') 

--Changed
INSERT INTO temp_sgt_bisaccodes_2011 VALUES (
	'POL040000',
	'American Government / General') 

--Changed
INSERT INTO temp_sgt_bisaccodes_2011 VALUES (
	'POL040010',
	'American Government / Executive Branch') 

--Changed
INSERT INTO temp_sgt_bisaccodes_2011 VALUES (
	'POL040030',
	'American Government / Judicial Branch') 

--Changed
INSERT INTO temp_sgt_bisaccodes_2011 VALUES (
	'POL006000',
	'American Government / Legislative Branch') 

--Changed
INSERT INTO temp_sgt_bisaccodes_2011 VALUES (
	'POL040040',
	'American Government / Local') 

--Changed
INSERT INTO temp_sgt_bisaccodes_2011 VALUES (
	'POL030000',
	'American Government / National') 

--Changed
INSERT INTO temp_sgt_bisaccodes_2011 VALUES (
	'POL020000',
	'American Government / State') 

--Changed
INSERT INTO temp_sgt_bisaccodes_2011 VALUES (
	'POL004000',
	'Civil Rights') 

--Added
INSERT INTO temp_sgt_bisaccodes_2011 VALUES (
	'POL046000',
	'Commentary & Opinion') 

--Changed
INSERT INTO temp_sgt_bisaccodes_2011 VALUES (
	'POL009000',
	'Comparative Politics') 

--Changed
INSERT INTO temp_sgt_bisaccodes_2011 VALUES (
	'POL035010',
	'Human Rights') 

--Added
INSERT INTO temp_sgt_bisaccodes_2011 VALUES (
	'POL047000',
	'Imperialism') 

--Changed
INSERT INTO temp_sgt_bisaccodes_2011 VALUES (
	'POL036000',
	'Intelligence & Espionage') 

--Added
INSERT INTO temp_sgt_bisaccodes_2011 VALUES (
	'POL048000',
	'Intergovernmental Organizations') 

--Changed
INSERT INTO temp_sgt_bisaccodes_2011 VALUES (
	'POL014000',
	'Law Enforcement') 

--Changed
INSERT INTO temp_sgt_bisaccodes_2011 VALUES (
	'POL023000',
	'Political Economy') 

--Changed
INSERT INTO temp_sgt_bisaccodes_2011 VALUES (
	'POL035000',
	'Political Freedom') 

--Changed
INSERT INTO temp_sgt_bisaccodes_2011 VALUES (
	'POL005000',
	'Political Ideologies / Communism, Post-Communism & Socialism') 

--Changed
INSERT INTO temp_sgt_bisaccodes_2011 VALUES (
	'POL031000',
	'Political Ideologies / Nationalism & Patriotism') 

--Added
INSERT INTO temp_sgt_bisaccodes_2011 VALUES (
	'POL042040',
	'Political Ideologies / Radicalism') 

--Added
INSERT INTO temp_sgt_bisaccodes_2011 VALUES (
	'POL049000',
	'Propaganda') 

--Added
INSERT INTO temp_sgt_bisaccodes_2011 VALUES (
	'POL050000',
	'Public Policy / Communication Policy') 

--Changed
INSERT INTO temp_sgt_bisaccodes_2011 VALUES (
	'POL012000',
	'Security (National & International)') 

--Changed
INSERT INTO temp_sgt_bisaccodes_2011 VALUES (
	'POL037000',
	'Terrorism')

--Added
INSERT INTO temp_sgt_bisaccodes_2011 VALUES (
	'POL051000',
	'Utopias') 

--Added
INSERT INTO temp_sgt_bisaccodes_2011 VALUES (
	'POL052000',
	'Women in Politics') 

--Changed
INSERT INTO temp_sgt_bisaccodes_2011 VALUES (
	'POL040020',
	'World / General')

--Added
INSERT INTO temp_sgt_bisaccodes_2011 VALUES (
	'POL053000',
	'World / African') 

--Added
INSERT INTO temp_sgt_bisaccodes_2011 VALUES (
	'POL054000',
	'World / Asian') 

--Added
INSERT INTO temp_sgt_bisaccodes_2011 VALUES (
	'POL055000',
	'World / Australian & Oceanian') 

--Added
INSERT INTO temp_sgt_bisaccodes_2011 VALUES (
	'POL056000',
	'World / Canadian') 

--Added
INSERT INTO temp_sgt_bisaccodes_2011 VALUES (
	'POL057000',
	'World / Caribbean & Latin American') 

--Added
INSERT INTO temp_sgt_bisaccodes_2011 VALUES (
	'POL058000',
	'World / European') 

--Added
INSERT INTO temp_sgt_bisaccodes_2011 VALUES (
	'POL059000',
	'World / Middle Eastern') 

--Added
INSERT INTO temp_sgt_bisaccodes_2011 VALUES (
	'POL060000',
	'World / Russian & Former Soviet Union') 

--Changed
INSERT INTO temp_sgt_bisaccodes_2011 VALUES (
	'TEC021000',
	'Materials Science')
go