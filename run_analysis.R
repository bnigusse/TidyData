## Load functions
colNamesX <- function(namesttdata2) {
        x <- namesttdata2
        x <- gsub("*[()*]", "", x)
        x <- gsub("-", " ", x)
        x <- gsub("^tbody", "tbody ", x)
        x <- gsub("^fbody", "fbody ", x)
        x <- gsub("^tgravity", "tgravity ", x)
        x <- gsub("^angletbody", "angle tbody", x)
        x <- gsub("accjerk", "acc jerk", x)
        x <- gsub("gyrojerk", "gyro jerk", x)
        x <- gsub("bodyacc", "body acc", x)
        x <- gsub("bodygyro", "body gyro", x)
        x <- gsub("gyromag", "gyro mag", x)
        x <- gsub("accmag", "acc mag", x)
        x <- gsub("jerkmag", "jerk mag", x)
        x <- gsub("gyromean", "gyro mean", x)
        x <- gsub("accmean", "acc mean", x)
        x <- gsub("jerkmean", "jerk mean", x)
        x <- gsub("meanfreq", "mean freq", x)
        x <- gsub("gravitymean", "gravity mean", x)
        x <- gsub(" x", " x-axis", x)
        x <- gsub(" y", " y-axis", x)
        x <- gsub(" z", " z-axis", x)
        return(x)
}


## 1. Merges the training and the test sets to create one data set.
### create a sub directory
maindir <- "."
setwd(maindir)
subdir <- "ProjData"
if (! file.exists(subdir)){
    dir.create(file.path(maindir, subdir))
}

### download the data into current workding directory
fileUrl <- "https://d396qusza40orc.cloudfront.net/getdata%2Fprojectfiles%2FUCI%20HAR%20Dataset.zip?accessType=DOWNLOAD";
download.file(fileUrl,destfile="./ProjData/getdata-projectfiles-UCI HAR Dataset.zip",mode='wb')
unzip("./getdata-projectfiles-UCI HAR Dataset.zip", exdir = "./ProjData")

### read X_test, y_test, and subjects_test text files
### ProjData\UCI HAR Dataset\test
xtest <- read.table("./ProjData/UCI HAR Dataset/test/X_test.txt", header=F, sep = "")
ytest <- read.table("./ProjData/UCI HAR Dataset/test/y_test.txt", header=F, sep = "", col.names = "activity")
subjecttest <- read.table("./ProjData/UCI HAR Dataset/test/subject_test.txt", header=F, sep = "", col.names = "subject")
test <- cbind(xtest, ytest, subjecttest)

xtrain <- read.table("./ProjData/UCI HAR Dataset/train/X_train.txt", header=F, sep = "")
ytrain <- read.table("./ProjData/UCI HAR Dataset/train/y_train.txt", header=F, sep = "", col.names="activity")
subjecttrain <- read.table("./ProjData/UCI HAR Dataset/train/subject_train.txt", header=F, sep="", col.names="subject")
train <- cbind(xtrain, ytrain, subjecttrain)
ttdata <- rbind(test, train)

## 2. Extracts only the measurements on the mean and standard deviation for each measurement.
feature <- read.table("./ProjData/UCI HAR Dataset/features.txt", header=F, sep = "")
namesttdata <- c(tolower(feature[, 2]), "activity", "subject")
namesttdata2 <- c(c(grep("mean", namesttdata, value=TRUE), grep("std", namesttdata, value=TRUE)), "activity", "subject")
namesttdatabool <- namesttdata %in% namesttdata2
colIndex <- which(namesttdatabool == "TRUE")
ttdatameanstd <- ttdata[, colIndex]
colnames(ttdatameanstd) <- namesttdata2

## 3. Uses descriptive activity names to name the activities in the data set
activity <- read.table("./ProjData/UCI HAR Dataset/activity_labels.txt", header=F, sep = "")
activityNames <- factor(activity[, 2])
activityVector <- activityNames[ttdatameanstd$activity]
names(activityVector) <- "activity"
ttdatameanstd$activity <- activityVector

## 4. Appropriately labels the data set with descriptive variable names.
colnames(ttdatameanstd) <- colNamesX(namesttdata2)

## 5. From the data set in step 4, creates a second, independent tidy data set  
## with the average of each variable for each activity and each subject.
library(plyr)
ttdatafinal <- ddply(ttdatameanstd, .(activity, subject), colwise(mean))

## write the final data to a te test file "tidydata.txt" to a sub directory ProjData
## under the current working directory 
write.table(ttdatafinal, "./ProjData/tidydata.txt", sep="\t", append=FALSE, quote=FALSE, col.names=TRUE)

## you can read the data 
checkdata <- read.table("./ProjData/tidydata.txt", sep="\t", header=TRUE)

## 6. Create table of variables, variables descrions and their unites
##  using RScrippt (This is optional)

colNamesXX <- function(xNames) {
        
        xNames <- gsub("^tbody", "Time domain body", xNames)
        xNames <- gsub("^fbody", "Fast Furiour Transform of body", xNames)
        xNames <- gsub("^tgravity", "Time domain gravitational", xNames)
        xNames <- gsub("gyro", "angular velocity", xNames)
        xNames <- gsub("acc", "acceleration", xNames)
        xNames <- gsub("jerk", "jerk", xNames)
        xNames <- gsub("mag", "magnitude", xNames)
        xNames <- gsub("std", "standard", xNames)
        xNames <- gsub("mean", "average", xNames)
        xNames <- gsub("freq", "in frequency domain", xNames)
        xNames <- gsub("x-axis", "in x-axis direction", xNames)
        xNames <- gsub("y-axis", "in y-axis direction", xNames)
        xNames <- gsub("z-axis", "in z-axis direction", xNames)
        xNames <- gsub("average,", "average or ", xNames)
        xNames <- gsub("body body", "body", xNames)
        xNames <- gsub("activity", "Activity levels: Walking, Walking_upstairs, Walking_downstairs, Sitting, Standing, Laying", xNames)
        xNames <- gsub("subject", "Volunteers within an age bracket of 19-48 years participated in the experiment", xNames)
        return(xNames)
}

xNames <- colNamesX(namesttdata2)
x <- colNamesXX(xNames)
library(data.table)
varDesctbl <- data.table(varName = xNames, varDesc = x)
varDesctbl2 <- varDesctbl[, varUnits:= ifelse(grepl("acceleration", varDesc), "m/s^2", "radians/s")] 
library(psych)
View(varDesctbl2)


