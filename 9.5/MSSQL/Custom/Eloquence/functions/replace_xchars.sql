DROP FUNCTION replace_xchars
go
CREATE FUNCTION replace_xchars
    ( @i_string as varchar(2000) ) 

RETURNS varchar(2000)

BEGIN 
   DECLARE @o_string varchar(2000)

   select @o_string = @i_string


--the following select staments use <COLLATE Latin1_General_CS_AS> to force case sensitivity in the replace funtion

--handles convertion to 'A'
   select @o_string = replace(@o_string COLLATE Latin1_General_CS_AS ,char(192) COLLATE Latin1_General_CS_AS ,'A' COLLATE Latin1_General_CS_AS)
   select @o_string = replace(@o_string COLLATE Latin1_General_CS_AS,char(193) COLLATE Latin1_General_CS_AS,'A' COLLATE Latin1_General_CS_AS)
   select @o_string = replace(@o_string COLLATE Latin1_General_CS_AS,char(194) COLLATE Latin1_General_CS_AS,'A' COLLATE Latin1_General_CS_AS)
   select @o_string = replace(@o_string COLLATE Latin1_General_CS_AS,char(195) COLLATE Latin1_General_CS_AS,'A' COLLATE Latin1_General_CS_AS)
   select @o_string = replace(@o_string COLLATE Latin1_General_CS_AS,char(196) COLLATE Latin1_General_CS_AS,'A' COLLATE Latin1_General_CS_AS)
   select @o_string = replace(@o_string COLLATE Latin1_General_CS_AS,char(197) COLLATE Latin1_General_CS_AS,'A' COLLATE Latin1_General_CS_AS)
   select @o_string = replace(@o_string COLLATE Latin1_General_CS_AS,char(198) COLLATE Latin1_General_CS_AS,'Ae' COLLATE Latin1_General_CS_AS)

--handles convertion to 'E'
   select @o_string = replace(@o_string COLLATE Latin1_General_CS_AS,char(200) COLLATE Latin1_General_CS_AS,'E' COLLATE Latin1_General_CS_AS)
   select @o_string = replace(@o_string COLLATE Latin1_General_CS_AS,char(201) COLLATE Latin1_General_CS_AS,'E' COLLATE Latin1_General_CS_AS)
   select @o_string = replace(@o_string COLLATE Latin1_General_CS_AS,char(202) COLLATE Latin1_General_CS_AS,'E' COLLATE Latin1_General_CS_AS)
   select @o_string = replace(@o_string COLLATE Latin1_General_CS_AS,char(203) COLLATE Latin1_General_CS_AS,'E' COLLATE Latin1_General_CS_AS)

--handles convertion to 'I'
   select @o_string = replace(@o_string COLLATE Latin1_General_CS_AS,char(204) COLLATE Latin1_General_CS_AS,'I' COLLATE Latin1_General_CS_AS)
   select @o_string = replace(@o_string COLLATE Latin1_General_CS_AS,char(205) COLLATE Latin1_General_CS_AS,'I' COLLATE Latin1_General_CS_AS)
   select @o_string = replace(@o_string COLLATE Latin1_General_CS_AS,char(206) COLLATE Latin1_General_CS_AS,'I' COLLATE Latin1_General_CS_AS)
   select @o_string = replace(@o_string COLLATE Latin1_General_CS_AS,char(207) COLLATE Latin1_General_CS_AS,'I' COLLATE Latin1_General_CS_AS)

--handles convertion to 'N'
   select @o_string = replace(@o_string COLLATE Latin1_General_CS_AS,char(209) COLLATE Latin1_General_CS_AS,'N' COLLATE Latin1_General_CS_AS)

