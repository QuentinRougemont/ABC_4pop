#!/usr/bin/env Rscript

source('01.scripts/cv4abc.R')

if("data.table" %in% rownames(installed.packages()) == FALSE) 
{install.packages("data.table", repos="https://cloud.r-project.org") 
    print("installing packages data.table..." ) }
if("dplyr" %in% rownames(installed.packages()) == FALSE) 
{install.packages("dplyr", repos="https://cloud.r-project.org") 
    print("installing dplyr..." ) }

library(data.table)
library(dplyr)

target <- read.table("ABCstat.txt", T)

#load simulations
SC2M2N_C      <- fread("zcat 00.simuls/SC_2M_2N_C.ABCstat.txt.gz"   )
SI2N     <- fread("zcat 00.simuls/SI_2N_2m_none.ABCstat.txt.gz" )

f <- function(x){
    m <- mean(x, na.rm = TRUE)
    x[is.na(x)] <- m
    x
}


SI2N <- apply(SI2N, 2, f)
SC2M2N_C     <- apply(SC2M2N_C , 2, f)

### avec toutes les stats:
#keep std and avg statistics
nlinesFul=min(nrow(SC2M2N_C),
              nrow(SI2N))
x <- as.factor(c(rep(1:2,each=nlinesFul)))

sumstats <- as.data.frame(rbind
          (SC2M2N_C[c(1:nlinesFul),],
          SI2N[c(1:nlinesFul),]) )

#sumstats <- sumstats[, !grepl("f", names(sumstats) )]
#sumstats <- sumstats[,c(2:144)]
#target2 <-  target[, !grepl("f", names(target) )]
#target2 <- target2[,c(2:144)]

sumstats <- sumstats[, !grepl("G", names(sumstats) )]
sum <- do.call(cbind, lapply(sumstats, as.numeric))

target2 <-  target[, !grepl("G", names(target) )]
obs <- matrix(rep(target2,10), byrow=T, nrow=10)
obs <- as.data.frame(obs)
obs <- do.call(cbind, lapply(obs, as.numeric))

nlinesFul

t <- c(0.01,0.001)
for(tol in t){
res1 <- model_selection_abc_nnet(target=obs, 
                                 x=x, 
                                 sumstat= sum, 
                                 tol= tol ,
                                 noweight=F,
                                 rejmethod=F,
                                 nb.nnet=50,
                                 size.nnet=15,MaxNWts=4000,
                                 output=paste0("best_SC2N2M_C_vs_bestSI2N_all_stats.tol.",
                                               tol ,".txt") )
}
