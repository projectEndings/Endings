# How staticSearch works

staticSearch has two main features:

1. A stemming text-search engine with wildcard and keyword-in-context support
1. A range of filter types to constrain search results based on document type, date, and so on.

There is one stipulation: the input document collection must consist of well-formed HTML5 in the XHTML namespace. Well-formedness is essential because we use Saxon to process the collection; the XHTML namespace arises purely out of our own prejudice. One of the documents must be a page which will be converted into the search page; this can take any form as long as it contains a single <code>&lt;div&gt;</code> element with the id "staticSearch".

The user supplies an XML configuration file which tells the staticSearch build process where to find the documents and the search page, and allows you to set various options such as the number and length of keyword-in-context fragments to harvest for each stem. They may also choose to insert specially-crafted HTML meta tags into the headers of their documents to enable staticSearch to create a range of different filter controls on the search page.

The build process, shown in the diagram below, runs the following steps:

1. Checks and validates the input document collection.
1. Checks the user's configuration file, and if it is valid, uses it to build an XSLT configuration file for the remaining processes.
1. Processes all documents in the collection to create versions in which tokens are tagged, and each tagged token has additional information about its context (more on this later).
1. Uses the tokenized texts to build a collection of JSON files which are used to power the search.
1. Creates the search page itself.
1. Creates a report on the process.