--handles convertion to 'O'
   select @o_string = replace(@o_string COLLATE Latin1_General_CS_AS,char(210) COLLATE Latin1_General_CS_AS,'O' COLLATE Latin1_General_CS_AS)
   select @o_string = replace(@o_string COLLATE Latin1_General_CS_AS,char(211) COLLATE Latin1_General_CS_AS,'O' COLLATE Latin1_General_CS_AS)
   select @o_string = replace(@o_string COLLATE Latin1_General_CS_AS,char(212) COLLATE Latin1_General_CS_AS,'O' COLLATE Latin1_General_CS_AS)
   select @o_string = replace(@o_string COLLATE Latin1_General_CS_AS,char(213) COLLATE Latin1_General_CS_AS,'O' COLLATE Latin1_General_CS_AS)
   select @o_string = replace(@o_string COLLATE Latin1_General_CS_AS,char(214) COLLATE Latin1_General_CS_AS,'O' COLLATE Latin1_General_CS_AS)

--handles convertion to 'U'
   select @o_string = replace(@o_string COLLATE Latin1_General_CS_AS,char(217) COLLATE Latin1_General_CS_AS,'U' COLLATE Latin1_General_CS_AS)
   select @o_string = replace(@o_string COLLATE Latin1_General_CS_AS,char(218) COLLATE Latin1_General_CS_AS,'U' COLLATE Latin1_General_CS_AS)
   select @o_string = replace(@o_string COLLATE Latin1_General_CS_AS,char(219) COLLATE Latin1_General_CS_AS,'U' COLLATE Latin1_General_CS_AS)
   select @o_string = replace(@o_string COLLATE Latin1_General_CS_AS,char(220) COLLATE Latin1_General_CS_AS,'U' COLLATE Latin1_General_CS_AS)
 
--handles convertion to 'Y'
   select @o_string = replace(@o_string COLLATE Latin1_General_CS_AS,char(221) COLLATE Latin1_General_CS_AS,'Y' COLLATE Latin1_General_CS_AS)

--handles convertion to 'a'
   select @o_string = replace(@o_string COLLATE Latin1_General_CS_AS,char(224) COLLATE Latin1_General_CS_AS,'a' COLLATE Latin1_General_CS_AS)
   select @o_string = replace(@o_string COLLATE Latin1_General_CS_AS,char(225) COLLATE Latin1_General_CS_AS,'a' COLLATE Latin1_General_CS_AS)
   select @o_string = replace(@o_string COLLATE Latin1_General_CS_AS,char(226) COLLATE Latin1_General_CS_AS,'a' COLLATE Latin1_General_CS_AS)
   select @o_string = replace(@o_string COLLATE Latin1_General_CS_AS,char(227) COLLATE Latin1_General_CS_AS,'a' COLLATE Latin1_General_CS_AS)
   select @o_string = replace(@o_string COLLATE Latin1_General_CS_AS,char(228) COLLATE Latin1_General_CS_AS,'a' COLLATE Latin1_General_CS_AS)
   select @o_string = replace(@o_string COLLATE Latin1_General_CS_AS,char(229) COLLATE Latin1_General_CS_AS,'a' COLLATE Latin1_General_CS_AS)
   select @o_string = replace(@o_string COLLATE Latin1_General_CS_AS,char(230) COLLATE Latin1_General_CS_AS,'a' COLLATE Latin1_General_CS_AS)

--handles convertion to 'e'
   select @o_string = replace(@o_string COLLATE Latin1_General_CS_AS,char(232) COLLATE Latin1_General_CS_AS,'e' COLLATE Latin1_General_CS_AS)
   select @o_string = replace(@o_string COLLATE Latin1_General_CS_AS,char(233) COLLATE Latin1_General_CS_AS,'e' COLLATE Latin1_General_CS_AS)
   select @o_string = replace(@o_string COLLATE Latin1_General_CS_AS,char(234) COLLATE Latin1_General_CS_AS,'e' COLLATE Latin1_General_CS_AS)
   select @o_string = replace(@o_string,char(235) COLLATE Latin1_General_CS_AS,'e')

