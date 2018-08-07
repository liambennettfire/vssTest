if exists (select * from sysobjects where id = object_id(N'[dbo].[rtf2html_sp]') and OBJECTPROPERTY(id, N'IsProcedure') = 1)
drop procedure [dbo].[rtf2html_sp]
GO

SET QUOTED_IDENTIFIER  OFF    SET ANSI_NULLS  ON 
GO

/****** Object:  Stored Procedure dbo.rtf2html_sp    Script Date: 4/23/2002 9:52:04 AM ******/

create proc dbo.rtf2html_sp as
/** This procedure will convert the text in rtf2htmltext temporary table 
from rtf to html. It is assumed that the temp table has been preloaded
with the rtf text and that the calling procedure will retrieve the 
converted html as needed fro the temp table
**/


/** BCP the temp table to a file - YOU MUST USE -c -CACP to translate to Windows 1250 code page to prevent loss
of extended character such as bullets, etc.  -c alone strips some extended characters (7bit vs 8 bit?) **/

/**exec master..xp_cmdshell 'bcp PSS5..rtf2htmltext out c:\program files\logictran\rtf2htmltext.rtf -Uqsidba -Pqsidba -c -CACP'**/
exec master..xp_cmdshell 'bcp PSS5..rtf2htmltext out c:\logictran\rtf2htmltext.rtf -Uqsidba -Pqsidba -c -CACP'


/** CONVERT TO HTML AND IMPORT **/
/** Call the Logictran rtf converter via a command line. Send the two parameters NoFont = true and OnlyBody= True
to prevent the converter from creating all of the page formatting headers and font information, so that what you get is 
a raw html file which can be imbedded in xml, or other web site uses without the baggage of creating a standalone html page
This command creates the HTML file with the same name as the input file, with the html extension. HTML files, log files and
error files are created in the same directory as the input file **/


/**exec master..xp_cmdshell '"c:\program files\logictran\r2netcmd.exe" -DNoFont=1 -DOnlyBody=1 -DPauseOnError=0 c:\rtf2htmltext.rtf'**/
exec master..xp_cmdshell '"c:\logictran\r2netcmd.exe" -DNoFont=1 -DOnlyBody=1 -DMaintenanceNoNag=1  -DPauseOnError=0 c:\logictran\rtf2htmltext.rtf'

/** Append an arbitraty Row Terminator (i.e. || - double pipe) so that the bcp works correctly.
This must match the -t param in the inbound bcp **/

/*exec master..xp_cmdshell 'type "c:\program files\logictran\rtf2htmlterm.txt" >>c:\rtf2htmltext.html'*/
exec master..xp_cmdshell 'type "c:\logictran\rtf2htmlterm.txt" >>c:\logictran\rtf2htmltext.html'


/** Empty out the temp table inbound **/
truncate table rtf2htmltext

/* Load the HTML file back into the temp table */ 

/**exec master..xp_cmdshell 'bcp UOC..rtf2htmltext in c:\program files\logictran\rtf2htmltext.html  -Uqsidba -Pqsidba -c'**/
exec master..xp_cmdshell 'bcp UOC..rtf2htmltext in c:\logictran\rtf2htmltext.html  -Uqsidba -Pqsidba -c'

/* delete the temp rtf and  html file to protect from an invalid row being inserted  on the next comment to be converted if it fails */

/**exec master..xp_cmdshell '"del c:\program files\logictran\rtf2htmltext.rtf"'
exec master..xp_cmdshell '"del c:\program files\logictran\rtf2htmltext.html"'**/

exec master..xp_cmdshell '"del c:\logictran\rtf2htmltext.rtf"'
exec master..xp_cmdshell '"del c:\logictran\rtf2htmltext.html"'


GO
