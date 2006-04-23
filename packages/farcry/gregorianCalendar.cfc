<cfcomponent displayname="gregorianCalendar" output="no" hint="gregorian calendar functions: version 2.1 may-2004 Paul Hastings (paul@sustainbleGIS.com)">
<!--- 
author:		paul hastings <paul@sustainableGIS.com>
date:		13-may-2004
revisions:
notes:		
			
methods in this CFC:
	- getLocales returns LIST of java style locales (en_US,etc.) available on this server. PUBLIC
	- isValidLocale returns BOOLEAN indicating whether a given locale is valid on this server. should
	be used for locale validation prior to passing to this CFC. takes one required argument, thisLocale,
	string such as "en_US", "th_TH", etc. PUBLIC
	- getServerOffset returns offset in ms from GMT for this server. PRIVATE
	- i18nDateTimeFormat returns formatted date/time string in input locale based on gregorian calendar. 
	required argument is thisDate , a valid date/time object. other non-required arguments:
			--thisLocale locale used to format this datetime string, defaults to en_US
			--thisDateFormat integer value used to indicate the type of date formatting, 0-3, 
			FULL, LONG, MEDIUM, SHORT, defaults to 1 (LONG).
			--thisTimeFormat integer value used to indicate the type of time formatting, 0-3, 
			FULL, LONG, MEDIUM, SHORT, defaults to 1 (LONG).
	this is a PUBLIC method.
	- i18nDateFormat returns formatted date string in input locale based on gregorian calendar. required
	argument is thisDate, a valid date/time object . other non-required arguments:
			--thisLocale locale used to format this datetime string, defaults to en_US
			--thisDateFormat integer value used to indicate the type of date formatting, 0-3, 
			FULL, LONG, MEDIUM, SHORT, defaults to 1 (LONG).
	this is a PUBLIC method.		
	- i18nTimeFormat returns formatted time string in input locale based on gregorian calendar. required
	argument is thisDate, a valid date/time object . other non-required arguments:
			--thisTZOffset timezone offset in hours, defaults to server offset
			--thisLocale locale used to format this datetime string, defaults to en_US
			--thisTimeFormat integer value used to indicate the type of time formatting, 0-3, 
			FULL, LONG, MEDIUM, SHORT, defaults to 1 (LONG).
	this is a PUBLIC method.	
	- i18nDateParse parses a date string formatted	FULL,LONG,MEDIUM,SHORT style into a valid date object.
	required arguments are thisDate holding the formatted date string, thisLocale indicating the locale
	for this date string. PUBLIC
	- getLocaleName returns name of a given locale, localized if available. required argument is 
	thisLocale, string.PUBLIC
	- i18nIsLeapYear returns true or false if given years is a leap year. required argument thisYear integer.
	PUBLIC	
	- i18nIsWeekend returns true or false if given date falls on a weekend according to gregorian calendar. 
	required argument thisDate valid dateTime object. PUBLIC	
	- getCalendarName returns calendar name, localized if it exists. required argument is thisLocale,
	string such as "en_US", "th_TH", etc. PUBLIC
	- weekStarts return first day of week for this calendar, this locale. required argument is 
	thisLocale, string such as "en_US", "th_TH", etc. PUBLIC	
	- isBefore returns boolean indicating whether a date is before another date by this calendar. 
	required arguments are thisDate and when, both dates .  returns true if argument when is 
	before argument thisDate. PUBLIC
	- isAfter returns boolean indicating whether a date is after another date by this calendar. 
	required arguments are thisDate and when, both dates .  returns true if argument when is 
	after argument thisDate. PUBLIC	
	- i18nDaysInMonth returns number of days in given month. required argument is thisDate, valid date
	. PUBLIC
	- i18nDayOfWeek returns day of week for given date. required argument is thisDate, valid date. PUBLIC
	- is24HourFormat returns 0 if not 24 hour timeformat, 1 if 24 hour timeformat (0-23 style), 2 if 
	24 hour timeformat (0-24 style). required argument is thisLocale, vald java style locale.
	- getEras returns locale based era (AH, AD, BC, etc.). required argument is thisLocale, java style
	locale. PUBLIC
	- getMonths returns array of localized month names for this calendar. required argument is thisLocale, 
	java style locale. PUBLIC
	- getShortMonths  returns array of localized short month names for this calendar. required argument 
	is thisLocale, java style locale. PUBLIC
	- getWeekDays  returns array of localized day names for this calendar. required argument is 
	thisLocale, java style locale. optional argument is calendarOrder boolean, determines if array is 
	ordered by calendar (locale dependent) or by normalized java days (week starts on sunday), default 
	is true. PUBLIC
	- getShortWeekDays returns array of localized short day names for this calendar. required argument is 
	thisLocale, java style locale. optional argument is calendarOrder boolean, determines if array is 
	ordered by calendar (locale dependent) or by normalized java days (week starts on sunday), default 
	is true. PUBLIC	
	- getTimeSpan returns array of localized timespan (0-23, 1-12am/pm). required argument is thisLocale,
	valid java locale. PUBLIC
	- getMaxDay returns maximum days in any month. PUBLIC	
	- getYear returns this calendar year, required argument is thisYear, gregorian calendar year. PUBLIC	
	- getDaysInMonth returns array containing maximum number of days per month in this calendar. PUBLIC	
	- isDayFirstFormat determines if given locale uses day-month or month-day format. required argument
	is thisLocale, java style locale. PUBLIC
	- monthDayFormat formats a month/day or day/month string depending on passed locale. required arguments
	are thisDate, valid datetime object and thisLocale valid java style locale. PUBLIC
	- dayFormat formats a day string depending on passed locale. required arguments are thisDate, valid
	dateTime object, thisLocale valid java style locale. optional argument is application.longFormat boolean, if 
	true returns full weekday name. defaults to false. PUBLIC
	- monthFormat formats a month string depending on passed locale. required arguments are thisDate, 
	valid dateTime object, thisLocale valid java style locale. optional argument is application.longFormat boolean,
	if true returns full month name. defaults to true. PUBLIC
