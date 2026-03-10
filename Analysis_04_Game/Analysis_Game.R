# Coded by George.RA.Hancock 08/01/2026


#....................................................................................................................................
#----Setup----
#....................................................................................................................................
#....................................................................................................................................



#Load R packages.
#...................................
#Make sure these are all installed.

library(tidyverse)
library(ggplot2)
library(lme4)
library(lmerTest)
library(dplyr)
library(plyr)
library(ggimage)
library(slider)
library(car)
library(emmeans)
library(gtools)
library(MASS)
library(sf)
library(purrr)
library(viridis)

#Set working directory to source
#...................................
setwd(dirname(rstudioapi::getSourceEditorContext()$path))



#Dataframes
#..................................

# df, the main dataframe initially includes all data from the game, then
#     data for the frame clicked is added on top.
        # Main variables
        # Player ID, the unique ID code of the player
        # Tutorial, was the trial part of the tutorial
        # trialNumber, the number of the trial 1-30
        # pathNumber, the unique path number
        # flipX, whether the path was flipped on the x axis
        # flipY, whether the path was flipped on the y axis
        # clickX, the x coordinate of the click
        # clickY, the y coordinate of the click
        # clickDeg, the orientation of the click relative the butterlies orientation in degrees
        # clickDist, the euclidean distance of the click from the butterflies
        # clickFrame, the frame of the click
        # clickTime, the time of the click
        # butterflyX, the x coordinate of the butterfly
        # butterflyY, the y coordinate of the butterfly
        # butterflyDeg, the heading of the butterfly in degrees
        # displayRate, the frame rate the butterfly was displayed at


# paths, data for the specific paths calculated based on the x and y coordinates 
      # and heading.

# emd, contains the emd measured for the butterfly when the path is re-orientated such 
      # that the start and end point are in a straight vertical line.

# simed, contains the emd measured for a white triangle that follows the butterfly path 
      # re-orientated such the start and end point are in a straight vertical line.

# hitbox, contains the hitbox areas for each butterfly for each frame of each flight path.


#Screen Features
#..................................
xMax = 1920
yMax = 1080


#Import and adjust data
#...................................


# Get a list of all CSV files in the Results folder
files <- list.files(
  path = "Append_Results",
  pattern = "\\.csv$",
  full.names = TRUE
)

# Read each CSV and row-bind into a single data frame
df <- do.call(
  rbind,
  lapply(files, read.csv, stringsAsFactors = FALSE)
)



paths = read.csv("data_flightPath.csv")
hitbox = read.csv("data_hitbox.csv")
emd = read.csv("data_emd.csv")
simemd = read.csv("data_triangle.csv")


#Paths, create direction metric.

paths$x_direction = sin(paths$heading_deg/180*pi)
paths$y_direction = cos(paths$heading_deg/180*pi)

paths <- paths %>%
  group_by(pathNumber) %>%
  dplyr::arrange(frame, .by_group = TRUE) %>%
  dplyr::mutate(path_final_y_sign = factor(
    ifelse(last(y) >= 0, "positive", "negative"),
    levels = c("negative", "positive")
  )) %>%
  ungroup()

paths$dist_300ms = (paths$x_diff_300ms^2 + paths$y_diff_300ms^2)^0.5

paths <- paths %>%
  group_by(pathNumber) %>%
  dplyr::arrange(frame, .by_group = TRUE) %>%
  dplyr::mutate(Meanspeed = mean(dist_300ms)) %>%
  ungroup()


paths$ExpectedHeading = paths$heading_deg - paths$heading_diff_300ms 
paths$pastX = paths$x - paths$x_diff_300ms
paths$pastY = paths$y - paths$y_diff_300ms
paths$expectedX = paths$pastX + cos(paths$ExpectedHeading/180*pi) * paths$Meanspeed
paths$expectedY = paths$pastY + sin(paths$ExpectedHeading/180*pi) * paths$Meanspeed
paths$expectedDist = with(paths,((x-expectedX)^2 + (y-expectedY)^2 )^0.5)

min(paths$x)
mean(paths$x_diff_300ms)
mean(paths$y_diff_300ms)

# Rescale hitboxes, as images are 66.6% the size of the screen
hitbox <- hitbox %>%
  dplyr::mutate(
    across(
      .cols = where(is.numeric) & !c(pathNumber, frame),
      ~ . * 1.5
    )
  )

#Add Confusion Measures
emd$Forwards_Confusion = (emd$EMD_Backward - emd$EMD_Forward) / (emd$EMD_Backward + emd$EMD_Forward)
emd$Sideways_Confusion = ((emd$EMD_Left/2+emd$EMD_Right/2) - emd$EMD_Forward) / ((emd$EMD_Left/2+emd$EMD_Right/2)+ emd$EMD_Forward)
emd$Left_Right_Bias = (emd$EMD_Left - emd$EMD_Right) / (emd$EMD_Left + emd$EMD_Right)


simemd$sim_Forwards_Confusion = (simemd$TriangleEMD_Backward - simemd$TriangleEMD_Forward) / (simemd$TriangleEMD_Backward + simemd$TriangleEMD_Forward) 
simemd$sim_Sideways_Confusion = ((simemd$TriangleEMD_Left/2+simemd$TriangleEMD_Right/2) - simemd$TriangleEMD_Forward) / ((simemd$TriangleEMD_Left/2+simemd$TriangleEMD_Right/2)+ simemd$TriangleEMD_Forward) 
simemd$sim_Left_Right_Bias = (simemd$TriangleEMD_Left - simemd$TriangleEMD_Right) / (simemd$TriangleEMD_Left + simemd$TriangleEMD_Right)




emd <- emd %>%
  group_by(butterfly) %>%
  mutate(
    mean_Forwards_Confusion = mean(Forwards_Confusion, na.rm = TRUE),
    mean_Sideways_Confusion = mean(Sideways_Confusion, na.rm = TRUE),
    mean_Left_Right_Bias    = mean(Left_Right_Bias, na.rm = TRUE)
  ) %>%
  ungroup()




# Parameters

fps <- 240

windows <- tribble(
  ~start_ms, ~end_ms,
  200, 0,
  300, 0,
  400, 0,
  200, 100,
  300, 100,
  400, 100,
  500, 100
)


# Helpers

ms_to_frames <- function(ms, fps) {
  ceiling(fps * ms / 1000)
}


# Sliding-window generator

add_sliding_stats <- function(
    df,
    value_cols,
    fps,
    windows,
    group_cols,
    order_col,
    prefix = ""
) {
  
  for (i in seq_len(nrow(windows))) {
    
    start_ms <- windows$start_ms[i]
    end_ms   <- windows$end_ms[i]
    
    start_frames <- ms_to_frames(start_ms, fps)
    end_frames   <- ms_to_frames(end_ms, fps)
    
    suffix <- paste0(start_ms, "to", end_ms, "ms")
    
    df <- df %>%
      dplyr::arrange(across(all_of(c(group_cols, order_col)))) %>%
      dplyr::group_by(across(all_of(group_cols))) %>%
      dplyr::mutate(
        across(
          all_of(value_cols),
          list(
            mean = ~ slide_dbl(
              .x,
              .before = start_frames,
              .after  = -end_frames,
              mean,
              na.rm = TRUE
            ),
            sd = ~ slide_dbl(
              .x,
              .before = start_frames,
              .after  = -end_frames,
              sd,
              na.rm = TRUE
            )
          ),
          .names = "{prefix}{.col}_{.fn}_{suffix}"
        )
      ) %>%
      ungroup()
  }
  
  df
}


# Apply to EMD data

emd <- add_sliding_stats(
  df = emd,
  value_cols = c(
    "EMD_Forward",
    "EMD_Backward",
    "EMD_Left",
    "EMD_Right",
    "Forwards_Confusion",
    "Sideways_Confusion",
    "Left_Right_Bias"
  ),
  fps = fps,
  windows = windows,
  group_cols = c("butterfly", "pathNumber"),
  order_col = "frame"
)


# Apply to Triangle simulation data

simemd <- add_sliding_stats(
  df = simemd,
  value_cols = c(
    "TriangleEMD_Forward",
    "TriangleEMD_Backward",
    "TriangleEMD_Left",
    "TriangleEMD_Right",
    "sim_Forwards_Confusion",
    "sim_Sideways_Confusion",
    "sim_Left_Right_Bias"
  ),
  fps = fps,
  windows = windows,
  group_cols = "pathNumber",
  order_col = "frame",
  prefix = "sim_"
)




