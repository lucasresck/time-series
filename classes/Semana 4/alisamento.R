library(zoo)
library(forecast)

# dados de poluição para o periodo de 1/1/1997 ate 31/12/1997
df <- readxl::read_xls('poluicao.xls')
startdate <- as.Date(df$DATA[1])
no2 <- zooreg(df$no2, start = startdate, frequency = 1)
plot(no2)

# separar uma janela de dados para estudo 
enddate <- as.Date('1997-01-15')
no2.1 <- window(no2, start = startdate, end = enddate)

# exponential smoothing (ggplot possui alisamento exponencial!!)
es1 <- HoltWinters(no2.1, beta = F, gamma = F)
plot(es1)
fc1 <- forecast(es1, 7)
plot(fc1)

# Holt
es2 <- HoltWinters(no2.1, gamma=F)
plot(es2)
fc2 <- forecast(es2, 7)
plot(fc2)

# Holt-Winters (multiplicativo)
es3 <- HoltWinters(no2.1, seasonal = 'multiplicative')
plot(es3)
fc3 <- forecast(es3, 7)
plot(fc3)

# Holt-Winters (aditivo)
es4 <- HoltWinters(no2.1, seasonal = 'additive')
plot(es4)
fc4 <- forecast(es4, 7)
plot(fc4)



