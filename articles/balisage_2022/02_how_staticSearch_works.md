# How staticSearch works

staticSearch has two main features:

1. A stemming text-search engine with wildcard and keyword-in-context support
1. A range of filter types to constrain search results based on document type, date, and so on.

There is one stipulation: the input document collection must consist of well-formed HTML5 in the XHTML namespace. Well-formedness is essential because we use Saxon to process the collection; the XHTML namespace arises purely out of our own prejudice. One of the documents must be a page which will be converted into the search page; this can take any form as long as it contains a single <div> element with the id "staticSearch".

You supply an XML configuration file which tells the staticSearch build process where to find the documents and the search page, and allows you to set various options such as the number and length of keyword-in-context fragments to harvest for each stem.

The build process, shown in the diagram below, runs the following steps:

1. 

