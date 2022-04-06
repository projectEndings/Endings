## What is staticSearch?

Broadly, staticSearch works by first taking in a user supplied XML configuration file that tells the staticSearch build process where to find the documents and the search page and sets various options such as the number and length of keyword-in-context fragments to harvest for each stem. It then runs the build process as follows:

1. Checks and validates the input document collection.

1. Checks the user's configuration file, and if it is valid, uses it to build an XSLT configuration file for the remaining processes.

1. Processes all documents in the collection to create versions in which stemmed tokens are tagged, and each tagged token has additional information about its context (more on this later). Each document is given an identifier consisting of its path relative to the search page.

1. Uses the tokenized texts to build a collection of JSON files which are used to power the search.

1. Creates the search page itself.

1. Creates a report on the process.

   

![The staticSearch build process](/Users/takeda/projects/Endings/articles/balisage_2022/images/staticSearch_process_01.svg "The staticSearch build Process"){width=80%}



### Configuration

First, an XSLT stylesheet transforms the user-supplied configuration file into an XSLT stylesheet, which is then included in all subsequent steps. It is necessary to convert the configuration file into its own XSLT as the configuration file relies on XPath match statements to assign weights to components of the HTML files. For example, elements can be assigned  "weights"[^1: "Weight" here is a slightly misleading term; most discussions of search engines refer to what we call "weight" as "boost" where what we call "score" is usually framed as "weight"]  via the `<rule>` element in the configuration file:

```
<rule match="header" weight="3"/>
<rule match="menu | aside | footer" weight="0"/>
```

The `@weight` attribute above signals the multiplier that should be applied to each instance of that element within a document when computing a term's score. We make some assumptions about specific weighting of elements (all heading-like elements `<h1>` etc are given a weight of 2; here a weight of 0 means that the indexer should ignore the element entirely).

The rule element (and other elements that bear a `@match`) are converted into `<xsl:template>`s that are run during the multi-phase tokenization process. 
