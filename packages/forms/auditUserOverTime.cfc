<cfcomponent displayname="Audit User Activity Over Time" hint="Provides information about user activity over time" extends="forms" output="false">
	<cfproperty name="typeevent" type="string" default="security.login" hint="The log type to filter by" ftSeq="1" ftFieldset="" ftLabel="Type" ftType="list" ftListDataTypename="farLog" ftListData="getTypeEventList" />
	<cfproperty name="period" type="string" default="day" hint="The period being examined (day|week)" ftSeq="2" ftFieldset="" ftLabel="Period" ftType="list" ftList="day:Days,week:Weeks" />
	<cfproperty name="noperiods" type="string" default="3" hint="Number of periods" ftSeq="3" ftFieldset="" ftLabel="Number of periods" ftType="list" ftList="1,2,3,4,5" />
	
</cfcomponent>