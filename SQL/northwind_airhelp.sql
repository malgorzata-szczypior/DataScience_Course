/*Sprawdź jak wyglądają zapasy magazynowe poszczególnych kategorii produktów (tabele
products, categories) - suma unitinstock*/

select c."CategoryName" , sum(p."UnitsInStock")
from products p 
join categories c  on p."CategoryID" = c."CategoryID" 
group by c."CategoryName" ;

/*
 Do wyników tabeli orders dodaj numer zamówienia w miesiącu (partycjonowanie po
miesiącach) kolejność według daty.
• Dodaj analogiczne pole, ale w kolejności malejącej.
• Wypisz datę pierwszego i ostatniego zamówienia w poszczególnych miesiącach.
• Dodaj do wyników kwotę zamówienia.
• Podziel zbiór za pomocą funkcji ntile na 5 podzbiorów według kwoty zamówienia.
• Wyznacz minimalną i maksymalną wartość z wyników poprzedniego punktu dla każdego
klienta. (wyniki funkcji ntile)
• Sprawdź, czy istnieją klienci premium (którzy zawsze występują w kwnatylu 4 lub 5).
 */
--o wyników tabeli orders dodaj numer zamówienia w miesiącu (partycjonowanie po miesiącach) kolejność według daty.
--• Dodaj analogiczne pole, ale w kolejności malejącej.
create view vo_orders2 as 
select *
, to_char(o."OrderDate" ,'mm-yyyy') as new_month
, row_number() over (partition by to_char(o."OrderDate" ,'mm-yyyy') order by o."OrderDate" ) as order_in_month
, row_number() over (partition by to_char(o."OrderDate" ,'mm-yyyy') order by o."OrderDate" desc) as order_in_month_desc
from orders o ;
--Wypisz datę pierwszego i ostatniego zamówienia w poszczególnych miesiącach.
create view vo_orders3 as
select vo.new_month
,  min(vo."OrderDate") as order_first_date
, max(vo."OrderDate") as order_last_date
, round(cast(sum(od."UnitPrice"*od."Quantity"*(1-od."Discount")) as numeric),2) as total_price
from vo_orders2 vo 
join order_details od on vo."OrderID" =od."OrderID" 
group by vo.new_month
order by 1;

--Podziel zbiór za pomocą funkcji ntile na 5 podzbiorów według kwoty zamówienia.
create view vo_orders4 as  
select * 
, ntile(5) over (order by total_price) 
from vo_orders3 vo3;

--• Wyznacz minimalną i maksymalną wartość z wyników poprzedniego punktu dla każdego klienta. (wyniki funkcji ntile)
select vo4.new_month
, min(vo4.total_price) over (partition by vo4.ntile)
, max(vo4.total_price) over (partition by vo4.ntile)
, vo4.ntile, vo4.order_first_date, vo4.order_last_date, vo2."CustomerID" 
from vo_orders2 vo2 
join vo_orders4 vo4 on vo2."OrderDate" =vo4.order_first_date
group by vo4.ntile, vo4.order_first_date, vo4.order_last_date, vo4.new_month, vo2."CustomerID", vo4.total_price
order by vo4.ntile;

--Sprawdź, czy istnieją klienci premium (którzy zawsze występują w kwnatylu 4 lub 5).
select 
 vo2."CustomerID", count(vo4.ntile) as how_many_in_both
from vo_orders2 vo2 
join vo_orders4 vo4 on vo2."OrderDate" =vo4.order_first_date
where vo4.ntile in (4,5)
group by vo2."CustomerID" ;


