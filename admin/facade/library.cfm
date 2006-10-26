<cfsetting enablecfoutputonly="yes">

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
<cfparam name="url.LibraryType" default="array">

<cfparam name="url.ftLibraryAddNewWebskin" default="libraryAdd"><!--- Method to Add New Object --->

<cfparam name="url.ftLibraryPickWebskin" default="libraryPick"><!--- Method to Pick Existing Objects --->
<cfparam name="url.ftLibraryPickListClass" default="thumbNailsWrap">
<cfparam name="url.ftLibraryPickListStyle" default="">

<cfparam name="url.ftLibrarySelectedWebskin" default="librarySelected"><!--- Method to Pick Existing Objects --->
<cfparam name="url.ftLibrarySelectedListClass" default="thumbNailsWrap">
<cfparam name="url.ftLibrarySelectedListStyle" default="">


<cfparam name="url.PackageType" default="types"><!--- Could be types or rules.. --->
	
<cfif url.PackageType EQ "rules">
	<cfset PrimaryPackage = application.rules[url.primaryTypeName] />
	<cfset PrimaryPackagePath = application.rules[url.primaryTypeName].rulepath />
<cfelse>
	<cfset PrimaryPackage = application.types[url.primaryTypeName] />
	<cfset PrimaryPackagePath = application.types[url.primaryTypeName].typepath />
</cfif>

<!--- TODO: dynamically determine the typename to join. --->
<cfset request.ftJoin = listFirst(url.ftJoin) />
<cfif NOT listContainsNoCase(PrimaryPackage.stProps[url.primaryFieldname].metadata.ftJoin,request.ftJoin)>
	<cfset request.ftJoin = listFirst(PrimaryPackage.stProps[url.primaryFieldname].metadata.ftJoin) />
</cfif>

<!--- Cleanup the Query_String so that we can paginate correctly --->
<cfscript>
	stURL = Duplicate(url);
	stURL = filterStructure(stURL,'Page,ftJoin');
	queryString=structToNamePairs(stURL);
</cfscript>




<ft:processForm action="Attach Selected">

	<cfset oPrimary = createObject("component",PrimaryPackagePath)>	
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
	
	<ft:processFormObjects typename="#request.ftJoin#" /><!--- Returns variables.lSavedObjectIDs --->

<!---	<!--- Attach the Newly Created Object --->
	<cfset oPrimary = createObject("component",application.types[url.primaryTypeName].typepath)>		
	<cfset stPrimary = oPrimary.getdata(objectid=url.primaryObjectID)>	
	
	<cfset lArray = arraytolist(stPrimary[url.primaryFieldName])>
	
	<cfdump var="#stPrimary#" expand="false">
	<cfloop list="#lSavedObjectIDs#" index="i">
		<cfif not listcontainsnocase(lArray,i)>
			<cfset arrayappend(stPrimary[url.primaryFieldName],i)>
		</cfif>				
	</cfloop>	
	
	
	<cfdump var="#stPrimary#" expand="false"><cfabort>
	
	<cfset stResult = oPrimary.setData(stProperties=stPrimary,user="#session.dmSec.authentication.userlogin#")>

 --->




	<cfset oPrimary = createObject("component",PrimaryPackagePath)>
	
	<cfset oData = createObject("component",application.types[request.ftJoin].typepath)>
	

	<cfloop list="#lSavedObjectIDs#" index="DataObjectID">

	
		<cfif len(url.WizzardID)>		
			
			<cfset oWizzard = createObject("component",application.types['dmWizzard'].typepath)>
			
			<cfset stWizzard = oWizzard.Read(wizzardID=url.WizzardID)>
			
			<cfif url.LibraryType EQ "UUID">
				<cfset stWizzard.Data[url.PrimaryObjectID][url.PrimaryFieldname] = DataObjectID>
		
			<cfelse><!--- Array --->
				<cfset arrayAppend(stWizzard.Data[url.PrimaryObjectID][url.PrimaryFieldname],DataObjectID)>
						
				<cfset variables.tableMetadata = createobject('component','farcry.fourq.TableMetadata').init() />
				<cfset tableMetadata.parseMetadata(md=getMetadata(oPrimary)) />		
				<cfset stFields = variables.tableMetadata.getTableDefinition() />
				
				<cfset o = createObject("component","farcry.fourq.gateway.dbGateway").init(dsn=application.dsn,dbowner="")>
				<cfset aProps = o.createArrayTableData(tableName=url.PrimaryTypename & "_" & url.PrimaryFieldName,objectid=url.PrimaryObjectID,tabledef=stFields[PrimaryFieldName].Fields,aprops=stWizzard.Data[PrimaryObjectID][url.PrimaryFieldname])>
		
				<cfset stWizzard.Data[url.PrimaryObjectID][url.PrimaryFieldname] = aProps>
			</cfif>
			
			<cfset stWizzard = oWizzard.Write(ObjectID=url.WizzardID,Data=stWizzard.Data)>
			
			<cfset st = stWizzard.Data[url.PrimaryObjectID]>
		<cfelse>
		
			<cfset stPrimary = oPrimary.getData(objectid=url.PrimaryObjectID)>
			
			<cfif url.LibraryType EQ "UUID">
				<cfset stPrimary[url.PrimaryFieldname] = DataObjectID>		
			<cfelse><!--- Array --->
				<cfset arrayAppend(stPrimary[url.PrimaryFieldname],DataObjectID)>
						
			</cfif>
		
			
			
			<cfparam name="session.dmSec.authentication.userlogin" default="anonymous" />
			<cfset oPrimary.setData(objectID=stPrimary.ObjectID,stProperties="#stPrimary#",user="#session.dmSec.authentication.userlogin#")>
			
		</cfif>
	</cfloop>
	
