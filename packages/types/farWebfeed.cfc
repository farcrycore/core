<!--- @@Copyright: Daemon Pty Limited 2002-2013, http://www.daemon.com.au --->
<!--- @@License:
    This file is part of FarCry.

    FarCry is free software: you can redistribute it and/or modify
    it under the terms of the GNU General Public License as published by
    the Free Software Foundation, either version 3 of the License, or
    (at your option) any later version.

    FarCry is distributed in the hope that it will be useful,
    but WITHOUT ANY WARRANTY; without even the implied warranty of
    MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
    GNU General Public License for more details.

    You should have received a copy of the GNU General Public License
    along with FarCry.  If not, see <http://www.gnu.org/licenses/>.
--->
<cfcomponent displayname="Webfeed" 
	extends="types" output="false" 
	hint="DEPRECATED: Use a type webskin instead." 
	bFriendly="true" bSystem="true"
	bdeprecated="true"
	icon="fa-ban">

	<cfproperty ftSeq="1" ftWizardStep="General" ftFieldset="Feed" name="title" type="string" default="" hint="The name of the feed" ftLabel="Title" ftType="string" ftValidation="required" />
	<cfproperty ftSeq="2" ftWizardStep="General" ftFieldset="Feed" name="subtitle" type="string" default="" hint="" ftLabel="Subtitle" ftType="string" ftHint="Displays best if it is only a few words long" />
	<cfproperty ftSeq="3" ftWizardStep="General" ftFieldset="Feed" name="directory" type="string" default="" hint="The directory the scheduled job should put the files" ftLabel="XML directory" ftType="string" ftHint="Path from the web root where xml files (rss.xml,atom.xml,itunes.xml) should be stored. Defaults to /feeds/##title-with-dashes##" />
	<cfproperty ftSeq="4" ftWizardStep="General" ftFieldset="Feed" name="url" type="string" default="" ftDefault="" hint="The url associated with the webfeed" ftLabel="Feed linkback" ftType="string" />
	<cfproperty ftSeq="5" ftWizardStep="General" ftFieldset="Feed" name="description" type="string" default="" hint="A description of the webfeed" ftLabel="Description" ftType="longchar" />
	<cfproperty ftSeq="6" ftWizardStep="General" ftFieldset="Feed" name="feedimage" type="string" default="" hint="Feed image" ftLabel="Feed image" ftType="image" ftDestination="/farWebfeed/feedimage" ftCreateFromSourceOption="false" ftAutoGenerateType="" ftImageWidth="" ftImageHeight="" ftHint="Size must be 88-144px by 31-400px" />
	<cfproperty ftSeq="7" ftWizardStep="General" ftFieldset="Feed" name="editor" type="string" default="" hint="The editor / author of the webfeed" ftLabel="Editor / author" ftType="string" ftHint="Defaults to website name" />
	<cfproperty ftSeq="8" ftWizardStep="General" ftFieldset="Feed" name="editoremail" type="string" default="" hint="The editor / author email" ftLabel="Editor / author email" ftType="string" />
	<cfproperty ftSeq="9" ftWizardStep="General" ftFieldset="Feed" name="language" type="string" hint="" ftDefault="en-au" ftLabel="language" ftType="string" ftValidation="required" />
	<cfproperty ftSeq="10" ftWizardStep="General" ftFieldset="Feed" name="copyright" type="string" default="" hint="" ftLabel="Copyright" ftType="string" />
	<cfproperty ftSeq="11" ftWizardStep="General" ftFieldset="Feed" name="keywords" type="string" default="" hint="" ftLabel="Keywords" ftType="string" ftHint="List of keywords (max. 12)" />
	<cfproperty ftSeq="12" ftwizardstep="General" ftFieldSet="Feed" name="generator" type="string" hint="Generator Info. Example: My Company - mycompany.com" required="false" default="http://www.farcrycms.org/" ftLabel="Generator" />

	<cfproperty ftSeq="21" ftWizardStep="General" ftFieldset="Content Type" name="itemtype" type="string" default="" hint="The type that webfeed items are created from" ftLabel="Type" ftType="list" ftListData="getTypesList" ftValidation="required,validate-selection" />

  <!--- Media --->

	<cfproperty ftSeq="22" ftWizardStep="Media" ftFieldset="Media" name="titleproperty" type="string" default="title" hint="The property that contains the item's title" ftLabel="Title property" ftType="list" />
	<cfproperty ftSeq="23" ftWizardStep="Media" ftFieldset="Media" name="contentproperty" type="string" default="teaser" hint="The property that contains the item's content" ftLabel="HTML Content property" ftHint="This can be a teaser or full text" ftType="list" />
	<cfproperty ftSeq="24" ftWizardStep="Media" ftFieldset="Media" name="enclosurefileproperty" type="string" default="" hint="The property that contains the item's media location" ftLabel="Enclosure file property" ftType="list" />
	<cfproperty ftSeq="25" ftWizardStep="Media" ftFieldset="Media" name="dateproperty" type="string" default="datetimecreated" hint="The property that contains the date to sort by" ftLabel="Published-date property" ftType="list" ftHint="The items in the webfeed will be ordered by this property" />
	<cfproperty ftSeq="26" ftWizardStep="Media" ftFieldset="Media" name="bAuthor" type="boolean" default="0" hint="Should the item creator be included in the item as the author" ftLabel="Include item creator as author" ftType="boolean" />
	<cfproperty ftSeq="27" ftWizardStep="Media" ftFieldset="Media" name="catFilter" type="longchar" default="" hint="Filter items by these categories. If none are selected all items will be included." ftLabel="Restrict by categories" ftType="category" ftAlias="root" />
	<cfproperty ftSeq="28" ftWizardStep="Media" ftFieldset="Media" name="keywordsproperty" type="string" default="" hint="The property that contains the item's keywords" ftLabel="Item keywords property" ftType="list" ftHint="Property should contain a list of keywords" />
	
	<!--- RSS --->

	<cfproperty ftSeq="31" ftWizardStep="RSS" ftFieldset="Feed" name="skiphours" type="string" default="" hint="The hours when the feed doesn't need to be checked" ftLabel="Skip hours" ftType="list" ftHint="The hours in the day when the feed doesn't need to be checked" ftListData="getHoursList" ftSelectMultiple="true" />
	<cfproperty ftSeq="32" ftWizardStep="RSS" ftFieldset="Feed" name="skipdays" type="string" default="" hint="The days when the feed doesn't need to be checked" ftLabel="Skip days" ftType="list" ftHint="The days of the week when the feed doesn't need to be checked" ftListData="getDaysList" ftSelectMultiple="true" />
	
	
	<!--- Atom --->

	<cfproperty ftSeq="51" ftWizardStep="Atom" ftFieldset="Feed" name="atomicon" type="string" hint="The feed icon" required="no" default="" ftType="Image" ftDestination="/farWebfeed/atomicon" ftCreateFromSourceOption="false" ftAutoGenerateType="" ftImageWidth="" ftImageHeight="" ftLabel="Feed icon" ftHint="Should be a square image and suitable for presentation at a small size" />  
	
	<!--- iTunes --->

  <cfproperty ftSeq="70" ftwizardstep="iTunes" ftFieldSet="Feed" name="iTunesFeedId" type="integer" hint="iTunes Feed ID" required="false" ftLabel="iTunes Feed ID" ftHint="The iTunes Feed ID is only required if you wish to ping iTunes when you add or update podcast episodes" ftHelpSection="For more info on how to obtain an iTunes feed ID, see the following URL: <a href=""http://www.apple.com/itunes/store/podcaststechspecs.html"">http://www.apple.com/itunes/store/podcaststechspecs.html</a>" />

	<cfproperty ftSeq="71" ftWizardStep="iTunes" ftFieldset="Feed" name="itunescategories" type="string" default="" hint="Feed iTunes categories" ftLabel="iTune categories" ftType="list" ftListData="getiTunesCategoryList" ftSelectMultiple="true" ftHint="iTunes accepts a maximum of 3 categories" />
	<cfproperty ftSeq="72" ftWizardStep="iTunes" ftFieldset="Feed" name="itunesauthor" type="string" default="" hint="" ftLabel="iTunes author" ftType="string" />
	<cfproperty ftSeq="73" ftWizardStep="iTunes" ftFieldset="Feed" name="itunesimage" type="string" hint="The itunes image" required="no" default="" ftType="Image" ftDestination="/farWebfeed/itunesimage" ftCreateFromSourceOption="false" ftAutoGenerateType="FitInside" ftImageWidth="600" ftImageHeight="600" ftlabel="iTunes image" ftHint="Should be a square image and at least 600px by 600px" />  
	
	<cfproperty ftSeq="81" ftWizardStep="iTunes" ftFieldset="Items" name="itunessubtitleproperty" type="string" default="" hint="The property that contains the item's itunes subtitle" ftLabel="Item subtitle property" ftType="list" />
	<cfproperty ftSeq="83" ftWizardStep="iTunes" ftFieldset="Items" name="itunesdurationproperty" type="string" default="" hint="The property that contains the item's duration" ftLabel="Item duration property" ftType="list" />
	

	<cffunction name="getTypesList" access="public" returntype="string" description="Returns a list of valid types" output="false">
		<cfset var qResult = querynew("value,name","varchar,varchar") />
		<cfset var typename = "" />
		<cfset var result = "" />
		
		<cfloop collection="#application.stCOAPI#" item="typename">
			<cfif structkeyexists(application.stCOAPI[typename],"typepath")>
				<cfset queryaddrow(qResult) />
				<cfset querysetcell(qResult,"value",typename) />
				<cfset querysetcell(qResult,"name",application.stCOAPI[typename].displayname) />
			</cfif>
		</cfloop>
		
		<cfquery dbtype="query" name="qResult">
			select		*
			from		qResult
			order by	name
		</cfquery>
		
		<cfloop query="qResult">
			<cfset result = listappend(result,"#value#:#name#")>
		</cfloop>
		
		<cfreturn result />
	</cffunction>
	
	<cffunction name="ftEditTitleProperty" access="public" returntype="string" description="Provides the edit skin for titleproperty" output="false">
		<cfargument name="typename" required="true" type="string" hint="The name of the type that this field is part of.">
		<cfargument name="stObject" required="true" type="struct" hint="The object of the record that this field is part of.">
		<cfargument name="stMetadata" required="true" type="struct" hint="This is the metadata that is either setup as part of the type.cfc or overridden when calling ft:object by using the stMetadata argument.">
		<cfargument name="fieldname" required="true" type="string" hint="This is the name that will be used for the form field. It includes the prefix that will be used by ft:processform.">

		<cfset var html = "" />
		<cfset var qProperties = querynew("name,value","varchar,varchar") />
		<cfset var propname = "" />
		<cfset var fttype = "" />
		
		<cfif len(arguments.stObject.itemtype)>
			<cfloop collection="#application.stCOAPI[arguments.stObject.itemtype].stProps#" item="propname">
				<cfset fttype = application.stCOAPI[arguments.stObject.itemtype].stProps[propname].metadata.ftType />
				<cfif not len(fttype)>
					<cfset fttype = application.stCOAPI[arguments.stObject.itemtype].stProps[propname].metadata.type />
				</cfif>
				
				<cfif structkeyexists(application.stCOAPI[arguments.stObject.itemtype].stProps[propname].metadata,"ftSeq") and listcontains("nstring,string",fttype)>
					<cfset queryaddrow(qProperties) />
					<cfset querysetcell(qProperties,"value",propname) />
					<cfif len(application.stCOAPI[arguments.stObject.itemtype].stProps[propname].metadata.ftLabel)>
						<cfset querysetcell(qProperties,"name",application.stCOAPI[arguments.stObject.itemtype].stProps[propname].metadata.ftLabel) />
					<cfelse>
						<cfset querysetcell(qProperties,"name",application.stCOAPI[arguments.stObject.itemtype].stProps[propname].metadata.name) />
					</cfif>
				</cfif>
			</cfloop>
		
			<cfquery dbtype="query" name="qProperties">
				select		*
				from		qProperties
				order by	name
			</cfquery>
		
			<cfsavecontent variable="html">
				<cfoutput><select id="#arguments.fieldname#" name="#arguments.fieldname#"></cfoutput>
				
				<cfloop query="qProperties">
					<cfoutput><option value="#qProperties.value#"<cfif arguments.stMetadata.value eq qProperties.value> selected="selected"</cfif>>#qProperties.name#</option></cfoutput>
				</cfloop>
				
				<cfoutput></select><input type="hidden" name="#arguments.fieldname#" value=" "><br style="clear: both;"/></cfoutput>
			</cfsavecontent>
		<cfelse>
			<cfsavecontent variable="html">
				<!--- If no list items are selected, an empty field is posted. --->
				<cfoutput>No type selected<input type="hidden" id="#arguments.fieldname#" name="#arguments.fieldname#" value="" /></cfoutput>
			</cfsavecontent>
		</cfif>
		
		<cfreturn html />
	</cffunction>
	
	<cffunction name="ftEditContentProperty" access="public" returntype="string" description="Provides the edit skin for contentproperty" output="false">
		<cfargument name="typename" required="true" type="string" hint="The name of the type that this field is part of.">
		<cfargument name="stObject" required="true" type="struct" hint="The object of the record that this field is part of.">
		<cfargument name="stMetadata" required="true" type="struct" hint="This is the metadata that is either setup as part of the type.cfc or overridden when calling ft:object by using the stMetadata argument.">
		<cfargument name="fieldname" required="true" type="string" hint="This is the name that will be used for the form field. It includes the prefix that will be used by ft:processform.">

		<cfset var html = "" />
		<cfset var qProperties = querynew("name,value","varchar,varchar") />
		<cfset var propname = "" />
		<cfset var fttype = "" />
		
		<cfif len(arguments.stObject.itemtype)>
			<cfloop collection="#application.stCOAPI[arguments.stObject.itemtype].stProps#" item="propname">
				<cfset fttype = application.stCOAPI[arguments.stObject.itemtype].stProps[propname].metadata.ftType />
				<cfif not len(fttype)>
					<cfset fttype = application.stCOAPI[arguments.stObject.itemtype].stProps[propname].metadata.type />
				</cfif>
				
				<cfif structkeyexists(application.stCOAPI[arguments.stObject.itemtype].stProps[propname].metadata,"ftSeq") and listcontainsnocase("nstring,string,longchar,richtext",fttype)>
					<cfset queryaddrow(qProperties) />
					<cfset querysetcell(qProperties,"value",propname) />
					<cfif len(application.stCOAPI[arguments.stObject.itemtype].stProps[propname].metadata.ftLabel)>
						<cfset querysetcell(qProperties,"name",application.stCOAPI[arguments.stObject.itemtype].stProps[propname].metadata.ftLabel) />
					<cfelse>
						<cfset querysetcell(qProperties,"name",application.stCOAPI[arguments.stObject.itemtype].stProps[propname].metadata.name) />
					</cfif>
				</cfif>
			</cfloop>
		
			<cfquery dbtype="query" name="qProperties">
				select		*
				from		qProperties
				order by	name
			</cfquery>
		
			<cfsavecontent variable="html">
				<cfoutput><select id="#arguments.fieldname#" name="#arguments.fieldname#"></cfoutput>
				
				<cfloop query="qProperties">
					<cfoutput><option value="#qProperties.value#"<cfif arguments.stMetadata.value eq qProperties.value> selected="selected"</cfif>>#qProperties.name#</option></cfoutput>
				</cfloop>
				
				<cfoutput></select><input type="hidden" name="#arguments.fieldname#" value=" "><br style="clear: both;"/></cfoutput>
			</cfsavecontent>
		<cfelse>
			<cfsavecontent variable="html">
				<!--- If no list items are selected, an empty field is posted. --->
				<cfoutput>No type selected<input type="hidden" id="#arguments.fieldname#" name="#arguments.fieldname#" value="" /></cfoutput>
			</cfsavecontent>
		</cfif>
		
		<cfreturn html />
	</cffunction>
	
	<cffunction name="ftEditEnclosureFileProperty" access="public" returntype="string" description="Provides the edit skin for enclosurefileproperty" output="false">
		<cfargument name="typename" required="true" type="string" hint="The name of the type that this field is part of.">
		<cfargument name="stObject" required="true" type="struct" hint="The object of the record that this field is part of.">
		<cfargument name="stMetadata" required="true" type="struct" hint="This is the metadata that is either setup as part of the type.cfc or overridden when calling ft:object by using the stMetadata argument.">
		<cfargument name="fieldname" required="true" type="string" hint="This is the name that will be used for the form field. It includes the prefix that will be used by ft:processform.">

		<cfset var html = "" />
		<cfset var qProperties = querynew("name,value","varchar,varchar") />
		<cfset var propname = "" />
		
		<cfif len(arguments.stObject.itemtype)>
			<cfloop collection="#application.stCOAPI[arguments.stObject.itemtype].stProps#" item="propname">
				<cfif structkeyexists(application.stCOAPI[arguments.stObject.itemtype].stProps[propname].metadata,"ftSeq") and application.stCOAPI[arguments.stObject.itemtype].stProps[propname].metadata.ftType eq "file">
					<cfset queryaddrow(qProperties) />
					<cfset querysetcell(qProperties,"value",propname) />
					<cfif len(application.stCOAPI[arguments.stObject.itemtype].stProps[propname].metadata.ftLabel)>
						<cfset querysetcell(qProperties,"name",application.stCOAPI[arguments.stObject.itemtype].stProps[propname].metadata.ftLabel) />
					<cfelse>
						<cfset querysetcell(qProperties,"name",application.stCOAPI[arguments.stObject.itemtype].stProps[propname].metadata.name) />
					</cfif>
				</cfif>
			</cfloop>
		
			<cfquery dbtype="query" name="qProperties">
				select		*
				from		qProperties
				order by	name
			</cfquery>
		
			<cfsavecontent variable="html">
				<cfoutput><select id="#arguments.fieldname#" name="#arguments.fieldname#"></cfoutput>
				<cfoutput><option value=""<cfif arguments.stMetadata.value eq ""> selected="selected"</cfif>>&lt; No media &gt;</option></cfoutput>
				
				<cfloop query="qProperties">
					<cfoutput><option value="#qProperties.value#"<cfif arguments.stMetadata.value eq qProperties.value> selected="selected"</cfif>>#qProperties.name#</option></cfoutput>
				</cfloop>
				
				<cfoutput></select><input type="hidden" name="#arguments.fieldname#" value=" "><br style="clear: both;"/></cfoutput>
			</cfsavecontent>
		<cfelse>
			<cfsavecontent variable="html">
				<!--- If no list items are selected, an empty field is posted. --->
				<cfoutput>No type selected<input type="hidden" id="#arguments.fieldname#" name="#arguments.fieldname#" value="" /></cfoutput>
			</cfsavecontent>
		</cfif>
		
		<cfreturn html />
	</cffunction>

	<cffunction name="ftEditDateProperty" access="public" returntype="string" description="Provides the edit skin for dateproperty" output="false">
		<cfargument name="typename" required="true" type="string" hint="The name of the type that this field is part of.">
		<cfargument name="stObject" required="true" type="struct" hint="The object of the record that this field is part of.">
		<cfargument name="stMetadata" required="true" type="struct" hint="This is the metadata that is either setup as part of the type.cfc or overridden when calling ft:object by using the stMetadata argument.">
		<cfargument name="fieldname" required="true" type="string" hint="This is the name that will be used for the form field. It includes the prefix that will be used by ft:processform.">

		<cfset var html = "" />
		<cfset var qProperties = querynew("name,value","varchar,varchar") />
		<cfset var propname = "" />
		<cfset var fttype	= '' />
		
		<cfif len(arguments.stObject.itemtype)>
			<cfloop collection="#application.stCOAPI[arguments.stObject.itemtype].stProps#" item="propname">
				<cfset fttype = application.stCOAPI[arguments.stObject.itemtype].stProps[propname].metadata.ftType />
				<cfif not len(fttype)>
					<cfset fttype = application.stCOAPI[arguments.stObject.itemtype].stProps[propname].metadata.type />
				</cfif>
				
				<cfif listcontains("date,datetime",fttype)>
					<cfset queryaddrow(qProperties) />
					<cfset querysetcell(qProperties,"value",propname) />
					<cfif len(application.stCOAPI[arguments.stObject.itemtype].stProps[propname].metadata.ftLabel)>
						<cfset querysetcell(qProperties,"name",application.stCOAPI[arguments.stObject.itemtype].stProps[propname].metadata.ftLabel) />
					<cfelse>
						<cfset querysetcell(qProperties,"name",application.stCOAPI[arguments.stObject.itemtype].stProps[propname].metadata.name) />
					</cfif>
				</cfif>
			</cfloop>
		
			<cfquery dbtype="query" name="qProperties">
				select		*
				from		qProperties
				order by	name
			</cfquery>
		
			<cfsavecontent variable="html">
				<cfoutput><select id="#arguments.fieldname#" name="#arguments.fieldname#"></cfoutput>
				
				<cfloop query="qProperties">
					<cfoutput><option value="#qProperties.value#"<cfif arguments.stMetadata.value eq qProperties.value> selected="selected"</cfif>>#qProperties.name#</option></cfoutput>
				</cfloop>
				
				<cfoutput></select><input type="hidden" name="#arguments.fieldname#" value=" "><br style="clear: both;"/></cfoutput>
			</cfsavecontent>
		<cfelse>
			<cfsavecontent variable="html">
				<!--- If no list items are selected, an empty field is posted. --->
				<cfoutput>No type selected<input type="hidden" id="#arguments.fieldname#" name="#arguments.fieldname#" value="" /></cfoutput>
			</cfsavecontent>
		</cfif>
		
		<cfreturn html />
	</cffunction>

	<cffunction name="getHoursList" access="public" returntype="query" description="Return list of hours" output="false">
		<cfset var i = 0 />
		<cfset var hourlabels = arraynew(1) />
		<cfset var stTZ = getTimeZoneInfo() />
		<cfset var qResult = querynew("value,name,orderfield","varchar,varchar,integer") />
		
		<cfset hourlabels[1] = "Midnight - 1am" />
		<cfset hourlabels[2] = "1am - 2am" />
		<cfset hourlabels[3] = "2am - 3am" />
		<cfset hourlabels[4] = "3am - 4am" />
		<cfset hourlabels[5] = "4am - 5am" />
		<cfset hourlabels[6] = "5am - 6am" />
		<cfset hourlabels[7] = "6am - 7am" />
		<cfset hourlabels[8] = "7am - 8am" />
		<cfset hourlabels[9] = "8am - 9am" />
		<cfset hourlabels[10] = "9am - 10am" />
		<cfset hourlabels[11] = "10am - 11am" />
		<cfset hourlabels[12] = "11am - Noon" />
		<cfset hourlabels[13] = "Noon - 1pm" />
		<cfset hourlabels[14] = "1pm - 2pm" />
		<cfset hourlabels[15] = "2pm - 3pm" />
		<cfset hourlabels[16] = "3pm - 4pm" />
		<cfset hourlabels[17] = "4pm - 5pm" />
		<cfset hourlabels[18] = "5pm - 6pm" />
		<cfset hourlabels[19] = "6pm - 7pm" />
		<cfset hourlabels[20] = "7pm - 8pm" />
		<cfset hourlabels[21] = "8pm - 9pm" />
		<cfset hourlabels[22] = "9pm - 10pm" />
		<cfset hourlabels[23] = "10pm - 11pm" />
		<cfset hourlabels[24] = "11pm - Midnight" />
		
		<cfloop from="0" to="23" index="i">
			<cfset queryaddrow(qResult) />
			<cfif i+stTZ.utcHourOffset gte 0 and i+stTZ.utcHourOffset lte 23>
				<cfset querysetcell(qResult,"value",i+stTZ.utcHourOffset) />
			<cfelseif i+stTZ.utcHourOffset lt 0>
				<cfset querysetcell(qResult,"value",i+stTZ.utcHourOffset+24) />
			<cfelse>
				<cfset querysetcell(qResult,"value",i+stTZ.utcHourOffset-24) />
			</cfif>
			<cfset querysetcell(qResult,"name",hourlabels[i+1]) />
			<cfset querysetcell(qResult,"orderfield",i) />
		</cfloop>
		
		<cfquery dbtype="query" name="qResult">
			select		*
			from		qResult
			order by	orderfield
		</cfquery>
		
		<cfreturn qResult />
	</cffunction>

	<cffunction name="getDaysList" access="public" returntype="string" description="Retuns list of days" output="false">
	
		<cfreturn "Sunday,Monday,Tuesday,Wednesday,Thursday,Friday,Saturday" />
	</cffunction>

	<cffunction name="getiTunesCategoryList" access="public" returntype="string" description="Returns a list of iTunes categories" output="false">
		<cfset var result = "" />
		
		<cfset result = listappend(result,"Arts > Design") />
		<cfset result = listappend(result,"Arts > Fashion & Beauty") />
		<cfset result = listappend(result,"Arts > Food") />
		<cfset result = listappend(result,"Arts > Literature") />
		<cfset result = listappend(result,"Arts > Performing Arts") />
		<cfset result = listappend(result,"Arts > Visual Arts") />
		
		<cfset result = listappend(result,"Business > Business News") />
		<cfset result = listappend(result,"Business > Careers") />
		<cfset result = listappend(result,"Business > Investing") />
		<cfset result = listappend(result,"Business > Management & Marketing") />
		<cfset result = listappend(result,"Business > Shopping") />
		
		<cfset result = listappend(result,"Comedy") />
		
		<cfset result = listappend(result,"Education > Education Technology") />
		<cfset result = listappend(result,"Education > Higher Education") />
		<cfset result = listappend(result,"Education > K-12") />
		<cfset result = listappend(result,"Education > Language Courses") />
		<cfset result = listappend(result,"Education > Training") />
		
		<cfset result = listappend(result,"Games & Hobbies > Automotive") />
		<cfset result = listappend(result,"Games & Hobbies > Aviation") />
		<cfset result = listappend(result,"Games & Hobbies > Hobbies") />
		<cfset result = listappend(result,"Games & Hobbies > Other Games") />
		<cfset result = listappend(result,"Games & Hobbies > Video Games") />
		
		<cfset result = listappend(result,"Government & Organizations > Local") />
		<cfset result = listappend(result,"Government & Organizations > National") />
		<cfset result = listappend(result,"Government & Organizations > Non-Profit") />
		<cfset result = listappend(result,"Government & Organizations > Regional") />
		
		<cfset result = listappend(result,"Health > Alternative Health") />
		<cfset result = listappend(result,"Health > Fitness & Nutrition") />
		<cfset result = listappend(result,"Health > Self-Help") />
		<cfset result = listappend(result,"Health > Sexuality") />
		
		<cfset result = listappend(result,"Kids & Family") />
		
		<cfset result = listappend(result,"Music") />
		
		<cfset result = listappend(result,"News & Politics") />
		
		<cfset result = listappend(result,"Religion & Spirituality > Buddhism") />
		<cfset result = listappend(result,"Religion & Spirituality > Christianity") />
		<cfset result = listappend(result,"Religion & Spirituality > Hinduism") />
		<cfset result = listappend(result,"Religion & Spirituality > Islam") />
		<cfset result = listappend(result,"Religion & Spirituality > Judaism") />
		<cfset result = listappend(result,"Religion & Spirituality > Other") />
		<cfset result = listappend(result,"Religion & Spirituality > Spirituality") />
		
		<cfset result = listappend(result,"Science & Medicine > Medicine") />
		<cfset result = listappend(result,"Science & Medicine > Natural Sciences") />
		<cfset result = listappend(result,"Science & Medicine > Social Sciences") />
		
		<cfset result = listappend(result,"Society & Culture > History") />
		<cfset result = listappend(result,"Society & Culture > Personal Journals") />
		<cfset result = listappend(result,"Society & Culture > Philosophy") />
		<cfset result = listappend(result,"Society & Culture > Places & Travel") />
		
		<cfset result = listappend(result,"Sports & Recreation > Amateur") />
		<cfset result = listappend(result,"Sports & Recreation > College & High School") />
		<cfset result = listappend(result,"Sports & Recreation > Outdoor") />
		<cfset result = listappend(result,"Sports & Recreation > Professional") />
		
		<cfset result = listappend(result,"Technology > Gadgets") />
		<cfset result = listappend(result,"Technology > Tech News") />
		<cfset result = listappend(result,"Technology > Podcasting") />
		<cfset result = listappend(result,"Technology > Software How-To") />
		
		<cfset result = listappend(result,"TV & Film") />
		
		<cfreturn result />
	</cffunction>

	<cffunction name="ftEditiTunesSubtitleProperty" access="public" returntype="string" description="Provides the edit skin for itunessubtitleproperty" output="false">
		<cfargument name="typename" required="true" type="string" hint="The name of the type that this field is part of.">
		<cfargument name="stObject" required="true" type="struct" hint="The object of the record that this field is part of.">
		<cfargument name="stMetadata" required="true" type="struct" hint="This is the metadata that is either setup as part of the type.cfc or overridden when calling ft:object by using the stMetadata argument.">
		<cfargument name="fieldname" required="true" type="string" hint="This is the name that will be used for the form field. It includes the prefix that will be used by ft:processform.">

		<cfset var html = "" />
		<cfset var qProperties = querynew("name,value","varchar,varchar") />
		<cfset var propname = "" />
		<cfset var fttype	= '' />
		
		<cfif len(arguments.stObject.itemtype)>
			<cfloop collection="#application.stCOAPI[arguments.stObject.itemtype].stProps#" item="propname">
				<cfset fttype = application.stCOAPI[arguments.stObject.itemtype].stProps[propname].metadata.ftType />
				<cfif not len(fttype)>
					<cfset fttype = application.stCOAPI[arguments.stObject.itemtype].stProps[propname].metadata.type />
				</cfif>
				
				<cfif structkeyexists(application.stCOAPI[arguments.stObject.itemtype].stProps[propname].metadata,"ftSeq") and listcontains("nstring,string",fttype)>
					<cfset queryaddrow(qProperties) />
					<cfset querysetcell(qProperties,"value",propname) />
					<cfif len(application.stCOAPI[arguments.stObject.itemtype].stProps[propname].metadata.ftLabel)>
						<cfset querysetcell(qProperties,"name",application.stCOAPI[arguments.stObject.itemtype].stProps[propname].metadata.ftLabel) />
					<cfelse>
						<cfset querysetcell(qProperties,"name",application.stCOAPI[arguments.stObject.itemtype].stProps[propname].metadata.name) />
					</cfif>
				</cfif>
			</cfloop>
		
			<cfquery dbtype="query" name="qProperties">
				select		*
				from		qProperties
				order by	name
			</cfquery>
		
			<cfsavecontent variable="html">
				<cfoutput><select id="#arguments.fieldname#" name="#arguments.fieldname#"></cfoutput>
				<cfoutput><option value=""<cfif arguments.stMetadata.value eq ""> selected="selected"</cfif>>&lt; No media &gt;</option></cfoutput>
				
				<cfloop query="qProperties">
					<cfoutput><option value="#qProperties.value#"<cfif arguments.stMetadata.value eq qProperties.value> selected="selected"</cfif>>#qProperties.name#</option></cfoutput>
				</cfloop>
				
				<cfoutput></select><input type="hidden" name="#arguments.fieldname#" value=" "><br style="clear: both;"/></cfoutput>
			</cfsavecontent>
		<cfelse>
			<cfsavecontent variable="html">
				<!--- If no list items are selected, an empty field is posted. --->
				<cfoutput>No type selected<input type="hidden" id="#arguments.fieldname#" name="#arguments.fieldname#" value="" /></cfoutput>
			</cfsavecontent>
		</cfif>
		
		<cfreturn html />
	</cffunction>

	<cffunction name="ftEditKeywordsProperty" access="public" returntype="string" description="Provides the edit skin for ituneskeywordsproperty" output="false">
		<cfargument name="typename" required="true" type="string" hint="The name of the type that this field is part of.">
		<cfargument name="stObject" required="true" type="struct" hint="The object of the record that this field is part of.">
		<cfargument name="stMetadata" required="true" type="struct" hint="This is the metadata that is either setup as part of the type.cfc or overridden when calling ft:object by using the stMetadata argument.">
		<cfargument name="fieldname" required="true" type="string" hint="This is the name that will be used for the form field. It includes the prefix that will be used by ft:processform.">

		<cfset var html = "" />
		<cfset var qProperties = querynew("name,value","varchar,varchar") />
		<cfset var propname = "" />
		<cfset var fttype	= '' />
		
		<cfif len(arguments.stObject.itemtype)>
			<cfloop collection="#application.stCOAPI[arguments.stObject.itemtype].stProps#" item="propname">
				<cfset fttype = application.stCOAPI[arguments.stObject.itemtype].stProps[propname].metadata.type />
				
				<cfif structkeyexists(application.stCOAPI[arguments.stObject.itemtype].stProps[propname].metadata,"ftSeq") and listcontains("nstring,string",fttype)>
					<cfset queryaddrow(qProperties) />
					<cfset querysetcell(qProperties,"value",propname) />
					<cfif len(application.stCOAPI[arguments.stObject.itemtype].stProps[propname].metadata.ftLabel)>
						<cfset querysetcell(qProperties,"name",application.stCOAPI[arguments.stObject.itemtype].stProps[propname].metadata.ftLabel) />
					<cfelse>
						<cfset querysetcell(qProperties,"name",application.stCOAPI[arguments.stObject.itemtype].stProps[propname].metadata.name) />
					</cfif>
				</cfif>
			</cfloop>
		
			<cfquery dbtype="query" name="qProperties">
				select		*
				from		qProperties
				order by	name
			</cfquery>
		
			<cfsavecontent variable="html">
				<cfoutput><select id="#arguments.fieldname#" name="#arguments.fieldname#"></cfoutput>
				<cfoutput><option value=""<cfif arguments.stMetadata.value eq ""> selected="selected"</cfif>>&lt; No media &gt;</option></cfoutput>
				
				<cfloop query="qProperties">
					<cfoutput><option value="#qProperties.value#"<cfif arguments.stMetadata.value eq qProperties.value> selected="selected"</cfif>>#qProperties.name#</option></cfoutput>
				</cfloop>
				
				<cfoutput></select><input type="hidden" name="#arguments.fieldname#" value=" "><br style="clear: both;"/></cfoutput>
			</cfsavecontent>
		<cfelse>
			<cfsavecontent variable="html">
				<!--- If no list items are selected, an empty field is posted. --->
				<cfoutput>No type selected<input type="hidden" id="#arguments.fieldname#" name="#arguments.fieldname#" value="" /></cfoutput>
			</cfsavecontent>
		</cfif>
		
		<cfreturn html />
	</cffunction>

	<cffunction name="ftEditiTunesDurationProperty" access="public" returntype="string" description="Provides the edit skin for itunesdurationproperty" output="false">
		<cfargument name="typename" required="true" type="string" hint="The name of the type that this field is part of.">
		<cfargument name="stObject" required="true" type="struct" hint="The object of the record that this field is part of.">
		<cfargument name="stMetadata" required="true" type="struct" hint="This is the metadata that is either setup as part of the type.cfc or overridden when calling ft:object by using the stMetadata argument.">
		<cfargument name="fieldname" required="true" type="string" hint="This is the name that will be used for the form field. It includes the prefix that will be used by ft:processform.">

		<cfset var html = "" />
		<cfset var qProperties = querynew("name,value","varchar,varchar") />
		<cfset var propname = "" />
		<cfset var fttype	= '' />
		
		<cfif len(arguments.stObject.itemtype)>
			<cfloop collection="#application.stCOAPI[arguments.stObject.itemtype].stProps#" item="propname">
				<cfset fttype = application.stCOAPI[arguments.stObject.itemtype].stProps[propname].metadata.ftType />
				<cfset fttype = application.stCOAPI[arguments.stObject.itemtype].stProps[propname].metadata.type />
				
				<cfif structkeyexists(application.stCOAPI[arguments.stObject.itemtype].stProps[propname].metadata,"ftSeq") and listcontains("nstring,string,numeric",fttype)>
					<cfset queryaddrow(qProperties) />
					<cfset querysetcell(qProperties,"value",propname) />
					<cfif len(application.stCOAPI[arguments.stObject.itemtype].stProps[propname].metadata.ftLabel)>
						<cfset querysetcell(qProperties,"name",application.stCOAPI[arguments.stObject.itemtype].stProps[propname].metadata.ftLabel) />
					<cfelse>
						<cfset querysetcell(qProperties,"name",application.stCOAPI[arguments.stObject.itemtype].stProps[propname].metadata.name) />
					</cfif>
				</cfif>
			</cfloop>
		
			<cfquery dbtype="query" name="qProperties">
				select		*
				from		qProperties
				order by	name
			</cfquery>
		
			<cfsavecontent variable="html">
				<cfoutput><select id="#arguments.fieldname#" name="#arguments.fieldname#"></cfoutput>
				<cfoutput><option value=""<cfif arguments.stMetadata.value eq ""> selected="selected"</cfif>>&lt; No media &gt;</option></cfoutput>
				
				<cfloop query="qProperties">
					<cfoutput><option value="#qProperties.value#"<cfif arguments.stMetadata.value eq qProperties.value> selected="selected"</cfif>>#qProperties.name#</option></cfoutput>
				</cfloop>
				
				<cfoutput></select><input type="hidden" name="#arguments.fieldname#" value=" "><br style="clear: both;"/></cfoutput>
			</cfsavecontent>
		<cfelse>
			<cfsavecontent variable="html">
				<!--- If no list items are selected, an empty field is posted. --->
				<cfoutput>No type selected<input type="hidden" id="#arguments.fieldname#" name="#arguments.fieldname#" value="" /></cfoutput>
			</cfsavecontent>
		</cfif>
		
		<cfreturn html />
	</cffunction>

	<cffunction name="getFeedObjects" access="public" returntype="query" description="Returns a query of objects to output in the feed" output="false">
		<cfargument name="objectid" type="uuid" required="false" hint="The objectid of the feed to process" />
		<cfargument name="stObj" type="struct" required="false" hint="A webfeed object struct to process" />
		
		<cfset var qResult = querynew("empty") />
		
		<cfif not structkeyexists(arguments,"objectid") and not structkeyexists(arguments,"stObj")>
			<cfthrow message="getFeedObjects requires the objectid or stObj argument" />
		<cfelseif not structkeyexists(arguments,"stObj")>
			<cfset arguments.stObj = getData(arguments.objectid) />
		</cfif>
		
		<!--- Get objects --->
		<cfif len(arguments.stObj.catFilter)>
			<cfset qResult = application.factory.oCategory.getObjectByCategory(lCategories=arguments.stObj.catFilter,typename=arguments.stObj.itemtype,bHasAny=true) />
			
			<cfquery dbtype="query" name="qResult" maxrows="10">
				select		objectid,datetimelastupdated
				from		qResult
				<cfif len(arguments.stObj.enclosurefileproperty)>
					where	#arguments.stObj.enclosurefileproperty# like '%.mp3' or #arguments.stObj.enclosurefileproperty# like '%.m4v'
				</cfif>
				order by	#arguments.stObj.dateproperty# desc
			</cfquery>
		<cfelse>
			<cfquery datasource="#application.dsn#" name="qResult" maxrows="10">
				select		objectid,datetimelastupdated
				from		#application.dbowner##arguments.stObj.itemtype#
				<cfif len(arguments.stObj.enclosurefileproperty)>
					where	#arguments.stObj.enclosurefileproperty# like '%.mp3' or #arguments.stObj.enclosurefileproperty# like '%.m4v'
				</cfif>
				order by	#arguments.stObj.dateproperty# desc
			</cfquery>
		</cfif>
		
		<cfreturn qResult />
	</cffunction>

</cfcomponent>