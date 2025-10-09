
# INSTURCTIONS----

#DATA, Import and process datasets-----------

## Load Libraries ----
#~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

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
library(plyr)
library(randomForest)
library(caret)
library(iml)
library(dplyr)
library(rpart)
library(rpart.plot)

setwd(dirname(rstudioapi::getSourceEditorContext()$path))



## Prep Collins Data ----
#~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
EMDdata <- read.csv("./DF_EMD.csv", header=TRUE)
PATdata <- read.csv("./DF_Pattern_Analysis.csv", header=TRUE)
INFOdata <- read.csv("./DF_Info_Table.csv", header=TRUE)

dataSet=EMDdata
nrow(dataSet)

dataSet = merge(dataSet,PATdata)
dataSet = merge(dataSet,INFOdata)

nrow(dataSet)

dataSet=subset(dataSet,treatment=="Patterned_Flapping")

dataSet$ButterflyID = dataSet$genusSpecies # Used to ID the butterly, either its species binomial or its unique ID tag
dataSet$SelectionPressure = "Nature"
dataSet$Population = "Collins"
dataSet$Repeat = 0
dataSet$Generation = "End"

dataSet$morphoType = paste(dataSet$genusSpecies,"_",dataSet$sex,sep="")
dataSet$wingDir = paste(dataSet$morphoType,".png",sep="")
dataSet$imdDir <- paste(dirname(rstudioapi::getSourceEditorContext()$path), "/Wing_PNGs/Collins/", dataSet$wingDir,sep="")



## Prep GA Data ----
#~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

GAPdata <- read.csv("./GA_Population_Data.csv", header=TRUE)
GAMdata <- read.csv("./GA_Pattern_Analysis.csv", header=TRUE)

GAM_clean <- GAMdata %>% distinct()
GAP_clean <- GAPdata %>% distinct()


GAP_clean$Generation = GAP_clean$Generation
GAP_clean$Unique = with(GAP_clean,paste(Population,Generation,ID))


GAP_clean = subset(GAP_clean,Generation==0 | Generation ==20)



GAdataSet = merge(GAP_clean,GAM_clean)

nrow(GAPdata)
nrow(GAMdata)
nrow(GAdataSet)

s =  subset(GAdataSet,Population=="Papilio_machaon_BF_1" )
nrow(s)/2/2




GAdataSet <- GAdataSet %>%
  mutate(
    parts = str_split(Population, "_", simplify = TRUE),
    Wingshape = paste(parts[, 1], parts[, 2], sep = "_"),
    SelectionPressure = parts[, 3],
    Repeat = as.integer(parts[, 4])
  )


attach(GAdataSet)
GAdataSet$ButterflyID = paste(Population,Generation,ID,sep="/") # Used to ID the butterly, either its species binomial or its unique ID tag
GAdataSet$genusSpecies = GAdataSet$Wingshape

nrow(GAdataSet)
GAdataSet = merge(GAdataSet,INFOdata)
nrow(GAdataSet)





GAdataSet$SelectionPressure = revalue(GAdataSet$SelectionPressure, c("BF" = "Forwards-Confusion", "FE" = "Forwards-Energy", "SF" = "Sideways-Confusion", "R"="Random-Selection"))
GAdataSet$Generation = as.factor(GAdataSet$Generation)
GAdataSet$GenNum = as.factor(GAdataSet$Generation)
GAdataSet$Generation = revalue(GAdataSet$GenNum, c("0" = "Start", "20" = "End"))


s =  subset(GAdataSet,Population=="Papilio_machaon_BF_1" & Generation=="Start")
nrow(s)/2


GAdataSet$imdDir <- paste(dirname(rstudioapi::getSourceEditorContext()$path), "/Wing_PNGs/GA/", GAdataSet$Population, "/", GAdataSet$GenNum,"_", GAdataSet$ID, ".png" ,sep="")



GAdataSet <- GAdataSet %>%
  dplyr::group_by( Population,SelectionPressure, Generation,) %>%
  dplyr::mutate(
    rank_fit = min_rank(desc(Fitness)),
  ) %>%
  ungroup()







# SCREEN GA DATA----
#~~~~~~~~~~~~~~~~~~~~~~~~~~~~~


