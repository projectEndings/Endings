## 6. The Lingering Problem: Search



With these Principles in place, we were able to convert the dormant projects, like The Robert Graves Diary, and the on-going projects, like *The Map of Early Modern London*, from unwieldy eXist applications into a large bundle of static HTML, CSS, and JS. Our goal for these static incarnations was that they looked and functioned identically to the live application and, as these sites were steadily released and tested, we were happy to find that doing so was not only feasible, but significantly improved the projects. Our staticization of Graves, for instance, surfaced various encoding errors that had gone unnoticed for many years, which we could now easily diagnose and fix. And in moving from a dynamic application to the static site, we had the opportunity to re-write the codebase from scratch, removing the layers of dead-code that had sedimented within the codebase over its long history of updates and maintenance and modernizing the CSS and JavaScript. Projects in active development benefitted similarly; not only did these re-writes provide a good opportunity to scrutinize the project, lopping off code that was either irrelelvant or, in retrospect, decidely unnecessary.  Thanks to our Jenkins server, any development on the project, either to the source data or the processing, we no longer needed to hold our breath when a new document needed to be updated nor anxiously click around the site to confirm that we hadn't broken the site entirely: any encoder could simply commit, wait a few minutes, and, so long as the Jenkins server didn't send its "BUILD FAILED" message, then  proof their changes in the context of the site. 

<!--Image of the "old" graves homepage, maybe?-->

But these sites all lacked a significant and crucial part of their functionality: search. Indeed, the homepage for Graves, which was essentially one large, faceted search page, looked identical to the live site but was rendered completely inert on the static site. We had conceded that the kinds of search our projects required—complex faceting and filters, wildcards, and exact phrase queries split across multiple, collection specific search pages—was necessarily the stuff of servers and could not be made static. While static sites can have some search capabilities powered by code-bases like Lunr, these libraries retain their entire index in memory and so were thus ill-equipped to handle the thousands of documents, millions of words, and complex metadata structures that comprise a standard digital edition. Our intermediate solution was to simply take the static sites and package them into eXist applications; these would be entirely static in terms of their function, would be entirely static save for the search capabilities. Of course, this worked perfectly well, but was a not a particularly satisfying solution: we had re-written these sites in their entirety to remove their dependency on eXist and now we were returning with hat in hand. 

Given that redundancy posed no problem, we next attempted to try a variety of search engines, placing them all—four in total—on the Graves site  (Holmes and Takeda). Though these were all completely unarchivable, the site's searching capabilities would, at least, no longer have a single point of failure and hopefully one of them one would persist. 



#### Our intermediate phase: eXist apps with entirely static content save for search



#### Experimentation with Google and Solr (draw on Tokyo presentation for this and below)



<!-- JT: I reversed the following two points (used to be existing first, then brainwave). But I wonder if it makes sense to have existing offline search at the beginning (i.e. we knew that there were some offline searches available, but they just couldn't work; we also knew that there were services that we could use, but that's entirely unsustainable since it introduces a major dependency outside of our control) -->

#### Our little brainwave: you only need the bits of the index that serve your actual search



#### Existing offline searches: the single-massive-index approach, no use at scale



#### How staticSearch works

