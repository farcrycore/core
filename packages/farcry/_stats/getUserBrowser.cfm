<cfscript>
	browserName="Unknown: ";
	browserVersion=user_agent;
	if (Len(user_agent))
	{
		if (FindNoCase("MSIE",user_agent) AND NOT findNoCase("opera",user_agent) )
		{ 
			browserName="MSIE";
			browserVersion=Val(RemoveChars(user_agent,1,FindNoCase("MSIE",user_agent)+4));
		}
		else if (findNoCase("opera",user_agent))
		{
			browserName = "Opera";
			browserVersion = Val(RemoveChars(user_agent,1,FindNoCase("Opera",user_agent)+5));
		}	
		else if (findNoCase("safari",user_agent))
		{
			browsername = "Safari";
			browserVersion = "";// Not sure about how to disect the user_agent string for version just yet.
		}	
		else if (findNoCase("Googlebot",user_agent))
		{
			browsername = "Googlebot";
			browserVersion = Val(RemoveChars(user_agent,1,FindNoCase("Googlebot",user_agent)+9));
		}	
		else if (findNoCase("ia_archiver",user_agent))
		{
			browsername = "ia archiver";
			browserVersion = "";// Not sure about how to disect the user_agent string for version just yet.
		}
		else	
		{
			if (Find("Mozilla",user_agent)) { 
				if (not Find("compatible",user_agent))
				{ 
					browserVersion=Val(RemoveChars(user_agent,1,Find("/",user_agent)));
					if (browserVersion lt 5) {
						//netscape browsers
						browserName="Netscape";	
					}
					else 
					{
						//mozilla browsers
						browserName="Mozilla";	
						browserVersion=Val(RemoveChars(user_agent,1,Find("rv:",user_agent)+2));
					}
				}
				else
				{
					browserName="compatible"; 
				}
			}
			if (Find("ColdFusion",user_agent)) 
			{ 
				browserName="ColdFusion";
			}
		}
	}	
	stBroswer = structNew();
	stBrowser.name = trim(browsername);
	stBrowser.version = trim(browserversion);
</cfscript>