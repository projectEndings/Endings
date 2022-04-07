### Indexing

staticSearch works by generating an "inverted index" from the tokenized documents; this index is simply a directory full of JSON files on the file system: each unique stemmed term has a JSON file to itself, named for itself ('book.json', 'walk.json', etc.) that contains information about the documents in which that term appears.  This means that when the search page queries the index, it need only retrieve the individual JSON files for the terms which are in the search; the bulk of the index is never retrieved.  

The many JSON files range in size depending, of course, on their frequency within the document collection; in most cases, the individual JSON files are trivially small, but for very common words not included in the stopwords file, they can reach into MBs. However, given that these are texts files and most servers can serve and accept GZIP compression, the files can be highly compressed and thus retrieved almost instantly.     As shown in @statistics, regardless of compression, the JSON index is significantly smaller than the input document collection.

#### Stem Files

Here's an example of the stem file for the term "glow":

```json
{
	"stem": "glow",
	"instances": [
		{
			"docUri": "poems/twilight.html",
			"score": 1,
			"contexts": [
				{
					"form": "glow",
					"weight": "1",
					"pos": 49,
					"context": "Twilight for dreams, the dun and dying <mark>glow</mark>",
					"fid": "l_9"
				}
			]
		}
	]
}
```

This contains an entry for each document which contains the stem, an overall score for that stem in that document, and precise information about each individual instance, including a keyword-in-context extract in which it is marked.

Each stem is created by grouping the entire set of stems by their `@ss-stem` value.

```xml
<xsl:for-each-group select="$stems" group-by="string(@ss-stem)">
  <xsl:variable name="stem" select="current-grouping-key()" as="xs:string"/>
  <xsl:call-template name="makeTokenCounterMsg"/>
  <xsl:variable name="map" as="element(j:map)">
    <xsl:call-template name="makeMap"/>
  </xsl:variable>
  <xsl:result-document href="{$outDir}/stems/{$stem}{$versionString}.json" method="text">
    <xsl:sequence select="xml-to-json($map, map{'indent': $indentJSON})"/>
  </xsl:result-document>
</xsl:for-each-group>
```

The `makeMap` template takes each group of stems and creates the an XML map in the JSON namespace[^02_2_1] for the file:

```xml
 <xsl:template name="makeMap" as="element(j:map)">
        <!--The term we're creating a JSON for, inherited from the createMap template -->
        <xsl:variable name="stem" select="current-grouping-key()" as="xs:string"/>
        <!--The group of all the terms (so all of the spans that have this particular term
            in its @ss-stem -->
        <xsl:variable name="stemGroup" select="current-group()" as="element(span)*"/>
        <!--Create the outermost part of the structure-->
        <map xmlns="http://www.w3.org/2005/xpath-functions">
           <!--The stem is the top level string key for this map; it should be
                the same as the JSON file name.-->
            <string key="stem">
                <xsl:value-of select="$stem"/>
            </string>
             <!--Start instances array: this contains all of the instances of the stem
                 per document -->
            <array key="instances">
                <!--If every HTML document processed has an @id at the root,
                    then use that as the grouping-key; otherwise,
                    use the document uri -->
                <xsl:for-each-group select="$stemGroup"
                    group-by="document-uri(/)">
                    <!--Sort the documents so that the document with the
                    most number of this hit comes first-->
                    <xsl:sort select="count(current-group())" order="descending"/>
                    <!--The current document uri, which functions
                    as the key for grouping the spans-->
                    <xsl:variable name="currDocUri" select="current-grouping-key()" 
                    as="xs:string"/>
                    <!--The spans that are contained within this document-->
                    <xsl:variable name="thisDocSpans" 
                    select="current-group()" as="element(span)*"/>
                    <!--Get the total number of documents 
                    (i.e. the number of iterations that this
                     for-each-group will perform) for this span-->
                    <xsl:variable name="stemDocsCount" select="last()" as="xs:integer"/>
                    <!--The document that we want to process
                    		will always be the ancestor html of
                        any item of the current-group() -->
                    <xsl:variable name="thisDoc"
                        select="current-group()[1]/ancestor::html"
                        as="element(html)"/>
                    <!--Get the raw score of all the spans by getting the weight for 
                        each span and then adding them all together -->
                    <xsl:variable name="rawScore" 
                        select="sum(for $span in $thisDocSpans
                        return hcmc:returnWeight($span))"
                        as="xs:integer"/>
                        
                   <!--Map for each document that has this token-->
                    <map xmlns="http://www.w3.org/2005/xpath-functions">
                        <string key="docId">
                            <xsl:value-of select="$thisDoc/@id"/>
                        </string>
                        <!--And the relative URI from the document, which is to be used
                        for linking from the KWIC to the document. We've created this
                        already in the tokenization stage and stored it in a custom
                        data-attribute-->
                        <string key="docUri">
                            <xsl:value-of select="$thisDoc/@data-staticSearch-relativeUri"/>
                        </string>
                        <!--The document's score, forked depending on configured
                            algorithm -->
                        <number key="score">
                            <xsl:choose>
                                <xsl:when test="$scoringAlgorithm = 'tf-idf'">
                                    <xsl:sequence select="hcmc:returnTfIdf($rawScore, $stemDocsCount, $currDocUri)"/>
                                </xsl:when>
                                <xsl:otherwise>
                                    <xsl:sequence select="$rawScore"/>
                                </xsl:otherwise>
                            </xsl:choose>
                        </number>
                        <!--Now add the contexts array, if specified to do so -->
                        <xsl:if test="$phrasalSearch or $createContexts">
                            <xsl:call-template name="returnContextsArray"/>
                        </xsl:if>
                    </map>
                </xsl:for-each-group>
            </array>
        </map>
    </xsl:template>
```

