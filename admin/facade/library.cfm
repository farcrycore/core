<!--- 
|| LEGAL ||
$Copyright: Daemon Pty Limited 1995-2003, http://www.daemon.com.au $
$License: Released Under the "Common Public License 1.0", http://www.opensource.org/licenses/cpl.php$

|| VERSION CONTROL ||
$Header: $
$Author: $
$Date: $
$Name:  $
$Revision: $

|| DESCRIPTION || 
$Description:  $
$TODO: $

|| DEVELOPER ||
$Developer: $

@@displayname: Type Library Picker Page
@@author: Mat Bryant (mat@daemon.com.au)
 --->


<cfimport taglib="/farcry/farcry_core/tags/webskin/" prefix="ws" >
<cfimport taglib="/farcry/farcry_core/tags/formtools/" prefix="ft" >
<cfimport taglib="/farcry/farcry_core/tags/widgets/" prefix="widgets" >

<cfinclude template="/farcry/farcry_core/admin/includes/utilityFunctions.cfm">


<cfparam name="url.primaryObjectID" default="">
<cfparam name="url.primaryTypeName" default="">
<cfparam name="url.primaryFieldName" default="">
<cfparam name="url.primaryFormFieldName" default="">
<cfparam name="url.ftLink" default="">
<cfparam name="url.ftLibraryFieldList" default="objectid">
<cfparam name="url.ftLibraryPickerMethod" default="ftPicker"><!--- ftLibraryPickerMethod --->
<cfparam name="url.ftLibraryPickerListCSS" default="thumbNailsWrap"><!--- thumbNailsWrap --->
<cfparam name="url.ftLibraryPickerListStyle" default="">
<cfparam name="url.ftLibraryAddMethod" default="ftAdd">



<cfscript>
	stURL = Duplicate(url);
	stURL = filterStructure(stURL,'Page');
	queryString=structToNamePairs(stURL);
</cfscript>


<ft:processForm action="Attach Selected">
	


	<cfset t = createObject("component",application.types[url.primaryTypeName].typepath)>
	
	
	<cfset stobj = t.getdata(objectid=url.primaryObjectID)>
	

	<cfset stProperties = StructNew()>
	<cfset stproperties.objectid = url.primaryObjectID>
	<cfset stproperties[url.primaryFieldName] = stobj[url.primaryFieldName]>
	
	<cfset lArray = arraytolist(stobj[url.primaryFieldName])>
	
	<cfparam name="form.#url.primaryFieldName#" default="">
	
	<cfloop list="#form[url.primaryFieldName]#" index="i">
		<cfif not listcontainsnocase(lArray,i)>
			<cfset arrayappend(stproperties[url.primaryFieldName],i)>
		</cfif>
	</cfloop>	

	<cfset stobj = t.setData(stProperties=stProperties,user="annonymous")>		
	

</ft:processForm>



<ft:processForm action="Attach,Attach & Add Another">

	<ft:processFormObjects typename="#url.ftLink#" /><!--- Returns variables.lSavedObjectIDs --->
	

	<!--- Attach the Newly Created Object --->
	<cfset t = createObject("component",application.types[url.primaryTypeName].typepath)>		
	<cfset stObj = t.getdata(objectid=url.primaryObjectID)>	
	
	<cfset lArray = arraytolist(stobj[url.primaryFieldName])>
	
	<cfloop list="#lSavedObjectIDs#" index="i">
		<cfif not listcontainsnocase(lArray,i)>
			<cfset arrayappend(stObj[url.primaryFieldName],i)>
		</cfif>				
	</cfloop>	
	
	<cfif isdefined("session.dmSec.authentication.userlogin")>
		<cfset userlogin = session.dmSec.authentication.userlogin>
	<cfelse>
		<cfset userlogin = "annonymous">
	</cfif>	
	
	<cfset stobj = t.setData(stProperties=stObj,user="annonymous")>


</ft:processForm>


<ft:processForm action="Close,Cancel">
	<cfoutput>
	<script type="text/javascript">
		self.blur();
		window.opener.location = window.opener.location;
		window.close();
	</script>
	</cfoutput>
	<cfabort>
</ft:processForm>

<ft:processForm action="Attach & Add Another" url="#cgi.script_name#?#querystring#&librarySection=Add" />

<ft:processForm action="*" url="#cgi.script_name#?#querystring#" />



<cfmodule template="/farcry/farcry_core/tags/admin/popupHeader.cfm" pageTitle="Library">


<cfset oPrimary = createObject("component",application.types[url.primaryTypeName].typepath)>
<cfset q = oPrimary.getArrayFieldAsQuery(objectid="#url.primaryObjectID#", Fieldname="#url.primaryFieldName#", Typename="#url.primaryTypeName#", Link="#url.ftLink#")>
	

<cfset oLibrary = createObject("component",application.types[url.ftLink].typepath)>


<cfquery datasource="#application.dsn#" name="qLibraryList">
SELECT ObjectID
<cfif len(url.ftLibraryFieldList)>
	,#url.ftLibraryFieldList#
