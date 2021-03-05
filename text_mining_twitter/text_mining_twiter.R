library(twitteR)
library(ROAuth)

library(NLP)
library(Rcpp)
library(tm)

library(SnowballC)
library(fpc)
library(RColorBrewer)
library(wordcloud)
library(ggplot2)

# ----------------------------------------
# RETRIEVING tweets from Twitter

consumer_key <- ""
consumer_secret <- ""
access_token <- ""
access_token_secret <- ""

setup_twitter_oauth(consumer_key, consumer_secret, access_token, access_token_secret)
tweetsVJ <- userTimeline("", n = 450)
(length(tweetsVJ))

# ----------------------------------------

df <- twListToDF(tweetsVJ)
dim(df)

myCorpus <- Corpus(VectorSource(df$text))

# ----------------------------------------
# TEXT CLEANING

myCorpus[1:5]$content
myCorpus <- tm_map(myCorpus, content_transformer(tolower))

removeURL <- function(x) gsub("http[^[:space:]]*", "", x)
myCorpus <- tm_map(myCorpus, content_transformer(removeURL))

myCorpus[5]$content
twitterAccs <- function(x) gsub("@\\S* ", "", x)
myCorpus <- tm_map(myCorpus, content_transformer(twitterAccs))
myCorpus[5]$content
symbolCodes <- function(x) gsub('\\p{So}|\\p{Cn}', "", x, perl = TRUE)
myCorpus <- tm_map(myCorpus, content_transformer(symbolCodes))
myCorpus[5]$content
singleLetters <- function(x) gsub(" *\\b[[:alpha:]]{1,2}\\b *", " ", x, perl = TRUE)
myCorpus <- tm_map(myCorpus, content_transformer(singleLetters))

myCorpus <- tm_map(myCorpus, removePunctuation)

removeNoEngLettersANDspaces <- function(x) gsub("[^[:alpha:][:space:]]*", "", x)
myCorpus <- tm_map(myCorpus, content_transformer(removeNoEngLettersANDspaces))

ws <- function(x) gsub("^\\s+|\\s+$", "", x)
myCorpus <- tm_map(myCorpus, content_transformer(ws))
removeExtraWS <- function(x) gsub("\\s+", " ", x)
myCorpus <- tm_map(myCorpus, content_transformer(removeWhiteSpace))

myCorpus <- tm_map(myCorpus, stripWhitespace)

myCorpus[1:5]$content

# ----------------------------------------
#  STOPWORDS

tdm <- TermDocumentMatrix(myCorpus, control=list(wordLengths=c(1,Inf)))
findFreqTerms(tdm, lowfreq=10)

myStopwords <- c(stopwords("en"), "r", "available", "via", "w", "�", "th", "will", "th", "amp", "its")
stopwords("en")
myStopwords

myStopwords <- setdiff(myStopwords, c("r", "big" ))
myStopwords

myCorpus <- tm_map(myCorpus, removeWords, myStopwords)

# ----------------------------------------
# WHITESPACE

myCorpus <- tm_map(myCorpus, stripWhitespace)
myCorpus[11:15]$content
for (i in 11:15) {
  cat(paste("[[", i, "]] ", sep=""))
  writeLines(strwrap(myCorpus[[i]], width=73))
}  



tdm <- TermDocumentMatrix(myCorpus, control=list(wordLengths=c(1,Inf)))
findFreqTerms(tdm, lowfreq=10)

myCorpus[1:5]$content

# ----------------------------------------
#  Steemming words  

# ----------------------------------------
# Term-Document Matrix (TDM) 


tdm <- TermDocumentMatrix(myCorpus, control=list(wordLengths=c(1,Inf)))
tdm
findFreqTerms(tdm, lowfreq=10)



idx <- which(dimnames(tdm)$Terms == "r")
inspect(tdm[idx+(0:5),21:30])
idx <- which(dimnames(tdm)$Terms %in% c("r", "data", "mining"))
as.matrix(tdm[idx, 21:30])


inspect(tdm[idx+(0:5),101:110])

rownames(tdm)

# ----------------------------------------
#  Frequent Terms and Associations

findFreqTerms(tdm, lowfreq=10)

termFrequency <- rowSums(as.matrix(tdm))
termFrequency <- subset(termFrequency, termFrequency>=10)

library(ggplot2)
df <- data.frame(term=names(termFrequency), freq=termFrequency)
ggplot(df, aes(x=term, y=freq)) + geom_bar(stat="identity") +
  xlab("Terms") + ylab("Count") + coord_flip()

barplot(termFrequency, las=2)

findAssocs(tdm,"lithuania", 0.15)
findAssocs(tdm,"congratulations", 0.22)
findAssocs(tdm,"people", 0.27)

# ----------------------------------------
# World Cloud    

m <- as.matrix(tdm)
wordFreq <- sort(rowSums(m), decreasing=TRUE)
pal <- brewer.pal(9, "BuGn")
pal <- pal[-(1:4)]
set.seed(375) # to make it reproducible
grayLevels <- gray( (wordFreq+10) / (max(wordFreq)+10) )
wordcloud(words=names(wordFreq), freq=wordFreq, min.freq=3, 
          random.order=F, colors=pal)

# ----------------------------------------
#  Clustering Words 

tdm2 <- removeSparseTerms(tdm, sparse=0.95)
m2 <- as.matrix(tdm2)
distMatrix <- dist(scale(m2))
fit <- hclust(distMatrix, method="ward.D")
plot(fit)
rect.hclust(fit, k=10)
(groups <- cutree(fit, k=10))

# ----------------------------------------
# Clustering Tweets         

m3 <- t(m2)
set.seed(122)
k<- 10
kmeansResult <- kmeans(m3, k)
round(kmeansResult$centers, digits=3)

for (i in 1:k) {
  cat(paste("cluster ", i, ": ", sep=""))
  s <- sort(kmeansResult$centers[i,], decreasing=T)
  cat(names(s)[1:3], "\n")
}

pamResult <- pamk(m3, metric="manhattan")
(k <- pamResult$nc)

pamResult <- pamResult$pamobject
for (i in 1:k) {
  cat(paste("cluster", i, ": "))
  cat(colnames(pamResult$medoids)[which(pamResult$medoids[i,]==1)], "\n")
}

plot(pamResult, color=F, labels=4, lines=0, cex=.8, col.clus=1,
     col.p=pamResult$clustering)
layout(matrix(1)) 

pamResult <- pamk(m3, krange=2:9, metric="manhattan")
(k<-pamResult$nc)

pamResult <- pamResult$pamobject
for (i in 1:k) {
  cat(paste("cluster", i, ": "))
  cat(colnames(pamResult$medoids)[which(pamResult$medoids[i,]==1)], "\n")
}

plot(pamResult, color=F, labels=4, lines=0, cex=.8, col.clus=1,
     col.p=pamResult$clustering)
layout(matrix(1)) 
