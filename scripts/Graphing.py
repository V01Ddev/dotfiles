import matplotlib
import tikzplotlib
import matplotlib.pyplot as plt
import numpy as np

# Range of x
x = np.arange(-100,100,1)

# The eq
y = 1+(2/(x+1))

# Setting axis style
ax = plt.gca()
ax.spines['top'].set_color('none')
ax.spines['bottom'].set_position('zero')
ax.spines['left'].set_position('zero')
ax.spines['right'].set_color('none')

# Ploting and exporting 
plt.plot(x,y)
plt.savefig("graph.png")
