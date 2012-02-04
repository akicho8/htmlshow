$ ->
  $(document).keypress (e) ->
    if e.charCode == "I".charCodeAt(0)
      location.href = $(".__hs_paginate a.index:first").prop("href")
    if e.charCode == "N".charCodeAt(0)
      location.href = $(".__hs_paginate a.next:first").prop("href")
    if e.charCode == "P".charCodeAt(0)
      location.href = $(".__hs_paginate a.prev:first").prop("href")
    true
