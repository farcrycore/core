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
		<cfset var sv = arrayNew(1) />
		
		<cftry>
			<cfset sv[1] = "Done blown up!" />
			<cfset this.myComp.throw(
				type="test", 
				key="testMXUnit.test3",
				message="My Default Message",
				substituteValues=sv
			) />
			<cfcatch type="test">
				<cfif this.myComp.getCurrentLocale() eq "en_AU">
					<cfset assertEquals(cfcatch.message, "Error mate! It's Done blown up!") />
				<cfelseif this.myComp.getCurrentLocale() eq "en_US">
					<cfset assertEquals(cfcatch.message, "Error: Done blown up!") />
				<cfelse>
					<cfset assertEquals("Bad locale or something", false) />
				</cfif>
			</cfcatch>
			<cfcatch type="any">
				<cfset assertEquals("Didn't catch correctly", false) />
			</cfcatch>
		</cftry>
		
	</cffunction>

	<cffunction name="getResourceTestFullAU" access="public">
		<cfset var mystring = this.myComp.getResource("testMXUnit.test1@label","","en_AU", "Rob") />
		<cfset assertEquals(mystring, "G'day Rob") />
	</cffunction>
	
	<cffunction name="getResourceTestFullUS" access="public">
		<cfset var mystring = this.myComp.getResource("testMXUnit.test1@label","","en_US", "Rob") />
		<cfset assertEquals(mystring, "Rob, Howdy Pa'dna") />
	</cffunction>

	<cffunction name="getResourceTestBasic" access="public">
		<cfset var mystring = this.myComp.getResource("testMXUnit.test2@label") />
		
		<cfif this.myComp.getCurrentLocale() eq "en_AU">
			<cfset assertEquals(mystring, "Bob's your uncle") />
		<cfelseif this.myComp.getCurrentLocale() eq "en_US">
			<cfset assertEquals(mystring, "You're all set") />
		<cfelse>
			<cfset assertEquals(true, false) />
		</cfif>
	</cffunction>

	<cffunction name="getCurrentLocaleTest" access="public">
		<cfset var mylocale = this.myComp.getCurrentLocale() />
		
		<cfset assertEquals(arrayLen(listToArray(mylocale,"_")), 2) />
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
		<cfquery datasource="#application.dsn#" name="refobjects">
			SELECT max(objectID) as objectid
			FROM refobjects 
		</cfquery>
		
		<cfset myobj = this.myComp.getContentObject(refobjects.objectid) />
		
		<cfset assertIsStruct(myobj) />
		
		<cfloop list="CREATEDBY,DATETIMECREATED,DATETIMELASTUPDATED,EVENT,IPADDRESS,LABEL,LASTUPDATEDBY,LOCATION,LOCKED,LOCKEDBY,NOTES,OBJECT,OBJECTID,OWNEDBY,TYPE,TYPENAME,USERID" index="x">
			<cfset assertTrue( structKeyExists(myobj, x), true) />
		</cfloop>
		
		<cfset assertTrue( len(myobj.type) gt 0 ) />
		<cfset assertTrue( len(myobj.typename) gt 0 ) />
	</cffunction>

	<cffunction name="arrayTest">
		<cfset var myarray = this.myComp.array("Thing 1","Thing 2","Thing 3") />
		<cfset assertEquals(arrayLen(myarray), 3) />
	</cffunction>

	<cffunction name="getUUIDTest" access="public" hint="">
		<cfset assertEquals(isValid("UUID",this.myComp.getUUID()), true) />
	</cffunction>

	<!--- ARRAY utilities --->
	<cffunction name="arrayFindTest" access="public" hint="Returns the index of the first element that matches the specified value. 0 if not found." >
		<cfset var myArray = arrayNew(1) />
		<cfset myArray[1] = "Value 1" />
		<cfset myArray[2] = "Value 3" />
		
		<cfset assertEquals(this.myComp.arrayFind(myArray,"Value 1"), 1) />
		<cfset assertEquals(this.myComp.arrayFind(myArray,"Value 10"), 0) />
	</cffunction>

	<!--- LIST utilities --->
	<cffunction name="listReverseTest" access="public" hint="Reverses a list">
		<cfset var mylist = "Thing 1,Thing 2,Thing 3,Thing 4" />
		<cfset mylist = this.myComp.listReverse(mylist) />
		
		<cfset assertEquals(listFirst(mylist), "Thing 4") />
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
		<cfset var listOne = "Thing,Thang,Thong,Ding,Dang,Dong" />
		<cfset var listTwo = "他,是,我,的,妹妹" />
		<cfset var listThree = "我们,去,澳洲,thing" />
		<cfset var listFour = "我们,去,Thang,澳洲" />
		
		<cfset assertEquals(this.myComp.listContainsAny(listOne,listTwo), false) />
		<cfset assertEquals(this.myComp.listContainsAny(listOne,listThree), false) />
		<cfset assertEquals(this.myComp.listContainsAny(listOne,listFour), true) />
	</cffunction>

	<cffunction name="listContainsAnyNoCaseTest" access="public" description="Returns true if the first list contains any of the items in the second list">
		<cfset var listOne = "Thing,Thang,Thong,Ding,Dang,Dong" />
		<cfset var listTwo = "他,是,我,的,妹妹" />
		<cfset var listThree = "我们,去,澳洲,thing" />
		<cfset var listFour = "我们,去,Thang,澳洲" />
		
		<cfset assertEquals(this.myComp.listContainsAnyNoCase(listOne,listTwo), false) />
		<cfset assertEquals(this.myComp.listContainsAnyNoCase(listOne,listThree), true) />
		<cfset assertEquals(this.myComp.listContainsAnyNoCase(listOne,listFour), true) />
	</cffunction>

	<!--- STRUCT ulilities --->
	<cffunction name="structMergeTest" access="public" hint="Performs a deep merge on two structs">
		<cfset var myStructOne = structNew() />
		<cfset var myStructTwo = structNew() />
		<cfset var myMerged = "" />
		
		<cfset myStructOne.substruct = structNew() />
		<cfset myStructTwo.toplevel = "Yadda" />
		
		<cfset myMerged = this.myComp.structMerge(myStructOne, myStructTwo) />
		
		<cfset assertEquals(isStruct(myMerged.substruct), true) />
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
	
	<cffunction name="getCurrentUserTest">
		<cfset var currentUser = this.myComp.getCurrentUser() />
		<cfset assertEquals(isStruct(currentUser), true) />
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