/* Partner tui sugeruje, że wnioski są próbą wyłudzenia odszkodowania.
		Przeprowadź analizę (podstawowe):
  1.Jaka jest dynamika miesięczna (MoM) zmiany liczby wniosków dla tego partnera w
roku 2017? Skorzystaj ze składni podzapytania CTE */
with mom as 
(
select to_char(data_utworzenia,'mm')
, count(id)  as akt_miesiac
,lag(count(id)) over () as pop_miesiac
from wnioski
where to_char(data_utworzenia,'yyyy')='2017' and partner = 'tui'
group by to_char(data_utworzenia,'mm')
)
select *, round((akt_miesiac-pop_miesiac)::decimal/pop_miesiac *100,2) as mom
from mom;
/* 2.Jak zmienia się suma wypłaconych rekompensat w kolejnych miesiącach 2017 roku?
Policz MoM z wykorzystaniem podzapytania CTE */
with mom as 
(
select to_char(data_utworzenia,'mm')
,round(sum(kwota_rekompensaty),2)  as akt_miesiac
,lag(round(sum(kwota_rekompensaty),2)) over () as pop_miesiac
from wnioski
where to_char(data_utworzenia,'yyyy')='2017' and partner = 'tui'
group by to_char(data_utworzenia,'mm')
)
select *, round((akt_miesiac-pop_miesiac)/pop_miesiac *100,2) as mom
from mom;

/* 3.Jak kwota rekompensaty jest skorelowana z liczbą pasażerów dla różnych typów
podróży i typów wniosków (pola typ_podrozy i typ_wniosku)? Analizę wykonaj dla
roku 2017.*/
select typ_podrozy, typ_wniosku ,corr(liczba_pasazerow, kwota_rekompensaty)
from wnioski w
where to_char(data_utworzenia,'yyyy')='2017' and partner = 'tui'
group by typ_podrozy, typ_wniosku;

/* 4. Jak wygląda średnia, mediana i moda rekompensaty dla różnych typów podróży i
typów wniosków (pola typ_podrozy i typ_wniosku)? Analizę wykonaj dla roku 2017. */
select typ_podrozy, typ_wniosku,
round(avg(kwota_rekompensaty),2) as srednia,
percentile_disc(0.5) within group (order by kwota_rekompensaty) as mediana,
mode() within group (order by kwota_rekompensaty) as moda
from wnioski w
where to_char(data_utworzenia,'yyyy')='2017'
group by typ_podrozy, typ_wniosku;

/*5. Czy wnioski biznesowe są częściej oceniane przez operatora (procentowo) niż inne
typy wniosów? Porównaj dane w latach 2016 i 2017 dla partnera tui i dla innych
partnerów. */
with subqury as 
(
select to_char(w3.data_utworzenia,'yyyy') as rok ,count(ao2.id_wniosku) as suma
from wnioski w3
join analiza_operatora ao2 on w3.id=ao2.id_wniosku
where to_char(w3.data_utworzenia,'yyyy') in ('2016', '2017')
group by to_char(w3.data_utworzenia,'yyyy')
)
select to_char(w2.data_utworzenia,'yyyy'),
case when w2.partner is null then 'n/a' else w2.partner end as partner,
case when w2.typ_podrozy is null then 'n/a' else w2.typ_podrozy end as typ_podrozy,
count(ao.id_wniosku) as liczba_wni, sq.suma as w_wnioski,
round((count(ao.id_wniosku)::decimal/sq.suma *100),2) as proc
from wnioski w2
join analiza_operatora ao on w2.id=ao.id_wniosku
join subqury sq on to_char(w2.data_utworzenia,'yyyy')=sq.rok
where to_char(w2.data_utworzenia,'yyyy') in ('2016', '2017')
group by to_char(w2.data_utworzenia,'yyyy'), w2.partner, w2.typ_podrozy, sq.suma
order by 1,2,3;

/* 6. Oblicz dystrybuję procentową typów wniosków dla tego partnera (jaką część
wszystkich wniosków stanowią wnioski danego typu). */
with sub as 
(select count(id) as suma from wnioski where partner='tui')
select   w.typ_wniosku, count(w.id) as suma,  round(count(w.id)::decimal/sub.suma *100,2) as proc
from wnioski w
cross join sub
where partner ='tui'
group by w.partner, w.typ_wniosku, sub.suma
order by 3;

/* 7. Porównaj obliczoną dystrybucję z dystrybucją wniosków wszystkich innych partnerów
(ale nie wniosków bez partnera). Oblicz dla nich średnią. */

