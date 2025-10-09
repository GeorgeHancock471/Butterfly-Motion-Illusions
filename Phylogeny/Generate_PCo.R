# INSTURCTIONS----

#Delete Library code if not GRAH
#Select all code and hit RUN

# GRAH Change Library----
# This code was made for GRAHs laptop due to a directory issue, please remove to run on your computer.
.libPaths()
new_library_path <- "C:\\Users\\Localadmin_hangeorg\\Documents\\RStudio\\library\\"
.libPaths(new_library_path)
setwd(dirname(rstudioapi::getSourceEditorContext()$path))


# Obtain PCos----

# Load necessary libraries
library(ape)
library(phytools)



# Read the Newick tree file
tree <- read.tree("European_Butterflies_Full_DropTipped_Wiemers_2023.nwk")

# Extract species names (tip labels)
Binomial <- tree$tip.label

# Print the species names
print(Binomial)

# Compute the cophenetic distance matrix
cophenetic_matrix <- cophenetic(tree)

# Convert it to a distance object
dist_matrix <- as.dist(cophenetic_matrix)

# Perform Principal Coordinates Analysis (PCoA)
pcoa_result <- cmdscale(dist_matrix, k = 3)  # Extract first 3 principal coordinates

# Convert to a data frame
pcoa_df <- as.data.frame(pcoa_result)
colnames(pcoa_df) <- c("PCo1", "PCo2", "PCo3")  # Rename columns for clarity

# Add species names (Binomial)
pcoa_df$Binomial <- Binomial

# Print the first few rows
head(pcoa_df)

# Save to CSV
write.csv(pcoa_df, "DF_Phylogeny_PCo.csv", row.names = FALSE)
