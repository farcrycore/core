<!--- @@Copyright: Copyright (c) 2009 Rob Rohan. All rights reserved. --->
<!--- @@displayname:  --->
<!--- @@description: typesTest --->

<cfcomponent extends="mxunit.framework.TestCase">
	<!--- setup and teardown --->
	<cffunction name="setUp" returntype="void" access="public">
		<!--- Any code needed to return your environment to normal goes here --->
		<cfset this.myComp = createObject("component", "farcry.core.packages.types.types") />
	</cffunction>

	<cffunction name="tearDown" returntype="void" access="public">
		<!--- Any code needed to return your environment to normal goes here --->
	</cffunction>
	
	<!--- ////////////////////////////////////////////////////////////////// --->
	
	<cffunction name="showFarcryDateTestEmptyString" returntype="void" access="public">
		<cfset assertEquals(
			this.myComp.showFarcryDate(""), 
			false
		) />
	</cffunction>
	
	<cffunction name="showFarcryDateTestNow" returntype="void" access="public">
		<cfset assertEquals(
			this.myComp.showFarcryDate(now()), 
			true
		) />
	</cffunction>
	
	<cffunction name="showFarcryDateTest100Years" returntype="void" access="public">
		<cfset assertEquals(
			this.myComp.showFarcryDate( dateAdd("yyyy", 100, now()) ), 
			true
		) />
	</cffunction>
	
	<cffunction name="showFarcryDateTest101Years" returntype="void" access="public">
		<cfset assertEquals(
			this.myComp.showFarcryDate( dateAdd("yyyy", 101, now()) ), 
			false
		) />
	</cffunction>
	
	<cffunction name="showFarcryDateTest2050" returntype="void" access="public">
		<cfset assertEquals(
			this.myComp.showFarcryDate( createDate(2050,1,1) ), 
			false
		) />
	</cffunction>
	
	<cffunction name="showFarcryDateTest2051" returntype="void" access="public">
		<cfset assertEquals(
			this.myComp.showFarcryDate( createDate(2051,1,1) ), 
			true
		) />
	</cffunction>
	
</cfcomponent>