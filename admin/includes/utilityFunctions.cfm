<cfprocessingDirective pageencoding="utf-8">

	<cffunction name="fGetOnclickEvent" hint="returns the onclick event for the editor based on the application.config.general.richTextEditor">
		<cfset var onClickEvent = "">
		<!--- work out if onClick event needed for specified rich text editor --->
		<cfswitch expression="#application.config.general.richTextEditor#">
			<cfcase value="soEditorPro">
				<cfset onClickEvent = "soEditorbody.updateFormField();">
			</cfcase>
			<cfcase value="soEditor">
				<cfset onClickEvent = "soEditorbody.updateFormField();">
			</cfcase>
			<cfcase value="textArea">
				<cfset onClickEvent = "">
			</cfcase>
			<cfcase value="eopro">
				<cfset onClickEvent= "scriptForm_onsubmit();">
			</cfcase>
			<cfcase value="htmlarea">
				<cfset onClickEvent= "document.editform.onsubmit();document.editform.submit();">
			</cfcase>
			<cfdefaultcase>
				<cfset onClickEvent = "">
			</cfdefaultcase>
		</cfswitch>	
		<cfreturn onClickEvent>
	</cffunction>

	<cffunction name="arrayKeyToList">
		<cfargument name="array" required="true">
		<cfargument name="key" required="true">
		<cfargument name="delimiter" required="false" default=",">

		<cfscript>
			list = '';
			for(i=1;i LTE arrayLen(arguments.array);i=i+1)
			{
				if (len(list))
					list = list & arguments.delimiter;
				arrayEntry = arguments.array[i];
				list = list	& arrayEntry[arguments.key];
			}	
		</cfscript>
		<cfreturn list>
	</cffunction>
	
	<cffunction name="appendURlVar" hint="appends a url parmater to a given URL. Determines if ? or & is required">
		<cfargument name="urlstring" required="Yes" hint="URl to have param appended to">
		<cfargument name="urlvaluepair" required="Yes" hint="URL value pair to be appended to urlstring">
		<cfscript>
			completeURL = arguments.urlstring;
			if(findnocase(".cfm?",URLDecode(completeURL)))
				append = "&";
			else
				append = "?";
			completeURL = completeURL & append & arguments.urlvaluepair;	
		</cfscript>								
		<cfreturn completeURL>	
	</cffunction>
	

	<cfscript>
	function arrayReverse(inArray){
		var outArray = ArrayNew(1);
		var i=0;
			var j = 1;
		for (i=ArrayLen(inArray);i GT 0;i=i-1){
			outArray[j] = inArray[i];
			j = j + 1;
		}
		return outArray;
	}

	</cfscript>
	
	<cffunction name="getPackagePath" hint="Returns full package for a component based on its name - useful for determing whether this component is a core or custom effort ">
		<!--- Now that we're using APPLICATION.TYPES[TYPENAME].TYPEPATH this function is deprecated ~Tom --->
		<cfargument name="name" required="true">
		
		<cfscript>
			packagepath = '';
			//first search types
			for(key IN application.types)
			{
				if (key IS arguments.name)
				{
					packagePath = application.types[key].typePath;
				}	
			}
			//search rules now if not found in application.types scope
			if (not len(packagepath))
			{
				for(key IN application.rules)
				{
					if (key IS arguments.name)
					{
						packagePath = application.rules[key].rulePath;
					}	
				}
			}
			
		
		</cfscript>
		<cfreturn packagepath>
	</cffunction>

	

	<cffunction name="QueryToStructure">
		<cfargument name="query" type="query" required="true">
		<cfscript>
			stStruct = structNew();
			cols = ListtoArray(arguments.query.columnlist);
			for(index=1; index LTE arraylen(cols); index=index+1)
			{
				stStruct[cols[index]] = arguments.query[cols[index]][1];
			}
		</cfscript>
		<cfreturn stStruct>
	</cffunction>
	
	
	
	<cffunction name="QueryToArrayOfStructures" returntype="array" hint="Converts a query object to an array of structures">
		<cfargument name="theQuery" required="true">
		<cfargument name="theArray" required="false" default="#arrayNew(1)#">
		<cfset var cols = ListtoArray(theQuery.columnlist)>
		<cfset var row = 1>
		<cfset var thisRow = "">
		<cfset var col = 1>
		<cfscript>	
			for(row = 1; row LTE theQuery.recordcount; row = row + 1)
		{
			thisRow = structnew();
			for(col = 1; col LTE arraylen(cols); col = col + 1){
				thisRow[cols[col]] = theQuery[cols[col]][row];
			}
			arrayAppend(arguments.theArray,duplicate(thisRow));
		}
	
	</cfscript>
	<cfreturn arguments.theArray>
	</cffunction>
	
	<cffunction name="QueryToStructureOfStructures" returntype="struct" hint="Converts a query object to an array of structures. Assumes objectid to be key">
		<cfargument name="theQuery" required="true" hint="Assumes objectid to be key">
		<cfset var stReturn = structNew()>
		<cfset var row = 1>
		<cfset var index = 1>
		<cfscript>	
		cols = ListtoArray(arguments.thequery.columnlist);
		for(row = 1; row LTE arguments.theQuery.recordcount; row = row + 1)
		{
			st = structNew();
			for(index=1; index LTE arraylen(cols); index=index+1)
			{
				st[cols[index]] = arguments.thequery[cols[index]][row];
			}
			streturn[theQuery.objectid[row]] = duplicate(st);
		}
	
		</cfscript>
		<cfreturn stReturn>
	</cffunction>
	
	
	<cffunction name="filterStructure" hint="Removes specified structure elements">
		<cfargument name="st" required="Yes" hint="The structure to parse">
		<cfargument name="lKeys" required="Yes" hint="A list of structure keys to delete">
		
		<cfset var i = 1>
		<cfscript>
			aKeys = listToArray(arguments.lKeys);	
			for(i = 1;i LTE arrayLen(aKeys);i=i+1)
			{
				if(structKeyExists(arguments.st,aKeys[i]))
					structDelete(arguments.st,aKeys[i]);
			}
				
		</cfscript>
		<cfreturn arguments.st>
	</cffunction>
	
	<cffunction name="structToNamePairs" hint="Builds a named pair string from a structure">
		<cfargument name="st">
		<cfargument name="delimiter" default="&" required="false">
		<cfargument name="Quotes" default="" required="false">
		<cfset var keyindex = 1>
		<cfscript>
			namepair = '';
			keyCount = structCount(arguments.st);
			for(key in arguments.st)
			{	
				namepair = namepair & "#key#=#arguments.quotes##arguments.st[key]##arguments.quotes#";
				if(keyIndex LT keyCount)
					namepair = namepair & "#arguments.delimiter#";
				keyIndex = keyIndex + 1;		
			}
		</cfscript>
		<cfreturn trim(namepair)>
	
	</cffunction>
	
	
