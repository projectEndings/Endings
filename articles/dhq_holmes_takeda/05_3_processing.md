### 5.3 Processing 

There is no single way to create an Endings-compliant site; different projects demand different technologies and there is no single language, framework, or tool for creating an Endings-compliant site (and there likely shouldn't be). So the principles below are necessarily technology agnostic and, while our own personal preferences may become apparent from the examples, do not advocate for one "stack" over another. But there is certainly no shortage of processing pipelines for creating static sites. Within the digital humanities, projects like GO:DH's Minimal Computing group and LibStatic, for instance, have created tools like Ed, Wax, and CollectionBuilder for static site creation using GitHub; and within web development more broadly, the uptake of the "JAMStack" has led to a proliferation of static site generators (the JAMStack website lists 326 at the time of writing) and many resources [CITE] on how to use them. 

But just because a pipeline produces static HTML output doesn't mean that the processing produces a site that is archivable and sustainable in the long term. The Endings team was made painfully aware of this in the creation of our own Endings website, which was built initially using GitHub Pages and a pre-built Jekyll template. Though completely static, the site violated many core Endings principles: it was comprised of malformed, invalid HTML [CITE PRINCIPLE] that relied on Bootstrap 4, varnished by a set of Javascript that depended on JQuery [CITE PRINCIPLE] to handle various UI components. The site has since been developed into a valid XHTML5 with all JQuery dependencies replaced by CSS3 and all updates are handled by a simple set of XSL transformations managed by an Ant build script. The problem with the old Endings site was not that it was built with Jekyll and that, had we just done Ant and XSL in the first place, all of our problems would have been solved; rather, the main issue was that the processing was meant only to create a static site, and not one that was coherent, consistent, and complete.

We understand processing, then, not in terms of a particular pipeline, tool, or programming language, but rather as the set of steps necessary for creating robust, sustainable, and archivable resources. While we have created some tools—like our diagnostics toolset as well as staticSearch, which is discussed in detail in [[XREF]]—as part of the Endings project, these toolsets are neither necessary for or comprise the entirety of an Endings "processing" pipeline. 

#### 3.1 Relentless validation: all processing includes validation/linting of all inputs and outputs and all validation errors should exit the process and prevent further execution unti the errors are resolved

Our aspiration is never to release a flawed edition of any project, so validation of all inputs and products is a core requirement in the project build process. TEI XML files are always accompanied by a schema, and validation of those files is always the first step in the build; encoders should not normally commit invalid files to the repository, but this does happen from time to time.  In the same way, the various other varieties of XML that may be generated as part of the build process should also be validated to ensure they are functional and therefore useful to other projects. Naturally, output HTML should also be validated, and the W3C's validator, which is available as a Java JAR file (vnu.jar), is simple to use for this purpose. We use CSS code not only in HTML output but as a language within XML as a convenient formal language to describe the layout and appearance of primary source texts; this CSS can be extracted and validated using the same W3C validator, ensuring that our descriptions are logical and processable by any CSS processor. 

Standard validation can catch many syntactic and stylistic errors in individual documents, but they do not necessarily confirm the collection's coherence and completeness as a whole. As we have argued before (Holmes and Takeda 2019), validation should be accompanied by a set of project diagnostics, which can, among other things, confirm referential integrity between documents, check for potential duplication of data (people, places, or bibliographic citations), and trace a project's progress across time. 

#### 3.2 Continuous integration: Any change to the source data requires an entire rebuild of the site (triggered automatically by a continuous integration server where possible). Processing values validity and maintainability over speed and efficiency

At its most basic, the processing for an Endings-compliant site could simply be a single individual who lovingly encodes an HTML document by hand and, after validating it against the W3C's HTML validator, uploads it to their server. Most projects, however, require a more robust technical pipeline that can re-arrange, transform, and aggregate their source materials into a fully functioning web application. While these builds should be able to be run locally, the project team seldom requires a local version as the project building is managed by a Continuous Integration and Continuous Deployment server (CI/CD). Our locally hosted Jenkins server polls each repository and if it detects any change whatsoever to the repository, it re-runs the entire build process, deleting all of the old artifacts and creating them anew. 

Compared to server-side systems that prize rapid delivery of products in milleseconds, our build processes can seem painfully slow and massively inefficient: changing a single character in a single file initiates an entire re-build of the site, which, depending on the size of the project, can take anywhere from a few minutes to two hours where much of that time isn't spent on building the HTML products that comprise the final site. Instead, most of the build time is occupied by relentlessly validating any and all inputs and outputs. 

#### 3.3 Code is contingent: While code is not expected to have significant longevity, all code should strive to follow Endings principles for data and products. 

Much like the source data, all processing code should be subject to version control and ideally in the same repository as the source data, which ensures that the data and the code are always in sync and thus makes rebuilding a project at a particular version trivial.[^1] This also means that all dependencies, including external JAR files and binaries, should be stored in the repository when the terms of the software permit (open-source software here is, of course, preferred). While it is a good idea to build routines into your processing that check for updates, upgrading a dependency should always be the developer's responsibility and not something performed silently in the background by a package manager; the repository should always contain the last version of the dependency that works with the rest of the code, such that the processing can work even when that version, the organization, or the package registry disappears. 

But while data and products are designed to survive, processing code is necessarily impermanent; while we strive to create the appropriate conditions for maintaining reproducibility, there is no guarantee that code will work in a year, let alone fifty. This is a luxury afforded by static sites: while server-side infrastructures require a great deal of consideration and investment to ensure that the processing can be maintained in future, it makes no difference how a static site is created as they are, by definition, untethered from the processing that created them. 



---

##### {DRAFT}: New set of principles

>1. Relentless validation: all processing includes validation/linting of all inputs and outputs and all validation errors should exit the process and prevent further execution unti the errors are resolved; all validation should be accompanied by diagnostics
>1. Continuous integration: Any change to the source data requires an entire rebuild of the site (triggered automatically by a continuous integration server where possible). Processing values validity and maintainability over speed and efficiency
>1. Code is contingent: While code is not expected to have significant longevity, all code should strive to follow Endings principles for data and products. Ideally, processing code:
>   1. should be subject to version control and, where possible, the same version control as the source data
>   1. should have minimal dependencies and all dependencies are similarly subject to version control (license and storage capabilities permitting)
>   1. should be open-source where possible



---

##### Footnotes 



[^1]: Placing the code alongside the data does, however, mean that all members of the team have access to the code, which not only could pose issues in some cases (an errant search and replace), but more importantly, it can lead to unnecessary clutter and disk use for team members.  
