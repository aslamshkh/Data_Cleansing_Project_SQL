# DataAnalysis_Project_SQL

## The table of contents

- [Project Overview](#project-overview)
- [Data Source](#data-source)
- [Tools](#tools)
- [Data Cleaning/Preparation](#sata-cleaning/preparation)
- [Exploratory Data Analysis (EDA)](#exploratory-data-analysis-(EDA))
- [Data Analysis](#data-analysis)
- [Results/Findings](#results/findings)
- [Recommendations](#recommendations)
- [Limitations](#limitations)
- [Referencing](#referencing)

### Project Overview

This data analysis project aims to provide insights into the sale performance of an e-Commers company over the past year. By analysing various aspects of the sales data, we seek to identify trends, make data driven recommendations, and gain understanding of the company's preference. 

### Data Source

The dataset used in this project is "sales_data.csv" containing data  about the sales made by the company.


### Tools

- Excel:      Data Cleaning [Click Here](https://github.com/aslamshaikhisdi/SQL-Portfolio-Project/edit/updatefile/README.md)
- SQL Server: Data Analysis
- PowerBI:    Report

### Data Cleaning/Preparation

#### Following steps were followed at the initial data preparation stage.

Data loading and inspection
Handling missing volume
Data cleaning and formatting

### Exploratory Data Analysis (EDA)

#### EDA involves data exploration to understand the data to answer the key questions.

1. What the overall sales trend?
2. Which products are the top sale?
3. What are the peak sales period?

### Data Analysis

#### Following codes were used to perform some of the important steps.

```sql
SELECT * FROM table
WHERE code = 2;
```

### Results/Findings

#### The analysis of the data gives the following insights

- The sales has been trending upwards over the year with the holiday peak time.
- Christmas makes the best time of the year with the highest sale increase. 
- Product category "A" is the top selling category. 

### Recommendations

#### Following are the recommendations based on the analysis.

- Investment in marketing and promotion in off peak time to promote more incoming. 
- Holidays season doesn't require any change in marketing as it is going to get sales as season shopping.
- Discounts must be introduced in peak and non peak seasons with a small variation but huge discounts be given at the non peak ours to increase the sales.


### Limitations

I had to remove all the zero values from the budget and revenue columns because they would have affected the accuracy of the conclusion from the analysis. There are still a few outlier after being omitted/ However, even then we have seen a positive collaboration between budget and number of votes with revenue. 


### Referencing

1. SQL for Business by Werty.
2. [STACK OVERFLOW](https://stack.com)
