<!--- 
author:		paul hastings <paul@sustainableGIS.com>
date:		13-may-2003
revisions:	

1-jun-2003 revised InetAddressLocator.jar install instructions.
2-jun-2003 changed init application lock to named lock
2-jun-2003 fixed bug in findLanguage method. thanks to Jochem van Dieten for pointing 
out the bug. cleaned up the var scoping.
2-jun-2003 changed application.allLocales to list from array to improve locale validation
speed. again thanks to Jochem van Dieten for pointing that out. cleaned up valid locales 
to just include locales w/ language_COUNTRY_VARIANT rather than just language (now matches
w/i18n functions CFC).
2-jun-2003 fixed bug in CFML easter egg replace
11-jul-2003 added showCountry & showLanguage methods. changed testbed to use createObject
4-aug-2003 tidied documentation, sync'd with sf.net (nwetters) note that the InetAddressLocator
class name has been changed to net.sf.javainetlocator.InetAddressLocator
5-aug-2003 added self-intialization to all methods, no need to call init(), left as public method
for backwards compatibility

notes:
this cfc trys to determine locale & country from user IP (cgi.REMOTE_ADDR) & browser language 
(cgi.HTTP_ACCEPT_LANGUAGE). it requires createObject functionality and nigel wetters' InetAddressLocator
java class (jar) be loaded. that jar is available from http://sourceforge.net/projects/javainetlocator drop nigel 
(nigel@wetters.net) a line if you find this java class useful or if you have issues with the GNU license his 
class is released under. for performance reasons, the required java objects are loaded into a shared scope (application). 

there are 7 methods in this component:
- init, initializes the required java objects into a shared scope, returns boolean indicating success
- isValidLocale, checks if a given locale is valid java locale, returns boolean indicating validity of locale
- findlocale, returns valid locale derived from http_accept_language & IP
- findCountry, returns 2 letter country code from IP
- findLanguage, returns two letter language code from http_accept_language & IP
- showCountry, returns full display name of country for this IP, localized if available
- showLanguage, returns full display name of language for this IP, localized if available

findLocale logic:
this component 1st tries to mix language from HTTP_ACCEPT_LANGUAGE and country/region from the
InetAddressLocator (this is to get around the built-in bias of that java class for countries/regions with more
than one language). it tests this against valid java locales & returns the mixed locale if valid. if the mixed
locale fails, it next tries to make HTTP_ACCEPT_LANGUAGE into a locale & again tests that against valid
java locales. if this fails, it returns the original locale derived from InetAddressLocator. note that the 
InetAddressLocator will return '**' for localhost, IP not in db, etc. findLocale therefore accepts an
optional 'fallbackLocale' arguement to handle these cases.

InetAddressLocator:
please see the InetAddressLocator.txt file but basically, if you 
distribute the InetAddressLocator class, you must also distribute the
GPL License. the InetAddressLocator class is covered by the GNU GENERAL 
PUBLIC LICENSE.  GNU GPL is available here: http://www.gnu.org/licenses/gpl.txt
if you have any questions concerning InetAddressLocator java class or
its distribution email: nigel@wetters.net

copy the InetAddressLocator.jar somewhere under your MX install dir. add its location to 
the Java path & stop & re-start the MX server service. Or more simply copy the 
InetAddressLocator.jar to /cfusionMX/wwwroot/web-inf/lib dir.
 --->

<cfcomponent displayname="geoLocator" hint="returns locale info based on user IP">

<cffunction access="public" displayname="init" name="init" output="No" 
	hint="initializes required geoLocator java objects into shared scope" returntype="boolean">
<cfset var bSuccess=1><!--- assume it worked --->	
<cfset var orgLocales="">
<cfset var theseLocales= arrayNew(1)>
<cfset var i=1>
<cfset var x="">
<cftry>
	<!--- handle any potential race conditions --->
	<cflock timeout="10" throwontimeout="Yes" type="EXCLUSIVE" name="geoLocatorLOCK">
		<cfobject type="Java" action="Create" class="net.sf.javainetlocator.InetAddressLocator"  name="application.geoLocator">
		<cfobject type="Java" action="Create" class="java.net.InetAddress"  name="application.ipAddress">
		<cfobject type="Java" action="Create" class="java.util.Locale"  name="application.javaLocale">
		<!--- enumerate available locales --->
		<cfset orgLocales = application.javaLocale.getAvailableLocales()>
		<cfloop index="i" from="1" to="#arrayLen(orgLocales)#">
			<cfif listLen(orgLocales[i],"_") GT 1>
				<cfset x=arrayAppend(theseLocales,orgLocales[i])>
			</cfif>
		</cfloop>
		<cfset application.allLocales = arrayToList(theseLocales)>
		<cfset application.geoLocatorInit=true>
	</cflock>
	<cfcatch type="Any"> <!--- handle object & security exceptions --->
		<cfset bSuccess=0> <!--- catch if it doesn't --->
	</cfcatch>	
