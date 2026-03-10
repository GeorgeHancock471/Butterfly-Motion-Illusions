# INSTURCTIONS----


# Libraries
#..............

library(tidyverse)
library(ggimage)
library(ggplot2)
library(ggpattern)
library(lme4)
library(LMERConvenienceFunctions)
library(lmerTest)
library(tidyr)
library(circular)
library(MASS)
library(dplyr)
library(ggfx)
library(randomForest)
library(caret)
library(iml)
library(dplyr)
library(rpart)
library(rpart.plot)
library(emmeans)

# Set working directory (adjust or skip if not needed)
setwd(dirname(rstudioapi::getSourceEditorContext()$path))

#DATA, Import and process datasets-----------
EMDdata <- read.csv("./DF_EMD.csv", header=TRUE) # EMD data with spatial sig 8 and temp sig 5
PATdata <- read.csv("./DF_Pattern_Analysis.csv", header=TRUE) # Pattern measures
WINGdata <- read.csv("./DF_Wing_Shape.csv", header=TRUE) # Wingshape measures
INFOdata <- read.csv("./DF_Info_Table.csv", header=TRUE) # Butterfly ID info
PHYLOdata <- read.csv("./DF_Phylogeny_PCo.csv", header=TRUE) # Phylogeny Principal Coordinates (PCo)
TIPdata <- read.csv("./DF_Phylogeny_Tip.csv", header=TRUE) # Phylogeny tip x and y coordinates
CIEdata <-  read.csv("./DF_CIE.csv", header=TRUE) # Wing CIELAB measures
SIZEdata <-  read.csv("./DF_Size_Wbf.csv", header=TRUE) # Butterfly size measures

nrow(PHYLOdata)
nrow(TIPdata)
nrow(INFOdata)

dataSet=EMDdata
nrow(dataSet)

dataSet = merge(dataSet,PATdata)
dataSet = merge(dataSet,WINGdata)
dataSet = merge(dataSet,INFOdata)
dataSet = merge(dataSet,CIEdata)
dataSet = merge(dataSet,SIZEdata)

nrow(dataSet) #9084
dataSet = merge(dataSet,PHYLOdata)
dataSet = merge(dataSet,TIPdata)
nrow(dataSet) # 9084
# dataSet size is correct



## Add and adjust variables ----
dataSet$sex <- as.factor(dataSet$sex)
dataSet$treatment <- as.factor(dataSet$treatment)


dataSet$label_treatment <- paste(dataSet$label, dataSet$treatment)
dataSet$label_treatment <- as.factor(dataSet$label_treatment)

dataSet$sex <- as.factor(dataSet$sex)
dataSet$treatment <- as.factor(dataSet$treatment)


levels(dataSet$treatment)[levels(dataSet$treatment)=="orig"] <- "PatternedDynamic" 
levels(dataSet$treatment)[levels(dataSet$treatment)=="glide"] <- "PatternedGlide" 
levels(dataSet$treatment)[levels(dataSet$treatment)=="grey"] <- "UnpatternedDynamic" 
levels(dataSet$treatment)[levels(dataSet$treatment)=="greyglide"] <- "UnpatternedGlide" 

dataSet$treatment <- factor(dataSet$treatment, levels = sort(levels(dataSet$treatment)))

dataSet$flightMode = ifelse(dataSet$treatment=="PatternedGlide" | dataSet$treatment=="UnpatternedGlide","gliding","flapping")

dataSet$patterned = ifelse(dataSet$treatment=="PatternedDynamic" | dataSet$treatment=="PatternedGlide","patterned","unpatterned")


dataSet$Forwards_Energy = dataSet$up_mean

attach(dataSet)
dataSet$morphoType = paste(dataSet$genusSpecies,"_",dataSet$sex,sep="")
dataSet$wingDir = paste(dataSet$morphoType,".png",sep="")
dataSet$imdDir <- paste(dirname(rstudioapi::getSourceEditorContext()$path), "/R_PNGs/", dataSet$wingDir,sep="")
dataSet$imdDirS <- paste(dirname(rstudioapi::getSourceEditorContext()$path), "/R_PNGs_unscaled/", dataSet$wingDir,sep="")

head(dataSet)

attach(dataSet)

# Up = forwards-energy
# Down = backwards-energy
# Left = left-energy
# Right = right-energy

###Create motion confusion measures ----


#Mc Contrast for backwards-forwards
dataSet$Forwards_Confusion= (down_mean-up_mean)/(down_mean+up_mean)

#Mc Contrast for sideways - forwards
dataSet$Sideways_Energy = left_mean/2+right_mean/2
attach(dataSet)
dataSet$Sideways_Confusion = (Sideways_Energy -up_mean)/(Sideways_Energy +up_mean)

#Relabel forwards energy
dataSet$Forwards_Energy = up_mean


#Scaled versions
dataSet$Forwards_Confusion_scaled = scale(dataSet$Forwards_Confusion)
dataSet$Sideways_Confusion_scaled = scale(dataSet$Sideways_Confusion)




## Colour Palettes ----
FamilyPalette_Alphabet = c("#8D5757","#81CFCF","#569157","#F27072","#FAF28D","#945495")
FamilyPalette_Ring = c("#8D5757","#81CFCF","#569157","","","")

dataSet$Family_Ring = factor(dataSet$Family, levels = c("Papilionidae","Hesperiidae","Pieridae","Riodinidae","Lycaenidae","Nymphalidae"))
FamilyPalette_Ring = c("#F27072","#8D5757","#FAF28D","#945495","#81CFCF","#569157")



#DATA, Screen data ----

## N - Species ----

d=subset(dataSet,render_method=="Patterned" & wing=="forewing" & flight_method=="Flapping" )
unique(d$Binomial)
# 397, species

## N - Morphotypes ----

d=subset(dataSet,render_method=="Patterned" & wing=="forewing" & flight_method=="Flapping" )
unique(d$morphoType)
# 757, morphotypes with phylogeny data included.



# PHYLOGENY ----
##................................
## What do the PCos Represent----
d=subset(dataSet,render_method=="Patterned" & wing=="forewing" & flight_method=="Flapping" )

##. Coordinates (supp)----
p = ggplot(d, aes(x=PCo1,y=PCo2)) + 
  geom_image(aes(image = imdDir), size = 0.07) +  # Images
  geom_point(aes(fill = Family_Ring), shape = 21, size = 3) +
  labs(title = "",
       fill = "Butterfly Family")+ 
  theme_light()

p
# Save SVG
svg("Sup_PCos_1&2.svg", width = 5, height = 4) 
p
dev.off()


p = ggplot(d, aes(x=PCo1,y=PCo3)) + 
  geom_image(aes(image = imdDir), size = 0.07) +  # Images
  geom_point(aes(fill = Family_Ring), shape = 21, size = 3) +
  labs(title = "",
       fill = "Butterfly Family")+ 
  theme_light()
# Save SVG
p
svg("Sup_PCos_1&3.svg", width = 5, height = 4) 
p
dev.off()


## . PCo 1 (supp)----
expV=1.2
p =ggplot(d, aes(x = phy_x * 1, y = phy_y * 1)) +
  # Family-colored points
  geom_point(aes(fill = Family_Ring), shape = 21, size = 3) +
  geom_point(aes(col = PCo1,x = phy_x * expV, y = phy_y * expV), shape = 16, size = 3) +
  labs(title = "",
       fill = "Butterfly\nFamily",
       color = "Principal\nCoordinate 1")+ 
  theme_void() + coord_fixed() 

# High PCo1 largely corresponds with Nymphalids, namely Satyrinae
p
# Save SVG
svg("Sup_PCo1_ring.svg", width = 4, height = 4) 
p
dev.off()




## . PCo 2 (supp)----
p =ggplot(d, aes(x = phy_x * 1, y = phy_y * 1)) +
  # Family-colored points
  geom_point(aes(fill = Family_Ring), shape = 21, size = 3) +
  geom_point(aes(col = PCo2,x = phy_x * expV, y = phy_y * expV), shape = 16, size = 3) +
  labs(title = "",
       fill = "Butterly\nFamily",
       color = "Principle\nCoordinate 2")+ 
  theme_void() + coord_fixed() 

