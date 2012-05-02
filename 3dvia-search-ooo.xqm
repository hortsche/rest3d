(: front-end for google warehouse :)
xquery version "1.0";

module namespace tdvia="http://rest3d.org/tdvia";

declare namespace xhtml="http://www.w3.org/1999/xhtml";

import module namespace rest3d="http://rest3d.org" at "rest3d.xqm";

declare function tdvia:search($q as xs:string, $max-pages as xs:integer)
{
let $warehouse := 'http://www.3dvia.com'
let $api := '/search/'

let $results-per-pages := xs:string(12 * $max-pages)
let $params := rest3d:to-form($params)
let $results := httpclient:get(xs:anyURI(concat($warehouse,$api,'?',$params)),false(),())

(: here we should check if there are any results :)

(: now parse the html pages to create response :)
let $response := 
  for $item in $results//xhtml:li[contains(@class,'size1of4')] 
  let $price := $item//xhtml:div[contains(@class,'icon-purchase')]/text()
  let $icon := data($item//xhtml:div[@class eq 'thumbnail-photo']//xhtml:img/@src)
  let $url := data($item//xhtml:div[@class eq 'thumbnail-photo']/xhtml:a/@href)
  let $id := replace($url,'/models/(.*?)/.*$','$1')
  let $author := $item//xhtml:div[@class eq 'tooltip']/xhtml:p[1]/text()
  let $info := data($item//xhtml:div[@class eq 'tooltip']//xhtml:a/@href)
  let $title := $item//xhtml:div[@class eq 'tooltip']//xhtml:h4/text()
  let $filename := ''
  let $description := ''
  let $badge := '' 
  let $toolchain := $item//xhtml:div[@class eq 'tooltip']/xhtml:p[3]/text()
  return
      element model {
         element server {$warehouse},
         element title {$title},
         element description {$description},
         element toolchain {$toolchain},
         element icon {attribute type {'img'}, data($icon)},
         element badge {$badge},
         element author {$author},
         element id {$id},
         element filename {$filename},
         element format {'zip'},
         element info { attribute type {'url'} , concat($warehouse,$info)}
  }
return $response

};

