(: front-end for google warehouse :)
xquery version "1.0";

import module namespace rest3d="http://rest3d.org" at "rest3d.xqm";
import module namespace warehouse="http://rest3d.org/warehouse" at "warehouse-search.xqm";
import module namespace tdvia="http://rest3d.org/tdvia" at "3dvia-search.xqm";
import module namespace ourbricks="http://rest3d.org/ourbricks" at "ourbricks-search.xqm";

let $q as xs:string := request:get-parameter('q','')

let $warehouse := warehouse:search($q,1) 
let $tdvia := tdvia:search($q,1)
let $ourbricks := ourbricks:search($q,1)

let $response := element rest3d { $warehouse, $tdvia, $ourbricks }

return rest3d:format($response)
