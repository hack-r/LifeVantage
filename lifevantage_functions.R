## File: lifevantage_functions.R ####
## (c) 2014, All Rights Reserved
## Author: Jason D. Miller, MS, MS
## Description: Functions and packages used in my analysis of LifeVantage



# Google Scholar Scraper --------------------------------------------------
get_google_scholar_df <- function(u) {
  html <- getURL(u)
  
  # parse HTML into tree structure
  doc <- htmlParse(html)
  
  # I hacked my own version of xpathSApply to deal with cases that return NULL which were causing me problems
  GS_xpathSApply <- function(doc, path, FUN) {
    path.base <- "/html/body/div[@class='gs_r']"
    nodes.len <- length(xpathSApply(doc, "/html/body/div[@class='gs_r']"))
    paths <- sapply(1:nodes.len, function(i) gsub( "/html/body/div[@class='gs_r']", paste("/html/body/div[@class='gs_r'][", i, "]", sep = ""), path, fixed = TRUE))
    xx <- sapply(paths, function(xpath) xpathSApply(doc, xpath, FUN), USE.NAMES = FALSE)
    xx[sapply(xx, length)<1] <- NA
    xx <- as.vector(unlist(xx))
    return(xx)
  }
  # construct data frame
  df <- data.frame(
    footer = GS_xpathSApply(doc, "/html/body/div[@class='gs_r']/font/span[@class='gs_fl']", xmlValue),
    title = GS_xpathSApply(doc, "/html/body/div[@class='gs_r']/div[@class='gs_rt']/h3", xmlValue),
    type = GS_xpathSApply(doc, "/html/body/div[@class='gs_r']/div[@class='gs_rt']/h3/span", xmlValue),
    publication = GS_xpathSApply(doc, "/html/body/div[@class='gs_r']/font/span[@class='gs_a']", xmlValue),
    description = GS_xpathSApply(doc, "/html/body/div[@class='gs_r']/font", xmlValue),
    cited_by = GS_xpathSApply(doc, "/html/body/div[@class='gs_r']/font/span[@class='gs_fl']/a[contains(.,'Cited by')]/text()", xmlValue),
    cited_ref = GS_xpathSApply(doc, "/html/body/div[@class='gs_r']/font/span[@class='gs_fl']/a[contains(.,'Cited by')]", xmlAttrs),
    title_url = GS_xpathSApply(doc,  "/html/body/div[@class='gs_r']/div[@class='gs_rt']/h3/a", xmlAttrs),
    view_as_html = GS_xpathSApply(doc, "/html/body/div[@class='gs_r']/font/span[@class='gs_fl']/a[contains(.,'View as HTML')]", xmlAttrs),
    view_all_versions = GS_xpathSApply(doc, "/html/body/div[@class='gs_r']/font/span[@class='gs_fl']/a[contains(.,' versions')]", xmlAttrs),
    from_domain = GS_xpathSApply(doc, "/html/body/div[@class='gs_r']/span[@class='gs_ggs gs_fl']/a", xmlValue),
    related_articles = GS_xpathSApply(doc, "/html/body/div[@class='gs_r']/font/span[@class='gs_fl']/a[contains(.,'Related articles')]", xmlAttrs),
    library_search = GS_xpathSApply(doc, "/html/body/div[@class='gs_r']/font/span[@class='gs_fl']/a[contains(.,'Library Search')]", xmlAttrs),
    stringsAsFactors = FALSE)
  # Clean up extracted text
  df$title <- sub(".*\\] ", "", df$title)
  df$description <- sapply(1:dim(df)[1], function(i) gsub(df$publication[i], "", df$description[i], fixed = TRUE))
  df$description <- sapply(1:dim(df)[1], function(i) gsub(df$footer[i], "", df$description[i], fixed = TRUE))
  df$type <- gsub("\\]", "", gsub("\\[", "", df$type))
  df$cited_by <- as.integer(gsub("Cited by ", "", df$cited, fixed = TRUE))
  
  # remove footer as it is now redundant after doing clean up
  df <- df[,-1]
  
  # free doc from memory
  free(doc)
  
  return(df)
}
