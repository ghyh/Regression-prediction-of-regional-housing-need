## ref: G. James, D. Witten, T. Hastie, and R. Tibshirani, An Introduction to Statistical Learning: with Applications in R. Springer New York, 2013.
filename = "filename"
setwd("/path/to/file")
workingDir = getwd()
RHNA = read.csv(file=file.path(workingDir,filename),header = TRUE)
# fix(RHNA)

dim(RHNA)
#names(RHNA)
names(RHNA[,-1])
summary(RHNA[,-1][,2])
pairs(RHNA[,-1][,1:6],upper.panel = NULL)
pairs(RHNA[,-1][,c(1,7:11)],upper.panel = NULL)
pairs(RHNA[,-1][,c(1,12:16)],upper.panel = NULL)
pairs(RHNA[,-1][,c(1,17:21)],upper.panel = NULL)
pairs(RHNA[,-1][,c(1,22:26)],upper.panel = NULL)
pairs(RHNA[,-1][,c(1,27:28)],upper.panel = NULL)
# removing outlier
cleanData = RHNA[,-1][-which.max(RHNA[,-1][,2]),]
# attach(cleanData)
# names(cleanData)
# summary(cleanData[,2])
# hist(RHNA[,-1][,3],breaks = 500)

#############################
###
### lasso Model
###
#############################

# For consistence of set.seed() across R version
# ref: https://stackoverflow.com/questions/47199415/is-set-seed-consistent-over-different-versions-of-r-and-ubuntu/56381613#56381613
# RNGkind(sample.kind = "Rounding")
# set.seed(1)
# sample(10)
library(glmnet)
set.seed(1)
train = sample(1:nrow(cleanData),nrow(cleanData)*4/5) # Data set for model training
test = (-train)  ## Data set for test
ytest = TOT_RHNA[test]
grid=10^seq(2,-2,length=100)

lassoModel = glmnet(as.matrix(cleanData[train,-1]),as.matrix(TOT_RHNA[train]), alpha=1,lambda = grid)
plot(lassoModel,label=TRUE,xvar = "lambda")

set.seed(1)
lassoCvOut = cv.glmnet(as.matrix(cleanData[train,-1]),as.matrix(TOT_RHNA[train]), alpha=1)
plot(lassoCvOut)
bestlam = lassoCvOut$lambda.min
lassoTrainingLam = lassoCvOut$lambda
# which.min(lassoTrainingLam)
# lassoTrainingLam[which.min(lassoTrainingLam)]
# lassoTrainingCvm = lassoCvOut$cvm
# lassoTrainingCvm[which.min(lassoTrainingLam)]
lassoTrainingCvsd = lassoCvOut$cvsd
lassoTrainingCvsd[which.min(lassoTrainingLam)]
lassoCvOut$cvm[lassoCvOut$lambda == lassoCvOut$lambda.min]
# lasso training MSE
lassoPredTrain = predict(lassoModel,s=bestlam,newx=as.matrix(cleanData[train,-1]))
mean((lassoPredTrain - cleanData[train,1])^2) 
lassoPredict = predict(lassoModel,s=bestlam,newx=as.matrix(cleanData[test,-1]))
mean((lassoPredict-ytest)^2)
lassoPredictCoef = predict(lassoModel,type="coefficients",s=bestlam)[1:28,]
lassoPredictCoef
#############################
###
### Decision Tree
###
############################
library(tree)
treeRHNA = tree(formula=TOT_RHNA~., data=cleanData[,-1],subset=train)
summary(treeRHNA)
plot(treeRHNA)
text(treeRHNA,pretty=0)

cvTreeRHNA = cv.tree(treeRHNA)
plot(cvTreeRHNA$size,cvTreeRHNA$dev,type='b')

## prune tree
pruneTreeRHNA = prune.tree(treeRHNA,best = 5)
plot(pruneTreeRHNA)
text(pruneTreeRHNA,pretty=0)

# training MSE
yTreeHatTraining = predict(treeRHNA,newdata = cleanData[train,-1])
treePredictResultTraining = mean((yTreeHatTraining- cleanData[train,1])^2)
treePredictResultTraining
# test MSE
yTreeHat = predict(treeRHNA,newdata = cleanData[test,-1])
RHNATest = cleanData[test,1]
treePredictResult = mean((yTreeHat-RHNATest)^2)
treePredictResult

############################
##
## random forest
##
###########################
library(randomForest)
set.seed(1)
rfTreeRHNA = randomForest(TOT_RHNA~.,data=cleanData[,-1],subset=train,mtry=9, importance=TRUE)
rfTreeRHNA
rfTreeRHNA$ntree
# training MSE
yhatRfTreeRHNATrain = predict(rfTreeRHNA,newdata=cleanData[train,-1])
mean((yhatRfTreeRHNATrain-cleanData[train,1])^2)
# test MSE
yhatRfTreeRHNA = predict(rfTreeRHNA,newdata=cleanData[-train,-1])
plot(yhatRfTreeRHNA,cleanData[-train,1])
abline(0,1)
mean((yhatRfTreeRHNA-cleanData[test,1])^2)

#########################
###
### PCA
###
##########################
library(pls)
set.seed(1)
pcrRHNA = pcr(TOT_RHNA~.,data=cleanData[,-1],subset=train,scale=TRUE,validation="CV")
summary(pcrRHNA)
validationplot(pcrRHNA,val.type = "MSEP")

