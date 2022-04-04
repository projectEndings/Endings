## How Static Search Works

### Configuration File

At its most basic, the staticSearch build process is comprised of three XSLT 3 transformations. First, an XSLT stylesheet transforms the user-supplied configuration file into an XSLT stylesheet, which is then included in all subsequent steps. It is necessary to convert the configuration file into its own XSLT as the configuration file relies on XPath match statements to assign weights to components of the HTML files. For example, elements can be assigned  "weights"[^1: "Weight" here is a slightly misleading term; most discussions of search engines refer to what we call "weight" as "boost" where what we call "score" is usually framed as "weight"]  via the `<rule>` element in the configuration file:

```
<rule match="header" weight="3"/>
<rule match="menu | aside | footer" weight="0"/>
```

The `@weight` attribute above signals the multiplier that should be applied to each instance of that element within a document when computing a term's score. We make some assumptions about specific weighting of elements (all heading-like elements `<h1>` etc are given a weight of 2; here a weight of 0 means that the indexer should ignore the element entirely).

The rule element (and other elements that bear a `@match`) are converted into `<xsl:template>`s that are run during the multi-phase tokenization process. 

### Tokenization

What we refer to as the "tokenization" process is a bit of a misnomer: it refers to a single monolithic stylesheet—`tokenize.xsl`—that processes each source document in multiple passes in order to create the minimal HTML structure necessary for generating the index. While the tokenization stage decorates each element with its stem, position, weight, et cetera, it only retains the information that is necessary for the indexing process, removing ignored elements, unnecessary wrappers, and most attributes. In most cases, input documents will contain a significant amount of HTML that appear on every page and should be completely ignored by the indexer, like the site menu, sidebar, or footer. As the example above shows, these elements are given a weight of 0, which means they are removed from the document. The tokenization process also removes elements that will have no bearing on the indexing process; this includes most inline elements, like links, spans, etc, unless these elements must be retained for a specific reason (i.e. they are assigned a higher weight or they contain a fragment identifier, which can be linked from the search results). 

Often, a well-configured instance of staticSearch will produce tokenized documents that are significantly smaller than the original. For example, consider this line from a poem in the Digital Victorian Periodical Poetry Project:

```html
 <div class="l" data-el="l" id="l_1"><span class="lineContent"><span data-el="hi" class="hi" style="font-variant: small-caps; letter-spacing: 0.06em;">A blush</span>, a smile, a dusk sweet vio<span class="rhyme label_a" data-el="rhyme" title="Masculine rhyme (Final syllable rhymes exactly; for example, Keats/beets.); label: a">let</span>—</span><span class="lineNum">1</span></div>
```

After being run through the tokenizer, all classes, data attributes, and other information irrelevant to the indexer is removed:

```html
<div id="l_1" ss-ctx="true">A <span ss-pos="3" ss-fid="l_1" ss-stem="blush">blush</span>, a <span ss-pos="4" ss-fid="l_1" ss-stem="smile">smile</span>, a <span ss-pos="5" ss-fid="l_1" ss-stem="dusk">dusk</span> <span ss-pos="6" ss-fid="l_1" ss-stem="sweet">sweet</span> <span ss-pos="7" ss-fid="l_1" ss-stem="violet">violet</span>—</div>
```

The second process is, of course, the tokenize, which occurs once we have the smallest possible document. Each meaningful text node is matched and analyzed using `<xsl:analyze-string>` to identify each "word" where a "word" is understood as:

* A number `[\d]+([\.,]?\d+)`
* An alphanumeric word `[\p{L}\p{M}]+`
* A hyphenated word: `$alphanumeric(-$alphanumeric)*)`

We also consider apostrophes (single and double) as part of a word, so the constructed Regular Expression is slightly more complicated when expressed in the XSLT:

```xml
 <xsl:variable name="numericWithDecimal">[<xsl:value-of select="string-join($allApos,'')"/>\d]+([\.,]?\d+)</xsl:variable>
 <xsl:variable name="alphanumeric">[\p{L}\p{M}<xsl:value-of select="string-join($allApos,'')"/>]+</xsl:variable>
 <xsl:variable name="hyphenatedWord">(<xsl:value-of select="$alphanumeric"/>-<xsl:value-of select="$alphanumeric"/>(-<xsl:value-of select="$alphanumeric"/>)*)</xsl:variable>
<xsl:variable name="tokenRegex">(<xsl:value-of select="string-join(($numericWithDecimal,$hyphenatedWord,$alphanumeric),'|')"/>)</xsl:variable>
```

