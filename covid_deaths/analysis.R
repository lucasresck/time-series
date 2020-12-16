# Import data
full <- readxl::read_xlsx('covid_deaths/covidrj.xlsx')
mortes <- diff(full$deaths)
plot(mortes, main = 'Deaths')

# Z(t) = T(t) + a_t

# Linear model
t = c(1:length(mortes))
deaths = data.frame(mortes = mortes, t = t)
mod = lm(mortes ~ t, data=deaths)
summary(mod)
plot(deaths$t, deaths$mortes, main = 'Linear model')
abline(mod$coefficients)
plot(mod$residuals, main = 'Residuals of the linear model')
# Not a good idea

# Polynomial model
mod = lm(mortes ~ poly(t, 2), data = deaths)
summary(mod)
prediction = predict(mod, data.frame(deaths$t))
plot(deaths$mortes, main = 'Polynomial model')
lines(prediction)
plot(mod$residuals, main = 'Residuals of the polynomial model')
# Better results

# Moving averages
w1 = filter(x = deaths$mortes, filter = rep(1/7, 7), sides = 2)
w2 = filter(x = deaths$mortes, filter = rep(1/14, 14), sides = 2)
w3 = filter(x = deaths$mortes, filter = rep(1/39, 30), sides = 2)
plot(deaths$mortes, main = 'Moving average')
lines(w1, col='red')
lines(w2, col='blue')
lines(w3, col='green')
legend(
  x = 0,
  y = 300,
  legend = c('Data', 'w1', 'w2', 'w3'), 
  col = c('black', 'red', 'blue', 'green'),
  pch = c('o', '', '', ''),
  lty = c(0, 1, 1, 1)
)

# LOWESS
lw1 = lowess(x = deaths$mortes, f=0.5)
lw2 = lowess(x = deaths$mortes, f=0.2)
plot(deaths$mortes, main = 'LOWESS')
lines(lw1, col='red')
lines(lw2, col='blue')
legend(
  x = 0,
  y = 300,
  legend = c('Data', 'lw1', 'lw2'), 
  col = c('black', 'red', 'blue'),
  pch = c('o', '', ''),
  lty = c(0, 1, 1)
)

# Differentiation and ACF
dz = diff(deaths$mortes, lag = 1)
plot(dz, main = 'Differentiation')
plot(acf(x = dz))
plot(acf(deaths$mortes))
# Diff is a good idea

# Trend test
library(randtests)
runs.test(x = deaths$mortes, alternative = "two.sided", plot = TRUE)

# Z(t) = T(t) + S(t) + a_t

# Seasonal dummies
N = length(deaths$mortes)
Q = factor(c(rep(c(1:7), N/7), c(1:(N%%7))))
deaths$Q = Q

# Deterministic seasonality
mod = lm(mortes ~ t+Q, data = deaths)
summary(mod)
plot(deaths$mortes, main = "Seasonality")
lines(mod$fitted.values)
# Log scale (multiplicative)
index = deaths$mortes != 0
mod = lm(log(mortes[index]) ~ t[index]+Q[index], data = deaths)
summary(mod)
plot(deaths$mortes, main = "Seasonality (multiplicative)")
lines(exp(mod$fitted.values))
# Better in logarithmic scale

# Stochastic seasonality
trend = filter(deaths$mortes, sides = 2, filter = rep(1/7, 7))
mod = lm(mortes ~ Q-1, data=deaths)
summary(mod)
S = mod$fitted.values
par(mfrow = c(4,1))
plot(deaths$mortes)
plot(trend)
plot(S)
plot(deaths$mortes - trend - S)

# Decompose
plot(decompose(ts(deaths$mortes, frequency = 7)))

# LOWESS
plot(stl(ts(deaths$mortes, frequency = 7), s.window = 7))

# Kruskal-Wallis
trend = decompose(ts(deaths$mortes, frequency = 7))$trend
deaths$detrended = deaths$mortes - trend
kruskal.test(detrended ~ Q, data = deaths)

# Analysis of variance
mod <- lm(detrended~Q-1, na.action = na.omit, data = deaths)
summary(mod)