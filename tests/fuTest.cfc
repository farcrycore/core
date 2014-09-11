<cfcomponent extends="farcry.plugins.testMXUnit.tests.FarcryTestCase" displayname="Friendly URL Tests" mode="self">
	
	<!--- setup and teardown --->
	<cffunction name="setUp" returntype="void" access="public">
		<cfset var q = "" />
		
		<cfset super.setUp() />
		
		<!--- Any code needed to setup your environment goes here --->
		<cfset this.farFU = createObject("component", "farcry.core.packages.types.farFU").onAppInit() />
		<cfset application.fc.factory.farFU = this.farFU />
		<cfset this.fapi = createObject("component", "farcry.core.packages.lib.fapi").init() />
		
		<cfquery datasource="#application.dsn#" name="q">
			select	*
			from	farFU
			where	friendlyURL<>'' and friendlyURL<>'/'
		</cfquery>
		<cfset this.testFU = application.fapi.getContentObject(objectid=q.objectid[1],typename="farFU") />
		<cfset this.testFU2 = application.fapi.getContentObject(objectid=q.objectid[2],typename="farFU") />
		
		<cfset createTemporaryObject(typename="farFU",refobjectid=createuuid(),friendlyURL="/test",querystring="",fuStatus=2,redirectionType="none",redirectTo="",bDefault=1,applicationname=application.applicationname) />
		<cfset createTemporaryObject(typename="farFU",refobjectid=this.testFU.objectid,friendlyURL="/test/fu",querystring="",fuStatus=2,redirectionType="none",redirectTo="",bDefault=1,applicationname=application.applicationname) />
		<cfset createTemporaryObject(typename="farFU",refobjectid=createuuid(),friendlyURL="/test/fu/more",querystring="",fuStatus=2,redirectionType="none",redirectTo="",bDefault=1,applicationname=application.applicationname) />
		
		<cfset this.origFUSetting = application.fc.factory.farFU.isUsingFU() />
		<cfset application.fc.factory.farFU.turnOn() />
	</cffunction>

	<cffunction name="tearDown" returntype="void" access="public">
		
		<cfif not this.origFUSetting>
			<cfset application.fc.factory.farFU.turnOff() />
		</cfif>
		
		<cfset super.tearDown() />
	</cffunction>
	
	
	<!--- No FU --->
	<cffunction displayname="Parse: /notafu" hint="Checks that this friendly URL is not parsed" name="parseFU_none" access="public">
		<cfset var stResult = this.farFU.getURLStructByURL(friendlyURL="/notafu") />
		
		<cfset assertEquals(structkeylist(stResult),"") />
	</cffunction>

	<cffunction displayname="Parse: [no furl]" hint="Checks that this friendly URL returns nothin" name="parseFU_nofurl" access="public">
		<cfset var stURL = structnew() />
		<cfset var stResult = structnew() />
		
		<cfset stResult = this.farFU.parseURL(stURL=stURL) />
		
		<cfset assertEquals(listsort(structkeylist(stResult),"textNoCase"),"__allowredirect") />
	</cffunction>
	
	<cffunction displayname="Parse: /" hint="Checks that this friendly URL returns nothin" name="parseFU_home" access="public">
		<cfset var stURL = structnew() />
		<cfset var stResult = structnew() />
		
		<cfset stURL.furl = "/" />
		
		<cfset stResult = this.farFU.parseURL(stURL=stURL) />
		
		<cfset assertEquals(listsort(structkeylist(stResult),"textNoCase"),"__allowredirect,furl") />
	</cffunction>
	
	<!--- Constructed FU: only typename --->
	<cffunction displayname="Parse: /typename" hint="Checks that this friendly URL is parsed as type" name="parseFU_typename" access="public">
		<cfset var stResult = this.farFU.getURLStructByURL(friendlyURL="/farFU") />
		
		<cfset assertEquals(structkeylist(stResult),"type") />
		<cfset assertEquals(stResult.type, "farFU") />
	</cffunction>
	
	<cffunction displayname="Parse: /typealias" hint="Checks that this friendly URL is parsed as type" name="parseFU_typealias" access="public">
		<cfset var stResult = this.farFU.getURLStructByURL(friendlyURL="/fu") />
		
		<cfset assertEquals(structkeylist(stResult),"type") />
		<cfset assertEquals(stResult.type, "farFU") />
	</cffunction>
	
	<cffunction displayname="Parse: /typealias/param1/value1/param2/value2" hint="Checks that this friendly URL is parsed as type, and two parameters" name="parseFU_typealias_parameters" access="public">
		<cfset var stResult = this.farFU.getURLStructByURL(friendlyURL="/fu/param1/value1/param2/value2") />
		
		<cfset assertEquals(listsort(structkeylist(stResult),"textNoCase"),"param1,param2,type") />
		<cfset assertEquals(stResult.type, "farFU") />
		<cfset assertEquals(stResult.param1, "value1") />
		<cfset assertEquals(stResult.param2, "value2") />
	</cffunction>
	
	<cffunction displayname="Parse: /?type=typename" hint="Checks that this friendly URL returns type" name="parseFU_qs_typename" access="public">
		<cfset var stURL = structnew() />
		<cfset var stResult = structnew() />
		
		<cfset stURL.furl = "/" />
		<cfset stURL.type = "fu" />
		
		<cfset stResult = this.farFU.parseURL(stURL=stURL) />
		
		<cfset assertEquals(listsort(structkeylist(stResult),"textNoCase"),"__allowredirect,furl,type") />
		<cfset assertEquals(stResult.type, "farFU") />
	</cffunction>
	
	<cffunction displayname="Parse: /?type=typealias" hint="Checks that this friendly URL returns type" name="parseFU_qs_typealias" access="public">
		<cfset var stURL = structnew() />
		<cfset var stResult = structnew() />
		
		<cfset stURL.furl = "/" />
		<cfset stURL.type = "farFU" />
		
		<cfset stResult = this.farFU.parseURL(stURL=stURL) />
		
		<cfset assertEquals(listsort(structkeylist(stResult),"textNoCase"),"__allowredirect,furl,type") />
		<cfset assertEquals(stResult.type, "farFU") />
	</cffunction>
	
	<!--- Constructed FU: type and view --->
	<cffunction displayname="Parse: /typename/viewname" hint="Checks that this friendly URL is parsed as type and view" name="parseFU_typename_viewname" access="public">
		<cfset var stResult = this.farFU.getURLStructByURL(friendlyURL="/farFU/displayPageTest") />
		
		<cfset assertEquals(listsort(structkeylist(stResult),"textNoCase"),"type,view") />
		<cfset assertEquals(stResult.type, "farFU") />
		<cfset assertEquals(stResult.view, "displayPageTest") />
	</cffunction>
	
	<cffunction displayname="Parse: /typename/viewalias" hint="Checks that this friendly URL is parsed as type and view" name="parseFU_typename_viewalias" access="public">
		<cfset var stResult = this.farFU.getURLStructByURL(friendlyURL="/farFU/test-page-default") />
		
		<cfset assertEquals(listsort(structkeylist(stResult),"textNoCase"),"type,view") />
		<cfset assertEquals(stResult.type, "farFU") />
		<cfset assertEquals(stResult.view, "displayPageTest") />
	</cffunction>
	
	<cffunction displayname="Parse: /typealias/viewname" hint="Checks that this friendly URL is parsed as type and view" name="parseFU_typealias_viewname" access="public">
		<cfset var stResult = this.farFU.getURLStructByURL(friendlyURL="/fu/displayPageTest") />
		
		<cfset assertEquals(listsort(structkeylist(stResult),"textNoCase"),"type,view") />
		<cfset assertEquals(stResult.type, "farFU") />
		<cfset assertEquals(stResult.view, "displayPageTest") />
	</cffunction>
	
	<cffunction displayname="Parse: /typealias/viewalias" hint="Checks that this friendly URL is parsed as type and view" name="parseFU_typealias_viewalias" access="public">
		<cfset var stResult = this.farFU.getURLStructByURL(friendlyURL="/fu/test-page-default") />
		
		<cfset assertEquals(listsort(structkeylist(stResult),"textNoCase"),"type,view") />
		<cfset assertEquals(stResult.type, "farFU") />
		<cfset assertEquals(stResult.view, "displayPageTest") />
	</cffunction>
	
	<cffunction displayname="Parse: /typealias/objectviewalias" hint="Checks that this friendly URL is as invalid due to the attempt to use an object-bound webskin" name="parseFU_typealias_objectviewalias" access="public">
		<cfset var stURL = structnew() />
		<cfset var stResult = structnew() />
		<cfset var error = false />
		
		<cfset stURL.furl = "/fu/test-page-object" />
		
		<cftry>
			<cfset stResult = this.farFU.parseURL(stURL=stURL) />
			
			<cfcatch>
				<cfset assertEquals(cfcatch.message,"You are trying to bind a type [farFU] to an object webskin [displayPageObjectTest]") />
				<cfset error = true />
			</cfcatch>
		</cftry>
		
		<cfif not error>
			<cfset fail("Error should have been thrown: 'You are trying to bind a type [farFU] to an object webskin [displayPageObjectTest]'") />
		</cfif>
	</cffunction>
	
	<cffunction displayname="Parse: /typealias/viewalias/param1/value1/param2/value2" hint="Checks that this friendly URL is parsed as type, view, and two parameters" name="parseFU_typealias_viewalias_parameters" access="public">
		<cfset var stResult = this.farFU.getURLStructByURL(friendlyURL="/fu/test-page-default/param1/value1/param2/value2") />
		
		<cfset assertEquals(listsort(structkeylist(stResult),"textNoCase"),"param1,param2,type,view") />
		<cfset assertEquals(stResult.type, "farFU") />
		<cfset assertEquals(stResult.view, "displayPageTest") />
		<cfset assertEquals(stResult.param1, "value1") />
		<cfset assertEquals(stResult.param2, "value2") />
	</cffunction>
	
	<cffunction displayname="Parse: /?type=typename&view=viewname" hint="Checks that this friendly URL returns type and view" name="parseFU_qs_typename_viewname" access="public">
		<cfset var stURL = structnew() />
		<cfset var stResult = structnew() />
		
		<cfset stURL.furl = "/" />
		<cfset stURL.type = "farFU" />
		<cfset stURL.view = "displayPageTest" />
		
		<cfset stResult = this.farFU.parseURL(stURL=stURL) />
		
		<cfset assertEquals(listsort(structkeylist(stResult),"textNoCase"),"__allowredirect,furl,type,view") />
		<cfset assertEquals(stResult.type, "farFU") />
		<cfset assertEquals(stResult.view, "displayPageTest") />
	</cffunction>
	
	<cffunction displayname="Parse: /?type=typename&view=viewalias" hint="Checks that this friendly URL returns type and view" name="parseFU_qs_typename_viewalias" access="public">
		<cfset var stURL = structnew() />
		<cfset var stResult = structnew() />
		
		<cfset stURL.furl = "/" />
		<cfset stURL.type = "farFU" />
		<cfset stURL.view = "test-page-default" />
		
		<cfset stResult = this.farFU.parseURL(stURL=stURL) />
		
		<cfset assertEquals(listsort(structkeylist(stResult),"textNoCase"),"__allowredirect,furl,type,view") />
		<cfset assertEquals(stResult.type, "farFU") />
		<cfset assertEquals(stResult.view, "displayPageTest") />
	</cffunction>
	
	<cffunction displayname="Parse: /?type=typealias&view=viewname" hint="Checks that this friendly URL returns type and view" name="parseFU_qs_typealias_viewname" access="public">
		<cfset var stURL = structnew() />
		<cfset var stResult = structnew() />
		
		<cfset stURL.furl = "/" />
		<cfset stURL.type = "fu" />
		<cfset stURL.view = "displayPageTest" />
		
		<cfset stResult = this.farFU.parseURL(stURL=stURL) />
		
		<cfset assertEquals(listsort(structkeylist(stResult),"textNoCase"),"__allowredirect,furl,type,view") />
		<cfset assertEquals(stResult.type, "farFU") />
		<cfset assertEquals(stResult.view, "displayPageTest") />
	</cffunction>
	
	<cffunction displayname="Parse: /?type=typealias&view=viewalias" hint="Checks that this friendly URL returns type and view" name="parseFU_qs_typealias_viewalias" access="public">
		<cfset var stURL = structnew() />
		<cfset var stResult = structnew() />
		
		<cfset stURL.furl = "/" />
		<cfset stURL.type = "fu" />
		<cfset stURL.view = "test-page-default" />
		
		<cfset stResult = this.farFU.parseURL(stURL=stURL) />
		
		<cfset assertEquals(listsort(structkeylist(stResult),"textNoCase"),"__allowredirect,furl,type,view") />
		<cfset assertEquals(stResult.type, "farFU") />
		<cfset assertEquals(stResult.view, "displayPageTest") />
	</cffunction>
	
	<!--- Constructed FU: type and bodyview --->
	<cffunction displayname="Parse: /typename/bodyname" hint="Checks that this friendly URL is parsed as type and bodyview" name="parseFU_typename_bodyname" access="public">
		<cfset var stResult = this.farFU.getURLStructByURL(friendlyURL="/farFU/displayTypeBodyTest") />
		
		<cfset assertEquals(listsort(structkeylist(stResult),"textNoCase"),"bodyview,type") />
		<cfset assertEquals(stResult.type, "farFU") />
		<cfset assertEquals(stResult.bodyview, "displayTypeBodyTest") />
	</cffunction>
	
	<cffunction displayname="Parse: /typename/bodyalias" hint="Checks that this friendly URL is parsed as type and bodyview" name="parseFU_typename_bodyalias" access="public">
		<cfset var stResult = this.farFU.getURLStructByURL(friendlyURL="/farFU/test-body-type") />
		
		<cfset assertEquals(listsort(structkeylist(stResult),"textNoCase"),"bodyview,type") />
		<cfset assertEquals(stResult.type, "farFU") />
		<cfset assertEquals(stResult.bodyview, "displayTypeBodyTest") />
	</cffunction>
	
	<cffunction displayname="Parse: /typealias/bodyname" hint="Checks that this friendly URL is parsed as type and bodyview" name="parseFU_typealias_bodyname" access="public">
		<cfset var stResult = this.farFU.getURLStructByURL(friendlyURL="/fu/displayTypeBodyTest") />
		
		<cfset assertEquals(listsort(structkeylist(stResult),"textNoCase"),"bodyview,type") />
		<cfset assertEquals(stResult.type, "farFU") />
		<cfset assertEquals(stResult.bodyview, "displayTypeBodyTest") />
	</cffunction>
	
	<cffunction displayname="Parse: /typealias/bodyalias" hint="Checks that this friendly URL is parsed as type and bodyview" name="parseFU_typealias_bodyalias" access="public">
		<cfset var stResult = this.farFU.getURLStructByURL(friendlyURL="/fu/test-body-type") />
		
		<cfset assertEquals(listsort(structkeylist(stResult),"textNoCase"),"bodyview,type") />
		<cfset assertEquals(stResult.type, "farFU") />
		<cfset assertEquals(stResult.bodyview, "displayTypeBodyTest") />
	</cffunction>
	
	<cffunction displayname="Parse: /typealias/objectbodyalias" hint="Checks that this friendly URL is as invalid due to the attempt to use an object-bound body webskin" name="parseFU_typealias_objectbodyalias" access="public">
		<cfset var stURL = structnew() />
		<cfset var stResult = structnew() />
		<cfset var error = false />
		
		<cfset stURL.furl = "/fu/test-body-default" />
		
		<cftry>
			<cfset stResult = this.farFU.parseURL(stURL=stURL) />
			
			<cfcatch>
				<cfset assertEquals(cfcatch.message,"You are trying to bind a type [farFU] to an object webskin [displayBodyTest]") />
				<cfset error = true />
			</cfcatch>
		</cftry>
		
		<cfif not error>
			<cfset fail("Error should have been thrown: 'You are trying to bind a type [farFU] to an object webskin [displayBodyTest]'") />
		</cfif>
	</cffunction>
	
	<cffunction displayname="Parse: /typealias/bodyalias/param1/value1/param2/value2" hint="Checks that this friendly URL is parsed as type, bodyview, and two parameters" name="parseFU_typealias_bodyalias_parameters" access="public">
		<cfset var stResult = this.farFU.getURLStructByURL(friendlyURL="/fu/test-body-type/param1/value1/param2/value2") />
		
		<cfset assertEquals(listsort(structkeylist(stResult),"textNoCase"),"bodyview,param1,param2,type") />
		<cfset assertEquals(stResult.type, "farFU") />
		<cfset assertEquals(stResult.bodyview, "displayTypeBodyTest") />
		<cfset assertEquals(stResult.param1, "value1") />
		<cfset assertEquals(stResult.param2, "value2") />
	</cffunction>
	
	<cffunction displayname="Parse: /?type=typename&bodyview=bodyname" hint="Checks that this friendly URL returns type and bodyview" name="parseFU_qs_typename_bodyname" access="public">
		<cfset var stURL = structnew() />
		<cfset var stResult = structnew() />
		
		<cfset stURL.furl = "/" />
		<cfset stURL.type = "farFU" />
		<cfset stURL.bodyview = "displayTypeBodyTest" />
		
		<cfset stResult = this.farFU.parseURL(stURL=stURL) />
		
		<cfset assertEquals(listsort(structkeylist(stResult),"textNoCase"),"__allowredirect,bodyview,furl,type") />
		<cfset assertEquals(stResult.type, "farFU") />
		<cfset assertEquals(stResult.bodyview, "displayTypeBodyTest") />
	</cffunction>
	
	<cffunction displayname="Parse: /?type=typename&bodyview=bodyalias" hint="Checks that this friendly URL returns type and bodyview" name="parseFU_qs_typename_bodyalias" access="public">
		<cfset var stURL = structnew() />
		<cfset var stResult = structnew() />
		
		<cfset stURL.furl = "/" />
		<cfset stURL.type = "farFU" />
		<cfset stURL.bodyview = "test-body-type" />
		
		<cfset stResult = this.farFU.parseURL(stURL=stURL) />
		
		<cfset assertEquals(listsort(structkeylist(stResult),"textNoCase"),"__allowredirect,bodyview,furl,type") />
		<cfset assertEquals(stResult.type, "farFU") />
		<cfset assertEquals(stResult.bodyview, "displayTypeBodyTest") />
	</cffunction>
	
	<cffunction displayname="Parse: /?type=typealias&bodyview=bodyname" hint="Checks that this friendly URL returns type and bodyview" name="parseFU_qs_typealias_bodyame" access="public">
		<cfset var stURL = structnew() />
		<cfset var stResult = structnew() />
		
		<cfset stURL.furl = "/" />
		<cfset stURL.type = "fu" />
		<cfset stURL.bodyview = "displayTypeBodyTest" />
		
		<cfset stResult = this.farFU.parseURL(stURL=stURL) />
		
		<cfset assertEquals(listsort(structkeylist(stResult),"textNoCase"),"__allowredirect,bodyview,furl,type") />
		<cfset assertEquals(stResult.type, "farFU") />
		<cfset assertEquals(stResult.bodyview, "displayTypeBodyTest") />
	</cffunction>
	
	<cffunction displayname="Parse: /?type=typealias&bodyview=bodyalias" hint="Checks that this friendly URL returns type and bodyview" name="parseFU_qs_typealias_bodyalias" access="public">
		<cfset var stURL = structnew() />
		<cfset var stResult = structnew() />
		
		<cfset stURL.furl = "/" />
		<cfset stURL.type = "fu" />
		<cfset stURL.bodyview = "test-body-type" />
		
		<cfset stResult = this.farFU.parseURL(stURL=stURL) />
		
		<cfset assertEquals(listsort(structkeylist(stResult),"textNoCase"),"__allowredirect,bodyview,furl,type") />
		<cfset assertEquals(stResult.type, "farFU") />
		<cfset assertEquals(stResult.bodyview, "displayTypeBodyTest") />
	</cffunction>
	
	<!--- Constructed FU: type, view, bodyview --->
	<cffunction displayname="Parse: /typename/viewname/bodyname" hint="Checks that this friendly URL is parsed as type, view and body" name="parseFU_typename_viewname_bodyname" access="public">
		<cfset var stResult = this.farFU.getURLStructByURL(friendlyURL="/farFU/displayPageTest/displayTypeBodyTest") />
		
		<cfset assertEquals(listsort(structkeylist(stResult),"textNoCase"),"bodyview,type,view") />
		<cfset assertEquals(stResult.type, "farFU") />
		<cfset assertEquals(stResult.view, "displayPageTest") />
		<cfset assertEquals(stResult.bodyview, "displayTypeBodyTest") />
	</cffunction>
	
	<cffunction displayname="Parse: /typename/viewname/bodyalias" hint="Checks that this friendly URL is parsed as type, view and body" name="parseFU_tyepname_viewname_bodyalias" access="public">
		<cfset var stResult = this.farFU.getURLStructByURL(friendlyURL="/farFU/displayPageTest/test-body-type") />
		
		<cfset assertEquals(listsort(structkeylist(stResult),"textNoCase"),"bodyview,type,view") />
		<cfset assertEquals(stResult.type, "farFU") />
		<cfset assertEquals(stResult.view, "displayPageTest") />
		<cfset assertEquals(stResult.bodyview, "displayTypeBodyTest") />
	</cffunction>
	
	<cffunction displayname="Parse: /typename/viewalias/bodyname" hint="Checks that this friendly URL is parsed as type, view and body" name="parseFU_typename_viewalias_bodyname" access="public">
		<cfset var stResult = this.farFU.getURLStructByURL(friendlyURL="/farFU/test-page-default/displayTypeBodyTest") />
		
		<cfset assertEquals(listsort(structkeylist(stResult),"textNoCase"),"bodyview,type,view") />
		<cfset assertEquals(stResult.type, "farFU") />
		<cfset assertEquals(stResult.view, "displayPageTest") />
		<cfset assertEquals(stResult.bodyview, "displayTypeBodyTest") />
	</cffunction>
	
	<cffunction displayname="Parse: /typename/viewalias/bodyalias" hint="Checks that this friendly URL is parsed as type, view and body" name="parseFU_typename_viewalias_bodyalias" access="public">
		<cfset var stResult = this.farFU.getURLStructByURL(friendlyURL="/farFU/test-page-default/test-body-type") />
		
		<cfset assertEquals(listsort(structkeylist(stResult),"textNoCase"),"bodyview,type,view") />
		<cfset assertEquals(stResult.type, "farFU") />
		<cfset assertEquals(stResult.view, "displayPageTest") />
		<cfset assertEquals(stResult.bodyview, "displayTypeBodyTest") />
	</cffunction>
	
	<cffunction displayname="Parse: /typealias/viewname/bodyname" hint="Checks that this friendly URL is parsed as type, view and body" name="parseFU_typealias_viewname_bodyname" access="public">
		<cfset var stResult = this.farFU.getURLStructByURL(friendlyURL="/fu/displayPageTest/displayTypeBodyTest") />
		
		<cfset assertEquals(listsort(structkeylist(stResult),"textNoCase"),"bodyview,type,view") />
		<cfset assertEquals(stResult.type, "farFU") />
		<cfset assertEquals(stResult.view, "displayPageTest") />
		<cfset assertEquals(stResult.bodyview, "displayTypeBodyTest") />
	</cffunction>
	
	<cffunction displayname="Parse: /typealias/viewname/bodyalias" hint="Checks that this friendly URL is parsed as type, view and body" name="parseFU_typealias_viewname_bodyalias" access="public">
		<cfset var stResult = this.farFU.getURLStructByURL(friendlyURL="/fu/displayPageTest/test-body-type") />
		
		<cfset assertEquals(listsort(structkeylist(stResult),"textNoCase"),"bodyview,type,view") />
		<cfset assertEquals(stResult.type, "farFU") />
		<cfset assertEquals(stResult.view, "displayPageTest") />
		<cfset assertEquals(stResult.bodyview, "displayTypeBodyTest") />
	</cffunction>
	
	<cffunction displayname="Parse: /typealias/viewalias/bodyname" hint="Checks that this friendly URL is parsed as type, view and body" name="parseFU_typealias_viewalias_bodyname" access="public">
		<cfset var stResult = this.farFU.getURLStructByURL(friendlyURL="/fu/test-page-default/displayTypeBodyTest") />
		
		<cfset assertEquals(listsort(structkeylist(stResult),"textNoCase"),"bodyview,type,view") />
		<cfset assertEquals(stResult.type, "farFU") />
		<cfset assertEquals(stResult.view, "displayPageTest") />
		<cfset assertEquals(stResult.bodyview, "displayTypeBodyTest") />
	</cffunction>
	
	<cffunction displayname="Parse: /typealias/viewalias/bodyalias" hint="Checks that this friendly URL is parsed as type, view and body" name="parseFU_typealias_viewalias_bodyalias" access="public">
		<cfset var stResult = this.farFU.getURLStructByURL(friendlyURL="/fu/test-page-default/test-body-type") />
		
		<cfset assertEquals(listsort(structkeylist(stResult),"textNoCase"),"bodyview,type,view") />
		<cfset assertEquals(stResult.type, "farFU") />
		<cfset assertEquals(stResult.view, "displayPageTest") />
		<cfset assertEquals(stResult.bodyview, "displayTypeBodyTest") />
	</cffunction>
	
	<cffunction displayname="Parse: /?type=typename&view=viewname&bodyview=bodyname" hint="Checks that this friendly URL is parsed as type, view and body" name="parseFU_qs_typename_viewname_bodyname" access="public">
		<cfset var stURL = structnew() />
		<cfset var stResult = structnew() />
		
		<cfset stURL.furl = "/" />
		<cfset stURL.type = "farFU" />
		<cfset stURL.view = "displayPageTest" />
		<cfset stURL.bodyview = "displayTypeBodyTest" />
		
		<cfset stResult = this.farFU.parseURL(stURL=stURL) />
		
		<cfset assertEquals(listsort(structkeylist(stResult),"textNoCase"),"__allowredirect,bodyview,furl,type,view") />
		<cfset assertEquals(stResult.type, "farFU") />
		<cfset assertEquals(stResult.view, "displayPageTest") />
		<cfset assertEquals(stResult.bodyview, "displayTypeBodyTest") />
	</cffunction>
	
	<cffunction displayname="Parse: /?type=typealias&view=viewalias&bodyview=bodyalias" hint="Checks that this friendly URL is parsed as type, view and body" name="parseFU_qs_typealias_viewalias_bodyalias" access="public">
		<cfset var stURL = structnew() />
		<cfset var stResult = structnew() />
		
		<cfset stURL.furl = "/" />
		<cfset stURL.type = "fu" />
		<cfset stURL.view = "test-page-default" />
		<cfset stURL.bodyview = "test-body-type" />
		
		<cfset stResult = this.farFU.parseURL(stURL=stURL) />
		
		<cfset assertEquals(listsort(structkeylist(stResult),"textNoCase"),"__allowredirect,bodyview,furl,type,view") />
		<cfset assertEquals(stResult.type, "farFU") />
		<cfset assertEquals(stResult.view, "displayPageTest") />
		<cfset assertEquals(stResult.bodyview, "displayTypeBodyTest") />
	</cffunction>
		
	<cffunction displayname="Parse: /typealias/viewalias/objectbodyalias" hint="Checks that this friendly URL is as invalid due to the attempt to use an object-bound webskin" name="parseFU_typealias_viewalias_objectbodyalias" access="public">
		<cfset var stURL = structnew() />
		<cfset var stResult = structnew() />
		<cfset var error = false />
		
		<cfset stURL.furl = "/fu/test-page-default/test-body-default" />
		
		<cftry>
			<cfset stResult = this.farFU.parseURL(stURL=stURL) />
			
			<cfcatch>
				<cfset assertEquals(cfcatch.message,"You are trying to bind a type [farFU] to an object webskin [displayBodyTest]") />
				<cfset error = true />
			</cfcatch>
		</cftry>
		
		<cfif not error>
			<cfset fail("Error should have been thrown: 'You are trying to bind a type [farFU] to an object webskin [displayBodyTest]'") />
		</cfif>
	</cffunction>
	
	<cffunction displayname="Parse: /typealias/viewalias/bodyalias/param1/value1/param2/value2" hint="Checks that this friendly URL is parsed as type, view, body, and two parameters" name="parseFU_typealias_viewalias_bodyalias_parameters" access="public">
		<cfset var stResult = this.farFU.getURLStructByURL(friendlyURL="/fu/test-page-default/test-body-type/param1/value1/param2/value2") />
		
		<cfset assertEquals(listsort(structkeylist(stResult),"textNoCase"),"bodyview,param1,param2,type,view") />
		<cfset assertEquals(stResult.type, "farFU") />
		<cfset assertEquals(stResult.view, "displayPageTest") />
		<cfset assertEquals(stResult.bodyview, "displayTypeBodyTest") />
		<cfset assertEquals(stResult.param1, "value1") />
		<cfset assertEquals(stResult.param2, "value2") />
	</cffunction>
	
	<!--- Constructed FU: only objectid --->
	<cffunction displayname="Parse: /objectid" hint="Checks that this friendly URL is parsed as object and type" name="parseFU_objectid" access="public">
		<cfset var stResult = this.farFU.getURLStructByURL(friendlyURL="/#this.testFU.objectid#") />
		
		<cfset assertEquals(structkeylist(stResult),"objectid,type") />
		<cfset assertEquals(stResult.objectid, this.testFU.objectid) />
		<cfset assertEquals(stResult.type, "farFU") />
	</cffunction>
	
	<cffunction displayname="Parse: /objectid/param1/value1/param2/value2" hint="Checks that this friendly URL is parsed as objectid, type, and two parameters" name="parseFU_objectid_parameters" access="public">
		<cfset var stResult = this.farFU.getURLStructByURL(friendlyURL="/#this.testFU.objectid#/param1/value1/param2/value2") />
		
		<cfset assertEquals(listsort(structkeylist(stResult),"textNoCase"),"objectid,param1,param2,type") />
		<cfset assertEquals(stResult.objectid, this.testFU.objectid) />
		<cfset assertEquals(stResult.type, "farFU") />
		<cfset assertEquals(stResult.param1, "value1") />
		<cfset assertEquals(stResult.param2, "value2") />
	</cffunction>
	
	<!--- Constructed FU: objectid and view --->
	<cffunction displayname="Parse: /objectid/viewname" hint="Checks that this friendly URL is parsed as objectid, type, and view" name="parseFU_objectid_viewname" access="public">
		<cfset var stResult = this.farFU.getURLStructByURL(friendlyURL="/#this.testFU.objectid#/displayPageTest") />
		
		<cfset assertEquals(listsort(structkeylist(stResult),"textNoCase"),"objectid,type,view") />
		<cfset assertEquals(stResult.objectid, this.testFU.objectid) />
		<cfset assertEquals(stResult.type, "farFU") />
		<cfset assertEquals(stResult.view, "displayPageTest") />
	</cffunction>
	
	<cffunction displayname="Parse: /objectid/viewalias" hint="Checks that this friendly URL is parsed as objectid, type, and view" name="parseFU_objectid_viewalias" access="public">
		<cfset var stResult = this.farFU.getURLStructByURL(friendlyURL="/#this.testFU.objectid#/test-page-default") />
		
		<cfset assertEquals(listsort(structkeylist(stResult),"textNoCase"),"objectid,type,view") />
		<cfset assertEquals(stResult.objectid, this.testFU.objectid) />
		<cfset assertEquals(stResult.type, "farFU") />
		<cfset assertEquals(stResult.view, "displayPageTest") />
	</cffunction>
	
	<cffunction displayname="Parse: /?objectid=objectid&view=viewname" hint="Checks that this friendly URL is parsed as objectid, type and view" name="parseFU_qs_objectid_viewname" access="public">
		<cfset var stURL = structnew() />
		<cfset var stResult = structnew() />
		
		<cfset stURL.furl = "/" />
		<cfset stURL.objectid = this.testFU.objectid />
		<cfset stURL.view = "displayPageTest" />
		
		<cfset stResult = this.farFU.parseURL(stURL=stURL) />
		
		<cfset assertEquals(listsort(structkeylist(stResult),"textNoCase"),"__allowredirect,furl,objectid,type,view") />
		<cfset assertEquals(stResult.objectid, this.testFU.objectid) />
		<cfset assertEquals(stResult.type, "farFU") />
		<cfset assertEquals(stResult.view, "displayPageTest") />
	</cffunction>
	
	<cffunction displayname="Parse: /?objectid=objectid&view=viewalias" hint="Checks that this friendly URL is parsed as objectid, type and view" name="parseFU_qs_objectid_viewalias" access="public">
		<cfset var stURL = structnew() />
		<cfset var stResult = structnew() />
		
		<cfset stURL.furl = "/" />
		<cfset stURL.objectid = this.testFU.objectid />
		<cfset stURL.view = "test-page-default" />
		
		<cfset stResult = this.farFU.parseURL(stURL=stURL) />
		
		<cfset assertEquals(listsort(structkeylist(stResult),"textNoCase"),"__allowredirect,furl,objectid,type,view") />
		<cfset assertEquals(stResult.objectid, this.testFU.objectid) />
		<cfset assertEquals(stResult.type, "farFU") />
		<cfset assertEquals(stResult.view, "displayPageTest") />
	</cffunction>
	
	<cffunction displayname="Parse: /objectid/viewalias/param1/value1/param2/value2" hint="Checks that this friendly URL is parsed as objectid, type, view, and two parameters" name="parseFU_objectid_viewalias_parameters" access="public">
		<cfset var stResult = this.farFU.getURLStructByURL(friendlyURL="/#this.testFU.objectid#/test-page-default/param1/value1/param2/value2") />
		
		<cfset assertEquals(listsort(structkeylist(stResult),"textNoCase"),"objectid,param1,param2,type,view") />
		<cfset assertEquals(stResult.objectid, this.testFU.objectid) />
		<cfset assertEquals(stResult.type, "farFU") />
		<cfset assertEquals(stResult.view, "displayPageTest") />
		<cfset assertEquals(stResult.param1, "value1") />
		<cfset assertEquals(stResult.param2, "value2") />
	</cffunction>
	
	<cffunction displayname="Parse: /objectid/typeviewalias" hint="Checks that this friendly URL is as invalid due to the attempt to use an type-bound webskin" name="parseFU_objectid_typeviewalias" access="public">
		<cfset var stURL = structnew() />
		<cfset var stResult = structnew() />
		<cfset var error = false />
		
		<cfset stURL.furl = "/#this.testFU.objectid#/test-page-type" />
		
		<cftry>
			<cfset stResult = this.farFU.parseURL(stURL=stURL) />
			
			<cfcatch>
				<cfset assertEquals(cfcatch.message,"You are trying to bind an object [#this.testFU.objectid#] to a type webskin [displayTypeTest]") />
				<cfset error = true />
			</cfcatch>
		</cftry>
		
		<cfif not error>
			<cfset fail("Error should have been thrown: 'You are trying to bind a type [#this.testFU.objectid#] to an object webskin [displayTypeTest]'") />
		</cfif>
	</cffunction>
	
	<!--- Constructed FU: objectid and bodyview --->
	<cffunction displayname="Parse: /objectid/bodyname" hint="Checks that this friendly URL is parsed as objectid, type, and bodyview" name="parseFU_objectid_bodyname" access="public">
		<cfset var stResult = this.farFU.getURLStructByURL(friendlyURL="/#this.testFU.objectid#/displayBodyTest") />
		
		<cfset assertEquals(listsort(structkeylist(stResult),"textNoCase"),"bodyview,objectid,type") />
		<cfset assertEquals(stResult.objectid, this.testFU.objectid) />
		<cfset assertEquals(stResult.type, "farFU") />
		<cfset assertEquals(stResult.bodyView, "displayBodyTest") />
	</cffunction>
	
	<cffunction displayname="Parse: /objectid/bodyalias" hint="Checks that this friendly URL is parsed as objectid, type, and bodyview" name="parseFU_objectid_bodyalias" access="public">
		<cfset var stResult = this.farFU.getURLStructByURL(friendlyURL="/#this.testFU.objectid#/test-body-default") />
		
		<cfset assertEquals(listsort(structkeylist(stResult),"textNoCase"),"bodyview,objectid,type") />
		<cfset assertEquals(stResult.objectid, this.testFU.objectid) />
		<cfset assertEquals(stResult.type, "farFU") />
		<cfset assertEquals(stResult.bodyView, "displayBodyTest") />
	</cffunction>
	
	<cffunction displayname="Parse: /?objectid=objectid&bodyview=bodyname" hint="Checks that this friendly URL is parsed as objectid, type and bodyview" name="parseFU_qs_objectid_bodyname" access="public">
		<cfset var stURL = structnew() />
		<cfset var stResult = structnew() />
		
		<cfset stURL.furl = "/" />
		<cfset stURL.objectid = this.testFU.objectid />
		<cfset stURL.bodyview = "displayBodyTest" />
		
		<cfset stResult = this.farFU.parseURL(stURL=stURL) />
		
		<cfset assertEquals(listsort(structkeylist(stResult),"textNoCase"),"__allowredirect,bodyview,furl,objectid,type") />
		<cfset assertEquals(stResult.objectid, this.testFU.objectid) />
		<cfset assertEquals(stResult.type, "farFU") />
		<cfset assertEquals(stResult.bodyview, "displayBodyTest") />
	</cffunction>
	
	<cffunction displayname="Parse: /?objectid=objectid&bodyview=bodyalias" hint="Checks that this friendly URL is parsed as objectid, type and bodyview" name="parseFU_qs_objectid_bodyalias" access="public">
		<cfset var stURL = structnew() />
		<cfset var stResult = structnew() />
		
		<cfset stURL.furl = "/" />
		<cfset stURL.objectid = this.testFU.objectid />
		<cfset stURL.bodyview = "test-body-default" />
		
		<cfset stResult = this.farFU.parseURL(stURL=stURL) />
		
		<cfset assertEquals(listsort(structkeylist(stResult),"textNoCase"),"__allowredirect,bodyview,furl,objectid,type") />
		<cfset assertEquals(stResult.objectid, this.testFU.objectid) />
		<cfset assertEquals(stResult.type, "farFU") />
		<cfset assertEquals(stResult.bodyview, "displayBodyTest") />
	</cffunction>
	
	<cffunction displayname="Parse: /objectid/bodyalias/param1/value1/param2/value2" hint="Checks that this friendly URL is parsed as objectid, type, bodyview, and two parameters" name="parseFU_objectid_bodyalias_parameters" access="public">
		<cfset var stResult = this.farFU.getURLStructByURL(friendlyURL="/#this.testFU.objectid#/test-body-default/param1/value1/param2/value2") />
		
		<cfset assertEquals(listsort(structkeylist(stResult),"textNoCase"),"bodyview,objectid,param1,param2,type") />
		<cfset assertEquals(stResult.objectid, this.testFU.objectid) />
		<cfset assertEquals(stResult.type, "farFU") />
		<cfset assertEquals(stResult.bodyView, "displayBodyTest") />
		<cfset assertEquals(stResult.param1, "value1") />
		<cfset assertEquals(stResult.param2, "value2") />
	</cffunction>
	
	<cffunction displayname="Parse: /objectid/typebodyalias" hint="Checks that this friendly URL is as invalid due to the attempt to use an type-bound webskin" name="parseFU_objectid_typebodyalias" access="public">
		<cfset var stURL = structnew() />
		<cfset var stResult = structnew() />
		<cfset var error = false />
		
		<cfset stURL.furl = "/#this.testFU.objectid#/test-body-type" />
		
		<cftry>
			<cfset stResult = this.farFU.parseURL(stURL=stURL) />
			
			<cfcatch>
				<cfset assertEquals(cfcatch.message,"You are trying to bind an object [#this.testFU.objectid#] to a type webskin [displayTypeBodyTest]") />
				<cfset error = true />
			</cfcatch>
		</cftry>
		
		<cfif not error>
			<cfset fail("Error should have been thrown: 'You are trying to bind an object [#this.testFU.objectid#] to a type webskin [displayTypeBodyTest]':#stResult.toString()#") />
		</cfif>
	</cffunction>
	
	<!--- Constructed FU: objectid, view, bodyview --->
	<cffunction displayname="Parse: /objectid/viewname/bodyname" hint="Checks that this friendly URL is parsed as objectid, type, view and body" name="parseFU_objectid_viewname_bodyname" access="public">
		<cfset var stResult = this.farFU.getURLStructByURL(friendlyURL="/#this.testFU.objectid#/displayPageTest/displayBodyTest") />
		
		<cfset assertEquals(listsort(structkeylist(stResult),"textNoCase"),"bodyview,objectid,type,view") />
		<cfset assertEquals(stResult.objectid, this.testFU.objectid) />
		<cfset assertEquals(stResult.type, "farFU") />
		<cfset assertEquals(stResult.view, "displayPageTest") />
		<cfset assertEquals(stResult.bodyview, "displayBodyTest") />
	</cffunction>
	
	<cffunction displayname="Parse: /objectid/viewname/bodyalias" hint="Checks that this friendly URL is parsed as objectid, type, view and body" name="parseFU_objectid_viewname_bodyalias" access="public">
		<cfset var stResult = this.farFU.getURLStructByURL(friendlyURL="/#this.testFU.objectid#/displayPageTest/test-body-default") />
		
		<cfset assertEquals(listsort(structkeylist(stResult),"textNoCase"),"bodyview,objectid,type,view") />
		<cfset assertEquals(stResult.objectid, this.testFU.objectid) />
		<cfset assertEquals(stResult.type, "farFU") />
		<cfset assertEquals(stResult.view, "displayPageTest") />
		<cfset assertEquals(stResult.bodyview, "displayBodyTest") />
	</cffunction>
	
	<cffunction displayname="Parse: /objectid/viewalias/bodyname" hint="Checks that this friendly URL is parsed as objectid, type, view and body" name="parseFU_objectid_viewalias_bodyname" access="public">
		<cfset var stResult = this.farFU.getURLStructByURL(friendlyURL="/#this.testFU.objectid#/test-page-default/displayBodyTest") />
		
		<cfset assertEquals(listsort(structkeylist(stResult),"textNoCase"),"bodyview,objectid,type,view") />
		<cfset assertEquals(stResult.objectid, this.testFU.objectid) />
		<cfset assertEquals(stResult.type, "farFU") />
		<cfset assertEquals(stResult.view, "displayPageTest") />
		<cfset assertEquals(stResult.bodyview, "displayBodyTest") />
	</cffunction>
	
	<cffunction displayname="Parse: /objectid/viewalias/bodyalias" hint="Checks that this friendly URL is parsed as objectid, type, view and body" name="parseFU_objectid_viewalias_bodyalias" access="public">
		<cfset var stResult = this.farFU.getURLStructByURL(friendlyURL="/#this.testFU.objectid#/test-page-default/test-body-default") />
		
		<cfset assertEquals(listsort(structkeylist(stResult),"textNoCase"),"bodyview,objectid,type,view") />
		<cfset assertEquals(stResult.objectid, this.testFU.objectid) />
		<cfset assertEquals(stResult.type, "farFU") />
		<cfset assertEquals(stResult.view, "displayPageTest") />
		<cfset assertEquals(stResult.bodyview, "displayBodyTest") />
	</cffunction>
	
	<cffunction displayname="Parse: /?objectid=objectid&view=viewalias&body=bodyalias" hint="Checks that this friendly URL is parsed as objectid, type, view and body alias" name="parseFU_qs_objectid_viewalias_bodyalias" access="public">
		<cfset var stURL = structnew() />
		<cfset var stResult = structnew() />
		
		<cfset stURL.furl = "/" />
		<cfset stURL.objectid = this.testFU.objectid />
		<cfset stURL.view = "test-page-default" />
		<cfset stURL.bodyview = "test-body-default" />
		
		<cfset stResult = this.farFU.parseURL(stURL=stURL) />
		
		<cfset assertEquals(listsort(structkeylist(stResult),"textNoCase"),"__allowredirect,bodyview,furl,objectid,type,view") />
		<cfset assertEquals(stResult.objectid, this.testFU.objectid) />
		<cfset assertEquals(stResult.type, "farFU") />
		<cfset assertEquals(stResult.view, "displayPageTest") />
		<cfset assertEquals(stResult.bodyview, "displayBodyTest") />
	</cffunction>
	
	<cffunction displayname="Parse: /objectid/viewalias/bodyalias/param1/value1/param2/value2" hint="Checks that this friendly URL is parsed as objectid, type, view, body, and two parameters" name="parseFU_objectid_viewalias_bodyalias_parameters" access="public">
		<cfset var stResult = this.farFU.getURLStructByURL(friendlyURL="/#this.testFU.objectid#/test-page-default/test-body-default/param1/value1/param2/value2") />
		
		<cfset assertEquals(listsort(structkeylist(stResult),"textNoCase"),"bodyview,objectid,param1,param2,type,view") />
		<cfset assertEquals(stResult.objectid, this.testFU.objectid) />
		<cfset assertEquals(stResult.type, "farFU") />
		<cfset assertEquals(stResult.view, "displayPageTest") />
		<cfset assertEquals(stResult.bodyview, "displayBodyTest") />
		<cfset assertEquals(stResult.param1, "value1") />
		<cfset assertEquals(stResult.param2, "value2") />
	</cffunction>
	
	<!--- Normal FU: only FU --->
	<cffunction displayname="Parse: /fu" hint="Checks that this friendly URL is parsed as object and type" name="parseFU_fu" access="public">
		<cfset var stResult = this.farFU.getURLStructByURL(friendlyURL="/test/fu") />
		
		<cfset assertEquals(structkeylist(stResult),"objectid,type") />
		<cfset assertEquals(stResult.objectid, this.testFU.objectid) />
		<cfset assertEquals(stResult.type, "farFU") />
	</cffunction>
	
	<cffunction displayname="Parse: /fu/param1/value1/param2/value2" hint="Checks that this friendly URL is parsed as objectid, type, and two parameters" name="parseFU_fu_parameters" access="public">
		<cfset var stResult = this.farFU.getURLStructByURL(friendlyURL="/test/fu/param1/value1/param2/value2") />
		
		<cfset assertEquals(listsort(structkeylist(stResult),"textNoCase"),"objectid,param1,param2,type") />
		<cfset assertEquals(stResult.objectid, this.testFU.objectid) />
		<cfset assertEquals(stResult.type, "farFU") />
		<cfset assertEquals(stResult.param1, "value1") />
		<cfset assertEquals(stResult.param2, "value2") />
	</cffunction>
	
	<!--- Normal FU: FU and view --->
	<cffunction displayname="Parse: /fu/viewname" hint="Checks that this friendly URL is parsed as objectid, type, and view" name="parseFU_fu_viewname" access="public">
		<cfset var stResult = this.farFU.getURLStructByURL(friendlyURL="/test/fu/displayPageTest") />
		
		<cfset assertEquals(listsort(structkeylist(stResult),"textNoCase"),"objectid,type,view") />
		<cfset assertEquals(stResult.objectid, this.testFU.objectid) />
		<cfset assertEquals(stResult.type, "farFU") />
		<cfset assertEquals(stResult.view, "displayPageTest") />
	</cffunction>
	
	<cffunction displayname="Parse: /fu/viewalias" hint="Checks that this friendly URL is parsed as objectid, type, and view" name="parseFU_fu_viewalias" access="public">
		<cfset var stResult = this.farFU.getURLStructByURL(friendlyURL="/test/fu/test-page-default") />
		
		<cfset assertEquals(listsort(structkeylist(stResult),"textNoCase"),"objectid,type,view") />
		<cfset assertEquals(stResult.objectid, this.testFU.objectid) />
		<cfset assertEquals(stResult.type, "farFU") />
		<cfset assertEquals(stResult.view, "displayPageTest") />
	</cffunction>
	
	<cffunction displayname="Parse: /fu/viewalias/param1/value1/param2/value2" hint="Checks that this friendly URL is parsed as fu, type, view, and two parameters" name="parseFU_fu_viewalias_parameters" access="public">
		<cfset var stResult = this.farFU.getURLStructByURL(friendlyURL="/test/fu/test-page-default/param1/value1/param2/value2") />
		
		<cfset assertEquals(listsort(structkeylist(stResult),"textNoCase"),"objectid,param1,param2,type,view") />
		<cfset assertEquals(stResult.objectid, this.testFU.objectid) />
		<cfset assertEquals(stResult.type, "farFU") />
		<cfset assertEquals(stResult.view, "displayPageTest") />
		<cfset assertEquals(stResult.param1, "value1") />
		<cfset assertEquals(stResult.param2, "value2") />
	</cffunction>

	<cffunction displayname="Parse: /fu?objectid=objectid&view=viewalias" hint="Checks that this friendly URL is parsed as objectid, type, and view" name="parseFU_fu_qs_viewalias" access="public">
		<cfset var stURL = structnew() />
		<cfset var stResult = structnew() />
		
		<cfset stURL.furl = "/test/fu" />
		<cfset stURL.view = "test-page-default" />
		
		<cfset stResult = this.farFU.parseURL(stURL=stURL) />
		
		<cfset assertEquals(listsort(structkeylist(stResult),"textNoCase"),"__allowredirect,furl,objectid,type,view") />
		<cfset assertEquals(stResult.objectid, this.testFU.objectid) />
		<cfset assertEquals(stResult.type, "farFU") />
		<cfset assertEquals(stResult.view, "displayPageTest") />
	</cffunction>
	
	<!--- Normal FU: FU, view, bodyview --->
	<cffunction displayname="Parse: /fu/viewname/bodyname" hint="Checks that this friendly URL is parsed as objectid, type, view and body" name="parseFU_fu_viewname_bodyname" access="public">
		<cfset var stResult = this.farFU.getURLStructByURL(friendlyURL="/test/fu/displayPageTest/displayBodyTest") />
		
		<cfset assertEquals(listsort(structkeylist(stResult),"textNoCase"),"bodyview,objectid,type,view") />
		<cfset assertEquals(stResult.objectid, this.testFU.objectid) />
		<cfset assertEquals(stResult.type, "farFU") />
		<cfset assertEquals(stResult.view, "displayPageTest") />
		<cfset assertEquals(stResult.bodyview, "displayBodyTest") />
	</cffunction>
	
	<cffunction displayname="Parse: /fu/viewname/bodyalias" hint="Checks that this friendly URL is parsed as objectid, type, view and body" name="parseFU_fu_viewname_bodyalias" access="public">
		<cfset var stResult = this.farFU.getURLStructByURL(friendlyURL="/test/fu/displayPageTest/test-body-default") />
		
		<cfset assertEquals(listsort(structkeylist(stResult),"textNoCase"),"bodyview,objectid,type,view") />
		<cfset assertEquals(stResult.objectid, this.testFU.objectid) />
		<cfset assertEquals(stResult.type, "farFU") />
		<cfset assertEquals(stResult.view, "displayPageTest") />
		<cfset assertEquals(stResult.bodyview, "displayBodyTest") />
	</cffunction>
	
	<cffunction displayname="Parse: /fu/viewalias/bodyname" hint="Checks that this friendly URL is parsed as objectid, type, view and body" name="parseFU_fu_viewalias_bodyname" access="public">
		<cfset var stResult = this.farFU.getURLStructByURL(friendlyURL="/test/fu/test-page-default/displayBodyTest") />
		
		<cfset assertEquals(listsort(structkeylist(stResult),"textNoCase"),"bodyview,objectid,type,view") />
		<cfset assertEquals(stResult.objectid, this.testFU.objectid) />
		<cfset assertEquals(stResult.type, "farFU") />
		<cfset assertEquals(stResult.view, "displayPageTest") />
		<cfset assertEquals(stResult.bodyview, "displayBodyTest") />
	</cffunction>
	
	<cffunction displayname="Parse: /fu/viewalias/bodyalias" hint="Checks that this friendly URL is parsed as objectid, type, view and body" name="parseFU_fu_viewalias_bodyalias" access="public">
		<cfset var stResult = this.farFU.getURLStructByURL(friendlyURL="/test/fu/test-page-default/test-body-default") />
		
		<cfset assertEquals(listsort(structkeylist(stResult),"textNoCase"),"bodyview,objectid,type,view") />
		<cfset assertEquals(stResult.objectid, this.testFU.objectid) />
		<cfset assertEquals(stResult.type, "farFU") />
		<cfset assertEquals(stResult.view, "displayPageTest") />
		<cfset assertEquals(stResult.bodyview, "displayBodyTest") />
	</cffunction>
	
	<cffunction displayname="Parse: /fu?objectid=objectid&bodyview=bodyalias" hint="Checks that this friendly URL is parsed as objectid, type, and bodyview" name="parseFU_fu_qs_bodyalias" access="public">
		<cfset var stURL = structnew() />
		<cfset var stResult = structnew() />
		
		<cfset stURL.furl = "/test/fu" />
		<cfset stURL.bodyview = "test-body-default" />
		
		<cfset stResult = this.farFU.parseURL(stURL=stURL) />
		
		<cfset assertEquals(listsort(structkeylist(stResult),"textNoCase"),"__allowredirect,bodyview,furl,objectid,type") />
		<cfset assertEquals(stResult.objectid, this.testFU.objectid) />
		<cfset assertEquals(stResult.type, "farFU") />
		<cfset assertEquals(stResult.bodyview, "displayBodyTest") />
	</cffunction>
	
	<cffunction displayname="Parse: /fu/viewalias/bodyalias/param1/value1/param2/value2" hint="Checks that this friendly URL is parsed as objectid, type, view, body, and two parameters" name="parseFU_fu_viewalias_bodyalias_parameters" access="public">
		<cfset var stResult = this.farFU.getURLStructByURL(friendlyURL="/test/fu/test-page-default/test-body-default/param1/value1/param2/value2") />
		
		<cfset assertEquals(listsort(structkeylist(stResult),"textNoCase"),"bodyview,objectid,param1,param2,type,view") />
		<cfset assertEquals(stResult.objectid, this.testFU.objectid) />
		<cfset assertEquals(stResult.type, "farFU") />
		<cfset assertEquals(stResult.view, "displayPageTest") />
		<cfset assertEquals(stResult.bodyview, "displayBodyTest") />
		<cfset assertEquals(stResult.param1, "value1") />
		<cfset assertEquals(stResult.param2, "value2") />
	</cffunction>
	
	<cffunction displayname="Parse: /fu?objectid=objectid&view=viewalias&bodyview=bodyalias" hint="Checks that this friendly URL is parsed as objectid, type, view and bodyview" name="parseFU_fu_qs_viewalias_bodyalias" access="public">
		<cfset var stURL = structnew() />
		<cfset var stResult = structnew() />
		
		<cfset stURL.furl = "/test/fu" />
		<cfset stURL.view = "test-page-default" />
		<cfset stURL.bodyview = "test-body-default" />
		
		<cfset stResult = this.farFU.parseURL(stURL=stURL) />
		
		<cfset assertEquals(listsort(structkeylist(stResult),"textNoCase"),"__allowredirect,bodyview,furl,objectid,type,view") />
		<cfset assertEquals(stResult.objectid, this.testFU.objectid) />
		<cfset assertEquals(stResult.type, "farFU") />
		<cfset assertEquals(stResult.view, "displayPageTest") />
		<cfset assertEquals(stResult.bodyview, "displayBodyTest") />
	</cffunction>
	
	
	<!--- Constructed FU: type --->
	<cffunction displayname="Generate: /typealias" hint="Checks that this friendly URL is generated" name="generateFU_typealias" access="public">
		<cfset var furl = this.fapi.getLink(type="farFU") />
		
		<cfset assertEquals(furl,"/fu") />
	</cffunction>

	<cffunction displayname="Generate: /typealias/param1/value1/param2/value2 from urlParameters" hint="Checks that this friendly URL is generated" name="generateFU_typealias_urlParameters" access="public">
		<cfset var urlParameters = "param1=value1&param2=value2" />
		<cfset var furl = "" />
		
		<!--- urlParameters --->
		<cfset furl = this.fapi.getLink(type="farFU",urlParameters=urlParameters) />
		<cfset assertEquals(furl,"/fu/param1/value1/param2/value2") />
	</cffunction>

	<cffunction displayname="Generate: /typealias/param1/value1/param2/value2 from stParameters" hint="Checks that this friendly URL is generated" name="generateFU_typealias_stParameters" access="public">
		<cfset var stParameters = structnew() />
		<cfset var furl = "" />
		
		<!--- stParameters --->
		<cfset stParameters["param1"] = "value1" />
		<cfset stParameters["param2"] = "value2" />
		<cfset furl = this.fapi.getLink(type="farFU",stParameters=stParameters) />
		<cfset assertEquals(furl,"/fu/param1/value1/param2/value2") />
	</cffunction>

	<!--- Constructed FU: type and view --->
	<cffunction displayname="Generate: /typealias/viewalias" hint="Checks that this friendly URL is generated" name="generateFU_typealias_viewalias" access="public">
		<cfset var furl = this.fapi.getLink(type="farFU",view="displayTypeTest") />
		
		<cfset assertEquals(furl,"/fu/test-page-type") />
	</cffunction>

	<cffunction displayname="Generate: /typealias/viewalias/param1/value1/param2/value2 from urlParameters" hint="Checks that this friendly URL is generated" name="generateFU_typealias_viewalias_urlParameters" access="public">
		<cfset var urlParameters = "param1=value1&param2=value2" />
		<cfset var furl = "" />
		
		<!--- urlParameters --->
		<cfset furl = this.fapi.getLink(type="farFU",view="displayTypeTest",urlParameters=urlParameters) />
		<cfset assertEquals(furl,"/fu/test-page-type/param1/value1/param2/value2") />
	</cffunction>

	<cffunction displayname="Generate: /typealias/viewalias/param1/value1/param2/value2 from stParameters" hint="Checks that this friendly URL is generated" name="generateFU_typealias_viewalias_stParameters" access="public">
		<cfset var stParameters = structnew() />
		<cfset var furl = "" />
		
		<!--- stParameters --->
		<cfset stParameters["param1"] = "value1" />
		<cfset stParameters["param2"] = "value2" />
		<cfset furl = this.fapi.getLink(type="farFU",view="displayTypeTest",stParameters=stParameters) />
		<cfset assertEquals(furl,"/fu/test-page-type/param1/value1/param2/value2") />
	</cffunction>

	<!--- Constructed FU: type and bodyview --->
	<cffunction displayname="Generate: /typealias/bodyalias" hint="Checks that this friendly URL is generated" name="generateFU_typealias_bodyalias" access="public">
		<cfset var furl = this.fapi.getLink(type="farFU",bodyview="displayTypeBodyTest") />
		
		<cfset assertEquals(furl,"/fu/test-body-type") />
	</cffunction>

	<cffunction displayname="Generate: /typealias/bodyalias/param1/value1/param2/value2 from urlParameters" hint="Checks that this friendly URL is generated" name="generateFU_typealias_bodyalias_urlParameters" access="public">
		<cfset var urlParameters = "param1=value1&param2=value2" />
		<cfset var furl = "" />
		
		<!--- urlParameters --->
		<cfset furl = this.fapi.getLink(type="farFU",bodyview="displayTypeBodyTest",urlParameters=urlParameters) />
		<cfset assertEquals(furl,"/fu/test-body-type/param1/value1/param2/value2") />
	</cffunction>

	<cffunction displayname="Generate: /typealias/bodyalias/param1/value1/param2/value2 from stParameters" hint="Checks that this friendly URL is generated" name="generateFU_typealias_bodyalias_stParameters" access="public">
		<cfset var stParameters = structnew() />
		<cfset var furl = "" />
		
		<!--- stParameters --->
		<cfset stParameters["param1"] = "value1" />
		<cfset stParameters["param2"] = "value2" />
		<cfset furl = this.fapi.getLink(type="farFU",bodyview="displayTypeBodyTest",stParameters=stParameters) />
		<cfset assertEquals(furl,"/fu/test-body-type/param1/value1/param2/value2") />
	</cffunction>

	<!--- Constructed FU: type, view and bodyview --->
	<cffunction displayname="Generate: /typealias/viewalias/bodyalias" hint="Checks that this friendly URL is generated" name="generateFU_typealias_viewalias_bodyalias" access="public">
		<cfset var furl = this.fapi.getLink(type="farFU",view="displayTypeTest",bodyview="displayTypeBodyTest") />
		
		<cfset assertEquals(furl,"/fu/test-page-type/test-body-type") />
	</cffunction>

	<cffunction displayname="Generate: /typealias/viewalias/bodyalias/param1/value1/param2/value2 from urlParameters" hint="Checks that this friendly URL is generated" name="generateFU_typealias_viewalias_bodyalias_urlParameters" access="public">
		<cfset var urlParameters = "param1=value1&param2=value2" />
		<cfset var furl = "" />
		
		<!--- urlParameters --->
		<cfset furl = this.fapi.getLink(type="farFU",view="displayTypeTest",bodyview="displayTypeBodyTest",urlParameters=urlParameters) />
		<cfset assertEquals(furl,"/fu/test-page-type/test-body-type/param1/value1/param2/value2") />
	</cffunction>

	<cffunction displayname="Generate: /typealias/viewalias/bodyalias/param1/value1/param2/value2 from stParameters" hint="Checks that this friendly URL is generated" name="generateFU_typealias_viewalias_bodyalias_stParameters" access="public">
		<cfset var stParameters = structnew() />
		<cfset var furl = "" />
		
		<!--- stParameters --->
		<cfset stParameters["param1"] = "value1" />
		<cfset stParameters["param2"] = "value2" />
		<cfset furl = this.fapi.getLink(type="farFU",view="displayTypeTest",bodyview="displayTypeBodyTest",stParameters=stParameters) />
		<cfset assertEquals(furl,"/fu/test-page-type/test-body-type/param1/value1/param2/value2") />
	</cffunction>

	<!--- Constructed FU: objectid --->
	<cffunction displayname="Generate: /objectid" hint="Checks that this friendly URL is generated" name="generateFU_objectid" access="public">
		<cfset var furl = this.fapi.getLink(objectid=this.testFU2.objectid) />
		
		<cfset assertEquals(furl,"/#this.testFU2.objectid#") />
	</cffunction>

	<cffunction displayname="Generate: /objectid/param1/value1/param2/value2 from urlParameters" hint="Checks that this friendly URL is generated" name="generateFU_objectid_urlParameters" access="public">
		<cfset var urlParameters = "param1=value1&param2=value2" />
		<cfset var furl = "" />
		
		<!--- urlParameters --->
		<cfset furl = this.fapi.getLink(objectid=this.testFU2.objectid,urlParameters=urlParameters) />
		<cfset assertEquals(furl,"/#this.testFU2.objectid#/param1/value1/param2/value2") />
	</cffunction>

	<cffunction displayname="Generate: /objectid/param1/value1/param2/value2 from stParameters" hint="Checks that this friendly URL is generated" name="generateFU_objectid_stParameters" access="public">
		<cfset var stParameters = structnew() />
		<cfset var furl = "" />
		
		<!--- stParameters --->
		<cfset stParameters["param1"] = "value1" />
		<cfset stParameters["param2"] = "value2" />
		<cfset furl = this.fapi.getLink(objectid=this.testFU2.objectid,stParameters=stParameters) />
		<cfset assertEquals(furl,"/#this.testFU2.objectid#/param1/value1/param2/value2") />
	</cffunction>

	<!--- Constructed FU: objectid and view --->
	<cffunction displayname="Generate: /objectid/viewalias" hint="Checks that this friendly URL is generated" name="generateFU_objectid_viewalias" access="public">
		<cfset var furl = this.fapi.getLink(objectid=this.testFU2.objectid,view="displayTypeTest") />
		
		<cfset assertEquals(furl,"/#this.testFU2.objectid#/test-page-type") />
	</cffunction>

	<cffunction displayname="Generate: /objectid/viewalias/param1/value1/param2/value2 from urlParameters" hint="Checks that this friendly URL is generated" name="generateFU_objectid_viewalias_urlParameters" access="public">
		<cfset var urlParameters = "param1=value1&param2=value2" />
		<cfset var furl = "" />
		
		<!--- urlParameters --->
		<cfset furl = this.fapi.getLink(objectid=this.testFU2.objectid,view="displayTypeTest",urlParameters=urlParameters) />
		<cfset assertEquals(furl,"/#this.testFU2.objectid#/test-page-type/param1/value1/param2/value2") />
	</cffunction>

	<cffunction displayname="Generate: /objectid/viewalias/param1/value1/param2/value2 from stParameters" hint="Checks that this friendly URL is generated" name="generateFU_objectid_viewalias_stParameters" access="public">
		<cfset var stParameters = structnew() />
		<cfset var furl = "" />
		
		<!--- stParameters --->
		<cfset stParameters["param1"] = "value1" />
		<cfset stParameters["param2"] = "value2" />
		<cfset furl = this.fapi.getLink(objectid=this.testFU2.objectid,view="displayTypeTest",stParameters=stParameters) />
		<cfset assertEquals(furl,"/#this.testFU2.objectid#/test-page-type/param1/value1/param2/value2") />
	</cffunction>

	<!--- Constructed FU: objectid and bodyview --->
	<cffunction displayname="Generate: /objectid/bodyalias" hint="Checks that this friendly URL is generated" name="generateFU_objectid_bodyalias" access="public">
		<cfset var furl = this.fapi.getLink(objectid=this.testFU2.objectid,bodyview="displayTypeBodyTest") />
		
		<cfset assertEquals(furl,"/#this.testFU2.objectid#/test-body-type") />
	</cffunction>
	
	<cffunction displayname="Generate: /objectid/bodyalias/param1/value1/param2/value2 from urlParameters" hint="Checks that this friendly URL is generated" name="generateFU_objectid_bodyalias_urlParameters" access="public">
		<cfset var urlParameters = "param1=value1&param2=value2" />
		<cfset var furl = "" />
		
		<!--- urlParameters --->
		<cfset furl = this.fapi.getLink(objectid=this.testFU2.objectid,bodyview="displayTypeBodyTest",urlParameters=urlParameters) />
		<cfset assertEquals(furl,"/#this.testFU2.objectid#/test-body-type/param1/value1/param2/value2") />
	</cffunction>
	
	<cffunction displayname="Generate: /objectid/bodyalias/param1/value1/param2/value2 from stParameters" hint="Checks that this friendly URL is generated" name="generateFU_objectid_bodyalias_stParameters" access="public">
		<cfset var stParameters = structnew() />
		<cfset var furl = "" />
		
		<!--- stParameters --->
		<cfset stParameters["param1"] = "value1" />
		<cfset stParameters["param2"] = "value2" />
		<cfset furl = this.fapi.getLink(objectid=this.testFU2.objectid,bodyview="displayTypeBodyTest",stParameters=stParameters) />
		<cfset assertEquals(furl,"/#this.testFU2.objectid#/test-body-type/param1/value1/param2/value2") />
	</cffunction>

	<!--- Constructed FU: objectid, view and bodyview --->
	<cffunction displayname="Generate: /objectid/viewalias/bodyalias" hint="Checks that this friendly URL is generated" name="generateFU_objectid_viewalias_bodyalias" access="public">
		<cfset var furl = this.fapi.getLink(objectid=this.testFU2.objectid,view="displayTypeTest",bodyview="displayTypeBodyTest") />
		
		<cfset assertEquals(furl,"/#this.testFU2.objectid#/test-page-type/test-body-type") />
	</cffunction>
	
	<cffunction displayname="Generate: /objectid/viewalias/bodyalias/param1/value1/param2/value2 from urlParameters" hint="Checks that this friendly URL is generated" name="generateFU_objectid_viewalias_bodyalias_urlParameters" access="public">
		<cfset var urlParameters = "param1=value1&param2=value2" />
		<cfset var furl = "" />
		
		<!--- urlParameters --->
		<cfset furl = this.fapi.getLink(objectid=this.testFU2.objectid,view="displayTypeTest",bodyview="displayTypeBodyTest",urlParameters=urlParameters) />
		<cfset assertEquals(furl,"/#this.testFU2.objectid#/test-page-type/test-body-type/param1/value1/param2/value2") />
	</cffunction>
	
	<cffunction displayname="Generate: /objectid/viewalias/bodyalias/param1/value1/param2/value2 from stParameters" hint="Checks that this friendly URL is generated" name="generateFU_objectid_viewalias_bodyalias_stParameters" access="public">
		<cfset var stParameters = structnew() />
		<cfset var furl = "" />
		
		<!--- stParameters --->
		<cfset stParameters["param1"] = "value1" />
		<cfset stParameters["param2"] = "value2" />
		<cfset furl = this.fapi.getLink(objectid=this.testFU2.objectid,view="displayTypeTest",bodyview="displayTypeBodyTest",stParameters=stParameters) />
		<cfset assertEquals(furl,"/#this.testFU2.objectid#/test-page-type/test-body-type/param1/value1/param2/value2") />
	</cffunction>

	<!--- Normal FU: only FU --->
	<cffunction displayname="Generate: /fu" hint="Checks that this friendly URL is generated" name="generateFU_fu" access="public">
		<cfset var furl = this.fapi.getLink(objectid=this.testFU.objectid) />
		
		<cfset assertEquals(furl,"/test/fu") />
	</cffunction>

	<cffunction displayname="Generate: /fu/param1/value1/param2/value2 from urlParameters" hint="Checks that this friendly URL is generated" name="generateFU_fu_urlParameters" access="public">
		<cfset var urlParameters = "param1=value1&param2=value2" />
		<cfset var furl = "" />
		
		<!--- urlParameters --->
		<cfset furl = this.fapi.getLink(objectid=this.testFU.objectid,urlParameters=urlParameters) />
		<cfset assertEquals(furl,"/test/fu/param1/value1/param2/value2") />
	</cffunction>

	<cffunction displayname="Generate: /fu/param1/value1/param2/value2 from stParameters" hint="Checks that this friendly URL is generated" name="generateFU_fu_stParameters" access="public">
		<cfset var stParameters = structnew() />
		<cfset var furl = "" />
		
		<!--- stParameters --->
		<cfset stParameters["param1"] = "value1" />
		<cfset stParameters["param2"] = "value2" />
		<cfset furl = this.fapi.getLink(objectid=this.testFU.objectid,stParameters=stParameters) />
		<cfset assertEquals(furl,"/test/fu/param1/value1/param2/value2") />
	</cffunction>

	<!--- Normal FU: FU and view --->
	<cffunction displayname="Generate: /fu/viewalias" hint="Checks that this friendly URL is generated" name="generateFU_fu_viewalias" access="public">
		<cfset var furl = this.fapi.getLink(objectid=this.testFU.objectid,view="displayPageTest") />
		
		<cfset assertEquals(furl,"/test/fu/test-page-default") />
	</cffunction>

	<cffunction displayname="Generate: /fu/viewalias/param1/value1/param2/value2 from urlParameters" hint="Checks that this friendly URL is generated" name="generateFU_fu_viewalias_urlParameters" access="public">
		<cfset var urlParameters = "param1=value1&param2=value2" />
		<cfset var furl = "" />
		
		<!--- urlParameters --->
		<cfset furl = this.fapi.getLink(objectid=this.testFU.objectid,view="displayPageTest",urlParameters=urlParameters) />
		<cfset assertEquals(furl,"/test/fu/test-page-default/param1/value1/param2/value2") />
	</cffunction>

	<cffunction displayname="Generate: /fu/viewalias/param1/value1/param2/value2 from stParameters" hint="Checks that this friendly URL is generated" name="generateFU_fu_viewalias_stParameters" access="public">
		<cfset var stParameters = structnew() />
		<cfset var furl = "" />
		
		<!--- stParameters --->
		<cfset stParameters["param1"] = "value1" />
		<cfset stParameters["param2"] = "value2" />
		<cfset furl = this.fapi.getLink(objectid=this.testFU.objectid,view="displayPageTest",stParameters=stParameters) />
		<cfset assertEquals(furl,"/test/fu/test-page-default/param1/value1/param2/value2") />
	</cffunction>

	<!--- Normal FU: FU and body --->
	<cffunction displayname="Generate: /fu/bodyalias" hint="Checks that this friendly URL is generated" name="generateFU_fu_bodyalias" access="public">
		<cfset var furl = this.fapi.getLink(objectid=this.testFU.objectid,bodyview="displayBodyTest") />
		
		<cfset assertEquals(furl,"/test/fu/test-body-default") />
	</cffunction>

	<cffunction displayname="Generate: /fu/bodyalias/param1/value1/param2/value2 from urlParameters" hint="Checks that this friendly URL is generated" name="generateFU_fu_bodyalias_urlParameters" access="public">
		<cfset var urlParameters = "param1=value1&param2=value2" />
		<cfset var furl = "" />
		
		<!--- urlParameters --->
		<cfset furl = this.fapi.getLink(objectid=this.testFU.objectid,bodyview="displayBodyTest",urlParameters=urlParameters) />
		<cfset assertEquals(furl,"/test/fu/test-body-default/param1/value1/param2/value2") />
	</cffunction>

	<cffunction displayname="Generate: /fu/bodyalias/param1/value1/param2/value2 from stParameters" hint="Checks that this friendly URL is generated" name="generateFU_fu_bodyalias_stParameters" access="public">
		<cfset var stParameters = structnew() />
		<cfset var furl = "" />
		
		<!--- stParameters --->
		<cfset stParameters["param1"] = "value1" />
		<cfset stParameters["param2"] = "value2" />
		<cfset furl = this.fapi.getLink(objectid=this.testFU.objectid,bodyview="displayBodyTest",stParameters=stParameters) />
		<cfset assertEquals(furl,"/test/fu/test-body-default/param1/value1/param2/value2") />
	</cffunction>

	<!--- Normal FU: FU, view and body --->
	<cffunction displayname="Generate: /fu/viewalias/bodyalias" hint="Checks that this friendly URL is generated" name="generateFU_fu_viewalias_bodyalias" access="public">
		<cfset var furl = this.fapi.getLink(objectid=this.testFU.objectid,view="displayPageTest",bodyview="displayBodyTest") />
		
		<cfset assertEquals(furl,"/test/fu/test-page-default/test-body-default") />
	</cffunction>

	<cffunction displayname="Generate: /fu/viewalias/bodyalias/param1/value1/param2/value2 from urlParameters" hint="Checks that this friendly URL is generated" name="generateFU_fu_viewalias_bodyalias_urlParameters" access="public">
		<cfset var urlParameters = "param1=value1&param2=value2" />
		<cfset var furl = "" />
		
		<!--- urlParameters --->
		<cfset furl = this.fapi.getLink(objectid=this.testFU.objectid,view="displayPageTest",bodyview="displayBodyTest",urlParameters=urlParameters) />
		<cfset assertEquals(furl,"/test/fu/test-page-default/test-body-default/param1/value1/param2/value2") />
	</cffunction>

	<cffunction displayname="Generate: /fu/viewalias/bodyalias/param1/value1/param2/value2 from stParameters" hint="Checks that this friendly URL is generated" name="generateFU_fu_viewalias_bodyalias_stParameters" access="public">
		<cfset var stParameters = structnew() />
		<cfset var furl = "" />
		
		<!--- stParameters --->
		<cfset stParameters["param1"] = "value1" />
		<cfset stParameters["param2"] = "value2" />
		<cfset furl = this.fapi.getLink(objectid=this.testFU.objectid,view="displayPageTest",bodyview="displayBodyTest",stParameters=stParameters) />
		<cfset assertEquals(furl,"/test/fu/test-page-default/test-body-default/param1/value1/param2/value2") />
	</cffunction>


	<!--- Manual links: href --->
	<cffunction displayname="Generate: /href?param1=value1&param2=value2 from urlParameters" hint="Checks that this friendly URL is generated" name="generateFU_href_urlParameters" access="public">
		<cfset var urlParameters = "param1=value1&param2=value2" />
		<cfset var furl = "" />
		
		<!--- urlParameters --->
		<cfset furl = this.fapi.getLink(href="/abc/def",urlParameters=urlParameters) />
		<cfset assertEquals(furl,"/abc/def?param1=value1&amp;param2=value2") />
	</cffunction>


	<!--- Home page links --->
	<cffunction displayname="Generate: /?logout=1 from urlParameters" hint="Checks that this friendly URL is generated" name="generateFU_home_logout" access="public">
		<cfset var urlParameters = "logout=1" />
		<cfset var furl = "" />
		
		<!--- stParameters --->
		<cfset furl = this.fapi.getLink(objectid=application.navid.home,urlParameters=urlParameters) />
		<cfset assertEquals(furl,"/?logout=1") />
	</cffunction>


</cfcomponent>