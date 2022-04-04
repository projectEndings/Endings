## Limitations and Future Work

Since staticSearch was born out of our own projects in active development, it currently only contains four stemmers: implementions of Porter's stemming algorithms for English and French; an idempotent or "identity" stemmer; and a diacritic stemmer, which simply strips diacritics [[implementation detail]] but is otherwise idempotent. While the "identity" stemmer is not necessarily ideal, it does vastly simplify the creation of a search engine for multi-lingual documents and document collections.  

While ideally we could adopt existing implementations of stemming algorithms, the current infrastructure of staticSearch would require creating  identical implementations in both XSLT and JavaScript. While SaxonJS has now made running XSLT in the browser possible, the reverse is tricky and precisely what we would need to do given that  readily available implementations of stemmers in JavaScript far outweigh that of XSLT. 

## Future Work

Future work for staticSearch is tracked on the project's GitHub repository: https://github.com/projectEndings/staticSearch/issues. 

