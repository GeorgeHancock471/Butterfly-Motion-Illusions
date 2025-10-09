# INSTURCTIONS----

#Delete Library code if not GRAH
#Select all code and hit RUN

# GRAH Change Library----
# This code was made for GRAHs laptop due to a directory issue, please remove to run on your computer.
.libPaths()
new_library_path <- "C:\\Users\\Localadmin_hangeorg\\Documents\\RStudio\\library\\"
.libPaths(new_library_path)
setwd(dirname(rstudioapi::getSourceEditorContext()$path))



# Load Libraries ----
library(ape)
library(ggplot2)

# Set working directory (adjust or skip if not needed)
setwd(dirname(rstudioapi::getSourceEditorContext()$path))


# Load tree and metadata ----
tree <- read.tree("European_Butterflies_Full_DropTipped_Wiemers_2023.nwk")
info <- read.csv("DF_Info_Table.csv", header = TRUE)

# Standardize binomial names: replace underscores with spaces and trim
tree$tip.label <- gsub("_", " ", tree$tip.label)
tree$tip.label <- trimws(tree$tip.label)
tree$tip.label <- gsub(" ", "_", tree$tip.label)
info$Binomial <- gsub("_", " ", info$Binomial)
info$Binomial <- trimws(info$Binomial)
info$Binomial <- gsub(" ", "_", info$Binomial)



# Get the species in the info sheet ----
keep_tips <- info$Binomial

# Drop tips from the tree that are not in your info table
tree <- drop.tip(tree, setdiff(tree$tip.label, keep_tips))



# Obtain Coordinates ----
# Plot the tree using a fan
plot(tree, type = "fan", show.tip.label = FALSE)
axisPhylo()

# Retrieve the plot data 
lastPP <- get("last_plot.phylo", envir = .PlotPhyloEnv)

# Extract the number of tips
ntip <- lastPP$Ntip

# Extract the coordinates for the tips
xy <- data.frame(x = lastPP$xx[1:ntip], y = lastPP$yy[1:ntip])

# Calculate the angle for each tip (using atan2, which gives the angle in radians)
angles <- atan2(xy$y, xy$x)

# Convert angles from radians to degrees
angles_deg <- angles * (180 / pi)

# Create a new data frame with tip names and their corresponding angles and coordinates
tip_names <- tree$tip.label
tip_angles <- data.frame(Binomial = tip_names, Angle_deg = angles_deg, phy_x = xy$x, phy_y = xy$y)

# Optionally, print the first few rows to check the data
head(tip_angles)

# Merge the info data frame with tip_angles based on the Binomial column
merged_data <- merge(tip_angles,info,  by = "Binomial", all.x = TRUE)

# Optionally, check the merged data
head(merged_data)

# Save merged data to CSV if needed
write.csv(tip_angles, "DF_Phylogeny_Tip.csv", row.names = FALSE)

# Create Circular Phylogeny .SVG ----

merged_data$Family_Ring <- factor(merged_data$Family, 
                                  levels = c("Papilionidae", "Hesperiidae", "Pieridae", 
                                             "Riodinidae", "Lycaenidae", "Nymphalidae"))

FamilyPalette_Ring <- c("#F27072", "#8D5757", "#FAF28D", "#945495", "#81CFCF", "#569157")
family_colors_named <- setNames(FamilyPalette_Ring, levels(merged_data$Family_Ring))

#Create a named vector of Family by Binomial
family_by_species <- setNames(as.character(merged_data$Family_Ring), merged_data$Binomial)

#Order families to match tree tip labels
ordered_families <- family_by_species[tree$tip.label]

#Assign tip colors using the named palette
tip_colors <- family_colors_named[ordered_families]

#Plot the tree

# Assign colors to branches based on family
family_colors_edges <- family_colors_named[family_by_species[tree$tip.label]]
# Save SVG without date
svg("Circular_Phylogeny_NoDate.svg", width = 5, height = 5) 
par(mar = c(1, 1, 1, 1))  # Optional: adjust top margin for title
# Plot the tree
plot(tree, type = "fan", show.tip.label = FALSE, main = "")
tiplabels(pch = 21, bg = tip_colors, col = tip_colors, cex = 1)
# Close the device
dev.off()


# Save SVG without date
svg("Circular_Phylogeny_WithDate.svg", width = 5, height = 5) 
par(mar = c(1, 1, 1, 1))  # Optional: adjust top margin for title
# Plot the tree
plot(tree, type = "fan", show.tip.label = FALSE, main = "")
tiplabels(pch = 21, bg = tip_colors, col = tip_colors, cex = 1)
axisPhylo()
# Close the device
dev.off()





