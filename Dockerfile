# STAGE 1: Base setup and necessary dependencies installation
# Fetch an R image and use it as base
FROM rocker/r-base:4.4.0 AS base

# Install necessary dependencies
# Install necessary dependencies
RUN apt-get update --fix-missing && \
    apt-get install -y \
    libcurl4-openssl-dev \
    libssl-dev \
    libxml2-dev \
    libpng-dev \
    libjpeg-dev \
    libtiff-dev && \
    apt-get clean && \
    rm -rf /var/lib/apt/lists/*

# Install project-dependent packages
RUN R -e "install.packages(c('tidyverse', 'cluster', 'Hmisc', 'plotly', 'ggfortify', 'factoextra', 'NbClust', 'ggpubr', 'dplyr', 'PerformanceAnalytics', 'ggplot2'), repos='https://cloud.r-project.org/')"

# STAGE 2: Build the environment and install project
FROM base as builder

# Set the working directory
WORKDIR /home/R_feature_comparison

# Copy 'src' folder
COPY src ./src

# Run setup.R to install project-dependent packages
RUN Rscript ./src/setup.R


# STAGE 3: Final image with a leaner setup
FROM base AS final

# Set the working directory
WORKDIR /home/R_feature_comparison

# Copy renv.lock and src from builder stage
COPY --from=builder renv.lock ./renv.lock
COPY --from=builder src ./src

# Restore the environment
RUN Rscript -e "install.packages('renv'); renv::restore(lockfile = 'renv.lock')"
