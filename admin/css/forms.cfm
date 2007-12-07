<!--- allow output only from cfoutput tags --->
<cfsetting enablecfoutputonly="yes" />

	<!--- set content type of cfm to css to enable output to be parsed as css by all browsers --->
	<cfcontent type="text/css; charset=UTF-8">

	<!--- include layout css --->
	<cfinclude template="forms/layout.cfm"/>

	<!--- include webskin css --->
	<cfinclude template="forms/webskin.cfm"/>

	<!--- include formatting css --->
	<cfinclude template="forms/formatting.cfm"/>
	
	<!--- include farcryButton css --->
	<cfinclude template="forms/farcryButton.cfm"/>
	
	
	
	<!--- BELOW IS A STYLE SPECIFICALLY FOR THE extJS tree. --->
	<cfoutput>
	li.x-tree-node {background-image:none;}
	.x-tree-node img.categoryIconCls,  .x-tree-node-collapsed img.categoryIconCls, .x-tree-node-expanded img.categoryIconCls{
	    background-image:url(#application.url.webtop#/images/treeimages/customIcons/NavApproved.gif);
	}
	/*The following styles fix an IE bugs where some of the display is hidden*/
	ul {position:static;}
	.ext-ie ul.x-tree-node-ct{font-size:100%;line-height:100%;}
	</cfoutput>

<!--- end allow output only from cfoutput tags --->
<cfsetting enablecfoutputonly="no" />