create temp table zad7 as
with sub1 as
(select 
count(id) filter(where partner = 'tui') as  wnioski_tui,
count(id) filter(where partner != 'tui' and partner is not null) as wnioski_inne
from wnioski
),
sub2 as
(select  
w.typ_wniosku, 
count(w.id) filter(where partner = 'tui') as suma_tui,
count(id) filter(where partner != 'tui' and partner is not null) as suma_n_tui,
sub1.wnioski_tui, sub1.wnioski_inne
from wnioski w
cross join sub1
group by  w.typ_wniosku, sub1.wnioski_tui, sub1.wnioski_inne)
select *,
round(suma_tui::decimal/wnioski_tui *100,2) as proc_tui,
round(suma_n_tui::decimal/wnioski_inne *100,2) as proc_inne
from sub2;

select typ_wniosku,
round((suma_tui+suma_n_tui)::decimal/(wnioski_tui+wnioski_inne)*100,2) as srednia
from zad7;

/*Pozostałe zadania (zaawansowane):
 1. Oblicz P25 i P75 wysokości wypłaconych rekompensat. Ile wniosków otrzymało
rekompensaty poniżej i równe P25, a ile powyżej i równe P75? Skorzystaj
percentile_disc i z funkcji count w połączeniu z case
 */
with p as 
(select
percentile_disc(0.25) within group (order by kwota_rekompensaty) as p_25,
percentile_disc(0.75) within group (order by kwota_rekompensaty) as p_75
from wnioski w2)
select 
count(id) filter(where kwota_rekompensaty < p_25) as ile_m_25,
count(id) filter(where kwota_rekompensaty =p_25) as ile_25,
count(id) filter(where kwota_rekompensaty  = p_75) as ile_75,
count(id) filter(where kwota_rekompensaty > p_75) as ile_w_75
from wnioski
cross join p;

/* 2. Wyświetl listę wniosków, których wypłacona rekompensata była równa lub wyższa
niż P75. */
with p as
(
select 
percentile_disc(0.75) within group (order by kwota_rekompensaty) as p_75
from wnioski w2
)
select id, kwota_rekompensaty
from wnioski w
join p on w.kwota_rekompensaty >= p.p_75;

/* 3. Znajdź jaki powód operatora jest zgłaszany najczęściej przez każdego z operatorów. */
with most as
(select partner,powod_operatora,
count(id) as ile_wnioskow,
max(count(id)) over (partition by partner) as max_wnioski
from wnioski
where partner is not null
group by partner, powod_operatora
order by partner)
select partner, powod_operatora,max_wnioski
from most
group by partner, powod_operatora, max_wnioski, ile_wnioskow
having ile_wnioskow=max_wnioski
order by 3 desc;

/* 4. Stwórz tabelę przestawną, gdzie rzędami będą poszczególni operatorzy podróży, w
kolumnach typy wniosków, a wartościami będą średnie kwoty rekompensaty. */

create extension tablefunc;

select * from crosstab( 
'select oo.nazwa::text,
w.typ_wniosku::text,
round(avg(w.kwota_rekompensaty),2)::numeric
from wnioski w
join podroze p2 on w.id=p2.id_wniosku
join szczegoly_podrozy sp on sp.id_podrozy=p2.id
join o_operatorzy oo on sp.identyfikator_operatora =oo.nazwa
group by 1,2')
as final_result
(
"operator" text ,
"anulowany" numeric,
"opozniony" numeric,
"przepelniony" numeric
);

/* 5. Przeanalizuj kampanie marketingowe (m_kampanie) w latach 2015-2017. Który typ
kampanii przynosił najwięcej leadów zakończonych wypłatą rekompensaty w
poszczególnych latach? */
select
date_part('year', mk.data_kampanii),
mk.typ_kampanii,
count(w.id)
from wnioski w  
join m_lead ml on w.id=ml.id_wniosku
join m_lead_kampania mlk on ml.id=mlk.id_lead
join m_kampanie mk on mlk.id_kampania=mk.id and date_part('year', mk.data_kampanii) in (2015,2016,2017)
where w.stan_wniosku ='wyplacony'
group by 1,2
order by 1, 3 desc;









