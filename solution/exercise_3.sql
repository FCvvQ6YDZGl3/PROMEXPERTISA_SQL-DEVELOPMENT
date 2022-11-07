select
	c.cntr_type [Тип договора]
	,c.cntr_number
	,c.cntr_date
	,c.cntr_supplier_cntt_id
	,cam.cntr_amount
	,iam.ivic_amount_by_contract
from
	dbo.[contract] c
	left join dbo.contractor ca on ca.cntt_id = c.cntr_supplier_cntt_id
	left join
	(
		select
			ctsg_cntr_id
			,sum(cs.ctsg_amount) cntr_amount
		from
			dbo.contract_stage cs
		group by
			cs.ctsg_cntr_id
	) cam on cam.ctsg_cntr_id = c.cntr_id
left join
(
	select
		cs.ctsg_cntr_id
		,sum(i.ivic_amount) ivic_amount_by_contract
	from
	dbo.invoice i
	inner join dbo.contract_stage cs on cs.ctsg_id = i.ivic_ctsg_id
	group by
		cs.ctsg_cntr_id
) iam on iam.ctsg_cntr_id = c.cntr_id