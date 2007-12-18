<!--- import fourQ tag library --->
<cfimport taglib="/farcry/core/packages/fourq/tags/" prefix="q4">

<cfscript>
// create default home page
stHTML = structNew();
stHTML.aObjectIDs = arrayNew(1);
stHTML.aRelatedIDs = arrayNew(1);
stHTML.aTeaserImageIDs = arrayNew(1);
stHTML.body = '<P>Built from the ground up on the revolutionary ColdFusion MX server platform, <strong>farcry</strong> is the affordable, powerful site management solution that is quick to implement, and intuitive to use.</P><P><strong>farcry</strong> offers the advanced features of high-end site-management solutions, including sophisticated container management, publishing rules, version control and integrated search, at a small fraction of the cost.</P>';
stHTML.commentLog = '';
stHTML.createdBy = 'farcry';
stHTML.datetimeCreated = now();
stHTML.datetimeLastUpdated = now();
stHTML.displayMethod = 'displayPageTypeA';
stHTML.label = 'farcry - open source';
stHTML.lastUpdatedBy = 'farcry';
stHTML.metaKeywords = '';
stHTML.objectID = createUUID();
stHTML.status = 'approved';
stHTML.teaser = 'Built from the ground up on the revolutionary ColdFusion MX server platform, <strong>farcry</strong> is the affordable, powerful site management solution that is quick to implement, and intuitive to use.';
stHTML.title = 'farcry - open source';
stHTML.typeName = 'dmHTML';
stHTML.versionID = '';
stHTML.extendedmetadata = '';
// bowden 7/23/2006. Added. taken from b300.cfm
stHTML.reviewdate = createODBCDate(CreateDate(2050,month(Now()),day(Now())));
// end of add
// create 2nd level page
stHTML2 = structNew();
stHTML2.aObjectIDs = arrayNew(1);
stHTML2.aRelatedIDs = arrayNew(1);
stHTML2.aTeaserImageIDs = arrayNew(1);
stHTML2.body = '<p>FarCry has an ever helpful, active and growing developer community.  Daemon provides a variety of community services including mailing lists for developers and users alike.</p>      <p>Each mailing list is available via email (obviously), a web based interface and NNTP (a newsgroup or USENET interface). Instructions for leaving every list are clearly given in the footer of every post.  DIGEST and other options are available.  Please refer to the web based interface for a full list of configuration options. Visitors are allowed, but you must join the list to post.</p>  <h3>farcry-dev (public)</h3>   <p>farcry-dev@googlegroups.com<br /> Aimed at managing support for FarCry open source developers.  Anyone making enquiries about modifying or extending or deploying the code base should be referred to this list.</p>      <ul>   <li>To join the mailing list, go to: <a href="http://groups.google.com/group/farcry-dev/about">http://groups.google.com/group/farcry-dev/about</a></li>     <li>Old web based archive: <a href="http://www.mail-archive.com/farcry-dev@lists.daemon.com.au/">http://www.mail-archive.com/farcry-dev@lists.daemon.com.au/</a></li>   <li>Web based interface: <a href="http://www.nabble.com/FarCry-f621.html">http://www.nabble.com/FarCry-f621.html</a><br /> </li> </ul>  <h3>farcry-user (public)</h3>   <p>farcry-user@googlegroups.com <br />  Aimed at managing support for FarCry open source users.  Anyone making enquiries about adding, editing or managing content should be referred to this list. </p>      <ul>   <li>To join the mailing list, go to: <span style="text-decoration: underline"><a href="http://groups.google.com/group/farcry-user/about">http://groups.google.com/group/farcry-user/about</a></span></li> <li>Web based interface: <a href="http://www.nabble.com/FarCry-f621.html">http://www.nabble.com/FarCry-f621.html</a></li> </ul>  <h3>farcry-beta (public)</h3>   <p>farcry-beta@googlegroups.com <br />  The beta list is focused at providing a discussion environment and ad hoc support forum for developers getting to grips with and developing changes for the next generation of FarCry CMS. </p>      <ul>   <li>To join the mailing list, go to: <a href="http://groups.google.com/group/farcry-beta/about">http://groups.google.com/group/farcry-beta/about</a></li> </ul>  <h3>farcry-de (public)</h3>  <p>farcry-de@googlegroups.com<br />farcry-de ist die deutschsprachige Mailingliste zu Problemen/L&ouml;sungen mit dem ColdFusion CMS Farcry. To join the mailing list, go to: </p>   <ul>  <li><a href="http://groups.google.com/group/farcry-de/about">http://groups.google.com/group/farcry-de/about</a></li> </ul>
<h1>More information</h1><p>Check out <a href="http://www.farcrycms.org/">http://www.farcrycms.org/</a> for more information.</p>';
stHTML2.commentLog = '';
stHTML2.createdBy = 'farcry';
stHTML2.datetimeCreated = now();
stHTML2.datetimeLastUpdated = now();
stHTML2.displayMethod = 'displayPageTypeB';
stHTML2.label = 'FarCry Support';
stHTML2.lastUpdatedBy = 'farcry';
stHTML2.metaKeywords = '';
stHTML2.objectID = createUUID();
stHTML2.status = 'approved';
stHTML2.teaser = 'An example page';
stHTML2.title = 'FarCry Support';
stHTML2.typeName = 'dmHTML';
stHTML2.versionID = '';
stHTML2.extendedmetadata = '';
// bowden 7/23/2006. Added. taken from b300.cfm
stHTML2.reviewdate = createODBCDate(CreateDate(2050,month(Now()),day(Now())));
// end of add

