# Author: Nathalie van Hees, 11 March 2016.

packages <- c("utils", "data.table", "plyr", "dplyr")
if (length(setdiff(packages, rownames(installed.packages()))) > 0) {
    install.packages(setdiff(packages, rownames(installed.packages())))  
}

fileUrl <- "https://d396qusza40orc.cloudfront.net/getdata%2Fprojectfiles%2FUCI%20HAR%20Dataset.zip"
if (!file.exists("./UCI_HAR_Dataset.zip")) {download.file(fileUrl, destfile = "./UCI_HAR_Dataset.zip") 
}

DateDownloaded <- date()
print(DateDownloaded)
list.files()

library("utils")
unzip("UCI_HAR_Dataset.zip")

library(data.table)
TrainDataset <- data.table(read.table("./UCI HAR Dataset/train/X_train.txt"))
TestDataset <- data.table(read.table("./UCI HAR Dataset/test/X_test.txt"))
activity_labels <- data.table(read.table("./UCI HAR Dataset/activity_labels.txt"))
features <- data.table(read.table("./UCI HAR Dataset/features.txt"))
TrainActLabels <- data.table(read.table("./UCI HAR Dataset/train/Y_train.txt"))
TestActLabels <- data.table(read.table("./UCI HAR Dataset/test/Y_test.txt"))
subjectNrtrain <- data.table(read.table("./UCI HAR Dataset/train/subject_train.txt"))
subjectNrtest <- data.table(read.table("./UCI HAR Dataset/test/subject_test.txt"))

colnames(TrainDataset) <- as.character(features$V2)
colnames(TestDataset) <- as.character(features$V2)

TrainDataset$RowNumber <- as.numeric(rownames(TrainDataset))
TestDataset$RowNumber <- as.numeric(rownames(TestDataset))

TrainDataset$Condition <- "Train"
TestDataset$Condition <- "Test"

library(dplyr)
TestTotal <- mutate(TestDataset, Activity = TestActLabels$V1,SubjectNr = subjectNrtest$V1)
TrainTotal <- mutate(TrainDataset, Activity = TrainActLabels$V1,SubjectNr = subjectNrtrain$V1)

TestTrain <- rbind(TestTotal,TrainTotal)

TestTrainMeanStd <- select(TestTrain, Activity, SubjectNr, contains("-mean()"), contains("-std()")) 

library(plyr)
TestTrainMeanStd$Activity <- mapvalues(TestTrainMeanStd$Activity, 
                                       from = c("1", "2", "3", "4", "5", "6"), 
                                       to = c("WALKING", "WALKING_UPSTAIRS", "WALKING_DOWNSTAIRS", "SITTING", "STANDING", "LAYING"))

names(TestTrainMeanStd) <- gsub("\\(", "", names(TestTrainMeanStd))
names(TestTrainMeanStd) <- gsub("\\)", "", names(TestTrainMeanStd))
names(TestTrainMeanStd) <- gsub("\\-", "", names(TestTrainMeanStd))
names(TestTrainMeanStd) <- gsub("^t", "time", names(TestTrainMeanStd))
names(TestTrainMeanStd) <- gsub("^f", "frequency", names(TestTrainMeanStd))
names(TestTrainMeanStd) <- gsub("Acc", "Accelerometer", names(TestTrainMeanStd))
names(TestTrainMeanStd) <- gsub("Gyro", "Gyroscope", names(TestTrainMeanStd))
names(TestTrainMeanStd) <- gsub("Mag", "Magnitude", names(TestTrainMeanStd))
names(TestTrainMeanStd) <- gsub("BodyBody", "Body", names(TestTrainMeanStd))
names(TestTrainMeanStd) <- tolower(names(TestTrainMeanStd))

meandata<-aggregate(. ~subjectnr + activity, TestTrainMeanStd, mean)
meandata<-meandata[order(meandata$subject,meandata$activity),]

write.table(meandata, file = "tidydataset.txt",row.name=FALSE)

