use project2;
select * from Date_wise_report;
select * from Order_status;

-- calculate the Stock count & work order count based on order_id
select os.Order_id, 
sum(case when os.Order_Type='STOCK' then 1 else 0 end) as Stock_Count,
sum(case when os.Order_Type='Work_Order' then 1 else 0 end) as Work_Order_Count from Order_Status os group by os.Order_id;

-- calculate Work_order_pending Status
select os.Order_id, 
sum(case when os.Order_Type='STOCK' then 1 else 0 end) as Stock_Count,
sum(case when os.Order_Type='Work_Order' then 1 else 0 end) as Work_Order_Count,
sum(case when os.Order_Type='STOCK' then 1 else 0 end) - sum(case when os.Order_Type='Work_Order' then 1 else 0 end) as Work_Order_Pending_Status
from Order_Status os group by os.Order_id;

-- (i) creat a new field (Field name work_order_closed_or_not 
-- (ii) Work_order_pending status < 0 Then update order_closed other wise Order_pending

select os.Order_id, 
sum(case when os.Order_Type = 'STOCK' then 1 else 0 end) as Stock_Count,
sum(case when os.Order_Type = 'Work_Order' then 1 else 0 end) as Work_Order_Count,
sum(case when os.Order_Type = 'STOCK' then 1 else 0 end) - sum(case when os.Order_Type = 'Work_Order' then 1 else 0 end) as Work_Order_Pending_status,
case
when (sum(case when os.Order_Type = 'STOCK' then 1 else 0 end) - sum(case when os.Order_Type = 'Work_Order' then 1 else 0 end)) <0 then 'Order Closed'
else 'Order Pending'
end as Work_Order_Closed_or_Not from Order_Status os group by os.Order_id;

-- create a new table after completing pending status (table name: Order_pending_status)
create table Order_pending_status(select os.Order_id, 
sum(case when os.Order_Type = 'STOCK' then 1 else 0 end) as Stock_Count,
sum(case when os.Order_Type = 'Work_Order' then 1 else 0 end) as Work_Order_Count,
sum(case when os.Order_Type = 'STOCK' then 1 else 0 end) - sum(case when os.Order_Type = 'Work_Order' then 1 else 0 end) as Work_Order_Pending_status,
case
when (sum(case when os.Order_Type = 'STOCK' then 1 else 0 end) - sum(case when os.Order_Type = 'Work_Order' then 1 else 0 end)) <0 then 'Order Closed'
else 'Order Pending'
end as Work_Order_Closed_or_Not from Order_Status os group by os.Order_id);
select * from Order_pending_status;

-- create a second table while using join (table name : order_supplier_report)

create table order_supplier_report (select os.Order_id, os.Order_Type, os.Assembly_Supplier,dwr.Sale_id,
dwr.Sale_Date, dwr.Qty, dwr.Item_Type, dwr.Job_Status, dwr.Planner, dwr.Buyer_Name, dwr.Preferred_Supplier, dwr.Safety, dwr.Pre_PLT,
dwr.Post_PLT, dwr.LT, dwr.Run_Total, dwr.Late, dwr.Safety_RT, dwr.PO_Note, dwr.Net_Neg, dwr.Last_Neg, dwr.Item_Category, dwr.Created_On_Date
from Order_Status os left join Date_wise_report dwr on os.Sale_id = dwr.Sale_id);

select * from order_supplier_report;

-- (I) Date_wise Quantity & Order_id count
select Sale_Date, sum(Qty) as Total_Quantity, count(distinct Order_id) as Order_ID_Count from order_supplier_report group by Sale_Date 
order by Sale_Date;

-- (II)split the supplier_name while using comma delimiter
select Order_id, Order_Type, Assembly_Supplier, Sale_Date, Qty, Item_Type, Job_Status, Planner, 
SUBSTRING_INDEX(Buyer_Name, ',', -1) as First_Name, SUBSTRING_INDEX(Buyer_Name, ',', 1) as Last_Name, Preferred_Supplier, Safety, Pre_PLT, Post_PLT, 
LT, Run_Total, Late, Safety_RT, PO_Note,  Net_Neg, Last_Neg, Item_Category, Created_On_Date from order_supplier_report;

-- stored the all reports and tables while using stored procedure
delimiter %%
drop table order_supplier_report;
create procedure SupplierReport()
begin
create table order_supplier_report as select os.Order_id, os.Order_Type, os.Assembly_Supplier,dwr.Sale_id,
dwr.Sale_Date, dwr.Qty, dwr.Item_Type, dwr.Job_Status, dwr.Planner, dwr.Buyer_Name, dwr.Preferred_Supplier, dwr.Safety, dwr.Pre_PLT,
dwr.Post_PLT, dwr.LT, dwr.Run_Total, dwr.Late, dwr.Safety_RT, dwr.PO_Note, dwr.Net_Neg, dwr.Last_Neg, dwr.Item_Category, dwr.Created_On_Date
from Order_Status os left join Date_wise_report dwr on  os.Sale_id = dwr.Sale_id; 
select * from order_supplier_report;     
end %%
delimiter ;
call SupplierReport();


delimiter %%
create procedure OrderCount()
begin
create table date_wise_qty_order_count as
select Sale_Date, sum(Qty) as Total_Quantity, count(distinct Order_id) as Order_ID_Count from order_supplier_report 
group by Sale_Date order by Sale_Date;
select * from date_wise_qty_order_count;     
end %%
delimiter ;
call OrderCount();

delimiter %%
create procedure SupplierNameSplit()
begin
create table supplier_name_split as
select Order_id, Order_Type, Assembly_Supplier, Sale_Date, Qty, Item_Type, Job_Status, Planner, 
SUBSTRING_INDEX(Buyer_Name, ',', -1) as First_Name, SUBSTRING_INDEX(Buyer_Name, ',', 1) as Last_Name, Preferred_Supplier, Safety, Pre_PLT, Post_PLT, 
LT, Run_Total, Late, Safety_RT, PO_Note,  Net_Neg, Last_Neg, Item_Category, Created_On_Date from order_supplier_report;
select * from supplier_name_split;   
end %%
delimiter ;
call SupplierNameSplit();