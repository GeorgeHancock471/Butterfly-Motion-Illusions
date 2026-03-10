# INSTURCTIONS----


# Load Libraries ----
library(ggpattern)
library(ggplot2)
library(lme4)
library(LMERConvenienceFunctions)
library(lmerTest)
library(tidyr)
library(circular)
library(MASS)
library(dplyr)
library(emmeans)

setwd(dirname(rstudioapi::getSourceEditorContext()$path))

# Load Data ----
EMDdata <- read.csv("EMD_Output.csv", header=TRUE)
Tdata  <- read.csv("Info_Treatment.csv", header=TRUE)
Bdata <- read.csv("Info_Butterfly.csv", header=TRUE)

# Create EMD DataFrame ----
df_emd <- merge(EMDdata,Tdata)
df_emd <- merge(df_emd,Bdata)
df_emd

#NB Up = Forwards, Down = Backwards
df_emd$Forwards_Confusion = with(df_emd, (Down-Up)/(Down+Up))
df_emd$Sideways_Confusion = with(df_emd, (Left-Up)/(Left+Up))

df_emd$Forwards_Energy = df_emd$Up



#Supp, How does motion energy change across the flight?  ----

df_expl = subset(df_emd, ID == "T18_Va_11Aug2" ) # Isolate red admiral flight used for Figure 1


p = ggplot(subset(df_expl,Pattern=="Patterned"), aes(x = Frame, y = Up)) + 
  geom_area(aes(y = Up), fill = "green", alpha = 1) +
  geom_area(aes(y = -Down), fill = "magenta", alpha = 1) +
  geom_area(data=subset(df_expl,Pattern=="Averaged"),aes(y = Up), fill = "yellow", alpha = 0.7) +
  geom_area(data=subset(df_expl,Pattern=="Averaged"),aes(y = -Down), fill = "cyan", alpha = 0.5) +
  geom_line(aes(y = Up-Down), col = "red", linetype=1, size=1) +
  geom_line(data=subset(df_expl,Pattern=="Averaged"),aes(y = Up-Down), col = "black", linetype=1, linewidth=1) +
  geom_hline(yintercept=0)+
  theme_classic()+
  labs(title = "",
       x = "Frame",
       y = "EMD motion energy") + 
  theme_classic()

p

# Save SVG
svg("Sup_motion_energy_across_frames.svg", width = 5, height = 5) 
p
dev.off()



#Supp, What are the ratios of motion energy across the pattern treatments? ----
df_up = df_emd
df_down = df_emd
df_left = df_emd
df_right = df_emd

df_up$motion_energy = df_emd$Up
df_down$motion_energy = df_emd$Down
df_left$motion_energy = df_emd$Left
df_right$motion_energy = df_emd$Right

df_up$direction = "forwards"
df_down$direction = "backwards"
df_left$direction = "left"
df_right$direction = "right"

df_directions = rbind(df_up,df_down,df_left,df_right)


df_avg_energy <- df_directions %>%
  group_by(Pattern, direction) %>%
  summarise(avg_motion_energy = mean(motion_energy, na.rm = TRUE)) %>%
  ungroup()

df_normalized <- df_avg_energy %>%
  group_by(Pattern) %>%
  mutate(norm_motion_energy = avg_motion_energy / avg_motion_energy[direction == "forwards"]) %>%
  ungroup()


# Average Energy
p = ggplot(df_avg_energy, aes(x = Pattern, y = avg_motion_energy, fill = direction)) +
  geom_col(position = "dodge", alpha=1, col = "black") +
  labs(y = "Mean Motion Energy", title = "Mean Motion Energy by Pattern and Direction") +
  scale_fill_manual(values = c("#c452c2","#5cc452", "#c45452", "#526dc4")) + 
  labs(title = "",
       x = "Appearance",
       y = "MotionEnergy",
       fill = "Direction",
       pattern = "Appearance") +  theme_classic() 
p

# Save SVG
svg("Sup_energy_ratio_unnormalised.svg", width = 5, height = 5) 
p
dev.off()

# Normalised Average Energy
p =ggplot(df_normalized, aes(x = Pattern, y = norm_motion_energy, fill = direction)) +
  geom_col(position = "dodge", alpha=1, col = "black") +
  labs(y = "Mean Motion Energy", title = "Mean Motion Energy by Pattern and Direction") +
  scale_fill_manual(values = c("#c452c2","#5cc452", "#c45452", "#526dc4")) + 
  labs(title = "",
       x = "Appearance",
       y = "Normalised Motion Energy",
       fill = "Direction",
       pattern = "Appearance") +  theme_classic() 

p

# Save SVG
svg("Sup_energy_ratio_normalised.svg", width = 5, height = 5) 
p
dev.off()



#Main, How does pattern influence our motion confusion metrics? ---- 

df_emd$Pattern <- factor(df_emd$Pattern, levels = c("Patterned", "Averaged", "Black", "White"))

