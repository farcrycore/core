<cfsetting enablecfoutputonly="true" />
<!--- @@displayname: Loops through sections (subsection, menu, menuitem) in the webtop data --->
<!--- @@description: Processes tag content  for each subsection of specified section that the user has permission for --->
<!--- @@author: Blair McKenzie (blair@daemon.com.au) --->

<!--- Require end tag --->
<cfif not thistag.HasEndTag>
	<cfthrow message="admin:subsections tag requires an end tag" />
</cfif>

<!--- Define attributes --->
<cfparam name="attributes.parent" type="any" default="#application.factory.oWebtop.stWebtop#" /><!--- The parent to loop through --->
<cfparam name="attributes.item" type="variablename" /><!--- Variable to store an item in during a loop --->
<cfparam name="attributes.class" type="string" default="" /><!--- Variable name to store a child class (first|last) during a loop --->
<cfparam name="attributes.honoursecurity" type="boolean" default="true" /><!--- Should the loop skip denied sections --->

<cfswitch expression="#thistag.ExecutionMode#">
	<cfcase value="start">
		<!--- Get item struct --->
		<cfif isstruct(attributes.parent)>
			<cfset thistag.stItems = attributes.parent />
		<cfelseif issimplevalue(attributes.parent)>
			<cfset thistag.stItems = application.factory.oWebtop.getItem(attributes.parent,attributes.honoursecurity) />
		<cfelse>
			<!--- Invalid value --->
			<cfthrow message="The parent attribute must either be a webtop struct or an id path specifying a webtop struct" />
		</cfif>
		
		<!--- Length of loop --->
		<cfset thistag.lastindex = listlen(thistag.stItems.childorder) />
		
		<!--- If no children, exit tag --->
		<cfif not thistag.lastindex>
			<cfexit method="exittag" />
		</cfif>
		
		<!--- Start at child 1 --->
		<cfset thistag.index = 1 />
		<cfif len(attributes.class)>
			<cfset caller[attributes.class] = "first" />
		</cfif>
		<cfset caller[attributes.item] = thistag.stItems.children[listgetat(thistag.stItems.childorder,thistag.index)] />
	</cfcase>
	
	<cfcase value="end">
		<!--- Move to next sub section --->
		<cfset thistag.index = thistag.index + 1 />
		
		<cfif thistag.index lte thistag.lastindex>
			<!--- Load next child and loop again --->
			<cfif len(attributes.class)>
				<cfif thistag.index eq thistag.lastindex>
					<cfset caller[attributes.class] = "last" />
				<cfelse>
					<cfset caller[attributes.class] = "" />
				</cfif>
			</cfif>
			<cfset caller[attributes.item] = thistag.stItems.children[listgetat(thistag.stItems.childorder,thistag.index)] />
			<cfexit method="loop" />
		<cfelse>
			<!--- Loop exited, empty variable --->
			<cfif len(attributes.class)>
				<cfset caller[attributes.class] = "" />
			</cfif>
			<cfset caller[attributes.item] = structnew() />
		</cfif>
	</cfcase>
</cfswitch>

<cfsetting enablecfoutputonly="false" />