</ft:processForm>



	<!--- <ft:processForm action="Create">
		
		<cffile action="UPLOAD"
			filefield="ImageZipFile" 
			destination="#application.path.project#\www\images\Original\"
			nameconflict="MAKEUNIQUE">
			
		<cfset ImageZipFile = Duplicate(File)>

		<!--- Unzip the  --->
		<cfset oZip = createObject("component","#application.PrimaryPackagePath#.farcry.tmt_zip")>
		
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
					
					<cfset t = createObject("component",application.types[request.ftJoin].typepath)>
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

<ft:processForm action="Attach & Add Another" url="#cgi.script_name#?#querystring#&ftJoin=#request.ftJoin#&librarySection=Add" />

<ft:processForm action="*" excludeAction="Search" url="#cgi.script_name#?#querystring#&ftJoin=#request.ftJoin#" />


<admin:Header Title="Library" bodyclass="popup imagebrowse library" onload="setupPanes('container1','tab1');">



<cfset oPrimary = createObject("component",PrimaryPackagePath)>
<cfset oData = createObject("component",application.types[request.ftJoin].typepath)>

<cfset stPrimary = oPrimary.getData(objectid=url.primaryObjectID, bArraysAsStructs=true)>


<cfif URL.LibraryType EQ "array">
<!---	<cfset qArray = oPrimary.getArrayFieldAsQuery(objectid="#url.primaryObjectID#", Fieldname="#url.primaryFieldName#", Typename="#url.primaryTypeName#", ftJoin="#request.ftJoin#")> --->
	<cfquery datasource="#application.dsn#" name="q">
	SELECT * FROM #url.primaryTypeName#_#url.primaryFieldName#
	WHERE parentID = '#url.primaryObjectID#'
	</cfquery>
		
	<cfset lBasketIDs = valueList(q.data) />
<cfelse>
	<cfset lBasketIDs = stPrimary[url.primaryFieldName] />
</cfif>

<!-------------------------------------------------------------------------- 
LIBRARY DATA
	- generate library data query to populate library interface 
--------------------------------------------------------------------------->
<cfif isDefined("url.ftLibraryData") AND len(url.ftLibraryData)>	
	<!--- use ftlibrarydata method from primary content type --->
	<cfif structkeyexists(oprimary, url.ftLibraryData)>
		<cfinvoke component="#oPrimary#" method="#url.ftLibraryData#" returnvariable="qLibraryList" />
	</cfif>