--->
<cfscript>
	// working objects
	aCalendar = createObject("java","java.util.GregorianCalendar");
	aLocale = createObject("java","java.util.Locale");
	dateSymbols=createObject("java","java.text.DateFormatSymbols");
	aDateFormat = createObject("java","java.text.DateFormat");
	utcTZ=createObject("java","java.util.TimeZone").getTimeZone("UTC");
	// defaults
	eraField=0;
	yearField=1;
	monthField=2;
	WOYfield=3;  //week of year
	WOMField=4;  //week of month
	dateField=5; //day of month
	DOMfield=5;	 //day of month
	DOYfield=6;	 //day of year
	DOWfield=7;	 //day of week
	DOWMfield=8; // day of week in month
	hourField=10; 
	minuteField=12;
	secondField=13;
	weekdayField=0;
	weekendField=1;
	// weekdays are fixed across all calendars
	SUNDAY=1;
	MONDAY=2;
	TUESDAY=3;
	WEDNESDAY=4;
	THURSDAY=5;
	FRIDAY=6;
	SATURDAY=7; 	
</cfscript> 

<cffunction access="public" name="getLocales" output="No" returntype="string">
	<cfscript>
		var orgLocales="";
		var theseLocales="";	
		orgLocales = aLocale.getAvailableLocales();
		for (i=1; i LTE arrayLen(orgLocales); i=i+1) {
			if (listLen(orgLocales[i],"_") GT 1) {
			listAppend(theseLocales,orgLocales[i]);
			} // if locale more than language
		} //for
		return theseLocales;	
	</cfscript>
</cffunction> 

<cffunction access="public" name="isValidLocale" output="No" returntype="boolean">
<cfargument name="thisLocale" required="yes" type="string">
	<cfset var isOK=false>
	<cfif listFind(getLocales(),arguments.thisLocale)>
		<cfset isOK=true>
	</cfif>
	<cfreturn isOK>
</cffunction> 

<cffunction name="getServerOffset" access="private" output="No" returntype="numeric" 
	hint="returns server TZ offset in ms">
	<cfscript>
	  	var tzInfo="";
		tzInfo=GetTimeZoneInfo(); // get from server
		return (tzInfo.utcHourOffset*60*60*1000)+(tzInfo.utcMinuteOffset*60*1000);
	</cfscript>
</cffunction> 

