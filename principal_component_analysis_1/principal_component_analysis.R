initialData <- read.delim(file="mnist.txt", header=TRUE, sep=",")
myData<-initialData

# Clean data
dim(myData)

corTrainData <- cor(myData)
corTrainData

library(caret)
set.seed(42)
trainIndexes = createDataPartition(myData$label,p=0.7, list=FALSE,times=1)
trainData = myData[trainIndexes,]
testData = myData[-trainIndexes,]

dim(trainData)
dim(testData)
t(head(myData[1], 20))
t(head(trainData[1], 20))

trainData_withoutLabel<-trainData[2:(length(trainData))] # Leave data without first column (label)

corTrainData <- cor(trainData_withoutLabel)
corTrainData

# Eigenvectors ################################################################

dim(trainData_withoutLabel)
pca <- princomp(trainData_withoutLabel, scores=TRUE)
summary(pca)
str(pca)
loadings(pca)
plot(pca, type="lines", n=20) # scree plot

###############################################################################

eigs <- pca$sdev^2
summaryPCA <- rbind(
  SD = sqrt(eigs),
  Proportion = eigs/sum(eigs),
  Cumulative = cumsum(eigs)/sum(eigs))

summaryPCA
summaryPCA[2,]

summaryPCA[2,1:4]
sum(summaryPCA[2,1:4])

i <- 1
prcSum <- 0
while (prcSum < 0.90) {
  prcSum <- prcSum + summaryPCA[2,i]
  i = i+1
  print(c(prcSum, i))
}

print(prcSum)
print(i)

###############################################################################

str(trainData$label)
plot(pca$scores[,1], pca$scores[,2], col=trainData$label+1, xlab="PC1", ylab="PC2")
legend(x=-2200, y=0,c(0,2,4,6),col=c(1,3,5,7),pch=1)

biplot(pca)

###############################################################################

# pair1_PCX1 <- sample(1:783, 1)
# pair1_PCX2 <- pair1_PCX1+1
# plot(pca$scores[,pair1_PCX1], pca$scores[,pair1_PCX2], col=trainData$label, xlab="PCX1", ylab="PCX2")
# 
# pair2_PCX1 <- sample(1:783, 1)
# pair2_PCX2 <- pair2_PCX1+1
# plot(pca$scores[,pair2_PCX1], pca$scores[,pair2_PCX2], col=trainData$label, xlab="PCX1", ylab="PCX2")
# 
# pair3_PCX1 <- sample(1:783, 1)
# pair3_PCX2 <- pair3_PCX1+1
# plot(pca$scores[,pair3_PCX1], pca$scores[,pair3_PCX2], col=trainData$label, xlab="PCX1", ylab="PCX2")

# Gaussian mixture model  #####################################################

require(mclust)

makeClusters <- function(pcaScores, mainComponentsCount, clustersCount) {
  
  components <- data.frame(pcaScores) # 5 main components
  clustersData <- Mclust(data=components, G=clustersCount) # 4 clusters
  
  return(clustersData)
}

mainComponentsCount <- 5
clustersCount <- 4
clustersData_trainData <- makeClusters(pca$scores[,1:mainComponentsCount], mainComponentsCount, clustersCount)

plot(clustersData_trainData)

clustersData_trainData
summary(clustersData_trainData)

###############################################################################

varianceProcent <- round(pca$sdev^2/sum(pca$sdev^2)*100) # percent explained variance

# prediction of PCs for validation dataset
testData_withoutLabel<-testData[2:(length(testData))] # Leave data without first column (label)

pred <- predict(pca, newdata=testData_withoutLabel)

COLOR <- c(2:4)
PCH <- c(1,16)

pc <- c(1,2) # principal components to plot

op <- par(mar=c(4,4,1,1), ps=10)
plot(pca$scores[,pc], col=COLOR[trainData$label], cex=PCH[1], 
     xlab=paste0("PC ", pc[1], " (", varianceProcent[pc[1]], "%)"), 
     ylab=paste0("PC ", pc[2], " (", varianceProcent[pc[2]], "%)")
)
points(pred[,pc], col=COLOR[testData$label], pch=PCH[2])
legend("topleft", legend=c("training data", "test data"), col=3, pch=PCH)
par(op)