emd$Forwards_Confusion_mean_300to0ms

head(df)


df$imageDir <- paste(dirname(rstudioapi::getSourceEditorContext()$path), "/figure_photos2/", df$butterfly, ".png",sep="")
df$imageDir2 <- paste(dirname(rstudioapi::getSourceEditorContext()$path), "/figure_photos3/", df$butterfly, ".png",sep="")



df$Hitbox = "None"
df$uniquePlay = paste(df$PlayerID,(df$Phase*100+df$trialNumber))



#Create Variables matched to flips
df <- df %>%
  dplyr::mutate(
    clickX_actual      = if_else(flipX == 1, xMax - clickX, clickX),
    butterflyX_actual  = if_else(flipX == 1, xMax - butterflyX, butterflyX),
    butterflyDeg_actual   = if_else(flipX == 1, (180 - butterflyDeg) %% 360, butterflyDeg),
  )
df <- df %>%
  dplyr::mutate(
    clickY_actual      = if_else(flipY == 1, yMax - clickY, clickY),
    butterflyY_actual  = if_else(flipY == 1, yMax - butterflyY, butterflyY),
    butterflyDeg_actual   = if_else(flipY == 1, (-butterflyDeg) %% 360, butterflyDeg),
  )


df$frame = df$clickFrame

df$frame = ifelse(df$frame==0,1,df$frame)

df_raw = df

nrow(subset(df, Tutorial==0))/30



nrow(df)
df2 <- merge(
  df,
  paths,
  by = c("butterfly", "pathNumber", "frame"),
  all.x = TRUE
)

nrow(subset(df2, Tutorial==0))/30


df2 = merge(df2,hitbox)
df2 = merge(df2,emd)
df2 = merge(df2,simemd)


nrow(subset(df2, Tutorial==0))/30


nrow(df2)
df=df2


df$dist_300ms = (df$x_diff_300ms^2 + df$y_diff_300ms^2)^0.5
df$Perpendicular_Distance = df$clickDist*abs(sin(df$clickDeg/180*pi))
df$Parallel_Distance = df$clickDist*abs(cos(df$clickDeg/180*pi))
df$Back_Front= df$clickDist*(cos(df$clickDeg/180*pi))
df$Left_Right= df$clickDist*(sin(df$clickDeg/180*pi))


#Convert G values into hitboxes
df$Hitbox = ifelse(df$clickRGB_G>=245,"Hindwing",df$Hitbox)
df$Hitbox = ifelse(df$clickRGB_G>=80 & df$clickRGB_G<245,"Forewing",df$Hitbox)
df$Hitbox = ifelse(df$clickRGB_G>=30 & df$clickRGB_G<150  & df$butterfly=="Papilio_alexanor__Female" & df$Back_Front<0, "Tail",df$Hitbox)
df$Hitbox = ifelse(df$clickRGB_G<30 & df$clickRGB_B>100, "Body",df$Hitbox )


#Tutorial Length

df <- df %>%
  dplyr::group_by(PlayerID) %>%
  dplyr::mutate(Tutorial_Count = sum(Tutorial == 1, na.rm = TRUE)) %>%
  ungroup()



df$oldId = df$butterfly
unique(df$butterfly)
df <- df %>%
  mutate(butterfly = dplyr::recode(
    butterfly,
    "Brintesia_circe__Male"   = "B.c",
    "Gonepteryx_cleobule__Male" = "G.c",
    "Lycaena_tityrus__Female"   = "L.t",
    "Papilio_alexanor__Female" = "P.a",
    "Pyrgus_sidae__Male"       = "P.s"
  ))

df$butterfly


df$pathNumber = as.factor(df$pathNumber)





#Show image for plot function
make_image_positions <- function(data, x_var, y_var, image_var, pad = 1) {
  x_var     <- enquo(x_var)
  y_var     <- enquo(y_var)
  image_var <- enquo(image_var)
  
  data %>%
    group_by(!!x_var) %>%
    dplyr::summarise(
      y = max(!!y_var, na.rm = TRUE)  * pad,
      image = first(!!image_var),
      .groups = "drop"
    )
}



#....................................................................................................................................
#----Dataframes----
#....................................................................................................................................
#....................................................................................................................................

#Reorder Factors

df$butterfly <- factor(df$butterfly,levels = c("L.t", "G.c", "P.s", "P.a", "B.c"))
emd$butterfly <- factor(emd$butterfly,levels = c("Lycaena_tityrus__Female" , "Gonepteryx_cleobule__Male", "Pyrgus_sidae__Male", "Papilio_alexanor__Female", "Brintesia_circe__Male"))

#Subset Data
df_nonTut = subset(df, Tutorial == 0) # dataframe not including the tutorial
df_hit = subset(df,clickHit==1 & Tutorial == 0) # dataframe only including instances where the butterfly was hit
df_click = subset(df,click==1 & Tutorial == 0) # dataframe only including instances where the screen was clicked/touched

df_nonTut$Tutorial_Count

nrow(df_nonTut)/30
nrow(subset(df_raw, Tutorial==0))/30

#There are 100 players as expected

nrow(df_click)


#....................................................................................................................................
#----Palettes and images----
#....................................................................................................................................
#....................................................................................................................................

Butterfly_Palette <- c( "#dd9386","#e7cf8d", "#a9afa1","#fcfaab","#938c87" )




#....................................................................................................................................
#----Player Plots----
#....................................................................................................................................
#....................................................................................................................................
# Here I have plots showing variation in the performance of different players


# MeanDataset
df_player_means <- df_click %>%
  dplyr::group_by(PlayerID) %>%
  dplyr::summarise(
    mean_clickHit  = mean(clickHit, na.rm = TRUE),
    mean_clickDist = mean(clickDist, na.rm = TRUE)
  )

## [Player] Click Distances----
#- click distance follows a normal distribution
ggplot(df_player_means, aes(x = mean_clickDist)) +
  geom_histogram(
    bins = 30,
    fill = "#4C72B0",
    color = "white",
    alpha = 0.85
  ) +
  geom_vline(
    aes(xintercept = mean(mean_clickDist)),
    linetype = "dashed",
    linewidth = 1
  ) +
  theme_classic(base_size = 14) +
  labs(
    title = "Distribution of Mean Click Distance by Player",
    x = "Mean Click Distance",
    y = "Number of Players"
  )


## [Player] Tutorial lengths----

#Data for how many tutorial takes it took for players
min(df$Tutorial_Count)
max(df$Tutorial_Count)
mean(df$Tutorial_Count)
sd(df$Tutorial_Count)


## [Player] Proportion Hit----
#- Proportion hit follows a positively skewed distribution with a longer negative tail
mean(df_player_means$mean_clickHit*100)

ggplot(df_player_means, aes(x = mean_clickHit*100)) +
  geom_histogram(
    bins = 8,
    fill = "#4C72B0",
    color = "white",
    alpha = 0.85
  ) +
  geom_vline(
    aes(xintercept = mean(mean_clickHit*100)),
    linetype = "dashed",
    linewidth = 1
  ) +
  theme_classic(base_size = 14) +
  labs(
    title = "",
    x = "Butterflies Caught (%)",
    y = "Number of Players"
  )




## [Player] Influence of Tutorial Count on Performance----
#- Number of trials for the tutorial did not effect the proportion hit by players
#- but did increase click distance (people who needed more tutorials were less accurate)
#- this change in accuracy was not significantly different in a particular direction

df_player_hit <- df_nonTut %>%
  dplyr::group_by(PlayerID) %>%
  dplyr::summarise(
    prop_hit = mean(clickHit, na.rm = TRUE),
    mean_dist = mean(clickDist, na.rm = TRUE),
    mean_BF = mean(Back_Front, na.rm = TRUE),
    Tutorial_Count = mean(Tutorial_Count, na.rm = TRUE),
    .groups = "drop"
  )


df_player_hit <- df_player_hit %>%
  mutate(PlayerID = reorder(as.factor(PlayerID), prop_hit))



#HITS
## Plots
ggplot(df_player_hit, aes(x = Tutorial_Count, y = prop_hit)) +
  geom_smooth (aes(),method=glm,formula=y~poly(x,1),alpha=0.25,size=1)+
  geom_point()+
  theme_classic()



## Simple Model
mod1 <- lm(prop_hit ~ Tutorial_Count, 
           data=subset(df_player_hit))
summary(mod1)
anova(mod1)
qqPlot(residuals(mod1))
hist(residuals(mod1))  


