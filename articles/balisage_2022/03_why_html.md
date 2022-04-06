## Why only XHTML?

There is one stipulation: the input document collection must consist of well-formed HTML5 in the XHTML namespace. Well-formedness is essential because we use Saxon to process the collection; the XHTML namespace arises purely out of our own prejudice. One of the documents must be a page which will be converted into the search page; this can take any form as long as it contains a single <code>&lt;div&gt;</code> element with the id "staticSearch".



