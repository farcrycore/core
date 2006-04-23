<!--- import fourQ tag library --->
<cfimport taglib="/farcry/fourq/tags/" prefix="q4">

<cfscript>
// create default home page
stHTML = structNew();
stHTML.aObjectIDs = arrayNew(1);
stHTML.aRelatedIDs = arrayNew(1);
stHTML.aTeaserImageIDs = arrayNew(1);
stHTML.body = '<p>blah blah blah</p>';
stHTML.commentLog = '';
stHTML.createdBy = 'farcry';
stHTML.datetimeCreated = now();
stHTML.datetimeLastUpdated = now();
stHTML.displayMethod = 'displaypageLanding';
stHTML.label = 'Tree 1';
stHTML.lastUpdatedBy = 'farcry';
stHTML.metaKeywords = '';
stHTML.objectID = createUUID();
stHTML.status = 'approved';
stHTML.teaser = '<p>Teaser teaser teaser</p>';
stHTML.title = 'Tree 1';
stHTML.typeName = 'dmHTML';
stHTML.versionID = '';

// create 2nd level page
stHTML2 = structNew();
stHTML2.aObjectIDs = arrayNew(1);
stHTML2.aRelatedIDs = arrayNew(1);
stHTML2.aTeaserImageIDs = arrayNew(1);
stHTML2.body = '<p>blah blah blah</p>';
stHTML2.commentLog = '';
stHTML2.createdBy = 'farcry';
stHTML2.datetimeCreated = now();
stHTML2.datetimeLastUpdated = now();
stHTML2.displayMethod = 'displaypageLanding';
stHTML2.label = 'Tree 2';
stHTML2.lastUpdatedBy = 'farcry';
stHTML2.metaKeywords = '';
stHTML2.objectID = createUUID();
stHTML2.status = 'approved';
stHTML2.teaser = '<p>Teaser teaser teaser</p>';
stHTML2.title = 'Tree 2';
stHTML2.typeName = 'dmHTML';
stHTML2.versionID = '';

// create 2nd level page
stHTML21 = structNew();
stHTML21.aObjectIDs = arrayNew(1);
stHTML21.aRelatedIDs = arrayNew(1);
stHTML21.aTeaserImageIDs = arrayNew(1);
stHTML21.body = '<p>blah blah blah</p>';
stHTML21.commentLog = '';
stHTML21.createdBy = 'farcry';
stHTML21.datetimeCreated = now();
stHTML21.datetimeLastUpdated = now();
stHTML21.displayMethod = 'displaypageLanding';
stHTML21.label = 'Tree 2_1';
stHTML21.lastUpdatedBy = 'farcry';
stHTML21.metaKeywords = '';
stHTML21.objectID = createUUID();
stHTML21.status = 'approved';
stHTML21.teaser = '<p>Teaser teaser teaser</p>';
stHTML21.title = 'Tree 2_1';
stHTML21.typeName = 'dmHTML';
stHTML21.versionID = '';

stHTML3 = structNew();
stHTML3.aObjectIDs = arrayNew(1);
stHTML3.aRelatedIDs = arrayNew(1);
stHTML3.aTeaserImageIDs = arrayNew(1);
stHTML3.body = '<p>blah blah blah</p>';
stHTML3.commentLog = '';
stHTML3.createdBy = 'farcry';
stHTML3.datetimeCreated = now();
stHTML3.datetimeLastUpdated = now();
stHTML3.displayMethod = 'displaypageLanding';
stHTML3.label = 'Tree 3';
stHTML3.lastUpdatedBy = 'farcry';
stHTML3.metaKeywords = '';
stHTML3.objectID = createUUID();
stHTML3.status = 'approved';
stHTML3.teaser = '<p>Teaser teaser teaser</p>';
stHTML3.title = 'Tree 3';
stHTML3.typeName = 'dmHTML';
stHTML3.versionID = '';
stHTML3.extendedmetadata = '';

