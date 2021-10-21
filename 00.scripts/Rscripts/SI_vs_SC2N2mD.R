#!/usr/bin/env Rscript

source('01.scripts/cv4abc.R')

if("data.table" %in% rownames(installed.packages()) == FALSE) 
{install.packages("data.table", repos="https://cloud.r-project.org") 
    print("installing packages data.table..." ) }
if("dplyr" %in% rownames(installed.packages()) == FALSE) 
{install.packages("dplyr", repos="https://cloud.r-project.org") 
    print("installing dplyr..." ) }
if("abc" %in% rownames(installed.packages()) == FALSE) 
{install.packages("abc", repos="https://cloud.r-project.org") 
    print("installing packages abc..." ) }
if("abcrf" %in% rownames(installed.packages()) == FALSE) 
{install.packages("abcrf", repos="https://cloud.r-project.org") 
    print("installing packages abcrf..." ) }


library(data.table)
library(dplyr)
library(abc)
library(abcrf)

target <- read.table("ABCstat.txt", T)

#load simulations
SC2M2N_D      <- fread("zcat 00.simuls/SC_2M_2N_D.ABCstat.txt.gz"   )
SI2N     <- fread("zcat 00.simuls/SI_2N_2m_none.ABCstat.txt.gz")

f <- function(x){
    m <- mean(x, na.rm = TRUE)
    x[is.na(x)] <- m
    x
}

SI2N <- apply(SI2N, 2, f)
SC2M2N_D     <- apply(SC2M2N_D    , 2, f)
###### SC C vs SI   ##################################
nlinesFul=min(nrow(SI2N),
	      nrow(SC2M2N_D))
x <- as.factor(c(rep(1:2,each=nlinesFul)))
sumstats <- as.data.frame(rbind
          (SI2N[c(1:nlinesFul),],
           SC2M2N_D[c(1:nlinesFul),]) )

sumstats <- sumstats[, !grepl("G", names(sumstats) )]
sum <- do.call(cbind, lapply(sumstats, as.numeric))

target2 <-  target[, !grepl("G", names(target) )]
obs <- matrix(rep(target2,10), byrow=T, nrow=10)
obs <- as.data.frame(obs)
obs <- do.call(cbind, lapply(obs, as.numeric))

tol <- 0.0025
res1 <- model_selection_abc_nnet(target=obs[,-1], 
                                 x=x, 
                                 sumstat= sum[,-1], 
                                 tol= tol ,
                                 noweight=F,
                                 rejmethod=F,
                                 nb.nnet=50,
                                 size.nnet=15,MaxNWts=4000,
                                 output=paste0("SI2N_vs_SC2M2N_D.tol.",
                                               tol ,".txt") )
tol <- 0.01
res1 <- model_selection_abc_nnet(target=obs[,-1], 
                                 x=x, 
                                 sumstat= sum[,-1], 
                                 tol= tol,
                                 noweight=F,
                                 rejmethod=F,
                                 nb.nnet=50,
                                 size.nnet=15,MaxNWts=4000,
                                 output=paste0("SI2N_vs_SC2M2N_D.tol.",
                                               tol ,".txt") )


