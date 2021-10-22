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

if exists (select * from sys.objects where object_id = OBJECT_ID(N'dbo.sp_WidokDlaPodsumowanieSprzedazyWgKontrahentow'))
	drop procedure dbo.sp_WidokDlaPodsumowanieSprzedazyWgKontrahentow
go

create procedure dbo.sp_WidokDlaPodsumowanieSprzedazyWgKontrahentow  with encryption
as
begin	
	if exists(select * from sys.views where name = 'dbo.vw_PodsumowanieSprzedazwgKontrahenta' and type ='V')
		drop view dbo.vw_PodsumowanieSprzedazwgKontrahenta	

	declare @Sql nvarchar(max)

	set @Sql = Concat(@Sql, ' ',
					'		
					create view dbo.vw_PodsumowanieSprzedazwgKontrahenta with encryption
					as
					', ' ')

	
	
	declare @RokPoprzedni VARCHAR(4)
	SET @RokPoprzedni = CAST(Year(GetDate())-1 AS VARCHAR(4))


	begin
		set @Sql = Concat(@Sql, ' ',
					'
					SELECT
pt.kh_Symbol
,pt.adr_NazwaPelna
,ISNULL( [0], 0.00) as [' + @RokPoprzedni + ']
,ISNULL( [1] ,0.00) as ''Styczeñ''
,ISNULL( [2] ,0.00) as ''Luty''
,ISNULL( [3] ,0.00) as ''Marzec''
,ISNULL( [4] ,0.00) as ''Kwiecieñ''
,ISNULL( [5] ,0.00) as ''Maj''
,ISNULL( [6] ,0.00) as ''Czerwiec''
,ISNULL( [7] ,0.00) as ''Lipiec''
,ISNULL( [8] ,0.00) as ''Sierpieñ''
,ISNULL( [9] ,0.00) as ''Wrzesieñ''
,ISNULL( [10],0.00)  as ''PaŸdziernik''
,ISNULL( [11],0.00)  as ''Listopad''
,ISNULL( [12],0.00)  as ''Grudzieñ''
,ISNULL( [13],0.00)  as ''Suma rok bie¿¹cy''

FROM
(
SELECT 
ISNULL(K.kh_Symbol,''0000000000'') as kh_Symbol
, ISNULL(AE.adr_NazwaPelna,''Detaliczny'') AS adr_NazwaPelna
,D.dok_WartNetto
,month(D.dok_DataWyst) AS Miesiac
FROM dok__Dokument D
LEFT JOIN kh__Kontrahent K ON D.dok_PlatnikId = K.kh_Id
LEFT JOIN adr__Ewid AE ON AE.adr_IdObiektu = K.kh_ID AND adr_TypAdresu = 1
WHERE dok_Typ in (2,4,21,14)
AND
dok_DataWyst>=DATEFROMPARTS(YEAR(GETDATE()),01,01)

UNION ALL
SELECT 
ISNULL(K.kh_Symbol,''0000000000'') as kh_Symbol
, ISNULL(AE.adr_NazwaPelna,''Detaliczny'') AS adr_NazwaPelna
,D.dok_WartNetto
,0 AS Miesiac
FROM dok__Dokument D
LEFT JOIN kh__Kontrahent K ON D.dok_PlatnikId = K.kh_Id
LEFT JOIN adr__Ewid AE ON AE.adr_IdObiektu = K.kh_ID AND adr_TypAdresu = 1
WHERE dok_Typ in (2,4,21,14)
AND
dok_DataWyst<DATEFROMPARTS(YEAR(GETDATE()),01,01)
AND
dok_DataWyst>=DATEFROMPARTS(YEAR(GETDATE())-1,01,01)

UNION ALL

SELECT 
ISNULL(K.kh_Symbol,''0000000000'') as kh_Symbol
, ISNULL(AE.adr_NazwaPelna,''Detaliczny'') AS adr_NazwaPelna
,D.dok_WartNetto
,13 AS Miesiac
FROM dok__Dokument D
LEFT JOIN kh__Kontrahent K ON D.dok_PlatnikId = K.kh_Id
LEFT JOIN adr__Ewid AE ON AE.adr_IdObiektu = K.kh_ID AND adr_TypAdresu = 1
WHERE dok_Typ in (2,4,21,14)
AND
dok_DataWyst>=DATEFROMPARTS(YEAR(GETDATE()),01,01)


) AS pyt
PIVOT
	(
	SUM(dok_WartNetto)
	FOR Miesiac in([0],[1],[2],[3],[4],[5],[6],[7],[8],[9],[10],[11],[12],[13])
	) as pt
		ORDER BY pt.kh_Symbol,pt.adr_NazwaPelna
					', ' ')

		
	end


	exec sp_executesql @Sql
end
go

















































