xquery version "1.0";

import module namespace rest3d="http://rest3d.org" at "rest3d.xqm";

(: inlined response :)
let $uri := request:get-url()
let $url0 := concat(replace($uri,'^(.*)/(.*)$','$1'),'/0')
let $url1 := concat(replace($uri,'^(.*)/(.*)$','$1'),'/1')

let $result:= 
<rest3d>
  <versions>
    <url> {$url0} </url>
    <version>0</version>
  </versions>
  <versions>
    <url> {$url1} </url>
    <version>1</version>
  </versions>
</rest3d>

return rest3d:format($result)

