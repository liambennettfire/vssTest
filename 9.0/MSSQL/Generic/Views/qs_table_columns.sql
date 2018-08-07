/**************************************************/
/*                                                */
/*  Rod Hamann                                    */
/*  10-22-2003                                    */
/*  PSS5 SIR 2439                                 */
/*  Tested on: GENMSDEV, GENMS2DEV                */
/*                                                */
/*                  MSSQL VERSION                 */
/*                                                */
/*  Provide generic import capabilities for PUBL. */
/*                                                */
/**************************************************/

CREATE VIEW qs_table_columns
   (table_name, column_name, col_type, col_lenghth, col_prec, isnullable, colid)
   AS
   SELECT so.name, sc.name, st.name, sc.length, sc.xprec, sc.isnullable, sc.colid
      FROM sysobjects so, syscolumns sc, systypes st
      WHERE so.xtype='U'
        AND so.id=sc.id
        AND sc.xtype=st.xtype
GO

GRANT ALL ON qs_table_columns TO PUBLIC

GO