SELECT
pt.kh_Symbol
,pt.adr_NazwaPelna
,ISNULL( [0], 0.00) as [Suma rok poprzedni]
,ISNULL( [1] ,0.00) as 'Stycze�'
,ISNULL( [2] ,0.00) as 'Luty'
,ISNULL( [3] ,0.00) as 'Marzec'
,ISNULL( [4] ,0.00) as 'Kwiecie�'
,ISNULL( [5] ,0.00) as 'Maj'
,ISNULL( [6] ,0.00) as'Czerwiec'
,ISNULL( [7] ,0.00) as 'Lipiec'
,ISNULL( [8] ,0.00) as 'Sierpie�'
,ISNULL( [9] ,0.00) as 'Wrzesie�'
,ISNULL( [10],0.00)  as 'Pa�dziernik'
,ISNULL( [11],0.00)  as 'Listopad'
,ISNULL( [12],0.00)  as 'Grudzie�'
,ISNULL( [13],0.00)  as 'Suma rok bie��cy'

FROM
(
SELECT 
ISNULL(K.kh_Symbol,'0000000000') as kh_Symbol
, ISNULL(AE.adr_NazwaPelna,'Detaliczny') AS adr_NazwaPelna
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
ISNULL(K.kh_Symbol,'0000000000') as kh_Symbol
, ISNULL(AE.adr_NazwaPelna,'Detaliczny') AS adr_NazwaPelna
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
ISNULL(K.kh_Symbol,'0000000000') as kh_Symbol
, ISNULL(AE.adr_NazwaPelna,'Detaliczny') AS adr_NazwaPelna
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