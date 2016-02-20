---
title: "CookBook"
author: "nigusseba"
date: "February 16, 2016"
output: word_document
---


## Overview 
This document summarizes the variables names including their description and units, the intermediate data set 
created, and the procdures used to create the tidy data sets. The RScripts used are to download the row data, 
merge the various pieces of data sets, tidy the data, and provide summary per the instruction. 

 
### The Variables Summary
The *varDesctbl2* data.table provides summary of the variables names, the variable names description and the units 
for each variable generated using R code. There are 88 variable names summarized as a data.table data format. 

```{r, echo=FALSE}
summary(varDesctbl2)
```

### Merged Row Data
The *ttdata* data.frame is raw data created by merging the test and train data sets. The average of each variable 
categorized by activity and each subject. 

```{r, echo=TRUE}
dim(ttdata)
```


### Tidy Extrated Data
The *ttdatameanstd* data.frame is raw data created by extracted the mean and standard variables from merged row 
data set *ttdata*. Also included are the activity and subjects are new columns.

```{r, echo=TRUE}
dim(ttdatameanstd)
```

### Tidy Average Data
The *ttdatafinal* data.frame is second independent tidy data set created with the mean(average) of each variable 
categorized by activity and each subject. 
 
```{r, echo=FALSE}
summary(ttdatafinal)
```


## Data Processing Steps
Set the working directory as the current working directry and expects the extracted data is placed in *UCI HAR Dataset* 
folder as the subdirectory that contains the *test* and *train* sub-sub directory that holds the data sets. Reads the 
raw test data sets into a data.table *xtest*, *ytest*, and *subjecttest* as follows:

```{r, echo=FALSE}

xtest <- read.table("./UCI HAR Dataset/test/X_test.txt", header=F, sep = "")

ytest <- read.table("./UCI HAR Dataset/test/y_test.txt", header=F, sep = "", col.names = "activity")

subjecttest <- read.table("./UCI HAR Dataset/test/subject_test.txt", header=F, sep = "", col.names = "subject")

test <- cbind(xtest, ytest, subjecttest)
```

Reads the raw train data sets into a data.table *xtrain*, *ytrain*, and *subjecttrain* as follows:

```{r, echo=FALSE}

xtrain <- read.table("./UCI HAR Dataset/train/X_train.txt", header=F, sep = "")

ytrain <- read.table("./UCI HAR Dataset/train/y_train.txt", header=F, sep = "", col.names="activity")

subjecttrain <- read.table("./UCI HAR Dataset/train/subject_train.txt", header=F, sep="", col.names="subject")

train <- cbind(xtrain, ytrain, subjecttrain)

ttdata <- rbind(test, train)
```


This step extracts only the measurements on the mean and standard deviation for each measurement. First the 
column names are read from the *features.txt* data set and the variable names were converted to lower case. 
And the variables mean and std are extracted, then these variables are mapped to the raw data column index. 
Finally the data corresponding to these indicies. The Rcode for this setp is shows below.

```{r, echo=FALSE}

feature <- read.table("./UCI HAR Dataset/features.txt", header=F, sep = "")

namesttdata <- c(tolower(feature[, 2]), "activity", "subject")

namesttdata2 <- c(c(grep("mean", namesttdata, value=TRUE), grep("std", namesttdata, value=TRUE)), "activity", "subject")

namesttdatabool <- namesttdata %in% namesttdata2

colIndex <- which(namesttdatabool == "TRUE")

ttdatameanstd <- ttdata[, colIndex]

colnames(ttdatameanstd) <- namesttdata2
```


Replace the numeric designation of the six activities by activity names. First the descriptive activity 
labels are read from the *activity_labels.txt* files and processed as follows.

```{r, echo=FALSE}

activity <- read.table("./UCI HAR Dataset/activity_labels.txt", header=F, sep = "")

activityNames <- factor(activity[, 2])

activityVector <- activityNames[ttdatameanstd$activity]

names(activityVector) <- "activity"

ttdatameanstd$activity <- activityVector
```


This step appropriately labels the data set with descriptive variable names created using the function *colNamesX*.

```{r, echo=FALSE}

colnames(ttdatameanstd) <- colNamesX(namesttdata2)
```

Creates a second, independent tidy data set with the average of each variable for each activity and each subject.

```{r, echo=FALSE}

library(plyr)

ttdatafinal <- ddply(ttdatameanstd, .(activity, subject), colwise(mean))

ttdatafinal
```

## Variables Dictionary Table
The following R code generated the variable dictionary.  The variables dictionay is a summary table that contains
the variable/column names, description of the variables and the units of the data.table *varDesctbl2*. The *View*
function displays the table if you run the following scripts.

``` {r, echo=FALSE}

xNames <- colNamesX(namesttdata2)

x <- colNamesXX(xNames)

library(data.table)

varDesctbl <- data.table(varName = xNames, varDesc = x)

varDesctbl2 <- varDesctbl[, varUnits:= ifelse(grepl("acceleration", varDesc), "m/s^2", "radians/s")] 

library(psych)

View(varDesctbl2)

```