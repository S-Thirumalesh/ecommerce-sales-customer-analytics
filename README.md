\# E-Commerce Sales \& Customer Analytics Dashboard



This project follows a complete analytics workflow, from preparing the

data to sharing business recommendations:



\*\*Data → SQL → Excel validation → Python analysis → Power BI dashboard →

Insights → Business recommendations\*\*



> \*\*About the data:\*\* This project uses the Sample Superstore dataset, a

> fictional-store dataset originally provided as Tableau sample data. I

> used the copy available on

> \[Kaggle](https://www.kaggle.com/datasets/vivek468/superstore-dataset-final).

> These records do not belong to a real company. The licence for this

> Kaggle copy is unclear, so I have not included the original raw file

> in this repository. The processed files are included to make the

> analysis reproducible. The dataset does not specify a currency, so I

> have not used a currency symbol in the project.



!\[Executive overview page](images/powerbi\_p1\_executive\_overview.png)



\---



\## 1. Project Overview



For this project, I took the role of a data analyst working with an

e-commerce business. The goal was to understand its sales, revenue,

profit, products, regions, customers, average order value and sales

patterns over time. I also wanted to identify areas that may need

attention.



I cleaned the data using MySQL, independently checked the results in

Excel, carried out the analysis in Python and created a four-page

dashboard in Power BI.



Two important findings stood out: order lines with very high discounts

were associated with losses, and Furniture generated a large share of

sales but a much smaller share of profit. These are patterns in the

sample data; they should not be treated as proof that one factor caused

another.



\## 2. Business Problem



Management needs a clearer picture of the business and wants answers to

a few practical questions:



\-   Which parts of the business make money, and which parts lose money?

\-   Which products, categories and regions need attention?

\-   During which periods are sales highest?

\-   Which customers are valuable, and which customers may be becoming

&#x20;   inactive?

\-   What actions should management consider based on the data?



\## 3. Project Objectives



The project was planned around the following objectives:



\-   Clean and validate the data, then confirm that the totals match

&#x20;   across SQL, Excel, Python and Power BI.

\-   Analyse sales, profit, products, regions, discounts and seasonality.

\-   Segment customers using a simple and explainable RFM approach.

\-   Build a four-page Power BI dashboard using a proper data model.

\-   Make recommendations that are supported by the analysis, while being

&#x20;   clear about the limitations of the data.



\## 4. Dataset



The analysis uses the Sample Superstore dataset.



| Item | Details |

|---|---|

| Source | Sample Superstore (Tableau sample data), using the \[Kaggle copy](https://www.kaggle.com/datasets/vivek468/superstore-dataset-final) |

| Raw data | 9,994 order lines and 21 columns |

| Period | Orders from 2014-01-03 to 2017-12-30, all from the United States |

| After cleaning | 9,993 order lines, 5,009 orders, 793 customers, 1,850 product names (1,894 name-and-ID pairs) |

| Currency | Not specified in the source file; no currency symbol is used |

| Information not available | Cost price, customer sign-up date and churn label |



The original dataset contains these 21 columns: Row ID, Order ID, Order

Date, Ship Date, Ship Mode, Customer ID, Customer Name, Segment,

Country, City, State, Postal Code, Region, Product ID, Category,

Sub-Category, Product Name, Sales, Quantity, Discount and Profit.



Discount is stored as a fraction, so `0.2` represents 20%. Profit can be

negative.



\## 5. Technologies Used



\-   \*\*MySQL Server 8.0.45 and MySQL Workbench:\*\* Used to create the

&#x20;   staging and clean tables and run 15 business analysis queries.

\-   \*\*Microsoft Excel:\*\* Used Power Query and pivot tables to

&#x20;   independently validate the SQL results.

\-   \*\*Python 3.12.10:\*\* Used pandas 3.1.0, numpy 2.5.4, matplotlib

&#x20;   3.11.2, seaborn 0.13.2, SciPy (version pinned in `requirements.txt`)

&#x20;   and Jupyter Notebook 7.6.3 for data preparation and analysis.

\-   \*\*Power BI Desktop:\*\* Used Power Query, the data model and DAX to

&#x20;   build the dashboard.

\-   \*\*Git 2.55.0 and GitHub:\*\* Used for version control.



\## 6. Project Architecture



The project moves through the following stages:



```text

Raw CSV

&#x20; → MySQL staging table (all text, kept untouched)

&#x20; → MySQL clean tables (customers, products, orders, order\_items)

&#x20; → SQL business analysis (15 queries)

&#x20; → Flat CSV export → Excel validation (Power Query, pivots)

&#x20; → Python: cleaning, EDA, statistics, customer (RFM) and product analysis

&#x20; → Power BI star-schema model (Sales, Customers, Products, Calendar)

&#x20; → Four-page dashboard → insights and recommendations

```



In the Power BI model, `Sales` is the fact table, with one row for each

order line. `Customers`, `Products` and `Calendar` are lookup tables.

They use one-to-many relationships with a single filter direction.



Region, state and city remain in `Sales`. A customer can place orders

from more than one region: 778 of the 793 customers in this dataset

ordered from more than one state.



!\[Power BI data model](images/powerbi\_data\_model.png)



\## 7. Data Cleaning



I first loaded the original data into an all-text staging table and kept

that table unchanged. The cleaning was done when the data was moved into

the typed tables.



During the checks, I found and handled the following issues:



\-   \*\*Hidden spaces:\*\* 225 rows contained non-breaking spaces in the

&#x20;   Product Name field. They look like ordinary spaces but use a

&#x20;   different byte code (`C2A0`). I replaced them with normal spaces in

&#x20;   the clean tables only.

\-   \*\*Repeated order line:\*\* Row ID 3407 was identical to Row ID 3406 in

&#x20;   every field except the ID. I excluded Row ID 3407 from the clean

&#x20;   tables. This is an assumption. Compared with the raw data, this

&#x20;   changes sales by −281.372 and profit by +12.0588.

\-   \*\*Reused Product IDs:\*\* 32 Product IDs were associated with two

&#x20;   completely different product names. For that reason, I do not

&#x20;   identify products using Product ID alone.

\-   \*\*Postal codes:\*\* 438 postal codes had only four digits because the

&#x20;   leading zero was missing from the file. All of these were in six

&#x20;   north-eastern states. I padded them to five digits in Python.



I kept records with negative profit because they represent real losses

in the dataset. I also kept very large sales values rather than treating

them as errors.



\*\*Validation:\*\* Total sales of 2,296,919.49 and total profit of

286,409.08 match across SQL, Excel, Python and Power BI. The only

intentional difference from the raw data is the removal of the one

repeated order line.



\## 8. SQL Analysis



The SQL scripts are available in the `sql/` folder.



| File | What it does |

|---|---|

| `01\_create\_staging\_table.sql` | Creates the staging table with 21 text columns |

| `02\_load\_staging\_data.sql` | Loads the data using `LOAD DATA INFILE` |

| `03\_data\_quality\_checks.sql` | Checks blanks, ranges, dates, duplicates and consistency |

| `04\_investigate\_issues.sql` | Investigates hidden characters, repeated rows and the 32 reused Product IDs |

| `05\_create\_clean\_tables.sql` | Creates the `customers`, `products`, `orders` and `order\_items` tables |

| `06\_load\_clean\_tables.sql` | Loads the clean tables |

| `07\_business\_analysis.sql` | Runs 15 business analysis queries |



The 15 business queries cover KPIs, yearly growth using `LAG`, monthly

sales, seasonality, category and sub-category performance, top and

bottom products, loss-making products, regions, states, top customers,

orders per customer, average spend per customer and profit margin by

discount level.



\*\*Excel validation:\*\* I recreated the same KPIs, pivot tables and charts

using the exported data in `excel/ecommerce\_analysis.xlsx`. The values

matched the SQL results. The validation details are recorded in

`excel/validation\_notes.md`.



!\[Excel pivot by category and region](images/excel\_pivot\_category\_region.png)



\## 9. Exploratory Data Analysis



I created ten charts in `notebooks/03\_eda.ipynb`. They are also saved in

the `images/` folder as `eda\_01` to `eda\_10`.



The charts cover yearly sales and profit, monthly sales, seasonality,

category performance, sub-category profit, regions, the top 10 products,

margin by discount level, the top 10 customers and customer type.



The statistical analysis is in `notebooks/04\_statistics.ipynb`. Some of

the main results are:



\-   \*\*Order value:\*\* The mean order value is 458.56, while the median is

&#x20;   151.96. A small number of large orders pull the average upwards.

\-   \*\*Customer spending:\*\* The mean customer spend is 2,896.49 and the

&#x20;   median is 2,256.39. The top 10% of customers (79 customers) account

&#x20;   for 30.62% of sales.

\-   \*\*Discount and profit:\*\* The Spearman correlation is −0.543. A

&#x20;   Mann-Whitney test comparing lines with no discount against lines

&#x20;   with a discount of 30% or more produced an extremely small p-value.

&#x20;   A randomly selected line with no discount had a higher profit than a

&#x20;   randomly selected line with a 30%+ discount 98.5% of the time.

\-   \*\*Interpretation:\*\* This is an association, not proof of cause.



!\[Distributions](images/stats\_01\_distributions.png)



!\[Correlation](images/stats\_02\_correlation.png)



\## 10. Customer Analysis



I used RFM analysis in `notebooks/05\_customer\_analysis.ipynb` to group

customers.



RFM stands for:



\-   \*\*Recency:\*\* Number of days since the customer's last order, using

&#x20;   2017-12-31 as "today".

\-   \*\*Frequency:\*\* Number of orders placed.

\-   \*\*Monetary:\*\* Total sales.



Recency and Monetary are divided into five equal groups. Frequency uses

fixed order-count groups: 1-3, 4-5, 6-7, 8-9 and 10 or more. This

means customers with the same number of orders receive the same

Frequency score.



The segment rules are my own and are documented in the notebook. The

dataset does not contain a churn label, so the term "Inactive" only

means that a customer has not purchased for a long time. It does not

confirm that the customer has churned.



| Segment | Customers | Share of sales | Profit | Margin | Customers losing money |

|---|---:|---:|---:|---:|---:|

| Loyal | 199 | 28.86% | 70,027.46 | 10.57% | 40 |

| Champions | 130 | 23.68% | 70,798.03 | 13.01% | 15 |

| At Risk | 135 | 20.64% | 78,293.55 | 16.52% | 16 |

| Inactive | 181 | 13.42% | 32,016.87 | 10.39% | 54 |

| Promising | 91 | 7.23% | 25,417.20 | 15.30% | 18 |

| Needs Attention | 57 | 6.17% | 9,855.96 | 6.95% | 12 |



A few additional observations:



\-   155 of the 793 customers (about 19.5%) have negative total profit.

\-   The store's customer types show similar patterns: Consumer has 409

&#x20;   customers and an 11.55% margin, Corporate has 236 customers and a

&#x20;   13.03% margin, and Home Office has 148 customers and a 14.05%

&#x20;   margin.

\-   Sales per customer range from 2,839.61 to 2,992.15.



!\[RFM segments](images/customer\_01\_rfm\_segments.png)



\## 11. Product Analysis



The product analysis is in `notebooks/06\_product\_analysis.ipynb`.



\*\*How products are counted:\*\* I analysed products by product name (1,850

products) and also by name-and-ID pair (1,894 pairs). The top 20

products by sales and the 20 biggest loss-making products were the same

under both methods.



There are 16 names associated with more than one Product ID, covering

314 lines. These have the same category and sub-category. One limitation

is that some names are generic, such as "Staples", so grouping by name

may combine different items. The effect on the totals is small.



Other findings:



\-   \*\*Sub-category performance:\*\* Copiers (37.20% margin) and Paper

&#x20;   (43.39% margin) earn well relative to their sales. Tables (−8.56%),

&#x20;   Bookcases (−3.02%) and Supplies (−2.55%) lose money overall.

&#x20;   Machines generate 189,238.63 in sales but have a margin of only

&#x20;   1.79%.

\-   \*\*Sales concentration:\*\* 136 products (7.4%) account for 50% of

&#x20;   sales, while 420 products (22.7%) account for 80%. The top 10

&#x20;   products contribute 10.65% of sales.

\-   \*\*Loss-making products:\*\* 299 of the 1,850 products make an overall

&#x20;   loss. Together, they account for 23.96% of sales and have a margin

&#x20;   of −14.00%. A discount of 30% or more appears on 36.72% of their

&#x20;   order lines, compared with 9.66% for the other products.



!\[Sub-category matrix](images/product\_01\_subcategory\_matrix.png)



!\[Sales concentration](images/product\_02\_sales\_concentration.png)



\## 12. Sales \& Revenue Analysis



The yearly sales and profit figures show how the business performed from

2014 to 2017.



| Year | Sales | Profit | Margin | Sales growth |

|---|---:|---:|---:|---:|

| 2014 | 483,966.13 | 49,556.03 | 10.24% | - |

| 2015 | 470,532.51 | 61,618.60 | 13.10% | −2.78% |

| 2016 | 609,205.60 | 81,795.17 | 13.43% | +29.47% |

| 2017 | 733,215.26 | 93,439.27 | 12.74% | +20.36% |



\*\*Overall performance\*\*



| Measure | Value |

|---|---:|

| Sales | 2,296,919.49 |

| Profit | 286,409.08 |

| Profit margin | 12.47% |

| Orders / customers | 5,009 / 793 |

| Average order value | 458.56 |



\*\*Performance by category\*\*



| Category | Sales | Profit | Margin |

|---|---:|---:|---:|

| Technology | 836,154.03 | 145,454.95 | 17.40% |

| Furniture | 741,718.42 | 18,463.33 | 2.49% |

| Office Supplies | 719,047.03 | 122,490.80 | 17.04% |



\*\*Performance by region\*\*



| Region | Sales | Profit | Margin |

|---|---:|---:|---:|

| West | 725,457.82 | 108,418.45 | 14.94% |

| East | 678,499.87 | 91,534.84 | 13.49% |

| Central | 501,239.89 | 39,706.36 | 7.92% |

| South | 391,721.91 | 46,749.43 | 11.93% |



\*\*Seasonality:\*\* September, November and December were the top three

months in every year. Together, these months contributed 47.5% of sales

in 2014, 45.7% in 2015, 41.0% in 2016 and 39.6% in 2017. January and

February were the weakest months.



\## 13. Power BI Dashboard



The Power BI file is available at

`dashboard/ecommerce\_sales\_dashboard.pbix`. I have also saved the DAX as

text in `dashboard/dax\_measures.txt`, which contains 18 measures and 2

calculated columns.



The dashboard has four pages:



| Page | Main question | What's included |

|---|---|---|

| 1. Executive Overview | How is the business doing? | KPI cards, monthly trend, category, region and top 10 products |

| 2. Trends \& Regions | When and where do we sell? | Yearly growth, month-by-year, share of year, regional margin and discounts |

| 3. Products \& Discounts | Which products sell but do not earn? | Sub-category matrix, margin by discount group, best and worst products |

| 4. Customers | Who is valuable, and who may be slipping? | RFM segments, top and bottom customers by profit |



Page 4 does not have a year slicer because the RFM groups were

calculated once using all four years of data.



!\[Page 2](images/powerbi\_p2\_trends\_regions.png)



!\[Page 3](images/powerbi\_p3\_products\_discounts.png)



!\[Page 4](images/powerbi\_p4\_customers.png)



\## 14. Key Business Insights



The following points summarise the main patterns found in the sample

data. They show relationships in the data, not proven causes.



1\.  \*\*Furniture has high sales but low profit.\*\* Furniture accounts for

&#x20;   32.3% of sales but only 6.5% of profit. Its margin is 2.49%,

&#x20;   compared with about 17% for the other two categories. Tables

&#x20;   (−17,725.48) and Bookcases (−3,472.56) make losses, while Chairs

&#x20;   (+26,602.23) and Furnishings (+13,059.14) make profits.



2\.  \*\*High discounts are associated with losses.\*\* Order lines with a

&#x20;   discount of 30% or more make up 13.93% of all lines and 15.8% of

&#x20;   sales (362,488.78), but they recorded a loss of 135,364.00, with a

&#x20;   margin of −37.34%. A total of 96.77% of these lines make a loss. By

&#x20;   comparison, lines with no discount have a margin of 29.51%. This

&#x20;   pattern appears in every category and region. However, the dataset

&#x20;   does not include cost price, so it cannot prove that discounts cause

&#x20;   the losses.



3\.  \*\*Discounts are not the only factor linked to losses.\*\* Supplies

&#x20;   makes a loss (−1,189.10) even though none of its lines have a

&#x20;   discount of 30% or more. Binders, where 40.25% of lines have a

&#x20;   discount of 30% or more, and Chairs, where the figure is 25.49%, are

&#x20;   still profitable overall.



4\.  \*\*The Central region has good sales but a low margin.\*\* Its margin

&#x20;   is 7.92%. Central has 643 of the 1,392 heavily discounted lines, and

&#x20;   27.7% of its own lines have a discount of 30% or more. The

&#x20;   comparable figure for West is 3.7%. Central's margin on lines with

&#x20;   no discount is 31.31%, which is not lower than the other regions

&#x20;   (26.65% to 30.84%). This suggests that the higher share of heavily

&#x20;   discounted lines may be linked to the lower margin, but it does not

&#x20;   prove the reason.



5\.  \*\*Sales are strongest from September to December.\*\* Stock, delivery

&#x20;   and promotions can be planned ahead for this period. January and

&#x20;   February are the weakest months.



6\.  \*\*Sales increased, but the margin did not keep improving.\*\* Sales

&#x20;   fell by 2.78% in 2015, then increased by 29.47% in 2016 and 20.36%

&#x20;   in 2017. The margin reached 13.43% in 2016 and then slipped slightly

&#x20;   to 12.74% in 2017. The average discount remained almost unchanged

&#x20;   each year, at about 16%.



7\.  \*\*The best-selling products are not always profitable.\*\* Seven of

&#x20;   the 20 best-selling products make an overall loss, and 12 have a

&#x20;   margin below the company-wide margin. The Cisco TelePresence System

&#x20;   EX90 ranks third by sales but recorded a loss of 1,811.08.



8\.  \*\*Champions and Loyal customers form the core customer groups.\*\*

&#x20;   Together, they represent 41.5% of customers and 52.54% of sales. The

&#x20;   At Risk group has 135 customers, whose last order was about 221 days

&#x20;   ago on average. Despite the label, this group has the highest total

&#x20;   profit of all segments (78,293.55) and the best margin (16.52%).



9\.  \*\*Even a Champion customer can be loss-making.\*\* The 10 customers

&#x20;   with the biggest losses account for a combined loss of 30,265.47,

&#x20;   which is about 10.6% of company profit. RFM describes customer

&#x20;   buying behaviour; it does not measure how profitable each customer

&#x20;   is to the business.



\## 15. Business Recommendations



The recommendations below are based on the findings above. The

limitations are included so that the results are not overstated.



| Recommendation | Evidence | What the data cannot tell us |

|---|---|---|

| Review discounts of 30% or more. For example, consider an approval rule or a cap. | Insight 2: a loss of 135,364.00 across 1,392 lines | Why the discounts were given or what the cost price was |

| Review pricing and discounts for Tables, Bookcases and Machines. | Tables: 55.17% of lines have a discount of 30% or more and profit is −17,725.48; Machines have a margin of 1.79% | Supplies loses money without heavy discounts, so costs and product mix may also matter |

| Review discount practices in the Central region. | Insight 4 | The data shows a pattern, not a proven cause |

| Plan stock and delivery ahead of September to December; test offers in January and February. | Insight 5 | The analysis covers only four years of sample data |

| Contact At Risk customers with a reminder or personal follow-up rather than immediately offering a deep discount. | 135 customers, 20.64% of sales and the highest segment profit | Their usual gap between orders is unknown, so the data cannot confirm that they are leaving |

| Rank products and customers using profit as well as sales. | Insights 7 and 9 | - |



The 135,364.00 loss on heavily discounted lines gives an idea of the

scale of the issue. It should not be treated as guaranteed savings: some

discounted orders may have generated sales that would not otherwise have

happened.



\## 16. Project Structure



```text

ecommerce-sales-customer-analytics/

├── data/

│   └── processed/        sales\_flat\_clean.csv, sales\_analysis\_ready.csv, customer\_rfm.csv

├── sql/                  01 to 07 SQL scripts

├── excel/                ecommerce\_analysis.xlsx, validation\_notes.md

├── notebooks/            01\_data\_overview, 02\_data\_cleaning, 03\_eda,

│                         04\_statistics, 05\_customer\_analysis, 06\_product\_analysis

├── dashboard/            ecommerce\_sales\_dashboard.pbix, dax\_measures.txt

├── images/               charts and screenshots

├── .gitignore

├── requirements.txt

└── README.md

```



The `data/raw/` folder is kept only on my computer and is ignored by

Git.



\## 17. How to Run the Project



Follow these steps if you want to reproduce the analysis from the

beginning.



1\.  \*\*Download the raw dataset (only required for a full rebuild).\*\*

&#x20;   Download it from the \[Kaggle dataset

&#x20;   page](https://www.kaggle.com/datasets/vivek468/superstore-dataset-final)

&#x20;   and save it as `data/raw/Sample - Superstore.csv`.



2\.  \*\*Run the SQL scripts (optional).\*\* The processed files are already

&#x20;   included in the repository. If you want to rebuild the SQL tables,

&#x20;   run scripts `01` to `07` in order using MySQL Workbench. Check the

&#x20;   folder shown by `SHOW VARIABLES LIKE 'secure\_file\_priv';`, place the

&#x20;   CSV there and update the file path in `02\_load\_staging\_data.sql`.



3\.  \*\*Set up Python.\*\* From the project folder, run these commands in

&#x20;   Windows Command Prompt:



&#x20;   ```bat

&#x20;   python -m venv .venv

&#x20;   .venv\\Scripts\\activate

&#x20;   pip install -r requirements.txt

&#x20;   jupyter notebook

&#x20;   ```



&#x20;   Open the notebooks in the `notebooks/` folder in numeric order. For

&#x20;   each notebook, use \*\*Kernel → Restart \& Run All\*\*.



4\.  \*\*Open the Power BI dashboard.\*\* Open

&#x20;   `dashboard/ecommerce\_sales\_dashboard.pbix`. If Power BI reports that

&#x20;   a file is missing, go to \*\*Home → Transform data → Data source

&#x20;   settings → Change source\*\* and select the CSV files in

&#x20;   `data/processed/`.



\## 18. Results



The final results are summarised below.



| Measure | Result |

|---|---:|

| Total sales | 2,296,919.49 |

| Total profit | 286,409.08 |

| Profit margin | 12.47% |

| Orders | 5,009 |

| Customers | 793 |

| Average order value | 458.56 |

| Sales and profit match across | SQL, Excel, Python and Power BI |

| Loss-making products | 299 of 1,850 |

| Customers with negative total profit | 155 of 793 |



\*\*Limitations of this analysis:\*\* The dataset is sample data from a

fictional store. It does not include cost price, a stated currency or a

churn label. The findings show associations, not proven causes. The RFM

segments use rules I defined, and products are counted by name (see

Section 11).



\## 19. Future Improvements



There are several ways this project could be extended:



\-   Add cost-price data to investigate why heavily discounted order

&#x20;   lines lose money.

\-   Analyse each customer's usual gap between orders to make the At Risk

&#x20;   classification more meaningful.

\-   Test discount rules through a small controlled trial before making

&#x20;   changes.

\-   Optionally, try K-Means as another way to group customers and

&#x20;   compare the results with RFM.

\-   Optionally, connect Power BI directly to the MySQL database instead

&#x20;   of using CSV files.



\## Credits and Author



\-   \*\*Dataset:\*\* Sample Superstore (Tableau sample data), using the

&#x20;   Kaggle copy linked above. The data belongs to its original source.

\-   \*\*Author:\*\* Thirumalesh, \[github.com/S-Thirumalesh](https://github.com/S-Thirumalesh)

