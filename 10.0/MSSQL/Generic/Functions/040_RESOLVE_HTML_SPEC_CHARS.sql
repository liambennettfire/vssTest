drop FUNCTION DBO.RESOLVE_HTML_SPEC_CHARS
go

CREATE FUNCTION DBO.RESOLVE_HTML_SPEC_CHARS
  (@i_clob_part varchar(8000))
   RETURNS varchar(8000)

BEGIN

  declare @v_cleantext varchar(8000)
  declare @v_ref_loc int
  declare @v_refprefix char(2)
  declare @v_reference varchar(20)
  declare @v_resolved varchar(20)
  declare @v_resvalue int
  declare @v_offset int
  declare @v_tagend int
  declare @v_bad_tag int 
  declare @v_cnt int 

  set @v_cnt = 1
  set @v_refprefix = '&#'
  set @v_cleantext = @i_clob_part
  set @v_offset = charindex(@v_refprefix, @v_cleantext,1)
  set @v_bad_tag = 0

  WHILE @v_offset>0 and @v_bad_tag = 0 
    begin  

     --prevent infinity loop if there are invalid special characters
     set @v_cnt = @v_cnt + 1
	if @v_cnt > 1000
	begin
		break
	end

      set @v_reference = substring(@v_cleantext,@v_offset,20)
      set @v_tagend = charindex(';',@v_reference,1)
      if @v_tagend > 0 
        begin
          set @v_reference = substring(@v_reference,1,@v_tagend)
          set @v_resolved = substring(@v_reference,3,len(@v_reference)-3)
          
          --mk2012.11.15> Case 21784 ... convert hex to decimal
          IF UPPER(LEFT(@v_resolved,1))='X' set @v_resolved = convert(int, convert(varbinary, '0'+@v_resolved, 1))
                    
          set @v_resvalue = cast(@v_resolved as int)
          set @v_resolved = nchar(@v_resolved)
          set @v_cleantext = replace(@v_cleantext,@v_reference,@v_resolved)
        end
      else
        begin
          set @v_bad_tag = 0
        end
      set @v_offset = charindex(@v_refprefix,@v_cleantext,@v_offset)
    END
  

  set @v_cleantext = replace(@v_cleantext,'&nbsp;',' ') 
  set @v_cleantext = replace(@v_cleantext,'&gt;','>') 
  set @v_cleantext = replace(@v_cleantext,'&lt;','<') 
  set @v_cleantext = replace(@v_cleantext,'&amp;','&') 
  set @v_cleantext = replace(@v_cleantext,'&quot;','"') 
   set @v_cleantext = replace(@v_cleantext,'\u0022','"') 


  set @v_cleantext = replace(@v_cleantext collate Latin1_General_CS_AS,'&iexcl;','\u00a1')
  set @v_cleantext = replace(@v_cleantext collate Latin1_General_CS_AS,'&cent;','\u00a2')
  set @v_cleantext = replace(@v_cleantext collate Latin1_General_CS_AS,'&pound;','\u00a3')
  set @v_cleantext = replace(@v_cleantext collate Latin1_General_CS_AS,'&curren;','\u00a4')
  set @v_cleantext = replace(@v_cleantext collate Latin1_General_CS_AS,'&yen;','\u00a5')
  set @v_cleantext = replace(@v_cleantext collate Latin1_General_CS_AS,'&brvbar;','\u00a6')
  set @v_cleantext = replace(@v_cleantext collate Latin1_General_CS_AS,'&sect;','\u00a7')
  set @v_cleantext = replace(@v_cleantext collate Latin1_General_CS_AS,'&uml;','\u00a8')
  set @v_cleantext = replace(@v_cleantext collate Latin1_General_CS_AS,'&copy;','\u00a9')
  set @v_cleantext = replace(@v_cleantext collate Latin1_General_CS_AS,'&ordf;','\u00aa')
  set @v_cleantext = replace(@v_cleantext collate Latin1_General_CS_AS,'&laquo;','')
  set @v_cleantext = replace(@v_cleantext collate Latin1_General_CS_AS,'&not;','\u00ab')
  set @v_cleantext = replace(@v_cleantext collate Latin1_General_CS_AS,'&reg;','\u00ae')
  set @v_cleantext = replace(@v_cleantext collate Latin1_General_CS_AS,'&macr;','\u00af')
  set @v_cleantext = replace(@v_cleantext collate Latin1_General_CS_AS,'&deg;','\u00b0')
  set @v_cleantext = replace(@v_cleantext collate Latin1_General_CS_AS,'&plusmn;','\u00b1')
  set @v_cleantext = replace(@v_cleantext collate Latin1_General_CS_AS,'&sup2;','\u00b2')
  set @v_cleantext = replace(@v_cleantext collate Latin1_General_CS_AS,'&sup3;','\u00b3')
  set @v_cleantext = replace(@v_cleantext collate Latin1_General_CS_AS,'&acute;','\u00b4')
  set @v_cleantext = replace(@v_cleantext collate Latin1_General_CS_AS,'&micro;','\u00b5')
  set @v_cleantext = replace(@v_cleantext collate Latin1_General_CS_AS,'&para;','\u00b6')
  set @v_cleantext = replace(@v_cleantext collate Latin1_General_CS_AS,'&middot;','\u00b7')
  set @v_cleantext = replace(@v_cleantext collate Latin1_General_CS_AS,'&cedil;','\u00b8')
  set @v_cleantext = replace(@v_cleantext collate Latin1_General_CS_AS,'&sup1;','\u00b9')
  set @v_cleantext = replace(@v_cleantext collate Latin1_General_CS_AS,'&ordm;','\u00ba')
  set @v_cleantext = replace(@v_cleantext collate Latin1_General_CS_AS,'&raquo;','\u00bb')
  set @v_cleantext = replace(@v_cleantext collate Latin1_General_CS_AS,'&frac14;','\u00bc')
  set @v_cleantext = replace(@v_cleantext collate Latin1_General_CS_AS,'&frac12;','\u00bd')
  set @v_cleantext = replace(@v_cleantext collate Latin1_General_CS_AS,'&frac34;','\u00be')
  set @v_cleantext = replace(@v_cleantext collate Latin1_General_CS_AS,'&iquest;','\u00bf')
  set @v_cleantext = replace(@v_cleantext collate Latin1_General_CS_AS,'&Agrave;','\u00c0')
  set @v_cleantext = replace(@v_cleantext collate Latin1_General_CS_AS,'&Aacute;','\u00c1')
  set @v_cleantext = replace(@v_cleantext collate Latin1_General_CS_AS,'&circ;','\u00c2')
  set @v_cleantext = replace(@v_cleantext collate Latin1_General_CS_AS,'&Atilde;','\u00c3')
  set @v_cleantext = replace(@v_cleantext collate Latin1_General_CS_AS,'&Auml;','\u00c4')
  set @v_cleantext = replace(@v_cleantext collate Latin1_General_CS_AS,'&ring;','\u00c5')
  set @v_cleantext = replace(@v_cleantext collate Latin1_General_CS_AS,'&AElig;','\u00c6')
  set @v_cleantext = replace(@v_cleantext collate Latin1_General_CS_AS,'&Ccedil;','\u00c7')
  set @v_cleantext = replace(@v_cleantext collate Latin1_General_CS_AS,'&Egrave;','\u00c8')
  set @v_cleantext = replace(@v_cleantext collate Latin1_General_CS_AS,'&Eacute;','\u00c9')
  set @v_cleantext = replace(@v_cleantext collate Latin1_General_CS_AS,'&Ecirc;','\u00ca')
  set @v_cleantext = replace(@v_cleantext collate Latin1_General_CS_AS,'&Euml;','\u00cb')
  set @v_cleantext = replace(@v_cleantext collate Latin1_General_CS_AS,'&Igrave;','\u00cc')
  set @v_cleantext = replace(@v_cleantext collate Latin1_General_CS_AS,'&Iacute;','\u00cd')
  set @v_cleantext = replace(@v_cleantext collate Latin1_General_CS_AS,'&Icirc;','\u00ce')
  set @v_cleantext = replace(@v_cleantext collate Latin1_General_CS_AS,'&Iuml;','\u00cf')
  set @v_cleantext = replace(@v_cleantext collate Latin1_General_CS_AS,'&ETH;','\u00d0')
  set @v_cleantext = replace(@v_cleantext collate Latin1_General_CS_AS,'&Ntilde;','\u00d1')
  set @v_cleantext = replace(@v_cleantext collate Latin1_General_CS_AS,'&Ograve;','\u00d2')
  set @v_cleantext = replace(@v_cleantext collate Latin1_General_CS_AS,'&Oacute;','\u00d3')
  set @v_cleantext = replace(@v_cleantext collate Latin1_General_CS_AS,'&Ocirc;','\u00d4')
  set @v_cleantext = replace(@v_cleantext collate Latin1_General_CS_AS,'&Otilde;','\u00d4')
  set @v_cleantext = replace(@v_cleantext collate Latin1_General_CS_AS,'&Ouml;','\u00d6')
  set @v_cleantext = replace(@v_cleantext collate Latin1_General_CS_AS,'&times;','\u00d7')
  set @v_cleantext = replace(@v_cleantext collate Latin1_General_CS_AS,'&Oslash;','\u00d8')
  set @v_cleantext = replace(@v_cleantext collate Latin1_General_CS_AS,'&Ugrave;','\u00d9')
  set @v_cleantext = replace(@v_cleantext collate Latin1_General_CS_AS,'&Uacute;','\u00da')
  set @v_cleantext = replace(@v_cleantext collate Latin1_General_CS_AS,'&Ucirc;','\u00db')
  set @v_cleantext = replace(@v_cleantext collate Latin1_General_CS_AS,'&Uuml;','\u00dc')
  set @v_cleantext = replace(@v_cleantext collate Latin1_General_CS_AS,'&Yacute;','\u00dd')
  set @v_cleantext = replace(@v_cleantext collate Latin1_General_CS_AS,'&THORN;','\u00de')
  set @v_cleantext = replace(@v_cleantext collate Latin1_General_CS_AS,'&szlig;','\u00df')
  set @v_cleantext = replace(@v_cleantext collate Latin1_General_CS_AS,'&agrave;','\u00e0')
  set @v_cleantext = replace(@v_cleantext collate Latin1_General_CS_AS,'&aacute;','\u00e1')
  set @v_cleantext = replace(@v_cleantext collate Latin1_General_CS_AS,'&acirc;','\u00e2')
  set @v_cleantext = replace(@v_cleantext collate Latin1_General_CS_AS,'&atilde;','\u00e3')
  set @v_cleantext = replace(@v_cleantext collate Latin1_General_CS_AS,'&auml;','\u00e4')
  set @v_cleantext = replace(@v_cleantext collate Latin1_General_CS_AS,'&aring;','\u00e5')
  set @v_cleantext = replace(@v_cleantext collate Latin1_General_CS_AS,'&aelig;','\u00e6')
  set @v_cleantext = replace(@v_cleantext collate Latin1_General_CS_AS,'&ccedil;','\u00e7')
  set @v_cleantext = replace(@v_cleantext collate Latin1_General_CS_AS,'&egrave;','\u00e8')
  set @v_cleantext = replace(@v_cleantext collate Latin1_General_CS_AS,'&eacute;','\u00e9')
  set @v_cleantext = replace(@v_cleantext collate Latin1_General_CS_AS,'&ecirc;','\u00ea')
  set @v_cleantext = replace(@v_cleantext collate Latin1_General_CS_AS,'&euml;','\u00eb')
  set @v_cleantext = replace(@v_cleantext collate Latin1_General_CS_AS,'&igrave;','\u00ec')
  set @v_cleantext = replace(@v_cleantext collate Latin1_General_CS_AS,'&iacute;','\u00ed')
  set @v_cleantext = replace(@v_cleantext collate Latin1_General_CS_AS,'&icirc;','\u00ee')
  set @v_cleantext = replace(@v_cleantext collate Latin1_General_CS_AS,'&iuml;','\u00ef')
  set @v_cleantext = replace(@v_cleantext collate Latin1_General_CS_AS,'&ieth;','\u00f0')
  set @v_cleantext = replace(@v_cleantext collate Latin1_General_CS_AS,'&ntilde;','\u00f1')
  set @v_cleantext = replace(@v_cleantext collate Latin1_General_CS_AS,'&ograve;','\u00f2')
  set @v_cleantext = replace(@v_cleantext collate Latin1_General_CS_AS,'&oacute;','\u00f3')
  set @v_cleantext = replace(@v_cleantext collate Latin1_General_CS_AS,'&ocirc;','\u00f4')
  set @v_cleantext = replace(@v_cleantext collate Latin1_General_CS_AS,'&otilde;','\u00f5')
  set @v_cleantext = replace(@v_cleantext collate Latin1_General_CS_AS,'&ouml;','\u00f6')
  set @v_cleantext = replace(@v_cleantext collate Latin1_General_CS_AS,'&divide;','\u00f7')
  set @v_cleantext = replace(@v_cleantext collate Latin1_General_CS_AS,'&oslash;','\u00f8')
  set @v_cleantext = replace(@v_cleantext collate Latin1_General_CS_AS,'&ugrave;','\u00f9')
  set @v_cleantext = replace(@v_cleantext collate Latin1_General_CS_AS,'&uacute;','\u00fa')
  set @v_cleantext = replace(@v_cleantext collate Latin1_General_CS_AS,'&ucirc;','\u00fb')
  set @v_cleantext = replace(@v_cleantext collate Latin1_General_CS_AS,'&uuml;','\u00fc')
  set @v_cleantext = replace(@v_cleantext collate Latin1_General_CS_AS,'&yacute;','\u00fd')
  set @v_cleantext = replace(@v_cleantext collate Latin1_General_CS_AS,'&thorn;','\u00fe')
  set @v_cleantext = replace(@v_cleantext collate Latin1_General_CS_AS,'&yuml;','\u00ff')
  set @v_cleantext = replace(@v_cleantext collate Latin1_General_CS_AS,'&rsquo;','\u2019')
  set @v_cleantext = replace(@v_cleantext collate Latin1_General_CS_AS,'&lsquo;','\u2018')
  set @v_cleantext = replace(@v_cleantext collate Latin1_General_CS_AS,'&ldquo;','\u201c')
  set @v_cleantext = replace(@v_cleantext collate Latin1_General_CS_AS,'&rdquo;','\u201d') 
  ---set @v_cleantext = replace(@v_cleantext collate Latin1_General_CS_AS,'&quot;','\u0022') 
  RETURN @v_cleantext
END 
go