Which yields the the following:

```text
(['‘’”“"\d]+([\.,]?\d+)|([\p{L}\p{M}'‘’”“"]+-[\p{L}\p{M}'‘’”“"]+(-[\p{L}\p{M}'‘’”“"]+)*)|[\p{L}\p{M}'‘’”“"]+)
```



If a word is indeed a word and is neither too short nor a stopword, it is then run through the user-configured XSLT stemmer. At the moment, staticSearch comes packaged with an [[]]. The full implementation of Porter 2 can be found in the repository: [[]])



### Indexing

From the tokenized document collection, we can now build a rich index of the terms and metadata in the documents that is fragmented across a huge collection of individual files; each unique stemmed term has a JSON file to itself, named for itself ('book.json', 'walk.json', etc.), which are referred to as the "stem files". This means that when the search page queries the index, it need only retrieve the individual JSON files for the terms which are in the search; the bulk of the index is never retrieved. A stem file looks like this:

![An example stem file](/Users/takeda/projects/Endings/articles/balisage_2022/images/stem_file.png "An example stem file"){width=80%}

This contains an entry for each document which contains the stem, an overall score for that stem in that document, and precise information about each individual instance, including a keyword-in-context extract in which it is marked.

1. This requires taking the entire document collection and grouping each token, which takes a significant amount of memory
2. Of all of the technical problems, the KWIC creation is trickiest

In addition to the stem files, the build process also creates the following individual JSON files:

ssTitles.json 
This maps each document's unique identifier (its path relative to the search page) to its title. It may also include an icon with which to identify the document in search results, and an optional sort key to be used instead of its title when search results with the same score are being listed.

ssWordString.json
This is a plain-text list of all the individual (unstemmed) words appearing in the collection, separated by pipes:

```text
...|page||pairs||paragraph||part||parts||peep||People||per||percent||percentages||perhaps|...
```

This file is used when processing wildcard searches. When the user enters a wildcard term, it is expanded into a regular expression which is used to extract all of the individual matching words from the word string JSON list. Each of those words is a potential match, so it is stemmed, and its stem file is retrieved. Then a search is made through all the contexts in those files to find matches for the wildcard/regex term in their contexts, so that all actual hits can be found.

For exact phrase (i.e. quoted string) searches, the quoted string is tokenized and the first non-stopword is extracted from it; that word is stemmed, and its stem file retrieved. Then all the contexts in that stem file are searched for an exact match for the phrase.

### The search filters

In addition to the text search, the user can trigger the creation of a range of different search filter controls on the search page, by including some HTML meta tags with specific formats in the document. For example, if a document has these three meta tags:

```html
    <meta name="Document type" class="staticSearch_desc" content="Poems"/>
    <meta name="Document type" class="staticSearch_desc" content="Translations"/>
    <meta name="Date of publication" class="staticSearch_date" content="1895-01-05"/>
```

then the containing document will be classified as belonging to two document categories, "Poems" and "Translations", in the "Document type" selection filter (which we refer to as a "description filter"). A second date range filter will also be created. If an end-user searches for documents in either of those categories, using a date-range that includes 1895-01-05, then this document will be selected. Other filter types include boolean, number range, and "feature filters", which provide a typeahead searchable list of keywords. The build process creates a separate JSON file for each of these filters. The JSON for a description filter looks like this (heavily truncated example):

![An example filter file](/Users/takeda/projects/Endings/articles/balisage_2022/images/desc_filter_json.png "An example, heavily truncated, description filter file"){width=80%}

When an end-user's search makes use of a filter control, then required filter JSON will also be downloaded along with any stem files needed, but the filter files are also downloaded in the background on page load so that most are already available by the time a user has initiated a search.

When filters are combined with text search, the list of documents containing hits for the text search are first computed, then those hits are filtered based on the filter settings. The small size and innate compressibility of the JSON files enables staticSearch to produce results quite rapidly, even from relatively large document collections.

