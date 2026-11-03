\# E-Commerce Sales \& Customer Analytics Dashboard



An end-to-end analytics project: \*\*Data → SQL → Excel check → Python analysis → Power BI dashboard → Insights → Business recommendations.\*\*



> \*\*This is sample data.\*\* The data is the well-known \*Sample Superstore\* dataset (Tableau sample data) of a made-up store. I used the Kaggle copy: <https://www.kaggle.com/datasets/vivek468/superstore-dataset-final>. It is \*\*not\*\* a real company's records. The license of this copy is not clear, so the original raw file is \*\*not\*\* included in this repository. The processed files are included so the analysis can be reproduced. The file does not state a currency, so no currency symbol is used anywhere in this project.



!\[Executive overview page](images/powerbi\_p1\_executive\_overview.png)



\---



\## 1. Project Overview



I acted as an analyst for an e-commerce company that wants to understand its revenue, sales over time, best products and categories, valuable customers, regions, average order value, customer groups, seasonality, and what needs attention. I cleaned the data in MySQL, checked it independently in Excel, analysed it in Python, and built a 4-page Power BI dashboard. The main finding is that heavily discounted order lines lose money, and that Furniture sells a lot but earns very little. All findings are patterns in sample data, not proven causes.



\## 2. Business Problem



Management wants to know:

\- Where does the business make money, and where does it lose money?

\- Which products, categories and regions need attention?

\- When do we sell the most?

\- Who are the valuable customers, and who may be slipping away?

\- What should management do next?



\## 3. Objectives



\- Clean and check the data, and prove that the totals agree across SQL, Excel, Python and Power BI.

\- Study sales, profit, products, regions, discounts and seasonality.

\- Group customers with a simple, explainable RFM method.

\- Build a 4-page Power BI dashboard on a proper data model.

\- Give recommendations based only on what the data shows, and state the limits.



\## 4. Dataset



| Item | Value |

|---|---|

| Source | Sample Superstore (Tableau sample data), Kaggle copy (link above) |

| Raw file | 9,994 order lines, 21 columns |

| Period | Orders from 2014-01-03 to 2017-12-30, all in the United States |

| After cleaning | 9,993 order lines, 5,009 orders, 793 customers, 1,850 product names (1,894 name-and-ID pairs) |

| Currency | Not stated in the file (no currency symbol used) |

| Not in the data | Cost price, customer sign-up date, churn label |



The 21 original columns are: Row ID, Order ID, Order Date, Ship Date, Ship Mode, Customer ID, Customer Name, Segment, Country, City, State, Postal Code, Region, Product ID, Category, Sub-Category, Product Name, Sales, Quantity, Discount, Profit. Discount is a fraction (0.2 means 20%). Profit can be negative.



\## 5. Technologies Used



\- \*\*MySQL Server 8.0.45\*\* and MySQL Workbench: staging table, clean tables, 15 business queries

\- \*\*Microsoft Excel\*\*: Power Query, pivot tables, an independent check of the SQL numbers

\- \*\*Python 3.12.10\*\*: pandas 3.1.0, numpy 2.5.4, matplotlib 3.11.2, seaborn 0.13.2, SciPy (version pinned in `requirements.txt`), Jupyter Notebook 7.6.3

\- \*\*Power BI Desktop\*\*: Power Query, data model, DAX

\- \*\*Git 2.55.0 and GitHub\*\*: version control



\## 6. Project Architecture



```

Raw CSV

&#x20; → MySQL staging table (all text, kept untouched)

&#x20; → MySQL clean tables (customers, products, orders, order\_items)

&#x20; → SQL business analysis (15 queries)

&#x20; → Flat CSV export  → Excel check (Power Query, pivots)

&#x20; → Python: cleaning, EDA, statistics, customer (RFM) and product analysis

&#x20; → Power BI star-schema model (Sales, Customers, Products, Calendar)

&#x20; → 4-page dashboard → insights and recommendations

```



Power BI data model: `Sales` is the fact table (one row per order line). `Customers`, `Products` and `Calendar` are lookup tables with one-to-many relationships and a single filter direction. Region, state and city stay in `Sales`, because a customer can order from several regions (778 of 793 customers ordered from more than one state).



!\[Power BI data model](images/powerbi\_data\_model.png)



\## 7. Data Cleaning



\- Loaded the raw data into an \*\*all-text staging table\*\* first and kept it untouched. Cleaning happened when moving to typed tables.

\- Found \*\*hidden non-breaking spaces\*\* in 225 rows, all in Product Name (they look like a space but have a different byte code, `C2A0`). Replaced them with normal spaces in the clean tables only.

\- Found \*\*one repeated order line\*\*: Row ID 3407 is identical to Row ID 3406 in every field except the ID. I left it out of the clean tables. \*\*This is an assumption.\*\* Effect compared with the raw data: sales −281.372 and profit +12.0588.

