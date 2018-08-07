IF EXISTS (SELECT * FROM dbo.sysobjects WHERE id = Object_id('temp_sgt_bisaccodes_2013') AND type = 'U')
  BEGIN
    DROP table temp_sgt_bisaccodes_2013
  END
go

CREATE TABLE temp_sgt_bisaccodes_2013 (
	Code char(255),
	Literal char(255))
go

--Changed
INSERT INTO temp_sgt_bisaccodes_2013 VALUES (
	'BIO031000',
	'LGBT')

--Added
INSERT INTO temp_sgt_bisaccodes_2013 VALUES (
	'BIO033000',
	'People with Disabilities')

--Changed
INSERT INTO temp_sgt_bisaccodes_2013 VALUES (
	'OCC036010',
	'Celtic Spirituality') 

--Changed
INSERT INTO temp_sgt_bisaccodes_2013 VALUES (
	'OCC036050',
	'Goddess Worship') 

--Changed
INSERT INTO temp_sgt_bisaccodes_2013 VALUES (
	'OCC010000',
	'Mindfulness & Meditation') 

--Changed
INSERT INTO temp_sgt_bisaccodes_2013 VALUES (
	'OCC036030',
	'Shamanism')  

--Changed
INSERT INTO temp_sgt_bisaccodes_2013 VALUES (
	'BUS017000',
	'Corporate Finance / General')

--Added
INSERT INTO temp_sgt_bisaccodes_2013 VALUES (
	'BUS017010',
	'Corporate Finance / Private Equity')

--Added
INSERT INTO temp_sgt_bisaccodes_2013 VALUES (
	'BUS017020',
	'Corporate Finance / Valuation')

--Added
INSERT INTO temp_sgt_bisaccodes_2013 VALUES (
	'BUS017030',
	'Corporate Finance / Venture Capital')

--Added
INSERT INTO temp_sgt_bisaccodes_2013 VALUES (
	'BUS111000',
	'Crowdfunding')

--Changed
INSERT INTO temp_sgt_bisaccodes_2013 VALUES (
	'BUS027000',
	'Finance / General')

--Added
INSERT INTO temp_sgt_bisaccodes_2013 VALUES (
	'BUS027010',
	'Finance / Financial Engineering')

--Added
INSERT INTO temp_sgt_bisaccodes_2013 VALUES (
	'BUS027020',
	'Finance / Financial Risk Management')

--Added
INSERT INTO temp_sgt_bisaccodes_2013 VALUES (
	'BUS027030',
	'Finance / Wealth Management')

--Added
INSERT INTO temp_sgt_bisaccodes_2013 VALUES (
	'BUS036070',
	'Investments & Securities / Analysis & Trading Strategies')

--Changed
INSERT INTO temp_sgt_bisaccodes_2013 VALUES (
	'BUS014000',
	'Investments & Securities / Commodities / General')

--Added
INSERT INTO temp_sgt_bisaccodes_2013 VALUES (
	'BUS014010',
	'Investments & Securities / Commodities / Energy')

--Added
INSERT INTO temp_sgt_bisaccodes_2013 VALUES (
	'BUS014020',
	'Investments & Securities / Commodities / Metals')

--Added
INSERT INTO temp_sgt_bisaccodes_2013 VALUES (
	'BUS036080',
	'Investments & Securities / Derivatives')

--Added
INSERT INTO temp_sgt_bisaccodes_2013 VALUES (
	'BUS036090',
	'Investments & Securities / Portfolio Management')

--Changed
INSERT INTO temp_sgt_bisaccodes_2013 VALUES (
	'BUS074000',
	'Nonprofit Organizations & Charities / General')

--Added
INSERT INTO temp_sgt_bisaccodes_2013 VALUES (
	'BUS074010',
	'Nonprofit Organizations & Charities / Finance & Accounting')

--Added
INSERT INTO temp_sgt_bisaccodes_2013 VALUES (
	'BUS074020',
	'Nonprofit Organizations & Charities / Fundraising & Grants')

--Added
INSERT INTO temp_sgt_bisaccodes_2013 VALUES (
	'BUS074030',
	'Nonprofit Organizations & Charities / Management & Leadership')

--Added
INSERT INTO temp_sgt_bisaccodes_2013 VALUES (
	'BUS074040',
	'Nonprofit Organizations & Charities / Marketing & Communications')

--Added
INSERT INTO temp_sgt_bisaccodes_2013 VALUES (
	'CGN012000',
	'Adaptations')

