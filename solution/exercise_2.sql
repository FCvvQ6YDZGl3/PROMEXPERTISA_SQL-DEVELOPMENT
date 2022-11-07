/*
EXEC sp_MSset_oledb_prop N'Microsoft.ACE.OLEDB.12.0', N'AllowInProcess', 1
EXEC sp_MSset_oledb_prop N'Microsoft.ACE.OLEDB.12.0', N'DynamicParameters', 1


sp_configure 'show advanced options', 1;
reconfigure;
go

sp_configure 'Ad Hoc Distributed Queries', 1;
reconfigure;
go
*/
drop table if exists #import_from_excel
select
	[№ договора] cntr_number
	,[№ этапа] ctsg_number
	,[№ Акта] excdt_number
	,[Дата/Дата начала] date_begin
	,[Дата окончания] date_end
	,trim([Поставщик]) supplier
	,trim([Валюта]) valute
	,[Сумма] amount
	,trim([Единица измерения]) measure
	,[Кол#] [count]
into #import_from_excel
from openrowset(
	'Microsoft.ACE.OLEDB.12.0'
	,'Excel 12.0; Database=....\PROMEXPERTISA_SQL-DEVELOPMENT\solution\exercise_2.xlsx'
	, [Лист1$]);
go

merge dbo.contractor as trg using
(
	select distinct e.supplier from #import_from_excel e where e.supplier is not null
) as src
on trg.cntt_name = src.supplier
when not matched
    then insert
        (
            cntt_name
        )
        values
        (
            src.supplier
        );
--select * from dbo.contractor

merge dbo.valute as trg using
(
	select distinct e.valute from #import_from_excel e where e.valute is not null
) as src
on trg.vlt_name = src.valute
when not matched
    then insert
        (
            vlt_name
			,vlt_code
        )
        values
        (
            src.valute
			,'VLT_' + UPPER(replace(substring(valute,1,16), ' ', '_'))
        );
--select * from dbo.valute

merge dbo.measure as trg using
(
	select distinct e.measure from #import_from_excel e where e.measure is not null
) as src
on trg.msur_name = src.measure
when not matched
    then insert
        (
            msur_name
			,msur_code
        )
        values
        (
            src.measure
			,'MSUR_' + UPPER(replace(substring(measure,1,16), ' ', '_'))
        );
--select * from dbo.measure

drop table if exists #contract
select distinct
	e.cntr_number
	,e.date_begin
	--,e.supplier
	,ca.cntt_id
	--,e.valute
	,v.vlt_id
into #contract
from #import_from_excel e
inner join dbo.contractor ca on ca.cntt_name = e.supplier
inner join dbo.valute v on v.vlt_name = e.valute
where
	e.cntr_number is not null
	and e.date_begin is not null
	and e.supplier is not null
	and e.valute is not null

merge dbo.[contract] as trg using
(
	select distinct * from #contract
) as src
on trg.cntr_number = src.cntr_number
when not matched
    then insert
        (
            cntr_number
			,cntr_date
			,cntr_supplier_cntt_id
			,cntr_payer_cntt_id
			,cntr_valute_id
        )
        values
        (
			src.cntr_number
			,src.date_begin
			,src.cntt_id
			,null
			,src.vlt_id
        );

drop table if exists [#contract_stage]
select distinct
	--e.cntr_number
	c.cntr_id
	,e.ctsg_number
	,e.date_begin
	,e.date_end
	,e.amount
	--,e.measure
	,m.msur_id
	,e.[count]
into [#contract_stage]
from #import_from_excel e
	inner join [contract] c on c.cntr_number = e.cntr_number
	inner join measure m on m.msur_name = e.measure
where
	e.cntr_number is not null
	and e.ctsg_number is not null
	and e.date_begin is not null
	and e.date_end is not null
	and e.amount is not null
	and e.measure is not null
	and e.[count] is not null

merge dbo.[contract_stage] as trg using
(
	select distinct * from [#contract_stage]
) as src
on trg.[ctsg_number] = src.[ctsg_number]
when not matched
    then insert
        (
		[ctsg_cntr_id]
      ,[ctsg_number]
      ,[ctsg_date_begin]
      ,[ctsg_date_end]
      ,[ctsg_msur_id]
      ,[ctsg_amount]
      ,[ctsg_count]
        )
        values
        (
			 src.cntr_id
			,src.ctsg_number
			,src.date_begin
			,src.date_end
			,src.msur_id
			,src.amount
			,src.[count]
        );

drop table if exists #execution_document
select distinct
	e.excdt_number
	,v.vlt_id
into #execution_document
from #import_from_excel e
	inner join dbo.valute v on v.vlt_name = e.valute
where
	e.excdt_number is not null
	and e.valute is not null

merge dbo.execution_document as trg using
(
	select distinct * from #execution_document
) as src
on trg.excdt_number = src.excdt_number
when not matched
    then insert
        (
		   [excdt_number]
		  ,[excdt_type_id]
		  ,[excdt_valute_id]
        )
        values
        (
			src.excdt_number
			,null
			,src.vlt_id
        );

drop table if exists #invoice
select distinct
	--e.excdt_number
	ed.excdt_id
	--,e.cntr_number
	,c.cntr_id
	--,e.ctsg_number
	,cs.ctsg_id
	,e.date_begin
	,e.amount
	,e.[count]
into #invoice
from #import_from_excel e
	inner join dbo.execution_document ed on ed.excdt_number = e.excdt_number
	inner join dbo.[contract] c on c.cntr_number = e.cntr_number
	inner join dbo.contract_stage cs on cs.ctsg_cntr_id = c.cntr_id
		and cs.ctsg_number = e.ctsg_number
where
	e.excdt_number is not null
	and e.cntr_number is not null
	and e.ctsg_number is not null
	and e.date_begin is not null
	and e.amount is not null
	and e.[count] is not null

merge dbo.invoice as trg using
(
	select distinct * from #invoice
) as src
on 
      trg.[ivic_excdt_id] = src.[excdt_id]
      and trg.[ivic_ctsg_id] = src.[ctsg_id]
      and trg.[ivic_date_complection] = src.date_begin
when not matched
    then insert
        (
			[ivic_excdt_id]
			,[ivic_position]
			,[ivic_ctsg_id]
			,[ivic_date_complection]
			,[ivic_amount]
			,[ivic_count]
        )
        values
        (
			src.excdt_id
			,null
			,src.ctsg_id
			,src.date_begin
			,src.amount
			,src.[count]
        );