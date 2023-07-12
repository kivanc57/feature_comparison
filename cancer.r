library(tidyverse)
library(cluster)
library(Hmisc)
library(plotly)
library(ggfortify)
library(factoextra)
library(NbClust)
library(ggpubr)
library(dplyr)
library(PerformanceAnalytics)
library(ggplot2)

data <- read.csv("/Users/admin/Desktop/Workplace/Data/cancer.csv", sep=",", row.names=1, stringsAsFactors = T)
data
nrow(data)
ncol(data)
head(data)
view(data)
colnames(numerical_data)


#Exporting data for Excel
export_data <- data[,1] %>% mutate_if(is.numeric, round, digits=3)
export_data$X <- data$X
export_data$diagnosis <- data$diagnosis

# We write the table as txt then extract it to an Excel file.
# The reason behind, direct Excel processes is not recommended with R.
write.table(export_data, file='/Users/admin/Desktop/data.txt', sep=',', row.names = T)

#remove NA's located on X from the df
data_rest <- data[, -32]

#Excluding the data$diagnosis for the sake of analysis since it's binary
numerical_data <- data_rest[, -1]
numerical_data_scaled <- scale(numerical_data)

#round numbers in columns and take the sum of all
summary_data <- round(apply(numerical_data, 2, summary),3)
clip <- pipe("pbcopy", "w")                       
write.table(summary_data, file=clip, sep = '\t', row.names = FALSE)                               
close(clip)

#Assigned new indexes to see and differenciate the entitites easily
rownames(data_rest) <- NULL
rownames(numerical_data) <- NULL

#Boxplot of each feature
png("/Users/admin/Desktop/boxplot.png", width = 20, height = 10, units = 'in', res = 300)
boxplot(scale(numerical_data),
        col = rainbow( ncol(numerical_data)),
        notch = TRUE,
        xlab = "Features",
        ylab = "Values")
dev.off()


#scatter plot (radius_mean, perimeter mean)
png("/Users/admin/Desktop/scatter_plot.png", width = 4, height = 4, units = 'in', res = 300)
ggplot(data = data_rest, mapping = aes(x = data_rest$radius_mean, y = data_rest$perimeter_mean)) +
  geom_point(mapping = aes(color = diagnosis)) +
  labs(x = "radius_mean",
       y = "perimeter_mean")
dev.off()

boxplot(scale(numerical_data),
        col = rainbow( ncol(numerical_data)),
        notch = TRUE,
        xlab = "Features",
        ylab = "Values")

#correlation graph with PerformanceAnalytics
chart.Correlation(numerical_data, histogram=TRUE, pch="+",  method = "pearson")
chart.Correlation(numerical_data, histogram=TRUE, pch="+",  method = "spearman")

#Correlation significance levels (p-values both for Pearson's and Spearman's)
corr_matrix <- as.matrix(round(cor(numerical_data)), 2)
corr_matrix[corr_matrix< 0.05]=NA
corr_matrix

#PCA Matrix
#The relations of the features is illustrated by PCA in different 2D space.
#We may also observer the features as vector thanks to eigen-vectors.
PCA_result <- prcomp(numerical_data, center = TRUE, scale. = TRUE)
summary(PCA_result)
PCA_plot <- autoplot(PCA_result, data = data_rest, colour = 'diagnosis',label.size = 3, shape = FALSE,
              loadings = TRUE, loadings.colour = 'blue',
              loadings.label = TRUE, loadings.label.size = 2)
ggplotly(PCA_plot)


#How to find the optional cluster number
set.seed(1)
NbClust(numerical_data, distance = "euclidean", min.nc = 2,
              max.nc = 10, method = "kmeans")
#K-means graph
km.res <- kmeans(numerical_data_scaled, 2)
fviz_cluster(km.res, numerical_data, ellipse.type = "norm", repel = TRUE)
ggsave("kmeans_graph.png")
pam.res <- pam(numerical_data_scaled, 2)
# Visualize pam clustering
fviz_cluster(pam.res, geom = "point", ellipse.type = "norm")