--Changed
INSERT INTO temp_sgt_bisaccodes_2013 VALUES (
	'CGN009000',
	'LGBT')

--Changed
INSERT INTO temp_sgt_bisaccodes_2013 VALUES (
	'CGN004130',
	'Manga / LGBT')

--Added
INSERT INTO temp_sgt_bisaccodes_2013 VALUES (
	'CKB114000',
	'Health & Healing / High Protein')

--Added
INSERT INTO temp_sgt_bisaccodes_2013 VALUES (
	'CKB115000',
	'Individual Chefs & Restaurants')

--Added
INSERT INTO temp_sgt_bisaccodes_2013 VALUES (
	'CKB116000',
	'Methods / Frying')

--Changed
INSERT INTO temp_sgt_bisaccodes_2013 VALUES (
	'CKB033000',
	'Methods / Garnishing & Food Presentation')

--Added
INSERT INTO temp_sgt_bisaccodes_2013 VALUES (
	'CKB117000',
	'Pet Food')

--Added
INSERT INTO temp_sgt_bisaccodes_2013 VALUES (
	'CRA058000',
	'Ribbon Work')

--Added
INSERT INTO temp_sgt_bisaccodes_2013 VALUES (
	'CRA059000',
	'Wirework') 

--Changed
INSERT INTO temp_sgt_bisaccodes_2013 VALUES (
	'DRA017000',
	'LGBT') 

--Changed
INSERT INTO temp_sgt_bisaccodes_2013 VALUES (
	'FAM007000',
	'Anger (see also SELF-HELP / Self-Management / Anger Management)') 

--Added
INSERT INTO temp_sgt_bisaccodes_2013 VALUES (
	'FAM050000',
	'Babysitting, Day Care & Child Care')

--Added
INSERT INTO temp_sgt_bisaccodes_2013 VALUES (
	'FAM051000',
	'Dating') 

--Added
INSERT INTO temp_sgt_bisaccodes_2013 VALUES (
	'FAM052000',
	'Dysfunctional Families')

--Added
INSERT INTO temp_sgt_bisaccodes_2013 VALUES (
	'FAM053000',
	'Extended Family')

--Changed
INSERT INTO temp_sgt_bisaccodes_2013 VALUES (
	'FAM005000',
	'Life Stages / Later Years')

--Added
INSERT INTO temp_sgt_bisaccodes_2013 VALUES (
	'FAM054000',
	'Life Stages / Mid-Life')

--Changed
INSERT INTO temp_sgt_bisaccodes_2013 VALUES (
	'FAM030000',
	'Marriage & Long Term Relationships')

--Added
INSERT INTO temp_sgt_bisaccodes_2013 VALUES (
	'FAM055000',
	'Military Families')

--Added
INSERT INTO temp_sgt_bisaccodes_2013 VALUES (
	'FIC060000',
	'Black Humor')

--Added
INSERT INTO temp_sgt_bisaccodes_2013 VALUES (
	'FIC061000',
	'Magical Realism')

--Added
INSERT INTO temp_sgt_bisaccodes_2013 VALUES (
	'FIC062000',
	'Noir')

--Added
INSERT INTO temp_sgt_bisaccodes_2013 VALUES (
	'FIC027190',
	'Romance / Gay')

--Added
INSERT INTO temp_sgt_bisaccodes_2013 VALUES (
	'FIC027200',
	'Romance / Historical / 20th Century')  

--Added
INSERT INTO temp_sgt_bisaccodes_2013 VALUES (
	'FIC027210',
	'Romance / Lesbian')  

--Added
INSERT INTO temp_sgt_bisaccodes_2013 VALUES (
	'FIC027220',
	'Romance / Military')

--Added
INSERT INTO temp_sgt_bisaccodes_2013 VALUES (
	'FIC027230',
	'Romance / Multicultural & Interracial') 

--Added
INSERT INTO temp_sgt_bisaccodes_2013 VALUES (
	'FIC027240',
	'Romance / New Adult') 

--Added
INSERT INTO temp_sgt_bisaccodes_2013 VALUES (
	'FIC027250',
	'Romance / Romantic Comedy') 

--Added
INSERT INTO temp_sgt_bisaccodes_2013 VALUES (
	'FIC028090',
	'Science Fiction / Alien Contact') 

