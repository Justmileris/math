# Poisson

library(MASS)

filePath <- "data.csv";
wholeData <- read.csv(file=filePath, header=TRUE, sep=";")
myData <- wholeData

myData<-myData[myData$id%%8!=5,]
myData<-myData[myData$type!='A',]
myData$type<-droplevels(myData$type)

summary(wholeData)
summary(myData)
dim(wholeData)
dim(myData)

# Linear, all elems
fit1_linear<-glm(formula=claims~engine+type+age, family=poisson, data=myData)

# Linear, no elem
fit2_NullDeviance<-glm(formula=claims~1, family=poisson, data=myData)

# stepAIC, both
selected_linearModel<-stepAIC(fit2_NullDeviance, direction="both", trace=TRUE, scope=list(upper=fit1_linear,lower=fit2_NullDeviance))

summary(fit1_linear)
summary(fit2_NullDeviance)
summary(selected_linearModel)

# Quadratic dep, continuous
fit3_quadratic<-glm(claims ~ I(age^2)+I(engine^2)+type, family="poisson",data=myData)
summary(fit3_quadratic)
fit2_NullDeviance <- glm(claims ~ 1, data=myData,family="poisson")
selected_qadraticModel<-stepAIC(fit2_NullDeviance,direction="both",scope=list(upper=fit3_quadratic,lower=fit2_NullDeviance))
summary(selected_qadraticModel)

# Linear + quadratic dep, continuous
fit4_linearAndQuadratic<-glm(claims ~ I(age^2)+I(engine^2)+age+engine+type, family="poisson",data=myData)
summary(fit4_linearAndQuadratic)
fit2_NullDeviance <- glm(claims ~ 1, data=myData,family="poisson")
selected_linearAndQuadraticModel<-stepAIC(fit2_NullDeviance,direction="both",scope=list(upper=fit4_linearAndQuadratic,lower=fit2_NullDeviance))
summary(selected_linearAndQuadraticModel)

# Group by 'engine' to ranges
myData$groupedEngine_1<-cut(myData$engine, seq(1200, 5100, 100),right= FALSE)
as.data.frame(table(myData$groupedEngine_1))
fit5_groupedEngine_1<-glm(claims~groupedEngine_1,family="poisson",data=myData)
summary(fit5_groupedEngine_1)

myData$groupedEngine_2<-cut(myData$engine, c(1200, 1300, 2800, 5100),right= FALSE)
as.data.frame(table(myData$groupedEngine_2))
fit6_groupedEngine_2<-glm(claims~groupedEngine_2,family="poisson",data=myData)
summary(fit6_groupedEngine_2)

# Group by 'age' to ranges
myData$groupedAge_1<-cut(myData$age, seq(18,82,3), right=FALSE)
as.data.frame(table(myData$groupedAge_1))
fit6_groupedAge_1<-glm(claims~groupedAge_1,family="poisson",data=myData)
summary(fit6_groupedAge_1)

myData$groupedAge_2<-cut(myData$age, c(18,60,82), right=FALSE)
fit7_groupedAge_2<-glm(claims~groupedAge_2,family="poisson",data=myData)
summary(fit7_groupedAge_2)

myData$groupedAge_2<-cut(myData$age, c(18,59,82), right=FALSE)
fit7_groupedAge_2<-glm(claims~groupedAge_2,family="poisson",data=myData)
summary(fit7_groupedAge_2)

myData$groupedAge_2<-cut(myData$age, c(18,58,82), right=FALSE)
fit7_groupedAge_2<-glm(claims~groupedAge_2,family="poisson",data=myData)
summary(fit7_groupedAge_2)

myData$groupedAge_2<-cut(myData$age, c(18,57,82), right=FALSE)
fit7_groupedAge_2<-glm(claims~groupedAge_2,family="poisson",data=myData)
summary(fit7_groupedAge_2)

# Grouped 'age' and 'engine'
fit8_groupedAgeAndEngine <- glm(claims ~ groupedAge_2+groupedEngine_2+type, data=myData, family="poisson")
selected_groupedModel<-stepAIC(fit2_NullDeviance,direction="both",scope=list(upper=fit8_groupedAgeAndEngine,lower=fit2_NullDeviance))
summary(selected_groupedModel)

# Best
summary(selected_linearAndQuadraticModel)

residuals(selected_linearAndQuadraticModel)
hist(residuals(selected_linearAndQuadraticModel))

fitted.values(selected_linearAndQuadraticModel)
hist(fitted.values(selected_linearAndQuadraticModel))

plot(selected_linearAndQuadraticModel)
plot(myData$age,myData$claims, xlab = 'Age', ylab = 'Claims count')
plot(myData$type,myData$claims, xlab = 'Type', ylab = 'Claims count')
plot(myData$engine,myData$claims, xlab = 'Engine', ylab = 'Claims count')
