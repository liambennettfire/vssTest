IF EXISTS (SELECT * FROM dbo.sysobjects WHERE id = Object_id('temp_sgt_inactives_2015') AND type = 'U')
  BEGIN
    DROP table temp_sgt_inactives_2015
  END
go

CREATE TABLE temp_sgt_inactives_2015 (
	Code char(255))
go

INSERT [dbo].[temp_sgt_inactives_2015] ([Code]) VALUES (N'JNF018050 ')
INSERT [dbo].[temp_sgt_inactives_2015] ([Code]) VALUES (N'JNF025220 ')
INSERT [dbo].[temp_sgt_inactives_2015] ([Code]) VALUES (N'JNF035010 ')
INSERT [dbo].[temp_sgt_inactives_2015] ([Code]) VALUES (N'JNF038110 ')
INSERT [dbo].[temp_sgt_inactives_2015] ([Code]) VALUES (N'JNF053130 ')
INSERT [dbo].[temp_sgt_inactives_2015] ([Code]) VALUES (N'JNF053150 ')
INSERT [dbo].[temp_sgt_inactives_2015] ([Code]) VALUES (N'JNF053250 ')
INSERT [dbo].[temp_sgt_inactives_2015] ([Code]) VALUES (N'JUV004030 ')
INSERT [dbo].[temp_sgt_inactives_2015] ([Code]) VALUES (N'JUV011050 ')
INSERT [dbo].[temp_sgt_inactives_2015] ([Code]) VALUES (N'JUV016130 ')
INSERT [dbo].[temp_sgt_inactives_2015] ([Code]) VALUES (N'JUV022040 ')
INSERT [dbo].[temp_sgt_inactives_2015] ([Code]) VALUES (N'JUV030070 ')
INSERT [dbo].[temp_sgt_inactives_2015] ([Code]) VALUES (N'JUV033030 ')
INSERT [dbo].[temp_sgt_inactives_2015] ([Code]) VALUES (N'JUV039080 ')
INSERT [dbo].[temp_sgt_inactives_2015] ([Code]) VALUES (N'JUV039110 ')
INSERT [dbo].[temp_sgt_inactives_2015] ([Code]) VALUES (N'JUV039260 ')
INSERT [dbo].[temp_sgt_inactives_2015] ([Code]) VALUES (N'JUV065000 ')
INSERT [dbo].[temp_sgt_inactives_2015] ([Code]) VALUES (N'MED058130 ')
