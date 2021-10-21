#!/usr/bin/env Rscript
#script to compare SC models among them
source('00.scripts/Rscripts/cv4abc.R')

#check if package are installed and donwload 
if("data.table" %in% rownames(installed.packages()) == FALSE) 
{install.packages("data.table", repos="https://cloud.r-project.org") 
    print("installing packages data.table..." ) }
if("dplyr" %in% rownames(installed.packages()) == FALSE) 
{install.packages("dplyr", repos="https://cloud.r-project.org") 
    print("installing dplyr..." ) }

library(data.table)
library(dplyr)

#load observed data
target <- read.table("ABCstat.txt", T)

#load simulations
SC2M2N_A      <- fread("zcat 00.simuls/SC_2M_2N_A.ABCstat.txt.gz"   )
SC2M2N_D      <- fread("zcat 00.simuls/SC_2M_2N_D.ABCstat.txt.gz"   )
SC2M2N_C      <- fread("zcat 00.simuls/SC_2M_2N_C.ABCstat.txt.gz"   )
SC2M2N_B      <- fread("zcat 00.simuls/SC_2M_2N_B.ABCstat.txt.gz"   )

f <- function(x){
    m <- mean(x, na.rm = TRUE)
    x[is.na(x)] <- m
    x
}
SC2M2N_A     <- apply(SC2M2N_A , 2, f)
SC2M2N_B     <- apply(SC2M2N_B , 2, f)
SC2M2N_C     <- apply(SC2M2N_C , 2, f)
SC2M2N_D     <- apply(SC2M2N_D , 2, f)

######## prepare data ################################################
nlinesFul=min(nrow(SC2M2N_A),
              nrow(SC2M2N_B),
              nrow(SC2M2N_C),
              nrow(SC2M2N_D)
	      )
x <- as.factor(c(rep(1:4,each=nlinesFul)))

sumstats <- as.data.frame(rbind(
          SC2M2N_A[c(1:nlinesFul),],
          SC2M2N_B[c(1:nlinesFul),],
          SC2M2N_C[c(1:nlinesFul),],
          SC2M2N_D[c(1:nlinesFul),]))

sumstats <- sumstats[, !grepl("G", names(sumstats) )]
sum <- do.call(cbind, lapply(sumstats, as.numeric))

target2 <-  target[, !grepl("G", names(target) )]
obs <- matrix(rep(target2,10), byrow=T, nrow=10)
obs <- as.data.frame(obs)
obs <- do.call(cbind, lapply(obs, as.numeric))

nlinesFul

###### perform model selection ###############################################
t <- c(0.0025,0.01) #0.005, etc

for(tol in t){
res1 <- model_selection_abc_nnet(target=obs, 
                                 x=x, 
                                 sumstat= sum, 
                                 tol= tol ,
                                 noweight=F,
                                 rejmethod=F,
                                 nb.nnet=50,
                                 size.nnet=15,MaxNWts=4000,
                                 output=paste0("SC2N2M_A_B_C_D_comparison_all_stats.tol.",
                                               tol ,".txt") )
}
