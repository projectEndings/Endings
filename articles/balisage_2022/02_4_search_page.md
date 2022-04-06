### Search Page

Once the documents have been indexed, staticSearch then creates the search page using assembled by the indexing process. This search page is  pre-populated with all necessary values for the search, including the query input, checkboxes for filters, inputs for dates and numeric filters, et cetera; the form itself also bears data-attributes specifying some of the configuration options—the name of the folder that contains the index, the number of results to show, et—to be used by the JavaScript.

Building the page beforehand means that the client-side script does not need to retrieve and parse any of the filters in order for the page to display the necessary controls; while some files—the list of stopwords, the word string, and the titles file—are crucial for any search to be performed and are thus fetched immediately on page load,  staticSearch retrieves these asynchronously in the background such that the page is immediately responsive and usable. 

