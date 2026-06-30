use Customer_Churn;
select * from fact_customerchurn;
select * from dim_customer;
select * from dim_product;
select * from dim_date;
Desc dim_date;
Desc dim_customer;
Alter table dim_customer modify column joindate date;
Alter table dim_date modify column FullDate date;
-- Total customer
select count(Distinct CustomerID) as total_customers from fact_customerchurn;
-- Total churned
select count(distinct ChurnID) as total_churned from fact_customerchurn where churned="Yes";
-- Active Customer
select count(*) as Active_Customers from fact_customerchurn where churned="No";
-- Total Revenue
select round(sum(NetRevenue),2) as total_Revenue from fact_customerchurn;
-- churn Rate %
 select round(avg( case when churned="Yes" then 1 else 0 end)*100,2)as churn_rate from fact_customerchurn;
 -- Average Age
 select round(avg(age),2) as avg_age from dim_customer;
 -- Average Revenue
 select round(avg(NetRevenue),2) as Avg_Revenue from fact_customerchurn;
 -- Average Tenure
 select round(avg(TenureMonths),2) as AvgTenure from fact_customerchurn;
 -- Average Satisfaction
 select round(avg(satisfactionScore),2) as Avgsatisfaction from fact_customerchurn;
 -- Average Churn Risk
 select round(Avg(ChurnRisk),2) as Avg_churn_risk from fact_customerchurn;
 -- Senior Citizens
 select count(*) as senior_citizen from dim_customer where Age>60;
 -- Churned Revenue Loss
 select round(sum(NetRevenue),2) as revenue_lost from fact_customerchurn where churned ="Yes";
-- Revenue At Risk
select round(sum(NetRevenue),2) as Revenue_at_risk from fact_customerchurn where ChurnRisk>0.70;
-- High Risk Customers
select customerID, Satisfactionscore,Churned from fact_customerchurn where Satisfactionscore<3;
-- Churn by Contract type
Select ContractType,count(*) as churn_count from Fact_customerchurn where Churned ="yes" group by ContractType;
-- Highest Churn Contract 
select ContractType, count(*) as churn_count from Fact_customerchurn where Churned="Yes" group by ContractType 
order by churn_count desc limit 1;
-- city Analysis
select c.city,count(*) as churn_count from Fact_customerchurn f join Dim_Customer c on c.CustomerID= f.CustomerID  where f.Churned="Yes" group by c.city 
order by churn_count desc;
-- product analysis 
select p.productName ,count(*) as churn_count from fact_customerchurn f join Dim_product p on f.ProductID=p.ProductID
 where f.churned='Yes' group by p.ProductName;
 -- Most Churned Product 
 select p.productName,count(*) as churn_count from fact_customerchurn f join dim_product p on f.productID=p.productID where f.Churned='Yes' 
 group by p.productName order by churn_count desc limit 1;
 -- Top Customers
 select CustomerID, NetRevenue, rank() over(order by NetRevenue desc) as Rank_Revenue from Fact_customerchurn;
-- Top 5 value Customers
select CustomerID, CLV_Estimate ,dense_rank() over(order by CLV_Estimate desc) as CLV_Rank from Fact_customerchurn limit 5;
-- Customer Risk Ranking
select CustomerID, SatisfactionScore, Dense_rank() over(order by satisfactionscore asc) as riskrank from fact_customerchurn ;
-- Customer with Churn Status(all customers)
select c.customerID,c.CustomerName,f.Churned from Dim_Customer c left join fact_customerchurn f on c.customerID=f.customerID;
-- customers without churn record
select c.customerID,c.CustomerName from Dim_Customer c left join fact_customerchurn f on 
c.customerID=f.customerID where f.customerID is null;
-- Top Churn Reasons
select ChurnReason, count(*) as churn_count from fact_customerchurn where churned='Yes' 
group by ChurnReason order by churn_count desc;
-- Retention Rate
select round(avg(case when Churned="No" then 1 else 0 end)*100,2) as retention_rate from fact_customerchurn;
-- High value customers who churned
select CustomerID, CLV_Estimate, NetRevenue from fact_customerchurn where churned='yes' order by CLV_Estimate desc;
-- Revenue by product
select p.productName ,round(sum(f.NetRevenue),2) as Revenue from fact_customerchurn f join 
dim_product p on f.productID=p.productID group by p.productName order by Revenue desc;
-- City wise retention
select c.city,count(*) as retained_customers from fact_customerchurn f join dim_customer c on f.CustomerID=c.customerID  where 
f.churned='No' group by c.city order by Retained_Customers desc;
-- High Risk High Revenue Customers
select CustomerID, NetRevenue,churnRisk from fact_customerchurn where churnrisk>0.70 and NetRevenue >
( select avg(NetRevenue) from fact_customerchurn );
-- Contrect Type Revenue Analysis
select contracttype,count(*) as Retained_Customers from fact_customerchurn where Churned='No' group by ContractType;
-- Top 3 Customers
select * from
(select customerID, Satisfactionscore,dense_rank() over(order by satisfactionscore desc) as riskrank from
fact_customerchurn) as  x where riskrank<=3;
-- cumulative revenue over time
select d.monthname, sum(f.NetRevenue) as MonthlyRevenue,sum(sum(f.NetRevenue)) over(order by d.month) as cumulative_revenue
from fact_customerchurn f join dim_date d  on f.DateID=d.DateID group by d.Month, d.MonthName order by d.Month;
--  cumlative churn count
select d.monthname, count(*) as monthly_churn, sum(count(*)) over( order by month) as culative_churn from fact_customerchurn f 
join dim_date d on f.DateID=d.DateID where churned='Yes' group by d.MonthName,d.Month order by d.Month;
-- Week day vs weekend churn
select case when dayofweek(d.fulldate) in(1,7) then'Weekend' else 'Weekday' end as day_type, count(*) as churn_count from fact_customerchurn f
join dim_date d on d.dateid=f.dateid where churned='yes' group by day_type;
-- top product per city revenue
select * from (
select c.city,p.productname,sum(netrevenue) as revenue, dense_rank() over(partition by c.city order by sum(f.netrevenue) desc) rnk
from fact_customerchurn f join dim_customer c on f.customerid=c.customerid join dim_product p on f.productid=p.productid
group by c.city,p.productname)x where rnk=1;
-- moving average monthly charge
select d.fulldate,avg(f.monthlycharge) as charge , avg(avg(f.monthlycharge)) over(order by d.fulldate rows between 2 
preceding and current row) as moving_avg from fact_customerchurn f join dim_date d on f.dateid=d.dateid group by d.fulldate 
order by d.fulldate;