## Correlation between forwards and sideways confusion (main) ----

d = subset(GAdataSet,SelectionPressure!="Random-Selection") # Metrics weren't measured for the randomly selected

d$Forwards_Confusion= with(d,(down_mean-up_mean)/(down_mean+up_mean))
d$Sideways_Confusion = with(d,(left_mean-up_mean)/(left_mean+up_mean))


m = lm(Forwards_Confusion ~ Sideways_Confusion, data = d)
summary(m)

d$Group = d$SelectionPressure

d$Group = ifelse(d$Generation=="Start","Unevolved",d$Group)

## Correlation plot (supp) ----
p = ggplot(d, aes(x = Sideways_Confusion, y = Forwards_Confusion, col = Group)) + 
  geom_point(alpha=0.2) +
  geom_smooth(method=glm, formula=y~poly(x,1)) + 
  scale_colour_manual(values = c("#CC79A7","orange","#56B4E9","#999999")) +
  theme_light()
p

p
# Save SVG
svg("Sup_Forwards_Sideways_Correlation.svg", width = 5, height = 3) 
p
dev.off()





## Improvement in fitness (supp) ----

## Did fitness improve across our populations

d = subset(GAdataSet,SelectionPressure!="Random-Selection") # No point in looking at fitness for random

d <- d %>%
  group_by(SelectionPressure) %>%
  dplyr::mutate(Fitness_scaled = scale(Fitness)) %>%
  ungroup()


m = lm(Fitness_scaled ~ Generation, data = d)
summary(m)


d$SelectionPressure<- factor(d$SelectionPressure, levels = c("Forwards-Confusion", "Sideways-Confusion", "Forwards-Energy","Random-Selection"))


p = ggplot(d, aes(x = SelectionPressure, y = Fitness_scaled, fill=SelectionPressure, group =paste(SelectionPressure,Wingshape))) +
  geom_boxplot(aes(alpha=Wingshape))+
  facet_grid( ~ Generation)+
  scale_fill_manual(values = c("#CC79A7","orange","#56B4E9","red")) +
  theme_classic()
p
# Save SVG
svg("Sup_Scaled_Fitness_Evolution.svg", width = 5, height = 3) 
p
dev.off()




# PREP DATA FOR RANDOM FOREST & PCA ------------

## Crop Collins Data----
#~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

df = dataSet

fw = subset(df,wing=="forewing")
nrow(fw)

df_f=data.frame(ButterflyID =fw$ButterflyID, 
                genusSpecies = fw$genusSpecies,
                Species = fw$Species,
                Genus = fw$Genus,
                Tribe = fw$Tribe,
                Subfamily = fw$Subfamily,
                Family = fw$Family,
                Population =fw$Population,
                Generation = fw$Generation, 
                Repeat = fw$Repeat,
                SelectionPressure = fw$SelectionPressure,
                imdDir = fw$imdDir,
                #Fitness
                fitness = fw$up_mean,
                #EMD
                up_mean = fw$up_mean, down_mean = fw$down_mean, left_mean = fw$left_mean, right_mean = fw$right_mean,
                #Pattern
                fw.pat.L.mean=fw$L_mean,fw.pat.E.mean=fw$E_mean,fw.pat.P.mean=fw$P_mean,fw.pat.VH.mean=fw$VH_mean,fw.pat.OA.mean=fw$OA_mean,fw.pat.DR.mean=fw$DR_mean,
                fw.pat.L.stdev=fw$L_stdev,fw.pat.E.stdev=fw$E_stdev,fw.pat.P.stdev=fw$P_stdev,fw.pat.VH.stdev=fw$VH_stdev,fw.pat.OA.stdev=fw$OA_stdev,fw.pat.DR.stdev=fw$DR_stdev,
                fw.pat.L.x=fw$L_x,fw.pat.E.x=fw$E_x,fw.pat.P.x=fw$P_x,fw.pat.VH.x=fw$VH_x,fw.pat.OA.x=fw$OA_x,fw.pat.DR.x=fw$DR_x,
                fw.pat.L.y=fw$L_y,fw.pat.E.y=fw$E_y,fw.pat.P.y=fw$P_y,fw.pat.VH.y=fw$VH_y,fw.pat.OA.y=fw$OA_y,fw.pat.DR.y=fw$DR_y)
