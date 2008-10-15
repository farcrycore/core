<cfsetting enablecfoutputonly="true" />
<!--- @@description: Loops over word changes between one string and another --->

<cfif not thistag.HasEndTag>
	<cfthrow message="diff must have an end tag" />
</cfif>

<cffunction name="getDiff" returntype="array" access="private" hint="Returns an array of diff structs">
	<cfargument name="aOld" type="array" required="true" hint="Original array of words to compare" />
	<cfargument name="aNew" type="array" required="true" hint="New array of words to compare" />
	<cfargument name="startOld" type="numeric" required="false" hint="Start position in old array" />
	<cfargument name="endOld" type="numeric" required="false" hint="End position in old array" />
	<cfargument name="startNew" type="numeric" required="false" hint="Start position in new array" />
	<cfargument name="endNew" type="numeric" required="false" hint="End position in new array" />
	
	<cfset var aResult = arraynew(1) />
	<cfset var aMatchingEnd = arraynew(1) />
	<cfset var num = arraynew(2) />
	<cfset var i = 0 />
	<cfset var j = 0 />
	<cfset var st = structnew() />
	
	<cfparam name="arguments.startOld" default="1" />
	<cfparam name="arguments.endOld" default="#arraylen(arguments.aOld)#" />
	<cfparam name="arguments.startNew" default="1" />
	<cfparam name="arguments.endNew" default="#arraylen(arguments.aNew)#" />
	
	<!--- Special case: old array is empty --->
	<cfif not arraylen(arguments.aOld)>
		<cfloop from="1" to="#arraylen(arguments.aNew)#" index="i">
			<cfset st = { diff="+", newindex=i, newvalue=arguments.aNew[i]} />
			<cfset arrayappend(aResult,st) />
		</cfloop>
		<cfreturn aResult />
	</cfif>
	
	<!--- Special case: new array is empty --->
	<cfif not arraylen(arguments.aNew)>
		<cfloop from="1" to="#arraylen(arguments.aOld)#" index="i">
			<cfset st = { diff="-", oldindex=i, oldvalue=arguments.aOld[i]} />
			<cfset arrayappend(aResult,st) />
		</cfloop>
		<cfreturn aResult />
	</cfif>
	
	<!--- trim off the matching items at the beginning --->
	<cfloop condition="arguments.startOld lte arguments.endOld and arguments.startNew lte arguments.endNew and arguments.aOld[arguments.startOld] eq arguments.aNew[arguments.startNew]">
		<cfset st = { oldindex=arguments.startOld, newindex=arguments.startNew, diff="=", oldvalue=arguments.aOld[arguments.startOld], newvalue=arguments.aNew[arguments.startNew] } />
		<cfset arrayappend(aResult,st) />
		<cfset arguments.startOld = arguments.startOld + 1 />
		<cfset arguments.startNew = arguments.startnew + 1 />
	</cfloop>
	
	<!--- trim off the matching items at the end --->
	<cfloop condition="arguments.startOld lte arguments.endOld and arguments.startNew lte arguments.endNew and arguments.aOld[arguments.endOld] eq arguments.aNew[arguments.endNew]">
		<cfset st = { oldindex=arguments.endOld, newindex=arguments.endNew, diff="=", oldvalue=arguments.aOld[arguments.endOld], newvalue=arguments.aNew[arguments.endNew] } />
		<cfset arrayappend(aMatchingEnd,st) />
		<cfset arguments.endOld = arguments.endOld - 1 />
		<cfset arguments.endNew = arguments.endNew - 1 />
	</cfloop>
	
	<!--- create the subsequence matrix --->
	<cfloop from="#arguments.startOld#" to="#arguments.endOld+1#" index="i">
		<cfset num[i][arguments.startNew] = 0 />
	</cfloop>
	<cfloop from="#arguments.startNew#" to="#arguments.endNew+1#" index="j">
		<cfset num[arguments.startOld][j] = 0 />
	</cfloop>
	<cfloop from="#arguments.startOld+1#" to="#arguments.endOld+1#" index="i">
		<cfloop from="#arguments.startNew+1#" to="#arguments.endNew+1#" index="j">
			<cfif arguments.aOld[i-1] eq arguments.aNew[j-1]>
				<cfset num[i][j] = num[i-1][j-1] + 1 />
			<cfelse>
				<cfset num[i][j] = max(num[i-1][j],num[i][j-1]) />
			</cfif>
		</cfloop>
	</cfloop>
	
	<!--- backtrack the subsequence --->
	<cfset arguments.endOld = arguments.endOld + 1 />
	<cfset arguments.endNew = arguments.endNew + 1 />
	<cfloop condition="arguments.endOld gt arguments.startOld or arguments.endNew gt arguments.startNew">
		<cfif (arguments.endOld gt arguments.startOld and arguments.endNew gt arguments.startNew and arguments.aOld[arguments.endOld-1] eq arguments.aNew[arguments.endNew-1])>
			<cfset st = { oldindex=arguments.endOld-1, newindex=arguments.endNew-1, diff="=", oldvalue=arguments.aOld[arguments.endOld-1], newvalue=arguments.aNew[arguments.endNew-1] } />
			<cfset arrayprepend(aMatchingEnd,st) />
			<cfset arguments.endOld = arguments.endOld - 1 />
			<cfset arguments.endNew = arguments.endnew - 1 />
		<cfelseif arguments.endNew gt arguments.startNew and (arguments.endOld eq arguments.startOld or num[arguments.endOld][arguments.endNew-1] gte num[arguments.endOld-1][arguments.endNew])>
			<cfset st = { newindex=arguments.endNew-1, diff="+", newvalue=arguments.aNew[arguments.endNew-1] } />
			<cfset arrayprepend(aMatchingEnd,st) />
			<cfset arguments.endNew = arguments.endNew - 1 />
		<cfelseif arguments.endOld gt arguments.startOld and (arguments.endNew eq arguments.startNew or num[arguments.endOld][arguments.endNew-1] lt num[arguments.endOld-1][arguments.endNew])>
			<cfset st = { oldindex=arguments.endOld-1, diff="-", oldvalue=arguments.aOld[arguments.endOld-1] } />
			<cfset arrayprepend(aMatchingEnd,st) />
			<cfset arguments.endOld = arguments.endOld - 1 />
		</cfif>
	</cfloop>
	
	<cfloop from="1" to="#arraylen(aMatchingEnd)#" index="i">
		<cfset arrayappend(aResult,aMatchingEnd[i]) />
	</cfloop>
	
	<cfreturn aResult />
