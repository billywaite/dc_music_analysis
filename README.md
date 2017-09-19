# Washington D.C. Historical Analysis

This is a repo for an analysis I am conducting on historical concert data for all major music venues in Washington D.C.

### Getting Started

1. Collecting the initial data - Scripts in the scraping folder
2. Cleaning and consolidating the scraped data - Scripts in the cleaning folder
3. Initial analysis - Dropped the data in Tableau for some quick visualizations
4. Next step is to work with the Spotify API to add genre + popularity

### Initial visualizations

Visualization of each venue's proportion of concerts by year

![Proportion of Concerts by Venue](/visualizations/area-chart.png?raw=true)
___

Same data as above, visualized as a heatmap

   Found a whole in the data with this visualization, need to figure out why Soundeck on Saturday's doesn't have data.

![Heatmap of Concerts by Day](/visualizations/heatmap.png?raw=true)
___

Stacked bar chart to the number of concerts by venue and day

![Number of concerts by day and venue](/visualizations/stacked-bar.png?raw=true)