df_f

hw = subset(df,wing=="hindwing")

df_h=data.frame(ButterflyID =hw$ButterflyID, 
                genusSpecies = hw$genusSpecies,
                Species = hw$Species,
                Genus = hw$Genus,
                Tribe = hw$Tribe,
                Subfamily = hw$Subfamily,
                Family = hw$Family,
                Population =hw$Population,
                Generation = hw$Generation, 
                Repeat = hw$Repeat,
                SelectionPressure = hw$SelectionPressure,
                imdDir = hw$imdDir,
                #Fitness
                fitness = hw$up_mean,
                #EMD
                up_mean = hw$up_mean, down_mean = hw$down_mean, left_mean = hw$left_mean, right_mean = hw$right_mean,
                #Pattern
                hw.pat.L.mean=hw$L_mean,hw.pat.E.mean=hw$E_mean,hw.pat.P.mean=hw$P_mean,hw.pat.VH.mean=hw$VH_mean,hw.pat.OA.mean=hw$OA_mean,hw.pat.DR.mean=hw$DR_mean,
                hw.pat.L.stdev=hw$L_stdev,hw.pat.E.stdev=hw$E_stdev,hw.pat.P.stdev=hw$P_stdev,hw.pat.VH.stdev=hw$VH_stdev,hw.pat.OA.stdev=hw$OA_stdev,hw.pat.DR.stdev=hw$DR_stdev,
                hw.pat.L.x=hw$L_x,hw.pat.E.x=hw$E_x,hw.pat.P.x=hw$P_x,hw.pat.VH.x=hw$VH_x,hw.pat.OA.x=hw$OA_x,hw.pat.DR.x=hw$DR_x,
                hw.pat.L.y=hw$L_y,hw.pat.E.y=hw$E_y,hw.pat.P.y=hw$P_y,hw.pat.VH.y=hw$VH_y,hw.pat.OA.y=hw$OA_y,hw.pat.DR.y=hw$DR_y)

nrow(df_f)
nrow(df_h)
df_FC=merge(df_f,df_h)

nrow(df_FC)


## Crop GA Data----
#~~~~~~~~~~~~~~~~~~~~~~~~~~~~~



df = GAdataSet

df$wing = df$Wing

fw = subset(df,wing=="forewing")
nrow(fw)
fw$Wingshape
fw$Population

length(fw$Population)

df_f=data.frame(ButterflyID =fw$ButterflyID, 
                genusSpecies = fw$genusSpecies,
                Species = fw$Species,
                Genus = fw$Genus,
                Tribe = fw$Tribe,
                Subfamily = fw$Subfamily,
                Family = fw$Family,
                Population =fw$Population,
                Generation = fw$Generation, 
                Repeat = fw$Repeat,
                SelectionPressure = fw$SelectionPressure,
                imdDir = fw$imdDir,
                #Fitness
                fitness = fw$Fitness,
                #EMD
                up_mean = fw$up_mean, down_mean = fw$down_mean, left_mean = fw$left_mean, right_mean = fw$right_mean,
                #Pattern
                fw.pat.L.mean=fw$L_mean,fw.pat.E.mean=fw$E_mean,fw.pat.P.mean=fw$P_mean,fw.pat.VH.mean=fw$VH_mean,fw.pat.OA.mean=fw$OA_mean,fw.pat.DR.mean=fw$DR_mean,
                fw.pat.L.stdev=fw$L_stdev,fw.pat.E.stdev=fw$E_stdev,fw.pat.P.stdev=fw$P_stdev,fw.pat.VH.stdev=fw$VH_stdev,fw.pat.OA.stdev=fw$OA_stdev,fw.pat.DR.stdev=fw$DR_stdev,
                fw.pat.L.x=fw$L_x,fw.pat.E.x=fw$E_x,fw.pat.P.x=fw$P_x,fw.pat.VH.x=fw$VH_x,fw.pat.OA.x=fw$OA_x,fw.pat.DR.x=fw$DR_x,
                fw.pat.L.y=fw$L_y,fw.pat.E.y=fw$E_y,fw.pat.P.y=fw$P_y,fw.pat.VH.y=fw$VH_y,fw.pat.OA.y=fw$OA_y,fw.pat.DR.y=fw$DR_y)
