## File: lifevantage_gscholar.R ####
## (c) 2014, All Rights Reserved
## Author: Jason D. Miller, MS, MS
## Description: Let's see what we can scrape from the Internet related to Protandim and LifeVantage for some ad hoc analyses


# Load Functions and Libraries --------------------------------------------
source("lifevantage_functions.R")

# Scrape Google Finance ---------------------------------------------------
googlefinance <- WebCorpus(GoogleFinanceSource("NASDAQ:LFVN"))

# Scrape Google News ------------------------------------------------------
lv.googlenews <- WebCorpus(GoogleNewsSource("LifeVantage"))
p.googlenews <- WebCorpus(GoogleNewsSource("Protandim"))
ts.googlenews <- WebCorpus(GoogleNewsSource("TrueScience"))

# Scrape NYTimes ----------------------------------------------------------
lv.nytimes <- WebCorpus(NYTimesSource(query = "LifeVantage", appid = nytimes_appid))
p.nytimes <- WebCorpus(NYTimesSource("Protandim", appid = nytimes_appid))
ts.nytimes <- WebCorpus(NYTimesSource("TrueScience", appid = nytimes_appid))

# Scrape Reuters ----------------------------------------------------------
lv.reutersnews <- WebCorpus(ReutersNewsSource("LifeVantage"))
p.reutersnews <- WebCorpus(ReutersNewsSource("Protandim"))
ts.reutersnews <- WebCorpus(ReutersNewsSource("TrueScience"))

# Scrape Yahoo! Finance ---------------------------------------------------
lv.yahoofinance <- WebCorpus(YahooFinanceSource("LFVN"))

# Scrape Yahoo! News ------------------------------------------------------
lv.yahoonews <- WebCorpus(YahooNewsSource("LifeVantage"))
p.yahoonews <- WebCorpus(YahooNewsSource("Protandim"))
ts.yahoonews <- WebCorpus(YahooNewsSource("TrueScience"))

# Scrape Yahoo! Inplay ----------------------------------------------------
lv.yahooinplay <- WebCorpus(YahooInplaySource("LifeVantage"))

# Scrape Google Scholar ---------------------------------------------------
gs_protandim   <- get_google_scholar_df( u = "http://scholar.google.com/scholar?as_q=protandim") # Not working
gs_lifevantage <- get_google_scholar_df( u = "http://scholar.google.com/scholar?as_q=lifevantage") # Not working

# Text Mining the Results -------------------------------------------------
corpus <- c(googlefinance, lv.googlenews, p.googlenews, ts.googlenews, lv.yahoofinance, lv.yahoonews, p.yahoonews,
                 ts.yahoonews, lv.yahooinplay) #lv.nytimes, p.nytimes, ts.nytimes,lv.reutersnews, p.reutersnews,  ts.reutersnews,

inspect(corpus)
wordlist <- c("lfvn", "lifevantage", "protandim", "truescience", "company", "fiscal", "nasdaq")

ds0.1g   <- tm_map(corpus, content_transformer(tolower))
ds1.1g   <- tm_map(ds0.1g, content_transformer(removeWords), wordlist)
ds1.1g   <- tm_map(ds1.1g, content_transformer(removeWords), stopwords("english"))
ds2.1g   <- tm_map(ds1.1g, stripWhitespace)
ds3.1g   <- tm_map(ds2.1g, removePunctuation)
ds4.1g   <- tm_map(ds3.1g, stemDocument)
ds5.1g   <- tm_map(ds4.1g, content_transformer(removeWords), c("a", "b", "c", "d", "e", "f","g","h","i","j","k","l","m","n","o","p","q","r","s","t","u","v","w","x","y","z"))

tdm.1g <- TermDocumentMatrix(ds5.1g)
dtm.1g <- DocumentTermMatrix(ds5.1g)

findFreqTerms(tdm.1g, 100)
findFreqTerms(tdm.1g, 200)
findFreqTerms(tdm.1g, 300)

findAssocs(dtm.1g, "worrisom", .3) 
findAssocs(dtm.1g, "want", .3) 
findAssocs(dtm.1g, "new", .2) 

tdm2.1g<- removeSparseTerms(tdm.1g, 0.86)
tmd.9  <- removeSparseTerms(tdm.1g, .9)
tmd.85 <- removeSparseTerms(tdm.1g, .85)
tmd.8  <- removeSparseTerms(tdm.1g, .8)
tmd.75 <- removeSparseTerms(tdm.1g, .75)

# Creates a Boolean matrix (counts # docs w/terms, not raw # terms)
tdm3.1g <- inspect(tdm2.1g)
tdm3.1g[tdm3.1g>=1] <- 1 

# Transform into a term-term adjacency matrix
termMatrix.1gram <- tdm3.1g %*% t(tdm3.1g)

# inspect terms numbered 5 to 10
termMatrix.1gram[5:10,5:10]
termMatrix.1gram[1:10,1:10]
