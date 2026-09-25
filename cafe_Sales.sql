SELECT TOP (1000) [Transaction_ID]
      ,[Item]
      ,[Quantity]
      ,[Price_Per_Unit]
      ,[Total_Spent]
      ,[Payment_Method]
      ,[Location]
      ,[Transaction_Date]
  FROM [Sales].[dbo].[dirty_cafe_sales];

  select * from [Sales].[dbo].[dirty_cafe_sales];
 

  select * into clean_cafe_sales
  from [Sales].[dbo].[dirty_cafe_sales];


  update [Sales].[dbo].[clean_cafe_sales]
  set Item = 'uncategorized'
  where Item in ('ERROR','UNKNOWN') or Item is null;

  update [Sales].[dbo].[clean_cafe_sales]
  set Payment_Method = 'not mention'
  where Payment_Method in ('ERROR','UNKNOWN') or Payment_Method is null;



  update [Sales].[dbo].[clean_cafe_sales]
  set Location = 'not specified'
  where Location in ('ERROR','UNKNOWN') or Location is null;


  alter table  clean_cafe_sales
  alter column Quantity int;



 select Location from [Sales].[dbo].[clean_cafe_sales];
  
 select Item from [Sales].[dbo].[clean_cafe_sales];
 
select Payment_Method from [Sales].[dbo].[clean_cafe_sales];

select Price_Per_Unit from [Sales].[dbo].[clean_cafe_sales];

select Total_Spent from [Sales].[dbo].[clean_cafe_sales];

select Transaction_Date from [Sales].[dbo].[clean_cafe_sales];