</cftry>
<cfreturn bSuccess>
</cffunction>

<cffunction name="isValidLocale" access="public" displayname="isValidLocale" 
	hint="determines if passed locale is valid java locale" output="No" returntype="boolean">
	<cfargument name="aLocale" required="Yes" type="string"><!--- locale to check --->
	<cfset var bLocaleValid=0> <!--- assume bad locale --->
	<cfif NOT structKeyExists(application,"geoLocatorInit")>
		<cfset isOK=init()>
	</cfif>
	<cfif Listfind(application.allLocales,arguments.aLocale)>
		<cfset bLocaleValid=1>
	</cfif>
	<cfreturn bLocaleValid>
</cffunction> 

<cffunction name="findLocale" access="public" displayname="findLocale" 
	hint="returns locale from user IP" output="No" returntype="string"> 
	<cfargument name="thisIP" required="Yes" type="string"><!--- this user's IP, cgi.REMOTE_ADDR --->
	<cfargument name="thisLanguage" required="Yes" type="string"><!--- CGI.http_accept_Language --->
	<cfargument name="fallbackLocale" required="No" type="string" default="en_US">
	<cfset var thisHost="">
	<cfset var aLocale="">
	<cfset var thisLocale="">
	<cfset var testLocale="">
	<cfset var aLanguage="">
	<cfset var mixedLocale=0>
	<cfif NOT structKeyExists(application,"geoLocatorInit")>
		<cfset isOK=init()>
	</cfif>
	<cfset thisHost=application.ipAddress.getByname(arguments.thisIP)>
	<cfset aLocale=application.geoLocator.getLocale(thisHost)>
	<cfif aLocale EQ "**"> <!--- localhost, IP not in db, etc. --->
		<cfset aLocale=arguments.fallbackLocale> <!--- fall back locale --->
	</cfif>
	<cfset thisLocale=aLocale>
	<!--- lets clean up CFML easter egg locales, considering who might be using this cfc --->
	<cfset aLanguage=replaceNoCase(arguments.thisLanguage,"CFML,","","ALL")>
	<cfset aLanguage=replaceNoCase(aLanguage,",CFML","","ALL")>
	<cfset aLanguage=replaceNoCase(aLanguage,",CFML,","","ALL")>
	<!--- just grab the first language/locale in the list --->
	<cfset aLanguage=listFirst(replaceNoCase(aLanguage,"-","_","ALL"),",")>
	<!--- try to make this a proper Locale --->
	<cfset aLanguage=left(aLanguage,2) & "_" & uCase(right(aLanguage,2))>
 	 <!--- easy stuff 1st, http_accept_language not the same as geoLocator locale or its not empty--->
	<cfif (aLanguage NEQ thisLocale) AND (trim(len(aLanguage)))><!--- this gets tricky and a bit arbitrary --->
		<!--- lets mix & match language & country to see if we come up w/a valid locale --->
		<cfset testLocale=left(aLanguage,2) & "_" & right(aLocale,2)>
		<cfif isValidLocale(testLocale)>
			<cfset mixedLocale=1>
			<cfset thisLocale=testLocale>
		</cfif>
		<!--- did mixed locale work and could the http_accept_language be a vlaid Locale, ie en_US, th_TH, etc --->
		<cfif NOT mixedLocale AND trim(len(aLanguage)) is 5>
			<cfif isValidLocale(aLanguage)>
					<cfset thisLocale=aLanguage>
			</cfif>
		</cfif>
	</cfif>
	<cfreturn thisLocale>
</cffunction>