# High PCo2 largely corresponds with Hesperiidae and adjacent Papilionidae and  Pieridae

p
# Save SVG
svg("Sup_PCo2_ring.svg", width = 4, height = 4) 
p
dev.off()

## . PCo 3 (supp)----
p = ggplot(d, aes(x = phy_x * 1, y = phy_y * 1)) +
  # Family-colored points
  geom_point(aes(fill = Family_Ring), shape = 21, size = 3) +
  geom_point(aes(col = PCo3,x = phy_x * expV, y = phy_y * expV), shape = 16, size = 3) +
  labs(title = "",
       fill = "Butterly\nFamily",
       color = "Principle\nCoordinate 3")+ 
  theme_void() + coord_fixed() 

# High PCo3 largely corresponds with Hesperiidae but not Pieridae
p
# Save SVG
svg("Sup_PCo3_ring.svg", width = 4, height = 4) 
p
dev.off()


#SEX Effects (supp) ----
#................................

## How does sex influence motion confusion metrics ----

d <- subset(dataSet, render_method == "Patterned" & wing == "forewing" & flight_method == "Flapping")
d <- subset(d,sex=="Male" | sex=="Female")

d <- d %>%
  group_by(Binomial) %>%
  filter(n() == 2) %>%
  ungroup()

unique(d$Binomial)

## - Sex & Forwards-Confusion ----
p = ggplot(subset(d,sex=="Male" | sex=="Female"), aes(x=sex,y=Forwards_Confusion, fill=sex)) + 
  geom_point()+
  geom_line(aes(group=genusSpecies),alpha=0.2)+
  labs(title = "",
       x = "Sex",
       y = "Forwards-Confusion",
       fill = "Sex")+ 
  geom_boxplot(alpha=1,width=0.5)+theme_light()

p
# Save SVG
svg("Sup_Sex_FC.svg", width = 4, height = 4) 
p
dev.off()

model <- lmer(Forwards_Confusion ~ sex + (1|Binomial) , 
            data = d)
summary(model)
hist(residuals(model))
qqnorm(residuals(model))     # Plots the residuals against a normal distribution
qqline(residuals(model))     # Adds a reference line for normality

#Males have slightly higher forwards confusion


## - Sex & Sideways-Confusion ----
p = ggplot(subset(d,sex=="Male" | sex=="Female"), aes(x=sex,y=Sideways_Confusion, fill=sex)) + 
  geom_point()+
  geom_line(aes(group=genusSpecies),alpha=0.2)+
  labs(title = "",
       x = "Sex",
       y = "Sideways-Confusion",
       fill = "Sex")+ 
  geom_boxplot(alpha=1,width=0.5)+theme_light()

p
# Save SVG
svg("Sup_Sex_SC.svg", width = 4, height = 4) 
p
dev.off()

model <- lmer(Sideways_Confusion ~ sex + (1|Binomial) , 
              data = d)
summary(model)
#Females have significantly higher sideways confusion
hist(residuals(model))
qqnorm(residuals(model))     # Plots the residuals against a normal distribution
qqline(residuals(model))     # Adds a reference line for normality




## - Sex & Forwards-Energy ----
p = ggplot(subset(d,sex=="Male" | sex=="Female"), aes(x=sex,y=Forwards_Energy, fill=sex)) + 
  geom_point()+
  scale_y_log10()+  
  geom_line(aes(group=genusSpecies),alpha=0.2)+
  labs(title = "",
       x = "Sex",
       y = "Log Forwards-Energy",
       fill = "Sex")+ 
  geom_boxplot(alpha=1,width=0.5)+theme_light()

p
# Save SVG
svg("Sup_Sex_FE.svg", width = 4, height = 4) 
p
dev.off()

model <- lmer(log(Forwards_Energy) ~ sex + (1|Binomial) , 
              data = d)
summary(model)
#No difference in forwards_energy

hist(residuals(model))
qqnorm(residuals(model))     # Plots the residuals against a normal distribution
qqline(residuals(model))     # Adds a reference line for normality




#GLIDING (supp) ----
#How does gliding and wing colour influence motion confusion. ----

## Forwards Confusion ----
d=subset(dataSet, wing=="forewing" )

d$Pattern = d$render_method

d$Pattern <- factor(d$Pattern, 
                         levels = c("Patterned", "Averaged", "White"))


p = ggplot(d, aes(x = Pattern, y = Forwards_Confusion, fill = Pattern, 
              pattern = Pattern)) + 
  geom_violin(alpha=0.25)+
  geom_boxplot_pattern(
    alpha=1,
    width = 0.3,
    aes(pattern = Pattern),
    pattern_alpha = 0.7,      # Adjust stripe alpha
    pattern_density = 0.3,    # Adjust stripe density
    pattern_spacing = 0.02,   # Adjust stripe spacing
    pattern_fill = "black",   # Color of stripes
    pattern_color = "black"   # Stripe border color
  ) +
  scale_fill_manual(values = c("salmon","darkgray",  "white")) + 
  scale_pattern_manual(values = c("stripe","none", "none")) +  # Apply stripes to the middle one
  facet_grid( flight_method ~.)+
  labs(title = "",
       x = "Pattern",
       y = "Forwards-Confusion",
       fill = "Pattern")+ 
  theme_light() + theme(
    strip.background = element_rect(fill = "white", color = "black"),
    strip.text = element_text(color = "black")
  )+ theme(legend.position = "none")

p
# Save SVG
svg("Sup_Glide_FC.svg", width = 3, height = 5) 
p
dev.off()


#Obtain outlier counts
outlier_counts <- d %>%
  group_by(flight_method, Pattern) %>%
  summarise(
    Q1 = quantile(Forwards_Confusion, 0.25, na.rm = TRUE),
    Q3 = quantile(Forwards_Confusion, 0.75, na.rm = TRUE),
    IQR = IQR(Forwards_Confusion, na.rm = TRUE),
    lower_bound = Q1 - 1.5 * IQR,
    upper_bound = Q3 + 1.5 * IQR,
    n_outliers = sum(
      Forwards_Confusion < lower_bound |
        Forwards_Confusion > upper_bound,
      na.rm = TRUE
    ),
    .groups = "drop"
  )

outlier_counts



# No forwards-confusion when gliding
# Patterning doesn't always improve confusion but on average it does
d$morphoType

model <- lmer(Forwards_Confusion ~ Pattern * flight_method + (1|morphoType), 
              data = d)
summary(model)
emmeans(model, pairwise ~ Pattern, adjust = "tukey",pbkrtest.limit = 4542)











## Sideways Confusion ----
d=subset(dataSet, wing=="forewing" )

d$Pattern = d$render_method

d$Pattern <- factor(d$Pattern, 
                    levels = c("Patterned", "Averaged", "White"))


p = ggplot(d, aes(x = Pattern, y = Sideways_Confusion, fill = Pattern, 
                  pattern = Pattern)) + 
  geom_violin(alpha=0.25)+
  geom_boxplot_pattern(
    alpha=1,
    width = 0.3,
    aes(pattern = Pattern),
    pattern_alpha = 0.7,      # Adjust stripe alpha
    pattern_density = 0.3,    # Adjust stripe density
    pattern_spacing = 0.02,   # Adjust stripe spacing
    pattern_fill = "black",   # Color of stripes
    pattern_color = "black"   # Stripe border color
  ) +
  scale_fill_manual(values = c("salmon","darkgray",  "white")) + 
  scale_pattern_manual(values = c("stripe","none", "none")) +  # Apply stripes to the middle one
  facet_grid( flight_method ~.)+
  labs(title = "",
       x = "Pattern",
       y = "Sideways-Confusion",
       fill = "Pattern")+ 
  theme_light() + theme(
    strip.background = element_rect(fill = "white", color = "black"),
    strip.text = element_text(color = "black")
  )+ theme(legend.position = "none")

p
# Save SVG
svg("Sup_Glide_SC.svg", width = 3, height = 5) 
p
dev.off()


# Sideways-confusion is maintained when gliding


model <- lmer(Sideways_Confusion ~ Pattern * flight_method + (1|morphoType), 
              data = d)

