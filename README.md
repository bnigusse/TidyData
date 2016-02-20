---
title: "README.md"
author: "nigusseba"
date: "February 19, 2016"
output: word_document
---


## Running the Analysis
Source the *run_analysis.R* Rscript to run the complete analysis. This script finally writes a tidy data 
set to a tab separated tets file *tidydata.txt* 

```{r, echo=FALSE}

source('./run_analysis.R')
```

## Reading the Tidy Data Set
The tidy data set can be read back using the following R code for verification purpose. The checkdata data 
must be identical to data table *ttdatafinal*.

```{r, ech=FALSE}

checkdata <- read.table("./tidydata.txt", sep="\t", header=TRUE)
```

## Variables Description
The following set of R codes allow to generate the compact variable names, the variables description and 
their corresponding units as a data table format. If you riin the five lines of code you will generate the 
variable names dictionary for the tidy data of this project. The column names of the final data are saved 
in the environment variable called *namesttdata2*. The data.table *varDesctbl2* contains the variables
dictionaly.

```{r, ech=FALSE}

xNames <- colNamesX(namesttdata2)

x <- colNamesXX(xNames)

library(data.table)

varDesctbl <- data.table(varName = xNames, varDesc = x)

varDesctbl2 <- varDesctbl[, varUnits:= ifelse(grepl("acceleration", varDesc), "m/s^2", "radians/s")]

library(psych)

View(varDesctbl2)
```
