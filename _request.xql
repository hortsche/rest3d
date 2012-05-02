xquery version "1.0";

import module namespace json="http://www.json.org";

let $names := for $name in request:get-parameter-names() return element parameter { element name {$name}, element value {request:get-parameter($name,())}}
let $posted-data := request:get-data()
let $session := if (session:exists()) then for $name in session:get-attribute-names() return element attribute { element name {$name}, element value {session:get-attribute($name)}} else element no-session {'no session'}

let $cookies := for $name in request:get-cookie-names() return element cookie {attribute name {$name}, attribute value {request:get-cookie-value($name)}}

let $headers := for $name in request:get-header-names() return element header {attribute name {$name}, attribute value {request:get-header($name)}}
 
return 
  json:xml-to-json( element return {$names, element POST {$posted-data} , element SESSION {$session},element COOKIES {$cookies}, element HEADERS {$headers}})