df_f

hw = subset(df,wing=="hindwing")

df_h=data.frame(ButterflyID =hw$ButterflyID, 
                genusSpecies = hw$genusSpecies,
                Species = hw$Species,
                Genus = hw$Genus,
                Tribe = hw$Tribe,
                Subfamily = hw$Subfamily,
                Family = hw$Family,
                Population =hw$Population,
                Generation = hw$Generation, 
                Repeat = hw$Repeat,
                SelectionPressure = hw$SelectionPressure,
                imdDir = hw$imdDir,
                #Fitness
                fitness = hw$Fitness,
                #EMD
                up_mean = hw$up_mean, down_mean = hw$down_mean, left_mean = hw$left_mean, right_mean = hw$right_mean,
                #Pattern
                hw.pat.L.mean=hw$L_mean,hw.pat.E.mean=hw$E_mean,hw.pat.P.mean=hw$P_mean,hw.pat.VH.mean=hw$VH_mean,hw.pat.OA.mean=hw$OA_mean,hw.pat.DR.mean=hw$DR_mean,
                hw.pat.L.stdev=hw$L_stdev,hw.pat.E.stdev=hw$E_stdev,hw.pat.P.stdev=hw$P_stdev,hw.pat.VH.stdev=hw$VH_stdev,hw.pat.OA.stdev=hw$OA_stdev,hw.pat.DR.stdev=hw$DR_stdev,
                hw.pat.L.x=hw$L_x,hw.pat.E.x=hw$E_x,hw.pat.P.x=hw$P_x,hw.pat.VH.x=hw$VH_x,hw.pat.OA.x=hw$OA_x,hw.pat.DR.x=hw$DR_x,
                hw.pat.L.y=hw$L_y,hw.pat.E.y=hw$E_y,hw.pat.P.y=hw$P_y,hw.pat.VH.y=hw$VH_y,hw.pat.OA.y=hw$OA_y,hw.pat.DR.y=hw$DR_y)


df_h$ButterflyID

nrow(df_f)
nrow(df_h)
df_GA=merge(df_f,df_h)
nrow(df_GA)

s =  subset(df_f,Population=="Papilio_machaon_BF_1")
nrow(s)

s =  subset(df_h,Population=="Papilio_machaon_BF_1")
nrow(s)

s =  subset(df_GA,Population=="Papilio_machaon_BF_1")
nrow(s)


#Merge GA and BF data
df = rbind(df_GA,df_FC)


nrow(df)

attach(df)
df$Forwards_Confusion= (down_mean-up_mean)/(down_mean+up_mean)
df$Sideways_Confusion = (left_mean-up_mean)/(left_mean+up_mean)
df$Forwards_Energy = up_mean



# PCA and Pairwise Comparisons ----


## Create Groupings ----
#...................................
set.seed(111)



df_pair$CreationMethod = ifelse(df_pair$SelectionPressure == "Nature", "Natural", "GA")

attach(df_pair)

df_pair$Group_FC = df_pair$SelectionPressure
df_pair$Group_FC = ifelse(df_pair$Generation=="Start","Unevolved",df_pair$Group_FC)


nrow(df_pair)

## Split fittest individuals from the final populations----
#................................................................
df_pair$fitness

df_pair <- df_pair%>%
  dplyr::group_by(Population,Generation) %>%
  dplyr::mutate(
    rank_Fit = min_rank(desc(fitness)),
    rank_FC = min_rank(desc(Forwards_Confusion)),
    rank_SC = min_rank(desc(Sideways_Confusion)),
    rank_FE = min_rank(desc(Forwards_Energy)),
  ) %>%
  ungroup()

ggplot(subset(df_pair), 
       aes(x = Group_FC, y = rank_FC, fill=Group_FC)) +
  geom_point()+
  theme_classic()