<cffunction access="public" name="i18nDateTimeFormat" output="No" returntype="string"> 
<cfargument name="thisDate" required="yes" type="date">
<cfargument name="thisLocale" required="no" type="string" default="en_US">
<cfargument name="thisDateFormat" default="1" required="No" type="numeric">
<cfargument name="thisTimeFormat" default="1" required="No" type="numeric">
	<cfscript>
		var tDateFormat=javacast("int",arguments.thisDateFormat);
		var tTimeFormat=javacast("int",arguments.thisTimeFormat);
		var iLocale=aLocale.init(listFirst(arguments.thisLocale,"_"),listLast(arguments.thisLocale,"_"));	
		return aDateFormat.getDateTimeInstance(tDateFormat,tTimeFormat,iLocale).format(arguments.thisDate);
	</cfscript>
</cffunction>

<cffunction access="public" name="i18nDateFormat" output="No" returntype="string"> 
<cfargument name="thisDate" required="yes" type="date">
<cfargument name="thisLocale" required="no" type="string" default="en_US">
<cfargument name="thisDateFormat" default="1" required="No" type="numeric">
	<cfscript>
		var tDateFormat=javacast("int",arguments.thisDateFormat);
		var iLocale=aLocale.init(listFirst(arguments.thisLocale,"_"),listLast(arguments.thisLocale,"_"));
		return aDateFormat.getDateInstance(tDateFormat,iLocale).format(arguments.thisDate);
	</cfscript>
</cffunction>

<cffunction access="public" name="i18nTimeFormat" output="No" returntype="string"> 
<cfargument name="thisDate" required="yes" type="date">
<cfargument name="thisLocale" required="no" type="string" default="en_US">
<cfargument name="thisTimeFormat" default="1" required="No" type="numeric">
	<cfscript>
		var aTimeFormat=javacast("int",arguments.thisTimeFormat);
		var iLocale=aLocale.init(listFirst(arguments.thisLocale,"_"),listLast(arguments.thisLocale,"_"));
		return aDateFormat.getTimeInstance(aTimeFormat,iLocale).format(arguments.thisDate);
	</cfscript>
</cffunction>

<cffunction access="public" name="i18nDateParse" output="No" returntype="date"> 
<cfargument name="thisDate" required="yes" type="string">
<cfargument name="thisLocale" required="yes" type="string">
	<cfscript>
		var isOk=false;
		var parsedDate="";
		var iLocale=aLocale.init(listFirst(arguments.thisLocale,"_"),listLast(arguments.thisLocale,"_"));
		// holy cow batman, can't parse dates in an elegant way. bash! pow! socko!
		// FULL
		try {
			isOK=true;
			parsedDate=aDateFormat.getDateInstance(0,iLocale).parse(arguments.thisDate);
		}
		catch (any errmsg) {
			isOK=false;
		}
		if (NOT isOK) {
		// LONG
		try {
			isOK=true;
			parsedDate=aDateFormat.getDateInstance(1,iLocale).parse(arguments.thisDate);
		}
		catch (any errmsg) {
			isOK=false;
		}
		}
		if (NOT isOK) {
		// MEDIUM
		try {
			isOK=true;
			parsedDate=aDateFormat.getDateInstance(2,iLocale).parse(arguments.thisDate);
		}
		catch (any errmsg) {
			isOK=false;
			}
		}
		// SHORT
		if (NOT isOK) {
		try {
			isOK=true;
			parsedDate=aDateFormat.getDateInstance(3,iLocale).parse(arguments.thisDate);
		}
		catch (any errmsg) {
			isOK=false;
		}
		}
		return parsedDate;
	</cfscript>
</cffunction>

<cffunction access="public" name="i18nIsLeapYear" output="No" returntype="boolean"> 
<cfargument name="thisYear" required="yes" type="numeric">
	<cfscript>
		return aCalendar.isLeapYear(arguments.thisYear);
	</cfscript>
</cffunction>

<cffunction access="public" name="i18nIsWeekend" output="No" returntype="boolean"> 
<cfargument name="thisDate" required="yes" type="date">
	<cfscript>
		return (dayofWeek(arguments.thisDate) EQ 1 OR dayofWeek(arguments.thisDate) EQ 7);
	</cfscript>
</cffunction>

<cffunction access="public" name="getLocaleName" output="No" returntype="string">
<cfargument name="thisLocale" required="yes" type="string">
	<cfset var iLocale=aLocale.init(listFirst(arguments.thisLocale,"_"),listLast(arguments.thisLocale,"_"))>
	<cfreturn iLocale.getDisplayname()>
</cffunction> 

<cffunction access="public" name="getCalendarName" output="No" returntype="string">
<cfargument name="thisLocale" required="yes" type="string">
	<cfreturn "java.util.GregorianCalendar">
