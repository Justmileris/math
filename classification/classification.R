# MJ
# Data set from: http://archive.ics.uci.edu/ml/datasets/Adult
library('plyr')
library('MASS')
library('party')

initialData <- read.delim(file="adult.data.txt", header=FALSE, sep=",")
myData <- initialData[1:10000,]
dim(myData)

colnames(myData) <- c('age', 'workclass', 'fnlwgt', 'education', 'education-num','status', 'occupation', 'relationship', 'race','sex', 'capital-gain', 'capital-loss', 'h-per-week','country', 'prediction')

### Renaming 'prediction' column

levels(myData$prediction)[1] <- FALSE
levels(myData$prediction)[2] <- TRUE

### Removing rows with missing values

idx <- myData == " ?"
is.na(myData) <- idx
myData<-myData[rowSums(is.na(myData)) == 0,]

myData$workclass<-factor(myData$workclass)
myData$occupation<-factor(myData$occupation)
myData$country<-factor(myData$country)

###

summary(myData)
str(myData)
dim(myData)

# Divide data sets to train ant test
set.seed(42)
trainIndexes <- sample(1:nrow(myData), 0.7 * nrow(myData))
testData <- myData[-trainIndexes,]
trainData <- myData[trainIndexes,]
#

#############################################
# SVM

library('tictoc')
library("e1071")
library(caret)

tic("SVM")
set.seed(42)
svmModel <- svm(prediction ~ ., data=trainData, kernel="radial", scale=FALSE)
summary(svmModel)
pred <- predict(svmModel, testData, type = "class")
confusionMatrix(table(pred, testData$prediction))

tic("SVM")
tunefit <- tune.svm(prediction~., data=trainData, cost=10^(2:3), gamma= 10^(-3:-1))
summary(tunefit)
svmfit <- tunefit$best.model
psvm <- predict(svmfit, testData, type = "class")
confusionMatrix(table(psvm, testData$prediction))
toc()
predSvmTrainData <- predict(svmfit, trainData, type = "class")
confusionMatrix(table(predSvmTrainData, trainData$prediction))
print(tunefit)

#############################################
#############################################
#
library("rpart")
library("rpart.plot")
tic('DECISION TREE')
set.seed(42)
fit <- rpart(prediction ~ ., data=trainData, method="class")
plot(fit)
summary(fit)
prp(fit)
pred <- predict(fit, trainData, type="class")
confusionMatrix(table(pred, trainData$prediction))
predTest <- predict(fit, testData, type="class")
confusionMatrix(table(predTest, testData$prediction))
printcp(fit)
plotcp(fit)

set.seed(42)
fit2 <- prune(fit, cp=0.1)
prp(fit2)
pred <- predict(fit2, trainData, type="class")
confusionMatrix(table(pred, trainData$prediction))
set.seed(42)
predTest <- predict(fit, testData, type="class")
confusionMatrix(table(predTest, testData$prediction))
toc()

#############################################
#############################################

tic('RANDOM FOREST')
set.seed(42)
fit <- cforest(prediction ~ ., data=trainData)
summary(fit)
pred <- predict(fit, testData, OOB=TRUE, type="response")
confusionMatrix(table(pred, testData$prediction))
predTrainData <- predict(fit, trainData, OOB=TRUE, type="response")
confusionMatrix(table(predTrainData, trainData$prediction))
toc()

#############################################
#############################################
#

library('nnet')
library('NeuralNetTools')

tic('NEURAL NETWORKS')
set.seed(42)
nn <- nnet(prediction ~ ., trainData, size=10, MaxNWts=2000, maxit=100000)
pred <- predict(nn, trainData, type = "class")
mean(trainData$prediction == pred)
table(trainData$prediction, pred)
pred <- predict(nn, testData, type = "class")
mean(pred ==testData$prediction)
table(pred, testData$prediction)
toc()
plotnet(nn, alpha=0.4,bias=TRUE)
