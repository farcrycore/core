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
<cfimport taglib="/farcry/farcry_core/tags/admin/" prefix="admin" >

<cfinclude template="/farcry/farcry_core/admin/includes/utilityFunctions.cfm">


<cfparam name="url.primaryObjectID" default="">
<cfparam name="url.primaryTypeName" default="">
<cfparam name="url.primaryFieldName" default="">
<cfparam name="url.primaryFormFieldName" default="">
<cfparam name="url.ftJoin" default="">
<cfparam name="url.WizzardID" default="">

<cfparam name="url.ftLibraryAddNewMethod" default="AddNew"><!--- Method to Add New Object --->

<cfparam name="url.ftLibraryPickMethod" default="Pick"><!--- Method to Pick Existing Objects --->
<cfparam name="url.ftLibraryPickListClass" default="thumbNailsWrap">
<cfparam name="url.ftLibraryPickListStyle" default="">

<cfparam name="url.ftLibrarySelectedMethod" default="Selected"><!--- Method to Pick Existing Objects --->
<cfparam name="url.ftLibrarySelectedListClass" default="thumbNailsWrap">
<cfparam name="url.ftLibrarySelectedListStyle" default="">


<!--- Cleanup the Query_String so that we can paginate correctly --->
<cfscript>
	stURL = Duplicate(url);
	stURL = filterStructure(stURL,'Page');
	queryString=structToNamePairs(stURL);
</cfscript>



<ft:processForm action="Attach Selected">

	<cfset oPrimary = createObject("component",application.types[url.primaryTypeName].typepath)>	
	<cfset stPrimary = oPrimary.getdata(objectid=url.primaryObjectID)>
	
	<cfset stProperties = StructNew()>
	<cfset stproperties.objectid = url.primaryObjectID>
	<cfset stproperties[url.primaryFieldName] = stPrimary[url.primaryFieldName]>
	
	<cfset lArray = arraytolist(stPrimary[url.primaryFieldName])>
	
	<cfparam name="form.#url.primaryFieldName#" default="">
	
	<cfloop list="#form[url.primaryFieldName]#" index="i">
		<cfif not listcontainsnocase(lArray,i)>
			<cfset arrayappend(stproperties[url.primaryFieldName],i)>
		</cfif>
	</cfloop>	

	<cfset stPrimary = oPrimary.setData(stProperties=stProperties,user="#session.dmSec.authentication.userlogin#")>	

</ft:processForm>



<ft:processForm action="Attach,Attach & Add Another">
	
	<ft:processFormObjects typename="#url.ftJoin#" /><!--- Returns variables.lSavedObjectIDs --->

	<!--- Attach the Newly Created Object --->
	<cfset oPrimary = createObject("component",application.types[url.primaryTypeName].typepath)>		
	<cfset stPrimary = oPrimary.getdata(objectid=url.primaryObjectID)>	
	
	<cfset lArray = arraytolist(stPrimary[url.primaryFieldName])>
	
	<cfloop list="#lSavedObjectIDs#" index="i">
		<cfif not listcontainsnocase(lArray,i)>
			<cfset arrayappend(stPrimary[url.primaryFieldName],i)>
		</cfif>				
	</cfloop>	
	
	
	<cfset stResult = oPrimary.setData(stProperties=stPrimary,user="#session.dmSec.authentication.userlogin#")>