--Added
INSERT INTO temp_sgt_bisaccodes_2013 VALUES (
	'FIC028100',
	'Science Fiction / Cyberpunk') 

--Added
INSERT INTO temp_sgt_bisaccodes_2013 VALUES (
	'FIC028110',
	'Science Fiction / Genetic Engineering') 

--Added
INSERT INTO temp_sgt_bisaccodes_2013 VALUES (
	'FIC063000',
	'Superheroes') 

--Added
INSERT INTO temp_sgt_bisaccodes_2013 VALUES (
	'FIC031070',
	'Thrillers / Supernatural') 

--Changed
INSERT INTO temp_sgt_bisaccodes_2013 VALUES (
	'GAM004000',
	'Gambling / General (see also SELF-HELP / Compulsive Behavior / Gambling)') 

--Added
INSERT INTO temp_sgt_bisaccodes_2013 VALUES (
	'HEA039160',
	'Diseases / Endocrine System')

--Changed
INSERT INTO temp_sgt_bisaccodes_2013 VALUES (
	'HEA039090',
	'Diseases / Immune & Autoimmune')

--Changed
INSERT INTO temp_sgt_bisaccodes_2013 VALUES (
	'HOM019000',
	'Cleaning, Caretaking & Organizing')

--Added
INSERT INTO temp_sgt_bisaccodes_2013 VALUES (
	'HUM018000',
	'Form / Puns & Word Play')

--Added
INSERT INTO temp_sgt_bisaccodes_2013 VALUES (
	'HUM019000',
	'Topic / Language') 

--Changed
INSERT INTO temp_sgt_bisaccodes_2013 VALUES (
	'JUV060000',
	'LGBT') 

--Added
INSERT INTO temp_sgt_bisaccodes_2013 VALUES (
	'JUV063000',
	'Recycling & Green Living') 

--Added
INSERT INTO temp_sgt_bisaccodes_2013 VALUES (
	'JUV064000',
	'Time Travel') 

--Changed
INSERT INTO temp_sgt_bisaccodes_2013 VALUES (
	'JUV040000',
	'Toys, Dolls & Puppets') 

--Changed
INSERT INTO temp_sgt_bisaccodes_2013 VALUES (
	'JNF013060',
	'Concepts / Senses & Sensation') 

--Added
INSERT INTO temp_sgt_bisaccodes_2013 VALUES (
	'JNF029060',
	'Language Arts / Journal Writing') 

--Added
INSERT INTO temp_sgt_bisaccodes_2013 VALUES (
	'JNF065000',
	'Recycling & Green Living') 

--Added
INSERT INTO temp_sgt_bisaccodes_2013 VALUES (
	'LAN029000',
	'Lexicography') 

--Changed
INSERT INTO temp_sgt_bisaccodes_2013 VALUES (
	'LCO016000',
	'LGBT') 

--Added
INSERT INTO temp_sgt_bisaccodes_2013 VALUES (
	'LIT022000',
	'Fairy Tales, Folk Tales, Legends & Mythology')

--Changed
INSERT INTO temp_sgt_bisaccodes_2013 VALUES (
	'LIT004160',
	'LGBT')

--Added
INSERT INTO temp_sgt_bisaccodes_2013 VALUES (
	'MED085080',
	'Surgery / Laparoscopic & Robotic')

--Changed
INSERT INTO temp_sgt_bisaccodes_2013 VALUES (
	'PER003050',
	'Dance / Choreography & Dance Notation')

--Added
INSERT INTO temp_sgt_bisaccodes_2013 VALUES (
	'PET012000',
	'Food & Nutrition') 

--Changed
INSERT INTO temp_sgt_bisaccodes_2013 VALUES (
	'POE021000',
	'LGBT') 

--Changed
INSERT INTO temp_sgt_bisaccodes_2013 VALUES (
	'POE023010',
	'Subjects & Themes / Death, Grief, Loss') 

--Added
INSERT INTO temp_sgt_bisaccodes_2013 VALUES (
	'POE023050',
	'Subjects & Themes / Family') 

--Added
INSERT INTO temp_sgt_bisaccodes_2013 VALUES (
	'PSY051000',
	'Cognitive Neuroscience & Cognitive Neuropsychology') 

--Changed
INSERT INTO temp_sgt_bisaccodes_2013 VALUES (
	'PSY008000',
	'Cognitive Psychology & Cognition') 

--Added
INSERT INTO temp_sgt_bisaccodes_2013 VALUES (
	'PSY052000',
	'Grief & Loss') 