\- Found \*\*32 Product IDs that each carry two completely different product names\*\*. Because of this, products are never identified by Product ID alone.

\- Found \*\*438 postal codes with four digits\*\* (leading zero lost in the file, all in six north-eastern states). Padded them to five digits in Python.

\- Kept lines with negative profit (real losses) and very large sales (real big orders).

\- \*\*Reconciliation:\*\* total sales 2,296,919.49 and total profit 286,409.08 match in SQL, Excel, Python and Power BI. The only intended difference to the raw data is the one repeated line.



\## 8. SQL Analysis



Scripts are in `sql/`:



| File | Purpose |

|---|---|

| `01\_create\_staging\_table.sql` | Staging table (21 text columns) |

| `02\_load\_staging\_data.sql` | `LOAD DATA INFILE` |

| `03\_data\_quality\_checks.sql` | Blanks, ranges, dates, duplicates, consistency |

| `04\_investigate\_issues.sql` | Hidden characters, repeated rows, 32 reused Product IDs |

| `05\_create\_clean\_tables.sql` | `customers`, `products`, `orders`, `order\_items` |

| `06\_load\_clean\_tables.sql` | Loads the clean tables |

| `07\_business\_analysis.sql` | 15 business queries |



The 15 queries cover KPIs, yearly growth (with `LAG`), monthly sales, seasonality, category and sub-category performance, top and bottom products, loss-making products, regions, states, top customers, orders per customer, average spend per customer, and margin by discount level.



\*\*Excel check:\*\* the same KPIs, pivot tables and charts were built from the exported data in `excel/ecommerce\_analysis.xlsx`. All values matched the SQL results (`excel/validation\_notes.md`).



!\[Excel pivot by category and region](images/excel\_pivot\_category\_region.png)



\## 9. Exploratory Data Analysis



Ten charts are in `notebooks/03\_eda.ipynb` and saved in `images/` as `eda\_01` to `eda\_10`: yearly sales and profit, monthly sales, seasonality, category, sub-category profit, region, top 10 products, margin by discount level, top 10 customers, and customer type.



\*\*Statistics\*\* (`notebooks/04\_statistics.ipynb`):

\- The average order is pulled up by a few big orders: mean order value 458.56, median 151.96.

\- Customer spending is skewed too: mean 2,896.49, median 2,256.39. The top 10% of customers (79 customers) give 30.62% of sales.

\- Discount and profit are linked: Spearman correlation −0.543. A Mann-Whitney test between no-discount lines and lines with 30% or more discount gave an extremely small p-value. A random no-discount line had a higher profit than a random 30%+ line 98.5% of the time.

\- This is an \*\*association, not proof of cause\*\*.



!\[Distributions](images/stats\_01\_distributions.png)

!\[Correlation](images/stats\_02\_correlation.png)



\## 10. Customer Analysis



\*\*RFM\*\* (`notebooks/05\_customer\_analysis.ipynb`): Recency (days since last order, with 2017-12-31 as "today"), Frequency (number of orders) and Monetary (total sales). Recency and Monetary use five equal groups. Frequency uses fixed groups of orders (1-3, 4-5, 6-7, 8-9, 10 or more), so customers with the same number of orders get the same score. The segment rules are my own and are written in the notebook. The dataset has no churn label, so "Inactive" only means "has not bought for a long time".



| Segment | Customers | Share of sales | Profit | Margin | Customers losing money |

|---|---|---|---|---|---|

| Loyal | 199 | 28.86% | 70,027.46 | 10.57% | 40 |

| Champions | 130 | 23.68% | 70,798.03 | 13.01% | 15 |

| At Risk | 135 | 20.64% | 78,293.55 | 16.52% | 16 |

| Inactive | 181 | 13.42% | 32,016.87 | 10.39% | 54 |

| Promising | 91 | 7.23% | 25,417.20 | 15.30% | 18 |

| Needs Attention | 57 | 6.17% | 9,855.96 | 6.95% | 12 |



\- 155 of 793 customers (about 19.5%) have a negative total profit.

\- The store's own customer types are similar: Consumer 409 customers (margin 11.55%), Corporate 236 (13.03%), Home Office 148 (14.05%). Sales per customer range from 2,839.61 to 2,992.15.



!\[RFM segments](images/customer\_01\_rfm\_segments.png)



\## 11. Product Analysis



(`notebooks/06\_product\_analysis.ipynb`)



\- \*\*How products are counted:\*\* by product name (1,850 products). I also did everything by name-and-ID pair (1,894). The top 20 products by sales and the 20 biggest losers were the same both ways. 16 names appear under more than one Product ID (314 lines, same category and sub-category each). \*\*Limitation:\*\* some of these are generic names such as "Staples", so merging by name may hide different items. Their effect on the totals is small.

