# -----
#
# Prepare the plots
#
# -----

import pandas as pd
import numpy as np
from matplotlib import dates as mdates
from matplotlib.dates import date2num
from matplotlib.colors import ListedColormap
from matplotlib import ticker
from scipy.interpolate import interp1d

# ----- for residents data only
def plot_rt_residents(result, ax, state_name, fig):

        # Colors
        ABOVE = [1,0,0]
        MIDDLE = [1,1,1]
        BELOW = [0.5,0.8,0.9]

        vals = np.ones((25, 3))
        vals1 = np.ones((25, 3))
        vals[:, 0] = np.linspace(BELOW[0], MIDDLE[0], 25)
        vals[:, 1] = np.linspace(BELOW[1], MIDDLE[1], 25)
        vals[:, 2] = np.linspace(BELOW[2], MIDDLE[2], 25)

        vals1[:, 0] = np.linspace(MIDDLE[0], ABOVE[0], 25)
        vals1[:, 1] = np.linspace(MIDDLE[1], ABOVE[1], 25)
        vals1[:, 2] = np.linspace(MIDDLE[2], ABOVE[2], 25)

        cmap = ListedColormap(np.r_[vals,vals1])
        color_mapped = lambda y: np.clip(y, .5, 1.5)-.5

        index = result['Reff-estimate'].index.get_level_values('report_date')
        values = result['Reff-estimate'].values

        # Plot dots and line
        ax.plot(index, values, c='k', zorder=1, alpha=.25)
        ax.scatter(index,values,s=30,lw=.5,c=cmap(color_mapped(values)),edgecolors='k', zorder=2)

        lowfn = interp1d(date2num(index),result['Low_50'].values,bounds_error=False,fill_value='extrapolate')
        highfn = interp1d(date2num(index),result['High_50'].values,bounds_error=False,fill_value='extrapolate')
        extended = pd.date_range(start=pd.Timestamp('2020-03-01'),end=index[-1])

        ax.fill_between(extended,lowfn(date2num(extended)),highfn(date2num(extended)),color='k',alpha=.1,lw=0,zorder=3)
        ax.axhline(1.0, c='k', lw=1, label='$R_t=1.0$', alpha=.25);

        # Formatting
        ax.xaxis.set_major_locator(mdates.MonthLocator())
        ax.xaxis.set_major_formatter(mdates.DateFormatter('%d'))
        ax.xaxis.set_minor_locator(mdates.DayLocator())
        ax.yaxis.set_major_locator(ticker.MultipleLocator(1))
        ax.yaxis.set_major_formatter(ticker.StrMethodFormatter("{x:.1f}"))
        ax.grid(which='major', axis='y', c='k', alpha=.1, zorder=-2)
        ax.margins(0)
        ax.set_ylim(0.0, 2.5)
        ax.set_xlim(result.index.get_level_values('report_date')[2], result.index.get_level_values('report_date')[-1])
        fig.set_facecolor('w')