options(scipen = 999)
summary(model)
emmeans(model, pairwise ~ Pattern, adjust = "tukey",pbkrtest.limit = 4542)







## Forwards Energy ----
d=subset(dataSet, wing=="forewing" )

d$Pattern = d$render_method

d$Pattern <- factor(d$Pattern, 
                    levels = c("Patterned", "Averaged", "White"))


p = ggplot(d, aes(x = Pattern, y = Forwards_Energy, fill = Pattern, 
                  pattern = Pattern)) + 
  geom_violin(alpha=0.25)+
  geom_boxplot_pattern(
    alpha=1,
    width = 0.3,
    aes(pattern = Pattern),
    pattern_alpha = 0.7,      # Adjust stripe alpha
    pattern_density = 0.3,    # Adjust stripe density
    pattern_spacing = 0.02,   # Adjust stripe spacing
    pattern_fill = "black",   # Color of stripes
    pattern_color = "black"   # Stripe border color
  ) +
  scale_y_log10()+ 
  
  scale_fill_manual(values = c("salmon","darkgray",  "white")) + 
  scale_pattern_manual(values = c("stripe","none", "none")) +  # Apply stripes to the middle one
  facet_grid( flight_method ~.)+
  labs(title = "",
       x = "Pattern",
       y = "Forwards-Energy",
       fill = "Pattern")+ 
  theme_light() + theme(
    strip.background = element_rect(fill = "white", color = "black"),
    strip.text = element_text(color = "black")
  )+ theme(legend.position = "none")

p
# Save SVG
svg("Sup_Glide_FE.svg", width = 3, height = 5) 
p
dev.off()


# Forwards energy is higher when gliding


model <- lmer(log(Forwards_Energy) ~ Pattern * flight_method + (1|morphoType), 
              data = d)
summary(model)
emmeans(model, pairwise ~ Pattern, adjust = "tukey",pbkrtest.limit = 4542)



# Why do some butterflies with averaged colour have high confusion? ----

p = ggplot(subset(d,flight_method=="Flapping"), aes(x=abs(83-L_mean),y=Forwards_Confusion)) + 
  geom_point() +  # Images
  geom_smooth (aes(),method=glm,formula=y~poly(x,1),alpha=0.25,size=0.75)  +
  facet_grid(. ~ render_method)+
  scale_x_log10()+ 
  labs(title = "",
       x = "Log Luminance Difference",
       y = "Forwards-Confusion",
       fill = "Pattern")+ 
  theme_light()
p

# Save SVG
svg("Sup_Glide_Outliers.svg", width = 6, height = 3) 
p
dev.off()



# butterflies with luminance values closer to that of the background spike for the average







#RADIAL PLOTS (Figure 2) -----------------

##Create Motion Confusion Metric----
d=subset(dataSet,render_method=="Patterned" & wing=="forewing" & flight_method=="Flapping" )
d$E_Ratios_b = scale(d$Sideways_Confusion)+scale(d$Forwards_Confusion)
d$E_Ratios = d$E_Ratios/18

#Exp 
expV = 1.6

#Compute angle in radians and convert to degrees for phylogeny coordinates
d$angle <- atan2(d$phy_y, d$phy_x) * 180 / pi

#Normalize to 0–360°
d$angle <- (d$angle + 360) %% 360

#Sort the data by angle
d_ordered <- d[order(d$angle), ]

# Total number of entries
n <- nrow(d_ordered)

# Create 12 evenly spaced indices
indices <- round(seq(1, n-2, length.out = 36))

# Remove the last index
indices = indices+1 

# Subset the data
d_subset <- d_ordered[indices, ]

# 1. Prepare a grey reference path at the mean radius
mean_radius <- mean(d_ordered$E_Ratios, na.rm = TRUE)
sd_radius <- sd(d_ordered$E_Ratios, na.rm = TRUE)
d_ordered <- d_ordered %>%
  mutate(x_mean = phy_x * (mean_radius + expV),
         y_mean = phy_y * (mean_radius + expV))

d_ordered <- d_ordered %>%
  mutate(x_mean_msd1 = phy_x * (mean_radius - sd_radius + expV),
         y_mean_msd1 = phy_y * (mean_radius - sd_radius + expV))

d_ordered <- d_ordered %>%
  mutate(x_mean_psd1 = phy_x * (mean_radius + sd_radius + expV),
         y_mean_psd1 = phy_y * (mean_radius + sd_radius + expV))

d_ordered <- d_ordered %>%
  mutate(x_mean_msd2 = phy_x * (mean_radius - sd_radius*2 + expV),
         y_mean_msd2 = phy_y * (mean_radius - sd_radius*2 + expV))

d_ordered <- d_ordered %>%
  mutate(x_mean_psd2 = phy_x * (mean_radius + sd_radius*2 + expV),
         y_mean_psd2 = phy_y * (mean_radius + sd_radius*2 + expV))


# 2. Prepare segment data for gradient-colored path
d_segments <- d_ordered %>%
  mutate(x = phy_x * (E_Ratios + expV),
         y = phy_y * (E_Ratios + expV),
         xend = lead(x),
         yend = lead(y),
         E_Ratios_next = lead(E_Ratios), 
         E_Ratios_next_b = lead(E_Ratios_b)) %>%
  filter(!is.na(xend)) %>%
  mutate(E_Ratios_avg_b = (E_Ratios_b + E_Ratios_next_b) / 2)%>%
  mutate(E_Ratios_avg = (E_Ratios + E_Ratios_next) / 2)

library(dplyr)

d_top <- d_segments %>%
  group_by(Family) %>%
  slice_max(order_by = E_Ratios, n = 1, with_ties = FALSE) %>%
  ungroup()

d_bot <- d_segments %>%
  group_by(Family) %>%
  slice_min(order_by = E_Ratios, n = 1, with_ties = FALSE) %>%
  ungroup()

angInt = 20

d_binned <- d_segments %>%
  mutate(angle_bin = floor(angle / angInt) *angInt) %>%  # Create 20-degree bins like 0, 20, 40, etc.
  group_by(angle_bin) %>%
  slice_max(order_by = E_Ratios, n = 1, with_ties = FALSE) %>%
  ungroup()

##Render Plot----
p = ggplot(d_ordered, aes(x = phy_x * 0.8, y = phy_y * 0.8)) +
  # Family-colored points
  #geom_point(aes(fill = Family_Ring), shape = 21, size = 3) +
  scale_fill_manual(values = FamilyPalette_Ring) +
  
  # Images
  geom_image(data = subset(d_subset,angle<350), aes(x = phy_x, y = phy_y, image = imdDirS), size = 0.03)+ 
  
  # Gray reference path at mean
  geom_path(data = d_ordered,
            aes(x = x_mean, y = y_mean),
            linetype = 2,
            inherit.aes = FALSE,
            size = 0.5, col = "black") +
  geom_path(data = d_ordered,
            aes(x = x_mean_msd1, y = y_mean_msd1),
            linetype = 2,
            inherit.aes = FALSE,
            size = 0.1, col = "black") +
  geom_path(data = d_ordered,
            aes(x = x_mean_psd1, y = y_mean_psd1),
            linetype = 2,
            inherit.aes = FALSE,
            size = 0.2, col = "black") +
  geom_path(data = d_ordered,
            aes(x = x_mean_msd2, y = y_mean_msd2),
            alpha = .5,
            linetype = 2,
            inherit.aes = FALSE,
            size = 0.2, col = "black") +
  geom_path(data = d_ordered,
            aes(x = x_mean_psd2, y = y_mean_psd2),
            alpha = .5,
            linetype = 2,
            inherit.aes = FALSE,
            size = 0.1, col = "black") +

  
  # Gradient-colored path by E_Ratios
  geom_segment(data = d_segments,
               aes(x = x, y = y, xend = xend, yend = yend, color = E_Ratios_avg_b),
               size = 1,
               inherit.aes = FALSE) +
  scale_color_viridis_c(option = "D", name = "Confusion", 
                        guide = guide_colorbar(
                          title.position = "top",  # Title above the color bar
                          title.hjust = 0.5,       # Center the title
                          barwidth = 1,           # Adjust the width of the gradient bar
                          barheight = 8            # Adjust the height of the gradient bar
                        )) + 
  #Binned
  geom_image(data = subset(d_binned), aes(x = x*1.05, y = y*1.05, image = imdDirS), size = 0.03)+  

  
  labs(title = "",
       x = "Sideways-Confusion",
       y = "Forwards-Confusion",
       fill = "Family") +
  
  theme_void() + coord_fixed() 

