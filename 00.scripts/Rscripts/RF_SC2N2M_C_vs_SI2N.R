#!/usr/bin/env Rscript

library(abcrf)
library(data.table)

### load data :
target <- read.table("ABCstat.txt", T)

### load simulations

SC2M2N_C <- fread("zcat 00.simuls/SC_2M_2N_C.ABCstat.txt.gz"   )
SI2N     <- fread("zcat 00.simuls/SI_2N_2m_none.ABCstat.txt.gz" )
#
f <- function(x){
    m <- mean(x, na.rm = TRUE)
    x[is.na(x)] <- m
    x
}

SC2M2N_C <- apply(SC2M2N_C  , 2, f)
SI2N     <- apply(SI2N , 2, f)

################################################################################
# keep wanted stats and merge data
nlinesFul=min(nrow(SC2M2N_C),nrow(SI2N))
x <- as.factor(c(rep(1:2,each=nlinesFul)))

sumstats <- as.data.frame(rbind
          (SC2M2N_C[c(1:nlinesFul),],
          SI2N[c(1:nlinesFul),]) )

sumstats <- sumstats[, !grepl("G", names(sumstats) )]
sum <- do.call(cbind, lapply(sumstats, as.numeric))

target2 <-  target[, !grepl("G", names(target) )]
obs <- matrix(rep(target2,10), byrow=T, nrow=10)
obs <- as.data.frame(obs)
obs <- do.call(cbind, lapply(obs, as.numeric))

nlinesFul

################################################################################
# Perform ABCRF model choice :
#class(sum)
colnames(sum)
sum <- as.data.frame(sum)

rf <- abcrf(x~., data=sum, 
      lda=TRUE, 
      ntree=1500,
      sampsize=min(5e4, nrow(sum)),
      paral=TRUE, 
      ncores= 5)
#
#rf
sink("RF1500trees_confussion_matrix_SC2N2M_C_vs_SI2N.txt")
print(rf)
sink()

data1 <- data.frame(x, as.data.frame(sum))

#plot variable importance and display model position:
#pdf(file="p1.pdf") #former name
pdf(file="variable_importance.pdf")
plot(rf, data1, obs=as.data.frame(target2))

dev.off()

###################################################################################################
#print("Now performing model choice")
res <-  predict(rf, as.data.frame(target2), data1, ntree=500, paral=T)
res
write.table(res$vote,"RF1500_trees_vote_SC2N2M_C_vs_SI2N.txt",
    quote=F,
    col.names=c("SC2M2N_C","SI2N" ),
    row.names=F)
write.table(cbind(res$allocation,res$post.prob),
    "RF1500_trees_best_model_SC2N2M_C_vs_SI2N.txt",
    quote=F,
    row.names=F,
    col.names=c("model","postprob"))
#### graphe des OOB: 
print("computing OOB")
pdf(file="OOB_1500_tree_error.SC2N2M_C_vs_SI2N.pdf")
err.abcrf(object = rf, training = data1, paral = TRUE)
dev.off()



exit()
#
## estimer les parametres:
colnames(SI2N) <- colnames(target)
SI <- as.data.frame(SI2N)

#read param:
priorfile <- fread("zcat 00.simuls/SI_2N_none.priorfile.txt.gz") 
priorfile <- as.data.frame(priorfile) 
prior <- do.call(cbind, lapply(priorfile, as.numeric))

colnames(prior) <- c("N_popA","N_popB","N_popC","N_popD",
    "Na_AB","Na_CD","Na",
    "shape_a_N","shape_b_N",
    "Tsplit_AB","Tsplit_CD","Tsplit")

SI <- SI[,c(2:144)]

model.rf <- list()
thepred <- list()

for(i in 1:ncol(prior)){
param = prior[,i]

data2 <-  data.frame(param, SI)
model.rf[[i]] <- regAbcrf(param ~., data2, ntree=500, min.node.size = 5, paral = T)
thepred[[i]]  <- predict(object = model.rf[[i]], obs = as.data.frame(target2), training = data2, quantiles = c(0.025,0.975), paral = TRUE)  

print("parameter", i )
print(colnames(prior[,i]))

print(thepred[[i]]$expectation)
print(thepred[[i]]$variance)
print(thepred[[i]]$quantiles)
sink(paste0("thepred",i))
print(thepred[[i]])
sink()
}

quit()

#prediction : 
pred1 <- predict(object = model.rf[[1]], obs = as.data.frame(target2), training = data2, quantiles = c(0.025,0.975), paral = TRUE)  
pred2 <- predict(object = model.rf[[2]], obs = as.data.frame(target2), training = data2, quantiles = c(0.025,0.975), paral = TRUE)  
pred3 <- predict(object = model.rf[[3]], obs = as.data.frame(target2), training = data2, quantiles = c(0.025,0.975), paral = TRUE)  
pred4 <- predict(object = model.rf[[4]], obs = as.data.frame(target2), training = data2, quantiles = c(0.025,0.975), paral = TRUE)  
pred5 <- predict(object = model.rf[[5]], obs = as.data.frame(target2), training = data2, quantiles = c(0.025,0.975), paral = TRUE)  
pred6 <- predict(object = model.rf[[6]], obs = as.data.frame(target2), training = data2, quantiles = c(0.025,0.975), paral = TRUE)  
pred7 <- predict(object = model.rf[[7]], obs = as.data.frame(target2), training = data2, quantiles = c(0.025,0.975), paral = TRUE)  
pred8 <- predict(object = model.rf[[8]], obs = as.data.frame(target2), training = data2, quantiles = c(0.025,0.975), paral = TRUE)  
pred9 <- predict(object = model.rf[[9]], obs = as.data.frame(target2), training = data2, quantiles = c(0.025,0.975), paral = TRUE)  
pred10<- predict(object = model.rf[[10]], obs = as.data.frame(target2), training = data2, quantiles = c(0.025,0.975), paral = TRUE)  
pred11<- predict(object = model.rf[[11]], obs = as.data.frame(target2), training = data2, quantiles = c(0.025,0.975), paral = TRUE)  
pred12<- predict(object = model.rf[[12]], obs = as.data.frame(target2), training = data2, quantiles = c(0.025,0.975), paral = TRUE)  

pred1$expectation
pred1$variance
pred1$quantiles

pred2$expectation
pred2$variance
pred2$quantiles

pred3$expectation
pred3$variance
pred3$quantiles

pred4$expectation
pred4$variance
pred4$quantiles

pred5$expectation
pred5$variance
pred5$quantiles

pred6$expectation
pred6$variance
pred6$quantiles

pred7$expectation
pred7$variance
pred7$quantiles

pred8$expectation
pred8$variance
pred8$quantiles

pred9$expectation
pred9$variance
pred9$quantiles

pred10$expectation
pred10$variance
pred10$quantiles

pred11$expectation
pred11$variance
pred11$quantiles

pred12$expectation
pred12$variance
pred12$quantiles
