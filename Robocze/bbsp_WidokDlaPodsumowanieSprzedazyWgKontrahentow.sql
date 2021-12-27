/*
Autor: Dariusz Brzozowski
Data utworzenia: 09.07.2020
Opis: Tworzy widok zbierajacy stany towarów z integrowanych baz
Wykorzystywane obiekty:
	- $TFS\Navireo\Brykacze\Applications\BIELbit.IntegracjaBaz\DataBase\ObiektySQL\bb_Integracja\bb_intgr_Magazyn.sql 
	- $TFS\Navireo\Brykacze\Applications\BIELbit.IntegracjaBaz\DataBase\ObiektySQL\bb_Integracja\bb_intgr_GrupaTw.sql 

CHANGELOG:
	Autor: Dariusz Brzozowski
	Data zmiany: 12.07.2021
	Opis: Wyœwietlenie wszystkich towarów, dodanie kolumny DaneZIntegracji pokazuj¹cej które dane faktycznie bior¹ udzia³ w integracji
*/

if exists (select * from sys.objects where object_id = OBJECT_ID(N'dbo.sp_intgr_WidokDlaZbiorczeStanyMagazynowe'))
	drop procedure dbo.bbsp_intgr_WidokDlaZbiorczeStanyMagazynowe  
go

create procedure dbo.bbsp_intgr_WidokDlaZbiorczeStanyMagazynowe  with encryption
as
begin	
	if exists(select * from sys.views where name = 'bbvw_intgr_ZbiorczeStanyMagazynowe' and type ='V')
		drop view dbo.bbvw_intgr_ZbiorczeStanyMagazynowe	

	declare @Sql nvarchar(max)

	set @Sql = Concat(@Sql, ' ',
					'		
					create view dbo.bbvw_intgr_ZbiorczeStanyMagazynowe with encryption
					as
					', ' ')

	declare cs cursor for select itb_NazwaBazy, itb_Id 
							from dbo.bb_intgr_TabelaBaz 
							where itb_Aktywna = 1 and (itb_RealizujeSprzedaz = 1 or (itb_RealizujeSprzedaz = 0 and itb_Kolejnosc > 0))
	open cs
	declare @Nazwa varchar(50)
	declare @BazaId int

	fetch next from cs into @Nazwa, @BazaId
	while @@fetch_status = 0
	begin
		set @Sql = Concat(@Sql, ' ',
					'
					select 
						Tw.tw_Zablokowany,
						Tw.tw_Rodzaj,
						Tw.tw_Symbol,
						Tw.tw_Nazwa,
						Tw.Stan,
						Tw.Rezerwacja,
						Tw.Dostepne,
						"StanKompletu" =
							case when TRY_CAST(Tw.tw_Pole1 as money) is null
							then 0
							else cast(Tw.tw_Pole1 as money) end,
						Tw.tw_JednMiary,
						case 
							when MagazynI.mag_NazwaFirmy is not null then  MagazynI.mag_NazwaFirmy
							else ''' + @Nazwa + '''
						end as Firma,
						case
							when MagazynI.mag_Nazwa is not null then MagazynI.mag_Nazwa
							else MagazynB.mag_Nazwa
						end as mag_Nazwa,
						case
							when MagazynI.mag_Id is not null then MagazynI.mag_Id
							else MagazynB.mag_Id
						end as mag_Id,
						Tw.tw_StanMin,
						Tw.tw_StanMaks,
						GrupaI.grt_Id,
						GrupaI.grt_Nazwa,
						MagazynI.mag_IdBazy as IdFirmy,
						Tw.tw_SklepInternet,
						case 
							when MagazynI.mag_Id is null then 0
							else 1
						end as DaneZIntegracji
					from
						' + @Nazwa + '.dbo.vwTowar Tw 
						left join ' + @Nazwa + '.dbo.sl_Magazyn MagazynB on MagazynB.mag_Id = Tw.st_MagId
						left join dbo.bb_intgr_Magazyn MagazynI on MagazynI.mag_Nazwa = MagazynB.mag_Nazwa and MagazynI.mag_IdBazy = ' + cast(@BazaId as nvarchar(10)) + '
						left join ' + @Nazwa + '.dbo.sl_GrupaTw GrupaB on GrupaB.grt_Id = Tw.tw_IdGrupa
						left join dbo.bb_intgr_GrupaTw GrupaI on GrupaB.grt_Nazwa = GrupaI.grt_Nazwa
					', ' ')

		fetch next from cs into @Nazwa, @BazaId
		if @@fetch_status = 0
			set @Sql = Concat(@Sql, ' ', 'union all', ' ')
	end

	close cs
	deallocate cs

	exec sp_executesql @Sql
end
go

















































