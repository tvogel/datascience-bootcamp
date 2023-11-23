# Project 1: Eniac expansion from Spain to Brazil

In this case study, the company Eniac wants to expand its business to Brazil and evaluates the potential after-sales fulfillment partner Magist for its suitability on two main business questions:

- Is Magist a good partner for high-end tech products which is Eniac's market focus?
- Are deliveries with Magist fast enough?

For this, Eniac has access to 25 months worth of operations data from Magist, including anonymized sellers, customers, products, orders, payments, shipping data and customer reviews.

I worked on this group project together with:

- [Adrian Mihail](https://github.com/adrianmihail)
- Helene Rebelo 
- [Petri Tiirikainen](https://github.com/PetriTiirikainen)

Our trainers:

- [Hana Lacic](https://github.com/hanaamulic)
- [Joan Claverol](https://github.com/JoanClaverol)

## Data exploration

The first part was to explore the [data structure](src/explore_tables.sql) using SQL. Then, specific business questions were distributed among the group members and I worked on them using more detailed [SQL queries](src/business_questions.sql).

## Visualization

For visualization, we were using [Tableau Public](https://public.tableau.com). Data was [exported](data) from SQL as both full-table data and query results in CSV format.

In the group, I focussed on two main topics:

### Structure of sellers using Magist

Data exploration revealed that Magist has many sellers that are very small and many sellers that donot focus on tech, both very unlike Eniac.

I chose to display this using a scatter plot of all sellers with the x-axis saying what fraction of products was sold in tech categories and the y-axis depicting the average monthly sales (click for PDF version):

[![scatter plot of all sellers with the x-axis saying what fraction of products was sold in tech categories and the y-axis depicting the average monthly sales](images/Sellers_%20Monthly%20Sales%20and%20Tech%20Affinity.png)](images/Sellers_%20Monthly%20Sales%20and%20Tech%20Affinity.pdf)

This showed that even the most-selling seller with tech focus with monthly sales of 9.2K€ sold orders of magnitudes less than Eniac which sells 1.17 M€ in the scenario. There were only 7 out of 3095 sellers that were focussing on tech and had monthly sales above 2.5K€. 

So, the conclusion was that even though, there are a few higher-volume sellers among Magist's sellers, there is really no precedent for Eniac and choice of Magist as a fulfillment partner would pioneering and needed special care by executive management.

### Customer satisfaction and expensive tech products

In the second aspect, I analyzed whether there are particular problems with customer satisfaction in conjunction with expensive tech products. For this, I analyzed Magist's customer reviews which assign a one to five star review score to reviewed orders. For each score, I analyzed the value of items in the respective order and whether they were tech products or not. This was depicted in five side-by-side box-plots (click for PDF version):

[![Five side-by-side box-plots](images/Price%20and%20Review%20Score.png)](images/Price%20and%20Review%20Score.pdf)

As the price distributions for both tech and non-tech products as well as more or less each score did not show pronounced differences or even a trend, I concluded that expensive tech products in fact do not show specific problems with customer satisfaction. An average customer review score of 4.0 for both tech and non-tech products also showed an acceptable level of customer satsifaction.

### Sales of products depending on price

Another interesting view is how the sales of tech and other products depend on the price. I used a binned bar plot to visualize this (click for PDF version):

[![Binned bar plot](images/Price%20vs%20Sales.png)](images/Price%20and%20Review%20Score.pdf)

This shows that even though there is a clear focus on cheaper products under 400€ for Magist's sellers, there is in fact an increase of tech products between 450€ and 1450€.


## Presentation

Together with the material of my group colleagues and after rehearsal and feedback from our trainers, we condensed our findings into a five minute presentation ([slides](docs/Eniac-Magist%20data%20analytics.pdf)).

# Take away

- exercise in SQL for explorative queries
- exercise in Tableau for creating clean plots
- translating business questions into data queries
- identifying key findings
- visualizing key findings with the help of explanatory plots

And in particular, it was really interesting to see how different the focus and result can be when five groups are given the same data and questions.
