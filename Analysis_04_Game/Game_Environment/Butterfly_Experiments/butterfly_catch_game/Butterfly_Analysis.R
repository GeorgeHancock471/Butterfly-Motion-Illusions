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
library(ggimage)
library(slider)
library(car)
library(emmeans)

#Set working directory to source
#...................................
setwd(dirname(rstudioapi::getSourceEditorContext()$path))


#Screen Features
#..................................
xMax = 1920
yMax = 1080


#Import and adjust data
#...................................


# Get a list of all CSV files in the Results folder
files <- list.files(
  path = "Results",
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


#Paths, create direction metric.

paths$x_direction = sin(paths$heading_deg/180*pi)
paths$y_direction = cos(paths$heading_deg/180*pi)






# Rescale hitboxes, as images are 66.6% the size of the screen
hitbox <- hitbox %>%
  mutate(
    across(
      .cols = where(is.numeric) & !c(pathNumber, frame),
      ~ . * 1.5
    )
  )

#Add Confusion Measures
emd$Forwards_Confusion = (emd$EMD_Backward - emd$EMD_Forward) / (emd$EMD_Backward + emd$EMD_Forward)
emd$Sideways_Confusion = ((emd$EMD_Left/2+emd$EMD_Right/2) - emd$EMD_Forward) / ((emd$EMD_Left/2+emd$EMD_Right/2)+ emd$EMD_Forward)
emd$Left_Right_Bias = (emd$EMD_Left - emd$EMD_Right) / (emd$EMD_Left + emd$EMD_Right)


emd <- emd %>%
  group_by(butterfly) %>%
  mutate(
    mean_Forwards_Confusion = mean(Forwards_Confusion, na.rm = TRUE),
    mean_Sideways_Confusion = mean(Sideways_Confusion, na.rm = TRUE),
    mean_Left_Right_Bias    = mean(Left_Right_Bias, na.rm = TRUE)
  ) %>%
  ungroup()




fps <- 240
window_ms <- 300
window_frames <- ceiling(fps * window_ms / 1000)  # 72 frames


emd <- emd %>%
  arrange(butterfly, pathNumber, frame) %>%
  group_by(butterfly, pathNumber) %>%
  mutate(
    
    forwards_mean_300ms = slide_dbl(
      EMD_Forward,
      .before = window_frames,
      .after = -1,
      .f = function(x) mean(x, na.rm = TRUE)
    ),
    
    forwards_sd_300ms = slide_dbl(
      EMD_Forward,
      .before = window_frames,
      .after = -1,
      .f = function(x) sd(x, na.rm = TRUE)
    ),
    
    backwards_mean_300ms = slide_dbl(
      EMD_Backward,
      .before = window_frames,
      .after = -1,
      .f = function(x) mean(x, na.rm = TRUE)
    ),
    
    backwards_sd_300ms = slide_dbl(
      EMD_Backward,
      .before = window_frames,
      .after = -1,
      .f = function(x) sd(x, na.rm = TRUE)
    ),
    
    backwards_mean_300ms = slide_dbl(
      EMD_Backward,
      .before = window_frames,
      .after = -1,
      .f = function(x) mean(x, na.rm = TRUE)
    ),
    
    backwards_sd_300ms = slide_dbl(
      EMD_Backward,
      .before = window_frames,
      .after = -1,
      .f = function(x) sd(x, na.rm = TRUE)
    ),
    
     left_mean_300ms = slide_dbl(
      EMD_Left,
      .before = window_frames,
      .after = -1,
      .f = function(x) mean(x, na.rm = TRUE)
    ),
    
    left_sd_300ms = slide_dbl(
      EMD_Left,
      .before = window_frames,
      .after = -1,
      .f = function(x) sd(x, na.rm = TRUE)
    ),
    
    
    right_mean_300ms = slide_dbl(
      EMD_Right,
      .before = window_frames,
      .after = -1,
      .f = function(x) mean(x, na.rm = TRUE)
    ),
    
    right_sd_300ms = slide_dbl(
      EMD_Right,
      .before = window_frames,
      .after = -1,
      .f = function(x) sd(x, na.rm = TRUE)
    ),
    
    forwards_con_mean_300ms = slide_dbl(
      Forwards_Confusion,
      .before = window_frames,
      .after = -1,
      .f = function(x) mean(x, na.rm = TRUE)
    ),
    
    forwards_con_sd_300ms = slide_dbl(
      Forwards_Confusion,
      .before = window_frames,
      .after = -1,
      .f = function(x) sd(x, na.rm = TRUE)
    ),
    
    sideways_con_mean_300ms = slide_dbl(
      Sideways_Confusion,
      .before = window_frames,
      .after = -1,
      .f = function(x) mean(x, na.rm = TRUE)
    ),
    
    sideways_con_sd_300ms = slide_dbl(
      Sideways_Confusion,
      .before = window_frames,
      .after = -1,
      .f = function(x) sd(x, na.rm = TRUE)
    ),
    
    lr_bias_mean_300ms = slide_dbl(
      Left_Right_Bias,
      .before = window_frames,
      .after = -1,
      .f = function(x) mean(x, na.rm = TRUE)
    ),
    
    lr_bias_sd_300ms = slide_dbl(
      Left_Right_Bias,
      .before = window_frames,
      .after = -1,
      .f = function(x) sd(x, na.rm = TRUE)
    )
    
  ) %>%
  ungroup()









head(paths)

head(df)


df$imageDir <- paste(dirname(rstudioapi::getSourceEditorContext()$path), "/figure_photos2/", df$butterfly, ".png",sep="")

df$Hitbox = "None"
df$uniquePlay = paste(df$PlayerID,(df$Phase*100+df$trialNumber))


df$Hitbox = ifelse(df$clickRGB_G>=245,"Hindwing",df$Hitbox)
df$Hitbox = ifelse(df$clickRGB_G>=80 & df$clickRGB_G<245,"Forewing",df$Hitbox)
df$Hitbox = ifelse(df$clickRGB_G>=30 & df$clickRGB_G<200  & df$butterfly=="Papilio_alexanor__Female", "Tail",df$Hitbox)
df$Hitbox = ifelse(df$clickRGB_G<30 & df$clickRGB_B>100, "Body",df$Hitbox )
df$frame = df$clickFrame

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

df$frame = ifelse(df$frame ==0, 1, df$frame)



nrow(df)
df2 <- merge(
  df,
  paths,
  by = c("butterfly", "pathNumber", "frame"),
  all.x = TRUE
)

nrow(df2)

df2 = merge(df2,hitbox)
df2 = merge(df2,emd)

nrow(df2)
df=df2



df$dist_300ms = (df$x_diff_300ms^2 + df$y_diff_300ms^2)^0.5
df$Perpendicular_Distance = df$clickDist*abs(sin(df$clickDeg/180*pi))
df$Parallel_Distance = df$clickDist*abs(cos(df$clickDeg/180*pi))
df$Back_Front= df$clickDist*(cos(df$clickDeg/180*pi))




#Split into use data frames
df_nonTut = subset(df, Tutorial == 0)
df_hit = subset(df,clickHit==1 & Tutorial == 0)
df_click = subset(df,click==1 & Tutorial == 0)



nrow(subset(df_nonTut, butterfly == Buttefly_IDs[1] & pathNumber == 9))
nrow(subset(df_nonTut, butterfly == Buttefly_IDs[2] & pathNumber == 9))
nrow(subset(df_nonTut, butterfly == Buttefly_IDs[3] & pathNumber == 9))
nrow(subset(df_nonTut, butterfly == Buttefly_IDs[4] & pathNumber == 9))
nrow(subset(df_nonTut, butterfly == Buttefly_IDs[5] & pathNumber == 9))




nrow(df_nonTut)/30


#Custom Functions
#...................................

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


unique(df$butterfly)
Butterfly_Palette <- c("#938c87", "#e7cf8d" , "#dd9386",  "#fcfaab","#a9afa1")
Buttefly_IDs = unique(df$butterfly)



#....................................................................................................................................
#----Player Plots----
#....................................................................................................................................
#....................................................................................................................................



df_player_means <- df_click %>%
  group_by(PlayerID) %>%
  summarise(
    mean_clickHit  = mean(clickHit, na.rm = TRUE),
    mean_clickDist = mean(clickDist, na.rm = TRUE)
  )


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




ggplot(df_player_means, aes(x = mean_clickHit*100)) +
  geom_histogram(
    bins = 12,
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


mean(df_player_means$mean_clickHit*100)



df_player_hit <- df_nonTut %>%
  group_by(PlayerID) %>%
  summarise(
    prop_hit = mean(clickHit, na.rm = TRUE),
    .groups = "drop"
  )


df_player_hit <- df_player_hit %>%
  mutate(PlayerID = reorder(as.factor(PlayerID), prop_hit))


ggplot(df_player_hit, aes(x = PlayerID, y = prop_hit)) +
  geom_col(
    fill = "#4C72B0",
    alpha = 0.85,
    width = 0.8
  ) +
  scale_y_continuous(labels = scales::percent, limits = c(0,1)) +
  theme_classic() +
  theme(
    text = element_text(size = 15),
    axis.text.x = element_text(angle = 90, vjust = 0.5),
    line = element_line(size = 0.6)
  ) +
  labs(
    y = "Percent Hit",
    x = "Player (ordered by mean hit rate)"
  )




#....................................................................................................................................
#----Pathing Plots----
#....................................................................................................................................
#....................................................................................................................................


##(Path) Check Locations ----
#......................
df$pathNumber

pathN = 10

#Check Hit Coordinates
ggplot(subset(df_click,pathNumber==pathN), aes(x = frame, y = clickY_actual)) +
  geom_point(data = subset(paths,pathNumber==pathN), aes(x=frame,y=-y*yMax/2+yMax/2)) +
  geom_point(aes(x=frame,y=butterflyY_actual),colour="purple", size =3) +
  geom_point(aes(x=frame,y=clickY_actual, colour=as.factor(clickHit)),shape=13, size =3) +
  coord_cartesian(xlim = c(0, 350), ylim = c(0, 1080)) +
  theme_classic()


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





#Check Butterfly Coordinates
ggplot(subset(df_click,pathNumber==pathN), aes(x = clickX_actual, y = clickY_actual)) +
  geom_point(data = subset(paths,pathNumber==pathN), aes(x=x*xMax/2+xMax/2,y=-y*yMax/2+yMax/2)) +
  geom_point(aes(x=butterflyX_actual,y=butterflyY_actual, colour=as.factor(paste(flipY,flipX))), size =3) +
  theme_classic()



#Check Hitbox Coordinates
ggplot(subset(df_click,pathNumber==pathN), aes(x = clickX_actual, y = clickY_actual)) +
  geom_point(data = subset(hitbox,pathNumber==pathN), aes(x=hitbox_x,y=hitbox_y)) +
  geom_point(aes(x=butterflyX_actual,y=butterflyY_actual),colour="purple", size =3) +
  geom_point(aes(x=clickX_actual,y=clickY_actual, colour=as.factor(clickHit)),shape=13, size =3) +
  theme_classic()



##(Path) Check Directions ----
#......................

pathN = 1
ggplot(subset(df_click,pathNumber==pathN), aes(x = clickX_actual, y = clickY_actual)) +
  geom_point(data = subset(paths,pathNumber==pathN), aes(x=frame,y=y)) +
  geom_point(data = subset(paths,pathNumber==pathN), aes(x=frame,y=(heading_deg-mean_heading_path)/360), col="steelblue") +
  geom_point(data = subset(paths,pathNumber==pathN), aes(x=frame,y=-y_direction), col="red") +
  theme_classic()

ggplot(subset(df_click,pathNumber==pathN), aes(x = clickX_actual, y = clickY_actual)) +
  geom_point(data = subset(paths,pathNumber==pathN), aes(x=frame,y=y)) +
  geom_point(data = subset(paths,pathNumber==pathN), aes(x=frame,y=(heading_deg)/360), col="steelblue") +
  geom_point(data = subset(paths,pathNumber==pathN), aes(x=frame,y=-y_direction), col="red") +
  theme_classic()


paths$




ggplot(subset(df_click,pathNumber==pathN), aes(x = clickX_actual, y = clickY_actual)) +
  geom_point(data = subset(paths,pathNumber==pathN), aes(x=frame,y=x)) +
  geom_point(data = subset(paths,pathNumber==pathN), aes(x=frame,y=-heading_deg/360), col="steelblue") +
  geom_point(data = subset(paths,pathNumber==pathN), aes(x=frame,y=-x_direction), col="red") +
  theme_classic()

ggplot(subset(df_click,pathNumber==pathN), aes(x = clickX_actual, y = clickY_actual)) +
  geom_point(data = subset(paths,pathNumber==pathN), aes(x=frame,y=y)) +
  geom_line(data = subset(emd,pathNumber==pathN), aes(x=frame,y=-Left_Right_Bias, col=butterfly)) +
  theme_classic()

ggplot(subset(df_click,pathNumber==pathN), aes(x = clickX_actual, y = clickY_actual)) +
  geom_point(data = subset(paths,pathNumber==pathN), aes(x=frame,y=y)) +
  geom_line(data = subset(emd,pathNumber== pathN & butterfly == "Pyrgus_sidae__Male"), 
            aes(x=frame,y=EMD_Forward*10), col="green", linewidth =1) +
  geom_line(data = subset(emd,pathNumber== pathN & butterfly == "Pyrgus_sidae__Male"), 
            aes(x=frame,y=-EMD_Backward*10), col="purple", linewidth =1) +
  geom_line(data = subset(emd,pathNumber== pathN & butterfly == "Pyrgus_sidae__Male"), 
            aes(x=frame,y=EMD_Left*10), col="red", linewidth =1) +
  geom_line(data = subset(emd,pathNumber== pathN & butterfly == "Pyrgus_sidae__Male"), 
            aes(x=frame,y=-EMD_Right*10), col="blue", linewidth =1) +
  theme_classic()



ggplot(subset(df_click,pathNumber==pathN), aes(x = clickX_actual, y = clickY_actual)) +
  geom_point(data = subset(paths,pathNumber==pathN), aes(x=frame,y=y)) +
  geom_line(data = subset(emd,pathNumber== pathN & butterfly == "Pyrgus_sidae__Male"), 
            aes(x=frame,y=EMD_Forward*10), col="green", linewidth =1) +
  geom_line(data = subset(emd,pathNumber== pathN & butterfly == "Pyrgus_sidae__Male"), 
            aes(x=frame,y=EMD_Backward*10), col="purple", linewidth =1) +
  theme_classic()


ggplot(subset(df_click,pathNumber==pathN), aes(x = clickX_actual, y = clickY_actual)) +
  geom_point(data = subset(paths,pathNumber==pathN), aes(x=frame,y=y)) +
  geom_line(data = subset(emd,pathNumber== pathN & butterfly == "Pyrgus_sidae__Male"), 
            aes(x=frame,y=EMD_Left*10), col="red", linewidth =1) +
  geom_line(data = subset(emd,pathNumber== pathN & butterfly == "Pyrgus_sidae__Male"), 
            aes(x=frame,y=EMD_Right*10), col="blue", linewidth =1) +
  theme_classic()


#....................................................................................................................................
#----EMD----
#....................................................................................................................................
#....................................................................................................................................

##(EMD) Check Butterflies ----
#......................

img_pos <- make_image_positions(
  data      = df,
  x_var     = butterfly,
  y_var     = Forwards_Confusion,
  image_var = imageDir
)
#Forwards Confusion
ggplot(emd, aes(x = butterfly, y = Forwards_Confusion, fill = butterfly)) +
  geom_violin(alpha=0.5) +
  geom_boxplot(width = 0.15) +
  scale_fill_manual(values=Butterfly_Palette)+
  geom_image(
    data = img_pos,
    aes(x = butterfly, y = -1, image = image),
    inherit.aes = FALSE,
    size = 0.08
  )+theme_classic()+
  labs(
    fill = "Butterfly",
    y = "Forwards Confusion",
    x = "Butterfly"
  )

#Sideways Confusion
ggplot(emd, aes(x = butterfly, y = Sideways_Confusion, fill = butterfly)) +
  geom_violin(alpha=0.5) +
  geom_boxplot(width = 0.15) +
  scale_fill_manual(values=Butterfly_Palette)+
  geom_image(
    data = img_pos,
    aes(x = butterfly, y = -1, image = image),
    inherit.aes = FALSE,
    size = 0.08
  )+theme_classic()+
  labs(
    fill = "Butterfly",
    y = "Sideways Confusion",
    x = "Butterfly"
  )

#Forward Energy
ggplot(emd, aes(x = butterfly, y = EMD_Forward, fill = butterfly)) +
  geom_violin(alpha=0.5) +
  geom_boxplot(width = 0.15) +
  scale_fill_manual(values=Butterfly_Palette)+
  geom_image(
    data = img_pos,
    aes(x = butterfly, y = -0.01, image = image),
    inherit.aes = FALSE,
    size = 0.08
  )+theme_classic()+
  labs(
    fill = "Butterfly",
    y = "Forwards Energy",
    x = "Butterfly"
  )




#Side Bias
ggplot(emd, aes(x = butterfly, y = abs(EMD_Left-EMD_Right), fill = butterfly)) +
  geom_violin(alpha=0.5) +
  geom_boxplot(width = 0.15) +
  scale_fill_manual(values=Butterfly_Palette)+
  geom_image(
    data = img_pos,
    aes(x = butterfly, y = -0.01, image = image),
    inherit.aes = FALSE,
    size = 0.08
  )+theme_classic()+
  labs(
    fill = "Butterfly",
    x = "Butterfly"
  )



#Side Bias
ggplot(df_click, aes(x = butterfly, y = abs(EMD_Left-EMD_Right)/EMD_Backward, fill = butterfly)) +
  geom_violin(alpha=0.5) +
  geom_boxplot(width = 0.15) +
  scale_fill_manual(values=Butterfly_Palette)+
  geom_image(
    data = img_pos,
    aes(x = butterfly, y = -0.01, image = image),
    inherit.aes = FALSE,
    size = 0.08
  )+theme_classic()+
  labs(
    fill = "Butterfly",
    x = "Butterfly"
  )


ggplot(df_click, aes(x = butterfly, y =  abs(lr_bias_mean_300ms), fill = butterfly)) +
  geom_violin(alpha=0.5) +
  geom_boxplot(width = 0.15) +
  scale_fill_manual(values=Butterfly_Palette)+
  geom_image(
    data = img_pos,
    aes(x = butterfly, y = -0.01, image = image),
    inherit.aes = FALSE,
    size = 0.08
  )+theme_classic()+
  labs(
    fill = "Butterfly",
    x = "Butterfly"
  )




ggplot(df_click, aes(x = log(forwards_mean_300ms), y = Back_Front)) +
  geom_smooth (aes(),method=glm,formula=y~poly(x,1),alpha=0.25,size=1)+
  geom_point()+
  scale_colour_manual(values=Butterfly_Palette)+
  theme_classic()



ggplot(df_click, aes(x = abs(lr_bias_mean_300ms), y = clickHit)) +
  geom_smooth (aes(),method=glm,formula=y~poly(x,1),alpha=0.25,size=1)+
  geom_point()+
  scale_colour_manual(values=Butterfly_Palette)+
  theme_classic()

ggplot(df_click, aes(x = abs(lr_bias_mean_300ms), y = clickDist)) +
  geom_smooth (aes(),method=glm,formula=y~poly(x,1),alpha=0.25,size=1)+
  geom_point()+
  scale_colour_manual(values=Butterfly_Palette)+
  theme_classic()


ggplot(df_click, aes(x = Forwards_Confusion, y = clickHit, col=butterfly)) +
  geom_smooth (aes(),method=glm,formula=y~poly(x,1),alpha=0.25,size=1)+
  geom_point()+
  scale_colour_manual(values=Butterfly_Palette)+
  theme_classic()


pathN=1
ggplot(subset(df_click,pathNumber==pathN), aes(x = clickX_actual, y = clickY_actual)) +
  geom_point(data = subset(paths,pathNumber==pathN), aes(x=frame,y=y)) +
  geom_line(data = subset(emd,pathNumber== pathN & butterfly == Buttefly_IDs[1]), 
            aes(x=frame,y=EMD_Right*10 - EMD_Left*10), col="red", linewidth =1) +
  theme_classic()








ggplot(df_click, aes(x = forwards_mean_300ms, y = clickHit)) +
  geom_smooth (aes(),method=glm,formula=y~poly(x,1),alpha=0.25,size=1)+
  geom_point()+
  scale_colour_manual(values=Butterfly_Palette)+
  theme_classic()





ggplot(df_click, aes(x = forwards_mean_300ms, y = clickHit)) +
  geom_smooth (aes(),method=glm,formula=y~poly(x,1),alpha=0.25,size=1)+
  geom_point()+
  scale_colour_manual(values=Butterfly_Palette)+
  theme_classic()

ggplot(df_click, aes(x = forwards_sd_300ms, y = clickHit)) +
  geom_smooth (aes(),method=glm,formula=y~poly(x,1),alpha=0.25,size=1)+
  geom_point()+
  scale_colour_manual(values=Butterfly_Palette)+
  theme_classic()



ggplot(df_click, aes(x = lr_bias_mean_300ms, y = clickHit)) +
  geom_smooth (aes(),method=glm,formula=y~poly(x,1),alpha=0.25,size=1)+
  geom_point()+
  scale_colour_manual(values=Butterfly_Palette)+
  theme_classic()



ggplot(df_click, aes(x = lr_bias_sd_300ms, y = clickHit)) +
  geom_smooth (aes(),method=glm,formula=y~poly(x,1),alpha=0.25,size=1)+
  geom_point()+
  scale_colour_manual(values=Butterfly_Palette)+
  theme_classic()








ggplot(df, aes(x = trialNumber, y = clickHit)) +
  geom_point(alpha=0.15)+
  geom_smooth (aes(),method=glm,formula=y~poly(x,1),alpha=0.25,size=1)+
  facet_grid(~as.factor(Phase))+ 
  scale_colour_manual(values=Butterfly_Palette)+
  theme_classic()



ggplot(df, aes(x = trialNumber, y = clickDist)) +
  geom_point(alpha=0.15)+
  geom_smooth (aes(),method=glm,formula=y~poly(x,1),alpha=0.25,size=1)+
  facet_grid(~as.factor(Phase))+ 
  scale_colour_manual(values=Butterfly_Palette)+
  theme_classic()



ggplot(df, aes(x = trialNumber, y = clickDist)) +
  geom_smooth (aes(),method=glm,formula=y~poly(x,1),alpha=0.25,size=1)+
  geom_point()+
  facet_grid(~as.factor(Phase))+ 
  scale_colour_manual(values=Butterfly_Palette)+
  theme_classic()


ggplot(df_click, aes(x = pathNumber, y = clickY-butterflyY, fill = as.factor(pathNumber))) +
  geom_violin(alpha=0.5) +
  geom_boxplot(width = 0.15) +
  geom_hline(yintercept = 0) + 
  theme_classic()






ggplot(df_click, aes(x = as.factor(PlayerID), y = clickDist, fill = as.factor(PlayerID))) +
  geom_violin(alpha=0.5) +
  geom_boxplot(width = 0.15) +
  theme_classic()



ggplot(df_nonTut, aes(x = pathNumber, fill = as.factor(clickHit))) +
  geom_bar(position = "fill", alpha=0.5) +
  scale_y_continuous(labels = scales::percent) +
  theme_classic() +
  theme(
    text = element_text(size = 15),
    line = element_line(size = 0.6)
  )

ggplot(df_nonTut, aes(x = pathNumber, y = clickHit, fill = as.factor(pathNumber))) +
  geom_violin(alpha=0.5) +
  geom_boxplot(width = 0.15) +
  theme_classic()


ggplot(df_click, aes(x = clickX, y = clickY, col = as.factor(paste(flipX, flipY)))) +
  geom_point() +
  coord_cartesian(xlim = c(0, 1920), ylim = c(0, 1080)) +
  theme_classic()


ggplot(df_click, aes(x = butterflyX, y = butterflyY, col = as.factor(paste(flipX, flipY)))) +
  geom_point() +
  coord_cartesian(xlim = c(0, 1920), ylim = c(0, 1080)) +
  theme_classic()





#....................................................................................................................................
#----Main Plots----
#....................................................................................................................................
#....................................................................................................................................



#Click Time
#......................

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





#Click Distance
#......................

img_pos <-make_image_positions(
  data      = df_click,
  x_var     = butterfly,
  y_var     = clickDist,
  image_var = imageDir
)

ggplot(df_click, aes(x = butterfly, y = clickDist, fill = butterfly)) +
  geom_violin(alpha=0.5) +
  geom_boxplot(width = 0.15) +
  scale_fill_manual(values=Butterfly_Palette)+
  geom_image(
    data = img_pos,
    aes(x = butterfly, y = y*1.15, image = image),
    inherit.aes = FALSE,
    size = 0.08
  )+theme_classic()+
  labs(
    fill = "Butterfly",
    y = "Click Distance (px)",
    x = "Butterfly"
  )




df_click$hitbox_area

#Hitbox_Area
#......................

img_pos <-make_image_positions(
  data      = df_click,
  x_var     = butterfly,
  y_var     = clickDist,
  image_var = imageDir
)

ggplot(df_click, aes(x = butterfly, y = hitbox_area, fill = as.factor(clickHit))) +
  geom_boxplot(width = 0.15) +
  scale_fill_manual(values=Butterfly_Palette)+
  geom_image(
    data = img_pos,
    aes(x = butterfly, y = y*1.15, image = image),
    inherit.aes = FALSE,
    size = 0.08
  )+theme_classic()+
  labs(
    fill = "Butterfly",
    y = "Hitbox_area",
    x = "Butterfly"
  )





#Click Distance and EMD
#......................


make_image_positions(
  data      = df_click,
  x_var     = butterfly,
  y_var     = clickDist,
  image_var = imageDir
)
ggplot(df_click, aes(x = Forwards_Confusion, y = clickDist*abs(cos(clickDeg/180*pi)), col = butterfly)) +
  geom_smooth (aes(),method=glm,formula=y~poly(x,1),alpha=0.25,size=1)+
  geom_point()+
  scale_colour_manual(values=Butterfly_Palette)+
  theme_classic()+
  labs(
    fill = "Butterfly",
    y = "Click Lateral Distance (px)",
    x = "Forwards Confusion"
  )


ggplot(df_click, aes(x = Sideways_Confusion, y = clickDist*abs(sin(clickDeg/180*pi)), col = butterfly)) +
  geom_smooth (aes(),method=glm,formula=y~poly(x,1),alpha=0.25,size=1)+
  geom_point()+
  scale_colour_manual(values=Butterfly_Palette)+
  theme_classic()+
  labs(
    fill = "Butterfly",
    y = "Click Sideways Distance (px)",
    x = "Sideways Confusion"
  )




#Click Distance and Behaviour
#......................

make_image_positions(
  data      = df_click,
  x_var     = butterfly,
  y_var     = clickDist,
  image_var = imageDir
)



ggplot(df_click, aes(x = heading_diff_300ms, y =clickDist*(sin(clickDeg/180*pi)))) +
  geom_smooth (aes(),method=glm,formula=y~poly(x,1),alpha=0.25,size=1)+
  geom_point()+
  scale_colour_manual(values=Butterfly_Palette)+
  theme_classic()

ggplot(df_click, aes(x = dist_300ms, y =clickDist, col = hit)) +
  geom_smooth (aes(),method=glm,formula=y~poly(x,1),alpha=0.25,size=1)+
  geom_point()+
  scale_colour_manual(values=Butterfly_Palette)+
  theme_classic()

ggplot(df_click, aes(x = dist_300ms, y =clickDist, col=butterfly)) +
  geom_smooth (aes(),method=glm,formula=y~poly(x,1),alpha=0.25,size=1)+
  geom_point()+
  scale_colour_manual(values=Butterfly_Palette)+
  theme_classic()



df$clickLeftRight

#Click Directions Test
#......................

ggplot(df_click, aes(col=Hitbox,x = clickLeftRight, y = sin(clickDeg/180*pi))) +
  geom_boxplot(width = 0.15) +
  theme_classic()+
  labs(
    fill = "Butterfly",
    y = "Click X Distance (px)",
    x = "Butterfly"
  )

ggplot(df_click, aes(col=Hitbox,x = clickFrontBack, y = cos(clickDeg/180*pi))) +
  geom_boxplot(width = 0.15) +
  theme_classic()+
  labs(
    fill = "Butterfly",
    y = "Click X Distance (px)",
    x = "Butterfly"
  )




#Click Sideways Distance
#......................

make_image_positions(
  data      = df_click,
  x_var     = butterfly,
  y_var     = clickDist,
  image_var = imageDir
)
ggplot(df_click, aes(x = butterfly, y = abs(sin(clickDeg/180*pi)), fill = butterfly)) +
  geom_violin(alpha=0.5) +
  geom_boxplot(width = 0.15) +
  scale_fill_manual(values=Butterfly_Palette)+
  geom_image(
    data = img_pos,
    aes(x = butterfly, y = 0, image = image),
    inherit.aes = FALSE,
    size = 0.08
  )+theme_classic()+
  labs(
    fill = "Butterfly",
    y = "Click Sideways Distance (px)",
    x = "Butterfly"
  )


#Click Angles relative to butterflies.
ggplot(df_click, aes(x = clickDeg, fill = as.factor(clickHit))) +
  geom_histogram(
    binwidth = 30,
    boundary = 0,
    color = "white",
    alpha = 0.8
  ) +
  coord_polar() +
  facet_wrap(~ butterfly) +
  scale_x_continuous(
    limits = c(0, 360),
    breaks = seq(0, 360, by = 30) 
  ) +
  theme_classic() +
  theme(legend.position = "none") +
  labs(x = "Angle", y = "Clicks")


img_center <- data.frame(
  butterfly = unique(df_click$butterfly),
  x = 0,    # angle (doesn't matter in polar)
  y = 0     # center of compass
)

img_center$image <- img_pos$image



ggplot(df_click, aes(x = clickDeg, fill = as.factor(clickHit))) +
  
  geom_image(
    data = img_center,
    aes(x = x, y = y, image = image),
    inherit.aes = FALSE, color = "black", alpha=0.5,
    size = 0.4
  ) +
  
  geom_histogram(
    binwidth = 15,
    boundary = 0,
    color = "darkgray",
    alpha = 0.8
  ) +
  coord_polar() +
  facet_grid(as.factor(clickHit)~ butterfly) +
  scale_x_continuous(
    limits = c(0, 360),
    breaks = seq(0, 360, by = 30)
  ) +

  theme_classic() +
  theme(legend.position = "none") +
  labs(x = "Angle", y = "Clicks")






ggplot(df_click, aes(x = clickDeg, fill = as.factor(clickHit))) +
  
  geom_image(
    data = img_center,
    aes(x = x, y = y, image = image),
    inherit.aes = FALSE,
    alpha = 0.5,
    size = 0.4
  ) +
  
  geom_histogram(
    binwidth = 8,
    boundary = 0,
    color = "lightgray",
    alpha = 0.8
  ) +
  
  coord_polar() +
  
  facet_grid(
    as.factor(clickHit) ~ butterfly,
    scales = "free_y"     
  ) +
  
  scale_x_continuous(
    limits = c(0, 360),
    breaks = seq(0, 360, by = 30),
    labels = function(x) paste0(x, "°")
  ) +
  
  theme_classic() +
  
  theme(
    legend.position = "none",
    
    axis.text.x = element_text(size = 6),  
    
    panel.grid.major = element_line(color = "grey80", size = 0.3, alpha=0.5),
    panel.grid.minor = element_blank()
  ) +
  
  labs(x = "Angle", y = "Clicks")







ggplot(df_click, aes(x = clickDeg)) +
  
  geom_image(
    data = img_center,
    aes(x = x, y = y, image = image),
    inherit.aes = FALSE,
    alpha = 0.8,
    size = 0.4
  ) +
  
  geom_histogram(
    binwidth = 20,
    boundary = 0,
    color = "black",
    fill = "red",
    alpha = 0.4
  ) +
  
  coord_polar() +
  
  facet_wrap(
    .~ butterfly,
    scales = "free_y"     
  ) +
  
  scale_x_continuous(
    limits = c(0, 360),
    breaks = seq(0, 360, by = 30),
    labels = function(x) paste0(x, "°")
  ) +
  
  theme_classic() +
  
  theme(
    legend.position = "none",
    
    axis.text.x = element_text(size = 6),  
    
    panel.grid.major = element_line(color = "grey80", size = 0.3, alpha=0.5),
    panel.grid.minor = element_blank()
  ) +
  
  labs(x = "Angle", y = "Proportion of Clicks")








#Click Parallel Distance
#......................

make_image_positions(
  data      = df_click,
  x_var     = butterfly,
  y_var     = clickDist,
  image_var = imageDir
)
ggplot(df_click, aes(x = butterfly, y = abs(cos(clickDeg/180*pi)), fill = butterfly)) +
  geom_violin(alpha=0.5) +
  geom_boxplot(width = 0.15) +
  #facet_grid(. ~as.factor(clickHit)) +
  scale_fill_manual(values=Butterfly_Palette)+
  geom_image(
    data = img_pos,
    aes(x = butterfly, y = 0, image = image),
    inherit.aes = FALSE,
    size = 0.08
  )+theme_classic()+
  labs(
    fill = "Butterfly",
    y = "Click Parallel Distance (px)",
    x = "Butterfly"
  )

#Click Back vs Front
#......................
make_image_positions(
  data      = df_click,
  x_var     = butterfly,
  y_var     = clickDist,
  image_var = imageDir
)
ggplot(df_click, aes(x = butterfly, y = (cos(clickDeg/180*pi)), fill = butterfly)) +
  geom_violin(alpha=0.5) +
  geom_boxplot(width = 0.15) +
  #facet_grid(. ~as.factor(clickHit)) +
  scale_fill_manual(values=Butterfly_Palette)+
  geom_image(
    data = img_pos,
    aes(x = butterfly, y = , image = image),
    inherit.aes = FALSE,
    size = 0.08
  )+theme_classic()+
  labs(
    fill = "Butterfly",
    y = "Front vs Back",
    x = "Butterfly"
  )






#Click Distance = Hit
#......................


ggplot(df_click, aes(x = butterfly, y = clickDist, fill = as.factor(clickHit))) +
  geom_boxplot(width = 0.15) +
  theme_classic()+
  labs(
    fill = "Hit",
    y = "Click Distance (px)",
    x = "Hit"
  )





#Click Mean R
#......................
p1 <- ggplot(df_hit, aes( x = butterfly,
                            y = clickRGB_R,
                            fill = butterfly
)
) +
  geom_violin(alpha=0.5)


p1 +
  theme_classic() +
  theme(
    text = element_text(size = 15),
    line = element_line(size = 0.6)
  ) +
  labs(
    fill = "Butterfly",
    y = "RGB R",
    x = "Butterfly"
  )



#Click HitBox
#......................



ggplot(df_hit, aes(x = butterfly, fill = Hitbox)) +
  geom_bar(position = "fill", alpha=0.5) +
  scale_y_continuous(labels = scales::percent) +
  geom_image(
    data = img_pos,
    aes(x = butterfly, y = 1.05, image = image),
    inherit.aes = FALSE,
    size = 0.08
  )+
  theme_classic() + facet_grid(. ~as.factor(clickHit)) +
  theme(
    text = element_text(size = 15),
    line = element_line(size = 0.6)
  )+
  labs(
    fill = "Hitbox hit",
    y = "Proportion",
    x = "Butterfly"
  )




ggplot(df_hit, aes(x = butterfly, fill = Hitbox)) +
  geom_bar(alpha = 0.5) +   # default is position = "stack"
  geom_image(
    data = img_pos,
    aes(x = butterfly, y = 1.05, image = image),
    inherit.aes = FALSE,
    size = 0.08
  ) +
  theme_classic() +
  facet_grid(. ~ as.factor(clickHit)) +
  theme(
    text = element_text(size = 15),
    line = element_line(size = 0.6)
  ) +
  labs(
    fill = "Hitbox hit",
    y = "Count",
    x = "Butterfly"
  )







#Click Lethality
#......................
p1 <- ggplot(df_hit, aes( x = butterfly,
                            y = clickRGB_B,
                            fill = butterfly
)
) +
  geom_violin(alpha=0.5)+
  geom_boxplot()


p1 +
  theme_classic() +
  theme(
    text = element_text(size = 15),
    line = element_line(size = 0.6)
  ) +
  labs(
    fill = "Butterfly",
    y = "Lethality",
    x = "Butterfly"
  )




#Hit?
#......................

ggplot(df_nonTut, aes(x = butterfly, fill = as.factor(clickHit))) +
  geom_bar(position = "fill", alpha=0.5) +
  scale_y_continuous(labels = scales::percent) +
  geom_image(
    data = img_pos,
    aes(x = butterfly, y = 1.05, image = image),
    inherit.aes = FALSE,
    size = 0.08
  )+
  scale_y_continuous(labels = scales::percent) +
  theme_classic() +
  theme(
    text = element_text(size = 15),
    line = element_line(size = 0.6)
  )+
  labs(
    fill = "Hit or No Hit",
    y = "Proportion Hit",
    x = "Butterfly"
  )


ggplot(df_nonTut, aes(x = butterfly, fill = as.factor(clickHit))) +
  geom_bar(alpha = 0.5) +   # default is position = "stack"
  geom_image(
    data = img_pos,
    aes(x = butterfly, y = 1.05, image = image),
    inherit.aes = FALSE,
    size = 0.08
  ) +
  theme_classic() +
  theme(
    text = element_text(size = 15),
    line = element_line(size = 0.6)
  ) +
  labs(
    fill = "Hit or No Hit",
    y = "Proportion Hit",
    x = "Butterfly"
  )




#Click Left/Right
#......................

df_click$headingS = ifelse(df_click$heading_diff_from_mean<0,"Positive","Negative")

ggplot(df_click, aes(x = butterfly, fill = clickLeftRight)) +
  geom_bar(position = "fill", alpha=0.5) +
  scale_y_continuous(labels = scales::percent) +
  geom_image(
    data = img_pos,
    aes(x = butterfly, y = 1.05, image = image),
    inherit.aes = FALSE,
    size = 0.08
  )+
  theme_classic() + facet_grid(. ~as.factor(headingS)) +
  theme(
    text = element_text(size = 15),
    line = element_line(size = 0.6)
  )+
  labs(
    fill = "Left or Right",
    y = "Proportion Left/Right",
    x = "Butterfly"
  )



#Click Forward/Back
#......................

ggplot(df_click, aes(x = butterfly, fill = clickFrontBack)) +
  geom_bar(position = "fill", alpha=0.5) +
  scale_y_continuous(labels = scales::percent) +
  geom_image(
    data = img_pos,
    aes(x = butterfly, y = 1.05, image = image),
    inherit.aes = FALSE,
    size = 0.08
  )+
  theme_classic() + facet_grid(. ~as.factor(clickHit)) +
  theme(
    text = element_text(size = 15),
    line = element_line(size = 0.6)
  )+
  labs(
    fill = "Front or Back",
    y = "Proportion Front/Back",
    x = "Butterfly"
  )



#....................................................................................................................................
#----Stats----
#....................................................................................................................................
#....................................................................................................................................


#Confusion
df_click$pathNumber = as.factor(df_click$pathNumber)


mod1 <- lmer(clickDist~ abs(lr_bias_mean_300ms)   + (1|PlayerID)+(1|trialNumber)+(1|pathNumber), data=df_click)
summary(mod1)
anova(mod1)
qqPlot(residuals(mod1))
hist(residuals(mod1))  

mod1 <- lmer(clickDist ~ Forwards_Confusion + (1|PlayerID)+(1|trialNumber)+(1|pathNumber), data=df_click)
summary(mod1)
anova(mod1)
qqPlot(residuals(mod1))
hist(residuals(mod1))  





mod1 <- lmer(clickDist ~ forwards_con_mean_300ms + (1|PlayerID)+(1|trialNumber)+(1|pathNumber), data=df_click)
summary(mod1)
anova(mod1)
qqPlot(residuals(mod1))
hist(residuals(mod1))  


mod1 <- lmer(clickDist ~ sideways_con_mean_300ms + (1|PlayerID)+(1|trialNumber)+(1|pathNumber), data=df_click)
summary(mod1)
anova(mod1)
qqPlot(residuals(mod1))
hist(residuals(mod1))  


df_click$forwards_con_mean_300ms

mod1 <- lmer(clickDist ~ sideways_con_sd_300ms + (1|PlayerID)+(1|trialNumber)+(1|pathNumber), data=df_click)
summary(mod1)
anova(mod1)
qqPlot(residuals(mod1))
hist(residuals(mod1))  

mod1 <- lmer(clickDist ~ Sideways_Confusion + (1|PlayerID)+(1|trialNumber)+(1|pathNumber), data=df_click)
summary(mod1)
anova(mod1)
qqPlot(residuals(mod1))
hist(residuals(mod1))  



#ClickDistance
df_click$pathNumber = as.factor(df_click$pathNumber)

mod1 <- lmer(clickDist ~ butterfly + (1|PlayerID)+(1|trialNumber)+(1|pathNumber), 
             data=subset(df_click,pathNumber!=9))
summary(mod1)
anova(mod1)
qqPlot(residuals(mod1))
hist(residuals(mod1))  

emm_butterfly <- emmeans(mod1, ~ butterfly)
pairs(emm_butterfly, adjust = "tukey")



#Parallel_Distance
df_click$pathNumber = as.factor(df_click$pathNumber)

mod1 <- lmer(Parallel_Distance ~ butterfly + (1|PlayerID)+(1|trialNumber)+(1|pathNumber), data=df_click)
summary(mod1)
anova(mod1)
qqPlot(residuals(mod1))
hist(residuals(mod1))  

emm_butterfly <- emmeans(mod1, ~ butterfly)
pairs(emm_butterfly, adjust = "tukey")


#Perpendicular_Distance
df_click$pathNumber = as.factor(df_click$pathNumber)

mod1 <- lmer(Perpendicular_Distance ~ butterfly + (1|PlayerID)+(1|trialNumber)+(1|pathNumber), data=df_click)
summary(mod1)
anova(mod1)
qqPlot(residuals(mod1))
hist(residuals(mod1))  

emm_butterfly <- emmeans(mod1, ~ butterfly)
pairs(emm_butterfly, adjust = "tukey")



#Back_Front
df_click$pathNumber = as.factor(df_click$pathNumber)

mod1 <- lmer(Back_Front  ~ butterfly + (1|PlayerID)+(1|trialNumber)+(1|pathNumber), data=df_click)
summary(mod1)
anova(mod1)
qqPlot(residuals(mod1))
hist(residuals(mod1))  

emm_butterfly <- emmeans(mod1, ~ butterfly)
pairs(emm_butterfly, adjust = "tukey")





#ClickHit Confusion
df_click$trialNumber
df_click$pathNumber = as.factor(df_click$pathNumber)

mod1_binom <- glmer(
  clickHit ~ abs(lr_bias_mean_300ms) + butterfly + (1 | PlayerID) +(1 | trialNumber) + (1 | pathNumber), data = df_nonTut,
  family = binomial(link = "logit")
)

summary(mod1_binom)
anova(mod1_binom)
qqPlot(residuals(mod1_binom))
hist(residuals(mod1_binom))  

emm_butterfly <- emmeans(mod1_binom, ~ butterfly)
pairs(emm_butterfly, adjust = "tukey")






#ClickHit
df_click$trialNumber
df_click$pathNumber = as.factor(df_click$pathNumber)

mod1_binom <- glmer(
  clickHit ~ butterfly  +  (1 | PlayerID) +(1 | trialNumber) + (1 | pathNumber), 
  data=subset(df_click,pathNumber!=9),
  family = binomial(link = "logit")
)

summary(mod1_binom)
anova(mod1_binom)
qqPlot(residuals(mod1_binom))
hist(residuals(mod1_binom))  

emm_butterfly <- emmeans(mod1_binom, ~ butterfly)
pairs(emm_butterfly, adjust = "tukey")



#ClickHitNoTail
df_click$trialNumber
df_click$pathNumber = as.factor(df_click$pathNumber)

df_click$clickHitnoTail = ifelse(df_click$Hitbox=="Tail",0,as.numeric(df_click$clickHit))
df_click$clickHitnoTail=as.factor(df_click$clickHitnoTail)

mod1_binom <- glmer(
  clickHitnoTail ~ butterfly + (1 | PlayerID) +(1 | trialNumber) + (1 | pathNumber), data = df_click,
  family = binomial(link = "logit")
)

summary(mod1_binom)
anova(mod1_binom)
qqPlot(residuals(mod1_binom))
hist(residuals(mod1_binom))  

emm_butterfly <- emmeans(mod1_binom, ~ butterfly)
pairs(emm_butterfly, adjust = "tukey")





#ClickLethality
df_click$trialNumber
mod1 <- glmer(
  clickRGB_B ~ butterfly + (1 | PlayerID) +(1 | trialNumber) + (1 | pathNumber), data = df_hit, family="poisson")

summary(mod1)
anova(mod1)
qqPlot(residuals(mod1))
hist(residuals(mod1))  

emm_butterfly <- emmeans(mod1, ~ butterfly)
pairs(emm_butterfly, adjust = "tukey")




#FrontBack
df_hit$clickFrontBackBinom = ifelse(df_hit$clickFrontBack=="\"Front\"","1","0")
df_hit$clickFrontBackBinom = as.factor(df_hit$clickFrontBackBinom)


mod1_binom <- glmer(
  clickFrontBackBinom ~ butterfly + (1 | PlayerID) +(1 | trialNumber) + (1 | pathNumber), data = df_hit,
  family = binomial(link = "logit")
)

summary(mod1_binom)
anova(mod1_binom)
qqPlot(residuals(mod1))
hist(residuals(mod1))  

emm_butterfly <- emmeans(mod1_binom, ~ butterfly)
pairs(emm_butterfly, adjust = "tukey")