stHTML31 = structNew();
stHTML31.aObjectIDs = arrayNew(1);
stHTML31.aRelatedIDs = arrayNew(1);
stHTML31.aTeaserImageIDs = arrayNew(1);
stHTML31.body = '<p>blah blah blah</p>';
stHTML31.commentLog = '';
stHTML31.createdBy = 'farcry';
stHTML31.datetimeCreated = now();
stHTML31.datetimeLastUpdated = now();
stHTML31.displayMethod = 'displaypageLanding';
stHTML31.label = 'Tree 3_1';
stHTML31.lastUpdatedBy = 'farcry';
stHTML31.metaKeywords = '';
stHTML31.objectID = createUUID();
stHTML31.status = 'approved';
stHTML31.teaser = '<p>Teaser teaser teaser</p>';
stHTML31.title = 'Tree 3_1';
stHTML31.typeName = 'dmHTML';
stHTML31.versionID = '';
stHTML31.extendedmetadata = '';

stHTML32 = structNew();
stHTML32.aObjectIDs = arrayNew(1);
stHTML32.aRelatedIDs = arrayNew(1);
stHTML32.aTeaserImageIDs = arrayNew(1);
stHTML32.body = '<p>blah blah blah</p>';
stHTML32.commentLog = '';
stHTML32.createdBy = 'farcry';
stHTML32.datetimeCreated = now();
stHTML32.datetimeLastUpdated = now();
stHTML32.displayMethod = 'displaypageLanding';
stHTML32.label = 'Tree 3_2';
stHTML32.lastUpdatedBy = 'farcry';
stHTML32.metaKeywords = '';
stHTML32.objectID = createUUID();
stHTML32.status = 'approved';
stHTML32.teaser = '<p>Teaser teaser teaser</p>';
stHTML32.title = 'Tree 3_2';
stHTML32.typeName = 'dmHTML';
stHTML32.versionID = '';
stHTML32.extendedmetadata = '';

stHTML321 = structNew();
stHTML321.aObjectIDs = arrayNew(1);
stHTML321.aRelatedIDs = arrayNew(1);
stHTML321.aTeaserImageIDs = arrayNew(1);
stHTML321.body = '<p>blah blah blah</p>';
stHTML321.commentLog = '';
stHTML321.createdBy = 'farcry';
stHTML321.datetimeCreated = now();
stHTML321.datetimeLastUpdated = now();
stHTML321.displayMethod = 'displaypageLanding';
stHTML321.label = 'Tree 3_2_1';
stHTML321.lastUpdatedBy = 'farcry';
stHTML321.metaKeywords = '';
stHTML321.objectID = createUUID();
stHTML321.status = 'approved';
stHTML321.teaser = '<p>Teaser teaser teaser</p>';
stHTML321.title = 'Tree 3_2_1';
stHTML321.typeName = 'dmHTML';
stHTML321.versionID = '';
stHTML321.extendedmetadata = '';

stHTML322 = structNew();
stHTML322.aObjectIDs = arrayNew(1);
stHTML322.aRelatedIDs = arrayNew(1);
stHTML322.aTeaserImageIDs = arrayNew(1);
stHTML322.body = '<p>blah blah blah</p>';
stHTML322.commentLog = '';
stHTML322.createdBy = 'farcry';
stHTML322.datetimeCreated = now();
stHTML322.datetimeLastUpdated = now();
stHTML322.displayMethod = 'displaypageLanding';
stHTML322.label = 'Tree 3_2_2';
stHTML322.lastUpdatedBy = 'farcry';
stHTML322.metaKeywords = '';
stHTML322.objectID = createUUID();
stHTML322.status = 'approved';
stHTML322.teaser = '<p>Teaser teaser teaser</p>';
stHTML322.title = 'Tree 3_2_2';
stHTML322.typeName = 'dmHTML';
stHTML322.versionID = '';
stHTML322.extendedmetadata = '';
</cfscript>

<!--- create default HTML page & CCS styles --->
<q4:contentobjectcreate typename="#application.packagepath#.types.#stHTML.typeName#" stProperties="#stHTML#" bAudit="false">
<q4:contentobjectcreate typename="#application.packagepath#.types.#stHTML2.typeName#" stProperties="#stHTML2#" bAudit="false">
<q4:contentobjectcreate typename="#application.packagepath#.types.#stHTML2.typeName#" stProperties="#stHTML21#" bAudit="false">
<q4:contentobjectcreate typename="#application.packagepath#.types.#stHTML2.typeName#" stProperties="#stHTML3#" bAudit="false">
<q4:contentobjectcreate typename="#application.packagepath#.types.#stHTML2.typeName#" stProperties="#stHTML31#" bAudit="false">
<q4:contentobjectcreate typename="#application.packagepath#.types.#stHTML2.typeName#" stProperties="#stHTML32#" bAudit="false">
<q4:contentobjectcreate typename="#application.packagepath#.types.#stHTML2.typeName#" stProperties="#stHTML321#" bAudit="false">
<q4:contentobjectcreate typename="#application.packagepath#.types.#stHTML2.typeName#" stProperties="#stHTML322#" bAudit="false">


