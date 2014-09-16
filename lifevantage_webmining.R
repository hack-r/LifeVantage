## File: lifevantage_webmining.R ####
## (c) 2014, All Rights Reserved
## Author: Jason D. Miller, MS, MS
## Description: Let's see what we can scrape from the Internet related to 
##               Protandim's maker LifeVantage for some ad hoc analyses


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
# gs_protandim   <- get_google_scholar_df( u = "http://scholar.google.com/scholar?as_q=protandim") # Not working
# gs_lifevantage <- get_google_scholar_df( u = "http://scholar.google.com/scholar?as_q=lifevantage") # Not working

# Text Mining the Results -------------------------------------------------
corpus <- c(googlefinance, lv.googlenews, p.googlenews, ts.googlenews, lv.yahoofinance, lv.yahoonews, p.yahoonews,
            ts.yahoonews, lv.yahooinplay) #lv.nytimes, p.nytimes, ts.nytimes,lv.reutersnews, p.reutersnews,  ts.reutersnews,

corpus
wordlist <- c("lfvn", "lifevantage", "protandim", "truescience", "company", "fiscal", "nasdaq", "quarter", 
              "market", "statement", "stock", "share", "statement", "statements", "financial", "sale", "corporate", "corporation",
              "2014")

ds0.1g   <- tm_map(corpus, content_transformer(tolower))
ds1.1g   <- tm_map(ds0.1g, content_transformer(removeWords), wordlist)
ds1.1g   <- tm_map(ds1.1g, content_transformer(removeWords), stopwords("english"))
ds2.1g   <- tm_map(ds1.1g, stripWhitespace)
ds3.1g   <- tm_map(ds2.1g, removePunctuation)
ds4.1g   <- tm_map(ds3.1g, stemDocument)
ds5.1g   <- tm_map(ds4.1g, content_transformer(removeWords), c("a", "b", "c", "d", "e", "f","g","h","i","j","k","l",
                                                               "m","n","o","p","q","r","s","t","u","v","w","x","y","z"))

tdm.1g <- TermDocumentMatrix(ds5.1g)
dtm.1g <- DocumentTermMatrix(ds5.1g)

findFreqTerms(tdm.1g, 40)
findFreqTerms(tdm.1g, 60)
findFreqTerms(tdm.1g, 80)
findFreqTerms(tdm.1g, 100)

findAssocs(dtm.1g, "skin", .75) 
findAssocs(dtm.1g, "scienc", .5) 
findAssocs(dtm.1g, "product", .75) 

tdm89.1g <- removeSparseTerms(tdm.1g, 0.89)
tdm9.1g  <- removeSparseTerms(tdm.1g, 0.9)
tdm91.1g <- removeSparseTerms(tdm.1g, 0.91)
tdm92.1g <- removeSparseTerms(tdm.1g, 0.92)

tdm2.1g <- tdm92.1g

# Creates a Boolean matrix (counts # docs w/terms, not raw # terms)
tdm3.1g <- inspect(tdm2.1g)
tdm3.1g[tdm3.1g>=1] <- 1 

# Transform into a term-term adjacency matrix
termMatrix.1gram <- tdm3.1g %*% t(tdm3.1g)

# inspect terms numbered 5 to 10 
termMatrix.1gram[5:10,5:10]
termMatrix.1gram[1:10,1:10]

# Create a 1-gram Word Cloud to Visualize the Text Data ---------------------
notsparse <- tdm2.1g
m = as.matrix(notsparse)
v = sort(rowSums(m),decreasing=TRUE)
d = data.frame(word = names(v),freq=v)

# Create the word cloud
pal = brewer.pal(9,"BuPu")
wordcloud(words = d$word, 
          freq = d$freq, 
          scale = c(3,.8), 
          random.order = F,
          colors = pal)

# Create an n-gram Word Cloud ----------------------------------------------
tdm.ng <- TermDocumentMatrix(ds5.1g, control = list(tokenize = BigramTokenizer))
dtm.ng <- DocumentTermMatrix(ds5.1g, control = list(tokenize = BigramTokenizer))

# Try removing sparse terms at a few different levels
tdm89.ng <- removeSparseTerms(tdm.ng, 0.89)
tdm9.ng  <- removeSparseTerms(tdm.ng, 0.9)
tdm91.ng <- removeSparseTerms(tdm.ng, 0.91)
tdm92.ng <- removeSparseTerms(tdm.ng, 0.92)

notsparse <- tdm91.ng
m = as.matrix(notsparse)
v = sort(rowSums(m),decreasing=TRUE)
d = data.frame(word = names(v),freq=v)

# Create the word cloud
pal = brewer.pal(9,"BuPu")
wordcloud(words = d$word, 
          freq = d$freq, 
          scale = c(3,.8), 
          random.order = F,
          colors = pal)