Each stem files contains precise information about each individual instance in which that stem appears. This is the most onerous part of the process as each context contains the a keyword-in-context string, which shows this word *in situ*. 

This has been difficult to optimize. Our approach so far has been to move up the tree and use node comparison operators (`<<` and `>>`) to compile all of the nodes that precede the span and the nodes that follow and then trim each string to the configured length.

This can still lead to very long strings being stored in memory, however, and so we have tried to optimize by iterating through each node using `<xsl:iterate>` and breaking once a string of the desired length has been found. 

```xml
<xsl:function name="hcmc:returnSnippet" as="xs:string?">
        <xsl:param name="nodes" as="node()*"/>
        <xsl:param name="isStartSnippet" as="xs:boolean"/>
    
        <!--Iterate through the nodes: 
            if we're in the start snippet we want to go from the end to the beginning-->
        <xsl:iterate select="if ($isStartSnippet) then reverse($nodes) else $nodes">
            <xsl:param name="stringSoFar" as="xs:string?"/>
            <xsl:param name="tokenCount" select="0" as="xs:integer"/>
            <!--If the iteration completes, then just return the full string-->
            <xsl:on-completion>
                <xsl:sequence select="$stringSoFar"/>
            </xsl:on-completion>
            <xsl:variable name="thisNode" select="."/>
            <!--Normalize and determine the word count of the text-->
            <xsl:variable name="thisText" select="replace(string($thisNode),'\s+', ' ')" as="xs:string"/>
            <xsl:variable name="tokens" select="tokenize($thisText)" as="xs:string*"/>
            <xsl:variable name="currTokenCount" select="count($tokens)" as="xs:integer"/>
            <xsl:variable name="fullTokenCount" select="$tokenCount + $currTokenCount" as="xs:integer"/>
            
            <xsl:choose>
                <!--If the number of preceding tokens plus the number of current tokens is 
                    less than half of the kwicLimit, then continue on, passing 
                    the new token count and the new string-->
                <xsl:when test="$fullTokenCount lt $kwicLengthHalf + 1">
                    <xsl:next-iteration>
                        <xsl:with-param name="tokenCount" select="$fullTokenCount"/>
                        <!--If we're processing the startSnippet, prepend the current text;
                            otherwise, append the current text-->
                        <xsl:with-param name="stringSoFar" 
                            select="if ($isStartSnippet)
                                    then ($thisText || $stringSoFar) 
                                    else ($stringSoFar || $thisText)"/>
                    </xsl:next-iteration>
                </xsl:when>
                
                <xsl:otherwise>
                    <!--Otherwise, break out of the loop and output the current context string-->
                    <xsl:break>
                        <!--Figure out how many tokens we need to snag from the current text-->
                        <xsl:variable name="tokenDiff" select="1 + $kwicLengthHalf - $tokenCount"/>
                        <xsl:choose>
                            <xsl:when test="$isStartSnippet">
                                <!--We need to see if there's a space before the token we care about:
                                    (there often is, but that is removed when we tokenized above) -->
                                <xsl:variable name="endSpace" 
                                    select="if (matches($thisText,'\s$')) then ' ' else ()"
                                    as="xs:string?"/>
                                <!--Get all of the tokens that we want from the string by:
                                    * Reversing the current token sequence
                                    * Getting the subset of tokens we need to hit the limit
                                    * And then reversing that sequence of tokens again.
                                -->
                                <xsl:variable name="newTokens" 
                                    select="reverse(subsequence(reverse($tokens), 1, $tokenDiff))"
                                    as="xs:string*"/>
                                <!--Return the string: we know we have to add the truncation string here too-->
                                <xsl:sequence 
                                    select="$kwicTruncateString || string-join($newTokens,' ') || $endSpace || $stringSoFar "/>
                            </xsl:when>
                            <xsl:otherwise>
                                <!--Otherwise, we're going left to right, which is simpler
                                    to handle: the same as above, but with no reversing -->
                                <xsl:variable name="startSpace" 
                                    select="if (matches($thisText,'^\s')) then ' ' else ()"
                                    as="xs:string?"/>
                                <xsl:variable name="newTokens" 
                                    select="subsequence($tokens, 1, $tokenDiff)" 
                                    as="xs:string*"/>
                                <xsl:sequence
                                    select="$stringSoFar || $startSpace || string-join($newTokens,' ') || $kwicTruncateString"/>
                            </xsl:otherwise>
                        </xsl:choose>
                    </xsl:break>
                </xsl:otherwise>
            </xsl:choose>
        </xsl:iterate>
    </xsl:function>
```

