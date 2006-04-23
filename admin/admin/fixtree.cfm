<!---
|| LEGAL ||
$Copyright: Daemon Pty Limited 1995-2003, http://www.daemon.com.au $
$License: Released Under the "Common Public License 1.0", http://www.opensource.org/licenses/cpl.php$

|| VERSION CONTROL ||
$Header: /cvs/farcry/farcry_core/admin/admin/fixtree.cfm,v 1.17 2003/11/28 02:33:34 paul Exp $
$Author: paul $
$Date: 2003/11/28 02:33:34 $
$Name: milestone_2-1-2 $
$Revision: 1.17 $

|| DESCRIPTION ||
$Description: tree fixer. The commented out stuff is debug$
$TODO:$

|| DEVELOPER ||
$Developer: Quentin Zervaas (quentin@mitousa.com) $

|| ATTRIBUTES ||
$in: $
$out:$
--->
<cfsetting enablecfoutputonly="Yes" requesttimeout="600">

<!--- check permissions --->
<cfscript>
	iCOAPITab = request.dmSec.oAuthorisation.checkPermission(reference="policyGroup",permissionName="AdminCOAPITab");
</cfscript>

<!--- set up page header --->
<cfimport taglib="/farcry/farcry_core/tags/admin/" prefix="admin">
<admin:header>

