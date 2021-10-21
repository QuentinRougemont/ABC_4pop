#!/usr/bin/env Rscript

library(abcrf)
library(data.table)

### load data :
target <- read.table("ABCstat.txt", T)

############################## load simulations #################################################
#SC1M1N_ACBD   <- fread("zcat 00.simuls/SC_1M_1N_ACBD.ABCstat.txt.gz")
#SC2M1N_ACBD   <- fread("zcat 00.simuls/SC_2M_1N_ACBD.ABCstat.txt.gz")
#SC1M2N_ACBD   <- fread("zcat 00.simuls/SC_1M_2N_ACBD.ABCstat.txt.gz")
SC2M2N_A      <- fread("zcat 00.simuls/SC_2M_2N_A.ABCstat.txt.gz"   )
SC2M2N_B      <- fread("zcat 00.simuls/SC_2M_2N_B.ABCstat.txt.gz"   )
SC2M2N_C      <- fread("zcat 00.simuls/SC_2M_2N_C.ABCstat.txt.gz"   )
SC2M2N_D      <- fread("zcat 00.simuls/SC_2M_2N_D.ABCstat.txt.gz"   )
SC2M2N_BD     <- fread("zcat 00.simuls/SC_2M_2N_BD.ABCstat.txt.gz"  )
SC2M2N_AC     <- fread("zcat 00.simuls/SC_2M_2N_AC.ABCstat.txt.gz"  )
SC2M2N_ACBD   <- fread("zcat 00.simuls/SC_2M_2N_ACBD.ABCstat.txt.gz")

f <- function(x){
    m <- mean(x, na.rm = TRUE)
    x[is.na(x)] <- m
    x
}

SC2M2N_A     <- apply(SC2M2N_A    , 2, f)
SC2M2N_B     <- apply(SC2M2N_B    , 2, f)
SC2M2N_C     <- apply(SC2M2N_C    , 2, f)
SC2M2N_D     <- apply(SC2M2N_D    , 2, f)
SC2M2N_AC    <- apply(SC2M2N_AC   , 2, f)
SC2M2N_BD    <- apply(SC2M2N_BD   , 2, f)
SC2M2N_ACBD  <- apply(SC2M2N_ACBD , 2, f)
################################################################################
# preapre all the data
nlinesFul=min(nrow(SC2M2N_A),nrow(SC2M2N_B),nrow(SC2M2N_C),nrow(SC2M2N_D),
              nrow(SC2M2N_AC),nrow(SC2M2N_BD), nrow(SC2M2N_ACBD))

x <- as.factor(c(rep(1:7,each=nlinesFul)))

sumstats <- as.data.frame(rbind(
    SC2M2N_A[c(1:nlinesFul),],
    SC2M2N_B[c(1:nlinesFul),],
    SC2M2N_C[c(1:nlinesFul),],
    SC2M2N_D[c(1:nlinesFul),],
    SC2M2N_BD[c(1:nlinesFul),],
    SC2M2N_AC[(1:nlinesFul),],
    SC2M2N_ACBD[c(1:nlinesFul),]) )

sumstats <- sumstats[, !grepl("G", names(sumstats) )]
sum <- do.call(cbind, lapply(sumstats, as.numeric))

target2 <-  target[, !grepl("G", names(target) )]
obs <- matrix(rep(target2,10), byrow=T, nrow=10)
obs <- as.data.frame(obs)
obs <- do.call(cbind, lapply(obs, as.numeric))
################################################################################
colnames(sum)
sum <- as.data.frame(sum)

rf <- abcrf(x~., data=sum, 
      lda=TRUE, 
      ntree=1000,
      sampsize=min(5e4, nrow(data)),
      paral=TRUE, 
      ncores= 5)
rf
sink("allSC_RF1000trees_confussion_matrix_amongSC_directionalities.txt")
print(rf)
sink()
data1 <- data.frame(x, as.data.frame(sum))

#plot variable importance and display model position:
pdf(file="variable_importance_allSC.pdf")
plot(rf, data1, obs=as.data.frame(target2))

dev.off()

###################################################################################################
#model choice: 
print("Now performing model choice")
res <-  predict(rf, as.data.frame(target2), data1, ntree=500, paral=T)
res
write.table(res$vote,"RF1000trees_vote_allSC_directionalities.txt",
    quote=F,
    col.names=c("SC2M2N_A","SC2M2N_B","SC2M2N_C","SC2M2N_D","SC2M2N_AC","SC2M2N_BD","SC2M2N_ACBD" ),
    row.names=F)
write.table(cbind(res$allocation,res$post.prob),
    "RF1000trees_best_model_SC_directionalities.txt",
    quote=F,
    row.names=F,
    col.names=c("model","postprob"))

#### graphe des OOB: 
print("computing OOB")
pdf(file="OOB_1500_tree_error.SC2N2M_all.pdf")
err.abcrf(object = rf, training = data1, paral = TRUE)
dev.off()