</ft:processForm>



	<!--- <ft:processForm action="Create">
		
		<cffile action="UPLOAD"
			filefield="ImageZipFile" 
			destination="#application.path.project#\www\images\Original\"
			nameconflict="MAKEUNIQUE">
			
		<cfset ImageZipFile = Duplicate(File)>

		<!--- Unzip the  --->
		<cfset oZip = createObject("component","#application.packagepath#.farcry.tmt_zip")>
		
		<cfset qZip = oZip.getEntryList(zipFilePath="#ImageZipFile.SERVERDIRECTORY#\#ImageZipFile.SERVERFILE#")>
		
		<cfoutput query="qZip">
			<cfif len(qZip.PathFromBase) and qZip.Type EQ "file">
				<cfset oZip.unZipEntry(zipFilePath="#ImageZipFile.SERVERDIRECTORY#\#ImageZipFile.SERVERFILE#", filepath="#qZip.PathFromBase#", destination="#application.path.project#\www\images\original")>
				
				<cfx_image action="read" file="#application.path.project#\www\images\original\#qZip.PathFromBase#">
				<cfif IMG_TYPE EQ "JPEG">
					
					<cfx_image action="resize"
						file="#application.path.project#\www\images\original\#qZip.PathFromBase#"
						output="#application.path.project#\www\images\optimised\#qZip.Name#"
						X="300"
						Y="480"
						QUALITY="100"
						thumbnail=yes
						bevel="0"
						backcolor="white">
					<cfx_image action="resize"
						file="#application.path.project#\www\images\original\#qZip.PathFromBase#"
						output="#application.path.project#\www\images\thumbnail\#qZip.Name#"
						X="150"
						Y="240"
						QUALITY="100"
						thumbnail=yes
						bevel="0"
						backcolor="white">
						
					<cfset stProperties = structNew()>
					<cfset stProperties.imagefile = qZip.Name>
					<cfset stProperties.originalImagePath = "#application.url.webroot#/images/original">
					<cfset stProperties.optimisedImage = qZip.Name>
					<cfset stProperties.optimisedImagePath = "#application.url.webroot#/images/optimised">
					<cfset stProperties.thumbnail = qZip.Name>
					<cfset stProperties.thumbnailImagePath = "#application.url.webroot#/images/thumbnail">
					<cfset stProperties.bLibrary = 1>	
					<cfset stProperties.status = "approved">	
					
					<cfset t = createObject("component",application.types[url.ftJoin].typepath)>
					<cfset stImage =  t.createData(stproperties=stProperties)>
					
					<!--- update category --->
					<cfparam name="form.lSelectedCategoryID" default="">
					<cfinvoke component="#application.packagepath#.farcry.category" method="assignCategories" returnvariable="stStatus">
						<cfinvokeargument name="objectID" value="#stImage.objectID#"/>
						<cfinvokeargument name="lCategoryIDs" value="#form.lSelectedCategoryID#"/>
						<cfinvokeargument name="dsn" value="#application.dsn#"/>
					</cfinvoke>
					
					<!--- Attach the Newly Created Object --->
					<cfset t = createObject("component",application.types[url.primaryTypeName].typepath)>		
					<cfset stObj = t.getdata(objectid=url.primaryObjectID)>	
					
					<cfset lArray = arraytolist(stobj[url.primaryFieldName])>
					
					<cfloop list="#stImage.ObjectID#" index="i">
						<cfif not listcontainsnocase(lArray,i)>
							<cfset arrayappend(stObj[url.primaryFieldName],i)>
						</cfif>				
					</cfloop>	
					
					<cfparam name="session.dmSec.authentication.userlogin" default="anonymous">
					<cfset stobj = t.setData(stProperties=stObj)>
										
					
				</cfif>
			</cfif>
		</cfoutput>
		
		

		
		
		
		
	</ft:processForm> --->
	
	
<ft:processForm action="Close,Cancel">
	<cfoutput>
	<script type="text/javascript">
		self.blur();
		window.close();
	</script>
	</cfoutput>
	<cfabort>
</ft:processForm>

<ft:processForm action="Attach & Add Another" url="#cgi.script_name#?#querystring#&librarySection=Add" />

<ft:processForm action="*" url="#cgi.script_name#?#querystring#" />


<admin:Header Title="Library" bodyclass="popup imagebrowse">



<cfset oPrimary = createObject("component",application.types[url.primaryTypeName].typepath)>
<cfset q = oPrimary.getArrayFieldAsQuery(objectid="#url.primaryObjectID#", Fieldname="#url.primaryFieldName#", Typename="#url.primaryTypeName#", Link="#url.ftJoin#")>
	

<cfset oData = createObject("component",application.types[url.ftJoin].typepath)>


<cfquery datasource="#application.dsn#" name="qLibraryList">
SELECT ObjectID
FROM #URL.ftJoin#
</cfquery>

<!--- Put JS and CSS for TabStyle1 into the header --->
<cfset Request.InHead.TabStyle1 = 1>

