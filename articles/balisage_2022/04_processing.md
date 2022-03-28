## Details about Processing

staticSearch is a complete search indexer and retrieval engine for collections of HTML documents and is comprised of two distinct, albeit interdependent, processes: an indexer of collections of HTML documents and a client-side JavaScript library for parsing queries and retrieving search results. [[ THIS SHOULD GO IN 02 ]]

### Configuration File

The structure and syntax of the configuration file is defined by staticSearch's custom schema (expressed as a TEI ODD) and provides specific options for the staticSearch build process. 

At its most basic, the staticSearch build process is comprised of three XSLT 3 transformations. First, an XSLT stylesheet transforms the user-supplied configuration file into an XSLT stylesheet, which is then included in all subsequent steps. It is necessary to convert the configuration file into its own XSLT as the configuration file relies on XPath match statements [CITE] to assign weights to components of the HTML files. For example, elements can be assigned  "weights"[^1: "Weight" here is a slightly misleading term; most discussions of search engines refer to what we call "weight" as "boost" where what we call "score" is usually framed as "weight"]  via the `<rule>` element in the configuration file:

```
<rule match="header" weight="3"/>
<rule match="menu | aside | footer" weight="0"/>
```

The `@weight` attribute above signals the multiplier that should be applied to each instance of that element within a document when computing a term's score. We make some assumptions about specific weighting of elements (all heading-like elements `<h1>` etc are given a weight of 2; here a weight of 0 means that the indexer should ignore the element entirely).

The rule element (and other elements that bear a `@match`) are converted into `<xsl:template>`s that are run during the multi-phase tokenization process. 

### Tokenization

What we refer to as the "tokenization" process is a single monolithic stylesheet—`tokenize.xsl`—that processes the document in multiple passes in order to create the minimal HTML structure for generating the inverted index.

The process creates a text patternset that is loaded by the XSLT task that takes the input fileset and maps it to its tokenized equivalent:

```xml
<xslt style="${ssBaseDir}/xsl/tokenize.xsl"
      classpath="${ssSaxon}" 
      destdir="${staticSearchTempDir}"
      reloadstylesheet="true" 
      force="true"
      useimplicitfileset="false">
      <factory name="net.sf.saxon.TransformerFactoryImpl"/>
      <fileset id="siteFiles" dir="${ssCollectionDirName}" casesensitive="no">
        <includesfile name="${ssPatternsetFile}"/>
        <!--Exclude the temporary directory's basename-->
        <exclude name="**/${staticSearchTempFolder}/**"/>
      </fileset>
      <regexpmapper from="^(.*)\.([^\.]+$)" to="\1_tokenized.html"/>
</xslt>
```

Earlier versions of staticSearch iterated through the document collection using `collection()` ; while this was the most straightforward method, it required significant memory use for large collections and proved unsustainable.

[[[ More details here about tokenization stage ]]

### Indexing



These JSON files are created by grouping all of the stems.  XSLT 3's built-in handling of maps and arrays allows for simple construction of these files. [[ Show some code fragment]]]



### Search Page









