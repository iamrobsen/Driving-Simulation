##############################################################
# Plotting the results of 10 simulated scenarios
# Output: Simulated statistical power to for an increasing adjusted effect of polypharmacy on the probability of road traffic crashes in older adults. 
# The simulated power is defined as the fraction of studies in which the p-value was less than 0.05 based on 1 000 simulations with 500 000 observations for each replication. 
# Adjustments were made for driving mileage, age, sex, and geographical region. 
##############################################################

import numpy as np
import seaborn as sns
import matplotlib.pyplot as plt

sns.color_palette("rocket")
sns.set_palette("rocket")

# Results from the simulations (power estimations)
y = [.077, .183, .334, .530, .706, .826, .904, .948, .977, .990]
# Effect sizes
x = [1.1, 1.2, 1.3, 1.4, 1.5, 1.6, 1.7, 1.8, 1.9, 2]

# Create the scatterplot
sns.set_style("white")
ax = sns.scatterplot(x=x, y=y)

# Add labels to the points
for i, point in enumerate(zip(x, y)):
    ax.annotate(f"{point[1]}", (point[0], point[1]), textcoords="offset points", xytext=(10,-10))

sns.lineplot(x = x, y = y, linestyle='dashed', linewidth=0.5)

# Add axis labels
plt.ylabel("Simulated Statistical Power")
plt.xlabel("Confounder-Adjusted Odds Ratio")

sns.despine()
plt.show()
