import numpy as np
import pandas as pd
from scipy import stats
import statsmodels.api as sm
import statsmodels.formula.api as smf

# Define the mathematical function invlogit
def invlogit(x):
    return np.exp(x)/(1+np.exp(x))
# Define the mathematical function logit
def logit(x):
    return np.log(x/(1-x))

# Simulation program
def sim_con():
    n = 500000
    
    # Parameters for K
    age = np.random.binomial(1, .3, n)  # >65yo
    sex = np.random.binomial(1, .52, n) # female
    area = np.random.binomial(1, .6, n) # urban
    
    # Parameters for the ZK relationship
    a1 = np.log(1.2)
    a2 = np.log(1.8)
    a3 = np.log(1.2)
   
    # Parameters for the XKZ relationship
    c1 = np.log(2)
    c2 = np.log(0.9)
    c3 = np.log(1.2)
    c4 = np.log(np.random.uniform(1.1, 3, 1))
    
    # Parameters for the YXZK relationship
    b1 = np.random.normal(np.log(1.35), (np.log(1.56)-np.log(1.17))/(2*1.96), 1)
    b2 = np.log(np.random.uniform(1.1, 4, 1))
    b3 = np.log(0.6)
    b4 = np.log(0.3)
    b5 = np.log(0.9)
    
    z = np.random.binomial(1, 1 / (1 + np.exp(-(np.log(0.3) + a1 * age + a2 * sex + a3 * area))))
    x = np.random.binomial(1, 1 / (1 + np.exp(-(np.log(0.17) + c1 * age + c2 * sex + c3 * area + c4 * z))))
    y = np.random.binomial(1, 1 / (1 + np.exp(-(np.log(0.000377) + b1 * x + b2 * z + b3 * age + b4 * sex + b5 * area))))

    df = pd.DataFrame(data = np.column_stack((y, x, z, age, sex, area)))
   
    # DGM under an effect of X
    model1 = smf.logit('y~x+z+age+sex+area', data=df).fit()
    se = np.sqrt(np.diag(model1.cov_params()))
    b1_1 = model1.params[1]
    se_b1_1 = se[1]
    
    # DGM under no effect of X
    b1 = 0
    y = np.random.binomial(1, invlogit(np.log(0.000377) + b1*x + b2*z + b3*age + b4*sex + b5*area), n)
    model0 = smf.logit('y~x+z+age+sex+area', data=df).fit()
    b1_0 = model0.params[1]
    se = np.sqrt(np.diag(model0.cov_params()))
    b1_0 = model0.params[1]
    se_b1_0 = se[1]
    b = (b1_1, se_b1_1, b1_0, se_b1_0)
    return(b)

# Simulate a 1000 studies
seed_value = 8492
np.random.seed(seed_value)

nsim = 1000
b = []
for i in range(nsim):
    b = np.append(b, np.array(sim_con()), axis=0)
sim_results = np.reshape(b, (nsim, 4))

# Simulated Statistical Power
z = (b1-0)/se_b1
p = stats.norm.cdf(-abs(z))*2
power = np.sum(p<.05)/nsim
print("Simulated power (%) = " , power*100)