<cfif iCOAPITab eq 1>

	<cfset dsn = "#application.dsn#" />
	
	<cfif IsDefined("form.typename")><!--- process the form --->
	    <cfparam name="form.debug" default="0"><!--- if they ask for debug, this is overwritten--->
	
	    <cfset dbtype = "#application.dbtype#" />
	
	    <!--- setup temporary table stuff --->
	    <cfswitch expression="#application.dbtype#">
	        <cfcase value="mysql">
	            <cfset temptablename = "tbltemp_fixtree" />
	            <cfquery datasource="#dsn#" name="q">
	                drop table if exists #temptablename#
	            </cfquery>
	            <cfquery datasource="#dsn#" name="q">
	                create temporary table #temptablename# (
	                    objectName char(50),
	                    objectID   char(35),
	                    parentID   char(35),
	                    nleft      int,
	                    nright     int,
	                    nlevel     int
	                )
	            </cfquery>
	        </cfcase>
			
			<cfcase value="ora">
	        	<cfset temptablename = "tbltemp_fixtree" />
				
				<cftry>
		           	<cfquery name="qDelete" datasource="#dsn#">
		              delete from #temptablename#
		            </cfquery>
					<cfcatch></cfcatch>
	            </cftry>
				
				<cftry>
		            <cfquery datasource="#dsn#" name="q">
		                create global temporary table #temptablename# (
		                    objectName varchar2(50),
		                    objectID   varchar2(35),
		                    parentID   varchar2(35),
		                    nleft      int,
		                    nright     int,
		                    nlevel     int
		                )
						on commit preserve rows
		            </cfquery>
					<cfcatch></cfcatch>
				</cftry>
	        </cfcase>
	
	        <cfdefaultcase>
	            <cfset temptablename = "####DoneIDs" />
	
	            <cfquery name="qExists" datasource="#dsn#">
	                select * from tempdb..sysobjects where type = 'u' and name = '#temptablename#'
	            </cfquery>
	            <cfif qExists.recordcount gt 0>
	                <cfquery name="q"  datasource="#dsn#">
	                    drop table #temptablename#
	                </cfquery>
	            </cfif>
	            <cfquery name="q" datasource="#dsn#">
	                create table #temptablename# (
	                    objectName char(50),
	                    objectID   char(35),
	                    parentID   char(35),
	                    nleft      int,
	                    nright     int,
	                    nlevel     int
	                )
	            </cfquery>
	        </cfdefaultcase>
	    </cfswitch>
		
		<cffunction name="fixValuesWithParent">
		    <cfargument name="parentid" type="uuid" required="yes" />
		    <cfargument name="newlevel" type="numeric" required="yes" />
		
		    <cfquery name="qGetChildren_#newlevel#" datasource="#dsn#">
		        select objectID, parentID, objectName from nested_tree_objects where parentid = '#parentid#'
		    </cfquery>
		
		    <cfloop query="qGetChildren_#newlevel#">
		        <cfset nval = nval + 1 />
		        <cfquery name="qFixNode" datasource="#dsn#">
		            insert into #temptablename#
		            values ('#left(objectName, 50)#', '#objectID#', '#parentID#', #nval#, 0, #newlevel#)
		        </cfquery>
		        <cfset fixValuesWithParent(objectid, newlevel + 1) />
		        <cfset nval = nval + 1 />
		        <cfquery name="qFixNode" datasource="#dsn#">
		            update #temptablename# set nright = #nval# where objectid = '#objectid#'
		        </cfquery>
		    </cfloop>
		</cffunction>
	
	    <!---
	      make sure the levels are good. to do this we need to make sure the root
	      is level zero, then each object has a level one greater than its parent.
	      --->
	    <cfquery name="qFixRootParentID" datasource="#dsn#">
	        update nested_tree_objects
	        set parentid = null
	        where typename = '#form.typename#'
	        and parentid = ''
	    </cfquery>
	    <cfquery name="qFixRootLevel" datasource="#dsn#" >
	        update nested_tree_objects
	        set nlevel = 0
	        WHERE typename = '#form.typename#'
	        and parentid is null
	    </cfquery>
	
	    <cfswitch expression="#application.dbtype#">
	        <cfcase value="mysql">
	
	            <cfset nval = 0>
	            <cfquery name="qGetRoots" datasource="#dsn#">
	                select objectID, parentID, objectName from nested_tree_objects where parentid is null and typename = "#form.typename#"
	            </cfquery>
	            <cfloop query="qGetRoots">
	                <cfset nval = nval + 1 />
	                <cfquery name="qFixNode" datasource="#dsn#">
	                    insert into #temptablename#
	                    values ('#left(objectName, 50)#', '#objectID#', '#parentID#', #nval#, 0, 0)
	                </cfquery>
	                <cfset fixValuesWithParent(objectid, 1) />
	                <cfset nval = nval + 1 />
	                <cfquery name="qFixNode" datasource="#dsn#">
	                    update #temptablename# set nright = #nval# where objectid = '#objectid#'
	                </cfquery>
	            </cfloop>
	
	        </cfcase>
			
			 <cfcase value="ora">
	
	            <cfset nval = 0>
	            <cfquery name="qGetRoots" datasource="#dsn#">
	                select objectID, parentID, objectName from nested_tree_objects where parentid is null and typename = '#form.typename#'
	            </cfquery>
	            <cfloop query="qGetRoots">
	                <cfset nval = nval + 1 />
	                <cfquery name="qFixNode" datasource="#dsn#">
	                    insert into #temptablename#
	                    values ('#left(objectName, 50)#', '#objectID#', '#parentID#', #nval#, 0, 0)
	                </cfquery>
	                <cfset fixValuesWithParent(objectid, 1) />
	                <cfset nval = nval + 1 />
	                <cfquery name="qFixNode" datasource="#dsn#">
	                    update #temptablename# set nright = #nval# where objectid = '#objectid#'
	                </cfquery>
	            </cfloop>
	
	        </cfcase>
	
	        <cfdefaultcase>
	            <cfset nval = 0>
	            <cfquery name="qGetRoots" datasource="#dsn#">
	                select objectID, parentID, objectName from nested_tree_objects where parentid is null and typename = '#form.typename#'
	            </cfquery>
	            <cfloop query="qGetRoots">
	                <cfset nval = nval + 1 />
	                <cfquery name="qFixNode" datasource="#dsn#">
	                    insert into #temptablename#
	                    values ('#left(objectName, 50)#', '#objectID#', '#parentID#', #nval#, 0, 0)
	                </cfquery>
	                <cfset fixValuesWithParent(objectid, 1) />
	                <cfset nval = nval + 1 />
	                <cfquery name="qFixNode" datasource="#dsn#">
	                    update #temptablename# set nright = #nval# where objectid = '#objectid#'
	                </cfquery>
	            </cfloop>
	        </cfdefaultcase>
	    </cfswitch>
	
	    <cfif form.debug eq 1>
	        <!--- show debug only, don't fix tree --->
	        <cfoutput>
	        <div class="formtitle">Debug Complete</div>
	        This is how the table would look if you ran this function without debug turned on:<p></cfoutput>
	        <cfquery name="qDisplayIndentedTree" datasource="#dsn#">
	            SELECT objectname as a_objectname, objectid as b_objectID, parentid as c_parentid,
	            nleft as d_nleft, nright as e_nright, nlevel as f_nlevel
	            FROM #temptablename#
	            order by nleft
	        </cfquery>
	        <cfdump var="#qDisplayIndentedTree#" label="Nested Tree for #form.typename#">
	    <cfelse>
	        <!--- update the real table --->
	        <cfswitch expression="#application.dbtype#">
	            <cfcase value="mysql">
	                <!---
	                  workaround for lack of subselect in mysql. would be better
	                  to it the defaultcase way - just in case for any reason an
	                  object didn't make it into the temp table (not sure why this
	                  would happen though)
	                  --->
	                <cfquery name="qUpdateVals" datasource="#dsn#" >
	                    delete from nested_tree_objects where typename = '#form.typename#'
	                </cfquery>
	            </cfcase>
	
	            <cfdefaultcase>
					<cfquery name="q" datasource="#dsn#">
						select objectid from #temptablename#
					</cfquery>
					<cfloop query="q">
						<cfquery name="qUpdateVals" datasource="#dsn#" >
	                    delete from nested_tree_objects
	                    where objectid = '#q.objectid#'
	                </cfquery>
					</cfloop>
				<!---  
					This was barfing on sql 2000 with a tree of over 700 nodes.
					 <cfquery name="qUpdateVals" datasource="#dsn#" >
	                    delete from nested_tree_objects
	                    where objectid in (select objectid from #temptablename#)
	                </cfquery> --->
	            </cfdefaultcase>
	        </cfswitch>
	        <cfquery name="qUpdateVals" datasource="#dsn#" >
	            insert into nested_tree_objects
	            select objectid, parentid, objectname, '#form.typename#' as typename, nleft, nright, nlevel
	            from #temptablename#
	        </cfquery>
	        <cfoutput>
	        <div class="formtitle">Tree fixed</div>
	        The nested tree table has been updated for the typename <strong>#form.typename#</strong>.</cfoutput>
	    </cfif>
	
	<cfelse><!--- show the form --->
		
		<!--- get types that use nested tree --->
	    <cfquery name="qTypeNames" datasource="#dsn#">
	        select distinct typename from nested_tree_objects order by typename
	    </cfquery>
		
	    <cfif qTypeNames.recordCount eq 0>
	        <cfoutput>
	            No items were found in your nested tree. This is bad.
	        </cfoutput>
	    <cfelse>
			<!--- show form --->
	        <cfset defaultType = 'dmNavigation' />
	        <cfoutput>
	            <div class="formtitle">Fix a nested tree</div>
	            <p>
	                Use this function if your nested tree ever gets confused about where its branches are supposed to live.
	                It puts them all back together again, rebuilding the tree from the roots up.
	                You may want to make a backup of your database before fixing the tree.
	                Please be patient, this process can take a few minutes!
	            </p>
	            <form action="fixtree.cfm" method="post">
	                Enter a typename to fix the tree of:
	                <select name="typename">
	                    <cfloop query="qTypeNames">
	                        <option value="#qTypeNames.typename#" <cfif qTypeNames.typename eq defaultType>selected</cfif>>#qTypeNames.typename#</option>
	                    </cfloop>
	                </select>
	                <br /><br />
	                <input type="checkbox" name="debug" value="1" checked>show debug only (don't fix the table)<br />
	                <br />
	                <input type="submit" name="submit" value="submit">
	            </form>
	
	        </cfoutput>
	    </cfif>
	</cfif>

<cfelse>
	<admin:permissionError>
</cfif>

<admin:footer>

<cfsetting enablecfoutputonly="No">