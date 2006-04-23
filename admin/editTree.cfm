<!--- <link href="../css/default.css" rel="stylesheet">
<link href="../css/overviewFrame.css" rel="stylesheet"> --->

<cfparam name="URL.type" default="dmHTML">
<cfset typename = "dmNavigation">

<cfoutput>
	<a href="objectbrowser.cfm?type=#URL.type#">Back to objectbrowser</a>
</cfoutput>
	
<cfif isDefined("FORM.submit")>
	<cfswitch expression="#FORM.submit#">
		
		<cfcase value="Move Node">
			<!--- Parent ID must be selected --->
			<cfif NOT isDefined("FORM.parentID")>  
				 No parentID selected - click <a href="<cfoutput>#CGI.HTTP_referer#</cfoutput>">here</a> to return
			<cfelse>
				 <!--- Move the branch --->
				 <cfinvoke component="fourq.utils.tree.tree" method="moveBranch" parentID="#form.ParentID#" objectID="#form.objectID#" returnvariable="stReturn">
				 
				 <cfdump var="#stReturn#" label="Move result">			  
			</cfif>
		</cfcase>
		
		<cfcase value="Insert Node">
			<cfscript>
				insertRoot = form.insertRoot; //are we gonna be inserting a root node?
				userMsg = ""; //build any error messages for the user
				if (len(trim(form.objectName)) EQ 0)
					userMsg = "Must enter a tree label name";
				if (NOT isDefined("FORM.parentID"))
					userMsg = userMsg & "<br> No Parent ID selected";
				if (NOT len(trim(userMsg)) EQ 0)
					error = true;
				else
					error = false;	
			</cfscript>
			<!--- If there has been an error - don't invoke any of the 4q methods  --->
			<cfif error>
				<cfoutput>
					<i style="color:red">#userMsg#</i> click <a href="<cfoutput>#CGI.HTTP_referer#</cfoutput>">here</a> to	go back
				</cfoutput>
			<cfelse>
				<!--- if root - set root - else just position the node in the tree using setChild() --->
				<cfif insertRoot>
				 	<cfinvoke component="fourq.utils.tree.tree"	 method="setRootNode" objectName = "#form.objectName#" typename = "#typename#" objectID="#form.objectID#" returnvariable="stReturn">
				<cfelse>
					<cfinvoke component="fourq.utils.tree.tree" method="setChild" objectName = "#form.objectName#"	 typename = "#typename#" parentID="#form.ParentID#"	 objectID="#form.objectID#"	 pos = "1" returnvariable="stReturn">
				</cfif>	 
			
				<cfdump var="#stReturn#" label="Result of node insertion">	
			</cfif>	
		</cfcase>
		
		<cfcase value="Delete Node">
            <!--- call deleteBranch() to rid the tree of this node			 --->
			<cfinvoke component="fourq.utils.tree.tree" method="deleteBranch" objectID="#form.objectID#" returnvariable="stReturn">
		 	<cfdump var="#stReturn#" label="Result of branch deletion">
		</cfcase>

		<cfcase value="cancel">
			<h3>Operation was cancelled</h3>
		</cfcase>
		<cfdefaultcase>
			<cfoutput>
				No action specified for form value "#form.submit#"
			</cfoutput>
		</cfdefaultcase>
		
	</cfswitch>

<cfelse>

	  <cfinvoke component="fourq.utils.tree.tree" method="displayIndentedTree" 	typename="#typename#" returnvariable="qReturn">		 
	  
	  <cfquery name="qGetThisNode" datasource="#application.fourq.dsn#">
		SELECT objectID, objectname
	    FROM nested_tree_objects
	    where objectID = '#URL.oID#'
	 </cfquery> 
	
	 <cfquery name="qGetTree" datasource="#application.fourq.dsn#">
	    SELECT objectID,space(nLevel*2) + objectname as objectname, nleft, nright, nlevel
	    FROM nested_tree_objects
	    where nleft is not null
	    and typename = '#typename#'
	    order by nleft
	 </cfquery>
	 
	 
	 
	 <!--- Inititalise variables --->
	 <cfscript>
		 insertRoot = false; //Do we need to insert the root node?
		 insert = false; //If an object is not in the tree - flag to insert it
		 submitValue = "Move Node"; //value of the submit button below
		 //if there are no entries in nested_tree_objects - better insert the root node
		 if (qReturn.recordCount EQ 0)
		  	insertRoot = true;
		 //if this object is not in nested_tree_objects - we will want to insert it	
		 if (NOT qGetThisNode.recordcount GT 0)
		 {
			objectName = '';
			insert = true;
			submitValue = "Insert Node";
		 }	
		 else
			objectName = trim(qGetThisNode.objectname);
	 </cfscript>
	
	
	<cfform name="treeForm" action="#CGI.script_name#?#CGI.query_string#" method="POST">
	<table>
		<tr>
			<td>
				Tree label
			</td>
			<td>
				<cfoutput><input type="Text" name="objectName" value="#objectName#"></cfoutput>
			</td>
		</tr>
		<tr>
			<td>
				Select object parent
			</td>
			<td>
				<cfif insertRoot>
					<input type="Hidden" name="parentID" value="0">
					<b>THIS NODE INSERTION WILL BE THE NEW ROOT</b>
				<cfelse>
					<select name="ParentID" size="<cfoutput>#qGetTree.recordCount#</cfoutput>">
					<cfoutput query="qGetTree">
						<cfset count = (nlevel * 2)>
						<option value="#objectID#">#repeatString(". ",count)# #qGetTree.objectName#
					</cfoutput>
					</select>				
				</cfif>
			</td>	
		</tr>
		<tr>
			<td valign="top">
				Action
			</td>
			<td colspan="1" align="left">
				<cfoutput>
					<input type="Hidden" name="objectID" value="#URL.oID#">
					<input type="Hidden" name="insertRoot" value="#insertRoot#">
					<input type="Submit" value="Cancel" name="submit">
					<cfif NOT insert>
						<input type="Submit" value="Delete Node" name="submit">
					</cfif>
					<input type="Submit" value="#submitValue#" name="submit">
					
					
				</cfoutput>
			</td>
		</tr>
	</table>
		
	</cfform>
	<cfdump var="#qGetTree#">
</cfif>

