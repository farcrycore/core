<cfcomponent displayname="i18nUtil" hint="util I18N functions: version 1.1 mar-2005 Paul Hastings (paul@sustainbleGIS.com)" output="no" bDocument="true" scopelocation="application.i18nUtils">
<!--- 

author:		paul hastings <paul@sustainableGIS.com>
date:		1-April-2004
revisions:	
3-mar-2005	expanded BIDI locale list based on CLDR 1.2 info
21-mar-2005	cleaned up some un-scoped vars

notes:
this CFC contains a few util I18N functions. all valid java locales	are supported. it requires the use 
of cfobject. 

methods in this CFC:

	- getLocalesAsQuery returns QUERY of java style locales (en_US,etc.)
	and their corresponding names (English (United States),etc.) available on this server. PUBLIC
		
	- getLocales returns LIST of java style locales (en_US,etc.) available on this server. PUBLIC
	
	- getLocaleNames returns LIST of java style locale names available on this server. PUBLIC
	
	- isBIDI returns boolean indicating whether given locale uses lrt to rtl writing sysem direction. 
	required argument is thisLocale. PUBLIC

	- isValidLocale returns BOOLEAN indicating whether a given locale is valid on this server. should
	be used for locale validation prior to passing to this CFC. takes one required argument, thisLocale,
	string such as "en_US", "th_TH", etc. PUBLIC
	
	- showCountry: returns country display name in english from given locale, takes 
	one required argument, thisLocale. returns string. PUBLIC
	
	- showLanguage: returns language display name in english from given locale, takes 
	one required argument, thisLocale. returns string. PUBLIC
 --->
<cfset variables.aLocale = createObject("java","java.util.Locale")>

<cffunction access="public" name="getLocalesAsQuery" output="No" returntype="query" hint="returns query of locales with their names" bDocument="true">
	<cfscript>
		var orgLocales=aLocale.getAvailableLocales();
		var qLocales=queryNew("value,name"); /* allow list to be used directly with list formtool */
		var i=0;
		var thisName="";
		for (i=1; i LTE arrayLen(orgLocales); i=i+1) {
			if (listLen(orgLocales[i],"_") EQ 2) {
				if (left(orgLocales[i],2) EQ "ar" or left(orgLocales[i],2) EQ "iw")
					thisName=chr(8235)&orgLocales[i].getDisplayName(orgLocales[i])&chr(8234);
				else
					thisName=orgLocales[i].getDisplayName(orgLocales[i]);
				queryAddRow(qLocales, {"value"=orgLocales[i], "name"=replace(thisName, ",", "", "ALL")});
			} // if locale more than language
		} //for
		return qLocales;
	</cfscript>
</cffunction>

<cffunction access="public" name="getLocales" output="No" returntype="string" hint="returns list of locales" bDocument="true">
	<cfscript>
		var orgLocales=aLocale.getAvailableLocales();
		var theseLocales="";	
		var i=0;
		for (i=1; i LTE arrayLen(orgLocales); i=i+1) {
			if (listLen(orgLocales[i],"_") EQ 2) {
				theseLocales=listAppend(theseLocales,orgLocales[i]);
			} // if locale more than language
		} //for
		return theseLocales;	
	</cfscript>
</cffunction> 

<cffunction access="public" name="getLocaleNames" output="No" returntype="string" hint="returns list of locale names, UNICODE direction char (LRE/RLE) added as required" bDocument="true">
	<cfscript>
		var orgLocales="";
		var theseLocales="";	
		var thisName="";
		var i=0;
		orgLocales = aLocale.getAvailableLocales();
		for (i=1; i LTE arrayLen(orgLocales); i=i+1) {
			if (listLen(orgLocales[i],"_") EQ 2) {
				if (left(orgLocales[i],2) EQ "ar" or left(orgLocales[i],2) EQ "iw")
					thisName=chr(8235)&orgLocales[i].getDisplayName(orgLocales[i])&chr(8234);
				else 
					thisName=orgLocales[i].getDisplayName(orgLocales[i]);
				theseLocales=listAppend(theseLocales,thisName);
			} // if locale more than language
		} //for
		return theseLocales;	
	</cfscript>
</cffunction> 

<cffunction access="public" name="showCountry" output="No" returntype="string" hint="returns display country name for give locale" bDocument="true">
<cfargument name="thisLocale" required="yes" type="string">	
	<cfscript>
		var locale=aLocale.init(listFirst(arguments.thisLocale,"_"),listLast(arguments.thisLocale,"_"));	
		return locale.getDisplayCountry();	
	</cfscript>
</cffunction> 

<cffunction access="public" name="showLanguage" output="No" returntype="string" hint="returns display country name for give locale" bDocument="true">
<cfargument name="thisLocale" required="yes" type="string">	
	<cfset var locale=aLocale.init(listFirst(arguments.thisLocale,"_"),listLast(arguments.thisLocale,"_"))>	
	<cfreturn locale.getDisplayLanguage()>	
</cffunction>

<cffunction access="public" name="isValidLocale" output="No" returntype="boolean" bDocument="true">
<cfargument name="thisLocale" required="yes" type="string">
	<cfset var isOK=false>
	<cfif listFind(getLocales(),arguments.thisLocale)>
		<cfset isOK=true>
	</cfif>
	<cfreturn isOK>
</cffunction> 

<cffunction access="public" name="isBidi" output="No" returntype="boolean" hint="determines if given locale is BIDI" bDocument="true">
<cfargument name="thisLocale" required="yes" type="string">
	<cfif listFind("ar,he,fa,ps",left(arguments.thisLocale,2))> <!--- cldr 1.2 info --->
		<cfreturn true>
	<cfelse>
		<cfreturn false>	
	</cfif>	
</cffunction>

</cfcomponent>	 