<cfscript>
// get root nav node
o_dmNav = createObject("component", "#application.packagepath#.types.dmNavigation");
o_farcrytree = createObject("component", "#application.packagepath#.farcry.tree");

// define default navigation nodes

stHomeNode = structNew();
stHomeNode.objectID = createUUID();
stHomeNode.aObjectIDs = arrayNew(1);
stHomeNode.aObjectIDs[1] = stHTML.objectID;
stHomeNode.status = 'approved';
stHomeNode.ExternalLink = '';
stHomeNode.target = '';
stHomeNode.options = '';
stHomeNode.lNavIDAlias = '';
stHomeNode.title = 'Tree 1';
stHomeNode.createdBy = 'farcry';
stHomeNode.label = 'Tree 1';
stHomeNode.datetimecreated = now();
stHomeNode.datetimelastupdated = now();
stHomeNode.lastupdatedby = 'farcry';

stHomeNode2 = structNew();
stHomeNode2.objectID = createUUID();
stHomeNode2.aObjectIDs = arrayNew(1);
stHomeNode2.aObjectIDs[1] = stHTML2.objectID;
stHomeNode2.status = 'approved';
stHomeNode2.ExternalLink = '';
stHomeNode2.target = '';
stHomeNode2.options = '';
stHomeNode2.lNavIDAlias = '';
stHomeNode2.title = 'Tree 2';
stHomeNode2.createdBy = 'farcry';
stHomeNode2.label = 'Tree 2';
stHomeNode2.datetimecreated = now();
stHomeNode2.datetimelastupdated = now();
stHomeNode2.lastupdatedby = 'farcry';

stHomeNode21 = structNew();
stHomeNode21.objectID = createUUID();
stHomeNode21.aObjectIDs = arrayNew(1);
stHomeNode21.aObjectIDs[1] = stHTML21.objectID;
stHomeNode21.status = 'approved';
stHomeNode21.ExternalLink = '';
stHomeNode21.target = '';
stHomeNode21.options = '';
stHomeNode21.lNavIDAlias = '';
stHomeNode21.title = 'Tree 2_1';
stHomeNode21.createdBy = 'farcry';
stHomeNode21.label = 'Tree 2_1';
stHomeNode21.datetimecreated = now();
stHomeNode21.datetimelastupdated = now();
stHomeNode21.lastupdatedby = 'farcry';

stHomeNode3 = structNew();
stHomeNode3.objectID = createUUID();
stHomeNode3.aObjectIDs = arrayNew(1);
stHomeNode3.aObjectIDs[1] = stHTML3.objectID;
stHomeNode3.status = 'approved';
stHomeNode3.ExternalLink = '';
stHomeNode3.target = '';
stHomeNode3.options = '';
stHomeNode3.lNavIDAlias = '';
stHomeNode3.title = 'Tree 3';
stHomeNode3.createdBy = 'farcry';
stHomeNode3.label = 'Tree 3';
stHomeNode3.datetimecreated = now();
stHomeNode3.datetimelastupdated = now();
stHomeNode3.lastupdatedby = 'farcry';

stHomeNode31 = structNew();
stHomeNode31.objectID = createUUID();
stHomeNode31.aObjectIDs = arrayNew(1);
stHomeNode31.aObjectIDs[1] = stHTML31.objectID;
stHomeNode31.status = 'approved';
stHomeNode31.ExternalLink = '';
stHomeNode31.target = '';
stHomeNode31.options = '';
stHomeNode31.lNavIDAlias = '';
stHomeNode31.title = 'Tree 3_1';
stHomeNode31.createdBy = 'farcry';
stHomeNode31.label = 'Tree 3_1';
stHomeNode31.datetimecreated = now();
stHomeNode31.datetimelastupdated = now();
stHomeNode31.lastupdatedby = 'farcry';

