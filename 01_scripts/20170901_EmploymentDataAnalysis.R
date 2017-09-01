# -x-x-x-x-x-x-x-x-x-x-x-x-x-x-x-x-x-x-x-x-x-x-x-x-x-x-x-x-x-x-x-x-x-x-x-x-x-x-x-x-x-x-x-x-x
# 
# EMPLOYMENT DATA ANALYSIS
#   
#   Date: 01/09/2017
#   Author: João Augusto P. Batista
#   Version: 0.0.1
#   Description: This script will create two simple charts for analyzing the employment 
#                status in Brazil in the alst 5 years, monthly
# 
# -x-x-x-x-x-x-x-x-x-x-x-x-x-x-x-x-x-x-x-x-x-x-x-x-x-x-x-x-x-x-x-x-x-x-x-x-x-x-x-x-x-x-x-x-x

# PACKAGES ----
library(dplyr)
library(lubridate)
library(ggplot2)
library(ggthemes)
library(reshape2)

# DATA IMPORT AND CLEANING ----
# Inflation
ipca <-
  read.csv2('00_data/ipca.csv') %>% 
  mutate(competencia = dmy(as.character(competencia)),
         var_apl = 0) %>% 
  select(-X)

# Get the cummulative inflation of each month up to July 2017
ipca$var_perc[2:nrow(ipca)] <-
  (ipca$num_indice[2:nrow(ipca)]/ipca$num_indice[1:nrow(ipca)-1])-1

ipca$var_perc[1] <- NA

# apply the calculated inflation, bringing values to July 2017
for (i in 1:nrow(ipca)) {
  ipca$var_apl[i] <-
    (ipca$num_indice[nrow(ipca)]/ipca$num_indice[i]) - 1
}

# movements
caged <-
  read.csv2('00_data/caged2012a2017.csv') %>% 
  mutate(competencia = ymd(paste0(as.character(competencia), '01')),
         media_sal_mensal = as.numeric(as.character(media_sal_mensal)),
         adm_des = ifelse(adm_des == 1, 'Hires', 'Separations'),
         adm_des = as.factor(adm_des)) %>% 
  left_join(ipca) %>% 
  mutate(media_sal_mensal_jul2017 = media_sal_mensal * (1 + var_apl))
  
# AUXILIARY DATA FRAMES ----
caged_cast <-
  dcast(caged, competencia ~ adm_des, value.var='saldo_mov') %>% 
  mutate(saldo = Hires + Separations) %>% 
  melt(id = c('competencia'))

names(caged_cast) <- c('competencia', 'adm_des', 'valor')

caged_cast1 <- caged_cast[which(as.character(caged_cast$adm_des) != 'saldo'),]
caged_cast2 <- caged_cast[which(as.character(caged_cast$adm_des) == 'saldo'),]

caged_cast1$t = 'Movements'
caged_cast2$t = 'Net Hires'

# for the wages
caged_cast_sal <-
  caged %>% 
  dcast(competencia ~ adm_des, value.var='media_sal_mensal_jul2017') %>% 
  mutate(dif_media_sal_mensal_jul2017 = Hires - Separations) %>% 
  melt(id = 'competencia') %>% 
  mutate(t = ifelse(variable == 'dif_media_sal_mensal_jul2017', 
                    'Wage Diference: Hires - Separations',
                    'Average Wage Evolution'))

caged_cast_sal1 <- caged_cast_sal[which(caged_cast_sal$t != 'Wage Diference: Hires - Separations'),]
caged_cast_sal2 <- caged_cast_sal[which(caged_cast_sal$t == 'Wage Diference: Hires - Separations'),]

# for the cumulative data
caged_cum <- caged_cast %>%  filter(adm_des == 'saldo') %>% mutate(cummulative = 0)
caged_cum$cummulative[1] <- caged_cum$valor

for (i in 2:nrow(caged_cum)) {
  caged_cum$cummulative[i] = caged_cum$cummulative[i-1] + caged_cum$valor[i]
}

# CHART BUILDING ----
# Using the The Economist theme!
p1 <-
  ggplot(caged_cast1) +
    geom_line(
      aes(x = competencia, y = abs(valor),
          color = adm_des)) +
    geom_bar(
      data = caged_cast2,
      aes(x = competencia, y = valor),
      fill = 'grey 30',
      stat = 'identity'
    ) +
    facet_wrap(~t, nrow=2, ncol=1, scales = "free_y") +
    labs(y = '# of Movements', title = 'Labor Market Behaviour',
         x = 'Month', color = 'Movement\nType') +
    scale_x_date(date_minor_breaks = '1 month', date_labels = '%b/%y') +
  theme_economist()

p2 <-
  ggplot(caged_cast_sal1) +
  geom_line(
    aes(x = competencia,
        y = value,
        color = variable)) +
  geom_bar(
    data = caged_cast_sal2,
    aes(x = competencia,
        y = value),
    stat = 'identity') +
  labs(y = 'Average Monthly Wage', title = 'Wage Behaviour',
       x = 'Month', color = 'Movement\nType') +
  scale_x_date(date_minor_breaks = '1 month', date_labels = '%b/%y') +
  facet_wrap(~t, nrow=2, ncol=1, scales = "free_y") +
  theme_economist()

p3 <- 
  ggplot(caged_cum) +
  geom_line(
    aes(x = competencia,
        y = cummulative/1000)) +
  labs(y = '# in Thousands',
       title = 'Cummulative Net Hires',
       x = 'Month') +
  scale_x_date(date_minor_breaks = '1 month', date_labels = '%b/%y') +
  theme_economist()

  
# SAVE THE CHARTS ---- 
ggsave('02_images/LaborMarketBehavior.png', p1, device = 'png')
ggsave('02_images/WageBehaviour.png', p2, device = 'png')
ggsave('02_images/CummulativeNetHires.png', p3, device = 'png')
