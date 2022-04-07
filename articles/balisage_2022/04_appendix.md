## Appendix

### Statistics

The following table details statistics about staticSearch's indexing process for three different projects: the very small staticSearch test set of documents; the *Winnifred Eaton Archive*'s (@Chapman2022) documents, including transcriptions; and the *Landscapes of Injustice*'s (@StangerRoss2021) large archive of primary and secondary source materials. Statistics below were taken on a Apple MacBook Pro running 16GB of RAM and silicon architecture (M1 Pro); timing and sizes are as reported by `gtime`, a port of GNU `time` for macOS.

| **Project**                        | **staticSearch Test Set** | **Winnifred Eaton Archive** | **Landscapes of Injustice** |
| ---------------------------------- | ------------------------- | --------------------------- | --------------------------- |
| **Number of HTML files tokenized** | 10                        | 1820                        | 93998                       |
| **Size of Document Collection**    | 17.4 KB                   | 31M                         | 264M                        |
| **Average document size**          | 1.8K                      | 17K                         | 2.9K                        |
| **Number of token files**          | 678                       | 20514                       | 92203                       |
| **Total Size (uncompressed)**      | 285K                      | 188M                        | 617M                        |
| **Average size (uncompressed)**    | 420B                      | 9.2K                        | 6.7K                        |
| **Total Size (compressed)**        | 171K                      | 39M                         | 106M                        |
| **Average size (compressed)**      | 252B                      | 1.9K                        | 1.2K                        |
| **Build time**                     | 6s 680ms                  | 1m 24s 52ms                 | 8m 53s 20ms                 |
| **Memory Used**                    | 391M                      | 1.3G                        | 3.7G                        |

###  Sample Static Search Implementations

![Phrasal search from the Colonial Despatches project](/Users/takeda/projects/Endings/articles/balisage_2022/images/despatches_phrasal_search.png)


![Simple word search with fragment images](/Users/takeda/projects/Endings/articles/balisage_2022/images/mariage-chat-images.png)





![Filter only search with description and date filters](/Users/takeda/projects/Endings/articles/balisage_2022/images/loi_casefiles_search.png)



!["Wildcard search combined with description filters"](/Users/takeda/projects/Endings/articles/balisage_2022/images/wea_wildcard_search.png "Foobarblort")
