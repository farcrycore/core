<!--- @@Copyright: Copyright (c) 2009 Rob Rohan. All rights reserved. --->
<!--- @@displayname:  --->
<!--- @@description: typesTest --->

<cfcomponent extends="mxunit.framework.TestCase">
	<!--- setup and teardown --->
	<cffunction name="setUp" returntype="void" access="public">
		<!--- Any code needed to return your environment to normal goes here --->
		<cfset this.myComp = createObject("component", "farcry.core.packages.farcry.fapi") />
	</cffunction>

	<cffunction name="tearDown" returntype="void" access="public">
		<!--- Any code needed to return your environment to normal goes here --->
	</cffunction>
	
	<!--- ////////////////////////////////////////////////////////////////// --->
	<cffunction name="findTypeTest" access="public">
		<cfset assertEquals(true, false) />
	</cffunction>

	<cffunction name="checkPermissionTest" access="public" hint="Checks the permission against a role. The roles defaults to the currently logged in users assigned roles.">
		<cfset assertEquals(true, false) />
	</cffunction>

	<cffunction name="checkWebskinPermissionTest" access="public" hint="Checks the view can be accessed by the role. The roles defaults to the currently logged in users assigned roles.">
		<cfset assertEquals(true, false) />
	</cffunction>

	<cffunction name="checkTypePermissionTest" access="public" hint="Checks the permission against the type for a given role. The roles defaults to the currently logged in users assigned roles.">
		<cfset assertEquals(true, false) />
	</cffunction>

	<cffunction name="checkObjectPermissionTest" access="public"  hint="Checks the permission against the objectid for a given role. The roles defaults to the currently logged in users assigned roles.">
		<cfset assertEquals(true, false) />
	</cffunction>

	<cffunction name="getConfigTest" access="public" hint="Returns the value of any config item. If no default is sent and the property is not found, an error is thrown.">
		<cfset assertEquals(true, false) />
	</cffunction>

	<cffunction name="throwTest" access="public" hint="Provides similar functionality to the cfthrow tag but is automatically incorporated to use the resource bundles.">
		<cfset assertEquals(true, false) />
	</cffunction>

	<cffunction name="getResourceTest" access="public" hint="Returns the resource string">
		<cfset assertEquals(true, false) />
	</cffunction>

	<cffunction name="checkNavIDTest" access="public" hint="Returns true if the navigation alias is found.">
		<cfset assertEquals(true, false) />
	</cffunction>

	<cffunction name="getNavIDTest" access="public" hint="Returns the objectID of the dmNavigation record for the passed alias. If the alias does not exist, the alternate alias will be used. ">
		<cfset assertEquals(true, false) />
	</cffunction>

	<cffunction name="checkCatIDTest" access="public" hint="Returns true if the category alias is found.">
		<cfset assertEquals(true, false) />
	</cffunction>

	<cffunction name="getCatIDTest" access="public" hint="Returns the objectID of the dmCategory record for the passed alias. If the alias does not exist, the alternate alias will be used. ">
		<cfset assertEquals(true, false) />
	</cffunction>

	<cffunction name="getContentTypeTest" access="public" hint="Returns the an instantiated content type">
		<cfset assertEquals(true, false) />
	</cffunction>

	<cffunction name="getContentObjectTest" access="public" hint="Allows you to fetch a content object with only the objectID">
		<cfset assertEquals(true, false) />
	</cffunction>

	<cffunction name="arrayTest">
		<cfset assertEquals(true, false) />
	</cffunction>

	<cffunction name="getUUIDTest" access="public" hint="">
		<cfset assertEquals(true, false) />
	</cffunction>

	<!--- ARRAY utilities --->
	<cffunction name="arrayFindTest" access="public" hint="Returns the index of the first element that matches the specified value. 0 if not found." >
		<cfset assertEquals(true, false) />
	</cffunction>

	<!--- LIST utilities --->
	<cffunction name="listReverseTest" access="public" hint="Reverses a list">
		<cfset assertEquals(true, false) />
	</cffunction>

	<cffunction name="listDiffTest" access="public" hint="Returns the items in list2 that aren't in list2">
		<cfset assertEquals(true, false) />
	</cffunction>

	<cffunction name="listIntersectionTest" access="public" hint="Returns the items in list2 that are also in list2">
		<cfset assertEquals(true, false) />
	</cffunction>

	<cffunction name="listMergeTest" access="public" hint="Adds items from the second list to the first, where they aren't already present">
		<cfset assertEquals(true, false) />
	</cffunction>

	<cffunction name="listSliceTest" access="public" hint="Returns the specified elements of the list">
		<cfset assertEquals(true, false) />
	</cffunction>

	<cffunction name="listFilterTest" access="public" hint="Filters the items in a list though a regular expression">
		<cfset assertEquals(true, false) />
	</cffunction>

	<cffunction name="listContainsAnyTest" access="public" description="Returns true if the first list contains any of the items in the second list">
		<cfset assertEquals(true, false) />
	</cffunction>

	<cffunction name="listContainsAnyNoCaseTest" access="public" description="Returns true if the first list contains any of the items in the second list">
		<cfset assertEquals(true, false) />
	</cffunction>

	<!--- STRUCT ulilities --->
	<cffunction name="structMergeTest" access="public" hint="Performs a deep merge on two structs">
		<cfset assertEquals(true, false) />
	</cffunction>

	<cffunction name="structCreateTest" access="public" hint="Creates and populates a struct with the provided arguments">
		<cfset assertEquals(true, false) />
	</cffunction>

	<cffunction name="structTest"  access="public" hint="Shortcut for creating structs">
		<cfset assertEquals(true, false) />
	</cffunction>

	<!--- PACKAGE utilities --->
	<cffunction name="getPathTest" access="public" hint="Finds the component in core/plugins/project, and returns its path">
		<cfset assertEquals(true, false) />
	</cffunction>

	<cffunction name="getComponentsTest" access="public" hint="Returns a list of components for a package">
		<cfset assertEquals(true, false) />
	</cffunction>

	<cffunction name="extendsTest" access="public" hint="Returns true if the specified component extends another">
		<cfset assertEquals(true, false) />
	</cffunction>

	<cffunction name="listExtendsTest" access="public" description="Returns a list of the components the specified one extends (inclusive)">
		<cfset assertEquals(true, false) />
	</cffunction>

	<!--- MISCELLANEOUS utilities --->
	<cffunction name="fixURLTest" hint="Refreshes the page with the specified query string values removed, replaced, or added. New values can be specified with a query string, struct, or named arguments.">
		<cfset assertEquals(true, false) />
	</cffunction>

	<cffunction name="insertQueryVariableTest" access="public" hint="Inserts the specified key and value, replacing the existing value for that key">
		<cfset assertEquals(true, false) />
	</cffunction>

	
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