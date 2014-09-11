<cfsetting enablecfoutputonly="true">
<!--- @@Copyright: Daemon Pty Limited 2002-2008, http://www.daemon.com.au --->
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
<!---
|| VERSION CONTROL ||
$Header: /cvs/farcry/core/webtop/admin/quickBuilder.cfm,v 1.9 2005/09/06 00:51:07 gstewart Exp $
$Author: gstewart $
$Date: 2005/09/06 00:51:07 $
$Name: milestone_3-0-1 $
$Revision: 1.9 $

|| DESCRIPTION || 
$Description: Quickly builds a navigation structure$
$TODO:$

|| DEVELOPER ||
$Developer: Quentin Zervaas (quentin@mitousa.com) $

|| ATTRIBUTES ||
$in: $
$out:$
--->

<cfprocessingDirective pageencoding="utf-8">

<cfimport taglib="/farcry/core/tags/admin/" prefix="admin">
<cfimport taglib="/farcry/core/tags/farcry/" prefix="farcry">
<cfimport taglib="/farcry/core/tags/navajo/" prefix="nj">
<cfimport taglib="/farcry/core/tags/security/" prefix="sec" />
<cfimport taglib="/farcry/core/tags/webskin/" prefix="skin">
<cfimport taglib="/farcry/core/tags/formtools/" prefix="ft">
<cfimport taglib="/farcry/core/packages/fourq/tags/" prefix="q4">
		
<!--- character to indicate levels --->
<cfset levelToken = "-" />