p
# Save SVG
svg("Fig_2_Radial_Butterflies.svg", width = 6, height = 6) 
p
dev.off()





# REVISED BAR VERSION


# Create radial bar coordinates directly from ordered data
d_bars <- d_ordered %>%
  mutate(
    x_start = phy_x * expV,
    y_start = phy_y * expV,
    x_end   = phy_x * (E_Ratios + expV),
    y_end   = phy_y * (E_Ratios + expV)
  )

# Render plot
p = ggplot(d_ordered, aes(x = phy_x * 0.8, y = phy_y * 0.8)) +
  
  scale_fill_manual(values = FamilyPalette_Ring) +
  
  # Butterfly images
  geom_image(data = subset(d_subset, angle < 350),
             aes(x = phy_x*1.15, y = phy_y*1.15, image = imdDirS),
             size = 0.03) +
  
  # Mean and SD reference paths
  geom_path(aes(x = x_mean, y = y_mean),
            linetype = 2,
            linewidth = 0.5,
            col = "black",
            inherit.aes = FALSE) +
  
  geom_path(aes(x = x_mean_msd1, y = y_mean_msd1),
            linetype = 2,
            linewidth = 0.1,
            col = "black",
            inherit.aes = FALSE) +
  
  geom_path(aes(x = x_mean_psd1, y = y_mean_psd1),
            linetype = 2,
            linewidth = 0.2,
            col = "black",
            inherit.aes = FALSE) +
  
  geom_path(aes(x = x_mean_msd2, y = y_mean_msd2),
            linetype = 2,
            alpha = .5,
            linewidth = 0.2,
            col = "black",
            inherit.aes = FALSE) +
  
  geom_path(aes(x = x_mean_psd2, y = y_mean_psd2),
            linetype = 2,
            alpha = .5,
            linewidth = 0.1,
            col = "black",
            inherit.aes = FALSE) +
  
  # Radial bars (one per butterfly)
  geom_segment(data = d_bars,
               aes(x = x_start,
                   y = y_start,
                   xend = x_end,
                   yend = y_end,
                   color = E_Ratios_b),
               linewidth = 0.85,
               lineend = "butt",
               inherit.aes = FALSE) +
  
  scale_color_viridis_c(
    option = "D",
    name = "Confusion",
    guide = guide_colorbar(
      title.position = "top",
      title.hjust = 0.8,
      barwidth = 1,
      barheight = 8
    )
  ) +
  
  # Binned highlight images
  geom_image(data = d_binned,
             aes(x = x * 1.08, y = y * 1.08, image = imdDirS),
             size = 0.03) +
  
  labs(
    title = "",
    x = "Sideways-Confusion",
    y = "Forwards-Confusion",
    fill = "Family"
  ) +
  
  theme_void() +
  coord_fixed()

p

install.packages("svglite")  # if not installed
library(svglite)

svglite("Fig_2_Radial_Butterflies_Bars.svg", width = 6, height = 6)
print(p)
dev.off()





#REGRESSION PLOT (Figure 2) -----------------

## Plot ---- 

d=subset(dataSet,render_method=="Patterned" & wing=="forewing" & flight_method=="Flapping")


d$genusSpeciesSex = paste(d$genusSpecies,d$sex,sep="__")

d2 = subset(d,genusSpeciesSex=="Brintesia_circe__Male" | 
              genusSpeciesSex=="Gonepteryx_cleobule__Male" |
              genusSpeciesSex=="Lycaena_tityrus__Female" |
              genusSpeciesSex=="Papilio_alexanor__Female" |
              genusSpeciesSex=="Pyrgus_sidae__Male" )

nrow(d2)
d2$Binomial
d2$Forwards_Confusion
d2$Sideways_Confusion
d2$Forwards_Energy

# Fit the model manually
model <- glm(Forwards_Confusion ~ poly(Sideways_Confusion, 1), data = d)

# Create a sequence of x values and predict y
pred_data <- data.frame(Sideways_Confusion = seq(min(d$Sideways_Confusion), max(d$Sideways_Confusion), length.out = 200))
pred_data$Forwards_Confusion <- predict(model, newdata = pred_data)

# Plot with gradient line
p = ggplot(d, aes(x = Sideways_Confusion, y = Forwards_Confusion)) + 
  #Mean
  geom_hline(aes(yintercept = mean(Forwards_Confusion)), linetype = 2,size=0.6) +
  geom_vline(aes(xintercept = mean(Sideways_Confusion)), linetype = 2,size=0.6) +
  
  geom_image(aes(image = imdDirS), size = 0.04) +
  
  # Regular Regression
  geom_smooth(method=glm, formula=y~poly(x,1), alpha=0.0, size=3, col="black") + 
  
  # Gradient regression line
  geom_path(data = pred_data, aes(x = Sideways_Confusion, y = Forwards_Confusion, color = scale(Sideways_Confusion)+ scale(Forwards_Confusion)), size = 2.5) +
  scale_color_viridis_c(option = "D", name = "Confusion", 
                        guide = guide_colorbar(
                          title.position = "top",  # Title above the color bar
                          title.hjust = 0.5,       # Center the title
                          barwidth = 1,           # Adjust the width of the gradient bar
                          barheight = 8            # Adjust the height of the gradient bar
                        )) +  
  
  geom_image(data = d2, aes(image = imdDirS), size = 0.05, col="cyan") +
  geom_image(data = d2, aes(image = imdDirS), size = 0.04) +
  
  labs(title = "",
       x = "Sideways-Confusion",
       y = "Forwards-Confusion",
       color = "Sideways-Confusion") +
  theme(panel.grid.major = element_blank(), 
        panel.grid.minor = element_blank(), 
        panel.background = element_blank(), 
        panel.border = element_rect(colour = "grey", fill=NA)) + coord_fixed() +theme(legend.position = "none")

p
# Save SVG
svg("Fig_2_Regression.svg", width = 6, height = 6) 
p
dev.off()

library(svglite)

svglite("Fig_2_Regression.svg", width = 6, height = 6)
print(p)
dev.off()




# Plot with just isolated butterflies
p = ggplot(d, aes(x = Sideways_Confusion, y = Forwards_Confusion)) + 
  #Mean
  geom_hline(aes(yintercept = mean(Forwards_Confusion)), linetype = 2,size=0.6) +
  geom_vline(aes(xintercept = mean(Sideways_Confusion)), linetype = 2,size=0.6) +
  
  geom_point( size = 2, col="black", alpha=0.1) +
  
  # Regular Regression
  geom_smooth(method=glm, formula=y~poly(x,1), alpha=0.0, size=1, col="blue", linetype=1) + 
  
  geom_image(data = d2, aes(image = imdDirS), size = 0.08, col="black") +
  geom_image(data = d2, aes(image = imdDirS), size = 0.07) +
  
  labs(title = "",
       x = "Sideways-Confusion",
       y = "Forwards-Confusion",
       color = "Sideways-Confusion") +
  theme(panel.grid.major = element_blank(), 
        panel.grid.minor = element_blank(), 
        panel.background = element_blank(), 
        panel.border = element_rect(colour = "grey", fill=NA)) + coord_fixed() +theme(legend.position = "none")

p









## Correlation ---- 
model <- lm(Forwards_Confusion ~ Sideways_Confusion , 
            data = d)
summary(model) 
hist(residuals(model))
qqnorm(residuals(model))     # Plots the residuals against a normal distribution
qqline(residuals(model))     # Adds a reference line for normality















#RANDOM FOREST MODELS (Main)------------

## Create RF Dataframe----
# ...............................................

## Split forewing and hindwing data to recombine.

head(dataSet)
df = subset(dataSet, render_method=="Patterned" & flight_method=="Flapping")
attach(df)

fw = subset(df,wing=="forewing")
nrow(fw)
fw$MorphType = paste(fw$genusSpecies,fw$sex,sep="_")

