(: front-end for google warehouse :)
xquery version "1.0";

module namespace ourbricks="http://rest3d.org/ourbricks";

declare namespace xhtml="http://www.w3.org/1999/xhtml";

import module namespace rest3d="http://rest3d.org" at "rest3d.xqm";

(: 
http://ourbricks.com/?q=duck/
:)

declare function ourbricks:search($q as xs:string, $max-pages as xs:integer)
{
let $warehouse := 'http://ourbricks.com'
let $api := '/'

let $results-per-pages := xs:string(12 * $max-pages)
let $params := concat('q=',$q)
let $params := rest3d:to-form($params)
let $results := httpclient:get(xs:anyURI(concat($warehouse,$api,'?',$params)),false(),()) 
(: here we should check if there are any results :)

(: now parse the html pages to create response :)
let $response := 
  for $item in $results//xhtml:div[@class eq 'item']
  let $price := ''
  let $icon := data($item//xhtml:div[@class eq 'thumbnail_block']//xhtml:img/@src)
  let $url := data($item//xhtml:div[@class eq 'thumbnail_block']/xhtml:a/@href)
  let $id := replace($url,'/viewer/(.*?)','$1')
  let $filename := ''
  let $description := data($item//xhtml:div[@class eq 'description'])
  let $info := data($item//xhtml:div[@class eq 'metadata_block']//xhtml:a[@class eq 'titlelink']/@href)
  let $title := data($item//xhtml:div[@class eq 'edittitle'])
  let $author := data($item//xhtml:a[@class eq 'author'])
  let $badge := ''
  let $license :=  data($item//xhtml:div[contains(@id,'license_')])
  let $toolchain := ''
  let $download := ''
  let $viewer := concat('http://vu.ourbricks.com/em.html?v=:',$id)
  return(
      element model {
         element server {$warehouse},
         element title {$title},
         element license {$license},
         element description {$description},
         element toolchain {$toolchain},
         element icon {attribute type {'img'}, data($icon)},
         element badge {$badge},
         element author {$author},
         element id {$id},
         element filename {$filename},
         element format {'zip'},
         element download {attribute type {'url'}, $download},
         element info { attribute type {'url'} , concat($warehouse,$info)},
         element viewer { attribute type {'url'}, $viewer},
         element copy {attribute type {'url'}, concat('copy.xml?server=ourbricks&amp;id=',$id,'&amp;download=',$download)}
  })
return $response

};

