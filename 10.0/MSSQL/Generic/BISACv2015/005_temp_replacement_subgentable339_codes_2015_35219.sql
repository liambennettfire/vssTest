IF EXISTS (SELECT * FROM dbo.sysobjects WHERE id = Object_id('temp_replacement_codes_2015') AND type = 'U')
  BEGIN
    DROP table temp_replacement_codes_2015
  END
go

CREATE TABLE temp_replacement_codes_2015 (
	Code char(255),
	literalwheninactivated char(255),
	lvcwa float,
	replacementcode char(255))
go

INSERT [dbo].[temp_replacement_codes_2015] ([Code], [literalwheninactivated], [lvcwa], [replacementcode]) VALUES (N'JNF018050 ', N'JUVENILE NONFICTION / People & Places / United States / Other ', 2014, N'JNF038100 ')
INSERT [dbo].[temp_replacement_codes_2015] ([Code], [literalwheninactivated], [lvcwa], [replacementcode]) VALUES (N'JNF025220 ', N'JUVENILE NONFICTION / History / Other ', 2014, N'JNF025000 ')
--INSERT [dbo].[temp_replacement_codes_2015] ([Code], [literalwheninactivated], [lvcwa], [replacementcode]) VALUES (N'JNF035010 ', N'JUVENILE NONFICTION / Mathematics / Advanced ', 2014, N'appropriate code beginning with YAN034 ')
INSERT [dbo].[temp_replacement_codes_2015] ([Code], [literalwheninactivated], [lvcwa], [replacementcode]) VALUES (N'JNF038110 ', N'JUVENILE NONFICTION / People & Places / Other ', 2014, N'JNF038000 ')
INSERT [dbo].[temp_replacement_codes_2015] ([Code], [literalwheninactivated], [lvcwa], [replacementcode]) VALUES (N'JNF053130 ', N'JUVENILE NONFICTION / Social Issues / Pregnancy ', 2014, N'YAN051170 ')
INSERT [dbo].[temp_replacement_codes_2015] ([Code], [literalwheninactivated], [lvcwa], [replacementcode]) VALUES (N'JNF053150 ', N'JUVENILE NONFICTION / Social Issues / Runaways ', 2014, N'YAN051190 ')
INSERT [dbo].[temp_replacement_codes_2015] ([Code], [literalwheninactivated], [lvcwa], [replacementcode]) VALUES (N'JNF053250 ', N'JUVENILE NONFICTION / Social Issues / Self-Mutilation ', 2014, N'YAN051210 ')
INSERT [dbo].[temp_replacement_codes_2015] ([Code], [literalwheninactivated], [lvcwa], [replacementcode]) VALUES (N'JUV004030 ', N'JUVENILE FICTION / Biographical / Other ', 2014, N'JUV004000 ')
INSERT [dbo].[temp_replacement_codes_2015] ([Code], [literalwheninactivated], [lvcwa], [replacementcode]) VALUES (N'JUV011050 ', N'JUVENILE FICTION / People & Places / United States / Other ', 2014, N'JUV030060 ')
INSERT [dbo].[temp_replacement_codes_2015] ([Code], [literalwheninactivated], [lvcwa], [replacementcode]) VALUES (N'JUV016130 ', N'JUVENILE FICTION / Historical / Other ', 2014, N'JUV016000 ')
INSERT [dbo].[temp_replacement_codes_2015] ([Code], [literalwheninactivated], [lvcwa], [replacementcode]) VALUES (N'JUV022040 ', N'JUVENILE FICTION / Legends, Myths, Fables / Other ', 2014, N'JUV022000 ')
INSERT [dbo].[temp_replacement_codes_2015] ([Code], [literalwheninactivated], [lvcwa], [replacementcode]) VALUES (N'JUV030070 ', N'JUVENILE FICTION / People & Places / Other ', 2014, N'JUV030000 ')
INSERT [dbo].[temp_replacement_codes_2015] ([Code], [literalwheninactivated], [lvcwa], [replacementcode]) VALUES (N'JUV033030 ', N'JUVENILE FICTION / Religious / Other ', 2014, N'JUV033000 ')
INSERT [dbo].[temp_replacement_codes_2015] ([Code], [literalwheninactivated], [lvcwa], [replacementcode]) VALUES (N'JUV039080 ', N'JUVENILE FICTION / Social Issues / Homosexuality ', 2014, N'JUV060000 ')
INSERT [dbo].[temp_replacement_codes_2015] ([Code], [literalwheninactivated], [lvcwa], [replacementcode]) VALUES (N'JUV039110 ', N'JUVENILE FICTION / Social Issues / Pregnancy ', 2014, N'YAF058180 ')
INSERT [dbo].[temp_replacement_codes_2015] ([Code], [literalwheninactivated], [lvcwa], [replacementcode]) VALUES (N'JUV039260 ', N'JUVENILE FICTION / Social Issues / Self-Mutilation ', 2014, N'YAF058230 ')
INSERT [dbo].[temp_replacement_codes_2015] ([Code], [literalwheninactivated], [lvcwa], [replacementcode]) VALUES (N'JUV065000 ', N'JUVENILE FICTION / Light Novel (Ranobe) ', 2014, N'YAF035000 ')
INSERT [dbo].[temp_replacement_codes_2015] ([Code], [literalwheninactivated], [lvcwa], [replacementcode]) VALUES (N'MED058130 ', N'MEDICAL / Nursing / Mental Health ', 2014, N'MED058180 ')

go