###############################################################################

predResultValues <- split(pred, length(testData[,1])) # Result is in one list, thus it should be divided to rows nad columns
predResultValues <- array(unlist(predResultValues), dim = c(length(testData_withoutLabel[,1]), length(testData_withoutLabel[1,]))) # 1201x784

clustersData_testData <- makeClusters(predResultValues[,1:mainComponentsCount], mainComponentsCount, clustersCount)
plot(clustersData_testData)

calculateResultAccuracy <- function(clusters_classifications, realLabels, dataTitle) {
  
  nums_and_clusters <- table(realLabels[,1], clusters_classifications)
  classifiedLabels<-c()
  
  row.names(nums_and_clusters)
  rowNames<-row.names(nums_and_clusters)
  indexesOfMaxValuesOfColumns<-max.col(t(nums_and_clusters)) # Indexes of max values in columns in matrix 
  clusters_Predicted_Labels<-rowNames[indexesOfMaxValuesOfColumns]
  
  for (i in 1:length(as.vector(clusters_classifications))) {
    temp_clusterNumber <- as.vector(clusters_classifications)[i]
    
    for (j in 1:length(clusters_Predicted_Labels)) {
      if (temp_clusterNumber == j) {
        temp_classifiedLabel <- as.numeric(c(clusters_Predicted_Labels[j]))
      }
    }
    
    classifiedLabels[i] <- temp_classifiedLabel
  }
  classifiedLabels <- as.numeric(classifiedLabels)
  
  accuratePredicionsCount <- 0
  for (i in 1:length(classifiedLabels)) {
    if (realLabels[,1][i] == classifiedLabels[i]) {
      accuratePredicionsCount <- accuratePredicionsCount + 1
    }
  }
  
  accuracy <- accuratePredicionsCount/length(classifiedLabels)*100
  accuracy <- round(accuracy, digits=2)
  
  cat(dataTitle, 'data accuracy:', accuracy, '%,   ', '(', accuratePredicionsCount, '/', length(classifiedLabels),')') 
  
  return(accuracy)
}

train_accuracy <- calculateResultAccuracy(clustersData_trainData$classification, trainData, 'Train')
test_accuracy <- calculateResultAccuracy(clustersData_testData$classification, testData, 'Test')

###############################################################################

train_accuracy

mainComponentsCount_task9 <- 8
clustersData_trainData_task9 <- makeClusters(pca$scores[,1:mainComponentsCount_task9], mainComponentsCount_task9, clustersCount)
train_accuracy_with_pc8 <- calculateResultAccuracy(clustersData_trainData_task9$classification, trainData, cat('Train (PC =', mainComponentsCount_task9, ')'))

mainComponentsCount_task9 <- 20
clustersData_trainData_task9 <- makeClusters(pca$scores[,1:mainComponentsCount_task9], mainComponentsCount_task9, clustersCount)
train_accuracy_with_pc8 <- calculateResultAccuracy(clustersData_trainData_task9$classification, trainData, cat('Train (PC =', mainComponentsCount_task9, ')'))

mainComponentsCount_task9 <- 50
clustersData_trainData_task9 <- makeClusters(pca$scores[,1:mainComponentsCount_task9], mainComponentsCount_task9, clustersCount)
train_accuracy_with_pc8 <- calculateResultAccuracy(clustersData_trainData_task9$classification, trainData, cat('Train (PC =', mainComponentsCount_task9, ')'))

mainComponentsCount_task9 <- 100
clustersData_trainData_task9 <- makeClusters(pca$scores[,1:mainComponentsCount_task9], mainComponentsCount_task9, clustersCount)
train_accuracy_with_pc8 <- calculateResultAccuracy(clustersData_trainData_task9$classification, trainData, cat('Train (PC =', mainComponentsCount_task9, ')'))

mainComponentsCount_task9 <- 20
clustersCount <- 4
clustersData_trainData_task9 <- makeClusters(pca$scores[,1:mainComponentsCount_task9], mainComponentsCount_task9, clustersCount)
train_accuracy_with_pc8 <- calculateResultAccuracy(clustersData_trainData_task9$classification, trainData, cat('Train (PC =', mainComponentsCount_task9, ')'))

summary(clustersData_trainData_task9)
