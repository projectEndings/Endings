
### 5.5 Release Management 

Without good release management, a project can never end gracefully; it can only falter and die. 

These principles apply to release management:

#### 5.5.1 Releases should be periodical and carefully planned. The “rolling release” model should be avoided.

In the world of traditional print scholarship, a publication is a coherent singular object, released on a particular day in a particular place, and provided with a convenient edition number which enabled scholars to cite it without ambiguity.^[This is not strictly true, of course—minor typographical variants are common within a single edition—but for most practical purposes we behave as though it is.] However, many digital edition projects have adopted a “rolling release” approach modelled on the predominant approach to software publication, where corrections and new features are steadily made to a mutable product. Typos and errors on a single page are quickly fixed and the site can be endlessly tweaked as new problems are inevitably discovered. 

This “rolling release” model, however, makes it difficult to maintain consistency, coherence, and completeness as the site is in a perpetual state of flux; pages are constantly subject to change, and thus the project as a whole is always shifting. Not only does this make stable citation problematic, but it makes archiving difficult. Most large projects go through moribund phases in which work largely stops, and will most likely end in a similar way, and so it is essential that whatever is the current released state (edition) of a project constitutes an acceptable version for the long term. The edition model of digital publication ensures the stability and coherence of the project; much like a print publication, each edition of a digital should be planned carefully, with deadlines and milestones governing its release.^[While this paper does not address project management per se, it is worth noting that this model provides some significant benefits in terms of digital project management. For instance, milestones help prevent feature creep as each release requires careful and considered planning regarding project priorities; by the same token, it allows some space—when combined with Continuous Integration processing mentioned in 5.3—for experimentation since there is no connection between the deployed site and the source data and thus no risk of breaking the existing site.]

#### 5.5.2 A release should only be made when the entire product set is coherent, consistent, and complete (passing all validation and diagnostic tests).

The irreversible nature of print publication means that an edition is often scrutinized and carefully proofed prior to publication. In the “rolling release” model, since digital material is much easier to correct and changes can be applied soon after they are found, it is far less common for this level of diligent inspection to be applied to digital editions. Since each release is organized around a set of milestones and goals, much of this scrutinty can be automated per 5.3.2.  In Holmes and Takeda 2019b, we describe three distinct levels of diagnostic checks which can be incorporated into a project build process to provide mechanical proof that no links are broken, no content is missing, and all planned content and features are complete. This approach, combined with the detailed proofreading we would expect to apply to any scholarly publication prior to release, not only minimizes flaws in the released edition, but also ensures that each edition is archivable.^[*The Map of Early Modern London* retains all past editions of the site. See [“Previous Map of London Editions”](https://mapoflondon.uvic.ca/old/)  for all editions. ]

#### 5.5.3 Like editions of print works, each release of a web resource should be clearly identified on every page by its build date and some kind of version number.

Just like print editions, digital resources should carry a clear edition number which applies throughout the resource to every part of it. Our normal practice is to include this information in the footer of every page. At the time of writing, for example, the current version of *The Map of Early Modern London* carries this information in its footer:

MoEML v.6.5, svn rev. 17540 2020-09-15 12:35:49 -0700 (Tue, 15 Sep 2020). 

This includes not only the specific edition number (6.5), but also the Subversion repository revision from which it was built, along with the exact date and time of the build.^[Including the version control information also makes it possible to rebuild this edition exactly as it is, if data is lost or corrupted.]

#### 5.5.4 Web resources should include detailed instructions for citation, so that end-users can unambiguously cite a specific page from a specific edition.

Citation patterns for web-based resources are still subject to some confusion and change, so we recommend that projects make things easier for other scholars by providing copy/pastable citation blocks for each individual page, accessible from a link on the page. The example in Figure [X] comes from the _Mapping Keats’s Progress_ project.

![Citation popup in _Mapping Keats’s Progress_](images/citationPopup.png){#id .class width=80% height=auto}
