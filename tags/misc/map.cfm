<cfsetting enablecfoutputonly="true" />
<!--- @@displayname: Filter loop --->

<cfif not thistag.HasEndTag>
	<cfthrow message="The map tag must have an end element">
</cfif>

<cfparam name="attributes.values" />
<cfparam name="attributes.index" default="index" />
<cfparam name="attributes.value" default="value" />
<cfparam name="attributes.sendback" default="sendback" />
<cfparam name="attributes.resulttype" default="" />
<cfparam name="attributes.result" default="result" />
<cfparam name="attributes.delimiters" default="," />

<cffunction name="initMap" access="public" resulttype="boolean" description="Type specific initialisation for map. Returns true if there are items to process." output="false">
	<cfif isstruct(attributes.values)>
		<cfset thistag.valuestype = "struct" />
		
		<cfset thistag.count = structcount(attributes.values) />
		<cfset thistag.keys = structkeyarray(attributes.values) />
		
		<cfif not len(attributes.resulttype)>
			<cfset attributes.resulttype = "struct" />
		</cfif>
	<cfelseif isarray(attributes.values)>
		<cfset thistag.valuestype = "array" />
		
		<cfset thistag.count = arraylen(attributes.values) />
		
		<cfif not len(attributes.resulttype)>
			<cfset attributes.resulttype = "array" />
		</cfif>
	<cfelseif isquery(attributes.values)>
		<cfset thistag.valuestype = "query" />
		
		<cfset thistag.count = attributes.values.recordcount />
		
		<cfif not len(attributes.resulttype)>
			<cfset attributes.resulttype = "querynew('#attributes.values.columnlist#')" />
		</cfif>
	<cfelse>
		<cfset thistag.valuestype = "list" />
		
		<cfset thistag.count = listlen(attributes.values) />
		
		<cfif not len(attributes.resulttype)>
			<cfset attributes.resulttype = "list" />
		</cfif>
	</cfif>
	
	<cfswitch expression="#attributes.resulttype#">
		<cfcase value="struct">
			<cfset thistag.result = structnew() />
		</cfcase>
		<cfcase value="array">
			<cfset thistag.result = arraynew(1) />
		</cfcase>
		<cfcase value="list">
			<cfset thistag.result = "" />
		</cfcase>
		<cfdefaultcase><!--- query --->
			<cfset thistag.result = evaluate(attributes.resulttype) />
			<cfset attributes.resulttype = "query" />
		</cfdefaultcase>
	</cfswitch>
	
	<cfif thistag.count>
		<cfreturn true />
	<cfelse>
		<cfreturn false />
	</cfif>
</cffunction>

<cffunction name="getValue" access="public" resulttype="any" description="Returns the specified element from the values" output="false">
	<cfargument name="index" type="numeric" required="true" hint="The index to return" />	
	
	<cfset var stResult = structnew() />
	<cfset var thiscol = "" />
	
	<cfswitch expression="#thistag.valuestype#">
		<cfcase value="struct">
			<cfreturn attributes.values[thistag.keys[arguments.index]] />
		</cfcase>
		<cfcase value="array">
			<cfreturn attributes.values[arguments.index] />
		</cfcase>
		<cfcase value="list">
			<cfreturn listgetat(attributes.values,arguments.index) />
		</cfcase>
		<cfcase value="query">
			<cfloop list="#attributes.values.columnlist#" index="thiscol">
				<cfset stResult[thiscol] = attributes.values[thiscol][arguments.index] />
			</cfloop>
			<cfreturn stResult />
		</cfcase>
	</cfswitch>
</cffunction>

<cffunction name="getIndex" access="public" resulttype="any" description="Returns an index to be used by the content" output="false">
	<cfargument name="index" type="numeric" required="true" hint="The index to return" />	
	
	<cfswitch expression="#thistag.valuestype#">
		<cfcase value="struct">
			<cfreturn thistag.keys[arguments.index] />
		</cfcase>
		<cfcase value="array,list,query" delimiters=",">
			<cfreturn arguments.index />
		</cfcase>
	</cfswitch>
</cffunction>

<cffunction name="getMap" access="public" resulttype="any" description="Returns an empty map variable to be populated by the content" output="false">
	<cfset var sendback = "" />
	
	<cfswitch expression="#attributes.resulttype#">
		<cfcase value="struct">
			<cfreturn structnew() />
		</cfcase>
		<cfcase value="array">
			<cfreturn arraynew(1) />
		</cfcase>
		<cfcase value="list">
			<cfreturn "" />
		</cfcase>
		<cfcase value="query">
			<cfset sendback = arraynew(1) />
			<cfset sendback[1] = structnew() />
			<cfreturn sendback />
		</cfcase>
	</cfswitch>
</cffunction>

<cffunction name="addMap" access="public" resulttype="void" description="Adds the map variable the result" output="false">
	<cfset var i = 0 />
	<cfset var thiscol = "" />
	
	<cfswitch expression="#attributes.resulttype#">
		<cfcase value="struct">
			<cfset structappend(thistag.result,caller[attributes.sendback]) />
		</cfcase>
		<cfcase value="array">
			<cfloop from="1" to="#arraylen(caller[attributes.sendback])#" index="i">
				<cfset arrayappend(thistag.result,caller[attributes.sendback][i]) />
			</cfloop>
		</cfcase>
		<cfcase value="list">
			<cfset thistag.result = listappend(thistag.result,caller[attributes.sendback],attributes.delimiters) />
		</cfcase>
		<cfcase value="query">
			<cfloop from="1" to="#arraylen(caller[attributes.sendback])#" index="i">
				<cfif not structisempty(caller[attributes.sendback][i])>
					<cfset queryaddrow(thistag.result) />
					<cfloop list="#thistag.result.columnlist#" index="thiscol">
						<cfif structkeyexists(caller[attributes.sendback][i],thiscol)>
							<cfset querysetcell(thistag.result,thiscol,caller[attributes.sendback][i][thiscol]) />
						</cfif>
					</cfloop>
				</cfif>
			</cfloop>
		</cfcase>
	</cfswitch>
</cffunction>

<cfif thistag.ExecutionMode eq "start">
	<cfif not initMap()>
		<cfset caller[attributes.result] = thistag.result />
		<cfexit method="exittag" />
	</cfif>
	
	<cfset thistag.index = 1 />
	<cfset caller[attributes.index] = getIndex(thistag.index) />
	<cfset caller[attributes.sendback] = getMap() />
	<cfset caller[attributes.value] = getValue(thistag.index) />
</cfif>

<cfif thistag.ExecutionMode eq "end">
	<cfset addMap() />
	
	<cfif thistag.index lt thistag.count>
		<cfset thistag.index = thistag.index + 1 />
		<cfset caller[attributes.index] = getIndex(thistag.index) />
		<cfset caller[attributes.sendback] = getMap() />
		<cfset caller[attributes.value] = getValue(thistag.index) />
		
		<cfexit method="loop" />
	</cfif>
	
	<cfset caller[attributes.result] = thistag.result />
</cfif>

<cfsetting enablecfoutputonly="false" />