</cfif>
FROM #URL.ftLink#
<cfif q.recordcount>WHERE ObjectID NOT IN (#ListQualify(valuelist(q.objectid),"'")#)</cfif>
</cfquery>

<!--- Put JS and CSS for tab6 into the header --->
<cfset request.inHead.Tabs6 = 1>

<cfoutput>

		<ft:form>
		
				
		
		<div id="LibraryTab">
        	<ul class="tabs6 links" style="">                   
				<li class="current"><a href="http://www.bcreative.com.au"><span>SELECT</span></a></li>
				<li><a href="http://www.bcreative.com.au"><span>ADD NEW</span></a></li>			
			</ul>
			<div class="panels" style="min-height:100px;_height:100px;border:1px solid black;padding:20px;clear:both;">
				<div class="panel">
						
						<!--- Render all the objects for the requested Type. --->
						<ws:paginate PageLinksShown=5 RecordsPerPage=9 query="#qLibraryList#">
							<cfif len(url.ftLibraryPickerMethod)>
								<div class="#url.ftLibraryPickerListCSS#" style="#url.ftLibraryPickerListStyle#">
									<ul>
										<cfloop query="qLibraryList" startrow="#StartRow#" endrow="#EndRow#">
											<li id="select#qLibraryList.objectID#" class="LibraryItem" style="cursor:pointer;" objectID="#qLibraryList.ObjectID#">
												<input type="checkbox" id="#primaryFieldName#" name="#primaryFieldName#" value="#qLibraryList.ObjectID#" />
												<cfinvoke component="#oLibrary#" method="#url.ftLibraryPickerMethod#">
													<cfinvokeargument name="ObjectID" value="#qLibraryList.ObjectID#">
												</cfinvoke>						
											</li>				
										</cfloop>			
									</ul>
								</div>			
							<cfelse>
								<table class="table1">	
								<thead>
									<tr>
										<th>Select</th>
										<cfloop list="#url.ftLibraryFieldList#" index="i">
											<th>#i#</th>
										</cfloop>
									</tr>
								</thead>
								<tbody>
									<ws:paginateRecords r_stRecord="stObject">
										
										<tr>
											<td class="sub"><input type="checkbox" id="#primaryFieldName#" name="#primaryFieldName#" value="#stObject.ObjectID#" /></td>
											<cfloop list="#url.ftLibraryFieldList#" index="i">
												<td>#stObject[i]#</td>
											</cfloop>
										</tr>
									
									</ws:paginateRecords>
								</tbody>
								</table>
				
							</cfif>
							
							<br style="clear:both;" /> 
							
							<div style="border:1px dashed ##CACACA;border-width:1px 0;">
								<ws:paginateScroll />
								<br style="clear:both;" />
							</div>
						</ws:paginate>
					
						<div class="f-submit-wrap">
							<div style="float:left;">
							<cfif qLibraryList.recordCount GT 0>	
								<ft:farcrybutton value="Attach Selected" />	
							</cfif>
							</div>
							<div style="float:right;">
								<ft:farcrybutton value="Close" />
							</div>
							
							<br style="clear:both;" />
						</div>
						

						<style type="text/css">
							.basket-active {background:##EAEAEA;}
						</style>		
						
						<div id="basket" style="border:1px solid green;min-height:100px;_height:100px;">
							-- DRAG THE ITEMS YOU WISH TO INCLUDE HERE --
						</div>						

				</div>
				<div class="panel">
					<div id="addnew" style="cursor:pointer;">
						

						<cfif len(url.ftLibraryAddMethod)>
							<cfinvoke component="#oLibrary#" method="#url.ftLibraryAddMethod#">
								<cfinvokeargument name="ObjectID" value="">
							</cfinvoke>
						<cfelse>
						
							<cfinvoke component="#oLibrary#" method="ftEdit">
								<cfinvokeargument name="ObjectID" value="">
							</cfinvoke>
						</cfif>
						
						
						<div class="f-submit-wrap">
							<div style="float:left;">
								<ft:farcrybutton value="Attach" />	
								<ft:farcrybutton value="Attach & Add Another" />	
							</div>
							<div style="float:right;">
								<ft:farcrybutton value="Cancel" />
							</div>
							
							<br style="clear:both;" />
						</div>
						
					</div>
				</div>
				
				<br style="clear:both;" />
			</div>
		</div>
	
		
		<br style="clear:both" />



		
		</ft:form>
		
		
		<cfset Request.InHead.ScriptaculousEffects = 1>
		
		<script type="text/javascript">
		<cfloop query="qLibraryList" startrow="#StartRow#" endrow="#EndRow#">
			new Draggable('select#qLibraryList.objectID#',
			 
		      {revert:true,
		      	endeffect: function(element) { 
		        	//new Effect.Opacity(element, {duration:2, from:0, to:.2}); 
		      	}
		      }
		     )
		</cfloop>
		
		Droppables.add('basket', {
			accept:'LibraryItem',
			hoverclass:'basket-active',
			onDrop:function(element) {
				//Effect.Opacity(element, {duration:2, from:0, to:.2}); 
				//Effect.Fade(element, {from:0.2,to:0.2});
				//$('#URL.primaryFieldName#').value = $(element).getAttribute('objectid');
                //$('basket').innerHTML = element.innerHTML;
                 new Ajax.Updater('basket', '/farcry/facade/library.cfc?method=ajaxUpdateArray', {
					//onLoading:function(request){Element.show('indicator')}, 
					onComplete:function(request){
						$('basket').innerHTML = request.responseText;
						//opener.hearme(request.responseText);
						//playme('basket' + $(element).getAttribute('objectid'));
						Effect.Fade(element, {from:0.2,to:0.2});
					}, 
					parameters:'primaryObjectID=#url.primaryObjectID#&primaryTypename=#url.primaryTypeName#&primaryFieldname=#url.primaryFieldname#&DataObjectID=' + encodeURIComponent($(element).getAttribute('objectid')) + '&DataTypename=#url.ftLink#', evalScripts:true, asynchronous:true
				}) 
				
                				
			}
		})
			
		function playme(id){
			Effect.Puff($(id), {queue:{scope:'myscope', position:'end'}})
			Effect.Appear($(id), {queue:{scope:'myscope', position:'end'}})
		}
		initTabNavigation('LibraryTab','current');
		
		</script>
</cfoutput>	


<cfmodule template="/farcry/farcry_core/tags/admin/popupFooter.cfm">