</cffunction> 

<cffunction access="public" name="isBefore" output="No" returntype="boolean">
<cfargument name="thisDate" required="yes" type="date">
<cfargument name="when" required="yes" type="date">
<cfargument name="thisLocale" required="yes" type="string">
	<cfset var locale=aLocale.init(listFirst(arguments.thisLocale,"_"),listLast(arguments.thisLocale,"_"))>
	<cfset var tCalendar=aCalendar.init(locale)>
	<cfset tCalendar.setTime(arguments.thisDate)>
	<cfreturn tCalendar.before(arguments.when)>
</cffunction>  

<cffunction access="public" name="isAfter" output="No" returntype="boolean">
<cfargument name="thisDate" required="yes" type="date">
<cfargument name="when" required="yes" type="date">
<cfargument name="thisLocale" required="yes" type="string">
	<cfset var locale=aLocale.init(listFirst(arguments.thisLocale,"_"),listLast(arguments.thisLocale,"_"))>
 	<cfset var tCalendar=aCalendar.init(locale)>
	<cfset tCalendar.setTime(arguments.thisDate)>
	<cfreturn tCalendar.after(arguments.when)>
</cffunction>  

<cffunction access="public" name="i18nDaysInMonth" output="No" returntype="numeric">
<cfargument name="thisDate" required="yes" type="date">
<cfargument name="thisLocale" required="yes" type="string">
	<cfset var locale=aLocale.init(listFirst(arguments.thisLocale,"_"),listLast(arguments.thisLocale,"_"))>
	<cfset var tCalendar=aCalendar.init(locale)>
	<cfset tCalendar.setTime(arguments.thisDate)>
	<cfreturn tCalendar.getActualMaximum(tCalendar.DAY_OF_MONTH)>
</cffunction>  

<cffunction access="public" name="i18nDayofWeek" output="No" returntype="numeric">
<cfargument name="thisDate" required="yes" type="date">
<cfargument name="thisLocale" required="yes" type="string">
	<cfset var locale=aLocale.init(listFirst(arguments.thisLocale,"_"),listLast(arguments.thisLocale,"_"))>
	<cfset var tCalendar=aCalendar.init(locale)>
	<cfset tCalendar.setTime(arguments.thisDate)>
	<cfreturn tCalendar.get(tCalendar.DAY_OF_WEEK)>
</cffunction>  

<cffunction access="public" name="getWeekDays" output="No" returntype="array" 
	hint="returns day names for this calendar">
<cfargument name="thisLocale" required="yes" type="string">
<cfargument name="calendarOrder" required="no" type="boolean" default="true">
	<cfset var locale=aLocale.init(listFirst(arguments.thisLocale,"_"),listLast(arguments.thisLocale,"_"))>
	<cfset var theseDateSymbols=dateSymbols.init(locale)>
	<cfset var localeDays="">
	<cfset var i=0>
	<cfset var tmp=listToArray(arrayToList(theseDateSymbols.getWeekDays()))>
	<!--- return days in java (start sunday) or calendar order (start saturday) --->	
	<cfif NOT arguments.calendarOrder>
		<cfreturn tmp>
	<cfelse>
		<cfswitch expression="#weekStarts(arguments.thisLocale)#">
		<cfcase value="1"> <!--- "standard" dates --->
			<cfreturn tmp>
		</cfcase>
		<cfcase value="2"> <!--- euro dates, starts on monday needs kludge --->
			<cfset localeDays=arrayNew(1)>
			<cfset localeDays[7]=tmp[1]>; <!--- move sunday to last --->
			<cfloop index="i" from="1" to="6">
				<cfset localeDays[i]=tmp[i+1]>
			</cfloop>
			<cfreturn localeDays>
		</cfcase>
		<cfcase value="7"> <!--- starts saturday, usually arabic, needs kludge --->
			<cfset localeDays=arrayNew(1)>
			<cfset localeDays[1]=tmp[7]> <!--- move saturday to first --->
			<cfloop index="i" from="1" to="6">
				<cfset localeDays[i+1]=tmp[i]>
			</cfloop>
			<cfreturn localeDays>
		</cfcase>
		</cfswitch>
	</cfif>
</cffunction> 

<cffunction access="public" name="getShortWeekDays" output="No" returntype="array" 
	hint="returns short day names for this calendar">
