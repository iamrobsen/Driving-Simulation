inv_logit <- function(x){1 / (1 + exp(-x))}
sim_logit_driving <- function() {
  n = 100000
  # Parameters for K
  age <-  rbinom(n, 1, .3)  # >65yo
  sex <-  rbinom(n, 1, .52) # female
  area <-  rbinom(n, 1, .6) # urban
  # Baseline b0 characteristics
  a0 <-  logit(.3)   # low driving mileage
  c0 <-  logit(0.17) # Polypharmacy
  b0 <-  logit(.002) # RTC
  # Parameters for the ZK relationship
  a1 <-  log(1.2)
  a2 <-  log(1.8)
  a3 <-  log(1.2)
  # Parameters for the XKZ relationship
  c1 <-  log(2)
  c2 <-  log(0.9)
  c3 <-  log(1.2)
  c4 <-  log(1.5)
  # Parameters for the YXZK relationship
  b1 <-  rnorm(1, log(1.35), (log(1.56)-log(1.17))/(2*1.96))
  b2 <-  log(3)
  b3 <-  log(0.6)
  b4 <-  log(0.3)
  b5 <-  log(0.9)
z <- rbinom(n, 1, inv_logit(a0 + a1*age + a2*sex + a3*area))
x <- rbinom(n, 1, inv_logit(c0 + c1*age + c2*sex + c3*area + c4*z))
y <- rbinom(n, 1, inv_logit(b0 + b1*x + b2*z + b3*age + b4*sex +
b5*area))
  # df = data.frame(data = cbind(y, x, z,age, sex, area) )
  # DGM under an effect of X
  model1 = glm(y~x+z+age+sex+area, family="binomial")
  b1_1 = coef(model1)[2]
  se = diag(vcov(model1))
  se_b1_1 = sqrt(se[2])
  # print(summary(model1))
# DGM under no effect of X
b1 = 0
y = rbinom(n, 1, inv_logit(b0 + b1*x + b2*z + b3*age + b4*sex + b5*area)) model0 = glm(y~x+z+age+sex+area, family="binomial")
b1_0 = coef(model0)[2]
se = diag(vcov(model0))
se_b1_0 = sqrt(se[2])
42
# print(summary(model0))
  b = cbind(b1_1, se_b1_1, b1_0, se_b1_0)
return(b) }
sim_logit_driving()
# Simulations
S <- 1000
e_b1_m1 <- rep(NA, S)
e_se_b1_m1 <- rep(NA, S)
e_b1_m0 <- rep(NA, S)
e_se_b1_m0 <- rep(NA, S)
for (i in seq_len(S)) {
  est <- sim_logit_driving()
  e_b1_m1[i]     <- est[1]
  e_se_b1_m1[i]  <- est[2]
  e_b1_m0[i]     <- est[3]
  e_se_b1_m0[i]  <- est[4]
}
c(mean(e_b1_m1), sd(e_b1_m1))
c(mean(e_b1_m0), sd(e_b1_m0))
hist(e_b1_m1)
# compute simulated power
sum( pnorm(-abs((e_b1_m1-0)/e_se_b1_m1))*2 < 0.05)/S*100