df_f=data.frame(MorphType = fw$MorphType, sex=fw$sex, imdDir = fw$imdDir,
                PCo1 =fw$PCo1,PCo2 =fw$PCo2,PCo3 =fw$PCo3, 
                #Size Linked Measures (mm)
                body.length = fw$Body_Length,
                wing.area = fw$Wing_Area,
                wing.frq = fw$Wing_WBF,
                #EMD Measures
                Forwards_Confusion=fw$Forwards_Confusion, 
                Sideways_Confusion=fw$Sideways_Confusion,
                Forwards_Energy = fw$Forwards_Energy, 
                #Col
                fw.col.rg.mean = fw$CIE_A_mean,
                fw.col.by.mean = fw$CIE_B_mean,
                fw.col.sat.mean = fw$CIE_S_mean,
                fw.col.rg.stdev = fw$CIE_A_stdev,
                fw.col.by.stdev = fw$CIE_B_stdev,
                fw.col.sat.stdev = fw$CIE_S_stdev,
                #Wing Shape (px)
                fw.shp.length=fw$fw_length,fw.shp.breadth=fw$fw_breadth,
                fw.shp.area=fw$fw_area,fw.shp.ar=fw$fw_ar,
                fw.shp.rough=fw$fw_rough,
                #Pattern
                fw.pat.L.mean=fw$L_mean,fw.pat.E.mean=fw$E_mean,fw.pat.P.mean=fw$P_mean,fw.pat.VH.mean=fw$VH_mean,fw.pat.OA.mean=fw$OA_mean,fw.pat.DR.mean=fw$DR_mean,
                fw.pat.L.stdev=fw$L_stdev,fw.pat.E.stdev=fw$E_stdev,fw.pat.P.stdev=fw$P_stdev,fw.pat.VH.stdev=fw$VH_stdev,fw.pat.OA.stdev=fw$OA_stdev,fw.pat.DR.stdev=fw$DR_stdev,
                fw.pat.L.x=fw$L_x,fw.pat.E.x=fw$E_x,fw.pat.P.x=fw$P_x,fw.pat.VH.x=fw$VH_x,fw.pat.OA.x=fw$OA_x,fw.pat.DR.x=fw$DR_x,
                fw.pat.L.y=fw$L_y,fw.pat.E.y=fw$E_y,fw.pat.P.y=fw$P_y,fw.pat.VH.y=fw$VH_y,fw.pat.OA.y=fw$OA_y,fw.pat.DR.y=fw$DR_y)
df_f


hw = subset(df,wing=="hindwing")
hw$MorphType = paste(hw$genusSpecies,hw$sex,sep="_")


df_h=data.frame(MorphType = hw$MorphType, sex=hw$sex,
                PCo1 =hw$PCo1,PCo2 =hw$PCo2,PCo3 =hw$PCo3, 
                #Size Linked Measures (mm)
                body.length = hw$Body_Length,
                wing.area = hw$Wing_Area,
                wing.frq = hw$Wing_WBF,
                #EMD Measures
                Forwards_Confusion=hw$Forwards_Confusion, 
                Sideways_Confusion=hw$Sideways_Confusion,
                Forwards_Energy = hw$Forwards_Energy, 
                #Col
                hw.col.rg.mean = hw$CIE_A_mean,
                hw.col.by.mean = hw$CIE_B_mean,
                hw.col.sat.mean = hw$CIE_S_mean,
                hw.col.rg.stdev = hw$CIE_A_stdev,
                hw.col.by.stdev = hw$CIE_B_stdev,
                hw.col.sat.stdev = hw$CIE_S_stdev,
                #Wing Shape (px)
                hw.shp.length=hw$hw_length,hw.shp.breadth=hw$hw_breadth,
                hw.shp.area=hw$hw_area,hw.shp.ar=hw$hw_ar,
                hw.shp.rough=hw$hw_rough,
                #Pattern
                hw.pat.L.mean=hw$L_mean,hw.pat.E.mean=hw$E_mean,hw.pat.P.mean=hw$P_mean,hw.pat.VH.mean=hw$VH_mean,hw.pat.OA.mean=hw$OA_mean,hw.pat.DR.mean=hw$DR_mean,
                hw.pat.L.stdev=hw$L_stdev,hw.pat.E.stdev=hw$E_stdev,hw.pat.P.stdev=hw$P_stdev,hw.pat.VH.stdev=hw$VH_stdev,hw.pat.OA.stdev=hw$OA_stdev,hw.pat.DR.stdev=hw$DR_stdev,
                hw.pat.L.x=hw$L_x,hw.pat.E.x=hw$E_x,hw.pat.P.x=hw$P_x,hw.pat.VH.x=hw$VH_x,hw.pat.OA.x=hw$OA_x,hw.pat.DR.x=hw$DR_x,
                hw.pat.L.y=hw$L_y,hw.pat.E.y=hw$E_y,hw.pat.P.y=hw$P_y,hw.pat.VH.y=hw$VH_y,hw.pat.OA.y=hw$OA_y,hw.pat.DR.y=hw$DR_y)
nrow(df_f)
nrow(df_h)
Forest_df=merge(df_f,df_h)
nrow(Forest_df)
# 757 rows is correct

attach(Forest_df)



# ....RF Forwards Confusion ----
# ................................................
# ................................................
# ................................................

set.seed(123)


# Subset the data to only include the selected columns for Metric
Forest_df_forwards_confusion <- Forest_df %>% dplyr::select(-Sideways_Confusion, -Forwards_Energy, -MorphType,-imdDir,-sex)

ncol(Forest_df_forwards_confusion)


# Train the Random Forest model for Metric
rf_model_forwards_confusion <- randomForest(Forwards_Confusion ~ ., data = Forest_df_forwards_confusion, ntree = 1500, mtry = 4)

# Model summary
print(rf_model_forwards_confusion)



# 2. Recursive Feature Elimination (RFE) for Metric
# ................................................
# Set up RFE control using Random Forest functions and 5-fold cross-validation
rfe_control_forwards_confusion <- rfeControl(functions = rfFuncs, method = "cv", number = 5)

# Define a range for the number of predictors to evaluate
sizes_to_try_forwards_confusion <- c(1:10, 15, 20, 30, 40)

# Run RFE for Metric; here, all predictors except the response 'Forwards_Confusion' are used
rfe_result_forwards_confusion <- rfe(x = Forest_df_forwards_confusion[, -which(names(Forest_df_forwards_confusion) == "Forwards_Confusion")],
                                    y = Forest_df_forwards_confusion$Forwards_Confusion,
                                    sizes = sizes_to_try_forwards_confusion,
                                    rfeControl = rfe_control_forwards_confusion)

print(rfe_result_forwards_confusion)


# Print the selected features based on RFE for Metric
selected_features_forwards_confusion <- rfe_result_forwards_confusion$optVariables
print(selected_features_forwards_confusion)


# 3. Train the Random Forest Model Using Selected Features for Metric
# ................................................
# Subset the data to include only the response and the selected predictors
data_final_forwards_confusion <- Forest_df_forwards_confusion[, c("Forwards_Confusion", selected_features_forwards_confusion)]

rf_model_final_forwards_confusion <- randomForest(Forwards_Confusion ~ ., data = data_final_forwards_confusion, ntree = 1500, mtry = 4)



# 4. Calculate RMSE to determine accuracy
# ................................................
# Get the actual values
actual <- data_final_forwards_confusion$Forwards_Confusion

# Predict the values using the trained model
predicted <- predict(rf_model_final_forwards_confusion, newdata = data_final_forwards_confusion)

# Calculate RMSE
rmse <- sqrt(mean((actual - predicted)^2))
print(paste("RMSE:", rmse))


summary(data_final_forwards_confusion$Forwards_Confusion)
sd(data_final_forwards_confusion$Forwards_Confusion)


# Get actual and predicted values
actual <- data_final_forwards_confusion$Forwards_Confusion
predicted <- predict(rf_model_final_forwards_confusion, newdata = data_final_forwards_confusion)

# Create data frame for plotting
plot_df <- data.frame(Observed = actual, Predicted = predicted)

