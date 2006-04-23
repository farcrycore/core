<!--- 
|| LEGAL ||
$Copyright: Daemon Pty Limited 1995-2003, http://www.daemon.com.au $
$License: Released Under the "Common Public License 1.0", http://www.opensource.org/licenses/cpl.php$ 

|| VERSION CONTROL ||
$Header: /cvs/farcry/farcry_core/tags/farcry/plpUpdateOutput.cfm,v 1.1.6.1 2005/06/20 05:54:54 guy Exp $
$Author: guy $
$Date: 2005/06/20 05:54:54 $
$Name: milestone_2-3-2 $
$Revision: 1.1.6.1 $

|| DESCRIPTION || 
Updates the output scope with submitted form elements from the plp

|| DEVELOPER ||
Brendan Sisson (brendan@daemon.com.au)

|| ATTRIBUTES ||
in: 
out:
--->

<cfloop index="FormItem" list="#CALLER.FORM.FieldNames#">
	<cfif StructKeyExists(CALLER.output,FormItem)>
		<cfif FormItem EQ "body">
			<cfset "CALLER.output.#FormItem#" = fEscapeHTMLChars(Evaluate("CALLER.FORM.#FormItem#"))>
		<cfelse>
			<cfset "CALLER.output.#FormItem#" = Evaluate("CALLER.FORM.#FormItem#")>
		</cfif>
	</cfif>
</cfloop>

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