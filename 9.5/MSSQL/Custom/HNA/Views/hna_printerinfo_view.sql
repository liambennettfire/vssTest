/****** Object:  View [dbo].[hna_printerinfo_view]    Script Date: 04/11/2015 10:55:26 ******/
IF  EXISTS (SELECT * FROM sys.views WHERE object_id = OBJECT_ID(N'[dbo].[hna_printerinfo_view]'))
DROP VIEW [dbo].[hna_printerinfo_view]
GO

/****** Object:  View [dbo].[hna_printerinfo_view]    Script Date: 04/11/2015 10:55:26 ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO


CREATE VIEW [dbo].[hna_printerinfo_view]
AS
SELECT     p.bookkey, 
		   p.printingkey, 
		   printercountry = CASE WHEN [dbo].[get_Tab_HNA_Printer_Country](p.bookkey) <> ' ' 
		   THEN [dbo].[get_Tab_HNA_Printer_Country](p.bookkey)
		   WHEN dbo.rpt_get_printing_taqversionspeccategory_vendorname (p.bookkey,p.printingkey,5,'C') <>''
		   THEN dbo.rpt_get_printing_taqversionspeccategory_vendorname (p.bookkey,p.printingkey,5,'C')
		   ELSE coalesce(v.country,[dbo].[rpt_get_contact_primary_country] (t.vendorkey)) 		   
           END, 
           printershortdesc= CASE WHEN dbo.rpt_get_printing_taqversionspeccategory_vendorname (p.bookkey,p.printingkey,5,'S') <>''
           THEN dbo.rpt_get_printing_taqversionspeccategory_vendorname (p.bookkey,p.printingkey,5,'S')
           ELSE coalesce(v.shortdesc,dbo.rpt_get_contact_name (t.vendorkey,'S')) 
           END
FROM       dbo.bindingspecs t 
		   LEFT OUTER JOIN dbo.vendor v ON t.vendorkey = v.vendorkey 
		   FULL OUTER JOIN dbo.printing p ON t.bookkey = p.bookkey AND t.printingkey = p.printingkey

GO

GRANT SELECT ON [dbo].[hna_printerinfo_view] to PUBLIC
GO

EXEC sys.sp_addextendedproperty @name=N'MS_DiagramPane1', @value=N'[0E232FF0-B466-11cf-A24F-00AA00A3EFFF, 1.00]
Begin DesignProperties = 
   Begin PaneConfigurations = 
      Begin PaneConfiguration = 0
         NumPanes = 4
         Configuration = "(H (1[40] 4[20] 2[20] 3) )"
      End
      Begin PaneConfiguration = 1
         NumPanes = 3
         Configuration = "(H (1 [50] 4 [25] 3))"
      End
      Begin PaneConfiguration = 2
         NumPanes = 3
         Configuration = "(H (1 [50] 2 [25] 3))"
      End
      Begin PaneConfiguration = 3
         NumPanes = 3
         Configuration = "(H (4 [30] 2 [40] 3))"
      End
      Begin PaneConfiguration = 4
         NumPanes = 2
         Configuration = "(H (1 [56] 3))"
      End
      Begin PaneConfiguration = 5
         NumPanes = 2
         Configuration = "(H (2 [66] 3))"
      End
      Begin PaneConfiguration = 6
         NumPanes = 2
         Configuration = "(H (4 [50] 3))"
      End
      Begin PaneConfiguration = 7
         NumPanes = 1
         Configuration = "(V (3))"
      End
      Begin PaneConfiguration = 8
         NumPanes = 3
         Configuration = "(H (1[56] 4[18] 2) )"
      End
      Begin PaneConfiguration = 9
         NumPanes = 2
         Configuration = "(H (1 [75] 4))"
      End
      Begin PaneConfiguration = 10
         NumPanes = 2
         Configuration = "(H (1[66] 2) )"
      End
      Begin PaneConfiguration = 11
         NumPanes = 2
         Configuration = "(H (4 [60] 2))"
      End
      Begin PaneConfiguration = 12
         NumPanes = 1
         Configuration = "(H (1) )"
      End
      Begin PaneConfiguration = 13
         NumPanes = 1
         Configuration = "(V (4))"
      End
      Begin PaneConfiguration = 14
         NumPanes = 1
         Configuration = "(V (2))"
      End
      ActivePaneConfig = 0
   End
   Begin DiagramPane = 
      Begin Origin = 
         Top = 0
         Left = 0
      End
      Begin Tables = 
         Begin Table = "v"
            Begin Extent = 
               Top = 47
               Left = 547
               Bottom = 238
               Right = 720
            End
            DisplayFlags = 280
            TopColumn = 0
         End
         Begin Table = "printing"
            Begin Extent = 
               Top = 91
               Left = 12
               Bottom = 199
               Right = 222
            End
            DisplayFlags = 280
            TopColumn = 0
         End
         Begin Table = "t"
            Begin Extent = 
               Top = 6
               Left = 260
               Bottom = 114
               Right = 428
            End
            DisplayFlags = 280
            TopColumn = 0
         End
      End
   End
   Begin SQLPane = 
   End
   Begin DataPane = 
      Begin ParameterDefaults = ""
      End
      Begin ColumnWidths = 9
         Width = 284
         Width = 1500
         Width = 1500
         Width = 1500
         Width = 1500
         Width = 1500
         Width = 1500
         Width = 1500
         Width = 1500
      End
   End
   Begin CriteriaPane = 
      Begin ColumnWidths = 11
         Column = 11805
         Alias = 900
         Table = 1170
         Output = 720
         Append = 1400
         NewValue = 1170
         SortType = 1350
         SortOrder = 1410
         GroupBy = 1350
         Filter = 1350
         Or = 1350
         Or = 1350
         Or = 1350
      End
   End
End
' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'VIEW',@level1name=N'hna_printerinfo_view'
GO

EXEC sys.sp_addextendedproperty @name=N'MS_DiagramPaneCount', @value=1 , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'VIEW',@level1name=N'hna_printerinfo_view'
GO


