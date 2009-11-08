<cfcomponent displayname="timezone" hint="various timezone functions not included in mx: version 2.1 jul-2005 Paul Hastings (paul@sustainbleGIS.com)" output="No">
<!---
author:		paul hastings <paul@sustainableGIS.com>
date:		11-sep-2003
revisions:
			23-oct-2003 changed to use argument dates rather than setting calendar time, forgot that
			java MONTH start with zero. kept gregorian calendar object for timezone offset in order to
			use DST_OFFSET field in calendar object.
			8-nov-2003 added castToUTC, castFromUTC to support Ray Camden's blog i18n, added castToServer
			and castFromServer at user request.
			14-feb-2005 reworked castToUTC, castFromUTC to not use gregorian calendar class,
			added init().
			16-feb-2005 fixed java/cf date bug in cast to/from functions
			6-aug-2005 fixed bug in to/from UTC methods, was using decimals hours for tz
			offsetsbut cf's dateAdd function only takes integers. thanks to Behrang Noroozinia
			<behrang@khorshidchehr.com> for finding that bug.
			30-mar-2006 added two methods (getServerTZShort,getServerId) contributed by dan
			switzer: dswitzer@pengoworks.com

notes:		this cfc contains methods to handle some timezone functionality not in cfmx as well as when
			you need to "cast" to a specific timezone (cf's timezone functions are tied to server). it
			requires the use of createObject.

methods in this CFC:
			- isDST determines if a given date & timezone are in DST. if no date or timezone is passed
			the method defaults to current date/time and server timezone. PUBLIC.
			- getAvailableTZ returns an array of available timezones on this server (ie according to
			server's JVM). PUBLIC.
			- isValidTZ determines if a given timezone is valid according to getAvailableTZ. PUBLIC.
			- usesDST determines if a given timezone uses DST. PUBLIC.
			- getRawOffset returns the raw (as opposed to DST) offset in hours for a given timezone.
			PUBLIC.
			- getTZOffset returns offset in hours for a given date/time & timezone, uses DST if timezone
			uses and is currently in DST. returns -999 if bad date or bad timezone. PUBLIC.
			- getDST returns DST savings for given timezone. returns -999 for bad timezone. PUBLIC.
			- castToUTC return UTC from given datetime in given timezone. required argument thisDate,
			optional argument thisTZ valid timezone ID, defaults to server timezone. PUBLIC.
			- castfromUTC return date in given timezone from UTC datetime. required argument thisDate,
			optional argument thisTZ valid timezone ID, defaults to server timezone. PUBLIC.
			- castToServer returns server datetime from given datetime in given timezone. required argument
			thisDate valid datetime, optional argument thisTZ valid timezone ID, defaults to server
			timezone. PUBLIC.
			- castfromServer return datetime in given timezone from server datetime. required argument
			thisDate valdi datetime, optional argument thisTZ valid timezone ID, defaults to server
			timezone. PUBLIC.
			- getServerTZ returns server timezone. PUBLIC
			- getServerTZShort returns "short" name for the server's timezone. PUBLIC
			- getServerId returns ID for the server's timezone. PUBLIC
			
LICENSE 

Copyright 2007 Paul Hastings

   Licensed under the Apache License, Version 2.0 (the "License");

   you may not use this file except in compliance with the License.

   You may obtain a copy of the License at



       http://www.apache.org/licenses/LICENSE-2.0



   Unless required by applicable law or agreed to in writing, software

   distributed under the License is distributed on an "AS IS" BASIS,

   WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.

   See the License for the specific language governing permissions and

   limitations under the License.

===   

If you like, you can find my wishlist at 

http://www.amazon.com/gp/registry/wishlist/35SOQPL36CP87/104-4400936-8795966

 --->

	<!--- the time zone object itself --->
	<cfset variables.tzObj = createObject("java","java.util.TimeZone")>
	<!--- list of all available timezone ids --->
	<cfset variables.tzList = listsort(arrayToList(variables.tzObj.getAvailableIDs()), "textnocase")>
	<!--- default timezone on the server --->
	<cfset variables.mytz = variables.tzObj.getDefault().ID>


	<!--- init --->
	<cffunction name="init" output="false" access="public" returntype="Any">
		<cfreturn this>
	</cffunction>


	<!--- isValidTZ --->
	<cffunction name="isValidTZ" output="false" returntype="boolean" access="public"
				hint="validates if a given timezone is in list of timezones available on this server">
		<cfargument name="tz" required="false" default="#variables.mytz#">
		<cfreturn IIF(listFindNoCase(variables.tzList,arguments.tz), true, false)>
	</cffunction>


	<!--- isDST --->
	<cffunction name="isDST" output="false" returntype="boolean" access="public"
				hint="determines if a given date in a given timezone is in DST">
		<cfargument name="dateToTest" required="false" type="date" default="#now()#">
		<cfargument name="tz" required="true" default="#variables.mytz#">
		<cfreturn variables.tzObj.getTimeZone(arguments.tz).inDaylightTime(arguments.dateTotest)>
	</cffunction>


	<!--- getAvailableTZ --->
	<cffunction name="getAvailableTZ" output="false" returntype="array" access="public"
				hint="returns a list of timezones available on this server">
		<cfreturn listToArray(variables.tzList)>
	</cffunction>


	<!--- getTZByOffset --->
	<cffunction name="getTZByOffset" output="false" returntype="array" access="public"
				hint="returns a list of timezones available on this server for a given raw offset">
		<cfargument name="thisOffset" required="true" type="numeric">
		<cfset var rawOffset = javacast("long", arguments.thisOffset * 3600000)>
		<cfreturn variables.tzObj.getAvailableIDs(rawOffset)>
	</cffunction>


	<!--- usesDST --->
	<cffunction name="usesDST" output="false" returntype="boolean" access="public"
				hint="determines if a given timezone uses DST">
		<cfargument name="tz" required="false" default="#variables.mytz#">
		<cfreturn variables.tzObj.getTimeZone(arguments.tz).useDaylightTime()>
	</cffunction>


	<!--- getRawOffset --->
	<cffunction name="getRawOffset" output="false" access="public" returntype="numeric"
				hint="returns rawoffset in hours">
		<cfargument name="tz" required="false" default="#variables.mytz#">
		<cfreturn variables.tzObj.getTimeZone(arguments.tz).getRawOffset() / 3600000>
	</cffunction>


	<!--- getTZOffset --->
	<cffunction name="getTZOffset" output="false" access="public" returntype="numeric"
				hint="returns offset in hours">
		<cfargument name="thisDate" required="no" type="date" default="#now()#">
		<cfargument name="tz" required="false" default="#variables.mytz#">
		<cfset var timezone = variables.tzObj.getTimeZone(arguments.tz)>
		<cfset var tYear = javacast("int", Year(arguments.thisDate))>
		<!--- java months are 0 based --->
		<cfset var tMonth = javacast("int", month(arguments.thisDate)-1)>
		<cfset var tDay = javacast("int", Day(thisDate))>
		<!--- day of week --->
		<cfset var tDOW = javacast("int", DayOfWeek(thisDate))>
		<cfreturn timezone.getOffset(1, tYear, tMonth, tDay, tDOW, 0) / 3600000>
	</cffunction>


	<!--- getDST --->
	<cffunction name="getDST" output="false" access="public" returntype="numeric"
				hint="returns DST savings in hours">
		<cfargument name="tz" required="false" default="#variables.mytz#">
		<cfreturn variables.tzObj.getTimeZone(arguments.tz).getDSTSavings() / 3600000>
	</cffunction>


	<!--- castToUTC --->
	<cffunction name="castToUTC" output="false" access="public" returntype="date"
				hint="returns UTC from given date in given TZ, takes DST into account">
		<cfargument name="thisDate" required="yes" type="date">
		<cfargument name="tz" required="false" default="#variables.mytz#">
		<cfreturn dateAdd("h", -getTZOffset(arguments.thisdate, arguments.tz), arguments.thisDate)>
	</cffunction>


	<!--- castFromUTC --->
	<cffunction name="castFromUTC" output="false" access="public" returntype="date"
				hint="returns date in given TZ from given UTC date, takes DST into account">
		<cfargument name="thisDate" required="yes" type="date">
		<cfargument name="tz" required="false" default="#variables.mytz#">
		<cfreturn dateAdd("h", getTZOffset(arguments.thisdate, arguments.tz), arguments.thisDate)>
	</cffunction>


	<!--- castToServer --->
	<cffunction name="castToServer" output="false" access="public" returntype="date"
				hint="returns server date in given TZ from given UTC date, takes DST into account">
		<cfargument name="thisDate" required="yes" type="date">
		<cfargument name="tz" required="false" default="#variables.mytz#">
		<cfreturn dateConvert("utc2Local",castToUTC(arguments.thisDate, arguments.tz))>
	</cffunction>


	<!--- castFromServer --->
	<cffunction name="castFromServer" output="false" access="public" returntype="date"
				hint="returns date in given TZ from given server date, takes DST into account">
		<cfargument name="thisDate" required="yes" type="date">
		<cfargument name="tz" required="false" default="#variables.mytz#">
		<cfreturn castFromUTC(dateConvert("local2UTC",arguments.thisDate),arguments.tz)>
	</cffunction>


	<!--- getServerTZ --->
	<cffunction name="getServerTZ" output="false" access="public" returntype="string"
				hint="returns server TZ (long)">
		<cfreturn variables.tzObj.getDefault().getDisplayName(true, variables.tzObj.LONG)>
	</cffunction>


	<!--- getServerTZShort --->
	<cffunction name="getServerTZShort" output="false" access="public" returntype="string"
				hint="returns server TZ (short). contributed by dan switzer: dswitzer@pengoworks.com">
		<cfreturn variables.tzObj.getDefault().getDisplayName(true, variables.tzObj.SHORT)>
	</cffunction>


	<!--- getServerId --->
	<cffunction name="getServerId" output="false" access="public" returntype="any"
				hint="returns the server timezone id. contributed by dan switzer: dswitzer@pengoworks.com">
		<cfreturn variables.mytz>
	</cffunction>

</cfcomponent>