# DISTANCE
## Plots
ggplot(df_player_hit, aes(x = Tutorial_Count, y = mean_dist)) +
  geom_smooth (aes(),method=glm,formula=y~poly(x,1),alpha=0.25,size=1)+
  geom_point()+
  theme_classic()


## Simple Model
mod1 <- lm(mean_dist ~ Tutorial_Count, 
           data=subset(df_player_hit))
summary(mod1)
anova(mod1)
qqPlot(residuals(mod1))
hist(residuals(mod1))  



# DISTANCE
## Plots
ggplot(df_player_hit, aes(x = Tutorial_Count, y = mean_BF)) +
  geom_smooth (aes(),method=glm,formula=y~poly(x,1),alpha=0.25,size=1)+
  geom_point()+
  theme_classic()


## Simple Model
mod1 <- lm(mean_BF ~ Tutorial_Count, 
           data=subset(df_player_hit))
summary(mod1)
anova(mod1)
qqPlot(residuals(mod1))
hist(residuals(mod1))  




#....................................................................................................................................
#----Pathing Plots----
#....................................................................................................................................
#....................................................................................................................................

##[Path] Compare Ends ----
#......................

#How do paths that end with the same y axis sign compaer (positive = diagonal flight)
ggplot(subset(paths), aes(x = x, y = y, col=path_final_y_sign)) +
  geom_point(size=0.1)+
  geom_hline(yintercept=1)+
  geom_hline(yintercept=-1)+
  geom_vline(xintercept=1)+
  geom_vline(xintercept=-1)+
  facet_wrap(~as.factor(pathNumber), ncol=5)+
  theme_classic()


#Diagonal flights tend to have greater click distances
ggplot(subset(df), aes(x = path_final_y_sign, y = clickDist, fill=path_final_y_sign)) +
  geom_violin(alpha=0.5)+
  geom_boxplot(width=0.4)+
  theme_classic()


mod1 <- lmer(
  clickDist^0.5  ~  path_final_y_sign  + 
    (1 | PlayerID) +
    (1 | trialNumber),
  data=subset(df_click))

summary(mod1)
anova(mod1)
qqPlot(residuals(mod1))
hist(residuals(mod1))  






#Diagonal flights tend to be harder to hit
ggplot(subset(df), 
       aes(x = path_final_y_sign, 
           y = clickHit, 
           fill = path_final_y_sign,
           col  = path_final_y_sign)) +
  stat_summary(fun = mean, 
               geom = "point", 
               alpha = 0.7) +
  stat_summary(fun.data = mean_se, 
               geom = "errorbar", 
               width = 0.2) +
  theme_classic()


mod1 <- glmer(
  clickHit ~  path_final_y_sign  + 
    (1 | PlayerID) +
    (1 | trialNumber),
  data=subset(df_click),
  family = binomial(link = "logit"))

summary(mod1)
anova(mod1)
qqPlot(residuals(mod1))
hist(residuals(mod1))  




##[Path] Which paths were hardest to hit ----
#......................
#Path 9 was the hardest to hit with paths, 1 ,4,5,6 being notably hard.

#Plot
ggplot(df_click, aes(x = as.factor(pathNumber), fill = as.factor(clickHit))) +
  geom_bar(position = "fill", alpha=0.5) +
  scale_y_continuous(labels = scales::percent) +
  theme_classic() +
  theme(
    text = element_text(size = 15),
    line = element_line(size = 0.6)
  )+
  labs(
    fill = "Front or Back",
    y = "Proportion Front/Back",
    x = "Butterfly"
  )









##[Path] Click Density Plots ----
#......................
#All paths and click positions have been re-flipped to their original starting points.

#kernels
ggplot(
  subset(df_click, pathNumber %in% 1:10),
  aes(x = frame, y = clickY_actual)
) +
  geom_density_2d_filled(
    contour_var = "ndensity",
    alpha = 0.9
  ) +
  geom_line(
    data = subset(paths, pathNumber %in% 1:10),
    aes(
      x = frame,
      y = -y * yMax / 2 + yMax / 2
    ),
    colour = "white",
    size = 1,
    alpha=0.4,
    inherit.aes = FALSE
  ) +
  facet_wrap(~ pathNumber, ncol = 5) +
  coord_cartesian(
    xlim = c(0, 350),
    ylim = c(0, 1080)
  ) +
  theme_classic() +
  labs(
    x = "Frame",
    y = "Click Y Position",
    fill = "Density",
    title = "Click Densities"
  )



#kernels, Miss & Hit
ggplot(
  subset(df_click, pathNumber %in% 1:10),
  aes(x = frame, y = clickY_actual)
) +
  geom_density_2d_filled(
    contour_var = "ndensity",
    alpha = 0.9
  ) +
  geom_line(
    data = subset(paths, pathNumber %in% 1:10),
    aes(
      x = frame,
      y = -y * yMax / 2 + yMax / 2
    ),
    colour = "white",
    size = 1,
    alpha=0.4,
    inherit.aes = FALSE
  ) +
  facet_grid(as.factor(clickHit)~ pathNumber) +
  coord_cartesian(
    xlim = c(0, 350),
    ylim = c(0, 1080)
  ) +
  theme_classic() +
  labs(
    x = "Frame",
    y = "Click Y Position",
    fill = "Density",
    title = "Click Densities"
  )



#....................................................................................................................................
#----Variable FrameRate----
#....................................................................................................................................
#....................................................................................................................................

## [Framerate] does drops in frame rate make the butterfly easier to click ----
#The frame rate was not always consistent across trials, alterning the speed of the butterflies.
#Q. Is there a positive correlation between framerate and click distance

ggplot(df_click, aes(x = displayRate, y = clickDist)) +
  geom_smooth (aes(),method=glm,formula=y~poly(x,1),alpha=0.25,size=1)+
  geom_point(alpha=0.1)+
  theme_classic()

# There is a slight positive correlation
mod1 <- lm(
  clickDist^0.5  ~  displayRate,
  data=subset(df_click))

summary(mod1)
anova(mod1)
qqPlot(residuals(mod1))
hist(residuals(mod1))  

#....................................................................................................................................
#----Phenotype and EMD Measures----
#....................................................................................................................................
#....................................................................................................................................


##[Pheno EMD] Forwards-Confusion, Supp Fig.28 ----
#Plot Forwards-Confusion
img_pos <- make_image_positions(
  data      = df_click,
  x_var     = butterfly,
  y_var     = Forwards_Confusion,
  image_var = imageDir
)
ggplot(df_click, aes(x = butterfly, y = Forwards_Confusion, fill = butterfly)) +
  geom_violin(alpha=0.5) +
  geom_boxplot(width = 0.15) +
  scale_fill_manual(values=Butterfly_Palette)+
  geom_image(
    data = img_pos,
    aes(x = butterfly, y = y*1.2, image = image),
    inherit.aes = FALSE,
    size = 0.08
  )+theme_classic()+
  labs(
    fill = "Butterfly",
    y = "Forwards Confusion",
    x = "Butterfly"
  )



##[Pheno EMD] Sideways-Confusion, Supp Fig.28 ----
#Plot Sideways-Confusion
img_pos <- make_image_positions(
  data      = df_click,
  x_var     = butterfly,
  y_var     = Sideways_Confusion,
  image_var = imageDir
)
ggplot(df_click, aes(x = butterfly, y = Sideways_Confusion, fill = butterfly)) +
  geom_violin(alpha=0.5) +
  geom_boxplot(width = 0.15) +
  scale_fill_manual(values=Butterfly_Palette)+
  geom_image(
    data = img_pos,
    aes(x = butterfly, y = y*1.2, image = image),
    inherit.aes = FALSE,
    size = 0.08
  )+theme_classic()+
  labs(
    fill = "Butterfly",
    y = "Sideways Confusion",
    x = "Butterfly"
  )



##[Pheno EMD] Forwards Energy, Supp Fig.28 ----
img_pos <- make_image_positions(
  data      = df_click,
  x_var     = butterfly,
  y_var     = (EMD_Forward),
  image_var = imageDir
)
ggplot(df_click, aes(x = butterfly, y = EMD_Forward, fill = butterfly)) +
  geom_violin(alpha=0.5) +
  geom_boxplot(width = 0.15) +
  scale_fill_manual(values=Butterfly_Palette)+
  #coord_trans(y = "log10")+
  scale_y_log10()+
  geom_image(
    data = img_pos,
    aes(x = butterfly, y = y*1.2, image = image),
    inherit.aes = FALSE,
    size = 0.08
  )+theme_classic()+
  labs(
    fill = "Butterfly",
    y = "Log Forwards Energy",
    x = "Butterfly"
  )