stCSS = structNew();
stCSS.createdBy = 'farcry';
stCSS.datetimeCreated = now();
stCSS.datetimeLastUpdated = now();
stCSS.description = 'Default stylesheet for farCry content management system.';
stCSS.fileName = 'main.css';
stCSS.label = 'Default Styles';
stCSS.lastUpdatedBy = 'farcry';
stCSS.objectID = createUUID();
stCSS.title = 'Default Styles';
stCSS.typeName = 'dmCSS';

stSearch = structNew();
stSearch.commentLog = '';
stSearch.createdBy = 'farcry';
stSearch.datetimeCreated = now();
stSearch.datetimeLastUpdated = now();
stSearch.displayMethod = 'displayDefault';
stSearch.include = '_search.cfm';
stSearch.label = 'Search';
stSearch.lastUpdatedBy = 'farcry';
stSearch.objectID = createUUID();
stSearch.status = 'approved';
stSearch.teaser = '';
stSearch.title = 'Search';
stSearch.typeName = 'dmInclude';

//create default HTML page & CCS styles 
oType = createobject("component","#application.packagepath#.types.#stHTML.typeName#");
oType.createData(stProperties=stHTML,user='farcry');
oType.createData(stProperties=stHTML2,user='farcry');
oType = createobject("component","#application.packagepath#.types.#stCSS.typeName#");
oType.createData(stProperties=stCSS,user='farcry');
oType = createobject("component","#application.packagepath#.types.#stSearch.typeName#");
oType.createData(stProperties=stSearch,user='farcry');

// create root nav node
o_dmNav = createObject("component", "#application.packagepath#.types.dmNavigation");
o_farcrytree = createObject("component", "#application.packagepath#.farcry.tree");

// define default navigation nodes
stRootNode = structNew();
stRootNode.objectID = createUUID();
stRootNode.aObjectIDs = arrayNew(1);
stRootNode.aObjectIDs[1] = stCSS.objectID;
stRootNode.status = 'approved';
stRootNode.ExternalLink = '';
stRootNode.target = '';
stRootNode.options = '';
stRootNode.lNavIDAlias = 'root';
stRootNode.title = 'Root';
stRootNode.createdBy = 'farcry';
stRootNode.label = 'Root';
stRootNode.datetimecreated = now();
stRootNode.datetimelastupdated = now();
stRootNode.lastupdatedby = 'farcry';

stHomeNode = structNew();
stHomeNode.objectID = createUUID();
stHomeNode.aObjectIDs = arrayNew(1);
stHomeNode.aObjectIDs[1] = stHTML.objectID;
stHomeNode.status = 'approved';
stHomeNode.ExternalLink = '';
stHomeNode.target = '';
stHomeNode.options = '';
stHomeNode.lNavIDAlias = 'home';
stHomeNode.title = 'Home';
stHomeNode.createdBy = 'farcry';
stHomeNode.label = 'Home';
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
stHomeNode2.title = 'Support';
stHomeNode2.createdBy = 'farcry';
stHomeNode2.label = 'Support';
stHomeNode2.datetimecreated = now();
stHomeNode2.datetimelastupdated = now();
stHomeNode2.lastupdatedby = 'farcry';

stUtilNode = structNew();
stUtilNode.objectID = createUUID();
stUtilNode.status = 'approved';
stUtilNode.ExternalLink = '';
stUtilNode.target = '';
stUtilnode.options = '';
stUtilNode.lNavIDAlias = 'hidden';
stUtilNode.title = 'Utility';
stUtilNode.createdBy = 'farcry';
stUtilNode.label = 'Utility';
stUtilNode.datetimecreated = now();
stUtilNode.datetimelastupdated = now();
stUtilNode.lastupdatedby = 'farcry';

stSearchNode = structNew();
stSearchNode.objectID = createUUID();
stSearchNode.aObjectIDs = arrayNew(1);
stSearchNode.aObjectIDs[1] = stSearch.objectID;
stSearchNode.status = 'approved';
stSearchNode.ExternalLink = '';
stSearchNode.target = '';
stSearchNode.options = '';
stSearchNode.lNavIDAlias = 'search';
stSearchNode.title = 'Search';
stSearchNode.createdBy = 'farcry';
stSearchNode.label = 'Search';
stSearchNode.datetimecreated = now();
stSearchNode.datetimelastupdated = now();
stSearchNode.lastupdatedby = 'farcry';