# training MSE
pcrRHNAResultTraining = predict(pcrRHNA,cleanData[train,-1],ncomp = 17)
mean((pcrRHNAResultTraining - cleanData[train,1])^2)
# test MSE
pcrRHNAResult = predict(pcrRHNA,cleanData[test,-1],ncomp = 17)
mean((pcrRHNAResult- cleanData[test,1] )^2)

### best subset
library(leaps)
regfit = regsubsets(cleanData[train,1]~.,data=cleanData[train,-1],nvmax = 27)
regfitSummary = summary(regfit)
regfitSummary
names(regfitSummary)
par(mfrow=c(2,2))
plot(regfit,scale="r2")
plot(regfit,scale="adjr2")
plot(regfit,scale="Cp")
plot(regfit,scale="bic")
plot(regfitSummary$rss,xlab="# of variables",ylab="RSS",type="l")
points(which.min(regfitSummary$rss),regfitSummary$rss[which.min(regfitSummary$rss)],col="red",cex=2,pch=20)
plot(regfitSummary$adjr2,xlab="# of variables",ylab="Adjusted Rsq",type="l")
which.max(regfitSummary$adjr2)
points(which.max(regfitSummary$adjr2),regfitSummary$adjr2[which.max(regfitSummary$adjr2)],col="red",cex=2,pch=20)
plot(regfitSummary$cp,xlab="# of variables",ylab="Cp",type="l")
which.min(regfitSummary$cp)
points(which.min(regfitSummary$cp),regfitSummary$cp[which.min(regfitSummary$cp)],col="red",cex=2,pch=20)
plot(regfitSummary$bic,xlab="# of variables",ylab="BIC",type="l")
which.min(regfitSummary$bic)
points(which.min(regfitSummary$bic),regfitSummary$bic[which.min(regfitSummary$bic)],col="red",cex=2,pch=20)

coefficients(regfit,11)

# pick 11 as the input for linear model
lmRHNA = lm(TOT_RHNA~POP16+POP45+HH20+HH30+CITY_PCT_HQTAPOP45+JOBACC_BYPOP+DEMO_LOSS+PT_VLR+PCT_LR+PCT_MR, data=cleanData[,-1],subset = train)
summary(lmRHNA)
# training MSE
lmRHNAPredTraining = predict(lmRHNA, cleanData[train,-1])
mean((lmRHNAPredTraining - cleanData[train,1])^2)
# test MSE
lmRHNAPred = predict(lmRHNA, cleanData[test,-1])
lmRHNATest = cleanData[test,1]
lmRHNAPredResult = mean((lmRHNATest-lmRHNAPred)^2)
lmRHNAPredResult

##############################
###
### GAM
### ref: https://stats.stackexchange.com/questions/346379/calculating-total-estimated-degrees-of-freedom-for-a-gam
###
################################
library(gam)
gamSpline1 = gam(TOT_RHNA~s(POP16)+s(POP45)+s(HH20)+s(HH30)+s(HH45)+s(SHR_2030_45_HHGR)+s(DOFPOP19)+s(CITY_PCT_HQTAPOP45)+s(SHR_HQTAPOP45)+s(MED_JOBACC)+s(JOBACC_BYPOP)+s(PCT_OWN)+s(DEMO_LOSS)+s(PCT_LI)+s(PT_VLR)+s(PCT_LR)+s(PCT_MR)+s(PCT_HR)+s(HQTAPOP45),data=cleanData[,-1],subset=train)
summary(gamSpline1)
gamSpline1$coefficients
par(mfrow=c(3,7))
plot(gamSpline1,se=TRUE,col='blue')

# training MSE for original/linear model
gamPred0 = predict(gamSpline1,newdata = cleanData[train,-1])
gamTest0 = cleanData[train,1]
gamPredictResult0 = mean((gamTest0-gamPred0)^2)
gamPredictResult0

# test MSE for original/linear model
gamPred1 = predict(gamSpline1,newdata = cleanData[test,-1])
gamTest1 = cleanData[test,1]
gamPredictResult1 = mean((gamTest1-gamPred1)^2)
gamPredictResult1

# adding non-linear terms term
gamSpline3 = gam(TOT_RHNA~s(POP16)+s(POP45)+s(HH20)+s(HH30)+s(HH45)+s(SHR_2030_45_HHGR)+s(DOFPOP19)+s(CITY_PCT_HQTAPOP45,3)+s(SHR_HQTAPOP45,2)+s(MED_JOBACC,4)+s(JOBACC_BYPOP,2)+s(PCT_OWN,4)+s(DEMO_LOSS,2)+s(PCT_LI,2)+s(PT_VLR,4)+s(PCT_LR,3)+s(PCT_MR,3)+s(PCT_HR,3)+s(HQTAPOP45),data=cleanData[,-1],subset=train)
summary(gamSpline3)
gamSpline3$coefficients
# par(mfrow=c(4,5))
# plot(gamSpline3,se=TRUE,col='green')

# training MSE for new model
gamPred2 = predict(gamSpline3,newdata = cleanData[train,-1])
gamTest2 = cleanData[train,1]
gamPredictResult2 = mean((gamTest2-gamPred2)^2)
gamPredictResult2

# test MSE for new model
gamPred3 = predict(gamSpline3,newdata=cleanData[test,-1])
gamTest3 = cleanData[test,1]
gamPredictResult3 = mean((gamTest3-gamPred3)^2)
gamPredictResult3