#....................................................................................................................................
#----Hitbox Sizes----
#....................................................................................................................................
#....................................................................................................................................

# Despite matching wing area, bounding box sizes of butterflies differed.

# Notablly the bounding box for the swallowtail was bigger then the other butterflies.



##[Hitbox] hitbox ----
img_pos <- make_image_positions(
  data      = df_click,
  x_var     = butterfly,
  y_var     = hitbox_area,
  image_var = imageDir
)
ggplot(df_click, aes(x = butterfly, y = hitbox_area, fill = butterfly)) +
  geom_violin(alpha=0.5) +
  geom_boxplot(width = 0.15) +
  scale_fill_manual(values=Butterfly_Palette)+
  geom_image(
    data = img_pos,
    aes(x = butterfly, y = y*1.05, image = image),
    inherit.aes = FALSE,
    size = 0.08
  )+theme_classic()


df_click$hitbox_bound_area = df_click$hitbox_w*df_click$hitbox_h

##[Hitbox] bounding hitbox ----
img_pos <- make_image_positions(
  data      = df_click,
  x_var     = butterfly,
  y_var     = hitbox_bound_area,
  image_var = imageDir
)
ggplot(df_click, aes(x = butterfly, y = hitbox_bound_area, fill = butterfly)) +
  geom_violin(alpha=0.5) +
  geom_boxplot(width = 0.15) +
  scale_fill_manual(values=Butterfly_Palette)+
  geom_image(
    data = img_pos,
    aes(x = butterfly, y = y*1.05, image = image),
    inherit.aes = FALSE,
    size = 0.08
  )+theme_classic()




##[Hitbox] forewing ----
img_pos <- make_image_positions(
  data      = df_click,
  x_var     = butterfly,
  y_var     = forewing_area,
  image_var = imageDir
)
ggplot(df_click, aes(x = butterfly, y = forewing_area, fill = butterfly)) +
  geom_violin(alpha=0.5) +
  geom_boxplot(width = 0.15) +
  scale_fill_manual(values=Butterfly_Palette)+
  geom_image(
    data = img_pos,
    aes(x = butterfly, y = y*1.05, image = image),
    inherit.aes = FALSE,
    size = 0.08
  )+theme_classic()



##[Hitbox] hindwing ----
img_pos <- make_image_positions(
  data      = df_click,
  x_var     = butterfly,
  y_var     = hindwing_area,
  image_var = imageDir
)
ggplot(df_click, aes(x = butterfly, y = hindwing_area, fill = butterfly)) +
  geom_violin(alpha=0.5) +
  geom_boxplot(width = 0.15) +
  scale_fill_manual(values=Butterfly_Palette)+
  geom_image(
    data = img_pos,
    aes(x = butterfly, y = y*1.05, image = image),
    inherit.aes = FALSE,
    size = 0.08
  )+theme_classic()



##[Hitbox] body ----
img_pos <- make_image_positions(
  data      = df_click,
  x_var     = butterfly,
  y_var     = body_area,
  image_var = imageDir
)
ggplot(df_click, aes(x = butterfly, y = body_area, fill = butterfly)) +
  geom_violin(alpha=0.5) +
  geom_boxplot(width = 0.15) +
  scale_fill_manual(values=Butterfly_Palette)+
  geom_image(
    data = img_pos,
    aes(x = butterfly, y = y*1.05, image = image),
    inherit.aes = FALSE,
    size = 0.08
  )+theme_classic()


#....................................................................................................................................
#----Phenotype and Click Measures----
#....................................................................................................................................
#....................................................................................................................................

## [Phenotype] clickTime ----

# P.a. had a significantly but marginally shorter click time then P.s. potentially because P.s. was 
# more cryptic against the background then other butterflies. 


#Plot
img_pos <- make_image_positions(
  data      = df_click,
  x_var     = butterfly,
  y_var     = clickTime,
  image_var = imageDir
)
ggplot(df_click, aes(x = butterfly, y = clickTime, fill = butterfly)) +
  geom_violin(alpha=0.5) +
  geom_boxplot(width = 0.15) +
  scale_fill_manual(values=Butterfly_Palette)+
  geom_image(
    data = img_pos,
    aes(x = butterfly, y = y*1.05, image = image),
    inherit.aes = FALSE,
    size = 0.08
  )+theme_classic()+
  labs(
    fill = "Butterfly",
    y = "Click Time (Seconds)",
    x = "Butterfly"
  )


#Model
mod1 <- lmer(
  clickTime  ~  butterfly+
    (1 | displayRate)+
    (1 | PlayerID)+
    (1 | trialNumber)+
    (1 | pathNumber),
  data=subset(df_click))

summary(mod1)
anova(mod1)
qqPlot(residuals(mod1))
hist(residuals(mod1))  

emm_butterfly <- emmeans(mod1, ~ butterfly)
pairs(emm_butterfly, adjust = "tukey")




## [Phenotype] Backwards vs Forwards click ----

# Attacks for L.t are significantly further forward then any of the other treatments


#Plot
img_pos <- make_image_positions(
  data      = df_click,
  x_var     = butterfly,
  y_var     = Back_Front,
  image_var = imageDir
)
ggplot(df_click, aes(x = butterfly, y = Back_Front, fill = butterfly)) +
  geom_violin(alpha=0.5) +
  geom_boxplot(width = 0.15) +
  scale_fill_manual(values=Butterfly_Palette)+
  geom_image(
    data = img_pos,
    aes(x = butterfly, y = y*1.05, image = image),
    inherit.aes = FALSE,
    size = 0.08
  )+theme_classic()+
  labs(
    fill = "Butterfly",
    y = "Backwards (-) to Forwards (+) click distance",
    x = "Butterfly"
  )


#Model
mod1 <- lmer(
  Back_Front  ~  butterfly+
    (1 | displayRate)+
    (1 | PlayerID)+
    (1 | trialNumber)+
    (1 | pathNumber),
  data=subset(df_click))

summary(mod1)
anova(mod1)
qqPlot(residuals(mod1))
hist(residuals(mod1))  

emm_butterfly <- emmeans(mod1, ~ butterfly)
pairs(emm_butterfly, adjust = "tukey")




## [Phenotype] Perpendicular click dist ----

# Attacks for L.t are more perpendicular then any other treatments.
# This is partly linked to them being further forward (closer to the middle)


#Plot
img_pos <- make_image_positions(
  data      = df_click,
  x_var     = butterfly,
  y_var     = Perpendicular_Distance,
  image_var = imageDir
)
ggplot(df_click, aes(x = butterfly, y = Perpendicular_Distance, fill = butterfly)) +
  geom_violin(alpha=0.5) +
  geom_boxplot(width = 0.15) +
  scale_fill_manual(values=Butterfly_Palette)+
  geom_image(
    data = img_pos,
    aes(x = butterfly, y = y*1.05, image = image),
    inherit.aes = FALSE,
    size = 0.08
  )+theme_classic()+
  labs(
    fill = "Butterfly",
    y = "Distance Perpendicular to Butterfly",
    x = "Butterfly"
  )


#Model
mod1 <- lmer(
  Perpendicular_Distance  ~  butterfly+
    (1 | displayRate)+
    (1 | PlayerID)+
    (1 | trialNumber)+
    (1 | pathNumber),
  data=subset(df_click))

summary(mod1)
anova(mod1)
qqPlot(residuals(mod1))
hist(residuals(mod1))  

emm_butterfly <- emmeans(mod1, ~ butterfly)
pairs(emm_butterfly, adjust = "tukey")


## [Phenotype] Binary hit? ----

# P.a. gets hit significantly more often then B.c and G.c, though this likely 
# due to its larger hitbox

#Plot
ggplot(df_click, aes(x = butterfly, fill = as.factor(clickHit))) +
  geom_bar(position = "fill", alpha=0.5) +
  scale_y_continuous(labels = scales::percent) +
  geom_image(
    data = img_pos,
    aes(x = butterfly, y = 1.05, image = image),
    inherit.aes = FALSE,
    size = 0.08
  )+
  theme_classic() +
  theme(
    text = element_text(size = 15),
    line = element_line(size = 0.6)
  )+
  labs(
    fill = "Front or Back",
    y = "Proportion Front/Back",
    x = "Butterfly"
  )