stFooterNode = structNew();
stFooterNode.objectID = createUUID();
stFooterNode.status = 'approved';
stFooterNode.ExternalLink = '';
stFooterNode.target = '';
stFooterNode.options = '';
stFooterNode.lNavIDAlias = 'footer';
stFooterNode.title = 'Footer';
stFooterNode.createdBy = 'farcry';
stFooterNode.label = 'Footer';
stFooterNode.datetimecreated = now();
stFooterNode.datetimelastupdated = now();
stFooterNode.lastupdatedby = 'farcry';

stImageNode = structNew();
stImageNode.objectID = createUUID();
stImageNode.status = 'approved';
stImageNode.ExternalLink = '';
stImageNode.target = '';
stImageNode.options = '';
stImageNode.lNavIDAlias = 'imageroot';
stImageNode.title = 'Images';
stImageNode.createdBy = 'farcry';
stImageNode.label = 'Images';
stImageNode.datetimecreated = now();
stImageNode.datetimelastupdated = now();
stImageNode.lastupdatedby = 'farcry';

stFileNode = structNew();
stFileNode.objectID = createUUID();
stFileNode.status = 'approved';
stFileNode.ExternalLink = '';
stFileNode.target = '';
stFileNode.options = '';
stFileNode.lNavIDAlias = 'fileroot';
stFileNode.title = 'Files';
stFileNode.createdBy = 'farcry';
stFileNode.label = 'Files';
stFileNode.datetimecreated = now();
stFileNode.datetimelastupdated = now();
stFileNode.lastupdatedby = 'farcry';

stTrashNode = structNew();
stTrashNode.objectID = createUUID();
stTrashNode.status = 'approved';
stTrashNode.ExternalLink = '';
stTrashNode.target = '';
stTrashNode.options = '';
stTrashNode.lNavIDAlias = 'rubbish';
stTrashNode.title = 'Trash';
stTrashNode.createdBy = 'farcry';
stTrashNode.label = 'Trash';
stTrashNode.datetimecreated = now();
stTrashNode.datetimelastupdated = now();
stTrashNode.lastupdatedby = 'farcry';

// create nodes
o_dmNav.createData(dsn=application.dsn,stProperties=stRootNode,bAudit=false,user='farcry');
o_dmNav.createData(dsn=application.dsn,stProperties=stHomeNode,bAudit=false,user='farcry');
o_dmNav.createData(dsn=application.dsn,stProperties=stHomeNode2,bAudit=false,user='farcry');
o_dmNav.createData(dsn=application.dsn,stProperties=stUtilNode,bAudit=false,user='farcry');
o_dmNav.createData(dsn=application.dsn,stProperties=stSearchNode,bAudit=false,user='farcry');
o_dmNav.createData(dsn=application.dsn,stProperties=stFooterNode,baudit=false,user='farcry');
o_dmNav.createData(dsn=application.dsn,stProperties=stImageNode,bAudit=false,user='farcry');
o_dmNav.createData(dsn=application.dsn,stProperties=stFileNode,bAudit=false,user='farcry');
o_dmNav.createData(dsn=application.dsn,stProperties=stTrashNode,bAudit=false,user='farcry');

// attach created nodes
o_farCryTree.setRootNode(dsn=application.dsn,objectID=stRootNode.objectID,objectName='Root',typeName='dmNavigation');
o_farCryTree.setYoungest(dsn=application.dsn,parentID=stRootNode.objectID,objectID=stHomeNode.objectID,objectName=stHomeNode.title,typeName='dmNavigation');
o_farCryTree.setYoungest(dsn=application.dsn,parentID=stHomeNode.objectID,objectID=stHomeNode2.objectID,objectName=stHomeNode2.title,typeName='dmNavigation');
o_farCryTree.setYoungest(dsn=application.dsn,parentID=stRootNode.objectID,objectID=stUtilNode.objectID,objectName=stUtilNode.title,typeName='dmNavigation');
o_farCryTree.setYoungest(dsn=application.dsn,parentID=stUtilNode.objectID,objectID=stSearchNode.objectID,objectName=stSearchNode.title,typeName='dmNavigation');
o_farCryTree.setYoungest(dsn=application.dsn,parentID=stUtilNode.objectID,objectID=stFooterNode.objectID,objectName=stFooterNode.title,typeName='dmNavigation');
o_farCryTree.setYoungest(dsn=application.dsn,parentID=stRootNode.objectID,objectID=stImageNode.objectID,objectName=stImageNode.title,typeName='dmNavigation');
o_farCryTree.setYoungest(dsn=application.dsn,parentID=stRootNode.objectID,objectID=stFileNode.objectID,objectName=stFileNode.title,typeName='dmNavigation');
o_farCryTree.setYoungest(dsn=application.dsn,parentID=stRootNode.objectID,objectID=stTrashNode.objectID,objectName=stTrashNode.title,typeName='dmNavigation');

// update nav alias
application.navid = o_dmNav.getNavAlias();
</cfscript>