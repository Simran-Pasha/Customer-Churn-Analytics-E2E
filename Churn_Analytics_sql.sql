CREATE DATABASE customer_churn_analytics;
use customer_churn_analytics;
select count(*) from raw_churn;
select * from raw_churn
limit 5;

#How many customers have churned, and what is the overall churn rate?
select  count(customerID) as Total_customers, 
count(case  when Churn = 'Yes' then customerID end) as Churned_cutomers  ,
(count(case  when Churn = 'Yes' then customerID end)/count(customerID)*100) as Churn_Rate
from raw_churn;

#How much monthly revenue is currently at risk because of churned customers?
select sum(MonthlyCharges) as Total_Montly_Revenue,
sum( case when Churn = 'Yes' then MonthlyCharges end) as Churned_Monthly_Revenu,
(sum( case when Churn = 'Yes' then MonthlyCharges end)/sum(MonthlyCharges)*100) as Revenue_Risk
from raw_churn;

#How does churn differ across Month-to-month, One year, and Two year contracts?
select Contract, count(customerID) as Total_customers, 
count(case when Churn = 'Yes' then CustomerID end) as Churned_customers,
(count(case when Churn = 'Yes' then CustomerID end)/count(customerID)*100) as Churn_Rate
from raw_churn
group by Contract;

#Does customer tenure relate to churn?
select  
case 
when tenure <=12 then '0-12 Months'
when tenure <=24 then '13-24 Months'
when tenure <=48 then '25-48 Months'
else '49-72 Months' 
end as Tenure_Group,
count(customerID) as Total_customers, 
count(case when Churn = 'Yes' then CustomerID end) as Churned_customers,
(count(case when Churn = 'Yes' then CustomerID end)/count(customerID)*100) as Churn_Rate
from raw_churn
group by 
case 
when tenure <=12 then '0-12 Months'
when tenure <=24 then '13-24 Months'
when tenure <=48 then '25-48 Months'
else '49-72 Months' 
end ;

#How does churn vary by payment method?
select PaymentMethod,
count(customerID) as Total_customers,
count(case when Churn = 'Yes' then customerID end) as churned_customers,
( count(case when Churn = 'Yes' then customerID end)/count(customerID)*100) as Churn_Rate
from raw_churn
group by PaymentMethod;

#How does churn vary by Internet Service type?
select InternetService,
count(customerID) as Total_customers,
count(case when Churn = 'Yes' then customerID end) as churned_customers,
( count(case when Churn = 'Yes' then customerID end)/count(customerID)*100) as Churn_Rate
from raw_churn
group by InternetService;

#Are customers with higher monthly charges churning more?
select 
case 
when MonthlyCharges <=30 then '0-30 Charges'
when MonthlyCharges <=60 then '31-60 Charges'
when MonthlyCharges <=90 then '61-90 Charges'
when MonthlyCharges <=120 then '91-120 Charges'
else  '>120'
end as Monthly_Charges_Band,
count(customerID) as Total_customers,
count(case when Churn = 'Yes' then customerID end) as churned_customers,
( count(case when Churn = 'Yes' then customerID end)/count(customerID)*100) as Churn_Rate
from raw_churn
group by 
case 
when MonthlyCharges <=30 then '0-30 Charges'
when MonthlyCharges <=60 then '31-60 Charges'
when MonthlyCharges <=90 then '61-90 Charges'
when MonthlyCharges <=120 then '91-120 Charges'
else  '>120'
end;

#How does churn vary between customers who have Tech Support, don't have Tech Support, or have no internet service?
select TechSupport,
count(customerID) as Total_customers,
count(case when Churn = 'Yes' then customerID end) as churned_customers,
( count(case when Churn = 'Yes' then customerID end)/count(customerID)*100) as Churn_Rate
from raw_churn
group by TechSupport;

#Which customer segments contribute the most monthly revenue at risk from churn?
select SeniorCitizen,
count(customerID) as Total_customers,
count(case when Churn ='Yes' then customerID end) as Churned_Customers,
(count(case when Churn ='Yes' then customerID end)/count(customerID) *100) as Churn_Rate,
sum(case when Churn='Yes' then MonthlyCharges end ) as Monthly_Revenue_Risk
from raw_churn
group by SeniorCitizen;

#For each contract type, how many customers have churned and how much monthly revenue is at risk?
select contract,
count(customerID) as Total_customers,
count(case when Churn ='Yes' then customerID end) as Churned_Customers,
(count(case when Churn ='Yes' then customerID end)/count(customerID) *100) as Churn_Rate,
sum(case when Churn='Yes' then MonthlyCharges end ) as Monthly_Revenue_Risk
from raw_churn
group by contract;

#For each contract type, rank customers by their MonthlyCharges from highest to lowest.
select customerID ,contract, Monthlycharges,
rank() over(partition by contract order by MonthlyCharges desc) as Customer_Rank
from raw_churn;

#Within each contract type, give every customer a unique sequential number based on MonthlyCharges from highest to lowest.
select customerID ,contract, Monthlycharges,
row_number() over(partition by contract order by MonthlyCharges desc) as Customer_Rank
from raw_churn;

#Within each contract type, rank customers by MonthlyCharges from highest to lowest, but don't skip rank numbers when there are ties.
select customerID ,contract, Monthlycharges,
dense_rank() over(partition by contract order by MonthlyCharges desc) as Customer_Rank
from raw_churn;

#one customer-level view with the calculated fields
CREATE VIEW churn_analysis AS
SELECT
    customerID,
    gender,
    SeniorCitizen,
    Partner,
    Dependents,
    tenure,
    PhoneService,
    MultipleLines,
    InternetService,
    OnlineSecurity,
    OnlineBackup,
    DeviceProtection,
    TechSupport,
    StreamingTV,
    StreamingMovies,
    Contract,
    PaperlessBilling,
    PaymentMethod,
    MonthlyCharges,
    TotalCharges,
    Churn,

    CASE
        WHEN Churn = 'Yes' THEN 1
        ELSE 0
    END AS Churn_Flag,

    CASE
        WHEN tenure <= 12 THEN '0-12 Months'
        WHEN tenure <= 24 THEN '13-24 Months'
        WHEN tenure <= 48 THEN '25-48 Months'
        ELSE '49-72 Months'
    END AS Tenure_Group,

    CASE
        WHEN MonthlyCharges <= 30 THEN '0-30 Charges'
        WHEN MonthlyCharges <= 60 THEN '31-60 Charges'
        WHEN MonthlyCharges <= 90 THEN '61-90 Charges'
        WHEN MonthlyCharges <= 120 THEN '91-120 Charges'
        ELSE '>120 Charges'
    END AS Monthly_Charge_Band,

    CASE
        WHEN Churn = 'Yes' THEN MonthlyCharges
        ELSE 0
    END AS Churned_Monthly_Revenue

FROM raw_churn;

Select * from churn_analysis;







































































