### Plot observation vs prediction
p = ggplot(plot_df, aes(x = Observed, y = Predicted)) +
  geom_point(alpha = 0.25) +
  geom_abline(slope = 1, intercept = 0, linetype = "dashed", color = "blue",size=0.8) +
  theme_light()
p
# Save SVG
svg("Sup_Forest_FC_Regession.svg", width = 4, height = 4) 
p
dev.off()



# 5. Generate SHAP for Metric
# ................................................
# i. Create a Predictor object (exclude response)
predictor_final_forwards_confusion <- Predictor$new(
  rf_model_final_forwards_confusion,
  data = data_final_forwards_confusion[, -which(names(data_final_forwards_confusion) == "Forwards_Confusion")],
  y = data_final_forwards_confusion$Forwards_Confusion
)

# ii. Compute SHAP values for a sample of observations (e.g., first 50)
n_obs_forwards_confusion <- min(50, nrow(data_final_forwards_confusion))  # adjust sample size if needed
shap_list_forwards_confusion <- lapply(1:n_obs_forwards_confusion, function(i) {
  # Compute SHAP for observation i
  shap_obj <- Shapley$new(
    predictor_final_forwards_confusion,
    x.interest = data_final_forwards_confusion[i, -which(names(data_final_forwards_confusion) == "Forwards_Confusion")]
  )
  # Add an identifier for the observation if needed
  shap_obj$results %>% mutate(observation = i)
})

# Combine all results into one data frame for Metric
all_shap_forwards_confusion <- do.call(rbind, shap_list_forwards_confusion)

# Inspect the structure of all_shap_forwards_confusion to check the column names.
str(all_shap_forwards_confusion)

# iii. Aggregate the SHAP values per feature for Metric:
shap_summary_forwards_confusion <- all_shap_forwards_confusion %>%
  dplyr::group_by(feature) %>%
  dplyr::summarise(
    mean_shap = mean(phi, na.rm = TRUE),
    sd_shap   = sd(phi, na.rm = TRUE),
    se_shap   = sd(phi, na.rm = TRUE) / sqrt(n()) 
  ) 

shap_summary_forwards_confusion$mean_abs_shap = abs(shap_summary_forwards_confusion$mean_shap)

print(shap_summary_forwards_confusion)

# Manually reorder the 'feature' factor based on mean_abs_shap in descending order
shap_summary_forwards_confusion$feature <- factor(shap_summary_forwards_confusion$feature,
                                                 levels = shap_summary_forwards_confusion$feature[order(as.numeric(shap_summary_forwards_confusion$mean_abs_shap), decreasing = FALSE)]
)

order(as.numeric(shap_summary_forwards_confusion$mean_abs_shap))

# 4. Create a SHAP bar plot for Metric ordered by the absolute mean SHAP value,
#    but displaying the mean SHAP (which can be positive or negative) with error bars (± SE).
p = ggplot(shap_summary_forwards_confusion, aes(x = feature, y = mean_shap)) +
  geom_errorbar(aes(ymin = mean_shap - se_shap, ymax = mean_shap + se_shap), width = 0.2) +
  geom_point(col = "steelblue", size = 5) +
  geom_hline(yintercept = 0, linetype = 2, alpha = 0.25) +
  coord_flip() +
  theme_light() +
  labs(
    title = "Forwards-Confusion SHAPs",
    x = "Feature",
    y = "SHAP mean (± SE)"
  ) +
  theme(plot.title = element_text(hjust = 0.5))

p
# Save SVG
svg("sup_Forest_SHAP_forwards_confusion.svg", width = 4, height = 4) 
p
dev.off()


# 5. Retrieve % Increase in MSE from the RF model for Metric
# For regression, randomForest calculates %IncMSE in its importance output.
rf_importance_forwards_confusion <- as.data.frame(rf_model_final_forwards_confusion$importance)
rf_importance_forwards_confusion$feature <- rownames(rf_importance_forwards_confusion)

# Merge the RF importance with the aggregated SHAP values for Metric
final_table_forwards_confusion <- merge(rf_importance_forwards_confusion, shap_summary_forwards_confusion, by = "feature", all.x = TRUE)

# Create a table with IncNodePurity and SHAP value ± SD for Metric
final_table_forwards_confusion <- final_table_forwards_confusion %>%
  dplyr::select(feature, IncNodePurity, mean_shap, sd_shap) %>%
  arrange(desc(abs(mean_shap)))  # Order by absolute mean SHAP if desired

# Optionally, format the SHAP column as "mean_shap ± sd_shap"
final_table_forwards_confusion <- final_table_forwards_confusion %>%
  mutate(SHAP = paste0(round(mean_shap, 3), " ± ", round(sd_shap, 3)))

# Print the final table for Metric
print(final_table_forwards_confusion)

# Write csv
write.csv(final_table_forwards_confusion, "SHAP_Summary_Forwards_Confusion.csv", row.names = FALSE)


# ....RF Sideways Confusion ----
# ................................................
# ................................................
# ................................................
set.seed(123)


# Subset the data to only include the selected columns for Metric
Forest_df_sideways_confusion <- Forest_df %>% dplyr::select(-Forwards_Confusion, -Forwards_Energy, -MorphType,-imdDir,-sex)

ncol(Forest_df_sideways_confusion)


# Train the Random Forest model for Metric
rf_model_sideways_confusion <- randomForest(Sideways_Confusion ~ ., data = Forest_df_sideways_confusion, ntree = 1500, mtry = 4)

# Model summary
print(rf_model_sideways_confusion)



# 2. Recursive Feature Elimination (RFE) for Metric
# ................................................
# Set up RFE control using Random Forest functions and 5-fold cross-validation
rfe_control_sideways_confusion <- rfeControl(functions = rfFuncs, method = "cv", number = 5)

# Define a range for the number of predictors to evaluate
sizes_to_try_sideways_confusion <- c(1:10, 15, 20, 30, 40)

# Run RFE for Metric; here, all predictors except the response Metic are used
rfe_result_sideways_confusion <- rfe(x = Forest_df_sideways_confusion[, -which(names(Forest_df_sideways_confusion) == "Sideways_Confusion")],
                                     y = Forest_df_sideways_confusion$Sideways_Confusion,
                                     sizes = sizes_to_try_sideways_confusion,
                                     rfeControl = rfe_control_sideways_confusion)

print(rfe_result_sideways_confusion)


# Print the selected features based on RFE for Metric
selected_features_sideways_confusion <- rfe_result_sideways_confusion$optVariables
print(selected_features_sideways_confusion)


# 3. Train the Random Forest Model Using Selected Features for Metric
# ................................................
# Subset the data to include only the response and the selected predictors
data_final_sideways_confusion <- Forest_df_sideways_confusion[, c("Sideways_Confusion", selected_features_sideways_confusion)]

rf_model_final_sideways_confusion <- randomForest(Sideways_Confusion ~ ., data = data_final_sideways_confusion, ntree = 1500, mtry = 4)



# 4. Calculate RMSE to determine accuracy
# ................................................
# Get the actual values
actual <- data_final_sideways_confusion$Sideways_Confusion

# Predict the values using the trained model
predicted <- predict(rf_model_final_sideways_confusion, newdata = data_final_sideways_confusion)

# Calculate RMSE
rmse <- sqrt(mean((actual - predicted)^2))
print(paste("RMSE:", rmse))


summary(data_final_sideways_confusion$Sideways_Confusion)
sd(data_final_sideways_confusion$Sideways_Confusion)


# Get actual and predicted values
actual <- data_final_sideways_confusion$Sideways_Confusion
predicted <- predict(rf_model_final_sideways_confusion, newdata = data_final_sideways_confusion)

# Create data frame for plotting
plot_df <- data.frame(Observed = actual, Predicted = predicted)

### Plot observation vs prediction
p = ggplot(plot_df, aes(x = Observed, y = Predicted)) +
  geom_point(alpha = 0.25) +
  geom_abline(slope = 1, intercept = 0, linetype = "dashed", color = "blue",size=0.8) +
  theme_light()
p
# Save SVG
svg("Sup_Forest_SC_Regession.svg", width = 4, height = 4) 
p
dev.off()