d1 = subset(df_pair,Group_FC=="Nature")
d2 = subset(df_pair,Group_FC=="Forwards-Confusion" & rank_FC<=1 )
d3 = subset(df_pair,Group_FC=="Sideways-Confusion" & rank_SC<=1)
d4 = subset(df_pair,Group_FC=="Forwards-Energy" & rank_FE<=1)
d5 = subset(df_pair,Group_FC=="Unevolved"  )
d6 = subset(df_pair,Group_FC=="Random-Selection" & rank_Fit<=1 )



bf_d=rbind(d1,d2,d3,d4,d5,d6)



pcData=bf_d%>% dplyr::select(-ButterflyID,
                                  -genusSpecies,
                                  -Species,
                                  -Genus,
                                  -Tribe,
                                  -Subfamily,
                                  -Family,
                                  -Population,
                                  -Generation,
                                  -Repeat,
                                  -SelectionPressure, 
                                  -imdDir,
                                  -fitness,
                                  -rank_Fit,
                                  -up_mean, -down_mean, - left_mean, - right_mean,
                                  -Forwards_Confusion, -Sideways_Confusion,-Forwards_Energy,
                                  -CreationMethod, -Group_FC, -rank_FC, -rank_SC, -rank_FE)



non_numeric_cols <- names(pcData)[!sapply(pcData, is.numeric)]
non_numeric_cols
cols <- names(pcData)
cols


#Create PCs that are both centered and scaled
myPr <- prcomp(pcData, scale = TRUE, center = TRUE) #prcomp

## Generate PCs----
#...................................
# Get PC summary, how much variance is explained by each PC?
summary(myPr)

# Extract Loadings
loadings <- myPr$rotation
loadings

PC1 = loadings[,1]
PC2 = loadings[,2]
PC3 = loadings[,3]
PC4 = loadings[,4]
PCs = loadings[,1:4]
PCsRank = sqrt(PCs^2)
PCsRank 
PCsRank<- as.data.frame(PCsRank)
PCsRank$PC1R <- as.numeric(PCsRank$PC1)
PCsRank$PC2R <- as.numeric(PCsRank$PC2)
PCsRank$PC3R <- as.numeric(PCsRank$PC3)
PCsRank$PC4R <- as.numeric(PCsRank$PC4)
PCSRANKED <-cbind(PCs[,1:4],PCsRank[,5:8])

# Identify which variables explain each PC
# If the majority of PCs are negative you may wish to multiply the PC by -1.

## PC Loadings (Supp) ----

# Get Most Important for PC1
PCsRanked1 <- PCSRANKED[order(PCSRANKED$PC1R, decreasing = TRUE),]  
PCsRanked1 <- cbind(PCsRanked1[1])
PCsRanked1

# -Get Most Important for PC2
PCsRanked2 <- PCSRANKED[order(PCSRANKED$PC2R, decreasing = TRUE),]  
PCsRanked2 <- cbind(PCsRanked2[2])
PCsRanked2



bf_df_pair = cbind(bf_d, myPr$x[,1:2]) 


## Examine PC Hulls (Main)----
#...................................

GroupPalette = c("#009E73","#999999","#CC79A7","#56B4E9","orange","red")
bf_df_pair$Group_FC <- factor(bf_df_pair$Group_FC, levels = c("Nature", "Unevolved", "Forwards-Confusion", "Sideways-Confusion", "Forwards-Energy","Random-Selection"))

hulls <- bf_df_pair %>%
  filter(!is.na(PC1) & !is.na(PC2)) %>%  # Exclude rows with missing coordinates
  group_by(paste(Group_FC)) %>%
  slice(chull(PC1, PC2))  # Compute convex hull for each group

p = ggplot(subset(bf_df_pair,), aes(x = PC1, y = PC2, col=Group_FC, shape=CreationMethod)) +
  geom_point(alpha=0.2)+
  geom_polygon(data = hulls, aes(x = PC1, y = PC2,fill = Group_FC, group = paste(Group_FC), col = Group_FC), 
               alpha = 0.2,  size = 1)+
  scale_fill_manual(values = GroupPalette) + 
  scale_colour_manual(values = GroupPalette) +
  theme_classic()

p
# Save SVG
svg("Fig_3_Hulls.svg", width = 5, height = 3) 
p
dev.off()



## Pairwise Difference ----
#...................................
data =bf_df_pair

