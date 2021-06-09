## 6. The Lingering Problem: Search



With these Principles in place, we were able to convert the dormant projects, like The Robert Graves Diary, and the on-going projects, like *The Map of Early Modern London*, from unwieldy eXist applications into a large bundle of static HTML, CSS, and JS. Our goal for these static incarnations was that they looked and functioned identically to the live application and, as these sites were steadily released and tested, we were happy to find that doing so was not only feasible, but significantly improved the projects. Our staticization of Graves, for instance, surfaced various encoding errors that had gone unnoticed for many years, which we could now easily diagnose and fix. And in moving from a dynamic application to the static site, we had the opportunity to re-write the codebase from scratch, removing the layers of dead-code that had sedimented within the codebase over its long history of updates and maintenance and modernizing the CSS and JavaScript. Projects in active development benefitted similarly; not only did these re-writes provide a good opportunity to scrutinize the project, lopping off code that was either irrelelvant or, in retrospect, decidely unnecessary.  Thanks to our Jenkins server, any development on the project, either to the source data or the processing, we no longer needed to hold our breath when a new document needed to be updated nor anxiously click around the site to confirm that we hadn't broken the site entirely: any encoder could simply commit, wait a few minutes, and, so long as the Jenkins server didn't send its "BUILD FAILED" message, then  proof their changes in the context of the site. 

<!--Image of the "old" graves homepage, maybe?-->

But these sites all lacked a significant and crucial part of their functionality: search. Most digital editions require some form of text-based searching and, in many cases, the ability to search across a large and disparate document collection and aggregate documents based on multiple metrics is the project's raison d'être. Search was, in other words, non-negotiable—we could not sacrifice the robust search mechanisms on the existing site. We could quietly ignore search in projects where search functionality was peripheral to other modes of discovery and aggregation; these projects, like *The Map Of Early Modern London*, had the now ubiquitous search bar in the top right-hand corner and, if an internal member of the project team tried to use the search either locally or in Jenkins, the page simply told them they couldn't. But once again, Graves forced us to come up with a real solution: the homepage for the project was essential one large, faceted search page, which we were able to replicate perfectly using CSS and JavaScript, but since searching was handled entirely by eXist, the static version was rendered completely inert. 

We had conceded that the kinds of search our projects required—complex faceting and filters, wildcards, and exact phrase queries split across multiple, collection specific search pages—was necessarily the stuff of servers and could not be made static. While there were some solutions available, they were  ill-equiped to handle the thousands of documents, millions of words, and complex metadata structures that comprise a standard digital edition. Outsourcing indexing to an external service, like ElastiSearch, was out of the question as it would violate the core Endings principles and client-side Javascript search engines, like Lunr, while suitable for smaller projects, could not cope with the amount of data that comprise fairly even small digital editions. 

Our intermediate solution was to stick with what we knew: package the static sites into a XAR bundle and spin up a simple eXist instance whose only job would be to index, query, and retrieve the search results from the static HTML pages. Of course, this worked perfectly and we released the first version of a number of our static sites following this approach. It was a suitable compromise, not a particularly satisfying solution, representing the kinds of fragility—where core functionality depended on a single server-side dependency—that we had sought to correct in the Endings project. We had gone through the trouble of re-writing these sites in their entirety to remove their dependency on eXist and had trumpeted our success with building completely static, serverless websites, and now here we were, returning to eXist, hat in hand. 

If we were to to return to eXist, we reckoned, then we should at least try to improve the situation and, in the spirit of LOCKSS and following our principle for "Graceful Failure," we decided to take a decidely maximalist approach. Using Graves as our case-study, we supplemented eXist with three other approaches: an embedded Google search widget; an interface to query the library Solr instance, which would ingest index files provided by the project; and a simple Javascript-only search that queried pre-build JSON indexes. While this proliferation of search engines does sit rather uncomfortably with the rest of the Endings principles, which advocate for fewer dependencies and persistent solutions, multiple search engines was the best possible solution and, as we argued [Holmes and Takeda 2018],  "provides a level of flexibility [. . .] essential for the survival of projects" (59). 



#### Our intermediate phase: eXist apps with entirely static content save for search



#### Experimentation with Google and Solr (draw on Tokyo presentation for this and below)



<!-- JT: I reversed the following two points (used to be existing first, then brainwave). But I wonder if it makes sense to have existing offline search at the beginning (i.e. we knew that there were some offline searches available, but they just couldn't work; we also knew that there were services that we could use, but that's entirely unsustainable since it introduces a major dependency outside of our control) -->

#### Our little brainwave: you only need the bits of the index that serve your actual search



#### Existing offline searches: the single-massive-index approach, no use at scale



#### How staticSearch works