<cffunction name="ParagraphFormat2">
	<cfargument name="str" required="Yes">
	
	<cfscript>
	str = arguments.str;	
	 {
	//first make Windows style into Unix style
	str = replace(str,chr(13)&chr(10),chr(10),"ALL");
	//now make Macintosh style into Unix style
	str = replace(str,chr(13),chr(10),"ALL");
	//now fix tabs
	str = replace(str,chr(9),"&nbsp;&nbsp;&nbsp;","ALL");
	//now return the text formatted in HTML
	}
	</cfscript>
	<cfreturn replace(str,chr(10),"<br />","ALL")>
</cffunction>
	
<cffunction name="fEscapeHTMLChars" hint="escape characters that soEditor wont" returntype="string">
	<cfargument name="inputStr">
	<cfset returnstring = inputStr>

<cfsavecontent variable="strEntitie">
"Character"|"Entity"|"Decimal"|"Hex"
"Latin small f with hook = function = florin"|"&fnof;"|"&#402;"|"&#x192;"
"Greek capital letter alpha"|"&Alpha;"|"&#913;"|"&#x391;"
"Greek capital letter beta"|"&Beta;"|"&#914;"|"&#x392;"
"Greek capital letter gamma"|"&Gamma;"|"&#915;"|"&#x393;"
"Greek capital letter delta"|"&Delta;"|"&#916;"|"&#x394;"
"Greek capital letter epsilon"|"&Epsilon;"|"&#917;"|"&#x395;"
"Greek capital letter zeta"|"&Zeta;"|"&#918;"|"&#x396;"
"Greek capital letter eta"|"&Eta;"|"&#919;"|"&#x397;"
"Greek capital letter theta"|"&Theta;"|"&#920;"|"&#x398;"
"Greek capital letter iota"|"&Iota;"|"&#921;"|"&#x399;"
"Greek capital letter kappa"|"&Kappa;"|"&#922;"|"&#x39A;"
"Greek capital letter lambda"|"&Lambda;"|"&#923;"|"&#x39B;"
"Greek capital letter mu"|"&Mu;"|"&#924;"|"&#x39C;"
"Greek capital letter nu"|"&Nu;"|"&#925;"|"&#x39D;"
"Greek capital letter xi"|"&Xi;"|"&#926;"|"&#x39E;"
"Greek capital letter omicron"|"&Omicron;"|"&#927;"|"&#x39F;"
"Greek capital letter pi"|"&Pi;"|"&#928;"|"&#x3A0;"
"Greek capital letter rho"|"&Rho;"|"&#929;"|"&#x3A1;"
"Greek capital letter sigma"|"&Sigma;"|"&#931;"|"&#x3A3;"
"Greek capital letter tau"|"&Tau;"|"&#932;"|"&#x3A4;"
"Greek capital letter upsilon"|"&Upsilon;"|"&#933;"|"&#x3A5;"
"Greek capital letter phi"|"&Phi;"|"&#934;"|"&#x3A6;"
"Greek capital letter chi"|"&Chi;"|"&#935;"|"&#x3A7;"
"Greek capital letter psi"|"&Psi;"|"&#936;"|"&#x3A8;"
"Greek capital letter omega"|"&Omega;"|"&#937;"|"&#x3A9;"
"Greek small letter alpha"|"&alpha;"|"&#945;"|"&#x3B1;"
"Greek small letter beta"|"&beta;"|"&#946;"|"&#x3B2;"
"Greek small letter gamma"|"&gamma;"|"&#947;"|"&#x3B3;"
"Greek small letter delta"|"&delta;"|"&#948;"|"&#x3B4;"
"Greek small letter epsilon"|"&epsilon;"|"&#949;"|"&#x3B5;"
"Greek small letter zeta"|"&zeta;"|"&#950;"|"&#x3B6;"
"Greek small letter eta"|"&eta;"|"&#951;"|"&#x3B7;"
"Greek small letter theta"|"&theta;"|"&#952;"|"&#x3B8;"
"Greek small letter iota"|"&iota;"|"&#953;"|"&#x3B9;"
"Greek small letter kappa"|"&kappa;"|"&#954;"|"&#x3BA;"
"Greek small letter lambda"|"&lambda;"|"&#955;"|"&#x3BB;"
"Greek small letter mu"|"&mu;"|"&#956;"|"&#x3BC;"
"Greek small letter nu"|"&nu;"|"&#957;"|"&#x3BD;"
"Greek small letter xi"|"&xi;"|"&#958;"|"&#x3BE;"
"Greek small letter omicron"|"&omicron;"|"&#959;"|"&#x3BF;"
"Greek small letter pi"|"&pi;"|"&#960;"|"&#x3C0;"
"Greek small letter rho"|"&rho;"|"&#961;"|"&#x3C1;"
"Greek small letter final sigma"|"&sigmaf;"|"&#962;"|"&#x3C2;"
"Greek small letter sigma"|"&sigma;"|"&#963;"|"&#x3C3;"
"Greek small letter tau"|"&tau;"|"&#964;"|"&#x3C4;"
"Greek small letter upsilon"|"&upsilon;"|"&#965;"|"&#x3C5;"
"Greek small letter phi"|"&phi;"|"&#966;"|"&#x3C6;"
"Greek small letter chi"|"&chi;"|"&#967;"|"&#x3C7;"
"Greek small letter psi"|"&psi;"|"&#968;"|"&#x3C8;"
"Greek small letter omega"|"&omega;"|"&#969;"|"&#x3C9;"
"Greek small letter theta symbol"|"&thetasym;"|"&#977;"|"&#x3D1;"
"Greek upsilon with hook symbol"|"&upsih;"|"&#978;"|"&#x3D2;"
"Greek pi symbol"|"&piv;"|"&#982;"|"&#x3D6;"
"bullet = black small circle"|"&bull;"|"&#8226;"|"&#x2022;"
"horizontal ellipsis = three dot leader"|"&hellip;"|"&#8230;"|"&#x2026;"
"prime = minutes = feet"|"&prime;"|"&#8242;"|"&#x2032;"
"double prime = seconds = inches"|"&Prime;"|"&#8243;"|"&#x2033;"
"overline = spacing overscore"|"&oline;"|"&#8254;"|"&#x203E;"
"fraction slash"|"&frasl;"|"&#8260;"|"&#x2044;"
"script capital P = power set = Weierstrass p"|"&weierp;"|"&#8472;"|"&#x2118;"
"blackletter capital I = imaginary part"|"&image;"|"&#8465;"|"&#x2111;"
"blackletter capital R = real part symbol"|"&real;"|"&#8476;"|"&#x211C;"
"trade mark sign"|"&trade;"|"&#8482;"|"&#x2122;"
"alef symbol = first transfinite cardinal"|"&alefsym;"|"&#8501;"|"&#x2135;"
"leftwards arrow"|"&larr;"|"&#8592;"|"&#x2190;"
"upwards arrow"|"&uarr;"|"&#8593;"|"&#x2191;"
"rightwards arrow"|"&rarr;"|"&#8594;"|"&#x2192;"
"downwards arrow"|"&darr;"|"&#8595;"|"&#x2193;"
"left right arrow"|"&harr;"|"&#8596;"|"&#x2194;"
"downwards arrow with corner leftwards = carriage return"|"&crarr;"|"&#8629;"|"&#x21B5;"
"leftwards double arrow"|"&lArr;"|"&#8656;"|"&#x21D0;"
"upwards double arrow"|"&uArr;"|"&#8657;"|"&#x21D1;"
"rightwards double arrow"|"&rArr;"|"&#8658;"|"&#x21D2;"
"downwards double arrow"|"&dArr;"|"&#8659;"|"&#x21D3;"
"left right double arrow"|"&hArr;"|"&#8660;"|"&#x21D4;"
"for all"|"&forall;"|"&#8704;"|"&#x2200;"
"partial differential"|"&part;"|"&#8706;"|"&#x2202;"
"there exists"|"&exist;"|"&#8707;"|"&#x2203;"
"empty set = null set = diameter"|"&empty;"|"&#8709;"|"&#x2205;"
"nabla = backward difference"|"&nabla;"|"&#8711;"|"&#x2207;"
"element of"|"&isin;"|"&#8712;"|"&#x2208;"
"not an element of"|"&notin;"|"&#8713;"|"&#x2209;"
"contains as member"|"&ni;"|"&#8715;"|"&#x220B;"
"n-ary product = product sign"|"&prod;"|"&#8719;"|"&#x220F;"
"n-ary sumation"|"&sum;"|"&#8721;"|"&#x2211;"
"minus sign"|"&minus;"|"&#8722;"|"&#x2212;"
"asterisk operator"|"&lowast;"|"&#8727;"|"&#x2217;"
"square root = radical sign"|"&radic;"|"&#8730;"|"&#x221A;"
"proportional to"|"&prop;"|"&#8733;"|"&#x221D;"
"infinity"|"&infin;"|"&#8734;"|"&#x221E;"
"angle"|"&ang;"|"&#8736;"|"&#x2220;"
"logical and = wedge"|"&and;"|"&#8743;"|"&#x2227;"
"logical or = vee"|"&or;"|"&#8744;"|"&#x2228;"
"intersection = cap"|"&cap;"|"&#8745;"|"&#x2229;"
"union = cup"|"&cup;"|"&#8746;"|"&#x222A;"
"integral"|"&int;"|"&#8747;"|"&#x222B;"
"therefore"|"&there4;"|"&#8756;"|"&#x2234;"
"tilde operator = varies with = similar to"|"&sim;"|"&#8764;"|"&#x223C;"
"approximately equal to"|"&cong;"|"&#8773;"|"&#x2245;"
"almost equal to = asymptotic to"|"&asymp;"|"&#8776;"|"&#x2248;"
"not equal to"|"&ne;"|"&#8800;"|"&#x2260;"
"identical to"|"&equiv;"|"&#8801;"|"&#x2261;"
"less-than or equal to"|"&le;"|"&#8804;"|"&#x2264;"
"greater-than or equal to"|"&ge;"|"&#8805;"|"&#x2265;"
"subset of"|"&sub;"|"&#8834;"|"&#x2282;"
"superset of"|"&sup;"|"&#8835;"|"&#x2283;"
"not a subset of"|"&nsub;"|"&#8836;"|"&#x2284;"
"subset of or equal to"|"&sube;"|"&#8838;"|"&#x2286;"
"superset of or equal to"|"&supe;"|"&#8839;"|"&#x2287;"
"circled plus = direct sum"|"&oplus;"|"&#8853;"|"&#x2295;"
"circled times = vector product"|"&otimes;"|"&#8855;"|"&#x2297;"
"up tack = orthogonal to = perpendicular"|"&perp;"|"&#8869;"|"&#x22A5;"
"dot operator"|"&sdot;"|"&#8901;"|"&#x22C5;"
"left ceiling = APL upstile"|"&lceil;"|"&#8968;"|"&#x2308;"
"right ceiling"|"&rceil;"|"&#8969;"|"&#x2309;"
"left floor = APL downstile"|"&lfloor;"|"&#8970;"|"&#x230A;"
"right floor"|"&rfloor;"|"&#8971;"|"&#x230B;"
"left-pointing angle bracket = bra"|"&lang;"|"&#9001;"|"&#x2329;"
"right-pointing angle bracket = ket"|"&rang;"|"&#9002;"|"&#x232A;"
"lozenge"|"&loz;"|"&#9674;"|"&#x25CA;"
"black spade suit"|"&spades;"|"&#9824;"|"&#x2660;"
"black club suit = shamrock"|"&clubs;"|"&#9827;"|"&#x2663;"
"black heart suit = valentine"|"&hearts;"|"&#9829;"|"&#x2665;"
"black diamond suit"|"&diams;"|"&#9830;"|"&#x2666;"
</cfsavecontent>

	<cfset stEntitie = StructNew()>
	<cfset aEntitie = ListToArray(strEntitie,"#chr(10)#")>

	<cfloop index="i" from="3" to="#ArrayLen(aEntitie)#">
		<cfset lentity = aEntitie[i]>
		<cfif ListLen(lentity,"|") EQ 4> <!--- ignore first line --->
			<cfset tDescription = ListGetAt(lentity,1,"|")>
			<cfset tHTML = ListGetAt(lentity,2,"|")>
			<cfset tDEC = ListGetAt(lentity,3,"|")>
			<cfset tHEX = ListGetAt(lentity,4,"|")>
			<cfset stEntitie[tHEX] = StructNew()>
			<cfset stEntitie[tHEX].hex = tHEX>
			<cfset stEntitie[tHEX].dec = tDEC>
			<cfset stEntitie[tHEX].html = tHTML>
			<cfset stEntitie[tHEX].hexNum = "0" & Right(tHEX,len(tHEX)-3)>
			<cfset stEntitie[tHEX].hexNum = Left(stEntitie[tHEX].hexNum,len(stEntitie[tHEX].hexNum)-3)>
			<cfset stEntitie[tHEX].decNum = Right(tDEC,len(tDEC)-3)>
			<cfset stEntitie[tHEX].decNum = Left(stEntitie[tHEX].decNum,len(stEntitie[tHEX].decNum)-2)>
		</cfif>
	</cfloop>

	<cfloop item="entitie" collection="#stEntitie#">
		<cfset currentEntitie = stEntitie[entitie].decNum>
		<cfset replaceEntitie = replaceNoCase(stEntitie[entitie].html,'"','','All')>
		<cfset returnstring = ReplaceNoCase(returnstring,chr(currentEntitie),replaceEntitie,"all")>
	</cfloop>

	<cfreturn returnstring>
