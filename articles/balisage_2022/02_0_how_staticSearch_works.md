## What is staticSearch?

Broadly, staticSearch works by first taking in a user supplied XML configuration file that tells the staticSearch build process where to find the documents and the search page and sets various options such as the number and length of keyword-in-context fragments to harvest for each stem. It then runs the build process as follows:

1. Checks and validates the input document collection.

1. Checks the user's configuration file, and if it is valid, uses it to build an XSLT configuration file for the remaining processes.

1. Processes all documents in the collection to create versions in which stemmed tokens are tagged, and each tagged token has additional information about its context (more on this later). Each document is given an identifier consisting of its path relative to the search page.

1. Uses the tokenized texts to build a collection of JSON files which are used to power the search.

1. Creates the search page itself.

1. Creates a report on the process.

   

![The staticSearch build process](/Users/takeda/projects/Endings/articles/balisage_2022/images/staticSearch_process_01.svg "The staticSearch build Process"){width=80%}



There is one stipulation: the input document collection must consist of well-formed HTML5 in the XHTML namespace. Well-formedness is essential because we use Saxon to process the collection; the XHTML namespace arises purely out of our own prejudice. 

While extending staticSearch to other namespaces would certainly be feasible, but it is difficult, in our minds, to imagine case where indexing and tokenizing the source files would be more effective than the produced documents. Since the search is meant to power a web application, users of the search are looking for information that they can find in the mass of HTML files, not the source documents from which they are produced. Our index, in other words, reflects the documents that are available in the collection and thus search results can be easily linked to the places in the source document which a term appears.    

### Configuration

The structure and syntax of the configuration file is defined by staticSearch's custom schema (expressed as a TEI ODD) and provides specific options for the staticSearch build process. A basic configuration file looks something like this:

```xml
<config xmlns="http://hcmc.uvic.ca/ns/staticSearch" version="2">
    <params>
        <searchFile>test/search.html</searchFile>
        <versionFile>test/VERSION</versionFile>
        <recurse>true</recurse>
        <phrasalSearch>true</phrasalSearch>
        <wildcardSearch>true</wildcardSearch>
        <createContexts>true</createContexts>
        <resultsPerPage>5</resultsPerPage>
        <minWordLength>2</minWordLength>
        <maxKwicsToHarvest>5</maxKwicsToHarvest>
        <maxKwicsToShow>5</maxKwicsToShow>
        <totalKwicLength>15</totalKwicLength>
        <kwicTruncateString>...</kwicTruncateString>
        <stopwordsFile>test/test_stopwords.txt</stopwordsFile>
        <dictionaryFile>xsl/english_words.txt</dictionaryFile>
        <outputFolder>ssTest</outputFolder>
    </params>
    <rules>
        <rule weight="2"
            match="h1 | h2"/>
        <rule weight="0"
            match="span[@class='lineNum']"/>
        <rule weight="0"
            match="script | style"/>
        <rule weight="0"
            match="header | footer"/>
    </rules>
    <contexts>
        <context match="blockquote" label="Quotations"/>
        <context match="div[@class='l']"/>
        <context match="span[@class='note'] | *[contains-token(@class,'sidenotes')]"
            label="Notes"/>
        <context match="cite" label="Citations"/>
        <context match="p[contains-token(@class,'citation')]" label="Citations"/>
    </contexts>
    <excludes>
        <exclude type="index" match="html[@id='excluded']"/>
        <exclude match="meta[contains-token(@class,'excludedMeta')]" type="filter"/>
    </excludes>
</config>
```

There are many interesting configuration options that are beyond the scope of this paper, but full documentation of each option is available on the project's website and the GitHub repository. The crucial parameter here is the `<searchFile>`. `<searchFile>` contains the path (relative to the configuration file) for the page in the collection that will be populated with the search form and controls for filters.  This page may or may not already exist. If that page exists, then it must contain an HTML block element (`<div>`, `<section>`, etc) with the id "staticSearch"; if that page does not exist, then the page is created during the build process. The `<searchFile>` parameter also gives the location of the collection to index; in the above case, staticSearch will index all of the HTML files in the `test/` directory. 

This configuration file is transformed into an XSLT stylesheet that is included in all subsequent steps of the build process. It is necessary to convert the configuration file into its own XSLT as some configuration options, like weighitng rules and context specifications, rely on XPath match statements. For example, elements can be assigned  "weights"[^1: "Weight" here is a slightly misleading term; most discussions of search engines refer to what we call "weight" as "boost" where what we call "score" is usually framed as "weight"]  via the `<rule>` element in the configuration file:

```
<rule match="header" weight="3"/>
<rule match="menu | aside | footer" weight="0"/>
```

The `@weight` attribute above signals the multiplier that should be applied to each instance of that element within a document when computing a term's score. We make some assumptions about specific weighting of elements (all heading-like elements `<h1>` etc are given a weight of 2; here a weight of 0 means that the indexer should ignore the element entirely).

The rule element (and other elements that bear a `@match`) are converted into `<xsl:template>`s that are run during the multi-phase tokenization process. 
