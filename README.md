# Brazilian Employment Data Analysis

This is a small exercise using R to understand the behaviour of the Brazilian labor market for the past 5 years and a half.

## About the data

The data used here comes CAGED microdata, hosted on a private PostgreSQL Server.
CAGED stands for General Registry of Employed and Unemployed, in a free translation (original: Cagastro Geral de Empregados e Desempregados). It stores each hiring and each separation on formal jobs, countrywide, monthly. Several variables are available, such as economic activity of the company, education level of the person, and city.

For this work, I'll use only the average monthly wage and the number of people hired or separated in a given month.

## Brazilian Labor Market

Looking at the cummulative net hires since January 2012, Brazilian labor market has receded to a level below the one registered in the start of the shown series. In fact, the expansion observed in 2.5 years was lost in just a year, with November 2016 at the same level as January 2012.

![Labor Market Behaviour](/02_images/CummulativeNetHires.png 'Labor Market Behaviour')

In the past months, however, we are able to see a stabilization of this number, with a few small but positive results in net hiring.

Below we can see that the level of both hires and separations has lowered significantly in the past 2 years or so, leaving the 170,000 movements for each type in 2012 through middle 2015, to a 120,000 movements level. This almost 30% decrase in movements shows a dire consequence of our current economic and political crisis, which is the cool down of economic activity.

![Labor Market Behaviour](/02_images/LaborMarketBehaviour.png 'Labor Market Behaviour')

On the bottom part of the chart we can also see the last two years of negative net hiring (when more people are fired or ask to quit than people being hired). We can also see a seasonal component every end of year, with heavy losses on net hiring.

## Wages

The difference on the average wage between those being hired to those being separated is rising consistently for the past years. The values presented below are in BRL of July 2017, inflated by IPCA (Broad Consumer Price Index - IBGE).

![Wage Behaviour](/02_images/WageBehaviour.png 'Wage Behaviour')
