drop table if exists contractor
create table contractor
(
	cntt_id int identity(1,1)
	,cntt_name varchar(100) not null
    ,constraint pk_cntt_id primary key(cntt_id)
    ,constraint uq_cntt_name unique(cntt_name)
)
go
drop table if exists valute
create table valute
(
	vlt_id int identity(1,1)
	,vlt_code varchar(20) not null
	,vlt_name varchar(50)
    ,constraint pk_vlt_id primary key(vlt_id)
	,constraint uq_vlt_code unique(vlt_code)
    ,constraint uq_vlt_name unique(vlt_name)
)
go
drop table if exists measure
create table measure
(
	msur_id int identity(1,1)
	,msur_code varchar(20)
	,msur_name varchar(50)
    ,constraint pk_msur_id primary key(msur_id)
	,constraint uq_msur_code unique(msur_code)
    ,constraint uq_msur_name unique(msur_name)
)
go

drop table if exists [contract]
create table [contract]
(
	cntr_id int identity(1,1)
	,cntr_number varchar(50) not null
	,cntr_date date not null
	,cntr_type int
	,cntr_supplier_cntt_id int
	,cntr_payer_cntt_id int
	,cntr_valute_id int
	,constraint pk_cntr_id primary key(cntr_id)
	,constraint uq_cntr_number unique(cntr_number)
	,constraint fk_cntr_supplier_cntt_id foreign key(cntr_supplier_cntt_id) references dbo.contractor(cntt_id)
	,constraint fk_cntr_payer_cntt_id foreign key(cntr_payer_cntt_id) references dbo.contractor(cntt_id)
	,constraint fk_cntr_vlt_id foreign key(cntr_valute_id) references dbo.valute(vlt_id)
)
go
drop table if exists [contract_stage]
create table [contract_stage]
(
	ctsg_cntr_id int
	,ctsg_id int identity(1,1)
	,ctsg_number varchar(50) not null
	,ctsg_date_begin date
	,ctsg_date_end date
	,ctsg_msur_id int
	,ctsg_amount money
	,ctsg_count money
	,constraint pk_ctsg_id primary key(ctsg_id)
	,constraint fk_ctsg_msur_id foreign key(ctsg_msur_id) references dbo.measure(msur_id)
	,constraint fk_ctsg_cntr_id foreign key(ctsg_cntr_id) references dbo.[contract](cntr_id)
)
go

drop table if exists execution_document
create table execution_document
(
	excdt_id int identity(1,1)
	,excdt_number varchar(50)
	,excdt_type_id int
	,excdt_valute_id int
	,constraint pk_excdt_id primary key(excdt_id)
	,constraint uq_excdt_number unique(excdt_number)
	,constraint fk_excdt_valute_id foreign key(excdt_valute_id) references dbo.valute(vlt_id)
)
go
drop table if exists invoice
create table invoice
(
	iviv_id int identity(1,1)
	,ivic_excdt_id int
	,ivic_position int
	,ivic_ctsg_id int not null
	,ivic_date_complection date
	,ivic_amount money
	,ivic_count money
	,constraint pk_iviv_id primary key(iviv_id)
	,constraint fk_ivic_excdt_id foreign key(ivic_excdt_id) references dbo.execution_document(excdt_id)
	,constraint fk_ivic_ctsg_id foreign key(ivic_ctsg_id) references dbo.contract_stage(ctsg_id)
)
go