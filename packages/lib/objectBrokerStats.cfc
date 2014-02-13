<cfcomponent name="objectBrokerStats" hint="Records statistics for an object broker's events" output="false">

	<!--- Put counters in public "this" scope --->
	<cfset this.summaryCounters = structNew() />
	<cfset this.typeCounters = structNew() />
	<cfset this.objectCounters = structNew() />
	
	<!--- The list of event names that we keep counters for --->
	<cfset variables.eventNames = "hit,miss,add,flush,evict,nullhit,reap" />
		
	<cffunction name="init" output="false">
		<cfargument name="bTrackObjectStats" type="boolean" default="false" />
		<cfset newSummaryCounters() />
		<cfset variables.bTrackObjectStats = arguments.bTrackObjectStats />
		<cfreturn this />
	</cffunction>

	<!--- TRACKING METHODS --->

	<cffunction name="trackObjectEvent" output="false" returntype="void">
		<cfargument name="eventname" type="string" required="true" />
		<cfargument name="typename" type="string" required="true" />
		<cfargument name="objectid" type="string" required="true" />
		
		<cfif ListFind(variables.eventNames,arguments.eventname)>
			<cfset incrementEventCounter(getSummaryCounters(),arguments.eventName) />
			<cfset incrementEventCounter(getTypeCounters(arguments.typename),arguments.eventName) />
			<cfif variables.bTrackObjectStats>
				<cfset incrementEventCounter(getObjectCounters(arguments.objectid),arguments.eventName) />
			</cfif>
		</cfif>
	</cffunction>

	<!--- REPORTING METHODS --->

	<cffunction name="getSummaryStats" output="false" returntype="struct">
		<cfreturn convertCountersToStats(getSummaryCounters()) />
	</cffunction>

	<cffunction name="getTypeStats" output="false" returntype="struct">
		<cfargument name="typename" type="string" required="true" />
		<cfreturn convertCountersToStats(getTypeCounters(arguments.typename)) />
	</cffunction>

	<cffunction name="getObjectStats" output="false" returntype="struct">
		<cfargument name="objectid" type="string" required="true" />
		<cfreturn convertCountersToStats(getObjectCounters(arguments.objectid)) />
	</cffunction>


	<!--- COUNTER METHODS (should be private) --->

	<cffunction name="createCounter" access="private" output="false" returntype="any">
		<cfreturn CreateObject("java","java.util.concurrent.atomic.AtomicInteger").init() />
	</cffunction>

	<cffunction name="isCounter" access="private" output="false" returntype="boolean">
		<cfargument name="obj" type="any" required="true" /> 
		<cfreturn isObject(arguments.obj) and isInstanceOf(arguments.obj,"java.util.concurrent.atomic.AtomicInteger") />
	</cffunction>

	<cffunction name="newSummaryCounters" output="false" returntype="struct">
		<cfset var eventName = "" />
		<cfloop list="#variables.eventNames#" index="eventName">
			<cfset this.summaryCounters[eventName] = createCounter() />
		</cfloop>
		<cfreturn this.summaryCounters />
	</cffunction>

	<cffunction name="newTypeCounters" output="false" returntype="struct">
		<cfargument name="typename" type="string" required="true" />
		<cfset var eventName = "" />
		<cfset this.typeCounters[arguments.typename] = structNew() />
		<cfloop list="#variables.eventNames#" index="eventName">
			<cfset this.typeCounters[arguments.typename][eventName] = createCounter() />
		</cfloop>
		<cfreturn this.typeCounters[arguments.typename] />
	</cffunction>

	<cffunction name="newObjectCounters" output="false" returntype="struct">
		<cfargument name="objectid" type="string" required="true" />
		<cfset var eventName = "" />
		<cfset this.objectCounters[arguments.objectid] = structNew() />
		<cfloop list="#variables.eventNames#" index="eventName">
			<cfset this.objectCounters[arguments.objectid][eventName] = createCounter() />
		</cfloop>
		<cfreturn this.objectCounters[arguments.objectid] />
	</cffunction>

	<cffunction name="getSummaryCounters" output="false" returntype="struct">
		<cfreturn this.summaryCounters />
	</cffunction>

	<cffunction name="getTypeCounters" output="false" returntype="struct">
		<cfargument name="typename" type="string" required="true" />
		<cftry>
			<cfreturn this.typeCounters[arguments.typeName] />
			<cfcatch >
				<cfreturn newTypeCounters(arguments.typeName) />
			</cfcatch>
		</cftry>
	</cffunction>

	<cffunction name="getObjectCounters" output="false" returntype="struct">
		<cfargument name="objectid" type="string" required="true" />
		<cftry>
			<cfreturn this.objectCounters[arguments.objectid] />
			<cfcatch >
				<cfreturn newObjectCounters(arguments.objectid) />
			</cfcatch>
		</cftry>
	</cffunction>

	<cffunction name="incrementEventCounter" output="false" returntype="numeric">
		<cfargument name="stCounters" type="struct" required="true" />
		<cfargument name="eventname" type="string" required="true" />
		<cfif StructKeyExists(arguments.stCounters,arguments.eventname)>
			<cfreturn arguments.stCounters[arguments.eventname].incrementAndGet() />
		<cfelse>
			<cfreturn -1 />
		</cfif>
	</cffunction>


	<cffunction name="convertCountersToStats" access="private" output="false" returntype="struct">
		<cfargument name="stCounters" type="struct" required="true" />
		<cfset var stStats = structNew() />
		<cfset var keyName = "" />
		<cfset var keyValue = "" />
		
		<cfloop collection="#arguments.stCounters#" item="keyName">
			<cfset keyValue = arguments.stCounters[keyName] />
			<cfif isCounter(keyValue)>
				<cfset stStats[keyName] = keyValue.get() />
			<cfelseif isStruct(keyValue)>
				<cfset stStats[keyName] = convertCountersToStats(keyValue) />
			<cfelseif isSimpleValue(keyValue)>
				<cfset stStats[keyName] = keyValue />
			</cfif>
		</cfloop>
		<cfreturn stStats />
	</cffunction>

</cfcomponent>