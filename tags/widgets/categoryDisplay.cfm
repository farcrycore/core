<cfsetting enablecfoutputonly="true">

<cfimport taglib="/farcry/core/tags/farcry" prefix="farcry" />
<farcry:deprecated message="widgets tag library is deprecated; please use formtools." />

<cfparam name="attributes.lSelectedCategoryID" default="">
<cfparam name="attributes.naviagtionURL" default="">
<cfparam name="attributes.naviagtionVariableName" default="categoryID">
<cfparam name="attributes.categoryFormFieldName" default="lSelectedCategoryID">
<cfparam name="attributes.moduleCounter" default="1"> <!--- keep track of how many trees there are on the page so as to not collapse the wrong branch --->

<cfset qNav = attributes.qListCategory>
<cfset lSelectedCategoryID = attributes.lSelectedcategoryID>
<cfset categoryFormFieldName = attributes.categoryFormFieldName>
<cfset naviagtionURL = attributes.naviagtionURL>
<cfset naviagtionVariableName = attributes.naviagtionVariableName>
<!--- generate the display html --->
	<!--- initialise counters --->
<cfset currentlevel = -1> <!--- nLevel counter --->
<cfset ul = 0> <!--- nested list counter --->
<cfset startLevel = 0>
<cfset iCounter = 0>
<cfloop index="i" from="1" to="#qNav.recordcount#">
	<cfset iParentObjectID = trim(qNav.parentID[i])>
	<cfset iCurrentObjectID = qNav.objectID[i]>
	<!--- <cfset bCollapsable = application.factory.otree.getDescendants(iCurrentObjectID).recordcount> --->
	<cfif qNav.nRight[i] EQ (qNav.nLeft[i] + 1)>
		<cfset bCollapsable = 0>
	<cfelse>
		<cfset bCollapsable = 1>
	</cfif>

	<cfif iParentObjectID EQ ""> <!--- root --->
		<cfset listDisplayState = "block">
	<cfelse>
		<cfset qDescendants = application.factory.otree.getDescendants(iParentObjectID)>
		<cfset aSelectedDescendant = ListToArray(ValueList(qDescendants.objectID))>
		<cfset listDisplayState = "none">
		<cfloop index="k" from="1" to="#ArrayLen(aSelectedDescendant)#">
			<cfif ListFindNoCase(lSelectedCategoryID,aSelectedDescendant[k])>
				<cfset listDisplayState = "block">
				<cfbreak>
			</cfif>
		</cfloop>
	</cfif>

	<cfif qNav.nLevel[i] GTE startLevel>
		<!--- update counters --->
		<cfset previouslevel = currentlevel>
		<cfset currentlevel=qNav.nLevel[i]>
		<!--- build nested list --->
		<cfif previouslevel EQ -1> <!--- if first item, open first list --->
<cfoutput><ul id="collapse_#attributes.moduleCounter#_#iParentObjectID#" class="nomarker category-tree"></cfoutput><cfset ul = ul + 1>
		<cfelseif currentlevel GT previouslevel> <!--- if new level, open new list --->
<cfoutput><ul id="collapse_#attributes.moduleCounter#_#iParentObjectID#" style="display:#listDisplayState#;margin: 5px 0 15px 25px" class="nomarker"></cfoutput><cfset ul = ul + 1>
		<cfelseif currentlevel LT previouslevel> <!--- if end of level, close items and lists until at correct level --->
<cfoutput>#repeatString("</li></ul></li>",previousLevel-currentLevel)#</cfoutput><cfset ul = ul - (previousLevel-currentLevel)>
		<cfelse> <!--- close item --->
<cfoutput></li></cfoutput>
		</cfif>
	</cfif>
	<!--- write item --->	
	<cfset iCounter = iCounter + 1>
<cfoutput>
<li>
<cfif bCollapsable GT 0>
<a href="javascript:void(0);" onclick="showHide('collapse_#attributes.moduleCounter#_#iCurrentObjectID#','#iCurrentObjectID#_#iCounter#-a');return false;" style="background:transparent">
<img id="#iCurrentObjectID#_#iCounter#-a" src="#application.url.farcry#/images/icons/xsmall/expand.png" alt="" /></a>
<a href="javascript:void(0);" onclick="showHide('collapse_#attributes.moduleCounter#_#iCurrentObjectID#','#iCurrentObjectID#_#iCounter#-a');return false;"></a>
</cfif>
<cfif naviagtionURL EQ "">
<label id="category_#qNav.ObjectID[i]#">
	<input class="f-checkbox" type="checkbox" name="#categoryFormFieldName#" id="category_#qNav.ObjectID[i]#" value="#qNav.ObjectID[i]#"<cfif ListFindNoCase(lSelectedCategoryID,qNav.ObjectID[i])> checked="checked"</cfif>>#trim(qNav.ObjectName[i])#
</label>
<cfelse>
	<cfif ListFindNoCase(lSelectedCategoryID,qNav.ObjectID[i])>
<strong>#trim(qNav.ObjectName[i])#</strong>
	<cfelse>
<a href="#cgi.script_name#?#naviagtionURL#&categoryID=#qNav.ObjectID[i]#">#trim(qNav.ObjectName[i])#</a>
	</cfif>	
</cfif>
</cfoutput>
</cfloop>
<!--- end of data, close open items and lists --->
<cfoutput>#repeatString("</li></ul>",ul)#</cfoutput>
<!--- // generate the display html --->
<cfsetting enablecfoutputonly="false">