<!--- 
|| LEGAL ||
$Copyright: Daemon Pty Limited 1995-2003, http://www.daemon.com.au $
$License: Released Under the "Common Public License 1.0", http://www.opensource.org/licenses/cpl.php$ 

|| VERSION CONTROL ||
$Header: /cvs/farcry/farcry_core/ui/admin/Attic/fixtree.cfm,v 1.1 2003/04/09 07:55:12 spike Exp $
$Author: spike $
$Date: 2003/04/09 07:55:12 $
$Name: b131 $
$Revision: 1.1 $

|| DESCRIPTION || 
$Description: tree fixer. The commented out stuff is debug$
$TODO: make this work for mysql and oracle $

|| DEVELOPER ||
$Developer: Daniel Morphett (daniel@daemon.com.au)$

|| ATTRIBUTES ||
$in: $
$out:$
--->
<cfsetting enablecfoutputonly="Yes" requesttimeout="600">

<!--- set up page header --->
<cfimport taglib="/farcry/farcry_core/tags/admin/" prefix="admin">
<admin:header>
	
<cfif IsDefined("form.typename")><!--- process the form --->
    <cfparam name="form.debug" default="0"><!--- if they ask for debug, this is overwritten--->
    
    <cfset temptablename = "####DoneIDs">
    <cfif IsDefined("form.datasource") and len(form.datasource)>
        <cfset ds ="#form.datasource#">
    <cfelse>
    	<cfabort showerror="can't do it without a datasource">	
    </cfif>

    <!--- make a temp table to add the vals to ---> 
    <cfquery name="qExists" datasource="#ds#">
    	select * from tempdb..sysobjects where type = 'u' and name = '#temptablename#'
    </cfquery> 
    <cfif qExists.recordcount gt 0>
        <cfquery name="q"  datasource="#ds#">
        	drop table #temptablename#
        </cfquery>
    </cfif>   
    <cfquery name="q" datasource="#ds#">    
        create table #temptablename# (objectName char(50), objectID char(35), parentID char(35), nleft int, nright int, nlevel int)
    </cfquery>		
    
	<!--- make sure the levels are good. to do this we need to make sure the root is level zero, 
			then each object has a level one greater than its parent. --->
	<cfquery name="qFixRootParentID" datasource="#ds#" >
    	update nested_tree_objects
    	set parentid = null
		WHERE typename = '#form.typename#'
		and parentid = ''
    </cfquery>
	<cfquery name="qFixRootLevel" datasource="#ds#" >
    	update nested_tree_objects
    	set nlevel = 0 
		WHERE typename = '#form.typename#'
		and parentid is null 
    </cfquery>
	<cfquery name="qFixOtherLevels" datasource="#ds#" >
    	update nested_tree_objects
    	set nlevel = isnull((
			select nlevel + 1 
			from nested_tree_objects nt 
			where typename = '#form.typename#' 
			and nt.objectid = nested_tree_objects.parentid
		),2) -- make arbitrary nlevel, but not one too deep(a deep one will slow down the fix tree)
		WHERE typename = '#form.typename#'
		and parentid is not null	
    </cfquery>
		
		
    <cfif isNumeric(form.maxlevel)>
        <cfset qLevels.maxlvl = form.maxlevel>
    <cfelse>
		<cfquery name="qLevels" datasource="#ds#" >
        	SELECT max(nlevel) as maxlvl
        	FROM nested_tree_objects
        	WHERE typename = '#form.typename#'
        </cfquery>
    </cfif>    
    
    <cfloop from="0" to="#qLevels.maxlvl#" index="nlevel"><!--- for each level... --->
        <!--- get the objectids --->
        <cfquery name="qGetObjects" datasource="#ds#" >
        	SELECT objectID, parentID, objectname
        	FROM nested_tree_objects
        	WHERE typename = '#form.typename#'
            and nlevel = #nlevel#
			order by nleft
        </cfquery>
        
        <cfloop query="qGetObjects"><!--- for each object... --->
            
            <cf_CalculateLeftAndRightVals 
                datasource="#ds#" 
                objectID="#objectID#"
                parentID="#parentID#"
                typename="#form.typename#"
                debug="#form.debug#"
                temptablename="#temptablename#"
                r_nleft="nleft"
                r_nright="nright"
                >
                
            <cfquery name="qInsertVals" datasource="#ds#" > <!--- insert the vals in the temp table --->  
            	insert into #temptablename# 
                values ('#left(objectName, 50)#', '#objectID#', '#parentID#', #nleft#, #nright#, #nlevel#)
            </cfquery> 
            
        </cfloop>
    
    </cfloop>
    <cfif form.debug eq 1>
		<!--- show debug only, don't fix tree --->
		<cfoutput>
		<div class="formtitle">Debug Complete</div>
        This is how the table would look if you ran this function without debug turned on:<p></cfoutput>
        <cfquery name="qDisplayIndentedTree" datasource="#ds#">
        	SELECT objectname as a_objectname, objectid as b_objectID, parentid as c_parentid, 
            nleft as d_nleft, nright as e_nright, nlevel as f_nlevel
        	FROM #temptablename#
        	order by nleft
        </cfquery>
        <cfdump var="#qDisplayIndentedTree#" label="Nested Tree for #form.typename#"> 
    <cfelse>                
    	<!--- update the real table --->       
		<cfquery name="qUpdateVals" datasource="#ds#" >
        	delete from nested_tree_objects            
            where objectid in (select objectid from #temptablename#)          
        </cfquery> 
		<cfquery name="qUpdateVals" datasource="#ds#" >
        	insert into nested_tree_objects            
            select objectid, parentid, objectname, '#form.typename#' as typename, nleft, nright, nlevel  
			from #temptablename#    
        </cfquery> 
        <cfoutput>
		<div class="formtitle">Tree fixed</div>
		The nested tree table has been updated for the typename #form.typename#.</cfoutput>
    </cfif>
<cfelse><!--- show the form --->
    <cfoutput>
        <div class="formtitle">Fix a nested tree</div>
        Use this function if your nested tree ever gets confused about where its branches are supposed to live.
        It puts them all back together again, rebuilding the tree from the roots up. 
		You may want to make a backup of your database before fixing the tree. 
		Please be patient, this process can take a few minutes!<p></p>
		
        <form action="fixtree.cfm" method="post">
            Enter a typename to fix the tree of:<br>
            <input type="text" name="typename" value="dmNavigation"><p>
            <!--- And the name of the datasource:<br>
            <input type="text" name="datasource" value="#application.dsn#"><br> --->
			<input type="hidden" name="datasource" value="#application.dsn#">
            And the number of levels to go down the tree (leave empty for all):<br>
            <input type="text" name="maxlevel"><br>
            <input type="checkbox" name="debug" value="1" checked>show debug only (don't fix the table)<p>
            <input type="submit" name="submit" value="submit">
        </form>
    </cfoutput>
</cfif>

<admin:footer>

<cfsetting enablecfoutputonly="No">