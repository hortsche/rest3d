xquery version "1.0";

module namespace functx="http://www.functx.com";

declare function functx:day-of-week($date as xs:anyAtomicType?) as xs:integer? {

  if (empty($date))
  then ()
  else (
    let    $gmt-date := adjust-date-to-timezone(xs:date($date), xs:dayTimeDuration("PT0H")),
           $days-since-baseline := ($gmt-date - xs:date('1901-01-06+00:00')) div xs:dayTimeDuration('P1D')
    return $days-since-baseline mod 7
  )

};

declare function functx:day-of-week-name-en($date as xs:anyAtomicType?) as xs:string? {

  ('Sunday', 'Monday', 'Tuesday', 'Wednesday', 'Thursday', 'Friday', 'Saturday')
    [functx:day-of-week($date) + 1]

};

declare function functx:day-of-week-abbrev-en($date as xs:anyAtomicType?) as xs:string? {

  ('Sun', 'Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat')
    [functx:day-of-week($date) + 1]

};

declare function functx:month-name-en($arg as xs:anyAtomicType?) as xs:string? {

  let    $date := xs:date($arg)
  return ('January', 'February', 'March', 'April', 'May', 'June', 'July', 'August', 'September', 'October', 'November', 'December')
           [month-from-date($date)]

};

declare function functx:month-abbrev-en($arg as xs:anyAtomicType?) as xs:string? {

  let    $date := xs:date($arg)
  return ('Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun', 'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec')
           [month-from-date($date)]

};

declare function functx:index-of-string($arg as xs:string?, $substring as xs:string) as xs:integer* {

  if   (contains($arg, $substring))
  then (string-length(substring-before($arg, $substring)) + 1,
        for $other in functx:index-of-string(substring-after($arg, $substring), $substring)
        return
          $other +
          string-length(substring-before($arg, $substring)) +
          string-length($substring))
  else ()

};

declare function functx:index-of-string-last($arg as xs:string?, $substring as xs:string) as xs:integer? {
  functx:index-of-string($arg, $substring)[last()]
};

declare function functx:pad-string-to-length($stringToPad as xs:string?, $padChar as xs:string, $length as xs:integer) as xs:string {

   substring(
     string-join(
       ($stringToPad, for $i in (1 to $length) return $padChar),
       ''),
     1,
     $length)

};

declare function functx:resolve-file-uri($resource-path as xs:string) as xs:anyURI {

  let    $adjusted-resource-path := replace($resource-path, "\\", "/"),
         $encoded-path-elements :=
           for    $resource-path-element at $index in tokenize($adjusted-resource-path, "/")
           return if ($index = 1)
                  then $resource-path-element
                  else xmldb:encode($resource-path-element)
  return xs:anyURI(concat("file:///", string-join($encoded-path-elements, "/")))

};