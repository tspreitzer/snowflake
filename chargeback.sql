-- CHARGEBACK --
-- Configure Snowflake Chargeback / Attribute Costs --
-- 01/19/2024, Tim Spreitzer
-- https://github.com/tspreitzer/snowflake/blob/main/chargeback.sql
---- I invite you to download scripts for your use. Download, modify, use, and share as desired.
-- This feature requires Enterprise Edition or higher. --
-- Keyboard Shortcuts MAC -- <Command><Shift><?> --
-- Keyboard Shortcuts Windows -- <Control><Shift><?> --
---- MAC: <Command><Enter> = Execute current statement
---- MAC: <Control><Option><Down Arrow> = Make bottom pane smaller

use role ACCOUNTADMIN;

use warehouse XSMALL_WH;

use schema ADMIN.DBA;

show tags;              -- List tags in current database.schema --

create tag COST_CENTER
    allowed_values 'Iron Man', 'Captain America', 'Thor';   -- Parameter 'allowed_values' is optional

show tags;              -- List tags in current database.schema --

alter tag COST_CENTER set comment = 'Attribute Costs';

show tags;              -- List tags in current database.schema --
show tags in account;   -- List tags in account --

-- Similar to 'show tags', with additional columns --
-- Latency for the view may be up to 2 hours --
select * from SNOWFLAKE.ACCOUNT_USAGE.TAGS  -- Includes deleted tags
order by TAG_NAME;

select * from SNOWFLAKE.ACCOUNT_USAGE.TAGS  -- Excludes deleted tags
where DELETED IS NULL
order by TAG_NAME;

-- Assign Compute Tags --
show warehouses;

alter warehouse XSMALL_WH set tag COST_CENTER='Iron Man';
alter warehouse SPACE_WH set tag COST_CENTER='Iron Man';
alter warehouse LARGE_WH set tag COST_CENTER='Captain America';
alter warehouse COMPUTE_WH set tag COST_CENTER='Captain America';
alter warehouse TRANSFORMING set tag COST_CENTER='Thor';
alter warehouse MEDIUM_WH set tag COST_CENTER='Thor';

-- Assign Storage Tags --
alter database FROSTBYTE_TASTY_BYTES set tag COST_CENTER='Iron Man';
alter database CITIBIKE set tag COST_CENTER='Thor';

-- Display tags and objects they are assigned to (all columns) --
-- Latency for the view may be up to 2 hours --
select * from SNOWFLAKE.ACCOUNT_USAGE.TAG_REFERENCES;

-- Display tags and objects they are assigned to (limited columns) --
-- Latency for the view may be up to 2 hours --
select  TAG_NAME
        ,DOMAIN
        ,OBJECT_NAME
        ,TAG_VALUE
from    SNOWFLAKE.ACCOUNT_USAGE.TAG_REFERENCES
order by TAG_NAME, DOMAIN, OBJECT_NAME, TAG_VALUE;

-- Query warehouse credit consumption by tags --
select  TAG_VALUE as COST_CENTER,
        sum(CREDITS_USED)
from    SNOWFLAKE.ACCOUNT_USAGE.WAREHOUSE_METERING_HISTORY, -- Latency for the view may be up to 3 hours --
        SNOWFLAKE.ACCOUNT_USAGE.TAG_REFERENCES              -- Latency for the view may be up to 2 hours --
where   WAREHOUSE_NAME=OBJECT_NAME
and     TAG_NAME='COST_CENTER'
group by 1
order by 2 desc;

-- Snowsight Dashboard Reports: Admin > Cost Management > Consumption --
-- Latency: Snowsight Dashboard updated every 12 hours --

-- References --
-- https://docs.snowflake.com/en/user-guide/cost-attributing
-- https://docs.snowflake.com/en/user-guide/object-tagging
-- https://docs.snowflake.com/en/sql-reference/sql/create-tag
-- https://docs.snowflake.com/en/sql-reference/account-usage/tags
-- https://docs.snowflake.com/en/sql-reference/account-usage/tag_references
-- https://docs.snowflake.com/en/sql-reference/sql/show-tags

---------
-- drop tag COST_CENTER;