## PLOTS ----

### Forward-Confusion Violin (Main, Figure 1)  ----

p = ggplot(df_emd, aes(x = Pattern, y = Forwards_Confusion, fill = Pattern, 
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
  scale_fill_manual(values = c("salmon","darkgray","black",  "white")) + 
  scale_pattern_manual(values = c("stripe","none", "none", "none")) +  # Apply stripes to the middle one
  labs(title = "",
       x = "Appearance",
       y = "Forward-Confusion",
       fill = "Appearance",
       pattern = "Appearance") +  theme_classic()  +theme(legend.position = "none")
p
# Save SVG
svg("Figure_1_FC_Violin.svg", width = 5, height = 5) 
p
dev.off()

nrow(df_emd)/4



### Sideways-Confusion Violin  (Main, Figure 1)   ----

p = ggplot(df_emd, aes(x = Pattern, y = Sideways_Confusion, fill = Pattern, 
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
  scale_fill_manual(values = c("salmon","darkgray","black",  "white")) + 
  scale_pattern_manual(values = c("stripe","none", "none", "none")) +  # Apply stripes to the middle one
  labs(title = "",
       x = "Appearance",
       y = "Sideways-Confusion",
       fill = "Appearance",
       pattern = "Appearance") +  theme_classic()  +theme(legend.position = "none")

p
# Save SVG
svg("Figure_1_SC_Violin.svg", width = 5, height = 5) 
p
dev.off()



### Forwards-Energy Violin  (Supp)   ----

p = ggplot(df_emd, aes(x = Pattern, y = Forwards_Energy, fill = Pattern, 
                   pattern = Pattern)) + 
  geom_violin(alpha=0.25) + scale_y_log10() +
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
  scale_fill_manual(values = c("salmon","darkgray","black",  "white")) + 
  scale_pattern_manual(values = c("stripe","none", "none", "none")) +  # Apply stripes to the middle one
  labs(title = "",
       x = "Appearance",
       y = "Forwards-Energy",
       fill = "Appearance",
       pattern = "Appearance") +  theme_classic()  +theme(legend.position = "none")
p
svg("Sup_FE_Violin.svg", width = 5, height = 5) 
p
dev.off()




## STATS----
set.seed(123)

### Forwards Confusion Stats (main) ----
df_emd$Pattern <- factor(df_emd$Pattern, 
                             levels = c("Patterned", "Averaged", "Black", "White"))


#Data has to be transformed to achieve, normal distribution. 
FC_Model <- lmer(((Forwards_Confusion+1)^0.5)~ Pattern+(1|ID)+(1|Frame), data = df_emd)
summary(FC_Model) 
hist(residuals(FC_Model))
qqnorm(residuals(FC_Model))     # Plots the residuals against a normal distribution
qqline(residuals(FC_Model))     # Adds a reference line for normality

### Forwards Confusion tukey posthoc (supp) ----
emmeans(FC_Model, pairwise ~ Pattern, adjust = "tukey")

#Run to generate DF values, WARNING there is a large computation time
#emmeans(FC_Model, pairwise ~ Pattern, adjust = "tukey",pbkrtest.limit = 9564)




### Sideways Confusion Stats (main) ----
df_emd$Pattern <- factor(df_emd$Pattern, 
                         levels = c("Patterned", "Averaged", "Black", "White"))

#Data has to be transformed to achieve, normal distribution. 
SE_Model <- lmer(((Sideways_Confusion+1)^0.5)~ Pattern+(1|ID)+(1|Frame), data = df_emd)
summary(SE_Model) 
hist(residuals(SE_Model))
qqnorm(residuals(SE_Model))     # Plots the residuals against a normal distribution
qqline(residuals(SE_Model))     # Adds a reference line for normality

### Sideways Confusion tukey posthoc (supp) ----
emmeans(SE_Model, pairwise ~ Pattern, adjust = "tukey")

#Run to generate DF values, WARNING there is a large computation time
#emmeans(SE_Model, pairwise ~ Pattern, adjust = "tukey",pbkrtest.limit = 9564)


### Forwards Energy Stats (supp) ----
df_emd$Pattern <- factor(df_emd$Pattern, 
                         levels = c("Patterned", "Averaged", "Black", "White"))

#Data has to be transformed to achieve, normal distribution. 
FE_Model <- lmer(((Forwards_Energy)^0.5)~ Pattern+(1|ID)+(1|Frame), data = df_emd)
summary(FE_Model) 
hist(residuals(FE_Model))
qqnorm(residuals(FE_Model))     # Plots the residuals against a normal distribution
qqline(residuals(FE_Model))     # Adds a reference line for normality

### Forwards Energy tukey posthoc (supp) ----
emmeans(FE_Model, pairwise ~ Pattern, adjust = "tukey")
#emmeans(FE_Model, pairwise ~ Pattern, adjust = "tukey",pbkrtest.limit = 9564)





