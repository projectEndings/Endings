## What is staticSearch?

Broadly, staticSearch works by first taking in a user supplied XML configuration file that tells the staticSearch build process where to find the documents and the search page and sets various options such as the number and length of keyword-in-context fragments to harvest for each stem. It then runs the build process as follows:

1. Checks and validates the input document collection.

1. Checks the user's configuration file, and if it is valid, uses it to build an XSLT configuration file for the remaining processes.

1. Processes all documents in the collection to create versions in which stemmed tokens are tagged, and each tagged token has additional information about its context (more on this later). Each document is given an identifier consisting of its path relative to the search page.

1. Uses the tokenized texts to build a collection of JSON files which are used to power the search.

1. Creates the search page itself.

1. Creates a report on the process.

   

![The staticSearch build process](/Users/takeda/projects/Endings/articles/balisage_2022/images/staticSearch_process_01.svg "The staticSearch build Process"){width=80%}



There is one stipulation: the input document collection must consist of well-formed HTML5 in the XHTML namespace. Well-formedness is essential because we use Saxon to process the collection; the XHTML namespace arises purely out of our own prejudice. That staticSearch uses and produces HTML, however, is an infrastructural feature. While extending staticSearch to other namespaces and to other XML dialects in general is certainly feasible and, in fact, our HTML documents are frequently derived from TEI XML encoed documents, it is difficult, in our minds, to imagine case where indexing and tokenizing  non-HTML files would be more effective. Since the search is meant to power a web application, users of the search are looking for information that they can find in the mass of HTML files, not the source documents from which they are produced. Our index, in other words, reflects the documents that are available in the collection and thus search results can be easily linked to the places in the source document which a term appears.  

We will now discuss the technical implementation in further detail.  