</cffunction>

<cfif thistag.ExecutionMode eq "start">
	<cfparam name="attributes.old" />
	<cfparam name="attributes.new" />
	<cfparam name="attributes.diff" default="diff" />
	
	<cfif isarray(attributes.old) and isarray(attributes.new)>
		<cfset thistag.aDiff = getDiff(attributes.old,attributes.new) />
	<cfelse>
		<!--- Turn the old string into an array of words --->
		<cfset aOld = listtoarray(rereplace(rereplace(attributes.old,"<[^>]+>","","ALL"),"[^A-Za-z]+"," ","ALL")," ") />
		
		<!--- Turn the new string into an array of words --->
		<cfset aNew = listtoarray(rereplace(rereplace(attributes.new,"<[^>]+>","","ALL"),"[^A-Za-z]+"," ","ALL")," ") />
		
		<cfset thistag.aDiff = getDiff(aOld,aNew) />
	</cfif>
	
	<cfif arraylen(thistag.aDiff)>
		<cfset thistag.index = 1 />
		<cfset thistag.count = arraylen(thistag.aDiff) />
		
		<cfset caller[attributes.diff] = thistag.aDiff[thistag.index] />
	<cfelse>
		<cfset caller[attributes.diff] = thistag.aDiff />
		
		<cfexit method="exittag" />
	</cfif>
</cfif>

<cfif thistag.ExecutionMode eq "end">
	<cfif thistag.index lt thistag.count>
		<cfset thistag.index = thistag.index + 1 />
		<cfset caller[attributes.diff] = thistag.aDiff[thistag.index] />
		
		<cfexit method="loop" />
	</cfif>
	
	<cfset caller[attributes.diff] = thistag.aDiff />
</cfif>

<cfsetting enablecfoutputonly="false" />