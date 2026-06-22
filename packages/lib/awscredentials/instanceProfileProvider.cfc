<cfcomponent displayname="AWS Credentials: EC2 instance profile" hint="Fetches EC2 instance-profile credentials via IMDSv2 (token-required metadata service at 169.254.169.254). Used for plain EC2; on ECS the container endpoint is preferred and tried first." output="false" persistent="false">

	<cfset this.id = "instanceProfile" />

	<cffunction name="init" returntype="any" output="false">
		<cfargument name="resolver" type="any" required="true" />
		<cfargument name="engine" type="string" required="false" default="unknown" />
		<cfset this.resolver = arguments.resolver />
		<cfset this.engine = arguments.engine />
		<cfset this.imdsToken = "" />
		<cfset this.imdsTokenExpires = "" />
		<cfreturn this />
	</cffunction>

	<cffunction name="canResolve" returntype="boolean" output="false">
		<cfargument name="definition" type="struct" required="true" />

		<cfset var token = "" />

		<cftry>
			<cfset token = getToken() />
			<cfcatch><cfreturn false /></cfcatch>
		</cftry>
		<cfreturn len(token) gt 0 />
	</cffunction>

	<cffunction name="resolve" returntype="struct" output="false">
		<cfargument name="definition" type="struct" required="true" />

		<cfset var token = getToken() />
		<cfset var roleResp = "" />
		<cfset var roleName = "" />
		<cfset var credResp = "" />
		<cfset var data = "" />
		<cfset var exp = "" />

		<!--- discover the instance-profile role name --->
		<cfhttp method="GET" url="http://169.254.169.254/latest/meta-data/iam/security-credentials/" result="roleResp" timeout="2" charset="utf-8">
			<cfhttpparam type="header" name="X-aws-ec2-metadata-token" value="#token#" />
		</cfhttp>
		<cfif listfirst(roleResp.statuscode," ") neq "200" or not len(trim(roleResp.fileContent))>
			<cfset application.fapi.throw(message="IMDS returned no instance-profile role ([{1}])",type="awscredentialserror",substituteValues=[ roleResp.statuscode ]) />
		</cfif>
		<cfset roleName = trim(listfirst(roleResp.fileContent, chr(10))) />

		<!--- fetch the role's temporary credentials --->
		<cfhttp method="GET" url="http://169.254.169.254/latest/meta-data/iam/security-credentials/#roleName#" result="credResp" timeout="2" charset="utf-8">
			<cfhttpparam type="header" name="X-aws-ec2-metadata-token" value="#token#" />
		</cfhttp>
		<cfif listfirst(credResp.statuscode," ") neq "200" or not isJSON(credResp.fileContent)>
			<cfset application.fapi.throw(message="IMDS credential request failed ([{1}]) for role [{2}]",type="awscredentialserror",substituteValues=[ credResp.statuscode, roleName ]) />
		</cfif>

		<cfset data = deserializeJSON(credResp.fileContent) />
		<cfif not (structkeyexists(data,"Code") and data.Code eq "Success")>
			<cfset application.fapi.throw(message="IMDS credential response was not Success for role [{1}]",type="awscredentialserror",substituteValues=[ roleName ]) />
		</cfif>

		<cfset exp = structkeyexists(data,"Expiration") ? this.resolver.parseAWSExpiration(data.Expiration) : "" />
		<!--- Instance-profile credentials are always time-limited; if IMDS omits or returns an
		      unparseable Expiration, fall back to a short TTL so the cache refreshes soon. --->
		<cfif not isDate(exp)>
			<cfset exp = dateAdd("n", 15, now()) />
		</cfif>

		<cfreturn {
			"accessKeyId" = data.AccessKeyId,
			"secretAccessKey" = data.SecretAccessKey,
			"sessionToken" = data.Token,
			"expiration" = exp,
			"source" = this.id
		} />
	</cffunction>

	<cffunction name="getToken" returntype="string" output="false" access="private" hint="Returns a cached IMDSv2 session token, fetching a new one (PUT) when missing or near expiry.">
		<cfset var tokResp = "" />

		<cfif len(this.imdsToken) and isDate(this.imdsTokenExpires) and dateCompare(now(), this.imdsTokenExpires) lt 0>
			<cfreturn this.imdsToken />
		</cfif>

		<cfhttp method="PUT" url="http://169.254.169.254/latest/api/token" result="tokResp" timeout="2" charset="utf-8">
			<cfhttpparam type="header" name="X-aws-ec2-metadata-token-ttl-seconds" value="21600" />
		</cfhttp>
		<cfif listfirst(tokResp.statuscode," ") neq "200" or not len(trim(tokResp.fileContent))>
			<cfset application.fapi.throw(message="IMDSv2 token request failed ({1})",type="awscredentialserror",substituteValues=[ tokResp.statuscode ]) />
		</cfif>

		<cfset this.imdsToken = trim(tokResp.fileContent) />
		<!--- renew a little before the 6h TTL --->
		<cfset this.imdsTokenExpires = dateAdd("s", 21000, now()) />
		<cfreturn this.imdsToken />
	</cffunction>

</cfcomponent>
