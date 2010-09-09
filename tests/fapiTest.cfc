<!--- @@Copyright: Copyright (c) 2009 Rob Rohan. All rights reserved. --->
<!--- @@displayname: fapiTest.cfc --->
<!--- @@description: 
	This file holds all the tests for the FAPI (FarCry 
	Public API).  WARNING: this file requires it be opened and saved in
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

<cfcomponent extends="mxunit.framework.TestCase" displayname="FAPI Tests" mode="self">
	<!--- setup and teardown --->
	<cffunction name="setUp" returntype="void" access="public">
		<!--- Any code needed to return your environment to normal goes here --->
		<cfset this.myComp = createObject("component", "farcry.core.packages.lib.fapi") />
	</cffunction>

	<cffunction name="tearDown" returntype="void" access="public">
		<!--- Any code needed to return your environment to normal goes here --->
	</cffunction>
	
	<!--- ////////////////////////////////////////////////////////////////// --->
	
	<cffunction name="findTypeTest" access="public">
		<!--- <cfset assertEquals(true, false) /> --->
		<cfset assertEquals(this.myComp.findType(createUUID()), "") />
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
		<!--- getConfig(key,name,[default]) --->
		<cfset assertTrue( len(this.myComp.getConfig('general','locale')) neq 0 ) />
		<cfset assertTrue( len(this.myComp.getConfig('general','adminemail')) neq 0 ) />
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
		
		<cfset assertTrue(this.myComp.checkNavID("root")) />
		<cfset assertFalse(this.myComp.checkNavID("this should not exist")) />
	</cffunction>

	<cffunction name="getNavIDTest" access="public" hint="Returns the objectID of the dmNavigation record for the passed alias. If the alias does not exist, the alternate alias will be used. ">
		
		<cfset assertTrue(len(this.myComp.getNavID("root"))) />
		<cfset assertEquals(this.myComp.getNavID("this should not exist","root"),this.myComp.getNavID("root")) />
		
		<cftry>
			<cfset this.myComp.getNavID("this should not exist") />
			
			<cfset fail("Error should have been thrown") />
			
			<cfcatch></cfcatch>
		</cftry>
	</cffunction>

	<cffunction name="checkCatIDTest" access="public" hint="Returns true if the category alias is found.">
		
		<cfset assertTrue(this.myComp.checkCatID("root")) />
		<cfset assertFalse(this.myComp.checkCatID("this should not exist")) />
	</cffunction>

	<cffunction name="getCatIDTest" access="public" hint="Returns the objectID of the dmCategory record for the passed alias. If the alias does not exist, the alternate alias will be used. ">
		
		<cfset assertTrue(len(this.myComp.getCatID("root"))) />
		<cfset assertEquals(this.myComp.getCatID("this should not exist","root"),this.myComp.getCatID("root")) />
		
		<cftry>
			<cfset this.myComp.getCatID("this should not exist") />
			
			<cfset fail("Error should have been thrown") />
			
			<cfcatch></cfcatch>
		</cftry>
	</cffunction>

	<cffunction name="getContentTypeTest" access="public" hint="Returns the an instantiated content type">
		<cfset assertEquals(true, false) />
	</cffunction>

	<cffunction name="getContentObjectTest" access="public" hint="Allows you to fetch a content object with only the objectID">
		<cfquery datasource="#application.dsn#" name="refobjects">
			SELECT max(objectID) as objectid
			FROM refObjects 
		</cfquery>
		
		<cfset myobj = this.myComp.getContentObject(refobjects.objectid) />
		
		<cfset assertIsStruct(myobj) />
		
		<cfloop list="OBJECTID,DATETIMECREATED,CREATEDBY,OWNEDBY,DATETIMELASTUPDATED,LASTUPDATEDBY,LOCKEDBY,LOCKED" index="x">
			<cfset assertTrue( structKeyExists(myobj, x), true) />
		</cfloop>
		
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
		<cfset listSubset = this.myComp.listFilter("one,two,three,four", "^[ot]", ",") />
		<cfset assertEquals(listSubset, "one,two,three") />
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
		
		<cfset assertTrue(this.myComp.extends("farcry.core.packages.types.dmHTML","farcry.core.packages.types.versions")) />
		<cfset assertFalse(this.myComp.extends("farcry.core.packages.types.dmNavigation","farcry.core.packages.types.versions")) />
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
	
	<cffunction name="getDocTypeTest" returntype="void" access="public">
		<!--- 
			HTML 2.0
			HTML PUBLIC "-//IETF//DTD HTML 2.0 Level 2//EN"
			HTML PUBLIC "-//IETF//DTD HTML//EN"
			HTML PUBLIC "-//IETF//DTD HTML 2.0//EN"
			HTML PUBLIC "-//IETF//DTD HTML Level 2//EN"
			
			HTML 3.0
			HTML PUBLIC "-//IETF//DTD HTML 3.0//EN"
			
			HTML 3.2
			HTML PUBLIC "-//W3C//DTD HTML 3.2 Final//EN"
			
			HTML 4.01
			HTML PUBLIC "-//W3C//DTD HTML 4.01//EN" "http://www.w3.org/TR/html4/strict.dtd"
			HTML PUBLIC "-//W3C//DTD HTML 4.01 Transitional//EN" "http://www.w3.org/TR/html4/loose.dtd"
			HTML PUBLIC "-//W3C//DTD HTML 4.01 Frameset//EN" "http://www.w3.org/TR/html4/frameset.dtd"
			
			XHTML 1.0
			html PUBLIC "-//W3C//DTD XHTML 1.0 Strict//EN" "http://www.w3.org/TR/xhtml1/DTD/xhtml1-strict.dtd"
			html PUBLIC "-//W3C//DTD XHTML 1.0 Transitional//EN" "http://www.w3.org/TR/xhtml1/DTD/xhtml1-transitional.dtd"
			html PUBLIC "-//W3C//DTD XHTML 1.0 Frameset//EN" "http://www.w3.org/TR/xhtml1/DTD/xhtml1-frameset.dtd"
			
			XHTML 1.1
			html PUBLIC "-//W3C//DTD XHTML 1.1//EN" "http://www.w3.org/TR/xhtml11/DTD/xhtml11.dtd"
			
			XHTML 2.0
			html PUBLIC "-//W3C//DTD XHTML 2.0//EN" "http://www.w3.org/MarkUp/DTD/xhtml2.dtd"
		--->
		<cfset var stDT = this.myComp.getDocType('html PUBLIC "-//W3C//DTD XHTML 1.0 Frameset//EN" "http://www.w3.org/TR/xhtml1/DTD/xhtml1-frameset.dtd"') />
		
		<cfset assertEquals(stDT.type, "xhtml") />
		<cfset assertEquals(stDT.version, "1.0") />
		<cfset assertEquals(stDT.subtype, "Frameset") />
		<cfset assertEquals(stDT.URI, "http://www.w3.org/TR/xhtml1/DTD/xhtml1-frameset.dtd") />
		
		<cfset stDT = this.myComp.getDocType('HTML PUBLIC "-//IETF//DTD HTML 2.0 Level 2//EN"') />
		
		<cfset assertEquals(stDT.type, "html") />
		<cfset assertEquals(stDT.version, "2.0") />
		<cfset assertEquals(stDT.URI, "") />
		
		<cfset stDT = this.myComp.getDocType('HTML PUBLIC "-//W3C//DTD HTML 3.2 Final//EN"') />
		
		<cfset assertEquals(stDT.type, "html") />
		<cfset assertEquals(stDT.version, "3.2") />
		<cfset assertEquals(stDT.URI, "") />
		
		<cfset stDT = this.myComp.getDocType('html PUBLIC "-//W3C//DTD XHTML 2.0//EN" "http://www.w3.org/MarkUp/DTD/xhtml2.dtd"') />
		
		<cfset assertEquals(stDT.type, "xhtml") />
		<cfset assertEquals(stDT.version, "2.0") />
		<cfset assertEquals(stDT.URI, "http://www.w3.org/MarkUp/DTD/xhtml2.dtd") />
		
		<cfset stDT = this.myComp.getDocType('html PUBLIC "-//W3C//DTD XHTML 1.1//EN" "http://www.w3.org/TR/xhtml11/DTD/xhtml11.dtd"') />
		
		<cfset assertEquals(stDT.type, "xhtml") />
		<cfset assertEquals(stDT.version, "1.1") />
		<cfset assertEquals(stDT.URI, "http://www.w3.org/TR/xhtml11/DTD/xhtml11.dtd") />
		
		<cfset stDT = this.myComp.getDocType('html') />
		
		<cfset assertEquals(stDT.type, "html") />
	</cffunction>
	
	
	<cffunction name="RFC822ToDateTest" access="public" returntype="void" output="false">
		<cfset var tdate = this.myComp.RFC822toDate() />
		
		<cfset assertEquals(year(tdate), year(now())) />	
		<cfset assertEquals(month(tdate), month(now())) />
		<cfset assertEquals(day(tdate), day(now())) />
	</cffunction>
	
	
	<cffunction name="dateToRFC822Test" access="public" returntype="void" output="false">
		<cfset var tdate = this.myComp.dateToRFC822(now()) />
		
		<!--- 
			This is a really lazy test, but I am in a bit of a rush 
			TODO: make this a real test
		--->
		<cfset assertEquals(arrayLen(listToArray(tdate," ")), 6) />	
	</cffunction>
	
	
	<cffunction name="removeMSWordCharsTest" access="public" returntype="void" output="false">
		<cfset var rval = this.myComp.removeMSWordChars("This String should be unchanged.") />
		<cfset assertEquals(rval, "This String should be unchanged.") />
		
		<cfset rval = this.myComp.removeMSWordChars("这个需要看书这个需要看书……") />
		<!--- the elips is replaced with periods --->
		<cfset assertEquals(rval, "这个需要看书这个需要看书......") />

		<cfset rval = this.myComp.removeMSWordChars("Schultz, Helen O’Neil, Frank") />
		<cfset assertEquals(rval, "Schultz, Helen O'Neil, Frank") />		
	</cffunction>
	
	<cffunction name="getContentObjects_basic" displayname="getContentObjects - basic" access="public" returntype="void" output="false">
		<cfset var q = this.myComp.getContentObjects(typename="dmHTML") />
		
		<cfset assertEquals(listsort(lcase(q.columnlist),"text"),"objectid","Incorrect properties returned") />
	</cffunction>
	
	<cffunction name="getContentObjects_lproperties" displayname="getContentObjects - different lproperties" access="public" returntype="void" output="false">
		<cfset var q = this.myComp.getContentObjects(typename="dmHTML",lProperties="title,datetimecreated") />
		
		<cfset assertEquals(listsort(lcase(q.columnlist),"text"),"datetimecreated,title","Incorrect properties returned") />
	</cffunction>
	
	<cffunction name="getContentObjects_orderby" displayname="getContentObjects - order by" access="public" returntype="void" output="false">
		<!--- Only tests that the DB doesn't throw an error --->
		
		<cfset var q = this.myComp.getContentObjects(typename="dmHTML",orderby="title") />
	</cffunction>
	
	<cffunction name="getContentObjects_filter_eq" displayname="getContentObjects - eq" access="public" returntype="void" output="false">
		<cfset var q = this.myComp.getContentObjects(typename="dmHTML",title_eq="Hello") />
		<cfset var d = "" />
		
		<cfsavecontent variable="d"><cfdump var="#q#"></cfsavecontent>
		
		<cfset assertTrue(refindnocase("title\s+=\s+\?",d)) />
	</cffunction>
	
	<cffunction name="getContentObjects_filter_neq" displayname="getContentObjects - neq" access="public" returntype="void" output="false">
		<cfset var q = this.myComp.getContentObjects(typename="dmHTML",title_neq="Hello") />
		<cfset var d = "" />
		
		<cfsavecontent variable="d"><cfdump var="#q#"></cfsavecontent>
		
		<cfset assertTrue(refindnocase("not\s+title\s+=\s+\?",d)) />
	</cffunction>
	
	<cffunction name="getContentObjects_filter_gt" displayname="getContentObjects - gt" access="public" returntype="void" output="false">
		<cfset var q = this.myComp.getContentObjects(typename="dmHTML",title_gt="Hello") />
		<cfset var d = "" />
		
		<cfsavecontent variable="d"><cfdump var="#q#"></cfsavecontent>
		
		<cfset assertTrue(refindnocase("title\s+&gt;\s+\?",d)) />
	</cffunction>
	
	<cffunction name="getContentObjects_filter_gtdate" displayname="getContentObjects - gt date" access="public" returntype="void" output="false">
		<cfset var q = this.myComp.getContentObjects(typename="dmHTML",datetimecreated_gt=now()) />
		<cfset var d = "" />
		
		<cfsavecontent variable="d"><cfdump var="#q#"></cfsavecontent>
		
		<cfset assertTrue(refindnocase("\(\s+datetimecreated\s+is\s+null\s+or\s+datetimecreated\s+=\s+\?\s+or\s+datetimecreated\s+&gt;\s+\?\s+or\s+datetimecreated\s+&gt;\s+\?\s+\)",d)) />
	</cffunction>
	
	<cffunction name="getContentObjects_filter_gte" displayname="getContentObjects - gte" access="public" returntype="void" output="false">
		<cfset var q = this.myComp.getContentObjects(typename="dmHTML",title_gte="Hello") />
		<cfset var d = "" />
		
		<cfsavecontent variable="d"><cfdump var="#q#"></cfsavecontent>
		
		<cfset assertTrue(refindnocase("title\s+&gt;=\s+\?",d)) />
	</cffunction>
	
	<cffunction name="getContentObjects_filter_gtedate" displayname="getContentObjects - gte date" access="public" returntype="void" output="false">
		<cfset var q = this.myComp.getContentObjects(typename="dmHTML",datetimecreated_gte=now()) />
		<cfset var d = "" />
		
		<cfsavecontent variable="d"><cfdump var="#q#"></cfsavecontent>
		
		<cfset assertTrue(refindnocase("\(\s+datetimecreated\s+is\s+null\s+or\s+datetimecreated\s+=\s+\?\s+or\s+datetimecreated\s+&gt;\s+\?\s+or\s+datetimecreated\s+&gt;=\s+\?\s+\)",d)) />
	</cffunction>
	
	<cffunction name="getContentObjects_filter_lt" displayname="getContentObjects - lt" access="public" returntype="void" output="false">
		<cfset var q = this.myComp.getContentObjects(typename="dmHTML",datetimecreated_lt=now()) />
		<cfset var d = "" />
		
		<cfsavecontent variable="d"><cfdump var="#q#"></cfsavecontent>
		
		<cfset assertTrue(refindnocase("datetimecreated\s+&lt;\s+\?",d)) />
	</cffunction>
	
	<cffunction name="getContentObjects_filter_ltdate" displayname="getContentObjects - lt date" access="public" returntype="void" output="false">
		<cfset var q = this.myComp.getContentObjects(typename="dmHTML",datetimecreated_lt=now()) />
		<cfset var d = "" />
		
		<cfsavecontent variable="d"><cfdump var="#q#"></cfsavecontent>
		
		<cfset assertTrue(refindnocase("\(\s+datetimecreated\s+is\s+null\s+or\s+datetimecreated\s+=\s+\?\s+or\s+datetimecreated\s+&gt;\s+\?\s+or\s+datetimecreated\s+&lt;\s+\?\s+\)",d)) />
	</cffunction>
	
	<cffunction name="getContentObjects_filter_lte" displayname="getContentObjects - lte" access="public" returntype="void" output="false">
		<cfset var q = this.myComp.getContentObjects(typename="dmHTML",datetimecreated_lte=now()) />
		<cfset var d = "" />
		
		<cfsavecontent variable="d"><cfdump var="#q#"></cfsavecontent>
		
		<cfset assertTrue(refindnocase("datetimecreated\s+&lt;=\s+\?",d)) />
	</cffunction>
	
	<cffunction name="getContentObjects_filter_ltedate" displayname="getContentObjects - lte date" access="public" returntype="void" output="false">
		<cfset var q = this.myComp.getContentObjects(typename="dmHTML",datetimecreated_lte=now()) />
		<cfset var d = "" />
		
		<cfsavecontent variable="d"><cfdump var="#q#"></cfsavecontent>
		
		<cfset assertTrue(refindnocase("\(\s+datetimecreated\s+is\s+null\s+or\s+datetimecreated\s+=\s+\?\s+or\s+datetimecreated\s+&gt;\s+\?\s+or\s+datetimecreated\s+&lt;=\s+\?\s+\)",d)) />
	</cffunction>
	
	<cffunction name="getContentObjects_filter_in" displayname="getContentObjects - in" access="public" returntype="void" output="false">
		<cfset var q = this.myComp.getContentObjects(typename="dmHTML",title_in="hello,world") />
		<cfset var d = "" />
		
		<cfsavecontent variable="d"><cfdump var="#q#"></cfsavecontent>
		
		<cfset assertTrue(refindnocase("title\s+in\s+\(\s*\?",d)) />
	</cffunction>
	
	<cffunction name="getContentObjects_filter_notin" displayname="getContentObjects - notin" access="public" returntype="void" output="false">
		<cfset var q = this.myComp.getContentObjects(typename="dmHTML",title_notin="hello,world") />
		<cfset var d = "" />
		
		<cfsavecontent variable="d"><cfdump var="#q#"></cfsavecontent>
		
		<cfset assertTrue(refindnocase("not\s+title\s+in\s+\(\s*\?",d)) />
	</cffunction>
	
	<cffunction name="getContentObjects_filter_like" displayname="getContentObjects - like" access="public" returntype="void" output="false">
		<cfset var q = this.myComp.getContentObjects(typename="dmHTML",title_like="%hello%") />
		<cfset var d = "" />
		
		<cfsavecontent variable="d"><cfdump var="#q#"></cfsavecontent>
		
		<cfset assertTrue(refindnocase("title\s+like\s+\?",d)) />
	</cffunction>
	
	<cffunction name="getContentObjects_filter_isnulltrue" displayname="getContentObjects - isnull = true" access="public" returntype="void" output="false">
		<cfset var q = this.myComp.getContentObjects(typename="dmHTML",title_isnull=true) />
		<cfset var d = "" />
		
		<cfsavecontent variable="d"><cfdump var="#q#"></cfsavecontent>
		
		<cfset assertTrue(refindnocase("\(\s+title\s+is\s+null\s+\)",d)) />
	</cffunction>
	
	<cffunction name="getContentObjects_filter_isnullfalse" displayname="getContentObjects - isnull = false" access="public" returntype="void" output="false">
		<cfset var q = this.myComp.getContentObjects(typename="dmHTML",title_isnull=false) />
		<cfset var d = "" />
		
		<cfsavecontent variable="d"><cfdump var="#q#"></cfsavecontent>
		
		<cfset assertTrue(refindnocase("\(\s+title\s+is\s+not\s+null\s+\)",d)) />
	</cffunction>
	
	<cffunction name="getContentObjects_filter_isnulldatetrue" displayname="getContentObjects - isnull date = true" access="public" returntype="void" output="false">
		<cfset var q = this.myComp.getContentObjects(typename="dmHTML",datetimecreated_isnull=true) />
		<cfset var d = "" />
		
		<cfsavecontent variable="d"><cfdump var="#q#"></cfsavecontent>
		
		<cfset assertTrue(refindnocase("\(\s+datetimecreated\s+is\s+null\s+or\s+datetimecreated\s+=\s+\?\s+or\s+datetimecreated\s+&gt;\s+\?\s+\)",d)) />
	</cffunction>
	
	<cffunction name="getContentObjects_filter_isnulldatefalse" displayname="getContentObjects - isnull date = false" access="public" returntype="void" output="false">
		<cfset var q = this.myComp.getContentObjects(typename="dmHTML",datetimecreated_isnull=false) />
		<cfset var d = "" />
		
		<cfsavecontent variable="d"><cfdump var="#q#"></cfsavecontent>
		
		<cfset assertTrue(refindnocase("\(\s+datetimecreated\s+is\s+not\s+null\s+and\s+not\s+datetimecreated\s+=\s+\?\s+and\s+datetimecreated\s+&lt;\s*\?\s+\)",d)) />
	</cffunction>
	
	<cffunction name="getContentObjects_filter_inarray" displayname="getContentObjects - eq array" access="public" returntype="void" output="false">
		<cfset var q = "" />
		<cfset var q2 = "" />
		
		<cfquery datasource="#application.dsn#" name="q">
			select		data,count(data) as total
			from		dmHTML_aObjectIDs
			group by	data
		</cfquery>
		
		<cfset q2 = this.myComp.getContentObjects(typename="dmHTML",aObjectIds_in=valuelist(q.data)) />
		<cfdirectory action="list" directory="" filter="" name="" />
		<cfset assertEquals(q.total[1],q2.recordcount,"Incorrect number of records returned") />
	</cffunction>
	<cffunction name="getLinkBasic" access="public" output="false" displayname="getLink - base test" returntype="void">
		<cfset var x = this.myComp.getLink(objectid='AB3C3520-B72D-46D6-B2066B5E844A1114') />
		
		<cfset assertEquals(x, "/AB3C3520-B72D-46D6-B2066B5E844A1114") />
	</cffunction>
	
	<cffunction name="getLinkBasicWithDomain" access="public" output="false" displayname="getLink - base test FQDN" returntype="void">
		<cfset var x = this.myComp.getLink(
											objectid='AB3C3520-B72D-46D6-B2066B5E844A1114', 
											includeDomain=true) />
		<cfset assertEquals(x, "http://#cgi.http_host#/AB3C3520-B72D-46D6-B2066B5E844A1114") />
	</cffunction>
	
	<cffunction name="getLinkBasicWithDomainURLParams" access="public" output="false" displayname="getLink - base test FQDN with params" returntype="void">
		<cfset var x = this.myComp.getLink(
											objectid='AB3C3520-B72D-46D6-B2066B5E844A1114', 
											includeDomain=true,
											urlparameters='key=4147631D-CE95') />
		<cfset assertEquals(
							x,
							"http://unsw.local/AB3C3520-B72D-46D6-B2066B5E844A1114/key/4147631D%2DCE95") />
	</cffunction>
	
	<cffunction name="getLinkBasicWithDomainOverrideURLParams" access="public" output="false" displayname="getLink - base test FQDN with params and domain override" returntype="void">
		<cfset var x = this.myComp.getLink(
											objectid='AB3C3520-B72D-46D6-B2066B5E844A1114', 
											includeDomain=true,
											urlparameters='key=4147631D-CE95',
											domain="daemon.com.au") />
		<cfset assertEquals(
							x,
							"http://daemon.com.au/AB3C3520-B72D-46D6-B2066B5E844A1114/key/4147631D%2DCE95") />
	</cffunction>
	
	<cffunction name="getLinkAlias" access="public" output="false" displayname="getLink - very basic alias test" returntype="void">
		<cfset var x = this.myComp.getLink(alias='home') />
		
		<cfset assertEquals(x, "/") />
	</cffunction>
</cfcomponent>