#Model
mod1 <- glmer(
  as.factor(clickHit)  ~  butterfly+
    (1 | displayRate)+
    (1 | PlayerID)+
    (1 | trialNumber)+
    (1 | pathNumber),
  family = binomial(link = "logit"),
  data=subset(df_click))

summary(mod1)
anova(mod1)
qqPlot(residuals(mod1))
hist(residuals(mod1))  

emm_butterfly <- emmeans(mod1, ~ butterfly)
pairs(emm_butterfly, adjust = "tukey")




## [Phenotype] Hitbox hit ----

# Attacks for L.t are to the forewing compared to others, while P.a. is considerably
# more likely to be hit on the tail/hindwing.
#Plot
ggplot(subset(df_hit,Hitbox!="None"), aes(x = butterfly, fill = Hitbox)) +
  geom_bar(position = "fill", alpha=0.5) +
  scale_y_continuous(labels = scales::percent) +
  geom_image(
    data = img_pos,
    aes(x = butterfly, y = 1.05, image = image),
    inherit.aes = FALSE,
    size = 0.08
  )+
  theme_classic() +
  theme(
    text = element_text(size = 15),
    line = element_line(size = 0.6)
  )+
  labs(
    fill = "Closest",
    y = "Proportion of hits to each hitbox",
    x = "Butterfly"
  )



## [Phenotype] Binary front or back click? ----
# Attacks for L.t are to the front more often then they are to the back compared to B.c and G.c
# Part of this may be due to the position of the red markings.

#Plot
ggplot(df_click, aes(x = butterfly, fill = clickFrontBack)) +
  geom_bar(position = "fill", alpha=0.5) +
  scale_y_continuous(labels = scales::percent) +
  geom_image(
    data = img_pos,
    aes(x = butterfly, y = 1.05, image = image),
    inherit.aes = FALSE,
    size = 0.08
  )+
  theme_classic() +
  theme(
    text = element_text(size = 15),
    line = element_line(size = 0.6)
  )+
  labs(
    fill = "Front or Back",
    y = "Proportion Front/Back",
    x = "Butterfly"
  )

#Model
mod1 <- glmer(
  as.factor(clickFrontBack)  ~  butterfly+
    (1 | displayRate)+
    (1 | PlayerID)+
    (1 | trialNumber)+
    (1 | pathNumber),
  family = binomial(link = "logit"),
  data=subset(df_click))

summary(mod1)
anova(mod1)
qqPlot(residuals(mod1))
hist(residuals(mod1))  

emm_butterfly <- emmeans(mod1, ~ butterfly)
pairs(emm_butterfly, adjust = "tukey")





## [Phenotype] Binary front or back hit? ----

# Hits to L.t. are signifincantly more likely to the front then the back.

#Plot
ggplot(df_hit, aes(x = butterfly, fill = clickFrontBack)) +
  geom_bar(position = "fill", alpha=0.5) +
  scale_y_continuous(labels = scales::percent) +
  geom_image(
    data = img_pos,
    aes(x = butterfly, y = 1.05, image = image),
    inherit.aes = FALSE,
    size = 0.08
  )+
  theme_classic() +
  theme(
    text = element_text(size = 15),
    line = element_line(size = 0.6)
  )+
  labs(
    fill = "Front or Back",
    y = "Proportion Front/Back",
    x = "Butterfly"
  )


#Model
mod1 <- glmer(
  as.factor(clickFrontBack)  ~  butterfly+
    (1 | displayRate)+
    (1 | PlayerID)+
    (1 | trialNumber)+
    (1 | pathNumber),
  family = binomial(link = "logit"),
  data=subset(df_hit))

summary(mod1)
anova(mod1)
qqPlot(residuals(mod1))
hist(residuals(mod1))  

emm_butterfly <- emmeans(mod1, ~ butterfly)
pairs(emm_butterfly, adjust = "tukey")




## [Phenotype] Binary Forewing vs Hindwing ----

# Attacks for P.a. hit the hindwing more than any other butterfly.
# B.c. is the second highest but  isn't significantly different from other treatments

###o. Screen hit box location ----
#Plot
ggplot(df_click, aes(x = butterfly, fill = clickFrontBack)) +
  geom_bar(position = "fill", alpha=0.5) +
  scale_y_continuous(labels = scales::percent) +
  facet_grid(.~ Hitbox)+
theme_classic() +
  theme(
    text = element_text(size = 15),
    line = element_line(size = 0.6)
  )+
  labs(
    fill = "Front or Back",
    y = "Proportion Front/Back",
    x = "Butterfly"
  )
#Forewings aren't always to the front of the butterfly 
# due to phases in the down stroke.


###o. Isolate Forewing vs Hindwing data, supp Fig.31 ----

df_hit$ForeVsHind = ifelse(df_hit$Hitbox=="Tail","Hindwing",df_hit$Hitbox)

df_forhind = subset(df_hit,ForeVsHind=="Forewing" | ForeVsHind=="Hindwing")
df_forhind$ForeVsHind = as.factor(df_forhind$ForeVsHind)

ggplot(df_forhind, aes(x = butterfly, fill = ForeVsHind)) +
  geom_bar(position = "fill", alpha=0.5) +
  scale_y_continuous(labels = scales::percent) +
  theme_classic() +
  geom_image(
    data = img_pos,
    aes(x = butterfly, y = 1.05, image = image),
    inherit.aes = FALSE,
    size = 0.08
  )+
  theme(
    text = element_text(size = 15),
    line = element_line(size = 0.6)
  )+
  labs(
    fill = "Forewing or Hindwing",
    y = "Proportion Forewing to Hindwing",
    x = "Butterfly"
  )

#Model
mod1 <- glmer(
  as.factor(ForeVsHind)  ~  butterfly+
    (1 | displayRate)+
    (1 | PlayerID)+
    (1 | trialNumber)+
    (1 | pathNumber),
  family = binomial(link = "logit"),
  data=subset(df_forhind))

summary(mod1)
anova(mod1)
qqPlot(residuals(mod1))
hist(residuals(mod1))  

emm_butterfly <- emmeans(mod1, ~ butterfly)
pairs(emm_butterfly, adjust = "tukey")



## [Phenotype] Click Density Plots, supp. Fig.30 and Fig.2.c ----

###o. Screen density plots ----
# Butterflies appear to have different shapes for click densities
# Lines show the bounding box of the butterfly not including the antennae.
ggplot(
  df_click,
  aes(x = abs(Left_Right), y = Back_Front)
) +
  geom_density_2d_filled(
    alpha = 0.9
  ) +
  
  geom_vline(xintercept = (164*1.5/2), alpha = 0.4) +
  geom_hline(yintercept = (40*1.5), alpha = 0.4) +
  geom_hline(yintercept = (-55*1.5), alpha = 0.4) +
  
  facet_grid(.~ butterfly) +
  theme_classic() +
  theme(
    #panel.grid.major = element_line(color = "black", size = 0.4, alpha=0.6),
    #panel.grid.minor = element_line(color = "black", size = 0.4, alpha=0.6)
  ) +
  labs(
    x = "Perpendicular Distance Px",
    y = "Parallel Distance",
    fill = "Density",
    title = "Angular Densities"
  )





###o. Extract ellipse data ----