<cfargument name="thisLocale" required="yes" type="string">
<cfargument name="calendarOrder" required="no" type="boolean" default="true">
	<cfset var locale=aLocale.init(listFirst(arguments.thisLocale,"_"),listLast(arguments.thisLocale,"_"))>
	<cfset var theseDateSymbols=dateSymbols.init(locale)>
	<cfset var localeDays="">
	<cfset var i=0>
	<cfset var tmp=listToArray(arrayToList(theseDateSymbols.getShortWeekDays()))>
	<cfif NOT arguments.calendarOrder>
		<cfreturn tmp>
	<cfelse>
		<cfswitch expression="#weekStarts(arguments.thisLocale)#">
		<cfcase value="1"> <!--- "standard" dates --->
			<cfreturn tmp>
		</cfcase>
		<cfcase value="2"> <!--- euro dates, starts on monday needs kludge --->
			<cfset localeDays=arrayNew(1)>
			<cfset localeDays[7]=tmp[1]>; <!--- move sunday to last --->
			<cfloop index="i" from="1" to="6">
				<cfset localeDays[i]=tmp[i+1]>
			</cfloop>
			<cfreturn localeDays>
		</cfcase>
		<cfcase value="7"> <!--- starts saturday, usually arabic, needs kludge --->
			<cfset localeDays=arrayNew(1)>
			<cfset localeDays[1]=tmp[7]> <!--- move saturday to first --->
			<cfloop index="i" from="1" to="6">
				<cfset localeDays[i+1]=tmp[i]>
			</cfloop>
			<cfreturn localeDays>
		</cfcase>
		</cfswitch>
	</cfif>
</cffunction> 

<cffunction access="public" name="getMonths" output="No" returntype="array" 
	hint="returns month names for this calendar">
<cfargument name="thisLocale" required="yes" type="string">
	<cfset var locale=aLocale.init(listFirst(arguments.thisLocale,"_"),listLast(arguments.thisLocale,"_"))>
	<cfset var theseDateSymbols=dateSymbols.init(locale)>
	<cfreturn theseDateSymbols.getMonths()>
</cffunction> 

<cffunction access="public" name="getShortMonths" output="No" returntype="array" 
	hint="returns abbrev month names for this calendar">
<cfargument name="thisLocale" required="yes" type="string">
	<cfset var locale=aLocale.init(listFirst(arguments.thisLocale,"_"),listLast(arguments.thisLocale,"_"))>
	<cfset var theseDateSymbols=dateSymbols.init(locale)>
	<cfreturn theseDateSymbols.getShortMonths()>
</cffunction> 

<cffunction access="public" name="getEras" output="No" returntype="array" 
	hint="returns era names for this calendar">
<cfargument name="thisLocale" required="yes" type="string">
	<cfset var locale=aLocale.init(listFirst(arguments.thisLocale,"_"),listLast(arguments.thisLocale,"_"))>
	<cfset var theseDateSymbols=dateSymbols.init(locale)>
	<cfreturn theseDateSymbols.getEras()>
</cffunction> 

<!--- really varies locale to locale --->
<cffunction access="public" name="weekStarts" output="No" returntype="numeric" 
	hint="returns DOY (1-7) that this locale's week starts">
<cfargument name="thisLocale" required="yes" type="string">
	<cfset var locale=aLocale.init(listFirst(arguments.thisLocale,"_"),listLast(arguments.thisLocale,"_"))>
	<cfset var tCalendar=aCalendar.init(locale)>
	<cfreturn tCalendar.getFirstDayOfWeek()>
</cffunction> 

<cffunction access="public" name="is24HourFormat" output="No" returntype="numeric" 
	hint="determines if given locale use military sytle 24 hour timeformat & which format it uses returns 0 if not 24 hour timeformat, 1 if timeformat is 0-23 and 2 if 0-24">
<cfargument name="thisLocale" required="yes" type="string">
	<cfset var locale=aLocale.init(listFirst(arguments.thisLocale,"_"),listLast(arguments.thisLocale,"_"))>
	<cfset var localTF=aDateFormat.getTimeInstance(aDateFormat.SHORT,locale).toPattern()>
	<!--- CASE senstive --->
	<cfif find("H",localTF,1)>
		<cfreturn 1> <!--- 0-23 --->
	<cfelseif find("k",localTF,1)>	
		<cfreturn 2> <!--- 0-24 --->
	<cfelse>
		<cfreturn 0> <!--- not 24 hour format --->
	</cfif>
