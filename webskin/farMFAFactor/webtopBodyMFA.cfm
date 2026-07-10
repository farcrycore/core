<cfsetting enablecfoutputonly="true" />
<!--- @@displayname: Multi-factor enrolment --->
<!--- @@description: Webtop admin list of users with an enrolled second factor - a standard objectadmin over farMFAFactor (search, sort, pagination). Permission-gated on SecurityManagement (see docs/0014). --->

<cfimport taglib="/farcry/core/tags/formtools" prefix="ft" />
<cfimport taglib="/farcry/core/tags/webskin" prefix="skin" />

<cfif not application.security.checkPermission(permission="SecurityManagement")>
	<skin:view typename="farCOAPI" webskin="webtopBodyNotFound" />
	<cfexit method="exittemplate">
</cfif>

<cfparam name="url.id" default="" />

<!--- clicking a user opens the reset confirmation in a modal and refreshes the list on close --->
<skin:onReady id="mfa-reset-modal">
	<cfoutput>
	$j(document).on("click", ".mfa-reset-link", function(e){
		e.preventDefault();
		$fc.objectAdminAction("Reset multi-factor", "#application.url.webtop#/index.cfm?id=#url.id#&typename=farUser&objectid=" + encodeURIComponent($j(this).data("userkey")) + "&view=webtopPageModal&bodyView=editMFAReset");
	});
	</cfoutput>
</skin:onReady>

<!--- User column resolves the name and links to the per-user reset; recovery-code rows are excluded so the list reads one row per enrolled user --->
<cfset aCustomColumns = arraynew(1) />
<cfset aCustomColumns[1] = structnew() />
<cfset aCustomColumns[1].title = "User" />
<cfset aCustomColumns[1].property = "userLabel" />
<cfset aCustomColumns[1].sortable = true />
<cfset aCustomColumns[1].webskin = "displayCellMFAUser" />

<ft:objectadmin typename="farMFAFactor"
	title="Multi-factor enrolment"
	columnList="userDirectory,factorType,lastUsed"
	aCustomColumns="#aCustomColumns#"
	sqlWhere="status = 'active' AND factorType <> 'recoveryCodes'"
	sqlorderby="userLabel asc"
	sortableColumns="factorType,lastUsed"
	lFilterFields="userLabel"
	bSelectCol="false"
	bCheckAll="false"
	bEditCol="false"
	bViewCol="false"
	bFlowCol="false"
	bPreviewCol="false"
	bShowActionList="false"
	lButtons=""
	lButtonsEmpty=""
	numitems="50" />

<cfsetting enablecfoutputonly="false" />
