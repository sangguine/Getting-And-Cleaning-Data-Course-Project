## You should create one R script called run_analysis.R that does the following.

## Merges the training and the test sets to create one data set.
## Extracts only the measurements on the mean and standard deviation for each measurement.
## Uses descriptive activity names to name the activities in the data set
## Appropriately labels the data set with descriptive variable names.
## From the data set in step 4, creates a second, independent tidy data set with the average of each variable for each activity and each subject.


if (!require("reshape2")) {
  install.packages("reshape2")
}

if (!require("data.table")) {
  install.packages("data.table")
}

require("reshape2")
require("data.table")

# Load data from files
activity_labels <- read.table("./UCI HAR Dataset/activity_labels.txt")[,2]
features <- read.table("./UCI HAR Dataset/features.txt")[,2]
X_test <- read.table("./UCI HAR Dataset/test/X_test.txt")
y_test <- read.table("./UCI HAR Dataset/test/y_test.txt")
subject_test <- read.table("./UCI HAR Dataset/test/subject_test.txt")

# Process x_test data
names(X_test) <- features
mean_std_measurements_logic <- grepl("mean|std", features)
mean_std_measurements_test <- X_test[,mean_std_measurements_logic]

# Process y_test data
y_test[,2] <- activity_labels[y_test[,1]]
names(y_test) <- c("Activity_Num", "Activity")

# Process subject_test data
names(subject_test) <- "Subject"

# Column bind 3 data sets
test_data <- cbind(as.data.table(subject_test), y_test, X_test)

# Load and process train data.
X_train <- read.table("./UCI HAR Dataset/train/X_train.txt")
y_train <- read.table("./UCI HAR Dataset/train/y_train.txt")
subject_train <- read.table("./UCI HAR Dataset/train/subject_train.txt")

# Process x_train data
names(X_train) <- features
mean_std_measurements_train <- X_train[,mean_std_measurements_logic]
y_train[,2] <- activity_labels[y_train[,1]]
names(y_train) <- c("Activity_Num", "Activity")
names(subject_train) <- "Subject"

# Column bind data
train_data <- cbind(as.data.table(subject_train), y_train, X_train)

# Merge the two data sets
data <- rbind(test_data, train_data)
labels <- c("Subject", "Activity_Num", "Activity")
melt_data_labels <- setdiff(colnames(data), labels)
melt_data <- melt(data, id = labels, measure.vars = melt_data_labels)

# Find mean
tidydata <- dcast(melt_data, Subject + Activity ~ variable, mean)

# Output
write.table(tidydata, file <- "./tidydata.txt", row.names <- FALSE)
