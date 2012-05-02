xquery version "1.0";

import module namespace rest3d = "http://rest3d.org" at "rest3d.xqm";
import module namespace xdb="http://exist-db.org/xquery/xmldb";

(: collections :)
let $collection := '/db/rest3d'
let $collection-model := fn:concat($collection,'/models')
let $collection-texture := fn:concat($collection,'/textures')
let $collection-xml := fn:concat($collection,'/xml')

(: fetch parameters :)
let $desc := replace(xs:string(request:get-parameter("q","")), "[^0-9a-zA-ZäöüßÄÖÜ\-,. ]", "")
let $upl := replace(xs:string(request:get-parameter("uploader","")), "[^0-9a-zA-ZäöüßÄÖÜ\-,. ]", "")
let $name := replace(xs:string(request:get-parameter("name","")), "[^0-9a-zA-ZäöüßÄÖÜ\-,. ]", "")

(: generate search predicates :)
let $desc_pred := if ($desc) then concat(concat('[contains(description, ',$desc,']') else ()
let $upl_pred := if ($upl) then concat(concat('[contains(uploader, ',$upl,']') else ()
let $name_pred := if ($name) then concat(concat('[contains(name, ',$name,']') else ()

(: generate search query :)
let $query := concat("collection('",$collection-xml,"')//model",$desc_pred,$upl_pred,$name_pred)

(: TODO: Check cache for result :)

(: execute search query :)
let $results := util:eval($query)

(: TODO: Add search to cache :)

(: TODO: Sort & Rank Results :)

(: TODO: Return results to user :)