</cfif>
<!--- if nothing exists to generate library data then cobble something together --->
<cfif NOT isDefined("qLibraryList")>
	<cfinvoke component="#oData#" method="getLibraryData" returnvariable="qLibraryList" />
	
</cfif>

<cfif listLen(lBasketIDs)>
	<cfquery dbtype="query" name="qLibraryList">
	SELECT * FROM qLibraryList
	WHERE ObjectID NOT IN (#ListQualify(lBasketIDs,"'")#)
	</cfquery>
</cfif>

<!--- Put JS and CSS for TabStyle1 into the header --->
<cfset Request.InHead.TabStyle1 = 1>


<cfoutput><h1 style="float:left;">#application.types[request.ftJoin].displayname# Library...</h1></cfoutput>


<cfif listLen(PrimaryPackage.stProps[url.primaryFieldname].metadata.ftJoin) GT 1>
	<ft:form>
	
	<cfoutput>
		Change To: 
		<select name="ftJoin" id="ftJoin" onchange="javascript:window.location='#cgi.script_name#?#querystring#&ftJoin=' + this[selectedIndex].value;"></cfoutput>
		<cfloop list="#PrimaryPackage.stProps[url.primaryFieldname].metadata.ftJoin#" index="i">
			<cfoutput><option value="#i#" <cfif url.ftJoin EQ i>selected</cfif>>#application.types[i].displayname#</option></cfoutput>
		</cfloop>
	<cfoutput></select></cfoutput>
	
	</ft:form>
</cfif>

<cfif structKeyExists(application.config.verity, "CONTENTTYPE") AND structKeyExists(application.config.verity.CONTENTTYPE,request.ftJoin)>
	
	<cfoutput><div style="float:right;"></cfoutput>


	<ft:processForm action="Search">
		<cfsearch collection="#application.applicationName#_#request.ftJoin#" criteria="#form.Criteria#" name="qResults" type="internet" />
		
		<cfif qResults.RecordCount>
			<cfquery dbtype="query" name="qLibraryList">
			SELECT objectid
			FROM qLibraryList
			WHERE objectid IN (#ListQualify(ValueList(qResults.key),"'")#)
			</cfquery>
		<cfelse>
			<cfoutput><h3>No Results matched search. All records have been returned</h3></cfoutput>
		</cfif>
		
	</ft:processForm>
	
	<ft:processForm action="Refresh">
		<cfset form.Criteria = "" />
	</ft:processForm>
	
	
	<cfparam name="form.Criteria" default="" />
	<ft:form>
		<cfoutput><input type="text" name="criteria" id="criteria" value="#form.Criteria#" /></cfoutput>
		<ft:farcrybutton value="Search" />
		<ft:farcrybutton value="Refresh" />
	</ft:form>
	<cfoutput></div></cfoutput>
	
</cfif>

<cfoutput><br style="clear:both;" /><br style="clear:both;" /></cfoutput>



	<!--- Create each of the the Linked Table Types as an object  --->
	<cfloop list="#PrimaryPackage.stProps[url.primaryFieldname].metadata.ftJoin#" index="i">		
		<cfset stJoinObjects[i] = createObject("component",application.types[i].typepath)>
	</cfloop>

	
	
	
	
	<!--- Add Form Tools Specific CSS --->
	<cfset Request.InHead.FormsCSS = 1>
	
	
	<cfset arguments.fieldname = "company" />
	
	<cfsavecontent variable="sPicker">
		<cfoutput>
		<div id="infoBox"></div>
		<table border="1" style="width:100%">
		<tr>
			<td style="width:50%">
				<h3>Selected <cfif URL.LibraryType EQ "UUID"><em>(only 1 permitted)</em></cfif></h3>
				
			<cfif URL.LibraryType EQ "array">
				<ul id="sortableListTo" class="arrayDetailView" style="background-color:##F1F1F1;height:500px;overflow-y:auto;overflow-x:hidden;">
			<cfelse>
				<div id="sortableListTo" style="background-color:##F1F1F1;height:500px;overflow-y:auto;overflow-x:hidden;">
			</cfif>	

		</cfoutput>	
			
					<cfif URL.LibraryType EQ "array">
						<cfloop from="1" to="#arrayLen(stPrimary[url.primaryFieldName])#" index="i">
							
							<cfset stCurrentArrayItem = stPrimary[url.primaryFieldName][i] />
							
							<cfset HTML = stJoinObjects[stCurrentArrayItem.typename].getView(objectid=stCurrentArrayItem.data, template="LibrarySelected", alternateHTML="") />
							<cfif NOT len(trim(HTML))>
								<cfset stTemp = stJoinObjects[stCurrentArrayItem.typename].getData(objectid=stCurrentArrayItem.data) />
								<cfif structKeyExists(stTemp, "label") AND len(stTemp.label)>
									<cfset HTML = stTemp.label />
								<cfelse>
									<cfset HTML = stTemp.objectid />
								</cfif>
							</cfif>		
							<!------------------------------------------------------------------------
							THE ID OF THE LIST ELEMENT MUST BE "FIELDNAME_OBJECTID" 
							BECAUSE THE JAVASCRIPT STRIPS THE "FIELDNAME_" TO DETERMINE THE OBJECTID
							 ------------------------------------------------------------------------->			
							<cfoutput>
							<li id="sortableListFrom_#stCurrentArrayItem.data#" class="sortableHandle">
								<div class="arrayDetail">
									<p>#HTML#</p>
								</div>								
							</li>
							</cfoutput>
						</cfloop>
					<cfelse>
						<cfif listLen(lBasketIDs)>
							<cfset HTML = oData.getView(objectid=stPrimary[url.primaryFieldName], template="LibrarySelected", alternateHTML="") />
							<cfif NOT len(trim(HTML))>
								<cfset stTemp = oData.getData(objectid=stPrimary[url.primaryFieldName]) />
								<cfif structKeyExists(stTemp, "label") AND len(stTemp.label)>
									<cfset HTML = stTemp.label />
								<cfelse>
									<cfset HTML = stTemp.objectid />
								</cfif>
							</cfif>		
							<!------------------------------------------------------------------------
							THE ID OF THE LIST ELEMENT MUST BE "FIELDNAME_OBJECTID" 
							BECAUSE THE JAVASCRIPT STRIPS THE "FIELDNAME_" TO DETERMINE THE OBJECTID
							 ------------------------------------------------------------------------->			
							<cfoutput>
							<p>#HTML#</p>
							</cfoutput>
						</cfif>
					</cfif>
				
			
			<cfoutput>
				
			<cfif URL.LibraryType EQ "array">
				</ul>
			<cfelse>
				</div>
			</cfif>
			
			</td>
			<td style="width:50%">
				<h3>Drag To Select</h3>
			</cfoutput>
			
				<ws:paginate PageLinksShown=5 RecordsPerPage=20 query="#qLibraryList#">		
			
			<cfoutput>
				<ul id="sortableListFrom" class="arrayDetailView" style="border:1px solid ##F1F1F1;height:500px;overflow-y:auto;overflow-x:hidden;">
			</cfoutput>
				
								
					
					<ws:paginateRecords r_stRecord="stObject">
						<cfif isDefined("stObject.label") AND len(stObject.label)>
							<cfset variables.alternateHTML = stObject.Label />
						<cfelse>
							<cfset variables.alternateHTML = stObject.ObjectID />
						</cfif>					
						<cfset HTML = oData.getView(objectid=stObject.ObjectID, template="LibrarySelected", alternateHTML=variables.alternateHTML) />
								
						<!------------------------------------------------------------------------
						THE ID OF THE LIST ELEMENT MUST BE "FIELDNAME_OBJECTID" 
						BECAUSE THE JAVASCRIPT STRIPS THE "FIELDNAME_" TO DETERMINE THE OBJECTID
						 ------------------------------------------------------------------------->			
						<cfoutput>
							<cfif URL.LibraryType EQ "array">
								<li id="sortableListFrom_#stObject.ObjectID#" class="sortableHandle">
							<cfelse>
								<li id="#stObject.ObjectID#" class="sortableHandle">
							</cfif>
								<div class="arrayDetail">
									<p>#HTML#</p>
								</div>								
							</li>
						</cfoutput>
					</ws:paginateRecords>
					
					
			<cfoutput>
				</ul>
			</cfoutput>
				

						
			<cfoutput><p></cfoutput>
				<ws:paginateScroll />
			<cfoutput></p></cfoutput>
			
				</ws:paginate>	
				
		<cfoutput>			
			</td>
		</tr>
		</table>
		</cfoutput>
		
		
		<cfset Request.InHead.ScriptaculousEffects = 1>
		<cfoutput>
		<script type="text/javascript">
		 // <![CDATA[
			Sortable.create("sortableListFrom",{
				dropOnEmpty:true,
				containment:["sortableListFrom","sortableListTo"],
				constraint:false
			});
			
			<cfif URL.LibraryType EQ "array">
				Sortable.create("sortableListTo",{
					dropOnEmpty:true,
					containment:["sortableListFrom","sortableListTo"],
					constraint:false,
					onUpdate:function(element) {
						
						opener.libraryCallback_#url.primaryFormFieldname#('sort',Sortable.sequence('sortableListTo'));
						new Effect.Highlight('sortableListTo',{startcolor:'##FFECD9',duration: 2});
				             				
					}
				});
				
				//call on initial page load
				opener.libraryCallback_#url.primaryFormFieldname#('sort',Sortable.sequence('sortableListTo'));
				
				
			<cfelse>
				Droppables.add('sortableListTo', {
				   onDrop: function(element) {
				   		$('sortableListTo').innerHTML = $(element).innerHTML;
				   		opener.libraryCallback_#url.primaryFormFieldname#('add',$(element).id);
						new Effect.Highlight('sortableListTo',{startcolor:'##FFECD9',duration: 2});
	
				   }
				});
				
				//call on initial page load
				opener.libraryCallback_#url.primaryFormFieldname#('sort',$(element).id);
			</cfif>
			

		     
	<!---		Droppables.add('sortableListTo', {
			accept:'sortableListFrom',
			hoverclass:'basket-active',
			onDrop:function(element) {
				alert('adding');
				//updateBasket('add',element);
			             				
			}
			}) --->
			
		 // ]]>
		 </script>
		</cfoutput>
	</cfsavecontent>
	
	
	
	
	
	
	
	
	
	
	
	
<!---<cfset RenderPickerHTML = RenderPicker() /> --->
<cfset RenderAddNewHTML = RenderAddNew() />



<cfoutput>
<div id="container1" class="tab-container">
	<ul class="tabs">
		<li id="tab1" onclick="return showPane('pane1', this)" class="tab-active">
			<a href="##pane1-ref">Attach</a>
		</li>
		<li id="tab2" onclick="return showPane('pane2', this)" class="tab-disabled">
			<a href="##pane2-ref">Add New</a>
		</li>
	</ul>
	
	<div class="tab-panes">
		<a name="pane1-ref" style="display: none;" ></a>
		<div id="pane1" style="display: block;">

			<!---#RenderPickerHTML# --->
			#sPicker#

		</div>
		<a name="pane2-ref" style="display: none;" ></a>
		<div id="pane2" style="display:none;">			

			#RenderAddNewHTML#
		
		</div>
	</div>
</div>
</cfoutput>

<cffunction name="RenderPicker" returntype="string" output="false">

		
	<cfsavecontent variable="sReturn">

	
	<ft:form style="width:100%;background:none;border:0px;">
		<cfoutput>
		<table style="width:100%;background:##fa0;">
		<tr>
			<td width="100px;" valign="top">
				<div id="utility">
					<h2 id="DragTitle">Drag here to add</h2> 
					
					<style type="text/css">
						.basket-active {background:##E17000;}
					</style>	
		</cfoutput>	
					
					<ft:object ObjectID="#url.primaryObjectID#" wizzardid="#url.WizzardID#" lFields="#url.primaryFieldName#" InTable=0 IncludeLabel=0 IncludeFieldSet=0 r_stFields="stBasketFields" packageType="#URL.packageType#" />
		
		<cfoutput>	
					<div id="basket" style="border:1px solid ##E17000;height:800px;">
						#stBasketFields[url.primaryFieldName].HTML#
					</div>	
					
												
				</div><!--- utility --->						
			</td>
			<td valign="top">
	
				<div id="content" style="margin-left:0px;" ></cfoutput>
					<!--- Render all the objects for the requested Type. --->
					<ws:paginate PageLinksShown=5 RecordsPerPage=20 query="#qLibraryList#">
						<cfoutput><div style="display:block;">	
							<div class="#url.ftLibraryPickListClass#" style="#url.ftLibraryPickListStyle#"></cfoutput>
							
								<cfset lRenderedObjects = "">
								<ws:paginateRecords r_stRecord="stObject">
									<cfset lRenderedObjects = ListAppend(lRenderedObjects,stObject.ObjectID) />
									
									<cfoutput><div id="select#stObject.objectID#" class="LibraryItem thumbNailItem" style="text-align:center;" objectID="#stObject.ObjectID#">
										<img src="#application.url.farcry#/images/dragbar.gif" id="handle#stObject.objectID#" style="cursor:move;" align="center"></cfoutput>
										
										<cfset stobj = oData.getData(objectid=stObject.ObjectID)>
										
										<cfif FileExists("#application.path.project#/webskin/#request.ftJoin#/#url.ftLibraryPickWebskin#.cfm")>
											<cfset oData.getDisplay(stObject=stobj, template="#url.ftLibraryPickWebskin#") />
											
											<!---<cfinclude template="/farcry/#application.applicationname#/webskin/#request.ftJoin#/#url.ftLibraryPickWebskin#.cfm"> --->
										<cfelse>
											<cfif isDefined("stobj.label") AND len(stobj.label)><cfoutput>#stobj.Label#</cfoutput><cfelse><cfoutput>#stobj.ObjectID#</cfoutput></cfif>
										</cfif>
	
									<cfoutput></div></cfoutput>
								</ws:paginateRecords>
							<cfoutput></div>
						</div>	
						
						<br style="clear:both;" />
						
						<div style="border:1px dashed ##CACACA;border-width:1px 0;"></cfoutput>
							<ws:paginateScroll />
							<cfoutput><br style="clear:both;" />
						</div></cfoutput>
					</ws:paginate>
				<cfoutput>
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
	</cfoutput>
		
			
		</ft:form>

	</cfsavecontent>
	<cfreturn sReturn >
</cffunction>

<cffunction name="RenderAddNew" returntype="string" output="false">
	<cfsavecontent variable="sReturn">
	
	<ft:form>
	
		<cfset stparam = structNew() />
		<cfset stparam.stPrimary = stPrimary />
		<cfset HTML = oData.getView(template="#url.ftLibraryAddNewWebskin#", alternateHTML="", stparam=stparam) />	
			
		<cfif len(HTML)>
			<cfoutput>#HTML#</cfoutput>
		<cfelse>
			<ft:object typename="#request.ftJoin#" lfields="" inTable=0 />
		</cfif>
		
		<cfoutput>
		<div>
			<ft:farcrybutton value="Attach" />	
			<ft:farcrybutton type="button" value="Close" onclick="self.blur();window.close();" />	
		</div>
		</cfoutput>
		
	</ft:form>
	
	</cfsavecontent>
	
	<cfreturn sReturn >
</cffunction>


<!---
<cfoutput>
		
		<cfset Request.InHead.ScriptaculousEffects = 1>
		
		<script type="text/javascript">
			
		<cfloop list="#lBasketIDs#" index="i">
			<cfif listFindNoCase(lRenderedObjects,i)>
				Effect.Fade($('select#i#'), {from:0.2,to:0.2});
			</cfif>
		</cfloop>
		
		<cfloop query="qLibraryList" startrow="#StartRow#" endrow="#EndRow#">
			new Draggable('select#qLibraryList.objectID#', {revert:true,handle:'handle#qLibraryList.objectID#'}) 
		</cfloop>
		
		
		
		function updateBasket(action,element){
			
			
			if(element){
				dataobjectid = encodeURIComponent($(element).getAttribute('objectid'));	
				var indicatorIcon = '<img alt="Indicator" src="/farcry/images/indicator.gif" /> Saving...';
				$('DragTitle').innerHTML = indicatorIcon;
			} else {
				dataobjectid = '';	
			}
			
			
			new Ajax.Request('/farcry/facade/library.cfc?method=ajaxUpdateArray', {
				parameters:'Action=' + action + '&LibraryType=#url.LibraryType#&primaryObjectID=#url.primaryObjectID#&primaryTypename=#url.primaryTypeName#&primaryFieldname=#url.primaryFieldname#&primaryFormFieldname=#url.primaryFormFieldname#&WizzardID=#url.WizzardID#&DataObjectID=' + dataobjectid + '&DataTypename=#request.ftJoin#&packageType=#url.PackageType#',
				asynchronous:true, 
				onSuccess:function(request){
					//$('basket').innerHTML = request.responseText;
					
					update_#url.primaryFormFieldname#_wrapper(request.responseText);	
					
					opener.update_#url.primaryFormFieldname#_wrapper(request.responseText);	
					//Effect.Pulsate($('#url.primaryFormFieldname#_' + $(element).getAttribute('objectid')), {duration:1});
					$('DragTitle').innerHTML = 'Drag here to add';
					update_#url.primaryFormFieldname#('sort',$('#url.primaryFormFieldname#'));
					
					if(element){
						Effect.Fade(element, {from:0.2,to:0.2});					
					
						// <![CDATA[
							  Sortable.create('#url.primaryFormFieldname#_list',
							  	{ghosting:false,hoverclass:'over',handle:'#url.primaryFormFieldname#_listhandle',constraint:'vertical',tag:'div',
							    onChange:function(element){$('#url.primaryFormFieldname#').value = Sortable.sequence('#url.primaryFormFieldname#_list')}
							    
							  })
							// ]]>
					} 
					
					
					
				
				}
			});
			
			
			<!--- new Ajax.Updater('#url.primaryFormFieldname#-wrapper', '/farcry/facade/library.cfc?method=ajaxUpdateArray', {
					onComplete:function(request){
						
						update_#url.primaryFormFieldname#_wrapper(request.responseText);	
						opener.update_#url.primaryFormFieldname#_wrapper(request.responseText);						
						Effect.Fade(element, {from:0.2,to:0.2});
						// <![CDATA[
							  Sortable.create('#url.primaryFormFieldname#_list',
							  	{ghosting:false,constraint:false,hoverclass:'over',handle:'#url.primaryFormFieldname#_listhandle',
							    onChange:function(element){$('#url.primaryFormFieldname#').value = Sortable.sequence('#url.primaryFormFieldname#_list')}
							    
							  })
							// ]]>	
													
					}, 
					parameters:'Action=' + action + '&LibraryType=#url.LibraryType#&primaryObjectID=#url.primaryObjectID#&primaryTypename=#url.primaryTypeName#&primaryFieldname=#url.primaryFieldname#&primaryFormFieldname=#url.primaryFormFieldname#&WizzardID=#url.WizzardID#&DataObjectID=' + encodeURIComponent($(element).getAttribute('objectid')) + '&DataTypename=#request.ftJoin#', evalScripts:true, asynchronous:true
				}) --->
		}
		
		Droppables.add('basket', {
			accept:'LibraryItem',
			hoverclass:'basket-active',
			onDrop:function(element) {
				
				//Effect.Opacity(element, {duration:2, from:0, to:.2}); 
				Effect.Fade(element, {duration:2,from:0,to:0.2});
				//$('#URL.primaryFieldName#').value = $(element).getAttribute('objectid');
                //$('basket').innerHTML = element.innerHTML;
                updateBasket('add',element);
                				
			}
		})
		
			
		updateBasket('refresh');

		//initTabNavigation('LibraryTab','current','tab-disabled');
		
		</script>
</cfoutput>	 --->

<admin:footer>


<cfsetting enablecfoutputonly="no">