<cfoutput>

	<h1>Library...</h1>

		
		
				
		
		<div id="LibraryTab" class="tab-container">
        	<ul class="links" style="">                   
				<li id="tab1" class="current"><a href="#cgi.script_name#?#querystring#&librarySection=Select"><span>SELECT</span></a></li>
				<li id="tab2"><a href="#cgi.script_name#?#querystring#&librarySection=Add"><span>ADD NEW</span></a></li>			
			</ul>
			<div class="tab-panes">
				<div class="panel">
				
					<ft:form style="width:100%;background:none;border:0px;">
					<table style="width:100%;background:##fa0;">
					<tr>
						<td width="100px;" valign="top">
							<div id="utility">
								<h2>Basket</h2> 
								
								<style type="text/css">
									.basket-active {background:##E17000;}
								</style>		
								
								<div id="basket" style="border:1px solid ##E17000;min-height:100px;_height:100px;">
									<ft:object ObjectID="#url.primaryObjectID#" wizzardid="#url.WizzardID#" lFields="#url.primaryFieldName#" InTable=0 IncludeLabel=0 />
								</div>	
															
							</div><!--- utility --->						
						</td>
						<td valign="top">

							<div id="content" style="margin-left:0px;" >
								<!--- Render all the objects for the requested Type. --->
								<ws:paginate PageLinksShown=5 RecordsPerPage=20 query="#qLibraryList#">
									<div style="display:block;">	
										<ul class="#url.ftLibraryPickListClass#" style="#url.ftLibraryPickListStyle#">
											<ws:paginateRecords r_stRecord="stObject">
												<li id="select#stObject.objectID#" class="LibraryItem" style="cursor:pointer;" objectID="#stObject.ObjectID#">
													<cfif FileExists("#application.path.project#/webskin/#url.ftJoin#/#url.ftLibraryPickMethod#.cfm")>
														<cfset stobj = oData.getData(objectid=stObject.ObjectID)>
														<cfinclude template="/farcry/#application.applicationname#/webskin/#url.ftJoin#/#url.ftLibraryPickMethod#.cfm">
													<cfelse>
														#stObject.ObjectID#
													</cfif>
		
												</li>
											</ws:paginateRecords>
										</ul>
									</div>	
									
									<br style="clear:both;" />
									
									<div style="border:1px dashed ##CACACA;border-width:1px 0;">
										<ws:paginateScroll />
										<br style="clear:both;" />
									</div>
								</ws:paginate>
							
								<div class="f-submit-wrap">
									<div style="float:left;">
									<cfif qLibraryList.recordCount GT 0>	
										<ft:farcrybutton type="button" value="Close" onclick="self.blur();window.close();" />
									</cfif>
									</div>
									
									<br style="clear:both;" />
								</div>
								
		
						
							</div> <!--- content --->						
						</td>
					</tr>
					</table>

					
						
					</ft:form>
				</div>
				<div class="panel">
					<ft:form>
						<div id="utility">
							<h2>Browse by category</h2> 
						</div><!--- utility --->
						
						<div id="content">
							
							
							<cfif StructKeyExists(oData,url.ftLibraryAddNewMethod)>
								<cfinvoke component="#oData#" method="#url.ftLibraryAddNewMethod#">
									<cfinvokeargument name="typename" value="#url.ftJoin#">
								</cfinvoke>
							<cfelse>
								<cfinvoke component="#oData#" method="AddNew">
									<cfinvokeargument name="typename" value="#url.ftJoin#">
								</cfinvoke>
							</cfif>

							
							
							<div class="f-submit-wrap">
								<div style="float:left;">
									<ft:farcrybutton value="Attach" />	
									<ft:farcrybutton type="button" value="Close" onclick="self.blur();window.close();" />	
								</div>
								
								<br style="clear:both;" />
							</div>
							
						</div>
					</ft:form>
				</div>
				
				<br style="clear:both;" />
			</div>
		</div>
	
		
		<br style="clear:both" />



		
		
		
		<cfset Request.InHead.ScriptaculousEffects = 1>
		
		<script type="text/javascript">
			
		<cfloop query="q">
			Effect.Fade($('select#q.objectID#'), {from:0.2,to:0.2});
		</cfloop>	
		
		<cfloop query="qLibraryList" startrow="#StartRow#" endrow="#EndRow#">
			new Draggable('select#qLibraryList.objectID#',
			 
		      {revert:true,
		      	endeffect: function(element) { 
		        	//new Effect.Opacity(element, {duration:1, from:0, to:.2}); 
		      	}
		      }
		     )
		</cfloop>
		
		Droppables.add('basket', {
			accept:'LibraryItem',
			hoverclass:'basket-active',
			onDrop:function(element) {
				//Effect.Opacity(element, {duration:2, from:0, to:.2}); 
				Effect.Fade(element, {duration:2,from:0,to:0.2});
				//$('#URL.primaryFieldName#').value = $(element).getAttribute('objectid');
                //$('basket').innerHTML = element.innerHTML;
                 new Ajax.Updater('basket', '/farcry/facade/library.cfc?method=ajaxUpdateArray', {
					//onLoading:function(request){Element.show('indicator')}, 
					onComplete:function(request){

						$('basket').innerHTML = request.responseText;
						opener.update_#url.primaryFormFieldname#_wrapper(request.responseText);						
						Effect.Fade(element, {from:0.2,to:0.2});
					}, 
					parameters:'primaryObjectID=#url.primaryObjectID#&primaryTypename=#url.primaryTypeName#&primaryFieldname=#url.primaryFieldname#&primaryFormFieldname=#url.primaryFormFieldname#&WizzardID=#url.WizzardID#&DataObjectID=' + encodeURIComponent($(element).getAttribute('objectid')) + '&DataTypename=#url.ftJoin#', evalScripts:true, asynchronous:true
				}) 
				
                				
			}
		})
			


		initTabNavigation('LibraryTab','current','tab-disabled');
		
		</script>
</cfoutput>	

<admin:footer>