\- \*\*Sub-categories:\*\* Copiers (margin 37.20%) and Paper (43.39%) earn a lot compared with their sales. Tables (−8.56%), Bookcases (−3.02%) and Supplies (−2.55%) lose money in total. Machines sell 189,238.63 but earn a margin of only 1.79%.

\- \*\*Concentration:\*\* 136 products (7.4%) make 50% of sales, and 420 products (22.7%) make 80%. The top 10 products make 10.65% of sales.

\- \*\*Loss-making products:\*\* 299 of 1,850 products lose money in total. They make 23.96% of sales and have a margin of −14.00%. 36.72% of their lines have a discount of 30% or more, against 9.66% for the other products.



!\[Sub-category matrix](images/product\_01\_subcategory\_matrix.png)

!\[Sales concentration](images/product\_02\_sales\_concentration.png)



\## 12. Sales \& Revenue Analysis



| Year | Sales | Profit | Margin | Sales growth |

|---|---|---|---|---|

| 2014 | 483,966.13 | 49,556.03 | 10.24% | - |

| 2015 | 470,532.51 | 61,618.60 | 13.10% | -2.78% |

| 2016 | 609,205.60 | 81,795.17 | 13.43% | +29.47% |

| 2017 | 733,215.26 | 93,439.27 | 12.74% | +20.36% |



| Total | Value |

|---|---|

| Sales | 2,296,919.49 |

| Profit | 286,409.08 |

| Profit margin | 12.47% |

| Orders / customers | 5,009 / 793 |

| Average order value | 458.56 |



| Category | Sales | Profit | Margin |

|---|---|---|---|

| Technology | 836,154.03 | 145,454.95 | 17.40% |

| Furniture | 741,718.42 | 18,463.33 | 2.49% |

| Office Supplies | 719,047.03 | 122,490.80 | 17.04% |



| Region | Sales | Profit | Margin |

|---|---|---|---|

| West | 725,457.82 | 108,418.45 | 14.94% |

| East | 678,499.87 | 91,534.84 | 13.49% |

| Central | 501,239.89 | 39,706.36 | 7.92% |

| South | 391,721.91 | 46,749.43 | 11.93% |



\*\*Seasonality:\*\* September, November and December were the top three months in every year. Together they made 47.5% (2014), 45.7% (2015), 41.0% (2016) and 39.6% (2017) of each year's sales. January and February are the weakest months.



\## 13. Power BI Dashboard



File: `dashboard/ecommerce\_sales\_dashboard.pbix`. The DAX is also saved as text in `dashboard/dax\_measures.txt` (18 measures and 2 calculated columns).



| Page | Question it answers |

|---|---|

| 1. Executive Overview | How is the business doing? KPI cards, monthly trend, category, region, top 10 products |

| 2. Trends \& Regions | When and where do we sell? Yearly growth, month-by-year, share of year, region margin and discounts |

| 3. Products \& Discounts | What sells but does not earn? Sub-category matrix, margin by discount group, best and worst products |

| 4. Customers | Who is valuable, who is slipping? RFM segments, top and bottom customers by profit |



Page 4 has no year slicer, because the RFM groups were calculated once over all four years.



!\[Page 2](images/powerbi\_p2\_trends\_regions.png)

!\[Page 3](images/powerbi\_p3\_products\_discounts.png)

!\[Page 4](images/powerbi\_p4\_customers.png)



\## 14. Key Business Insights



These are patterns in sample data. They are links, not proven causes.



1\. \*\*Furniture sells a lot but earns little.\*\* It is 32.3% of sales but 6.5% of profit (margin 2.49%, against about 17% for the other two categories). Tables (−17,725.48) and Bookcases (−3,472.56) lose money, while Chairs (+26,602.23) and Furnishings (+13,059.14) make a profit.

2\. \*\*Big discounts go together with losses.\*\* Lines with a discount of 30% or more are 13.93% of lines and 15.8% of sales (362,488.78), but they lost 135,364.00 (margin −37.34%). 96.77% of these lines lose money. Lines with no discount have a margin of 29.51%. The pattern holds in every category and region. The data cannot show whether discounts \*cause\* the losses, because there is no cost price.

3\. \*\*Discount is not the only reason for losses.\*\* Supplies loses money (−1,189.10) with no lines at 30% or more discount, while Binders (40.25% of lines at 30% or more) and Chairs (25.49%) are still profitable overall.

4\. \*\*Central sells well but earns little.\*\* Central's margin is 7.92%. It has 643 of the 1,392 heavy-discount lines (27.7% of its own lines, against 3.7% for West). Its margin on no-discount lines (31.31%) is not lower than the other regions (26.65% to 30.84%), so the low margin looks linked to the number of heavy-discount lines.

