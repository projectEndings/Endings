## Limitations and Future Work

There are some cases where staticSearch fails to index the entirety of a document collection due to the lack of memory available to Ant. 

While the tokenization stage decorates each element with its stem, position, weight, et cetera, it only retains the information that is necessary for the indexing process, removing ignored elements, unnecessary wrappers, and most attributes. In most cases, a well-configured instance of staticSearch will produce tokenized documents that are significantly smaller than the original. For instance, here is the 

```html
 <div class="l" data-el="l" id="l_1"><span class="lineContent"><span data-el="hi" class="hi" style="font-variant: small-caps; letter-spacing: 0.06em;">A blush</span>, a smile, a dusk sweet vio<span class="rhyme label_a" data-el="rhyme" title="Masculine rhyme (Final syllable rhymes exactly; for example, Keats/beets.); label: a">let</span>—</span><span class="lineNum">1</span></div>
```

```html
<div id="l_1" ss-ctx="true">A <span ss-pos="3" ss-fid="l_1" ss-stem="blush">blush</span>, a <span ss-pos="4" ss-fid="l_1" ss-stem="smile">smile</span>, a <span ss-pos="5" ss-fid="l_1" ss-stem="dusk">dusk</span> <span ss-pos="6" ss-fid="l_1" ss-stem="sweet">sweet</span> <span ss-pos="7" ss-fid="l_1" ss-stem="violet">violet</span>—</div>
```

Since staticSearch was born out of our own projects in active development, it currently only contains four stemmers: an implemention of Porter's stemming algorithm for each English and French; an  idempotent or "identity" stemmer, and a diacritic stemmer, which simply strips diacritics [[implementation detail]] but is otherwise idempotent. While the "identity" stemmer is not necessarily ideal, it does vastly simplify the creation of a search engine for multi-lingual documents and document collections.  

While ideally we could adopt existing implementations of stemming algorithms, the current infrastructure of staticSearch would require creating  identical implementations in both XSLT and JavaScript. While SaxonJS has now made running XSLT in the browser possible, the reverse is tricky and precisely what we would need to do given that  readily available implementations of stemmers in JavaScript far outweigh that of XSLT. 

## Future Work

Future work for staticSearch is tracked on the project's GitHub repository: https://github.com/projectEndings/staticSearch/issues. 

