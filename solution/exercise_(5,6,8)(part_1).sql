/*
HR �������, �������:
"���� ����� ������� 8 �������, ������ �������� ��� ������� � �����"
�� ���� ������ � ������ ��� ���� ���������� ������ ������ �� ������ � �������
����������� ������ �������, � ��� ��� ��� 8 �������.
�� ��������� ��������� ��� 1-8 � 1-4, ������ ��� ��� 5-�� ������ � "������ �����"
*/
--������� ���� � ������������ ����������� ��������� ����������
/*
select top(1) with ties cast(d.date as date), count(d.document_id)
from
	document d
group by cast(d.date as date)
order by 2
*/

select  top(1) with ties cast(c.cntr_date as date), count(c.cntr_id) as doc_count
from
	dbo.[contract] c
group by cast(c.cntr_date as date)
order by 2 desc

--� �������� �1 �� 01.01.06 �������� �������: ���� 10 ����, ���� 3 ���.
/*
declare @unit_id int = (select top(1) u.unt_id from dbo.unit u where u.unt_name = '����')
declare @curr_id int = (select top(1) c.crrn_id from dbo.currency c where c.crrn_name = '���')
drop table if exists #document_position
select
	ed.excdt_id
	,'' dcps_name
	,10.0 dcps_count
	,@unit_id dcps_unt_id
	,3.0 dcps_price
	,@curr_id dcps_crrn_id
into #invoice
from
dbo.document d
where
	d.dc_number = '�1'
	and cast(d.dc_date as date) = '2006-01-01'

insert into dbo.document_position
select  * from #document_position dc
where
	dc.dcps_crrn_id is not null
	and dc.dcps_unt_id is not null
	and dc.dcps_dt_id is not null
go
*/

/*
���������� ���� ���������� (01.01.06) ��������� �������� �������� �123. ��� ��������: �������� 
�������� � ��� ���������: ������� ��������
*/

/*
update d
	set d.dt_date = '2006-01-01'
from
	dbo.document d
	 left join dbo.contract c on c.
	 left join dbo.document_type dt on dt.dt_dct_id = d.dt_id
	  left join dbo.operation o on o.oprt_id = dt.dt_oprt_id
where
	c.ctr_number = '�123'
	and o.opr_name = '�������� ��������'
	and dt.dt_name = '������� ��������'
*/