5\. \*\*Sales peak from September to December.\*\* Plan stock, delivery and promotions early. January and February are the weakest months.

6\. \*\*Sales grew, but the margin stopped improving.\*\* Sales fell 2.78% in 2015, then grew 29.47% in 2016 and 20.36% in 2017. Margin was 13.43% in 2016 and slipped slightly to 12.74% in 2017. The average discount stayed almost the same every year (about 16%).

7\. \*\*Best sellers are not always profitable.\*\* 7 of the 20 best-selling products lose money in total, and 12 have a margin below the company margin. The Cisco TelePresence System EX90 is third by sales and lost 1,811.08.

8\. \*\*Customers: the core is Champions and Loyal.\*\* Together they are 41.5% of customers and 52.54% of sales. "At Risk" (135 customers, last order about 221 days ago on average) has the highest total profit of all segments (78,293.55) and the best margin (16.52%).

9\. \*\*A "Champion" can still lose money.\*\* The 10 customers with the biggest losses lose 30,265.47 together (about 10.6% of company profit). RFM shows how customers buy, not how much they earn for the business.



\## 15. Business Recommendations



| Recommendation | Evidence | What we cannot say |

|---|---|---|

| Review discounts of 30% or more (for example an approval rule or a cap) | Insight 2: loss of 135,364.00 on 1,392 lines | Why the discounts were given; the cost price |

| Check pricing and discounts of Tables, Bookcases and Machines | Tables: 55.17% of lines at 30%+, profit −17,725.48; Machines margin 1.79% | Supplies loses money without heavy discounts, so costs and mix matter too |

| Review Central's discount practice | Insight 4 | A pattern only, not a proven cause |

| Plan stock and delivery early for September to December; test offers in January and February | Insight 5 | Only four years of sample data |

| Contact "At Risk" customers with a reminder or personal follow-up, not a deep discount | 135 customers, 20.64% of sales, highest profit | Their normal gap between orders is unknown, so they may not be leaving |

| Rank products and customers by profit as well as by sales | Insights 7 and 9 | |



The loss on heavy-discount lines (135,364.00) shows the size of the problem. It is not a promise of savings, because discounted lines may also bring sales that would not happen otherwise.



\## 16. Project Structure



```

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



`data/raw/` is on my computer only (ignored by Git).



\## 17. How to Run



1\. \*\*Get the raw data\*\* (only needed to rebuild from scratch): download it from the Kaggle link above and save it as `data/raw/Sample - Superstore.csv`.

2\. \*\*SQL (optional, the processed files are already included):\*\* run the scripts in `sql/` in order 01 to 07 in MySQL Workbench. Put the CSV in the folder shown by `SHOW VARIABLES LIKE 'secure\_file\_priv';` and change the file path in `02\_load\_staging\_data.sql`.

3\. \*\*Python:\*\*

&#x20;  ```

&#x20;  python -m venv .venv

&#x20;  .venv\\Scripts\\activate

&#x20;  pip install -r requirements.txt

&#x20;  jupyter notebook

&#x20;  ```

&#x20;  Open the notebooks in `notebooks/` in numeric order and use \*Kernel > Restart \& Run All\*. (Commands are for Windows Command Prompt.)

4\. \*\*Power BI:\*\* open `dashboard/ecommerce\_sales\_dashboard.pbix`. If Power BI says a file is missing, go to \*Home > Transform data > Data source settings > Change source\* and point to the CSV files in `data/processed/`.



\## 18. Results



| Measure | Value |

|---|---|

| Total sales | 2,296,919.49 |

| Total profit | 286,409.08 |

| Profit margin | 12.47% |

| Orders | 5,009 |

| Customers | 793 |

| Average order value | 458.56 |

| Sales and profit match across | SQL, Excel, Python, Power BI |

| Loss-making products | 299 of 1,850 |

| Customers with negative total profit | 155 of 793 |



\*\*Limits of this analysis:\*\* sample data from a made-up store; no cost price; no currency stated; no churn label; all findings are links, not proven causes; the RFM segments depend on my own rules; products are counted by name (see Section 11).



\## 19. Future Improvements



\- Add cost-price data to study \*why\* discounted lines lose money.

\- Look at each customer's normal gap between orders to judge who is really "At Risk".

\- Test discount rules with a small controlled trial before changing them.

\- Optional: try K-Means as a second way to group customers and compare it with RFM.

\- Optional: connect Power BI directly to the MySQL database instead of CSV files.



\## Credits and Author



\- Dataset: Sample Superstore (Tableau sample data), Kaggle copy linked above. The data belongs to its original source.

\- Author: Thirumalesh, \[github.com/S-Thirumalesh](https://github.com/S-Thirumalesh)

