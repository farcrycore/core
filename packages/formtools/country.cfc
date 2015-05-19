<cfcomponent name="country" displayname="country" hint="Field containing a country" extends="field"> 
	
	<cffunction name="init" access="public" returntype="any" output="false" hint="Returns a copy of this initialised object">
		<cfset var q = querynew("code,name") />
		
		<cfset queryaddrow(q) /><cfset querysetcell(q,"code","AC") /><cfset querysetcell(q,"name","Ascension Island") />
		<cfset queryaddrow(q) /><cfset querysetcell(q,"code","AF") /><cfset querysetcell(q,"name","Afghanistan") />
		<cfset queryaddrow(q) /><cfset querysetcell(q,"code","AL") /><cfset querysetcell(q,"name","Albania") />
		<cfset queryaddrow(q) /><cfset querysetcell(q,"code","DZ") /><cfset querysetcell(q,"name","Algeria") />
		<cfset queryaddrow(q) /><cfset querysetcell(q,"code","AS") /><cfset querysetcell(q,"name","American Samoa") />
		<cfset queryaddrow(q) /><cfset querysetcell(q,"code","AD") /><cfset querysetcell(q,"name","Andorra") />
		<cfset queryaddrow(q) /><cfset querysetcell(q,"code","AO") /><cfset querysetcell(q,"name","Angola") />
		<cfset queryaddrow(q) /><cfset querysetcell(q,"code","AI") /><cfset querysetcell(q,"name","Anguilla") />
		<cfset queryaddrow(q) /><cfset querysetcell(q,"code","AQ") /><cfset querysetcell(q,"name","Antarctica") />
		<cfset queryaddrow(q) /><cfset querysetcell(q,"code","AG") /><cfset querysetcell(q,"name","Antigua and Barbuda") />
		<cfset queryaddrow(q) /><cfset querysetcell(q,"code","AR") /><cfset querysetcell(q,"name","Argentina") />
		<cfset queryaddrow(q) /><cfset querysetcell(q,"code","AM") /><cfset querysetcell(q,"name","Armenia") />
		<cfset queryaddrow(q) /><cfset querysetcell(q,"code","AW") /><cfset querysetcell(q,"name","Aruba") />
		<cfset queryaddrow(q) /><cfset querysetcell(q,"code","AU") /><cfset querysetcell(q,"name","Australia") />
		<cfset queryaddrow(q) /><cfset querysetcell(q,"code","AT") /><cfset querysetcell(q,"name","Austria") />
		<cfset queryaddrow(q) /><cfset querysetcell(q,"code","AZ") /><cfset querysetcell(q,"name","Azerbaijan") />
		<cfset queryaddrow(q) /><cfset querysetcell(q,"code","BS") /><cfset querysetcell(q,"name","Bahamas") />
		<cfset queryaddrow(q) /><cfset querysetcell(q,"code","BH") /><cfset querysetcell(q,"name","Bahrain") />
		<cfset queryaddrow(q) /><cfset querysetcell(q,"code","BD") /><cfset querysetcell(q,"name","Bangladesh") />
		<cfset queryaddrow(q) /><cfset querysetcell(q,"code","BB") /><cfset querysetcell(q,"name","Barbados") />
		<cfset queryaddrow(q) /><cfset querysetcell(q,"code","BY") /><cfset querysetcell(q,"name","Belarus") />
		<cfset queryaddrow(q) /><cfset querysetcell(q,"code","BE") /><cfset querysetcell(q,"name","Belgium") />
		<cfset queryaddrow(q) /><cfset querysetcell(q,"code","BZ") /><cfset querysetcell(q,"name","Belize") />
		<cfset queryaddrow(q) /><cfset querysetcell(q,"code","BJ") /><cfset querysetcell(q,"name","Benin") />
		<cfset queryaddrow(q) /><cfset querysetcell(q,"code","BM") /><cfset querysetcell(q,"name","Bermuda") />
		<cfset queryaddrow(q) /><cfset querysetcell(q,"code","BT") /><cfset querysetcell(q,"name","Bhutan") />
		<cfset queryaddrow(q) /><cfset querysetcell(q,"code","BO") /><cfset querysetcell(q,"name","Bolivia") />
		<cfset queryaddrow(q) /><cfset querysetcell(q,"code","BA") /><cfset querysetcell(q,"name","Bosnia and Herzegovina") />
		<cfset queryaddrow(q) /><cfset querysetcell(q,"code","BW") /><cfset querysetcell(q,"name","Botswana") />
		<cfset queryaddrow(q) /><cfset querysetcell(q,"code","BV") /><cfset querysetcell(q,"name","Bouvet Island") />
		<cfset queryaddrow(q) /><cfset querysetcell(q,"code","BR") /><cfset querysetcell(q,"name","Brazil") />
		<cfset queryaddrow(q) /><cfset querysetcell(q,"code","IO") /><cfset querysetcell(q,"name","British Indian Ocean Territory") />
		<cfset queryaddrow(q) /><cfset querysetcell(q,"code","BN") /><cfset querysetcell(q,"name","Brunei Darussalam") />
		<cfset queryaddrow(q) /><cfset querysetcell(q,"code","BG") /><cfset querysetcell(q,"name","Bulgaria") />
		<cfset queryaddrow(q) /><cfset querysetcell(q,"code","BF") /><cfset querysetcell(q,"name","Burkina Faso") />
		<cfset queryaddrow(q) /><cfset querysetcell(q,"code","BI") /><cfset querysetcell(q,"name","Burundi") />
		<cfset queryaddrow(q) /><cfset querysetcell(q,"code","KH") /><cfset querysetcell(q,"name","Cambodia") />
		<cfset queryaddrow(q) /><cfset querysetcell(q,"code","CM") /><cfset querysetcell(q,"name","Cameroon") />
		<cfset queryaddrow(q) /><cfset querysetcell(q,"code","CA") /><cfset querysetcell(q,"name","Canada") />
		<cfset queryaddrow(q) /><cfset querysetcell(q,"code","CV") /><cfset querysetcell(q,"name","Cape Verde") />
		<cfset queryaddrow(q) /><cfset querysetcell(q,"code","KY") /><cfset querysetcell(q,"name","Cayman Islands") />
		<cfset queryaddrow(q) /><cfset querysetcell(q,"code","CF") /><cfset querysetcell(q,"name","Central African Republic") />
		<cfset queryaddrow(q) /><cfset querysetcell(q,"code","TD") /><cfset querysetcell(q,"name","Chad") />
		<cfset queryaddrow(q) /><cfset querysetcell(q,"code","CL") /><cfset querysetcell(q,"name","Chile") />
		<cfset queryaddrow(q) /><cfset querysetcell(q,"code","CN") /><cfset querysetcell(q,"name","China") />
		<cfset queryaddrow(q) /><cfset querysetcell(q,"code","CX") /><cfset querysetcell(q,"name","Christmas Island") />
		<cfset queryaddrow(q) /><cfset querysetcell(q,"code","CC") /><cfset querysetcell(q,"name","Cocos (Keeling Islands)") />
		<cfset queryaddrow(q) /><cfset querysetcell(q,"code","CO") /><cfset querysetcell(q,"name","Colombia") />
		<cfset queryaddrow(q) /><cfset querysetcell(q,"code","KM") /><cfset querysetcell(q,"name","Comoros") />
		<cfset queryaddrow(q) /><cfset querysetcell(q,"code","CG") /><cfset querysetcell(q,"name","Congo") />
		<cfset queryaddrow(q) /><cfset querysetcell(q,"code","CK") /><cfset querysetcell(q,"name","Cook Islands") />
		<cfset queryaddrow(q) /><cfset querysetcell(q,"code","CR") /><cfset querysetcell(q,"name","Costa Rica") />
		<cfset queryaddrow(q) /><cfset querysetcell(q,"code","CI") /><cfset querysetcell(q,"name","Cote D'Ivoire (Ivory Coast)") />
		<cfset queryaddrow(q) /><cfset querysetcell(q,"code","HR") /><cfset querysetcell(q,"name","Croatia (Hrvatska)") />
		<cfset queryaddrow(q) /><cfset querysetcell(q,"code","CU") /><cfset querysetcell(q,"name","Cuba") />
		<cfset queryaddrow(q) /><cfset querysetcell(q,"code","CY") /><cfset querysetcell(q,"name","Cyprus") />
		<cfset queryaddrow(q) /><cfset querysetcell(q,"code","CZ") /><cfset querysetcell(q,"name","Czech Republic") />
		<cfset queryaddrow(q) /><cfset querysetcell(q,"code","DK") /><cfset querysetcell(q,"name","Denmark") />
		<cfset queryaddrow(q) /><cfset querysetcell(q,"code","DJ") /><cfset querysetcell(q,"name","Djibouti") />
		<cfset queryaddrow(q) /><cfset querysetcell(q,"code","DM") /><cfset querysetcell(q,"name","Dominica") />
		<cfset queryaddrow(q) /><cfset querysetcell(q,"code","DO") /><cfset querysetcell(q,"name","Dominican Republic") />
		<cfset queryaddrow(q) /><cfset querysetcell(q,"code","TP") /><cfset querysetcell(q,"name","East Timor") />
		<cfset queryaddrow(q) /><cfset querysetcell(q,"code","EC") /><cfset querysetcell(q,"name","Ecuador") />
		<cfset queryaddrow(q) /><cfset querysetcell(q,"code","EG") /><cfset querysetcell(q,"name","Egypt") />
		<cfset queryaddrow(q) /><cfset querysetcell(q,"code","SV") /><cfset querysetcell(q,"name","El Salvador") />
		<cfset queryaddrow(q) /><cfset querysetcell(q,"code","GQ") /><cfset querysetcell(q,"name","Equatorial Guinea") />
		<cfset queryaddrow(q) /><cfset querysetcell(q,"code","ER") /><cfset querysetcell(q,"name","Eritrea") />
		<cfset queryaddrow(q) /><cfset querysetcell(q,"code","EE") /><cfset querysetcell(q,"name","Estonia") />
		<cfset queryaddrow(q) /><cfset querysetcell(q,"code","ET") /><cfset querysetcell(q,"name","Ethiopia") />
		<cfset queryaddrow(q) /><cfset querysetcell(q,"code","EU") /><cfset querysetcell(q,"name","Europe") />
		<cfset queryaddrow(q) /><cfset querysetcell(q,"code","FK") /><cfset querysetcell(q,"name","Falkland Islands (Malvinas)") />
		<cfset queryaddrow(q) /><cfset querysetcell(q,"code","FO") /><cfset querysetcell(q,"name","Faroe Islands") />
		<cfset queryaddrow(q) /><cfset querysetcell(q,"code","FJ") /><cfset querysetcell(q,"name","Fiji") />
		<cfset queryaddrow(q) /><cfset querysetcell(q,"code","FI") /><cfset querysetcell(q,"name","Finland") />
		<cfset queryaddrow(q) /><cfset querysetcell(q,"code","FR") /><cfset querysetcell(q,"name","France") />
		<cfset queryaddrow(q) /><cfset querysetcell(q,"code","FX") /><cfset querysetcell(q,"name","France, Metropolitan") />
		<cfset queryaddrow(q) /><cfset querysetcell(q,"code","GF") /><cfset querysetcell(q,"name","French Guiana") />
		<cfset queryaddrow(q) /><cfset querysetcell(q,"code","PF") /><cfset querysetcell(q,"name","French Polynesia") />
		<cfset queryaddrow(q) /><cfset querysetcell(q,"code","TF") /><cfset querysetcell(q,"name","French Southern Territories") />
		<cfset queryaddrow(q) /><cfset querysetcell(q,"code","GA") /><cfset querysetcell(q,"name","Gabon") />
		<cfset queryaddrow(q) /><cfset querysetcell(q,"code","GM") /><cfset querysetcell(q,"name","Gambia") />
		<cfset queryaddrow(q) /><cfset querysetcell(q,"code","GE") /><cfset querysetcell(q,"name","Georgia") />
		<cfset queryaddrow(q) /><cfset querysetcell(q,"code","DE") /><cfset querysetcell(q,"name","Germany") />
		<cfset queryaddrow(q) /><cfset querysetcell(q,"code","GH") /><cfset querysetcell(q,"name","Ghana") />
		<cfset queryaddrow(q) /><cfset querysetcell(q,"code","GI") /><cfset querysetcell(q,"name","Gibraltar") />
		<cfset queryaddrow(q) /><cfset querysetcell(q,"code","GB") /><cfset querysetcell(q,"name","United Kingdom (Great Britain)") />
		<cfset queryaddrow(q) /><cfset querysetcell(q,"code","GR") /><cfset querysetcell(q,"name","Greece") />
		<cfset queryaddrow(q) /><cfset querysetcell(q,"code","GL") /><cfset querysetcell(q,"name","Greenland") />
		<cfset queryaddrow(q) /><cfset querysetcell(q,"code","GD") /><cfset querysetcell(q,"name","Grenada") />
		<cfset queryaddrow(q) /><cfset querysetcell(q,"code","GP") /><cfset querysetcell(q,"name","Guadeloupe") />
		<cfset queryaddrow(q) /><cfset querysetcell(q,"code","GU") /><cfset querysetcell(q,"name","Guam") />
		<cfset queryaddrow(q) /><cfset querysetcell(q,"code","GT") /><cfset querysetcell(q,"name","Guatemala") />
		<cfset queryaddrow(q) /><cfset querysetcell(q,"code","GN") /><cfset querysetcell(q,"name","Guinea") />
		<cfset queryaddrow(q) /><cfset querysetcell(q,"code","GW") /><cfset querysetcell(q,"name","Guinea-Bissau") />
		<cfset queryaddrow(q) /><cfset querysetcell(q,"code","GY") /><cfset querysetcell(q,"name","Guyana") />
		<cfset queryaddrow(q) /><cfset querysetcell(q,"code","HT") /><cfset querysetcell(q,"name","Haiti") />
		<cfset queryaddrow(q) /><cfset querysetcell(q,"code","HM") /><cfset querysetcell(q,"name","Heard and McDonald Islands") />
		<cfset queryaddrow(q) /><cfset querysetcell(q,"code","HN") /><cfset querysetcell(q,"name","Honduras") />
		<cfset queryaddrow(q) /><cfset querysetcell(q,"code","HK") /><cfset querysetcell(q,"name","Hong Kong") />
		<cfset queryaddrow(q) /><cfset querysetcell(q,"code","HU") /><cfset querysetcell(q,"name","Hungary") />
		<cfset queryaddrow(q) /><cfset querysetcell(q,"code","IS") /><cfset querysetcell(q,"name","Iceland") />
		<cfset queryaddrow(q) /><cfset querysetcell(q,"code","IN") /><cfset querysetcell(q,"name","India") />
		<cfset queryaddrow(q) /><cfset querysetcell(q,"code","ID") /><cfset querysetcell(q,"name","Indonesia") />
		<cfset queryaddrow(q) /><cfset querysetcell(q,"code","IR") /><cfset querysetcell(q,"name","Iran") />
		<cfset queryaddrow(q) /><cfset querysetcell(q,"code","IQ") /><cfset querysetcell(q,"name","Iraq") />
		<cfset queryaddrow(q) /><cfset querysetcell(q,"code","IE") /><cfset querysetcell(q,"name","Ireland") />
		<cfset queryaddrow(q) /><cfset querysetcell(q,"code","IL") /><cfset querysetcell(q,"name","Israel") />
		<cfset queryaddrow(q) /><cfset querysetcell(q,"code","IT") /><cfset querysetcell(q,"name","Italy") />
		<cfset queryaddrow(q) /><cfset querysetcell(q,"code","JM") /><cfset querysetcell(q,"name","Jamaica") />
		<cfset queryaddrow(q) /><cfset querysetcell(q,"code","JP") /><cfset querysetcell(q,"name","Japan") />
		<cfset queryaddrow(q) /><cfset querysetcell(q,"code","JO") /><cfset querysetcell(q,"name","Jordan") />
		<cfset queryaddrow(q) /><cfset querysetcell(q,"code","KZ") /><cfset querysetcell(q,"name","Kazakhstan") />
		<cfset queryaddrow(q) /><cfset querysetcell(q,"code","KE") /><cfset querysetcell(q,"name","Kenya") />
		<cfset queryaddrow(q) /><cfset querysetcell(q,"code","KI") /><cfset querysetcell(q,"name","Kiribati") />
		<cfset queryaddrow(q) /><cfset querysetcell(q,"code","KP") /><cfset querysetcell(q,"name","Korea (North) (People's Republic)") />
		<cfset queryaddrow(q) /><cfset querysetcell(q,"code","KR") /><cfset querysetcell(q,"name","Korea (South) (Republic)") />
		<cfset queryaddrow(q) /><cfset querysetcell(q,"code","KW") /><cfset querysetcell(q,"name","Kuwait") />
		<cfset queryaddrow(q) /><cfset querysetcell(q,"code","KG") /><cfset querysetcell(q,"name","Kyrgyzstan (Kyrgyz Republic)") />
		<cfset queryaddrow(q) /><cfset querysetcell(q,"code","LA") /><cfset querysetcell(q,"name","Laos") />
		<cfset queryaddrow(q) /><cfset querysetcell(q,"code","LV") /><cfset querysetcell(q,"name","Latvia") />
		<cfset queryaddrow(q) /><cfset querysetcell(q,"code","LB") /><cfset querysetcell(q,"name","Lebanon") />
		<cfset queryaddrow(q) /><cfset querysetcell(q,"code","LS") /><cfset querysetcell(q,"name","Lesotho") />
		<cfset queryaddrow(q) /><cfset querysetcell(q,"code","LR") /><cfset querysetcell(q,"name","Liberia") />
		<cfset queryaddrow(q) /><cfset querysetcell(q,"code","LY") /><cfset querysetcell(q,"name","Libya") />
		<cfset queryaddrow(q) /><cfset querysetcell(q,"code","LI") /><cfset querysetcell(q,"name","Liechtenstein") />
		<cfset queryaddrow(q) /><cfset querysetcell(q,"code","LT") /><cfset querysetcell(q,"name","Lithuania") />
		<cfset queryaddrow(q) /><cfset querysetcell(q,"code","LU") /><cfset querysetcell(q,"name","Luxembourg") />
		<cfset queryaddrow(q) /><cfset querysetcell(q,"code","MO") /><cfset querysetcell(q,"name","Macau") />
		<cfset queryaddrow(q) /><cfset querysetcell(q,"code","MK") /><cfset querysetcell(q,"name","Macedonia") />
		<cfset queryaddrow(q) /><cfset querysetcell(q,"code","MG") /><cfset querysetcell(q,"name","Madagascar") />
		<cfset queryaddrow(q) /><cfset querysetcell(q,"code","MW") /><cfset querysetcell(q,"name","Malawi") />
		<cfset queryaddrow(q) /><cfset querysetcell(q,"code","MY") /><cfset querysetcell(q,"name","Malaysia") />
		<cfset queryaddrow(q) /><cfset querysetcell(q,"code","MV") /><cfset querysetcell(q,"name","Maldives") />
		<cfset queryaddrow(q) /><cfset querysetcell(q,"code","ML") /><cfset querysetcell(q,"name","Mali") />
		<cfset queryaddrow(q) /><cfset querysetcell(q,"code","MT") /><cfset querysetcell(q,"name","Malta") />
		<cfset queryaddrow(q) /><cfset querysetcell(q,"code","MH") /><cfset querysetcell(q,"name","Marshall Islands") />
		<cfset queryaddrow(q) /><cfset querysetcell(q,"code","MQ") /><cfset querysetcell(q,"name","Martinique") />
		<cfset queryaddrow(q) /><cfset querysetcell(q,"code","MR") /><cfset querysetcell(q,"name","Mauritania") />
		<cfset queryaddrow(q) /><cfset querysetcell(q,"code","MU") /><cfset querysetcell(q,"name","Mauritius") />
		<cfset queryaddrow(q) /><cfset querysetcell(q,"code","YT") /><cfset querysetcell(q,"name","Mayotte") />
		<cfset queryaddrow(q) /><cfset querysetcell(q,"code","MX") /><cfset querysetcell(q,"name","Mexico") />
		<cfset queryaddrow(q) /><cfset querysetcell(q,"code","FM") /><cfset querysetcell(q,"name","Micronesia") />
		<cfset queryaddrow(q) /><cfset querysetcell(q,"code","MD") /><cfset querysetcell(q,"name","Moldova") />
		<cfset queryaddrow(q) /><cfset querysetcell(q,"code","MC") /><cfset querysetcell(q,"name","Monaco") />
		<cfset queryaddrow(q) /><cfset querysetcell(q,"code","MN") /><cfset querysetcell(q,"name","Mongolia") />
		<cfset queryaddrow(q) /><cfset querysetcell(q,"code","MS") /><cfset querysetcell(q,"name","Montserrat") />
		<cfset queryaddrow(q) /><cfset querysetcell(q,"code","MA") /><cfset querysetcell(q,"name","Morocco") />
		<cfset queryaddrow(q) /><cfset querysetcell(q,"code","MZ") /><cfset querysetcell(q,"name","Mozambique") />
		<cfset queryaddrow(q) /><cfset querysetcell(q,"code","MM") /><cfset querysetcell(q,"name","Myanmar") />
		<cfset queryaddrow(q) /><cfset querysetcell(q,"code","NA") /><cfset querysetcell(q,"name","Namibia") />
		<cfset queryaddrow(q) /><cfset querysetcell(q,"code","NR") /><cfset querysetcell(q,"name","Nauru") />
		<cfset queryaddrow(q) /><cfset querysetcell(q,"code","NP") /><cfset querysetcell(q,"name","Nepal") />
		<cfset queryaddrow(q) /><cfset querysetcell(q,"code","NL") /><cfset querysetcell(q,"name","Netherlands") />
		<cfset queryaddrow(q) /><cfset querysetcell(q,"code","AN") /><cfset querysetcell(q,"name","Netherlands Antilles") />
		<cfset queryaddrow(q) /><cfset querysetcell(q,"code","NT") /><cfset querysetcell(q,"name","Neutral Zone (Saudia Arabia/Iraq)") />
		<cfset queryaddrow(q) /><cfset querysetcell(q,"code","NC") /><cfset querysetcell(q,"name","New Caledonia") />
		<cfset queryaddrow(q) /><cfset querysetcell(q,"code","NZ") /><cfset querysetcell(q,"name","New Zealand") />
		<cfset queryaddrow(q) /><cfset querysetcell(q,"code","NI") /><cfset querysetcell(q,"name","Nicaragua") />
		<cfset queryaddrow(q) /><cfset querysetcell(q,"code","NE") /><cfset querysetcell(q,"name","Niger") />
		<cfset queryaddrow(q) /><cfset querysetcell(q,"code","NG") /><cfset querysetcell(q,"name","Nigeria") />
		<cfset queryaddrow(q) /><cfset querysetcell(q,"code","NU") /><cfset querysetcell(q,"name","Niue") />
		<cfset queryaddrow(q) /><cfset querysetcell(q,"code","NF") /><cfset querysetcell(q,"name","Norfolk Island") />
		<cfset queryaddrow(q) /><cfset querysetcell(q,"code","MP") /><cfset querysetcell(q,"name","Northern Mariana Islands") />
		<cfset queryaddrow(q) /><cfset querysetcell(q,"code","NO") /><cfset querysetcell(q,"name","Norway") />
		<cfset queryaddrow(q) /><cfset querysetcell(q,"code","OM") /><cfset querysetcell(q,"name","Oman") />
		<cfset queryaddrow(q) /><cfset querysetcell(q,"code","PK") /><cfset querysetcell(q,"name","Pakistan") />
		<cfset queryaddrow(q) /><cfset querysetcell(q,"code","PW") /><cfset querysetcell(q,"name","Palau") />
		<cfset queryaddrow(q) /><cfset querysetcell(q,"code","PA") /><cfset querysetcell(q,"name","Panama") />
		<cfset queryaddrow(q) /><cfset querysetcell(q,"code","PG") /><cfset querysetcell(q,"name","Papua New Guinea") />
		<cfset queryaddrow(q) /><cfset querysetcell(q,"code","PY") /><cfset querysetcell(q,"name","Paraguay") />
		<cfset queryaddrow(q) /><cfset querysetcell(q,"code","PE") /><cfset querysetcell(q,"name","Peru") />
		<cfset queryaddrow(q) /><cfset querysetcell(q,"code","PH") /><cfset querysetcell(q,"name","Philippines") />
		<cfset queryaddrow(q) /><cfset querysetcell(q,"code","PN") /><cfset querysetcell(q,"name","Pitcairn") />
		<cfset queryaddrow(q) /><cfset querysetcell(q,"code","PL") /><cfset querysetcell(q,"name","Poland") />
		<cfset queryaddrow(q) /><cfset querysetcell(q,"code","PT") /><cfset querysetcell(q,"name","Portugal") />
		<cfset queryaddrow(q) /><cfset querysetcell(q,"code","PR") /><cfset querysetcell(q,"name","Puerto Rico") />
		<cfset queryaddrow(q) /><cfset querysetcell(q,"code","PS") /><cfset querysetcell(q,"name","Palestine") />
		<cfset queryaddrow(q) /><cfset querysetcell(q,"code","QA") /><cfset querysetcell(q,"name","Qatar") />
		<cfset queryaddrow(q) /><cfset querysetcell(q,"code","RE") /><cfset querysetcell(q,"name","Reunion") />
		<cfset queryaddrow(q) /><cfset querysetcell(q,"code","RO") /><cfset querysetcell(q,"name","Romania") />
		<cfset queryaddrow(q) /><cfset querysetcell(q,"code","RU") /><cfset querysetcell(q,"name","Russian Federation") />
		<cfset queryaddrow(q) /><cfset querysetcell(q,"code","RW") /><cfset querysetcell(q,"name","Rwanda") />
		<cfset queryaddrow(q) /><cfset querysetcell(q,"code","GS") /><cfset querysetcell(q,"name","S. Georgia and S. Sandwich Isls.") />
		<cfset queryaddrow(q) /><cfset querysetcell(q,"code","KN") /><cfset querysetcell(q,"name","Saint Kitts and Nevis") />
		<cfset queryaddrow(q) /><cfset querysetcell(q,"code","LC") /><cfset querysetcell(q,"name","Saint Lucia") />
		<cfset queryaddrow(q) /><cfset querysetcell(q,"code","VC") /><cfset querysetcell(q,"name","Saint Vincent and The Grenadines") />
		<cfset queryaddrow(q) /><cfset querysetcell(q,"code","WS") /><cfset querysetcell(q,"name","Samoa") />
		<cfset queryaddrow(q) /><cfset querysetcell(q,"code","SM") /><cfset querysetcell(q,"name","San Marino") />
		<cfset queryaddrow(q) /><cfset querysetcell(q,"code","ST") /><cfset querysetcell(q,"name","Sao Tome and Principe") />
		<cfset queryaddrow(q) /><cfset querysetcell(q,"code","SA") /><cfset querysetcell(q,"name","Saudi Arabia") />
		<cfset queryaddrow(q) /><cfset querysetcell(q,"code","SN") /><cfset querysetcell(q,"name","Senegal") />
		<cfset queryaddrow(q) /><cfset querysetcell(q,"code","SC") /><cfset querysetcell(q,"name","Seychelles") />
		<cfset queryaddrow(q) /><cfset querysetcell(q,"code","SL") /><cfset querysetcell(q,"name","Sierra Leone") />
		<cfset queryaddrow(q) /><cfset querysetcell(q,"code","SG") /><cfset querysetcell(q,"name","Singapore") />
		<cfset queryaddrow(q) /><cfset querysetcell(q,"code","SK") /><cfset querysetcell(q,"name","Slovakia (Slovak Republic)") />
		<cfset queryaddrow(q) /><cfset querysetcell(q,"code","SI") /><cfset querysetcell(q,"name","Slovenia") />
		<cfset queryaddrow(q) /><cfset querysetcell(q,"code","SB") /><cfset querysetcell(q,"name","Solomon Islands") />
		<cfset queryaddrow(q) /><cfset querysetcell(q,"code","SO") /><cfset querysetcell(q,"name","Somalia") />
		<cfset queryaddrow(q) /><cfset querysetcell(q,"code","ZA") /><cfset querysetcell(q,"name","South Africa") />
		<cfset queryaddrow(q) /><cfset querysetcell(q,"code","SU") /><cfset querysetcell(q,"name","Soviet Union (former)") />
		<cfset queryaddrow(q) /><cfset querysetcell(q,"code","ES") /><cfset querysetcell(q,"name","Spain") />
		<cfset queryaddrow(q) /><cfset querysetcell(q,"code","LK") /><cfset querysetcell(q,"name","Sri Lanka") />
		<cfset queryaddrow(q) /><cfset querysetcell(q,"code","SH") /><cfset querysetcell(q,"name","St. Helena") />
		<cfset queryaddrow(q) /><cfset querysetcell(q,"code","PM") /><cfset querysetcell(q,"name","St. Pierre and Miquelon") />
		<cfset queryaddrow(q) /><cfset querysetcell(q,"code","SD") /><cfset querysetcell(q,"name","Sudan") />
		<cfset queryaddrow(q) /><cfset querysetcell(q,"code","SR") /><cfset querysetcell(q,"name","Suriname") />
		<cfset queryaddrow(q) /><cfset querysetcell(q,"code","SJ") /><cfset querysetcell(q,"name","Svalbard and Jan Mayen Islands") />
		<cfset queryaddrow(q) /><cfset querysetcell(q,"code","SZ") /><cfset querysetcell(q,"name","Swaziland") />
		<cfset queryaddrow(q) /><cfset querysetcell(q,"code","SE") /><cfset querysetcell(q,"name","Sweden") />
		<cfset queryaddrow(q) /><cfset querysetcell(q,"code","CH") /><cfset querysetcell(q,"name","Switzerland") />
		<cfset queryaddrow(q) /><cfset querysetcell(q,"code","SY") /><cfset querysetcell(q,"name","Syria") />
		<cfset queryaddrow(q) /><cfset querysetcell(q,"code","TW") /><cfset querysetcell(q,"name","Taiwan") />
		<cfset queryaddrow(q) /><cfset querysetcell(q,"code","TJ") /><cfset querysetcell(q,"name","Tajikistan") />
		<cfset queryaddrow(q) /><cfset querysetcell(q,"code","TZ") /><cfset querysetcell(q,"name","Tanzania") />
		<cfset queryaddrow(q) /><cfset querysetcell(q,"code","TH") /><cfset querysetcell(q,"name","Thailand") />
		<cfset queryaddrow(q) /><cfset querysetcell(q,"code","TG") /><cfset querysetcell(q,"name","Togo") />
		<cfset queryaddrow(q) /><cfset querysetcell(q,"code","TK") /><cfset querysetcell(q,"name","Tokelau") />
		<cfset queryaddrow(q) /><cfset querysetcell(q,"code","TO") /><cfset querysetcell(q,"name","Tonga") />
		<cfset queryaddrow(q) /><cfset querysetcell(q,"code","TT") /><cfset querysetcell(q,"name","Trinidad and Tobago") />
		<cfset queryaddrow(q) /><cfset querysetcell(q,"code","TN") /><cfset querysetcell(q,"name","Tunisia") />
		<cfset queryaddrow(q) /><cfset querysetcell(q,"code","TR") /><cfset querysetcell(q,"name","Turkey") />
		<cfset queryaddrow(q) /><cfset querysetcell(q,"code","TM") /><cfset querysetcell(q,"name","Turkmenistan") />
		<cfset queryaddrow(q) /><cfset querysetcell(q,"code","TC") /><cfset querysetcell(q,"name","Turks and Caicos Islands") />
		<cfset queryaddrow(q) /><cfset querysetcell(q,"code","TV") /><cfset querysetcell(q,"name","Tuvalu") />
		<cfset queryaddrow(q) /><cfset querysetcell(q,"code","UG") /><cfset querysetcell(q,"name","Uganda") />
		<cfset queryaddrow(q) /><cfset querysetcell(q,"code","UA") /><cfset querysetcell(q,"name","Ukraine") />
		<cfset queryaddrow(q) /><cfset querysetcell(q,"code","AE") /><cfset querysetcell(q,"name","United Arab Emirates") />
		<cfset queryaddrow(q) /><cfset querysetcell(q,"code","US") /><cfset querysetcell(q,"name","United States of America") />
		<cfset queryaddrow(q) /><cfset querysetcell(q,"code","UY") /><cfset querysetcell(q,"name","Uruguay") />
		<cfset queryaddrow(q) /><cfset querysetcell(q,"code","UZ") /><cfset querysetcell(q,"name","Uzbekistan") />
		<cfset queryaddrow(q) /><cfset querysetcell(q,"code","VU") /><cfset querysetcell(q,"name","Vanuatu") />
		<cfset queryaddrow(q) /><cfset querysetcell(q,"code","VA") /><cfset querysetcell(q,"name","Vatican City State (Holy See)") />
		<cfset queryaddrow(q) /><cfset querysetcell(q,"code","VE") /><cfset querysetcell(q,"name","Venezuela") />
		<cfset queryaddrow(q) /><cfset querysetcell(q,"code","VN") /><cfset querysetcell(q,"name","Viet Nam") />
		<cfset queryaddrow(q) /><cfset querysetcell(q,"code","VG") /><cfset querysetcell(q,"name","Virgin Islands (British)") />
		<cfset queryaddrow(q) /><cfset querysetcell(q,"code","VI") /><cfset querysetcell(q,"name","Virgin Islands (US)") />
		<cfset queryaddrow(q) /><cfset querysetcell(q,"code","WF") /><cfset querysetcell(q,"name","Wallis and Futuna Islands") />
		<cfset queryaddrow(q) /><cfset querysetcell(q,"code","EH") /><cfset querysetcell(q,"name","Western Sahara") />
		<cfset queryaddrow(q) /><cfset querysetcell(q,"code","YE") /><cfset querysetcell(q,"name","Yemen") />
		<cfset queryaddrow(q) /><cfset querysetcell(q,"code","YU") /><cfset querysetcell(q,"name","Yugoslavia") />
		<cfset queryaddrow(q) /><cfset querysetcell(q,"code","ZR") /><cfset querysetcell(q,"name","Zaire") />
		<cfset queryaddrow(q) /><cfset querysetcell(q,"code","ZM") /><cfset querysetcell(q,"name","Zambia") />
		<cfset queryaddrow(q) /><cfset querysetcell(q,"code","ZW") /><cfset querysetcell(q,"name","Zimbabwe") />
		
		<cfset this.qCountries = q />
		
		<cfreturn this>
	</cffunction>
	
	<cffunction name="edit" access="public" output="true" returntype="string" hint="his will return a string of formatted HTML text to enable the user to edit the data">
		<cfargument name="typename" required="true" type="string" hint="The name of the type that this field is part of.">
		<cfargument name="stObject" required="true" type="struct" hint="The object of the record that this field is part of.">
		<cfargument name="stMetadata" required="true" type="struct" hint="This is the metadata that is either setup as part of the type.cfc or overridden when calling ft:object by using the stMetadata argument.">
		<cfargument name="fieldname" required="true" type="string" hint="This is the name that will be used for the form field. It includes the prefix that will be used by ft:processform.">
		<cfargument name="inputClass" required="false" type="string" default="" hint="This is the class value that will be applied to the input field.">

		<cfset var html = "" />
		<cfset var qCommon = "" />
		<cfset var qAll = "" />
		<cfset var selectedItem = false />
		
		<cfparam name="arguments.stMetadata.ftCommon" default="Australia,New Zealand" />
		<cfparam name="arguments.stMetadata.ftCountries" default="" />
		<cfparam name="arguments.stMetadata.ftValue" default="name" /><!--- "code" | "name" --->
		
		<cfset qCommon = getCountries(arguments.stMetadata.ftCommon) />
		<cfset qAll = getCountries(arguments.stMetadata.ftCountries) />
		
		<cfsavecontent variable="html">
			<cfoutput>
				<select name="#arguments.fieldname#" id="#arguments.fieldname#" class="selectInput #arguments.inputClass# #arguments.stMetadata.ftclass#" style="#arguments.stMetadata.ftstyle#">
			</cfoutput>
			
			<cfif qCommon.recordcount>
				<cfoutput><optgroup label="Common choices"></cfoutput>
				
				<cfoutput query="qCommon">
					<option value="#qCommon[arguments.stMetadata.ftValue][qCommon.currentrow]#"<cfif arguments.stMetadata.value eq qCommon[arguments.stMetadata.ftValue][qCommon.currentrow]> selected="selected"<cfset selectedItem = true /></cfif>>#qCommon.name[qCommon.currentrow]#</option>
				</cfoutput>
			
				<cfoutput>
					</optgroup>
					<optgroup label="Other countries">
				</cfoutput>
			</cfif>
			
			<cfoutput query="qAll">
				<option value="#qAll[arguments.stMetadata.ftValue][qAll.currentrow]#"<cfif arguments.stMetadata.value eq qAll[arguments.stMetadata.ftValue][qCommon.currentrow] and not selectedItem> selected="selected"</cfif>>#qAll.name[qAll.currentrow]#</option>
				
			</cfoutput>
			
			<cfif qCommon.recordcount>
				<cfoutput></optgroup></cfoutput>
			</cfif>
			
			<cfoutput>
				</select>
			</cfoutput>
		</cfsavecontent>
		
		<cfreturn html>
	</cffunction>

	<cffunction name="getCountries" returntype="query" output="false" access="public" hint="Returns countries and country codes">
		<cfargument name="countries" type="string" required="false" hint="Including this argument restricts the countries to certain countries or country codes" />
		
		<cfset var q = querynew("code,name") />
		
		<cfquery dbtype="query" name="q">
			select		code,name
			from		this.qCountries
			<cfif structkeyexists(arguments,"countries") and len(arguments.countries)>
				where	code in (<cfqueryparam cfsqltype="cf_sql_varchar" list="true" value="#arguments.countries#">)
						OR name in (<cfqueryparam cfsqltype="cf_sql_varchar" list="true" value="#arguments.countries#">)
			</cfif>
			order by	name
		</cfquery>
		
		<cfreturn q />
	</cffunction>

	<cffunction name="display" access="public" output="false" returntype="string" hint="This will return a string of formatted HTML text to display.">
		<cfargument name="typename" required="true" type="string" hint="The name of the type that this field is part of.">
		<cfargument name="stObject" required="true" type="struct" hint="The object of the record that this field is part of.">
		<cfargument name="stMetadata" required="true" type="struct" hint="This is the metadata that is either setup as part of the type.cfc or overridden when calling ft:object by using the stMetadata argument.">
		<cfargument name="fieldname" required="true" type="string" hint="This is the name that will be used for the form field. It includes the prefix that will be used by ft:processform.">

		<cfset var html = arguments.stMetadata.value />
		<cfset var q = "" />
		
		<cfif structkeyexists(arguments.stMetadata,"ftValue") and arguments.stMetadata.ftValue eq "code">
			<cfset q = getCountries(arguments.stMetadata.value) />
			<cfset html = q.name[1] />
		</cfif>
		
		<cfreturn html>
	</cffunction>

	<cffunction name="validate" access="public" output="true" returntype="struct" hint="This will return a struct with bSuccess and stError">
		<cfargument name="objectid" required="true" type="string" hint="The objectid of the object that this field is part of.">
		<cfargument name="typename" required="true" type="string" hint="The name of the type that this field is part of.">
		<cfargument name="stFieldPost" required="true" type="struct" hint="The fields that are relevent to this field type.">
		<cfargument name="stMetadata" required="true" type="struct" hint="This is the metadata that is either setup as part of the type.cfc or overridden when calling ft:object by using the stMetadata argument.">
		
		<cfset var stResult = passed(value=stFieldPost.Value) />
		
		<cfif structKeyExists(arguments.stMetadata, "ftValidation") AND listFindNoCase(arguments.stMetadata.ftValidation, "required") AND NOT len(stFieldPost.Value)>
			<cfset stResult = failed(value="#arguments.stFieldPost.value#", message="This is a required field.") />
		</cfif>
	
		<cfreturn stResult />
	</cffunction>
	
</cfcomponent>