stHomeNode32 = structNew();
stHomeNode32.objectID = createUUID();
stHomeNode32.aObjectIDs = arrayNew(1);
stHomeNode32.aObjectIDs[1] = stHTML32.objectID;
stHomeNode32.status = 'approved';
stHomeNode32.ExternalLink = '';
stHomeNode32.target = '';
stHomeNode32.options = '';
stHomeNode32.lNavIDAlias = '';
stHomeNode32.title = 'Tree 3_2';
stHomeNode32.createdBy = 'farcry';
stHomeNode32.label = 'Tree 3_2';
stHomeNode32.datetimecreated = now();
stHomeNode32.datetimelastupdated = now();
stHomeNode32.lastupdatedby = 'farcry';

stHomeNode321 = structNew();
stHomeNode321.objectID = createUUID();
stHomeNode321.aObjectIDs = arrayNew(1);
stHomeNode321.aObjectIDs[1] = stHTML321.objectID;
stHomeNode321.status = 'approved';
stHomeNode321.ExternalLink = '';
stHomeNode321.target = '';
stHomeNode321.options = '';
stHomeNode321.lNavIDAlias = '';
stHomeNode321.title = 'Tree 3_2_1';
stHomeNode321.createdBy = 'farcry';
stHomeNode321.label = 'Tree 3_2_1';
stHomeNode321.datetimecreated = now();
stHomeNode321.datetimelastupdated = now();
stHomeNode321.lastupdatedby = 'farcry';

stHomeNode322 = structNew();
stHomeNode322.objectID = createUUID();
stHomeNode322.aObjectIDs = arrayNew(1);
stHomeNode322.aObjectIDs[1] = stHTML322.objectID;
stHomeNode322.status = 'approved';
stHomeNode322.ExternalLink = '';
stHomeNode322.target = '';
stHomeNode322.options = '';
stHomeNode322.lNavIDAlias = '';
stHomeNode322.title = 'Tree 3_2_2';
stHomeNode322.createdBy = 'farcry';
stHomeNode322.label = 'Tree 3_2_2';
stHomeNode322.datetimecreated = now();
stHomeNode322.datetimelastupdated = now();
stHomeNode322.lastupdatedby = 'farcry';

// create nodes
o_dmNav.createData(dsn=application.dsn,stProperties=stHomeNode,bAudit=false);
o_dmNav.createData(dsn=application.dsn,stProperties=stHomeNode2,bAudit=false);
o_dmNav.createData(dsn=application.dsn,stProperties=stHomeNode21,bAudit=false);
o_dmNav.createData(dsn=application.dsn,stProperties=stHomeNode3,bAudit=false);
o_dmNav.createData(dsn=application.dsn,stProperties=stHomeNode31,bAudit=false);
o_dmNav.createData(dsn=application.dsn,stProperties=stHomeNode32,bAudit=false);
o_dmNav.createData(dsn=application.dsn,stProperties=stHomeNode321,bAudit=false);
o_dmNav.createData(dsn=application.dsn,stProperties=stHomeNode322,bAudit=false);

// attach created nodes
o_farCryTree.setYoungest(dsn=application.dsn,parentID=application.navid.home,objectID=stHomeNode.objectID,objectName=stHomeNode.title,typeName='dmNavigation');
o_farCryTree.setYoungest(dsn=application.dsn,parentID=application.navid.home,objectID=stHomeNode2.objectID,objectName=stHomeNode2.title,typeName='dmNavigation');
o_farCryTree.setYoungest(dsn=application.dsn,parentID=stHomeNode2.objectID,objectID=stHomeNode21.objectID,objectName=stHomeNode21.title,typeName='dmNavigation');
o_farCryTree.setYoungest(dsn=application.dsn,parentID=application.navid.home,objectID=stHomeNode3.objectID,objectName=stHomeNode3.title,typeName='dmNavigation');
o_farCryTree.setYoungest(dsn=application.dsn,parentID=stHomeNode3.objectID,objectID=stHomeNode31.objectID,objectName=stHomeNode31.title,typeName='dmNavigation');
o_farCryTree.setYoungest(dsn=application.dsn,parentID=stHomeNode3.objectID,objectID=stHomeNode32.objectID,objectName=stHomeNode32.title,typeName='dmNavigation');
o_farCryTree.setYoungest(dsn=application.dsn,parentID=stHomeNode32.objectID,objectID=stHomeNode321.objectID,objectName=stHomeNode321.title,typeName='dmNavigation');
o_farCryTree.setYoungest(dsn=application.dsn,parentID=stHomeNode32.objectID,objectID=stHomeNode322.objectID,objectName=stHomeNode322.title,typeName='dmNavigation');
</cfscript>