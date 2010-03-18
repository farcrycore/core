<cfcomponent displayname="Sitemap configuration" hint="Configuration for site maps" extends="forms" output="false" key="image">
	<cfproperty name="domainName" type="string" default="" hint=""
		ftSeq="2" ftFieldset="General Details" 
		ftLabel="Domain name" ftvalidation="required" 
		ftType=""/>
		
		<cfproperty name="newsPublication" type="string" default="" hint=""
		ftSeq="2" ftFieldset="General Details" 
		ftLabel="News Publication" ftType="String" ftHint="If you are including news in the sitemap"/>
		
		<cfproperty name="sitemapRoot" type="string" default="" hint=""
			ftSeq="2" ftFieldset="General Details" 
			ftLabel="Sitemap root alias" ftType="String" ftHint="The navigation alias for the site map to start generating from"/>
</cfcomponent>