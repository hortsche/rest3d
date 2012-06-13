xquery version "1.0";

import module namespace xdb = "http://exist-db.org/xquery/xmldb";
import module namespace rest3d = "http://rest3d.org" at "rest3d.xqm";

(: collections :)
let $collection := '/db/rest3d'
let $collection-model := fn:concat($collection,'/models')
let $collection-texture := fn:concat($collection,'/textures')
let $collection-xml := fn:concat($collection,'/xml')

(: support searching by :)
(: The contains_supported are for string :)
let $contains_supported := ('name', 'uploader', 'description', 'texture')
(: These are typically numbers, for each on there is both a min_ and max_ parameter :)
(: e.g. to search by effects, either use min_effects, max_effects or both :)
let $range_supported := ('effects', 'vertices', 'texture_coors', 'textures', 'triangles', 'normals')

let $contains_string := string-join(
for $item in $contains_supported
	(: fetch parameter :)
	let $filtered := replace(xs:string(request:get-parameter($item,"")), "[^0-9a-zA-ZäöüßÄÖÜ\-,. ]", "")
	return if ($filtered) then 
		concat('[contains(', $item, ", '", $filtered, "')]")
	else()
,'')
let $min_string := string-join(
for $item in $range_supported
	let $min_item := concat('min_',$item)
	(: fetch parameter :)
	let $filtered := replace(xs:string(request:get-parameter($min_item,"")), "[^0-9a-zA-ZäöüßÄÖÜ\-,. ]", "")
	return if ($filtered) then
		concat('[count/', $item, '>=', $filtered, ']')
	else()
,'')
let $max_string := string-join(
for $item in $range_supported
	let $max_item := concat('max_',$item)
	(: fetch parameter :)
	let $filtered := replace(xs:string(request:get-parameter($max_item,"")), "[^0-9a-zA-ZäöüßÄÖÜ\-,. ]", "")
	return if ($filtered) then
		concat('[count/', $item, '<=', $filtered, ']')
	else()
,'')
	
(: generate search query :)
let $query := concat("collection('",$collection-xml,"')//model",$contains_string,$min_string,$max_string)

(: execute search query :)
let $results := util:eval($query)

(: sort results :)
(: Generate order :)
let $filtered_dir := replace(xs:string(request:get-parameter('direction',"decending")), "[^0-9a-zA-ZäöüßÄÖÜ\-,. ]", "")

let $direction :=
if ($filtered_dir = 'ascending') then 'ascending'
else 'descending'

let $order := replace(xs:string(request:get-parameter('order',"")), "[^0-9a-zA-ZäöüßÄÖÜ\-,. ]", "")
let $order_by :=
if ($order = $contains_supported or $order = $range_supported) then
	concat('$hit//',$order,' ',$direction)
else '$hit//name descending'

let $order_predicate := concat(
'for $hit in $results order by ',$order_by,' return $hit')

let $results := util:eval($order_predicate)

(: Calculate Range :)
(:  Currently does not work
let $limit := replace(xs:string(request:get-parameter('limit',"100")), "[^0-9]", "")
let $limit :=
if ($limit) then xs:integer($limit)
else 100
let $start := replace(xs:string(request:get-parameter('start',"1")), "[^0-9]", "")
let $start :=
if ($start) then xs:integer($start)
else 1
let $end := $start + $limit
:)
(: return rest3d:format($results) - this does not currently work, it complains that we are
 passing in multiple values.  All efforts to join sequences did not seem to work :)
 
return $results
