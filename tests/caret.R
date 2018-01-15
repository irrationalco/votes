# SETUP

setwd('/Users/Franklin/Git/votes/tests')
options(scipen = 999)
require(caret)
require(data.table)
require(dplyr)
require(party)
require(randomForest)
require(sampling)

# FUN

cleanText <- function(text) {
  text <- str_replace_all(text, 'á', 'a')
  text <- str_replace_all(text, 'é', 'e')
  text <- str_replace_all(text, 'í', 'i')
  text <- str_replace_all(text, 'ó', 'o')
  text <- str_replace_all(text, 'ú', 'u')
  text <- str_replace_all(text, 'ü', 'u')
  text <- str_replace_all(text, '\\.', '')
  text <- gsub('(?<=[\\s])\\s*|^\\s+|\\s+$', '', text, perl = TRUE)
    # checks for whitespace - deserves its own explanation:
    # (?<=    look behind to see if there is
    # [\s]    any character of: whitespace (\n, \r, \t, \f, and ' ')
    # )       end of look behind
    # \s*     whitespace (\n, \r, \t, \f, and ' ') (0 or more times (matching the most amount possible))
    # |       or
    # ^       the beginning of the string
    # \s+     whitespace (\n, \r, \t, \f, and ' ') (1 or more times (matching the most amount possible))
    # $       before an optional \n, and the end of the string
  return(text)
}

# DATA

# Read
ine <- fread('../ine/out/tbl_ine.csv', header = TRUE, sep = ',', stringsAsFactors = F)
coa <- fread('../coahuila/out/tbl_coahuila.csv', header = TRUE, sep = ',', stringsAsFactors = F)
dem <- fread('../inegi/out/inegi_summary.csv', header = TRUE, sep = ',', stringsAsFactors = F)
dem <- subset(dem, select = -c(MUN_IFE))
names(dem)[c(1:2)] <- c('CODIGO_ESTADO', 'CODIGO_MUNICIPIO')

x <- bind_rows(ine, coa)
y <- left_join(x, dem)

dem_tbl <- ine %>%
  select(ANO, CODIGO_ESTADO, CODIGO_MUNICIPIO, DISTRITO_FED, SECCION) %>%
  filter(ANO == 2015)

dat <- y %>% filter(ANO == 2015)
unq <- unique(dat[c('ANO', 'CODIGO_ESTADO', 'ESTADO', 'CODIGO_MUNICIPIO', 'DISTRITO_FED', 'SECCION')])

dat <- read.csv("./predict/actual2/electoral_vic.csv")
dat$PRESIDENTE <- with(dat, factor(PRESIDENTE))
dat$NC <- with(dat, factor(NC))
inegi <- read.csv("./data/inegi/inegi.csv")

### TRAIN DATA
train <- dat

train <- subset(train, ANO < 2015)
train <- subset(train, ANO > 2006)

MOV <- subset(train, select = c(MOV))
PAN <- subset(train, select = c(PAN))
PRI <- subset(train, select = c(PRI))

train <- subset(train, select = c(
        SECCION, TIPO, ELECCION, ANO, PRESIDENTE, NC, NOM, NOM.SECCION, TNT.EXP,
        ALI.ENC, ALT.ENC, CON.ENC, MOR.ENC, MOV.ENC, PAN.ENC, PRD.ENC, PRI.ENC, PT.ENC, VER.ENC, NC.ENC,
        ALI.EXP, ALT.EXP, CON.EXP, MOR.EXP, MOV.EXP, PAN.EXP, PRD.EXP, PRI.EXP, PT.EXP, VER.EXP, NC.EXP))

train.MOV <- data.frame(train, MOV)
train.PAN <- data.frame(train, PAN)
train.PRI <- data.frame(train, PRI)

train.MOV <- left_join(train.MOV, inegi)
train.PAN <- left_join(train.PAN, inegi)
train.PRI <- left_join(train.PRI, inegi)

### PREDICT DATA
predict <- dat

predict <- subset(predict, ANO == 2015)

predict <- subset(predict, select = c(
       SECCION, TIPO, ELECCION, ANO, PRESIDENTE, NC, NOM, NOM.SECCION, TNT.EXP,
        ALI.ENC, ALT.ENC, CON.ENC, MOR.ENC, MOV.ENC, PAN.ENC, PRD.ENC, PRI.ENC, PT.ENC, VER.ENC, NC.ENC,
        ALI.EXP, ALT.EXP, CON.EXP, MOR.EXP, MOV.EXP, PAN.EXP, PRD.EXP, PRI.EXP, PT.EXP, VER.EXP, NC.EXP))
predict <- left_join(predict, inegi)

###########################################################
### MODELS                                            ###
###########################################################

### MOV

    # SAMPLE