--Added
INSERT INTO temp_sgt_bisaccodes_2013 VALUES (
	'PSY045070',
	'Movements / Cognitive Behavioral Therapy (CBT)') 

--Changed
INSERT INTO temp_sgt_bisaccodes_2013 VALUES (
	'PSY045020',
	'Movements / Humanistic')

--Added
INSERT INTO temp_sgt_bisaccodes_2013 VALUES (
	'PSY022080',
	'Psychopathology / Personality Disorders')

--Added
INSERT INTO temp_sgt_bisaccodes_2013 VALUES (
	'REF031000',
	'Survival & Emergency Preparedness')

--Changed
INSERT INTO temp_sgt_bisaccodes_2013 VALUES (
	'REL025000',
	'Ecumenism & Interfaith')

--Added
INSERT INTO temp_sgt_bisaccodes_2013 VALUES (
	'SEL040000',
	'Communication & Social Skills')

--Added
INSERT INTO temp_sgt_bisaccodes_2013 VALUES (
	'SEL041000',
	'Compulsive Behavior / General')

--Added
INSERT INTO temp_sgt_bisaccodes_2013 VALUES (
	'SEL041010',
	'Compulsive Behavior / Gambling')  

--Added
INSERT INTO temp_sgt_bisaccodes_2013 VALUES (
	'SEL041020',
	'Compulsive Behavior / Hoarding') 

--Added
INSERT INTO temp_sgt_bisaccodes_2013 VALUES (
	'SEL041030',
	'Compulsive Behavior / Obsessive Compulsive Disorder (OCD)') 

--Added
INSERT INTO temp_sgt_bisaccodes_2013 VALUES (
	'SEL041040',
	'Compulsive Behavior / Sex & Pornography Addiction')

--Changed
INSERT INTO temp_sgt_bisaccodes_2013 VALUES (
	'SEL014000',
	'Eating Disorders & Body Image')

--Added
INSERT INTO temp_sgt_bisaccodes_2013 VALUES (
	'SEL042000',
	'Emotions') 

--Changed
INSERT INTO temp_sgt_bisaccodes_2013 VALUES (
	'SEL020000',
	'Mood Disorders / General') 

--Added
INSERT INTO temp_sgt_bisaccodes_2013 VALUES (
	'SEL020010',
	'Mood Disorders / Bipolar Disorder') 

--Changed
INSERT INTO temp_sgt_bisaccodes_2013 VALUES (
	'SEL011000',
	'Mood Disorders / Depression') 

--Added
INSERT INTO temp_sgt_bisaccodes_2013 VALUES (
	'SEL043000',
	'Post-Traumatic Stress Disorder (PTSD)') 

--Added
INSERT INTO temp_sgt_bisaccodes_2013 VALUES (
	'SEL044000',
	'Self-Management / General') 

--Changed
INSERT INTO temp_sgt_bisaccodes_2013 VALUES (
	'SEL033000',
	'Self-Management / Anger Management (see also FAMILY & RELATIONSHIPS / Anger)') 

--Changed
INSERT INTO temp_sgt_bisaccodes_2013 VALUES (
	'SEL024000',
	'Self-Management / Stress Management') 

--Changed
INSERT INTO temp_sgt_bisaccodes_2013 VALUES (
	'SEL035000',
	'Self-Management / Time Management') 

--Changed
INSERT INTO temp_sgt_bisaccodes_2013 VALUES (
	'SEL006000',
	'Substance Abuse & Addictions / Alcohol') 

--Changed
INSERT INTO temp_sgt_bisaccodes_2013 VALUES (
	'SEL013000',
	'Substance Abuse & Addictions / Drugs') 

--Added
INSERT INTO temp_sgt_bisaccodes_2013 VALUES (
	'SPO074000',
	'Caving') 

--Added
INSERT INTO temp_sgt_bisaccodes_2013 VALUES (
	'SPO075000',
	'Health & Safety') 

--Added
INSERT INTO temp_sgt_bisaccodes_2013 VALUES (
	'TEC003110',
	'Agriculture / Enology & Viticulture') 

--Changed
INSERT INTO temp_sgt_bisaccodes_2013 VALUES (
	'TRV026030',
	'Special Interest / Disabilities & Special Needs') 

--Changed
INSERT INTO temp_sgt_bisaccodes_2013 VALUES (
	'TRV026070',
	'Special Interest / LGBT') 

go