</cffunction>

<cffunction name="fBrowserDetect" returntype="string">
	<cfset returnString = "unknown">
	<cfif ListContainsNoCase(cgi.http_user_agent,"MSIE"," ")>
		<cfset returnString = "Microsoft IE">
	<cfelseif ListContainsNoCase(cgi.http_user_agent,"Firefox"," ")>
		<cfset returnString = "Firefox">
	</cfif>

	<cfreturn returnString>
</cffunction>

<cffunction name="ConvertVerityWebSearch" returntype="array" hint="Returns an array of structures defining the individual elements that can be used in a verity search">

	<cfargument name="webSearchString" type="string" required="true" default="">
	
	
	<cfset aPhrases = arrayNew(1)>
	<cfset PhraseState = "start">
	<cfset Phrasecount = 0>
	
	<cfloop from="1" to="#len(arguments.webSearchString)#" index="i">
		<cfset character = Mid(arguments.webSearchString, i, 1)>
		
		<cfif character EQ "#chr(34)#"><!--- chr(34) is a " --->
			<cfif PhraseState EQ "start">
				<cfset stPhrase = StructNew()>
				<cfset stPhrase.Start = i>
				<cfset stPhrase.End = "">
				<cfset stPhrase.String = "">
				<cfset stPhrase.Type = "Phrase">
				<cfset Phrasecount = Phrasecount + 1>
				<cfset PhraseState = "end">
			<cfelse>
				<cfset stPhrase.End = i>
				<cfset stPhrase.String = Mid(arguments.webSearchString, stPhrase.Start + 1, stPhrase.End - stPhrase.Start -1)>
				
				<cfset ArrayAppend(aPhrases,Duplicate(stPhrase))>
				<cfset PhraseState = "start">
			</cfif>
			
		</cfif>
		
	</cfloop>
	
	
			
	<cfset PhraseState = "start">
	
	<cfloop from="1" to="#len(arguments.webSearchString)#" index="i">
		<cfset character = Mid(arguments.webSearchString, i, 1)>
		
		<cfif character EQ "+" and PhraseState EQ "Start">
				<cfset stPhrase = StructNew()>
				<cfset stPhrase.Start = i>
				<cfset stPhrase.End = "">
				<cfset stPhrase.String = "">
				<cfset stPhrase.Type = "+">
				<cfset Phrasecount = Phrasecount + 1>
				<cfset PhraseState = "end">			
		</cfif>
		
		
		<cfif (character EQ " " and PhraseState EQ "end") or (i EQ len(arguments.webSearchString) and PhraseState EQ "end")>
			<cfset stPhrase.End = i>
			<cfset stPhrase.String = Mid(arguments.webSearchString, stPhrase.Start + 1, stPhrase.End - stPhrase.Start)>
			
			<cfset ArrayAppend(aPhrases,Duplicate(stPhrase))>
			
			<cfset PhraseState = "start">
		</cfif>
	</cfloop>

			
	<cfset PhraseState = "start">
	
	<cfloop from="1" to="#len(arguments.webSearchString)#" index="i">
		<cfset character = Mid(arguments.webSearchString, i, 1)>
		
		<cfif character EQ "-" and PhraseState EQ "Start">
				<cfset stPhrase = StructNew()>
				<cfset stPhrase.Start = i>
				<cfset stPhrase.End = "">
				<cfset stPhrase.String = "">
				<cfset stPhrase.Type = "-">
				<cfset Phrasecount = Phrasecount + 1>
				<cfset PhraseState = "end">			
		</cfif>
		
		
		<cfif (character EQ " " and PhraseState EQ "end") or (i EQ len(arguments.webSearchString) and PhraseState EQ "end")>
			<cfset stPhrase.End = i>
			<cfset stPhrase.String = Mid(arguments.webSearchString, stPhrase.Start + 1, stPhrase.End - stPhrase.Start)>
			
			<cfset ArrayAppend(aPhrases,Duplicate(stPhrase))>
				
			<cfset PhraseState = "start">
		</cfif>
	</cfloop>


	<cfset PhraseState = "start">
	<cfset stPhrase = StructNew()>
	<cfset stPhrase.Type = "regular">
	
	<cfloop from="1" to="#len(arguments.webSearchString)#" index="i">
		<cfset character = Mid(arguments.webSearchString, i, 1)>
		<cfif i EQ len(arguments.webSearchString)>
			<cfset nextcharacter = "">
		<cfelse>
			<cfset nextcharacter = Mid(arguments.webSearchString, i + 1, 1)>
		</cfif>
		
		<cfif i EQ 1>
			<cfset prevcharacter = "">
		<cfelse>
			<cfset prevcharacter = Mid(arguments.webSearchString, i - 1, 1)>
		</cfif>
		
		
		<cfif character EQ "#chr(34)#"><!--- chr(34) is a " ---> 
			<cfif PhraseState EQ "Start">
				<cfset PhraseState = "End">
				<cfset stPhrase.Type = "phrase">	
			<cfelse>
				<cfset PhraseState = "Start">
				<cfset stPhrase.Type = "regular">		
			</cfif>
		</cfif>
		
		
		<cfif PhraseState EQ "Start" AND stPhrase.Type EQ "regular">
			<cfif (character EQ " " AND Not ListContainsNoCase("#chr(34)#,+,-",nextCharacter)) or (i EQ 1 AND Not ListContainsNoCase("#chr(34)#,+,-",Character))>
				<cfset stPhrase = StructNew()>
				<cfset stPhrase.Start = i>
				<cfset stPhrase.End = "">
				<cfset stPhrase.String = "">
				<cfset stPhrase.Type = "regular">
				<cfset PhraseState = "end">	
				<cfset Phrasecount = Phrasecount + 1>	
			</cfif>
		<cfelseif PhraseState EQ "End" AND stPhrase.Type EQ "regular">
			<cfif character EQ " " or i EQ len(arguments.webSearchString)>
				
				<cfset stPhrase.End = i>
				<cfset stPhrase.String = Mid(arguments.webSearchString, stPhrase.Start, stPhrase.End - stPhrase.Start + 1 )>
				
				<cfset ArrayAppend(aPhrases,Duplicate(stPhrase))>
					
				<cfset PhraseState = "start">
				
			</cfif>
			
			<cfif (character EQ " " AND Not ListContainsNoCase("#chr(34)#,+,-",nextCharacter)) or (i EQ 1 AND Not ListContainsNoCase("#chr(34)#,+,-",Character))>
				<cfset stPhrase = StructNew()>
				<cfset stPhrase.Start = i>
				<cfset stPhrase.End = "">
				<cfset stPhrase.String = "">
				<cfset stPhrase.Type = "regular">
				<cfset PhraseState = "end">	
				<cfset Phrasecount = Phrasecount + 1>	
			</cfif>
						
		</cfif>
		
				
	</cfloop>
	
	<cfreturn aPhrases>
</cffunction>