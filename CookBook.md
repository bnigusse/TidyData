---
title: "CookBook"
author: "nigusseba"
date: "February 16, 2016"
output: word_document
---


## Overview 
This document summarizes the variables names including their description and units, the intermediate 
data set created, and the procdures used to create the tidy data sets. The RScripts used are to download
the row data, merge the various pieces of data sets, tidy the data, and provide summary per the instruction. 

 
### The Variables Summary
The varDesctbl2 data.table provides summary of the variables names, the variable names 
description and the units for each variable generated using R code. There are 88 variable 
names summarized as a data.table data format. 
```{r, echo=FALSE}
summary(varDesctbl2)
```

### The merged Row Data
The "ttdata" data.frame is raw data created by merging the test and train data sets. The    
average of each variable categorized by activity and each subject. 
```{r, echo=TRUE}
dim(ttdata)
```


### The tidy Extrated Data
The "ttdatameanstd" data.frame is raw data created by extracted the mean and standard  
variables from merged row data set (ttdata). Also included are the activity and subjects 
are new columns.    
```{r, echo=TRUE}
dim(ttdatameanstd)
```

### The tidy Mean Data
The "ttdatafinal" data.frame is second independent tidy data set created with the   
mean(average) of each variable categorized by activity and each subject. 
The final data 
```{r, echo=FALSE}
summary(ttdatafinal)
```


## The Data Processing Steps

Set the working directory the current working directry and creates a subdirectory called "ProjData" 
if it does not exist.

```{r, echo=FALSE}
maindir <- "."
setwd(maindir)
subdir <- "ProjData"
if (! file.exists(subdir)){
    dir.create(file.path(maindir, subdir))
}
```

Download the the raw data into current workding directory and extracts the data into a subdirectory 
called *ProjData*. 

```{r, echo=FALSE}
fileUrl <- "https://d396qusza40orc.cloudfront.net/getdata%2Fprojectfiles%2FUCI%20HAR%20Dataset.zip?accessType=DOWNLOAD";
download.file(fileUrl,destfile="./ProjData/getdata-projectfiles-UCI HAR Dataset.zip",mode='wb')
unzip("./getdata-projectfiles-UCI HAR Dataset.zip", exdir = "./ProjData")
```

Reads the raw test data sets into a data.table xtest, ytest, subjecttest as follows:

```{r, echo=FALSE}
xtest <- read.table("./ProjData/UCI HAR Dataset/test/X_test.txt", header=F, sep = "")
ytest <- read.table("./ProjData/UCI HAR Dataset/test/y_test.txt", header=F, sep = "", col.names = "activity")
subjecttest <- read.table("./ProjData/UCI HAR Dataset/test/subject_test.txt", header=F, sep = "", col.names = "subject")
test <- cbind(xtest, ytest, subjecttest)
```

Reads the raw train data sets into a data.table xtrain, ytrain, subjecttrain as follows:

```{r, echo=FALSE}
xtrain <- read.table("./ProjData/UCI HAR Dataset/train/X_train.txt", header=F, sep = "")
ytrain <- read.table("./ProjData/UCI HAR Dataset/train/y_train.txt", header=F, sep = "", col.names="activity")
subjecttrain <- read.table("./ProjData/UCI HAR Dataset/train/subject_train.txt", header=F, sep="", col.names="subject")
train <- cbind(xtrain, ytrain, subjecttrain)
ttdata <- rbind(test, train)
```


This step extracts only the measurements on the mean and standard deviation for each measurement. First the  
column names are read from the "features.txt" data set and the variable names were converted to lower case. 
And the variables mean and std are extracted, then these variables are mapped to the raw data column index. 
Finally the data corresponding to these indicies. The Rcode for this setp is shows below.

```{r, echo=FALSE}
feature <- read.table("./ProjData/UCI HAR Dataset/features.txt", header=F, sep = "")
namesttdata <- c(tolower(feature[, 2]), "activity", "subject")
namesttdata2 <- c(c(grep("mean", namesttdata, value=TRUE), grep("std", namesttdata, value=TRUE)), "activity", "subject")
namesttdatabool <- namesttdata %in% namesttdata2
colIndex <- which(namesttdatabool == "TRUE")
ttdatameanstd <- ttdata[, colIndex]
colnames(ttdatameanstd) <- namesttdata2
```


Replace the numeric designation of the six activities by activity names. Firs the descriptive activity 
names are read and processed as follows.
```{r, echo=FALSE}
activity <- read.table("./ProjData/UCI HAR Dataset/activity_labels.txt", header=F, sep = "")
activityNames <- factor(activity[, 2])
activityVector <- activityNames[ttdatameanstd$activity]
names(activityVector) <- "activity"
ttdatameanstd$activity <- activityVector
```


This step appropriately labels the data set with descriptive variable names created using
the function *colNamesX*.
```{r, echo=FALSE}
colnames(ttdatameanstd) <- colNamesX(namesttdata2)
```


Created creates a second, independent tidy data set with the average of each 
variable for each activity and each subject.
```{r, echo=FALSE}
library(plyr)
ttdatafinal <- ddply(ttdatameanstd, .(activity, subject), colwise(mean))
ttdatafinal
```