extract_hdr_metrics <- function(data,
                                x_var = "Left_Right",
                                y_var = "Back_Front",
                                group_var = "butterfly",
                                probs = c(0.25, 0.5, 0.75),
                                grid_n = 200) {
  
  results <- data %>%
    group_split(.data[[group_var]]) %>%
    map_dfr(function(df_group) {
      
      group_id <- unique(df_group[[group_var]])
      
      x <- abs(df_group[[x_var]])
      y <- df_group[[y_var]]
      
      # --- KDE ---
      kde <- kde2d(x, y, n = grid_n)
      
      z <- as.vector(kde$z)
      dx <- diff(kde$x[1:2])
      dy <- diff(kde$y[1:2])
      
      prob_mass <- z * dx * dy
      ord <- order(z, decreasing = TRUE)
      cumprob <- cumsum(prob_mass[ord])
      
      # thresholds for HDR
      levels <- sapply(probs, function(p) {
        z[ord][which(cumprob >= p)[1]]
      })
      
      # --- Extract contours and compute metrics ---
      map_dfr(seq_along(probs), function(i) {
        
        p <- probs[i]
        level_val <- levels[i]
        
        cl <- contourLines(kde$x, kde$y, kde$z, levels = level_val)
        
        if (length(cl) == 0) return(NULL)
        
        # Build sf polygons (handle multiple regions)
        polys <- lapply(cl, function(cn) {
          coords <- cbind(cn$x, cn$y)
          
          # close ring if needed
          if (!all(coords[1, ] == coords[nrow(coords), ])) {
            coords <- rbind(coords, coords[1, ])
          }
          
          st_polygon(list(coords))
        })
        
        sf_poly <- st_sfc(polys)
        
        # If multiple polygons, union into single geometry
        sf_poly <- st_union(sf_poly)
        
        # --- Metrics ---
        centroid <- st_centroid(sf_poly)
        centroid_coords <- st_coordinates(centroid)
        
        # Bounding box
        bbox <- st_bbox(sf_poly)  # xmin, ymin, xmax, ymax
        width  <- bbox["xmax"] - bbox["xmin"]
        height <- bbox["ymax"] - bbox["ymin"]
        
        # Use polygon boundary coordinates for PCA
        boundary_coords <- st_coordinates(st_boundary(sf_poly))[,1:2]
        
        pca <- prcomp(boundary_coords, scale. = FALSE)
        
        major_axis <- 2 * pca$sdev[1]
        minor_axis <- 2 * pca$sdev[2]
        aspect_ratio <- major_axis / minor_axis
        
        angle_deg <- atan2(
          pca$rotation[2,1],
          pca$rotation[1,1]
        ) * 180 / pi
        
        tibble(
          butterfly = group_id,
          probability = p,
          centroid_x = centroid_coords[1],
          centroid_y = centroid_coords[2],
          major_axis = major_axis,
          minor_axis = minor_axis,
          aspect_ratio = aspect_ratio,
          angle_deg = angle_deg,
          area = as.numeric(st_area(sf_poly)),
          xmin = bbox["xmin"],
          xmax = bbox["xmax"],
          ymin = bbox["ymin"],
          ymax = bbox["ymax"],
          width = width,
          height = height
        )
      })
    })
  
  return(results)
}

###o. Output ellipse table ----
hdr_metrics <- extract_hdr_metrics(df_click)
write.csv(hdr_metrics, "Output_Shape_Stats.csv")



###o. Create final plot ----

hdr_25 <- hdr_metrics %>% filter(probability == 0.25)

make_ellipse <- function(cx, cy, a, b, angle_deg, n_points = 100) {
  theta <- seq(0, 2*pi, length.out = n_points)
  
  x <- a * cos(theta)
  y <- b * sin(theta)
  
  # rotate
  angle_rad <- angle_deg * pi / 180
  xr <- x * cos(angle_rad) - y * sin(angle_rad)
  yr <- x * sin(angle_rad) + y * cos(angle_rad)
  
  tibble(x = xr + cx, y = yr + cy)
}

ellipses_25 <- pmap_dfr(
  list(
    cx = hdr_25$centroid_x,
    cy = hdr_25$centroid_y,
    a = hdr_25$major_axis / 2,   # PCA uses full axis length
    b = hdr_25$minor_axis / 2,
    angle_deg = hdr_25$angle_deg
  ),
  make_ellipse
) %>%
  mutate(butterfly = rep(hdr_25$butterfly, each = 100))



ggplot(df_click, aes(x = abs(Left_Right), y = Back_Front)) +
  
  # Density background
  geom_density_2d_filled(alpha = 0.7, show.legend = FALSE) +   # legend optional
  
  geom_vline(xintercept = (164*1.5/2), alpha = 0.4, col="white") +
  geom_hline(yintercept = (40*1.5), alpha = 0.4, col="white") +
  geom_hline(yintercept = (-55*1.5), alpha = 0.4, col="white") +
  
  
  # 25% HDR ellipses
  geom_path(
    data = ellipses_25,
    aes(x = x, y = y, group = butterfly),
    size = 0.8, col = "white",linetype=2,
    show.legend = FALSE
  ) +
  
  
  # Centroids as crosses
  geom_point(
    data = hdr_25,
    aes(x = centroid_x, y = centroid_y),
    shape = 4, size = 2, stroke = 1, col = "blue",
    show.legend = FALSE
  ) +
  
  # Facets
  facet_grid(. ~ butterfly) +
  
  # Axis limits
  coord_cartesian(xlim = c(0, 250), ylim = c(-250, 150)) +
  
  # Viridis palette for density fill
  scale_fill_viridis_d(option = "magma", direction = 1) +  # "magma", "cividis" also available
  
  # Theme and labels
  theme_classic() +
  theme(
    panel.grid.major = element_line(color = "gray", alpha=0.3),
    #panel.grid.minor = element_line(color = "black", size = 0.4, alpha=0.6)
  ) +
  labs(
    x = "Perpendicular Distance Px",
    y = "Parallel Distance Px",
    fill = "Density",
    title = "Angular Densities"
  )



#....................................................................................................................................
#----EMD----
#....................................................................................................................................
#....................................................................................................................................

## [EMD] Parallel vector (y), Back_Front ----

# Simple Model only including parallel vector
mod1 <- lmer(
  scale(Back_Front)  ~  
    scale(Forwards_Confusion_mean_400to0ms) +
    scale(Sideways_Confusion_mean_400to0ms) +
    scale(EMD_Forward_mean_400to0ms) +
    (1 | displayRate)+
    (1 | PlayerID)+
    (1 | trialNumber)+
    (1 | pathNumber),
  data=subset(df_click))

summary(mod1)
anova(mod1)
qqPlot(residuals(mod1))
hist(residuals(mod1))  


## [EMD] Perpendicular Vector (x), perpendicular distance ----
#Model
mod1 <- lmer(
  scale(Perpendicular_Distance)  ~  
    scale(Forwards_Confusion_mean_400to0ms) +
    scale(Sideways_Confusion_mean_400to0ms) +
    scale(EMD_Forward_mean_400to0ms) +
    (1 | displayRate)+
    (1 | PlayerID)+
    (1 | trialNumber)+
    (1 | pathNumber),
  data=subset(df_click))

summary(mod1)
anova(mod1)
qqPlot(residuals(mod1))
hist(residuals(mod1))  



## [EMD] Hindwing or Forewing ----


df_hit$ForeVsHind = ifelse(df_hit$Hitbox=="Tail","Hindwing",df_hit$Hitbox)

df_forhind = subset(df_hit,ForeVsHind=="Forewing" | ForeVsHind=="Hindwing")
df_forhind$ForeVsHind = as.factor(df_forhind$ForeVsHind)

ggplot(df_forhind, aes(x = quantcut(Forwards_Confusion_mean_400to0ms,2), fill = ForeVsHind)) +
  geom_bar(position = "fill", alpha=0.5) +
  scale_y_continuous(labels = scales::percent) +
  theme_classic() +
  theme(
    text = element_text(size = 15),
    line = element_line(size = 0.6)
  )+
  labs(
    fill = "Forewing or Hindwing",
    y = "Proportion Forewing to Hindwing",
    x = "Butterfly"
  )

#Model
mod1 <- glmer(
  as.factor(ForeVsHind)  ~  
    scale(Forwards_Confusion_mean_400to0ms) +
    scale(Sideways_Confusion_mean_400to0ms) +
    scale(EMD_Forward_mean_400to0ms) +
    (1 | displayRate)+
    (1 | PlayerID)+
    (1 | trialNumber)+
    (1 | pathNumber),
  family = binomial(link = "logit"),
  data=subset(df_forhind))

summary(mod1)
anova(mod1)
qqPlot(residuals(mod1))
hist(residuals(mod1))  


#....................................................................................................................................
# X and Y vector Plots ----
#....................................................................................................................................
#....................................................................................................................................

# here x and y positions relative the butterfly have been combined

df_click$x_vector = abs(df_click$Left_Right)
df_click$y_vector = df_click$Back_Front

nrow(df_click)
df_click$EMD_Backward_mean_400to0ms
df_long <- df_click %>%
  dplyr::select(PlayerID, trialNumber, pathNumber,
           Forwards_Confusion_mean_400to0ms,
           Sideways_Confusion_mean_400to0ms,
           EMD_Forward_mean_400to0ms,
           EMD_Backward_mean_400to0ms,
           EMD_Left_mean_400to0ms,
           EMD_Right_mean_400to0ms,
           Left_Right_Bias_mean_400to0ms,
           displayRate,
           butterfly,
         x_vector, y_vector) %>%
  pivot_longer(
    cols = c(x_vector, y_vector),
    names_to = "axis",
    values_to = "vector_value"
  )

