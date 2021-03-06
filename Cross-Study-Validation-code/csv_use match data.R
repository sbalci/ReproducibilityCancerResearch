##########################
#Decision Tree
#Train on GSE14479
load('GSE10899_common.Rdata')
load('GSE14479_common.Rdata')
library(randomForest)
rfModel= randomForest(y=GSE14479$type, x=GSE14479[,2:10041],mtry = 100, ntree=10000,do.trace=T)

#select important gene
sortedImp_gini = sort(rfModel$importance[,1], decreasing=T);
sortedImpt_scaled = sort(importance(rfModel, scale = T)[,1], decreasing = T )

ImpGene=names(sortedImp_gini)[1:1000]
train_Imp=GSE14479[,c(colnames(GSE14479)%in%ImpGene)]
type=GSE14479$type
train_Imp=cbind(type,train_Imp)
train_Imp$type=as.factor((train_Imp$type))

library(RWeka)
DT=J48(as.factor(type)~., data = train_Imp)

#test on GSE10899 dataset
test_Imp=GSE10899[,c(colnames(GSE10899)%in%ImpGene)]
type=GSE10899$type
test_Imp=cbind(type,test_Imp)
test_Imp$type=as.factor((test_Imp$type))
DT_pred_99=predict(DT, newdata = test_Imp)

table(test_Imp$type, DT_pred_99)


# DT_pred_99
# 0 1
# 0 0 4
# 1 0 6

#################
#Naive Bayes
#train on GSE14479
aml.mean=colMeans(GSE14479[GSE14479$type == 1,], na.rm="TRUE")
aml.std=apply(GSE14479[GSE14479$type == 1,], 2, sd)

all.mean=colMeans(GSE14479[GSE14479$type == 0,], na.rm="TRUE")
all.std=apply(GSE14479[GSE14479$type == 0,], 2, sd)

#calculate P use (mu1-mu2)/(sigma1+sigma2)
P=NULL
for (i in 2:length(all.mean)){
  p=abs((aml.mean[i]-all.mean[i])/(aml.std[i]+all.std[i]))
  P=c(P,p)
}

#use 90 genes
gene_90=data.frame(GSE14479[,c(1,head(order(P,decreasing = T),90)+1)])

#Parametric NaiveBayes (use package)
library(e1071)
NBfit.para=naiveBayes(as.factor(gene_90$type)~.,data = gene_90)
names(NBfit.para)
NBfit.para$apriori
NBfit.para$levels

test_gene_90=GSE10899[,colnames(GSE10899)%in%colnames(gene_90)]

test_99=predict(NBfit.para,test_gene_90)



