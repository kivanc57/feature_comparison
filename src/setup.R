# Install renv if not installed
if (!requireNamespace("renv", quietly=TRUE)) {
  install.packages("renv")
}

# Initialize it if not initialized
if (!file.exists("renv.lock")) {
  renv::init()
}
