#!/usr/bin/env python3
#
#   readsProcessing_report.py
#
import argparse
import pandas as pd
import matplotlib.pyplot as plt
from matplotlib import cm
from math import log10
import collections


def radial_piechart(df_a, df_b, label, params, colors):

    #create figure, axis
    fig, ax = plt.subplots()
    ax.axis("equal")

    #create rings of donut chart
    for i in range(params['n_points']):
        #hide labels in segments with textprops: alpha = 0 - transparent, alpha = 1 - visible
        r = params['radius'] - i * params['ring_with']
        innerring, _ = ax.pie([params['m_max'] - df_a[i], df_a[i]], radius = r, startangle = 90, labels = ["", label[i]], labeldistance = 1 - 1 / (1.5 * (params['n_points'] - i)), textprops = {"alpha": 0}, colors = ["white", colors[i]])
        ax.text(0, r - params['ring_with'] / 2, f'{label[i]} – {int(df_b[i])}% ', ha='right', va='center')
        plt.setp(innerring, width = params['ring_with'], edgecolor = "white")
    plt.legend()
    plt.savefig('percent_reads.png')

def plot_params(df_plot):

    #number of data points
    n = len(df_plot)
    #find max value for full ring
    k = 10 ** int(log10(max(df_plot)))
    m = k * (1 + max(df_plot) // k)

    #radius of donut chart
    r = 1.5
    r_inner = 0.4
    #calculate width of each ring
    w = (r - r_inner) / n 

    # gather parameters
    pie_params = collections.defaultdict(int)
    pie_params['n_points']      = n
    pie_params['k_max']         = k
    pie_params['m_max']         = m
    pie_params['radius']        = r
    pie_params['radius_inner']  = r_inner
    pie_params['ring_with']     = w

    return pie_params


def radial_pie(df):
    # Set data features/cathegories
    labels = [
        'Total', 
        'Filtradas',
        'No alineadas',
        'Alineadas'
        ]
    
    # Compute global mean
    
    
    df_mean = [
        pd.to_numeric(df['r_processed'], errors='coerce').mean(),
        pd.to_numeric(df['r_written'], errors='coerce').mean(),
        pd.to_numeric(df['unmapped'], errors='coerce').mean(),
        pd.to_numeric(df['mapped'], errors='coerce').mean()
        ]
    # Compute percents over the mean
    df_percent = [ i/df_mean[0]*100 for i in df_mean ]
    print(type(df['r_processed']))
    print(type(df['r_written']))
    print(type(df['unmapped']))
    print(type(df['mapped']))
    print(df_mean)
    print(df_percent)

    # Set up graph parameters and plot it: sourced from [https://stackoverflow.com/questions/49729748/create-a-circular-barplot-in-python]
    cols = [
        '#404040',
        '#8c8c8c',
        '#3366ff',
        '#00b33c'
    ]

    # Create a radial pie chart
    radial_piechart(df_a = df_mean, df_b = df_percent, label = labels, params = plot_params(df_mean), colors = cols)
