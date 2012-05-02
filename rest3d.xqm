xquery version "1.0";

module namespace rest3d="http://rest3d.org";

import module namespace json="http://www.json.org";
import module namespace request="http://exist-db.org/xquery/request";
import module namespace util="http://exist-db.org/xquery/util";
import module namespace functx="http://www.functx.com" at "functx.xqm";

(: return a xml document :)
declare function rest3d:as-xml($result as element())
{
  let $tmp := response:set-header("Content-Type","application/xml")
  return util:serialize($result,"method=xml omit-xml-declaration=no")
};

(: return json encoded string :)
declare function rest3d:as-json($result as element()) 
{
  (: check if we need to return a jsonp function :)
  let $jsonp as xs:string * := request:get-parameter('jsonp',())

  let $tmp := response:set-header("Content-type","text/plain")
  let $json := json:xml-to-json($result)
  return 
    if ($jsonp) then concat($jsonp,'(',$json,')')
    else $json
};

(: return html ul/li document :)
declare function local:to-html($from as element()*) as element()*
{

    for $node in $from
    return if ($node/*) then element li { node-name($node),
                               for $elem in $node/* return local:to-html($elem)}
           else element ul { element li {node-name($node),' = ', 
                                if ($node/@type eq 'img') then element img {attribute src {$node/text()}}
                                else if ($node/@type eq 'url') then element a {attribute href {$node/text()},$node/text()}
                                else $node/text()}}

};

declare function rest3d:as-html($result as element())
{
 let $result :=  
       <ul class="rest3d"> <style type="text/css">{'img {vertical-align: middle; height: 150; width: auto;}'} </style>
         { local:to-html($result/*)} </ul>
  return util:serialize($result,"method=xhtml")
};

(: select return format :)
declare function rest3d:format($result as element())
{
 let $format := request:get-parameter('api_format','xml')

 return
   if ($format eq 'xml') then rest3d:as-xml($result)
   else if ($format eq 'json') then rest3d:as-json($result)
   else if ($format eq 'html') then rest3d:as-html($result)
   else () (: need to invoque error method here :)
};


(: convert parameter to form :)
declare function rest3d:to-form($input as xs:string*) as xs:string
{

  if ($input) then
 (: assuming url encoding is done by httpclient:post :)
  let $input := replace($input,'&quot;','%22')
  (: let $input := replace($input,'&amp;','%26')  :)
  let $input := replace($input,'&apos;','%27')
  let $input := replace($input,'&lt;','%3C') 
  let $input := replace($input,'&gt;','%3E')
  let $input := replace($input,'\[','%5B')
  let $input := replace($input,'\]','%5D')
  (:let $input := replace($input,'=','%3D') // tested with 3dvia! :)
  (: let $input := replace($input,'~','%7E') :)
  (: let $input := replace($input,'.','%2E') :)
  let $input := replace($input,'\{','%7B')
  let $input := replace($input,'\}','%7D')
  let $input := replace($input,'\|','%7C')
  (: let $input := replace($input,'-','%2D')  :)
  (: let $input := replace($input,'_','%5F')  :)
  let $input := replace($input,'%%','%25') 
  let $input := replace($input,'\^','%5E')
  let $input := replace($input,'/','%2F')
  let $input := replace($input,'\\','%5C')
  let $input := replace($input,'é','%C3%A9')
  let $input := replace($input,'#','%23')
  let $input := replace($input,'!','%21') 
  let $input := replace($input,'\*','%2A')
  let $input := replace($input,'\(','%28')
  let $input := replace($input,'\)','%29')
  let $input := replace($input,';','%3B')
  let $input := replace($input,':','%3A')
  let $input := replace($input,'@','%40')
  let $input := replace($input,'\+','%2B')
  (: let $input := replace($input,'\$','%24') :)
  let $input := replace($input,',','%2C')
  let $input := replace($input,'\?','%3F')
  (: keep last :)
  let $input := replace($input,' ','+')
  return $input 
  else ''
};
