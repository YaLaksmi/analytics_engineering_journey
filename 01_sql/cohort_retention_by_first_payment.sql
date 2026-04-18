-- =============================================================================
-- НАЗВАНИЕ: Cohort retantion analysis
-- ЗАДАЧА: оценить удержание платящих клиентов
-- =============================================================================

-- 1) определяем месяц платежа
-- 2) определяем когорту = месяц первого платежа
-- 3) считаем активность по месяцам
-- 4) добавляем номер месяца жизни клиента
-- 5) рассчитываем retention_rate

with row_paiment_date as(
	select 
		customer_id,
		date_trunc('month', payment_date)::timestamp  as paiment_month
	from payment
),

stg_cohort_date as(
	select
		customer_id,
		min(paiment_month)::timestamp as hogort_date
	from row_paiment_date
	group by customer_id
),

stg_cohort_activity as(
	select 	
		rpd.customer_id,
		rpd.paiment_month,
		shd.hogort_date,
		
		extract(year from AGE(rpd.paiment_month, shd.hogort_date))*12 
		 + extract(month from AGE(rpd.paiment_month, shd.hogort_date)) as month_live_time
		 
	from row_paiment_date as rpd
	inner join stg_cohort_date as shd
		on rpd.customer_id = shd.customer_id
)




select 
	sha.hogort_date,
	sha.month_live_time,
	count(distinct sha.customer_id) as active_customers_cnt,
	round(100*count(distinct sha.customer_id)
		/FIRST_VALUE(count(distinct sha.customer_id)) over(partition by sha.hogort_date order by month_live_time),
		2
	) as retantion_rate
	
from stg_cohort_activity as sha
group by 
	sha.hogort_date,
	sha.month_live_time
order by 
	sha.hogort_date,
	sha.month_live_time;