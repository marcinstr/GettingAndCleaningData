# You should create one R script called run_analysis.R that does the following.

# 1. Merges the training and the test sets to create one data set.
# 2. Extracts only the measurements on the mean and standard deviation for each measurement.
# 3. Uses descriptive activity names to name the activities in the data set
# 4. Appropriately labels the data set with descriptive variable names.
# 5. From the data set in step 4, creates a second, independent tidy data set with the average of each variable for each activity and each subject.

if (!require("data.table")) install.packages("data.table")


if (!require("reshape2")) install.packages("reshape2") 

require("data.table")
require("reshape2")

# Firstly, load the activity labels...
ActivityLabels <- read.table("./UCI HAR Dataset/activity_labels.txt")[,2]

# ... and the names of data columns.
Features <- read.table("./UCI HAR Dataset/Features.txt")[,2]

# Secondly, extract the measurements on the mean and standard deviation for each measurement.
ExtractedFeatures <- grepl("mean|std", Features)

# Then, load and process X_Test & Y_Test data.
X_Test <- read.table("./UCI HAR Dataset/test/x_test.txt")
Y_Test <- read.table("./UCI HAR Dataset/test/y_test.txt")
SubjectTest <- read.table("./UCI HAR Dataset/test/subject_test.txt")
names(X_Test) = Features

# For X_Test, extract only the measurements on the mean and standard deviation for each measurement.
X_Test = X_Test[,ExtractedFeatures]

# Load activity labels from Y_Test.
Y_Test[,2]         = ActivityLabels[Y_Test[,1]]
names(Y_Test)      = c("Activity_ID", "Activity_Label")
names(SubjectTest) = "subject"

# Then, bind the data using cbind function.
TestData <- cbind(as.data.table(SubjectTest), Y_Test, X_Test)

# Again, load and process X_Train & Y_Train data.
X_Train <- read.table("./UCI HAR Dataset/train/X_train.txt")
Y_Train <- read.table("./UCI HAR Dataset/train/y_train.txt")
SubjectTrain <- read.table("./UCI HAR Dataset/train/subject_train.txt")
names(X_Train) = Features

# For X_Train, extract only the measurements on the mean and standard deviation for each measurement.
X_Train = X_Train[,ExtractedFeatures]

# Load activity data  from Y_Train.
Y_Train[,2]         = ActivityLabels[Y_Train[,1]]
names(Y_Train)      = c("Activity_ID", "Activity_Label")
names(SubjectTrain) = "subject"

# Then, bind the data using cbind function.
TrainData <- cbind(as.data.table(SubjectTrain), Y_Train, X_Train)

# Merge TestData and TrainData.
Data        = rbind(TestData, TrainData)
IDlabels    = c("subject", "Activity_ID", "Activity_Label")
DataLabels  = setdiff(colnames(Data), IDlabels)
MergedData  = melt(Data, id = IDlabels, measure.vars = DataLabels)

# Apply mean function to the gathered dataset.
TidyData    = dcast(MergedData, subject + Activity_Label ~ variable, mean)

# Finally, write the TidyData textfile
write.table(TidyData, file = "./TidyData.txt",row.name=FALSE)