<cffunction name="findCountry" access="public" displayname="findCountry" 
	hint="returns country from user IP" output="No" returntype="string"> 
	<cfargument name="thisIP" required="Yes" type="string"><!--- this user's IP, cgi.REMOTE_ADDR --->
	<cfargument name="fallbackCountry" required="No" type="string" default="US">
	<cfset var thisHost="">
	<cfset var thisCountry="">
	<cfif NOT structKeyExists(application,"geoLocatorInit")>
		<cfset isOK=init()>
	</cfif>
	<cfset thisHost=application.ipAddress.getByname(arguments.thisIP)>
	<cfset thisCountry=right(application.geoLocator.getLocale(thisHost),2)>
	<cfif thisCountry EQ "**"> <!--- localhost, IP not in db, etc. --->
		<cfset thisCountry=arguments.fallbackCountry> <!--- fall back country --->
	</cfif>
	<cfreturn thisCountry>
</cffunction>

<cffunction name="findLanguage" access="public" displayname="findCountry" 
	hint="returns language from user IP/http_accept_Language" output="No" returntype="string"> 
	<cfargument name="thisIP" required="Yes" type="string"><!--- this user's IP, cgi.REMOTE_ADDR --->
	<cfargument name="thisLanguage" required="Yes" type="string"><!--- CGI.http_accept_Language --->
	<cfargument name="fallbackLanguage" required="No" type="string" default="en">
	<cfset var foundLanguage="">
	<cfset var aLanguage="">
	<cfif NOT structKeyExists(application,"geoLocatorInit")>
		<cfset isOK=init()>
	</cfif>
	<!--- lets clean up CFML easter egg locales, considering who might be using this cfc --->
	<cfset aLanguage=replaceNoCase(arguments.thisLanguage,"CFML,","","ALL")>
	<cfset aLanguage=replaceNoCase(aLanguage,",CFML","","ALL")>
	<cfset aLanguage=replaceNoCase(aLanguage,",CFML,","","ALL")>
	<cfif len(trim(aLanguage))> <!--- anything left --->
		<cfset foundLanguage=left(listFirst(thisLanguage,","),2)> <!--- lets just grab the first language/locale in the list --->	
	<cfelse> <!--- empty --->
		<cfset thisHost=application.ipAddress.getByname(thisIP)>
		<cfset aLanguage=left(application.geoLocator.getLocale(thisHost),2)>
		<cfif aLanguage EQ "**"> <!--- localhost, IP not in db, etc. --->
			<cfset foundLanguage=arguments.fallbackLanguage> <!--- fall back language --->
		</cfif>
	</cfif>
	<cfreturn foundLanguage>
</cffunction>

<cffunction name="showCountry" access="public" displayname="showCountry" 
	hint="returns full country, localized if available, from user IP" output="No" 
	returntype="string"> 
	<cfargument name="thisIP" required="Yes" type="string"><!--- this user's IP, cgi.REMOTE_ADDR --->
	<cfset var thisHost="">
	<cfset var thisLocale="">
	<cfset var thisL="">
	<cfset var thisC="">
	<cfset var thisCountry="">	
	<cfif NOT structKeyExists(application,"geoLocatorInit")>
		<cfset isOK=init()>
	</cfif>
	<cfset thisHost=application.ipAddress.getByname(arguments.thisIP)>
	<cfset thisLocale=application.geoLocator.getLocale(thisHost)>
	<cfset thisL=left(thisLocale,2)>
	<cfset hisC=uCase(right(thisLocale,2))>
	<cfset thisCountry=application.javaLocale.init(thisL,thisC).getDisplayCountry(thisLocale)>
	<cfreturn thisCountry>
</cffunction>	

<cffunction name="showLanguage" access="public" displayname="showLanguage" 
	hint="returns full language, localized if available, from user IP" output="No" 
	returntype="string"> 
	<cfargument name="thisIP" required="Yes" type="string"><!--- this user's IP, cgi.REMOTE_ADDR --->
	<cfset var thisHost="">
	<cfset var thisLocale="">
	<cfset var thisL="">
	<cfset var thisC="">
	<cfset var thisLanguage="">
	<cfif NOT structKeyExists(application,"geoLocatorInit")>
		<cfset isOK=init()>
	</cfif>
	<cfset thisHost=application.ipAddress.getByname(arguments.thisIP)>
	<cfset thisLocale=application.geoLocator.getLocale(thisHost)>
	<cfset thisL=left(thisLocale,2)>
	<cfset thisC=uCase(right(thisLocale,2))>
	<cfset thisLanguage=application.javaLocale.init(thisL,thisC).getDisplayLanguage(thisLocale)>
	<cfreturn thisLanguage>
</cffunction>	
</cfcomponent>