</cffunction> 

<cffunction access="public" name="getTimeSpan" output="No" returntype="array" 
hint="returns array of localized timespan (0-23, 1-12am/pm)">
<cfargument name="thisLocale" required="yes" type="string">
<cfscript>
	var i=0;
	var localeTS=arrayNew(1);
	for (i=0; i lte 23; i=i+1) {
		arrayAppend(localeTS,i18nTimeFormat(createDateTime(year(now()),month(now()),day(now()),#i#,0,0),arguments.thisLocale,3));
	}
	return localeTS;
</cfscript>
</cffunction>  

<cffunction access="public" name="getMaxDay" output="No" returntype="numeric"
hint="returns maximum number of days in any month per calendar">
	<cfreturn aCalendar.getMaximum(DOMfield)>
</cffunction>  

<cffunction access="public" name="getYear" output="No" returntype="numeric"
hint="returns this calendar year">
<cfargument name="thisYear" required="yes" type="numeric">
	<cfscript>
		return arguments.thisYear;
	</cfscript>
</cffunction>  

<cffunction access="public" name="getDaysInMonth" output="No" returntype="array"
hint="returns array containing maximum number of days per month in this calendar">
<cfscript>
	var i=0;
	var t="";
	var days=arrayNew(1);
	var tCalendar=aCalendar;
	for (i=1; i LTE 12; i=i+1) {
		t=createDate(year(now()),i,1);
		tCalendar.setTime(t);
		arrayAppend(days,tCalendar.getActualMaximum(DOMfield));
	}
	return days;
</cfscript>
</cffunction>  

<cffunction access="public" name="isDayFirstFormat" output="No" returntype="boolean" 
	hint="determines if given locale uses day-month or month-day format">
<cfargument name="thisLocale" required="yes" type="string">
	<cfset var locale=aLocale.init(listFirst(arguments.thisLocale,"_"),listLast(arguments.thisLocale,"_"))>
	<cfset var dF=left(aDateFormat.getDateInstance(aDateFormat.SHORT,alocale).toPattern(),1)>
	<cfif dF EQ "d">
		<cfreturn true>
	<cfelse>
		<cfreturn false>
	</cfif>
</cffunction>

<cffunction access="public" name="monthDayFormat" output="No" returntype="string" 
	hint="formats a month/day or day/month string depending on passed locale">
<cfargument name="thisDate" required="yes" type="date">	
<cfargument name="thisLocale" required="yes" type="string">
<cfscript>
	var locale=aLocale.init(listFirst(arguments.thisLocale,"_"),listLast(arguments.thisLocale,"_"));
	var sDF=createObject("java","java.text.SimpleDateFormat");
	if (isDayFirstFormat(arguments.thisLocale))
		return sDF.init("d MMMM",locale).format(arguments.thisDate);
	else
		return sDF.init("MMMM d",locale).format(arguments.thisDate);
</cfscript>
</cffunction>

<cffunction access="public" name="dayFormat" output="No" returntype="string" 
	hint="formats a day string depending on passed locale">
<cfargument name="thisDate" required="yes" type="date">	
<cfargument name="thisLocale" required="yes" type="string">
<cfargument name="longFormat" required="No" default="false"> 
<cfscript>
	var locale=aLocale.init(listFirst(arguments.thisLocale,"_"),listLast(arguments.thisLocale,"_"));
	var sDF=createObject("java","java.text.SimpleDateFormat");
	if (arguments.longFormat)
		return sDF.init("EEEE",locale).format(arguments.thisDate);
	else
		return sDF.init("E",locale).format(arguments.thisDate);
</cfscript>
</cffunction>

<cffunction access="public" name="monthFormat" output="No" returntype="string" 
	hint="formats a month string depending on passed locale">
<cfargument name="thisDate" required="yes" type="date">	
<cfargument name="thisLocale" required="yes" type="string">
<cfargument name="longFormat" required="No" default="true"> 
<cfscript>
	var locale=aLocale.init(listFirst(arguments.thisLocale,"_"),listLast(arguments.thisLocale,"_"));
	var sDF=createObject("java","java.text.SimpleDateFormat");
	if (arguments.longFormat)
		return sDF.init("MMMM",locale).format(arguments.thisDate);
	else
		return sDF.init("MMM",locale).format(arguments.thisDate);
</cfscript>
</cffunction>

</cfcomponent>