# 5. Generate SHAP for Metric
# ................................................
# i. Create a Predictor object (exclude response)
predictor_final_sideways_confusion <- Predictor$new(
  rf_model_final_sideways_confusion,
  data = data_final_sideways_confusion[, -which(names(data_final_sideways_confusion) == "Sideways_Confusion")],
  y = data_final_sideways_confusion$Sideways_Confusion
)

# ii. Compute SHAP values for a sample of observations (e.g., first 50)
n_obs_sideways_confusion <- min(50, nrow(data_final_sideways_confusion))  # adjust sample size if needed
shap_list_sideways_confusion <- lapply(1:n_obs_sideways_confusion, function(i) {
  # Compute SHAP for observation i
  shap_obj <- Shapley$new(
    predictor_final_sideways_confusion,
    x.interest = data_final_sideways_confusion[i, -which(names(data_final_sideways_confusion) == "Sideways_Confusion")]
  )
  # Add an identifier for the observation if needed
  shap_obj$results %>% mutate(observation = i)
})

# Combine all results into one data frame for Metric
all_shap_sideways_confusion <- do.call(rbind, shap_list_sideways_confusion)

# Inspect the structure of all_shap_sideways_confusion to check the column names.
str(all_shap_sideways_confusion)

# iii. Aggregate the SHAP values per feature for Metric:
shap_summary_sideways_confusion <- all_shap_sideways_confusion %>%
  dplyr::group_by(feature) %>%
  dplyr::summarise(
    mean_shap = mean(phi, na.rm = TRUE),
    sd_shap   = sd(phi, na.rm = TRUE),
    se_shap   = sd(phi, na.rm = TRUE) / sqrt(n()) 
  ) 

shap_summary_sideways_confusion$mean_abs_shap = abs(shap_summary_sideways_confusion$mean_shap)

print(shap_summary_sideways_confusion)

# Manually reorder the 'feature' factor based on mean_abs_shap in descending order
shap_summary_sideways_confusion$feature <- factor(shap_summary_sideways_confusion$feature,
                                                  levels = shap_summary_sideways_confusion$feature[order(as.numeric(shap_summary_sideways_confusion$mean_abs_shap), decreasing = FALSE)]
)

order(as.numeric(shap_summary_sideways_confusion$mean_abs_shap))

# 4. Create a SHAP bar plot for Metric ordered by the absolute mean SHAP value,
#    but displaying the mean SHAP (which can be positive or negative) with error bars (± SE).
p = ggplot(shap_summary_sideways_confusion, aes(x = feature, y = mean_shap)) +
  geom_errorbar(aes(ymin = mean_shap - se_shap, ymax = mean_shap + se_shap), width = 0.2) +
  geom_point(col = "steelblue", size = 5) +
  geom_hline(yintercept = 0, linetype = 2, alpha = 0.25) +
  coord_flip() +
  theme_light() +
  labs(
    title = "Sideways-Confusion SHAPs",
    x = "Feature",
    y = "SHAP mean (± SE)"
  ) +
  theme(plot.title = element_text(hjust = 0.5))

p
# Save SVG
svg("sup_Forest_SHAP_sideways_confusion.svg", width = 4, height = 4) 
p
dev.off()


# 5. Retrieve % Increase in MSE from the RF model for metric
# For regression, randomForest calculates %IncMSE in its importance output.
rf_importance_sideways_confusion <- as.data.frame(rf_model_final_sideways_confusion$importance)
rf_importance_sideways_confusion$feature <- rownames(rf_importance_sideways_confusion)

# Merge the RF importance with the aggregated SHAP values for metric
final_table_sideways_confusion <- merge(rf_importance_sideways_confusion, shap_summary_sideways_confusion, by = "feature", all.x = TRUE)

# Create a table with IncNodePurity and SHAP value ± SD for metric
final_table_sideways_confusion <- final_table_sideways_confusion %>%
  dplyr::select(feature, IncNodePurity, mean_shap, sd_shap) %>%
  arrange(desc(abs(mean_shap)))  # Order by absolute mean SHAP if desired

# Optionally, format the SHAP column as "mean_shap ± sd_shap"
final_table_sideways_confusion <- final_table_sideways_confusion %>%
  mutate(SHAP = paste0(round(mean_shap, 3), " ± ", round(sd_shap, 3)))

# Print the final table for Metric
print(final_table_sideways_confusion)

# Write csv
write.csv(final_table_sideways_confusion, "SHAP_Summary_Sideways_Confusion.csv", row.names = FALSE)


# .... RF Forwards Energy ----
# ................................................
# ................................................
# ................................................
set.seed(123)


# Subset the data to only include the selected columns for metric
Forest_df_forwards_energy <- Forest_df %>% dplyr::select(-Sideways_Confusion, -Forwards_Confusion, -MorphType,-imdDir,-sex)

ncol(Forest_df_forwards_energy)


# Train the Random Forest model for Metric
rf_model_forwards_energy <- randomForest(Forwards_Energy ~ ., data = Forest_df_forwards_energy, ntree = 1500, mtry = 4)

# Model summary
print(rf_model_forwards_energy)



# 2. Recursive Feature Elimination (RFE) for metric
# ................................................
# Set up RFE control using Random Forest functions and 5-fold cross-validation
rfe_control_forwards_energy <- rfeControl(functions = rfFuncs, method = "cv", number = 5)

# Define a range for the number of predictors to evaluate
sizes_to_try_forwards_energy <- c(1:10, 15, 20, 30, 40)

# Run RFE for Metric; here, all predictors except the response 'Forwards_Energy' are used
rfe_result_forwards_energy <- rfe(x = Forest_df_forwards_energy[, -which(names(Forest_df_forwards_energy) == "Forwards_Energy")],
                                     y = Forest_df_forwards_energy$Forwards_Energy,
                                     sizes = sizes_to_try_forwards_energy,
                                     rfeControl = rfe_control_forwards_energy)

print(rfe_result_forwards_energy)


# Print the selected features based on RFE for Metric
selected_features_forwards_energy <- rfe_result_forwards_energy$optVariables
print(selected_features_forwards_energy)


# 3. Train the Random Forest Model Using Selected Features for metric
# ................................................
# Subset the data to include only the response and the selected predictors
data_final_forwards_energy <- Forest_df_forwards_energy[, c("Forwards_Energy", selected_features_forwards_energy)]

rf_model_final_forwards_energy <- randomForest(Forwards_Energy ~ ., data = data_final_forwards_energy, ntree = 1500, mtry = 4)



# 4. Calculate RMSE to determine accuracy
# ................................................
# Get the actual values
actual <- data_final_forwards_energy$Forwards_Energy

# Predict the values using the trained model
predicted <- predict(rf_model_final_forwards_energy, newdata = data_final_forwards_energy)

# Calculate RMSE
rmse <- sqrt(mean((actual - predicted)^2))
print(paste("RMSE:", rmse))


summary(data_final_forwards_energy$Forwards_Energy)
sd(data_final_forwards_energy$Forwards_Energy)


# Get actual and predicted values
actual <- data_final_forwards_energy$Forwards_Energy
predicted <- predict(rf_model_final_forwards_energy, newdata = data_final_forwards_energy)

# Create data frame for plotting
plot_df <- data.frame(Observed = actual, Predicted = predicted)

### Plot observation vs prediction
p = ggplot(plot_df, aes(x = Observed, y = Predicted)) +
  geom_point(alpha = 0.25) +
  geom_abline(slope = 1, intercept = 0, linetype = "dashed", color = "blue",size=0.8) +
  theme_light()
p
# Save SVG
svg("Sup_Forest_FE_Regession.svg", width = 4, height = 4) 
p
dev.off()



# 5. Generate SHAP for metric
# ................................................
# i. Create a Predictor object (exclude response)
predictor_final_forwards_energy <- Predictor$new(
  rf_model_final_forwards_energy,
  data = data_final_forwards_energy[, -which(names(data_final_forwards_energy) == "Forwards_Energy")],
  y = data_final_forwards_energy$Forwards_Energy
)