<sec:CheckPermission error="true" permission="developer">

	<ft:processForm action="Build Site Structure">
	
		<cfparam name="form.makeHTML" default="" />
		<cfparam name="form.displayMethod" default="" />
		
		<cfscript>
			aliasDelimiter = "||";
			startPoint = form.startPoint;
			if (len(form.makeHTML))
				displayMethod = form.displayMethod;
	
			createdBy = application.security.getCurrentUserID();
			status = "draft";
	
			structure = form.structure;
	
			lines = listToArray(structure, "#chr(13)##chr(10)#");
	
			// setup items with their level and objectids
			items = arrayNew(1);
			lastlevel = 1;
	
			for (i = 1; i lte arraylen(lines); i = i + 1) {
				prefix = spanIncluding(trim(lines[i]), levelToken);
				prefixLen = len(prefix);
	
				line = trim(lines[i]);
				lineLen = len(line);
	
				level = prefixLen + 1;
				if (level gt lastlevel)
					level = lastlevel + 1;
				title = trim(right(lines[i], lineLen - prefixLen));
	
				if (len(title) gt 0) {
					item = structNew();
					//item.title = ReplaceNoCase(title, "'", "''", "ALL");
					item.title = listFirst(title,aliasDelimiter);
					if(listLen(title,aliasDelimiter) eq 2){
						item.navAlias = lcase(replace(trim(listLast(title,aliasDelimiter))," ","_","ALL"));
					}
					else item.navAlias = "";
				   
					item.level = level;
					item.objectid = application.fc.utils.createJavaUUID();
					item.parentid = '';
					arrayAppend(items, item);
					lastlevel = item.level;
				}
			}
	
			parentstack = arrayNew(1);
			navstack = arrayNew(1);
			arrayAppend(parentstack, startPoint);
	
			// now figure out each item's parent node
			lastlevel = 0;
			for (i = 1; i lte arraylen(items); i = i + 1) {
				if (items[i].level lt lastlevel) {
					diff = lastlevel - items[i].level;
					for (j = 0; j lte diff; j = j + 1) {
						arrayDeleteAt(parentstack, arraylen(parentstack));
						arrayDeleteAt(navstack, arraylen(navstack));
					}
				}
				else if (items[i].level eq lastlevel) {
					arrayDeleteAt(parentstack, arraylen(parentstack));
					arrayDeleteAt(navstack, arraylen(navstack));
				}
	
				items[i].parentid = parentstack[arraylen(parentstack)];
	
				arrayAppend(parentstack, items[i].objectid);
	
				navtitle = lcase(rereplacenocase(items[i].title, "\W+", "_", "all"));
				arrayAppend(navstack, rereplace(navtitle, "_+", "_", "all"));
	
				if(items[i].navAlias neq ""){
					items[i].lNavIDAlias = items[i].navAlias;
				}
				else
					items[i].lNavIDAlias = '';
	
				lastlevel = items[i].level;
			}
			
		
			htmlItems = arrayNew(1);
	
			// now finish setting up the structure of each item
			for (i = 1; i lte arraylen(items); i = i + 1) {
				items[i].status = status;
				items[i].ExternalLink = '';
				items[i].target = '';
				items[i].options = '';
				items[i].label = items[i].title;
				items[i].createdby = createdBy;
				items[i].datetimecreated = now();
				items[i].datetimelastupdated = now();
				items[i].lastupdatedby = createdBy;
	
				if (len(form.makeHtml)) {
					htmlItem = structNew();
					htmlItem.aObjectIDs = arrayNew(1);
					htmlItem.aRelatedIDs = arrayNew(1);
					htmlItem.aTeaserImageIDs = arrayNew(1);
					htmlItem.body = "";
					htmlItem.createdBy = createdBy;
					htmlItem.datetimecreated = now();
					htmlItem.datetimelastupdated = now();
					htmlItem.displayMethod = displayMethod;
					htmlItem.title = items[i].title;
					htmlItem.label = htmlItem.title;
					htmlItem.lastUpdatedBy = createdBy;
					htmlItem.metaKeywords = "";
					htmlItem.objectID = application.fc.utils.createJavaUUID();
					htmlItem.status = status;
					htmlItem.teaser = "";
					htmlItem.typeName = form.makeHtml;
					htmlItem.versionID = "";
					htmlItem.extendedMetaData = "";
	
					arrayAppend(htmlItems, htmlItem);
	
					items[i].aObjectIDs = arrayNew(1);
					items[i].aObjectIDs[1] = htmlItem.objectID;
				}
	
				structDelete(items[i], "level");
			}
		</cfscript>

		
	
		<cfloop index="i" from="1" to="#arrayLen(htmlItems)#">
			<q4:contentobjectcreate typename="#application.types[htmlItems[i].typeName].typePath#" stProperties="#htmlItems[i]#" bAudit="false">
		</cfloop>
	
		<cfscript>
			o_dmNav = createObject("component", application.types.dmNavigation.typePath);
			o_farcrytree = createObject("component", "#application.packagepath#.farcry.tree");
	
			for (i = 1; i lte arraylen(items); i = i + 1) {
				o_dmNav.createData(dsn=application.dsn,stProperties=items[i],bAudit=false);
				o_farCryTree.setYoungest(dsn=application.dsn,parentID=items[i].parentID,objectID=items[i].objectID,objectName=items[i].title,typeName='dmNavigation');
			}
		</cfscript>
	
		<skin:bubble title="Navigation Tree Quick Builder" sticky="true" tags="quickbuilder,info">
			<cfoutput>
				#arrayLen(items)# 
				#lcase(application.fapi.getContentTypeMetadata('dmNavigation', 'displayName', 'navigation'))# 
				#application.fapi.getResource('quickbuilder.labels.contentItemsCreated@text', 'content item(s) have been created')#
				<!---	<cfset subS=listToArray('#arrayLen(items)#,"dmNavigation"')>
					#application.rb.formatRBString("sitetree.message.objectnumber@text",subS,"{1} <strong>{2}</strong> content items")#
					<cfset subS=listToArray('#arrayLen(htmlItems)#,"dmHTML"')>
					#application.rb.formatRBString("sitetree.message.objectnumber@text",subS,"{1} <strong>{2}</strong> content items")#
				--->
			</cfoutput>
		</skin:bubble>
	</ft:processForm>
	
	
	
	<!------------------- 
	THE FORM
	 --------------------->
		<skin:loadJS id="fc-jquery" />
		<skin:loadJS id="jquery-autoresize" />
		
		<cfset o = createObject("component", "#application.packagepath#.farcry.tree") />
		<cfset qNodes = o.getDescendants(dsn=application.dsn, objectid=application.fapi.getNavID('root')) />
		
		
		<ft:form>
		
			<cfoutput><h1><i class="fa fa-sitemap"></i> #application.rb.getResource("sitetree.headings.navTreeQuickBuilder@text","Navigation Tree Quick Builder")#</h1></cfoutput>
		
			
			<ft:fieldset>
			
				<ft:fieldsetHelp>
					<cfoutput>
					<admin:resource key="quickbuilder.messages.quicklyBuildFarCrySiteBlurb@text">
						<p>To quickly build a FarCry site structure, enter each node title on a new line. The hierarchy is determined by the characters in front of an item.</p>
					</admin:resource>
					</cfoutput>
				</ft:fieldsetHelp>
				
				<ft:field label="#application.rb.getResource("quickbuilder.labels.structure@label","Structure")#">
					<cfoutput>
						<textarea name="structure" id="structure" class="textareaInput autoresize"></textarea>
					</cfoutput>
					
					<ft:fieldHint>
						<cfoutput>
							Enter each item in the format: Title||Alias. The alias is optional. For Example:<br>
							&nbsp;&nbsp;Item 1<br>
							&nbsp;&nbsp;- Item 1.2<br>
							&nbsp;&nbsp;-- Item 1.2.1<br>
							&nbsp;&nbsp;- Item 1.3<br>
							&nbsp;&nbsp;Item 2<br>
							&nbsp;&nbsp;- Item 2.1<br>
							&nbsp;&nbsp;-- Item 2.2				
						</cfoutput>
					</ft:fieldHint>
				</ft:field>
			
		
				<skin:loadJS id="fc-jquery" />
				
				<skin:htmlHead>
				<cfoutput>
					<script type="application/javascript">
					function getDisplayMethod() {
						$j.ajax({
						   type: "POST",
						   url: '#application.url.farcry#/facade/quickBuilder.cfc?method=listTemplates',
						   data: { typename: $j('##makehtml').val() },
						   cache: false,
						   timeout: 10000,
						   success: function(msg){
								$j('##displayMethods').html(msg);			     	
						   }
						});
					}
					</script>
				</cfoutput>
				</skin:htmlHead>
				
				
				<ft:field label="#application.rb.getResource('quickbuilder.labels.createStructureWithin@label','Create structure within')#">
					<cfoutput>
						<select name="startPoint" id="startPoint">
							<option value="#application.fapi.getNavID('root')#">#application.rb.getResource("quickbuilder.labels.root@label","Root")#</option>
							<cfloop query="qNodes">
							<option value="#qNodes.objectId#"<cfif qNodes.objectId eq application.fapi.getNavID('home')> selected="selected"</cfif>>#RepeatString("&nbsp;&nbsp;|", qNodes.nlevel)#- #qNodes.objectName#</option>
							</cfloop>
						</select>				
					</cfoutput>
					
					<ft:fieldHint>
						<cfoutput>
						Select the navigation node under which you wish to have your new structure created.
						</cfoutput>
					</ft:fieldHint>
				</ft:field>
				
				
				<sec:CheckPermission permission="Create" objectid="#application.fapi.getNavID('home')#">
					<ft:field label="Auto Create Children">
						<cfset objType = CreateObject("component","#Application.stcoapi.dmNavigation.packagePath#")>
						<cfset lPreferredTypeSeq = "dmHTML"> <!--- this list will determine preffered order of objects in create menu - maybe this should be configurable. --->
						<!--- <cfset aTypesUseInTree = objType.buildTreeCreateTypes(lPreferredTypeSeq)> --->
						<cfset lAllTypes = structKeyList(application.types)>
						<!--- remove preffered types from *all* list --->
						<cfset aPreferredTypeSeq = listToArray(lPreferredTypeSeq)>
						<cfloop index="i" from="1" to="#arrayLen(aPreferredTypeSeq)#">
							<cfset lAlltypes = listDeleteAt(lAllTypes,listFindNoCase(lAllTypes,aPreferredTypeSeq[i]))>
						</cfloop>
						<cfset lAlltypes = ListAppend(lPreferredTypeSeq,lAlltypes)>
						<cfset aTypesUseInTree = objType.buildTreeCreateTypes(lAllTypes)>
						<cfif ArrayLen(aTypesUseInTree)>
							<cfoutput>
								
									<table>
									<tr>
										<td style="width:100px;">Type: </td>
										<td>
											<select name="makehtml" id="makehtml" onchange="getDisplayMethod()">
												<option value="">NONE</option>
												<cfloop index="i" from="1" to="#ArrayLen(aTypesUseInTree)#">								
													<cfif aTypesUseInTree[i].typename NEQ "dmNavigation">
														<option value="#aTypesUseInTree[i].typename#">#aTypesUseInTree[i].description#</option>
													</cfif>						
												</cfloop>	
											</select>
										</td>
									</tr>
									<tr>
										<td>Webskin: </td>
										<td id="displayMethods">--- select a content type above ---</td>
									</tr>
									</table>
								
							</cfoutput>
						</cfif>
						
						<ft:fieldHint>
							<cfoutput>
							If you wish to have content created under each of the new items in your structure, select the type of content and the template defining how it should be displayed.
							</cfoutput>
						</ft:fieldHint>
					</ft:field>
				</sec:CheckPermission>
				
				
			</ft:fieldset>
		
			<ft:buttonPanel>
				<ft:button value="Build Site Structure" text="#application.rb.getResource('quickbuilder.buttons.buildSiteStructure@label','Build Site Structure')#" />
			</ft:buttonPanel>
			
			
		</ft:form>
	
</sec:CheckPermission>


<cfsetting enablecfoutputonly="false">