--handles convertion to 'i'
   select @o_string = replace(@o_string COLLATE Latin1_General_CS_AS,char(236) COLLATE Latin1_General_CS_AS,'i' COLLATE Latin1_General_CS_AS)
   select @o_string = replace(@o_string COLLATE Latin1_General_CS_AS,char(237) COLLATE Latin1_General_CS_AS,'i' COLLATE Latin1_General_CS_AS)
   select @o_string = replace(@o_string COLLATE Latin1_General_CS_AS,char(238) COLLATE Latin1_General_CS_AS,'i' COLLATE Latin1_General_CS_AS)
   select @o_string = replace(@o_string COLLATE Latin1_General_CS_AS,char(239) COLLATE Latin1_General_CS_AS,'i' COLLATE Latin1_General_CS_AS)

--handles convertion to 'n'
   select @o_string = replace(@o_string COLLATE Latin1_General_CS_AS,char(241) COLLATE Latin1_General_CS_AS,'n' COLLATE Latin1_General_CS_AS)

--handles convertion to 'o'
   select @o_string = replace(@o_string COLLATE Latin1_General_CS_AS,char(242) COLLATE Latin1_General_CS_AS,'o' COLLATE Latin1_General_CS_AS)
   select @o_string = replace(@o_string COLLATE Latin1_General_CS_AS,char(243) COLLATE Latin1_General_CS_AS,'o' COLLATE Latin1_General_CS_AS)
   select @o_string = replace(@o_string COLLATE Latin1_General_CS_AS,char(244) COLLATE Latin1_General_CS_AS,'o' COLLATE Latin1_General_CS_AS)
   select @o_string = replace(@o_string COLLATE Latin1_General_CS_AS,char(245) COLLATE Latin1_General_CS_AS,'o' COLLATE Latin1_General_CS_AS)
   select @o_string = replace(@o_string COLLATE Latin1_General_CS_AS,char(245) COLLATE Latin1_General_CS_AS,'o' COLLATE Latin1_General_CS_AS)

--handles convertion to 'u'
   select @o_string = replace(@o_string COLLATE Latin1_General_CS_AS,char(249) COLLATE Latin1_General_CS_AS,'u' COLLATE Latin1_General_CS_AS)
   select @o_string = replace(@o_string COLLATE Latin1_General_CS_AS,char(250) COLLATE Latin1_General_CS_AS,'u' COLLATE Latin1_General_CS_AS)
   select @o_string = replace(@o_string COLLATE Latin1_General_CS_AS,char(251) COLLATE Latin1_General_CS_AS,'u' COLLATE Latin1_General_CS_AS)
   select @o_string = replace(@o_string COLLATE Latin1_General_CS_AS,char(252) COLLATE Latin1_General_CS_AS,'u' COLLATE Latin1_General_CS_AS)

--handles convertion to 'y'
   select @o_string = replace(@o_string COLLATE Latin1_General_CS_AS,char(253) COLLATE Latin1_General_CS_AS,'y' COLLATE Latin1_General_CS_AS)
   select @o_string = replace(@o_string COLLATE Latin1_General_CS_AS,char(255) COLLATE Latin1_General_CS_AS,'y' COLLATE Latin1_General_CS_AS)

--handles convertion to special (blank)
  select @o_string = replace(@o_string COLLATE Latin1_General_CS_AS,char(147) COLLATE Latin1_General_CS_AS,'"' COLLATE Latin1_General_CS_AS)
  select @o_string = replace(@o_string COLLATE Latin1_General_CS_AS,char(148) COLLATE Latin1_General_CS_AS,'"' COLLATE Latin1_General_CS_AS)
  select @o_string = replace(@o_string COLLATE Latin1_General_CS_AS,char(153) COLLATE Latin1_General_CS_AS,'' COLLATE Latin1_General_CS_AS)
  select @o_string = replace(@o_string COLLATE Latin1_General_CS_AS,char(161) COLLATE Latin1_General_CS_AS,'' COLLATE Latin1_General_CS_AS)
  select @o_string = replace(@o_string COLLATE Latin1_General_CS_AS,char(174) COLLATE Latin1_General_CS_AS,'' COLLATE Latin1_General_CS_AS)
  select @o_string = replace(@o_string COLLATE Latin1_General_CS_AS,char(191) COLLATE Latin1_General_CS_AS,'' COLLATE Latin1_General_CS_AS)


  RETURN @o_string
END