pairwise_df_pair_Nat <- subset(data,Group_FC=="Nature") %>%
  dplyr::rename_with(~ paste0(.x, "_Nat"))


pairwise_df_pair_All <- subset(data) %>%
  dplyr::rename_with(~ paste0(.x, "_All"))


# 1. Add row identifiers
pairwise_df_pair_All <- pairwise_df_pair_All %>% dplyr::mutate(id_All = row_number())
pairwise_df_pair_Nat <- pairwise_df_pair_Nat %>% dplyr::mutate(id_Nat = row_number())

# 2. Create all combinations (Cartesian product)
pairwise_combos <- crossing(pairwise_df_pair_All, pairwise_df_pair_Nat)

# 3. Remove self-pairs (if dataframes overlap, adjust accordingly)
pairwise_FC_df_pair<- pairwise_combos %>% dplyr::filter(id_All != id_Nat)



attach(pairwise_FC_df_pair)

pairwise_FC_df_pair$PC_Distance = ((PC1_All-PC1_Nat)^2 + 
                              (PC2_All-PC2_Nat)^2
                              ) ^0.5


unique(Group_FC_All)




CompPalette =  c("#009E73","#999999","#CC79A7","#56B4E9","orange","red")

pairwise_FC_df_pair$Comparisons = "1_Nature"
pairwise_FC_df_pair$Comparisons = ifelse(pairwise_FC_df_pair$Group_FC_All=="Unevolved",
                                    "2_Unevolved",pairwise_FC_df_pair$Comparisons)
pairwise_FC_df_pair$Comparisons = ifelse(pairwise_FC_df_pair$Group_FC_All=="Forwards-Confusion",
                                    "3_Forwards-Confusion",pairwise_FC_df_pair$Comparisons)
pairwise_FC_df_pair$Comparisons = ifelse(pairwise_FC_df_pair$Group_FC_All=="Sideways-Confusion",
                                    "4_Sideways-Confusion",pairwise_FC_df_pair$Comparisons)
pairwise_FC_df_pair$Comparisons = ifelse(pairwise_FC_df_pair$Group_FC_All=="Forwards-Energy",
                                    "5_Forwards-Energy",pairwise_FC_df_pair$Comparisons)
pairwise_FC_df_pair$Comparisons = ifelse(pairwise_FC_df_pair$Group_FC_All=="Random-Selection",
                                    "6_Random-Selection",pairwise_FC_df_pair$Comparisons)




sd= subset(pairwise_FC_df_pair,Comparisons=="2_Unevolved")
linePo = median(sd$PC_Distance)

p1<-ggplot(pairwise_FC_df_pair, aes(x=Comparisons, y=PC_Distance, fill=Comparisons)) +
  geom_violin(alpha=0.25)+
  scale_y_sqrt()+
  geom_boxplot(alpha=0.25, width=0.25)+
  scale_fill_manual(values = CompPalette) + 
  scale_colour_manual(values = CompPalette) +
  geom_hline(yintercept=linePo, linetype = 2)
p1+theme_classic()+theme(legend.position = "none")


mod1 <- lm((PC_Distance^0.5) ~ Comparisons, data =pairwise_FC_df_pair)
summary(mod1) 
hist(residuals(mod1))
qqnorm(residuals(mod1))     # Plots the residuals against a normal distribution
qqline(residuals(mod1))     # Adds a reference line for normality



## Emmeans Model Output (Main & Supp) ----
library(emmeans)
emm <- emmeans(mod1, pairwise ~ Comparisons, adjust = "tukey")
summary(emm)

emm_df_pair <- as.data.frame(emm$emmeans)

p  = ggplot(emm_df_pair, aes(x = Comparisons, y = emmean, col = Comparisons)) +
  geom_point(size = 3) +
  geom_errorbar(aes(ymin = lower.CL, ymax = upper.CL), width = 0.3, size= 1) +
  scale_y_log10() +
  scale_fill_manual(values = CompPalette) + 
  scale_colour_manual(values = CompPalette) +theme_classic()+theme(legend.position = "none")
p

# Save SVG
svg("Fig_3_EMMEANS.svg", width = 5, height = 3) 
p
dev.off()



