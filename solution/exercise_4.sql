--не однозначная ситуация, если необходио формировать список <stage> элементами с целью просто их
--пробудлировать внутри акта то это вот этот вариант. хотя что-то мне подсказывает что я не понял задумку базы из
--предствленной в задаче диаграммы. 
select
	c.cntr_number as '@number'
	, c.cntr_date as '@date'
	, cas.cntt_name '@seller'
	, v.vlt_name '@currency'
	,(
		select
			cs.ctsg_number as '@number'
			, cs.ctsg_date_begin as '@begin_date'
			, cs.ctsg_date_end as '@end_date'
			, cs.ctsg_amount as '@sum'
			, m.msur_name as '@unit'
			, cs.ctsg_count as '@count'
			,(
				select
					ed.excdt_number as '@number'
					,i.ivic_date_complection as '@date'
					,v.vlt_name as '@currency'
					,i.ivic_amount as '@sum'
					,cs.ctsg_count as [count]
					,m.msur_name as [unit]
					,cs.ctsg_amount as [sum]
				from dbo.execution_document ed
				inner join dbo.invoice i on i.ivic_excdt_id = ed.excdt_id
				left join dbo.valute v on v.vlt_id = ed.excdt_valute_id
				where i.ivic_ctsg_id = cs.ctsg_id
					for xml path('act'), type
			)
		from dbo.contract_stage cs
			left join dbo.measure m on m.msur_id = cs.ctsg_msur_id
		where cs.ctsg_cntr_id = c.cntr_id
			for xml path('stage'), type
	)
from
	dbo.[contract] c
	left join dbo.contractor cas on cas.cntt_id = c.cntr_supplier_cntt_id
	left join dbo.valute v on v.vlt_id = c.cntr_valute_id
	for xml path('contract'), type