-- SCALE WH UP DOWN --
-- Scale warehouse sizes up and down --
-- Tim Spreitzer, 2024-04-21, Version 1.0
-- https://github.com/tspreitzer/snowflake/blob/main/scale_wh_up_down.sql
-- I invite you to download scripts for your use. Download, modify, use and share as desired.
-- https://www.linkedin.com/in/timspreitzer/
-- https://www.youtube.com/c/TimSpreitzer
-- https://medium.com/@tim.spreitzer

-- You may need to increase the size of a warehouse to improve query profermance, for example
-- when you have remote spillage.
-- Similar to the Unix/Linux sleep command, the System Function SYSTEM$WAIT command can be
-- used to string together statements to scale a warehouse up then back down. This could
-- be useful in ad hoc situations where you cannot scheulde tasks as there is no set
-- schedule requiring a larger warehouse.
-- https://docs.snowflake.com/en/user-guide/performance-query-warehouse-size --
-- https://docs.snowflake.com/user-guide/cost-understanding-overall#virtual-warehouse-credit-usage --
-- https://community.snowflake.com/s/article/Misconception-of-larger-warehouse-sizes-costing-more --

-- #1) Snowsight GUI
-- Using ACCOUNTADMIN role: Admin > Warehouses > select & edit warehouse

-- #2) Execute individual statements

alter session set QUERY_TAG = "SCALE WH UP DOWN";    -- Optional --
-- alter session unset QUERY_TAG;
-- https://docs.snowflake.com/en/sql-reference/sql/alter-session --

use role sysadmin;

show warehouses;
-- https://docs.snowflake.com/en/sql-reference/sql/show-warehouses --

show warehouses like 'TASTY_BI_WH';

alter warehouse TASTY_BI_WH SET WAREHOUSE_SIZE = LARGE;
-- https://docs.snowflake.com/en/sql-reference/sql/alter-warehouse --

show warehouses like 'TASTY_BI_WH';

alter warehouse TASTY_BI_WH SET WAREHOUSE_SIZE = XSMALL;

show warehouses like 'TASTY_BI_WH';

-- #3) Execute 4 statements simultaneously
-- Highlight and run the following 4 commands together --
alter warehouse TASTY_BI_WH SET WAREHOUSE_SIZE = LARGE;     -- Scale up to LARGE
--CALL SYSTEM$WAIT(1, 'HOURS');                               -- Wait 1 hour -- Uncomment, modify
CALL SYSTEM$WAIT(2, 'MINUTES');                               -- To Test -- Wait 2 minutes
alter warehouse TASTY_BI_WH SET WAREHOUSE_SIZE = XSMALL;    -- Scale down to XSMALL
show warehouses like 'TASTY_BI_WH';

-- #4) Create stored procedures, or parameterized stored procedures

-- #5) Create and schedule tasks

-- #6) Create a Streamlit app

-- #7) Third-party apps to run scripts

-- #8) What are some other methods not listed here?

-- https://docs.snowflake.com/en/sql-reference/functions/system_wait
-- SYSTEM$WAIT( amount [ , time_unit ] )
-- Default time_unit is SECONDS.
-- Accepted time_unit values are DAYS, HOURS, MINUTES, SECONDS, MILLISECONDS, MICROSECONDS.

-- My testing and benchmarking results for the added time by calling SYSTEM$WAIT were 0.6 credtis
-- per hour based on SNOWFLAKE.ACCOUNT_USAGE.QUERY_HISTORY.CREDITS_USED_CLOUD_SERVICES.

-- You may not actually be billed for these cloud services credits, because usage for cloud services is
-- charged only if the daily consumption of cloud services exceeds 10% of the daily usage of virtual warehouses.
-- https://docs.snowflake.com/en/user-guide/cost-understanding-compute#understanding-billing-for-cloud-services-usage