df_long$axis <- factor(df_long$axis)


## [Butterfly] ----



mod1 <- lmer(
  vector_value  ~  axis*butterfly  +
    (1 | displayRate)+
    (1 | PlayerID)+
    (1 | trialNumber)+
    (1 | pathNumber),
  data=subset(df_long))

summary(mod1)
anova(mod1)
qqPlot(residuals(mod1))
hist(residuals(mod1))  

emm_options(pbkrtest.limit = 6000)
emm_butterfly <- emmeans(mod1, ~ axis | butterfly)
pairs(emm_butterfly, adjust = "tukey")





df_long$combined = paste(df_long$axis,df_long$butterfly)

mod1 <- lmer(
  vector_value  ~  combined  +
    (1 | displayRate)+
    (1 | PlayerID)+
    (1 | trialNumber)+
    (1 | pathNumber),
  data=subset(df_long))

summary(mod1)
anova(mod1)
qqPlot(residuals(mod1))
hist(residuals(mod1))  

emm_options(pbkrtest.limit = 6000)
emm_butterfly <- emmeans(mod1, ~ combined)
pairs(emm_butterfly, adjust = "tukey")








mod1 <- lmer(
  Back_Front  ~  butterfly  +
    (1 | displayRate)+
    (1 | PlayerID)+
    (1 | trialNumber)+
    (1 | pathNumber),
  data=subset(df_click))

summary(mod1)
anova(mod1)
qqPlot(residuals(mod1))
hist(residuals(mod1))  

emm_options(pbkrtest.limit = 6000)
emm_butterfly <- emmeans(mod1, ~ butterfly)
pairs(emm_butterfly, adjust = "tukey")


## [EMD] ----

mod1 <- lmer(
  scale(vector_value)  ~  
    axis  +
    scale(Forwards_Confusion_mean_400to0ms) +
    scale(Sideways_Confusion_mean_400to0ms) +
    scale(EMD_Forward_mean_400to0ms) +
    axis:scale(Forwards_Confusion_mean_400to0ms) +
    axis:scale(Sideways_Confusion_mean_400to0ms) +
    axis:scale(EMD_Forward_mean_400to0ms) +
    (1 | displayRate)+
    (1 | PlayerID)+
    (1 | trialNumber)+
    (1 | pathNumber),
  data=subset(df_long))

summary(mod1)
anova(mod1)
qqPlot(residuals(mod1))
hist(residuals(mod1))  























#....................................................................................................................................
#----Triangle EMD----
#....................................................................................................................................
#....................................................................................................................................

emd$
ggplot(emd, aes(x = pathNumber, 
                     y = Forwards_Confusion)) +
  geom_boxplot()+
  theme_classic()


mean(
  emd$Forwards_Confusion[
      is.finite(emd$Forwards_Confusion)
  ],
  na.rm = TRUE
)

sd(
  emd$Forwards_Confusion[
    is.finite(emd$Forwards_Confusion)
  ],
  na.rm = TRUE
)


mean(
  simemd$sim_Forwards_Confusion[
    is.finite(simemd$sim_Forwards_Confusion)
  ],
  na.rm = TRUE
)

sd(
  simemd$sim_Forwards_Confusion[
    is.finite(simemd$sim_Forwards_Confusion)
  ],
  na.rm = TRUE
)






mean(
  emd$Sideways_Confusion[
    is.finite(emd$Sideways_Confusion)
  ],
  na.rm = TRUE
)

sd(
  emd$Sideways_Confusion[
    is.finite(emd$Sideways_Confusion)
  ],
  na.rm = TRUE
)


mean(
  simemd$sim_Sideways_Confusion[
    is.finite(simemd$sim_Sideways_Confusion)
  ],
  na.rm = TRUE
)

sd(
  simemd$sim_Sideways_Confusion[
    is.finite(simemd$sim_Sideways_Confusion)
  ],
  na.rm = TRUE
)



#....................................................................................................................................
# Angle Correction Test ----
#....................................................................................................................................
#....................................................................................................................................

df_click$x_offset_hitbox = with(df_click, butterflyX_actual - hitbox_x)
df_click$y_offset_hitbox = with(df_click, butterflyY_actual - hitbox_y)
df_click$offset_hitbox  = with(df_click,(x_offset_hitbox^2+y_offset_hitbox^2)^0.5)




df_click$x_miss = with(df_click, clickX_actual - butterflyX_actual)
df_click$y_miss = with(df_click, clickY_actual - butterflyY_actual)
df_click$clickDist_check = with(df_click, (x_miss^2+y_miss^2)^0.5)

df_click$clickDeg_raw = with(df_click,atan2(y_miss,x_miss)*180/pi)
df_click$clickDeg_raw_check = with(df_click,(clickDeg_raw + 180) %% 360 - 180)
df_click$clickDeg_check = with(df_click,clickDeg_raw+heading_deg)
df_click$clickDeg_check = with(df_click,(clickDeg_check + 180) %% 360 - 180)

df_click$Back_Front_check = with(df_click, cos(clickDeg_check/180*pi)*clickDist_check)
df_click$Left_Right_check = with(df_click, sin(clickDeg_check/180*pi)*clickDist_check)


df_click$clickLeftRight_check = with(df_click,ifelse(clickDeg_check<0,"Right","Left"))
df_click$clickFrontBack_check = with(df_click,ifelse(abs(clickDeg_check)>90,"Back","Front"))

df_click$x_miss_hitbox = with(df_click, clickX_actual - (hitbox_x))
df_click$y_miss_hitbox = with(df_click, clickY_actual - (hitbox_y))
df_click$clickDist_hitbox = with(df_click, (x_miss_hitbox^2 + y_miss_hitbox^2)^0.5)




df_click$clickDeg_raw_hitbox = with(df_click,atan2(y_miss_hitbox,x_miss_hitbox)*180/pi)
df_click$clickDeg_raw_check_hitbox = with(df_click,(clickDeg_raw_hitbox + 180) %% 360 - 180)
df_click$clickDeg_check_hitbox = with(df_click,clickDeg_raw_hitbox+heading_deg)
df_click$clickDeg_check_hitbox = with(df_click,(clickDeg_check_hitbox + 180) %% 360 - 180)


df_click$Back_Front_hitbox = with(df_click, cos(clickDeg_check_hitbox/180*pi)*clickDist_hitbox)
df_click$Left_Right_hitbox = with(df_click, sin(clickDeg_check_hitbox/180*pi)*clickDist_hitbox)


#Offset PLOT
ggplot(
  subset(df_click,hitbox_x>0),
  aes(x = abs(Left_Right_check), y = Back_Front_check)
) +
  geom_vline(xintercept = 0, alpha = 0.4) +
  geom_hline(yintercept = 0, alpha = 0.4) +
  geom_density_2d_filled(
    alpha = 0.9
  ) +
  facet_grid(quantcut(Left_Right_Bias,2)~ butterfly) +
  theme_classic() +
  theme(
    #panel.grid.major = element_line(color = "black", size = 0.4, alpha=0.6),
    #panel.grid.minor = element_line(color = "black", size = 0.4, alpha=0.6)
  ) +
  labs(
    x = "Perpendicular Distance Px Hitbox",
    y = "Parallel Distance Px Hitbox",
    fill = "Density"
  )








#REGULAR PLOT   
ggplot(
  subset(df_click,hitbox_x>0),
  aes(x = (Left_Right_check), y = Back_Front_check)
) +
  geom_density_2d_filled(
    alpha = 0.9
  ) +
  geom_vline(xintercept = 0, alpha = 0.4) +
  geom_hline(yintercept = 0, alpha = 0.4) +
  geom_vline(xintercept = (164*1.5/2), alpha = 0.4) +
  geom_hline(yintercept = (40*1.5), alpha = 0.4) +
  geom_hline(yintercept = (-55*1.5), alpha = 0.4) +
  geom_vline(xintercept = (-164*1.5/2), alpha = 0.4) +
  facet_grid(.~ butterfly) +
  theme_classic() +
  theme(
    #panel.grid.major = element_line(color = "black", size = 0.4, alpha=0.6),
    #panel.grid.minor = element_line(color = "black", size = 0.4, alpha=0.6)
  ) +
  labs(
    x = "Perpendicular Distance Px",
    y = "Parallel Distance",
    fill = "Density",
    title = "Angular Densities"
  )