# ii. Compute SHAP values for a sample of observations (e.g., first 50)
n_obs_forwards_energy <- min(50, nrow(data_final_forwards_energy))  # adjust sample size if needed
shap_list_forwards_energy <- lapply(1:n_obs_forwards_energy, function(i) {
  # Compute SHAP for observation i
  shap_obj <- Shapley$new(
    predictor_final_forwards_energy,
    x.interest = data_final_forwards_energy[i, -which(names(data_final_forwards_energy) == "Forwards_Energy")]
  )
  # Add an identifier for the observation if needed
  shap_obj$results %>% mutate(observation = i)
})

# Combine all results into one data frame for Metric
all_shap_forwards_energy <- do.call(rbind, shap_list_forwards_energy)

# Inspect the structure of all_shap_forwards_energy to check the column names.
str(all_shap_forwards_energy)

# iii. Aggregate the SHAP values per feature for Metric:
shap_summary_forwards_energy <- all_shap_forwards_energy %>%
  dplyr::group_by(feature) %>%
  dplyr::summarise(
    mean_shap = mean(phi, na.rm = TRUE),
    sd_shap   = sd(phi, na.rm = TRUE),
    se_shap   = sd(phi, na.rm = TRUE) / sqrt(n()) 
  ) 

shap_summary_forwards_energy$mean_abs_shap = abs(shap_summary_forwards_energy$mean_shap)

print(shap_summary_forwards_energy)

# Manually reorder the 'feature' factor based on mean_abs_shap in descending order
shap_summary_forwards_energy$feature <- factor(shap_summary_forwards_energy$feature,
                                                  levels = shap_summary_forwards_energy$feature[order(as.numeric(shap_summary_forwards_energy$mean_abs_shap), decreasing = FALSE)]
)

order(as.numeric(shap_summary_forwards_energy$mean_abs_shap))

# 4. Create a SHAP bar plot for Metric ordered by the absolute mean SHAP value,
#    but displaying the mean SHAP (which can be positive or negative) with error bars (± SE).
p = ggplot(shap_summary_forwards_energy, aes(x = feature, y = mean_shap)) +
  geom_errorbar(aes(ymin = mean_shap - se_shap, ymax = mean_shap + se_shap), width = 0.2) +
  geom_point(col = "steelblue", size = 5) +
  geom_hline(yintercept = 0, linetype = 2, alpha = 0.25) +
  coord_flip() +
  theme_light() +
  labs(
    title = "Forwards-Energy SHAPs",
    x = "Feature",
    y = "SHAP mean (± SE)"
  ) +
  theme(plot.title = element_text(hjust = 0.5))

p
# Save SVG
svg("sup_Forest_SHAP_forwards_energy.svg", width = 4, height = 4) 
p
dev.off()


# 5. Retrieve % Increase in MSE from the RF model for metric
# For regression, randomForest calculates %IncMSE in its importance output.
rf_importance_forwards_energy <- as.data.frame(rf_model_final_forwards_energy$importance)
rf_importance_forwards_energy$feature <- rownames(rf_importance_forwards_energy)

# Merge the RF importance with the aggregated SHAP values for metric
final_table_forwards_energy <- merge(rf_importance_forwards_energy, shap_summary_forwards_energy, by = "feature", all.x = TRUE)

# Create a table with IncNodePurity and SHAP value ± SD for metric
final_table_forwards_energy <- final_table_forwards_energy %>%
  dplyr::select(feature, IncNodePurity, mean_shap, sd_shap) %>%
  arrange(desc(abs(mean_shap)))  # Order by absolute mean SHAP if desired

# Optionally, format the SHAP column as "mean_shap ± sd_shap"
final_table_forwards_energy <- final_table_forwards_energy %>%
  mutate(SHAP = paste0(round(mean_shap, 3), " ± ", round(sd_shap, 3)))

# Print the final table for metric
print(final_table_forwards_energy)

# Write csv
write.csv(final_table_forwards_energy, "SHAP_Summary_Forwards_Energy.csv", row.names = FALSE)




## Check feature effects (sup)----
# ...............................................

### Forwards-confusion ----

#Set 1
p = ggplot(Forest_df, aes(x=fw.pat.L.stdev,y=fw.pat.E.mean)) + 
  geom_image(aes(image = imdDir), size = 0.08, alpha=1) +  
  theme_light()
p
# Save SVG
svg("Sup_SHAP_FC_feature_1.svg", width = 4, height = 4) 
p
dev.off()


#Set 2
p = ggplot(Forest_df, aes(x=hw.pat.VH.mean,y=hw.pat.L.mean)) + 
  geom_image(aes(image = imdDir), size = 0.08, alpha=1) +  
  theme_light()
p
# Save SVG
svg("Sup_SHAP_FC_feature_2.svg", width = 4, height = 4) 
p
dev.off()



#Set 3
p = ggplot(Forest_df, aes(x=fw.pat.VH.mean,y=hw.shp.rough)) + 
  geom_image(aes(image = imdDir), size = 0.08, alpha=1) +  
  theme_light()
p
# Save SVG
svg("Sup_SHAP_FC_feature_3.svg", width = 4, height = 4) 
p
dev.off()



#Set 4
p = ggplot(Forest_df, aes(x=fw.pat.L.mean,y=hw.pat.L.x)) + 
  geom_image(aes(image = imdDir), size = 0.08, alpha=1) +  
  theme_light()
p
# Save SVG
svg("Sup_SHAP_FC_feature_4.svg", width = 4, height = 4) 
p
dev.off()




### Sideways-confusion ----

#Set 1
p = ggplot(Forest_df, aes(x=hw.pat.VH.mean,y=hw.pat.L.mean)) + 
  geom_image(aes(image = imdDir), size = 0.08, alpha=1) +  
  theme_light()
p
# Save SVG
svg("Sup_SHAP_SC_feature_1.svg", width = 4, height = 4) 
p
dev.off()


#Set 2
p = ggplot(Forest_df, aes(x=body.length,y=fw.pat.L.mean)) + 
  geom_image(aes(image = imdDir), size = 0.08, alpha=1) +  
  theme_light()
p
# Save SVG
svg("Sup_SHAP_SC_feature_2.svg", width = 4, height = 4) 
p
dev.off()



#Set 3
p = ggplot(Forest_df, aes(x=hw.pat.P.stdev,y=hw.shp.rough)) + 
  geom_image(aes(image = imdDir), size = 0.08, alpha=1) +  
  theme_light()
p
# Save SVG
svg("Sup_SHAP_SC_feature_3.svg", width = 4, height = 4) 
p
dev.off()



#Set 4
p = ggplot(Forest_df, aes(x=hw.pat.DR.mean,y=fw.pat.VH.mean)) + 
  geom_image(aes(image = imdDir), size = 0.08, alpha=1) +  
  theme_light()
p
# Save SVG
svg("Sup_SHAP_SC_feature_4.svg", width = 4, height = 4) 
p
dev.off()




### Forwards-Energy ----

#Set 1
p = ggplot(Forest_df, aes(x=hw.pat.L.mean,y=fw.pat.L.mean)) + 
  geom_image(aes(image = imdDir), size = 0.08, alpha=1) +  
  theme_light()
p
# Save SVG
svg("Sup_SHAP_FE_feature_1.svg", width = 4, height = 4) 
p
dev.off()


#Set 2
p = ggplot(Forest_df, aes(x=fw.pat.E.mean,y=fw.pat.L.stdev)) + 
  geom_image(aes(image = imdDir), size = 0.08, alpha=1) +  
  theme_light()
p
# Save SVG
svg("Sup_SHAP_FE_feature_2.svg", width = 4, height = 4) 
p
dev.off()



#Set 3
p = ggplot(Forest_df, aes(x=hw.pat.L.stdev,y=hw.pat.E.mean)) + 
  geom_image(aes(image = imdDir), size = 0.08, alpha=1) +  
  theme_light()
p
# Save SVG
svg("Sup_SHAP_FE_feature_3.svg", width = 4, height = 4) 
p
dev.off()



#Set 4
p = ggplot(Forest_df, aes(x=fw.pat.L.x,y=fw.pat.P.x)) + 
  geom_image(aes(image = imdDir), size = 0.08, alpha=1) +  
  theme_light()
p
# Save SVG
svg("Sup_SHAP_FE_feature_4.svg", width = 4, height = 4) 
p
dev.off()


