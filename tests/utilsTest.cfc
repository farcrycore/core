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

	<cffunction name="generateRandomStringTest" access="public">
		<cfset var testObject = CreateObject("component","farcry.core.packages.farcry.utils").init() />
		<cfset var aRandomString = ArrayNew(1) />
		<cfset var randomString = "" />
		<cfset var expectedRandomStringLen = 40 />
		<cfset var i = 0 />
		<cfset var sampleCharPos = 0 />
		<cfset var sampleCharLen = 5 />
		<cfset var strNum1 = 0 />
		<cfset var strNum2 = 0 />
		
		<!---
			Any test of the randomness of a function is inherently non-deterministic.
			That is, even if the function is truly random, there is a chance that the test will fail.
			
			The probability of a truly random hexadecimal string generator failing a single run of this test is about 1.5%
				(the calculation of this probability is left as an exercise for the reader).
			The probability of a padded UUID generator failing a single run of this test is likely to be over 90%
				(in one sample of 40 test runs against a padded CreateUUID(), all 40 tests failed).
		--->
		
		<!--- Generate a series of random strings --->
		<cfloop index="i" from="1" to="100">
			<cfset aRandomString[i] = testObject.generateRandomString() />
			<cfset assertEquals(expectedRandomStringLen,Len(aRandomString[i]),"Len(aRandomString[#i#])") />
			<cfset debug(aRandomString[i]) />
		</cfloop>
		
		<!--- Simple randomised testing of the series to find similarities in pairs of substrings --->
		<cfloop index="i" from="1" to="1000">
			<!--- Select a random pair of strings in the array --->
			<cfset strNum1 = RandRange(1,99) />
			<cfset strNum2 = RandRange(strNum1+1,100) />
			
			<!--- Select a random position for a sample --->
			<cfset sampleCharPos = RandRange(1,expectedRandomStringLen - sampleCharLen) />
			
			<!--- Check that the same sample substring in each of the selected strings are not equal --->
			<cfset assertTrue(Mid(aRandomString[strNum1],sampleCharPos,sampleCharLen) neq Mid(aRandomString[strNum2],sampleCharPos,sampleCharLen),
					"Random test #i# failed: string #strNum1# [#aRandomString[strNum1]#] vs string #strNum2# [#aRandomString[strNum2]# position #sampleCharPos#]") />
		</cfloop>
		
	</cffunction>

	<cffunction name="isGeneratedRandomStringTest" access="public">
		<cfset var testObject = CreateObject("component","farcry.core.packages.farcry.utils").init() />
		
		<cfset assertFalse(testObject.isGeneratedRandomString("This Isnt A GeneratedRandomString String"), "Non-hexadecimal string") />
		<cfset assertFalse(testObject.isGeneratedRandomString("0718E7431C16D4F8A447CB14D8DCB365734"), "String too short") />
		<cfset assertFalse(testObject.isGeneratedRandomString("0718E7431C16D4F8A447CB14D8DCB3657341379DBCD18FEA742"), "String too long") />
		<cfset assertTrue( testObject.isGeneratedRandomString("0718E7431C16D4F8A447CB14D8DCB36573406D8C"), "Correct length hexadecimal string") />
	</cffunction>

</cfcomponent>