#HITBOX PLOT
ggplot(
  subset(df_click,hitbox_x>0),
  aes(x = (Left_Right_hitbox), y = Back_Front_hitbox)
) +
  geom_density_2d_filled(
    alpha = 0.9
  ) +
  geom_vline(xintercept = 0, alpha = 0.4) +
  geom_hline(yintercept = 0, alpha = 0.4) +
  geom_vline(xintercept = (164*1.5/2), alpha = 0.4) +
  geom_hline(yintercept = (40*1.5), alpha = 0.4) +
  geom_hline(yintercept = (-55*1.5), alpha = 0.4) +
  geom_vline(xintercept = (-164*1.5/2), alpha = 0.4) +
  facet_grid(.~ butterfly) +
  theme_classic() +
  theme(
    #panel.grid.major = element_line(color = "black", size = 0.4, alpha=0.6),
    #panel.grid.minor = element_line(color = "black", size = 0.4, alpha=0.6)
  ) +
  labs(
    x = "Perpendicular Distance Px Hitbox",
    y = "Parallel Distance Px Hitbox",
    fill = "Density"
  )




# REGULAR PLOT
ggplot(
  subset(df_click,hitbox_x>0),
  aes(x = (Left_Right_check), y = Back_Front_check)
) +
  geom_density_2d_filled(
    alpha = 0.9
  ) +
  geom_vline(xintercept = 0, alpha = 0.4) +
  geom_hline(yintercept = 0, alpha = 0.4) +
  geom_vline(xintercept = (164*1.5/2), alpha = 0.4) +
  geom_hline(yintercept = (40*1.5), alpha = 0.4) +
  geom_hline(yintercept = (-55*1.5), alpha = 0.4) +
  geom_vline(xintercept = (-164*1.5/2), alpha = 0.4) +
  facet_grid(.~ butterfly) +
  theme_classic() +
  theme(
    #panel.grid.major = element_line(color = "black", size = 0.4, alpha=0.6),
    #panel.grid.minor = element_line(color = "black", size = 0.4, alpha=0.6)
  ) +
  labs(
    x = "Perpendicular Distance Px",
    y = "Parallel Distance Px",
    fill = "Density"
  )




ggplot(
  subset(df_click,hitbox_x>0 & clickHit==1),
  aes(x = (Left_Right_check), y = Back_Front_check)
) +
  geom_point(aes(col=Hitbox))+
  facet_grid(.~ butterfly) +
  theme_classic() +
  theme(
    #panel.grid.major = element_line(color = "black", size = 0.4, alpha=0.6),
    #panel.grid.minor = element_line(color = "black", size = 0.4, alpha=0.6)
  ) +
  labs(
    x = "Perpendicular Distance Px",
    y = "Parallel Distance",
    fill = "Density",
    title = "Angular Densities"
  )



mod1 <- lmer(
  Back_Front_check  ~  butterfly+
    (1 | displayRate)+
    (1 | PlayerID)+
    (1 | trialNumber)+
    (1 | pathNumber),
  data=subset(df_click,hitbox_x>0))

summary(mod1)
anova(mod1)
qqPlot(residuals(mod1))
hist(residuals(mod1))  

emm_butterfly <- emmeans(mod1, ~ butterfly)
pairs(emm_butterfly, adjust = "tukey")


df$

mod1 <- lmer(
  Back_Front ~  Left_Right_Bias+
    (1 | butterfly) +
    (1 | displayRate) +
    (1 | PlayerID) +
    (1 | trialNumber) +
    (1 | pathNumber),
  data=subset(df_click,hitbox_x>0))

summary(mod1)
anova(mod1)
qqPlot(residuals(mod1))
hist(residuals(mod1))  

emm_butterfly <- emmeans(mod1, ~ butterfly)
pairs(emm_butterfly, adjust = "tukey")







unique(paths$butterfly)

paths$x_c = paths$x
paths$y_c = paths$y




pathN = 4
ggplot(subset(df_click,pathNumber==pathN & butterfly=="B.c"), aes(x = clickX_actual/(xMax/2)-1, y = -(clickY_actual/(yMax/2)-1))) +
  geom_point(aes(col=paste(clickFrontBack,clickLeftRight)))+
  geom_point(data = 
               subset(paths,pathNumber==pathN & 
                        butterfly=="Brintesia_circe__Male" & floor(frame/10)==frame/10), 
             aes(x=x_c+(cos(heading_deg/180*pi)*0.01),y=y_c+(sin(heading_deg/180*pi)*0.01)), 
             col="red",size=1) +
  geom_point(data = 
               subset(paths,pathNumber==pathN & 
                        butterfly=="Brintesia_circe__Male" & floor(frame/10)==frame/10), 
             aes(x=x_c-(cos(heading_deg/180*pi)*0.01),y=y_c-(sin(heading_deg/180*pi)*0.01)), 
             col="steelblue",size=2) +
  geom_point(data = 
               subset(paths,pathNumber==pathN & 
               butterfly=="Brintesia_circe__Male" & floor(frame/10)==frame/10), 
               aes(x=x_c,y=y_c), 
               col="steelblue") +
  theme_classic()




ggplot(df_click, aes(x = clickDeg_raw_check, fill=paste(clickFrontBack,clickLeftRight))) +
  geom_histogram(
    bins = 30,
    color = "white",
    alpha = 0.85
  ) +
  theme_classic(base_size = 14) 




ggplot(df_click, aes(x = clickDeg_check, fill=paste(clickFrontBack,clickLeftRight))) +
  geom_histogram(
    bins = 30,
    color = "white",
    alpha = 0.85
  ) +
  theme_classic(base_size = 14) 

ggplot(df_click, aes(x = clickDeg_check, fill=paste(clickFrontBack_check,clickLeftRight_check))) +
  geom_histogram(
    bins = 30,
    color = "white",
    alpha = 0.85
  ) +
  theme_classic(base_size = 14) 



df$


ggplot(df_click, aes(x = butterfly, 
                     y = clickDeg, 
                     fill = quantcut(Left_Right_Bias_mean_400to0ms,2))) +
  geom_boxplot()+
  theme_classic()


ggplot(df_click, aes(x = butterfly, 
                     y = Back_Front, 
                     fill = quantcut(abs(Left_Right_Bias_mean_400to0ms),2))) +
  geom_boxplot()+
  theme_classic()








max(df_click$x)
ggplot(df_click, aes(x = butterflyX_actual, y = butterflyX)) +
  geom_point()+
  geom_point(aes(y=x*(1920/2)+((1920)/2)),col="red")+
  geom_point(aes(y= butterflyX_actual),col="blue")+
  theme_classic()
                                
ggplot(df_click, aes(x = clickDist, y = clickDist_check)) +
  geom_smooth (aes(),method=glm,formula=y~poly(x,1),alpha=0.25,size=1)+
  geom_point()+
  theme_classic()
                                
ggplot(df_click, aes(x = clickDist, y = clickDist_hitbox)) +
  geom_smooth (aes(),method=glm,formula=y~poly(x,1),alpha=0.25,size=1)+
  geom_point()+
  theme_classic()


ggplot(df_click, aes(x = paste(clickFrontBack,clickLeftRight), y = clickDeg, fill = paste(clickFrontBack,clickLeftRight))) +
  geom_boxplot()+
  theme_classic()

ggplot(df_click, aes(x = paste(clickFrontBack,clickLeftRight), y = clickDeg_raw, fill = paste(clickFrontBack,clickLeftRight))) +
  geom_boxplot()+
  theme_classic()
butterflyDeg_actual


img_pos <- make_image_positions(
  data      = df_click,
  x_var     = butterfly,
  y_var     = clickDist,
  image_var = imageDir
)
















ggplot(subset(df_click,hitbox_x>0), aes(x = butterfly, y = clickDist_hitbox, fill = butterfly)) +
  geom_violin(alpha=0.5) +
  geom_boxplot(width = 0.15) +
  scale_fill_manual(values=Butterfly_Palette)+
  geom_image(
    data = img_pos,
    aes(x = butterfly, y = y*1.05, image = image),
    inherit.aes = FALSE,
    size = 0.08
  )+theme_classic()

mod1 <- lmer(
  clickDist_hitbox  ~  butterfly+
    (1 | displayRate)+
    (1 | PlayerID)+
    (1 | trialNumber)+
    (1 | pathNumber),
  data=subset(df_click,hitbox_x>0))

summary(mod1)
anova(mod1)
qqPlot(residuals(mod1))
hist(residuals(mod1))  

emm_butterfly <- emmeans(mod1, ~ butterfly)
pairs(emm_butterfly, adjust = "tukey")


