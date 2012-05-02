<cfcomponent extends="mxunit.framework.TestCase" displayname="Events model Tests">
	
	<!--- setup and teardown --->
	<cffunction name="setUp" returntype="void" access="public">
		<!--- Any code needed to return your environment to normal goes here --->
			
		<!--- Call dummyEvents.clearEvents() in case some events were queued by a previous test --->
		<cfset var dummyEvent = createObject("component", "farcry.core.packages.events.dummy")>
		<cfset dummyEvent.clearEvents()>
		
		<cfset this.myEvents = createObject("component", "farcry.core.packages.lib.events")>
	</cffunction>

	<cffunction name="tearDown" returntype="void" access="public">
		<!--- Any code needed to return your environment to normal goes here --->
	</cffunction>
	
	<!--- ////////////////////////////////////////////////////////////////// --->
	
	<cffunction name="testAnnounce_MissingComponent" access="public">
		<!--- This should do nothing (no effect, no exception) --->
		<cfset this.myEvents.announce("ThisComponentShouldNotExist","dummyEvent")>
		<cfset assertEquals(0,ArrayLen(request._dummy_events_queue),"Number of queued events")>
	</cffunction>
	
	<cffunction name="testAnnounce_MissingMethod" access="public">
		<!--- This should do nothing (no effect, no exception) --->
		<cfset this.myEvents.announce("dummy","ThisMethodShouldNotExist")>
		<cfset assertEquals(0,ArrayLen(request._dummy_events_queue),"Number of queued events")>
	</cffunction>

	<cffunction name="testAnnounce_ValidMethod" access="public">
		<cfset this.myEvents.announce("dummy","dummyEvent")>
		<cfset assertEquals(1,ArrayLen(request._dummy_events_queue),"Number of queued events")>
	</cffunction>

	<cffunction name="testAnnounce_EventData" access="public">
		<cfset var stEventParams = { randomNumber = RandRange(1,1000) }> <!--- Make params non-deterministic --->
		
		<cfset this.myEvents.announce("dummy","dummyEvent",stEventParams)>
		<cfset assertEquals(1,ArrayLen(request._dummy_events_queue),"Number of queued events")>
		
		<!--- Verify data that was queued by the dummyEvent code --->
		<cfset assert(StructKeyExists(request._dummy_events_queue[1],"eventName"),"eventName should exist")>
		<cfset assertEquals("dummyEvent",request._dummy_events_queue[1].eventName,"eventName")>
		<cfset assert(StructKeyExists(request._dummy_events_queue[1],"eventParams"),"eventParams should exist")>
		<cfset assertEquals(stEventParams,request._dummy_events_queue[1].eventParams,"eventParams")>
	</cffunction>

	<cffunction name="testGetListeners_MissingComponent" access="public">
		<cfset var aListeners = this.myEvents.getListeners("ThisComponentShouldNotExist",false)>
		<cfset assertEquals(0,ArrayLen(aListeners),"Number of listener components")>
	</cffunction>

	<cffunction name="testGetListeners_ValidComponent" access="public">
		<cfset var aListeners = this.myEvents.getListeners("dummy",false)>
		<cfset assertEquals(1,ArrayLen(aListeners),"Number of listener components")>
		<cfset assert(IsInstanceOf(aListeners[1],"farcry.core.packages.events.dummy"),"Component should be instance of events.dummy")>
	</cffunction>

	<cffunction name="testGetListeners_Caching" access="public">
		<!--- Call getListeners() twice, components should be the same --->
		<cfset var aListeners1 = this.myEvents.getListeners("dummy")>
		<cfset var aListeners2 = this.myEvents.getListeners("dummy")>
		<cfset assertEquals(1,ArrayLen(aListeners1),"Number of listener1 components")>
		<cfset assertEquals(1,ArrayLen(aListeners2),"Number of listener2 components")>
		<cfset assertSame(aListeners1[1],aListeners2[1],"Instances should be same")>
	</cffunction>
	
	<cffunction name="testGetListeners_NoCaching" access="public">
		<!--- Call getListeners() twice, components should be different --->
		<cfset var aListeners1 = this.myEvents.getListeners("dummy",false)>
		<cfset var aListeners2 = this.myEvents.getListeners("dummy",false)>
		<cfset assertEquals(1,ArrayLen(aListeners1),"Number of listener1 components")>
		<cfset assertEquals(1,ArrayLen(aListeners2),"Number of listener2 components")>
		<cfset assertNotSame(aListeners1[1],aListeners2[1],"Instances should not be same")>
	</cffunction>
	

</cfcomponent>