#### Additional Files

In addition to the stem files, the build process also creates the following individual JSON files:

##### ssTitles.json 

This maps each document's unique identifier (its path relative to the search page) to its title. It may also include an icon with which to identify the document in search results, and an optional sort key to be used instead of its title when search results with the same score are being listed.

##### ssWordString.json

This is a plain-text list of all the individual (unstemmed) words appearing in the collection, separated by pipes:

```text
...|page||pairs||paragraph||part||parts||peep||People||per||percent||percentages||perhaps|...
```

This file is used when processing wildcard searches. When the user enters a wildcard term, it is expanded into a regular expression which is used to extract all of the individual matching words from the word string JSON list. Each of those words is a potential match, so it is stemmed, and its stem file is retrieved. Then a search is made through all the contexts in those files to find matches for the wildcard/regex term in their contexts, so that all actual hits can be found.

For exact phrase (i.e. quoted string) searches, the quoted string is tokenized and the first non-stopword is extracted from it; that word is stemmed, and its stem file retrieved. Then all the contexts in that stem file are searched for an exact match for the phrase.

#### Filter Files

In addition to the text search, the user can trigger the creation of a range of different search filter controls on the search page, by including some HTML meta tags with specific formats in the document. For example, if a document has these three meta tags:

```html
    <meta name="Document type" class="staticSearch_desc" content="Poems"/>
    <meta name="Document type" class="staticSearch_desc" content="Translations"/>
    <meta name="Date of publication" class="staticSearch_date" content="1895-01-05"/>
```

then the containing document will be classified as belonging to two document categories, "Poems" and "Translations," in the "Document type" selection filter (which we refer to as a "description filter"). A second date range filter will also be created. If an end-user searches for documents in either of those categories, using a date-range that includes 1895-01-05, then this document will be selected. Other filter types include boolean, number range, and "feature filters", which provide a typeahead searchable list of keywords. The build process creates a separate JSON file for each of these filters. 

The JSON for a description filter looks like this (heavily truncated example):

```json
{
  "filterId": "ssDesc4",
  "filterName": "Poet’s nationality",
  "ssDesc4_1": {
    "name": "English",
    "docs": 
    	["poems\/p_1095_a_duet.html",
       "poems\/p_1099_the_ox.html"]
  },
  "ssDesc4_2": {
    "name": "Irish",
    "docs": 
    [ "poems\/p_8866_golden_lilies.html",
      "poems\/p_8825_in_a_cathedral.html"]
  }
}
```

When an end-user's search makes use of a filter control, then required filter JSON will also be downloaded along with any stem files needed, but the filter files are also downloaded in the background on page load so that most are already available by the time a user has initiated a search.

When filters are combined with text search, the list of documents containing hits for the text search are first computed, then those hits are filtered based on the filter settings. The small size and innate compressibility of the JSON files enables staticSearch to produce results quite rapidly, even from relatively large document collections.



---

[^02_2_1]: This advantage of using this structure rather than XPath maps and arrays is the ease with which we can construct an array until such time that the proposed XSLT 4.0 array instruction becomes available.