set.seed(1)
destrabe1 <- createDataPartition(y = train.MOV$SECCION, p = 1.0, list = FALSE)
large1 <- train.MOV[destrabe1,]
mini1 <- train.MOV[-destrabe1,]

    # NON-FORMULA
independent1 <- subset(large1, select = -c(MOV))
response1 <- large1[,"MOV"]

    # TRAIN
set.seed(1)
rf1.control <- trainControl(method = "repeatedcv", number = 10, repeats = 1)
rf1.train <- train(x = independent1, y = response1, method = "rf", metric = "RMSE", importance = TRUE, proximity = TRUE, trControl = rf1.control)
rf1.final <- rf1.train$finalModel

rf1.train
rf1.final

    # PREDICT
predicted.MOV <- predict.train(rf1.train, predict)

### PAN

    # SAMPLE
set.seed(1)
destrabe2 <- createDataPartition(y = train.PAN$SECCION, p = 1.0, list = FALSE)
large2 <- train.PAN[destrabe2,]
mini2 <- train.PAN[-destrabe2,]

    # NON-FORMULA
independent2 <- subset(large2, select = -c(PAN))
response2 <- large2[,"PAN"]

    # TRAIN
set.seed(1)
rf2.control <- trainControl(method = "repeatedcv", number = 10, repeats = 1)
rf2.train <- train(x = independent2, y = response2, method = "rf", metric = "RMSE", importance = TRUE, proximity = TRUE, trControl = rf2.control)
rf2.final <- rf2.train$finalModel

rf2.train
rf2.final

    # PREDICT
predicted.PAN <- predict.train(rf2.train, predict)

### PRI

    # SAMPLE
set.seed(1)
destrabe3 <- createDataPartition(y = train.PRI$SECCION, p = 1.0, list = FALSE)
large3 <- train.PRI[destrabe3,]
mini3 <- train.PRI[-destrabe3,]

    # NON-FORMULA
independent3 <- subset(large3, select = -c(PRI))
response3 <- large3[,"PRI"]

    # TRAIN
set.seed(1)
rf3.control <- trainControl(method = "repeatedcv", number = 10, repeats = 1)
rf3.train <- train(x = independent3, y = response3, method = "rf", metric = "RMSE", importance = TRUE, proximity = TRUE, trControl = rf3.control)
rf3.final <- rf3.train$finalModel

rf3.train
rf3.final

    # PREDICT
predicted.PRI <- predict.train(rf3.train, predict)

###########################################################
### COMPARE                                           ###
###########################################################

MOV.PRED <- predicted.MOV
PAN.PRED <- predicted.PAN
PRI.PRED <- predicted.PRI

compare <- data.frame(SECCION = predict$SECCION, ELECCION = predict$ELECCION, ANO = predict$ANO, MOV.EXP = predict$MOV.EXP, MOV.PRED = MOV.PRED, PAN.EXP = predict$PAN.EXP, PAN.PRED = PAN.PRED, PRI.EXP = predict$PRI.EXP, PRI.PRED = PRI.PRED)
write.csv(compare, "./predict/actual2/compare.csv", row.names = FALSE, quote = FALSE)

###########################################################
### PLOTS                                           ###
###########################################################

    # IMPORTANCE
png("./predict/actual2/varImpPlot_MOV.png", res = 100, width = 1000, height = 1000) 
varImpPlot(rf1.final)
dev.off()
png("./predict/actual2/varImpPlot_PAN.png", res = 100, width = 1000, height = 1000) 
varImpPlot(rf2.final)
dev.off()
png("./predict/actual2/varImpPlot_PRI.png", res = 100, width = 1000, height = 1000) 
varImpPlot(rf3.final)
dev.off()

    # OBS VS PRED
png("./predict/actual2/ObsVsPred_MOV.png", res = 100, width = 1000, height = 1000) 
reg1 <- lm(response1 ~ rf1.final$predicted)
plot(response1, rf1.final$predicted, xlim = c(0, 1500), ylim = c(0, 1500))
abline(reg1, col = "red")
dev.off()
png("./predict/actual2/ObsVsPred_PAN.png", res = 100, width = 1000, height = 1000) 
reg2 <- lm(response2 ~ rf2.final$predicted)
plot(response2, rf2.final$predicted, xlim = c(0, 1500), ylim = c(0, 1500))
abline(reg2, col = "red")
dev.off()
png("./predict/actual2/ObsVsPred_PRI.png", res = 100, width = 1000, height = 1000) 
reg3 <- lm(response3 ~ rf3.final$predicted)
plot(response3, rf3.final$predicted, xlim = c(0, 1500), ylim = c(0, 1500))
abline(reg3, col = "red")
dev.off()

### NOTA PARA HACER "predict_me.csv"

AYUNTAMIENTO    2013    2013
DF              2009    2015
AYUNTAMIENTO    2010    2016
GOBERNADOR      2010    2016
DF              2012    2018
PRESIDENTE      2012    2018
SENADOR         2012    2018