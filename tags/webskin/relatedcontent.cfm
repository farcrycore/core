<cfsetting enablecfoutputonly="true" />
<cfsilent>
<!--- @@Copyright: Daemon Pty Limited 1995-2007, http://www.daemon.com.au --->
<!--- @@License: Released Under the "Common Public License 1.0", http://www.opensource.org/licenses/cpl.php --->
<!--- @@displayname: Related Content Tag --->
<!--- @@Description: Display related content. --->
<!--- @@Developer: Geoff Bowers (modius@daemon.com.au) --->

<!--- 
SAMPLE USAGE:
<skin:relatedcontent 
	objectid="#stobj.objectid#" 
	arrayProperty="aRelatedPosts" 
	typename="farBlogPost"
	filter="farBlogPost"
	webskin="displayTeaserStandard" 
	rendertype="unordered" />
--->

<!--- import tag libraries --->
<cfimport taglib="/farcry/core/tags/webskin" prefix="skin" />

<!--- only run tag once --->
<cfif thistag.executionMode eq "end">
	<cfexit method="exittag" />
</cfif>

<!--- required attributes --->
<cfparam name="attributes.objectid" type="uuid" />
<cfparam name="attributes.arrayProperty" type="string" /><!--- propertyname of the array to render --->
<cfparam name="attributes.webskin" type="string" /><!--- webskin to render related content view --->

<!--- optional attributes --->
<cfparam name="attributes.typename" default="" type="string" /><!--- content typename of parent; providing improves performance --->
<cfparam name="attributes.filter" default="" type="string" /><!--- content typename to filter by for mixed type arrays --->
<cfparam name="attributes.rendertype" default="none" type="string" /><!--- render options: unordered, ordered, none --->
<cfparam name="attributes.alternateHTML" default="#attributes.webskin# template unavailable." type="string" /><!--- alternative HTML if webskin is missing --->
<cfparam name="attributes.r_html" default="" type="string" /><!--- Empty will render the html inline --->

<!--- determine typename if its not supplied --->
<cfif not len(attributes.typename)>
	<cfif structKeyExists(attributes.stObject, "typename")>
		<cfset attributes.typename = stobject.typename />
	<cfelseif len(attributes.objectid)>
		<cfset attributes.typename = application.coapi.coapiUtilities.findType(objectid=attributes.objectid) />
	</cfif>
</cfif>

<cfif not len(attributes.typename) or not structKeyExists(application.stCoapi, attributes.typename)>
	<cfthrow message="relatedcontent: invalid typename attribute passed." />
</cfif>	

<!--- create content type instance --->
<cfset o[attributes.typename] = createObject("component", application.stcoapi["#attributes.typename#"].packagePath) />
<cfset st = o[attributes.typename].getData(objectid=attributes.objectid, bArraysAsStructs=true) />

<!--- validate attributes.arrayproperty --->
<cfif NOT structKeyExists(st, attributes.arrayProperty) OR NOT isArray(st[attributes.arrayProperty], 1)>
	<cfthrow message="relatedcontent: invalid arrayProperty attribute passed." detail="arrayProperty must be a valid one dimensional array of content objectids." />
</cfif>

<cfset aRelated = st[attributes.arrayProperty] />

<!--- apply typename filter --->
<cfset aFiltered = arrayNew(1) />
<cfloop from="1" to="#arrayLen(aRelated)#" index="i">
	<cfif len(aRelated[i].typename) AND (aRelated[i].typename eq attributes.filter OR NOT len(attributes.filter)) >
		<!--- add matching keys --->
		<cfset arrayAppend(aFiltered, aRelated[i]) />
		<!--- instantiate an object for each content type to render --->
		<cfif NOT structKeyExists(o, aRelated[i].typename)>
			<cfset rendertype=aRelated[i].typename />
			<cfset o["#aRelated[i].typename#"] = createObject("component", application.stcoapi["#aRelated[i].typename#"].packagePath) />
		</cfif>
	</cfif>
</cfloop>
<cfset aRelated = aFiltered />

<!--- if nothing to process, exit immediately --->
<cfif arrayIsEmpty(st[attributes.arrayProperty])>
	<cfexit method="exittag" />
</cfif>

<!--- generate output by rendertype --->
<cfset html="" />

<cfswitch expression="#attributes.rendertype#">

	<cfcase value="unordered">
		<cfset html = html & "<ul>" />
		<cfloop from="1" to="#arrayLen(aRelated)#" index="j">
			<cfset html = html & "<li>" & o["#aRelated[j].typename#"].getView(objectid=aRelated[j].data, template="#attributes.webskin#", alternateHTML="#attributes.alternateHTML#") & "</li>" />
		</cfloop>
		<cfset html = html & "</ul>" />
	</cfcase>

	<cfcase value="ordered">
		<cfset html = html & "<ol>" />
		<cfloop from="1" to="#arrayLen(aRelated)#" index="k">
			<cfset html = html & "<li>" & o["#aRelated[k].typename#"].getView(objectid=aRelated[k].data, template="#attributes.webskin#", alternateHTML="#attributes.alternateHTML#") & "</li>" />
		</cfloop>
		<cfset html = html & "</ol>" />
	</cfcase>
	
	<cfdefaultcase>
		<cfloop from="1" to="#arrayLen(aRelated)#" index="l">
			<cfset html = html & " " & o["#aRelated[l].typename#"].getView(objectid=aRelated[l].data, template="#attributes.webskin#", alternateHTML="#attributes.alternateHTML#") />
		</cfloop>
	</cfdefaultcase>

</cfswitch>

</cfsilent>

<!--- return to caller scope or output inline --->
<cfif len(attributes.r_html)>
	<cfset setVariable(caller[attributes.r_html], html) />
<cfelse>
	<cfoutput>#html#</cfoutput>	
</cfif>

<cfsetting enablecfoutputonly="false" />