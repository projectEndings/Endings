### Tokenizing

#### Cleaning and Pre-Processing

What we refer to as the "tokenization" process is a bit of a misnomer: it refers to a single monolithic stylesheet—`tokenize.xsl`—that processes each source document in multiple passes in order to create the minimal HTML structure necessary for generating the index.[^02_2_1] The first stage in the process is to remove irrelevant content, retaining only the information that is necessary for the indexing process and removing ignored elements, unnecessary wrappers, and most attributes. In most cases, input documents will contain a significant amount of boilerplate HTML that appears on every page and should be completely ignored by the indexer, like the site menu, sidebar, or footer. As the example above shows, these elements are given a weight of 0, which means they are removed from the tokenized document. The tokenization process also removes elements that will have no bearing on the indexing process; this includes most inline elements, like links, spans, etc, unless these elements must be retained for a specific reason (i.e. they are assigned a higher weight or they contain a fragment identifier, which can be linked from the search results). 

Often, a well-configured instance of staticSearch will produce tokenized documents that are significantly smaller than the original. For example, consider this line from a poem in the *Digital Victorian Periodical Poetry Project*:

```html
 <div class="l" data-el="l" id="l_1"><span class="lineContent"><span data-el="hi" class="hi" style="font-variant: small-caps; letter-spacing: 0.06em;">A blush</span>, a smile, a dusk sweet vio<span class="rhyme label_a" data-el="rhyme" title="Masculine rhyme (Final syllable rhymes exactly; for example, Keats/beets.); label: a">let</span>—</span><span class="lineNum">1</span></div>
```

After being run through the tokenizer, all classes, data attributes, superfluous wrapping elements, and other information irrelevant to the indexer are removed:

```html
<div id="l_1" ss-ctx="true">A <span ss-pos="3" ss-fid="l_1" ss-stem="blush">blush</span>, a <span ss-pos="4" ss-fid="l_1" ss-stem="smile">smile</span>, a <span ss-pos="5" ss-fid="l_1" ss-stem="dusk">dusk</span> <span ss-pos="6" ss-fid="l_1" ss-stem="sweet">sweet</span> <span ss-pos="7" ss-fid="l_1" ss-stem="violet">violet</span>—</div>
```

#### Stemming

The second process is, of course, tokenization. The tokenization stage wraps each token in a span element and decorates the element with the token's stem, position, weight, et cetera. Each meaningful text node is matched and analyzed using `<xsl:analyze-string>` to identify each "word" where a "word" is understood as:

* A number `[\d]+([\.,]?\d+)`
* An alphanumeric word `[\p{L}\p{M}]+`
* A hyphenated word: `$alphanumeric(-$alphanumeric)*)`

We also consider apostrophes and quotation marks (both "straight" and "curly") as part of a word, so the constructed Regular Expression is slightly more complicated when expressed in the XSLT:

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

If a word is indeed a word and is neither too short nor a stopword, it is then run through the user-configured XSLT stemmer. At the moment, staticSearch has four different stemmers: the Porter stemming algorithms for English and French (@Porter1980; @Porter2002; @PorterFrench) ; an "identity" stemmer; and a diacritic stemmer, which simply strips diacritics and is otherwise idempotent.[^02_3_1] Users can specify their own stemmers, but, at the moment, the stemmers need to be implemented identically in both XSLT and JavaScript. We are currently exploring options for integrating existing implementations of Porter's stemming algorithms in Java and JavaScript (for Saxon and the browser, respectively).

---



[^02_3_1]: While the "identity" stemmer is not necessarily ideal, it does vastly simplify the creation of a search engine for multi-lingual documents and document collections. It also provides a convenient starting point for users who might want to implement their own stemmers.

[^02_2_1]: @Quin2008 discusses possible solutions for full-text querying of XML with lq-text and notes that, while tedious, "a pragmatic approach is to re-write documents before indexing them, perhaps with XSLT." While we were not aware of Quin's extensions to lq-text hitherto working on staticSearch, the approach described in many ways pre-figures and anticipates our own.
