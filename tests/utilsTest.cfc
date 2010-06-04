<!--- @@Copyright: Copyright (c) 2009 Rob Rohan. All rights reserved. --->
<!--- @@displayname: fapiTest.cfc --->
<!--- @@description: 
	This file holds all the tests for the Utils API in FarCry. 
	WARNING: this file requires it be opened and saved in
	UTF-8.  There are characters in this file that require UTF-8 
	encoding.  Please ensure you are opening and saving this file in UTF-8 
	or tests will start to fail and will need to be re-written using the 
	correct encoding.  
	
	On Windows UTF-8 is not the default. If you are using Eclipse please
	right click on the file and make sure the encoding is UTF-8.  If this
	doesn't look like Chinese:
		这个我的猴子！那个我的帽子！我写得津津有味！
	Then you are not using UTF-8.
--->
<cfcomponent extends="mxunit.framework.TestCase" displayname="Utils Tests">
	<!--- setup and teardown --->
	<cffunction name="setUp" returntype="void" access="public">
		<!--- Any code needed to return your environment to normal goes here --->
	</cffunction>

	<cffunction name="tearDown" returntype="void" access="public">
		<!--- Any code needed to return your environment to normal goes here --->
		
	</cffunction>
	
	<!--- ////////////////////////////////////////////////////////////////// --->
	
	<cffunction name="arrayFromStringCommands_Blank_Test" access="public">
		<cfset assertEquals(
							application.fc.utils.arrayFromStringCommands("", ""),
							arraynew(1)) />
	</cffunction>
	
	<cffunction name="arrayFromStringCommands_MinusAsterisk_Test" access="public">
		<cfset assertEquals(
							application.fc.utils.arrayFromStringCommands("one,two,three,four", "-*"),
							arraynew(1)) />
	</cffunction>
	
	<cffunction name="arrayFromStringCommands_AsteriskMinus_Test" access="public">
		<cfset assertEquals(
							application.fc.utils.arrayFromStringCommands("one,two,three,four", "*:-four"),
							listtoarray("one,two,three")) />
	</cffunction>
	
	<cffunction name="arrayFromStringCommands_AsteriskPlus_Test" access="public">
		<cfset assertEquals(
							application.fc.utils.arrayFromStringCommands("one,two,three,four", "*:+five"),
							listtoarray("one,two,three,four,five")) />
	</cffunction>
	
	<cffunction name="arrayFromStringCommands_Plus_Test" access="public">
		<cfset assertEquals(
							application.fc.utils.arrayFromStringCommands("one,two,three,four", "+five"),
							listtoarray("one,two,three,four,five")) />
	</cffunction>
	
	<cffunction name="arrayFromStringCommands_AsteriskPlusMinus_Test" access="public">
		<cfset assertEquals(
							application.fc.utils.arrayFromStringCommands("one,two,three,four", "*:+five:-one"),
							listtoarray("two,three,four,five")) />
	</cffunction>
	
	<cffunction name="arrayFromStringCommands_AsteriskPlusListMinusList_Test" access="public">
		<cfset assertEquals(
							application.fc.utils.arrayFromStringCommands(
																		 "one,two,three,four", 
																		 "*:+five,six,seven:-one,four,three"),
							listtoarray("two,five,six,seven")) />
	</cffunction>
	
	<!--- ////////////////////////////////////////////////////////////////// --->
	
</cfcomponent>