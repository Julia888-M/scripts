/* исходный скрипт
 select bom.*
,*
from dim.ArticleBomAggregated as bom
left join dim.ArticleSet as aset on aset.id = bom.ID_ArticleSet
left join report.ArticleGeneralData as a on a.id_article = bom.ID_Article_Main
left join report.ArticleGeneralData as a_comp on a_comp.ID_Article  =  bom.ID_Article_Component*/


--скрипт для номенклатуры
with article as (
select a.Sku as SKU_parent --родительский СКЮ набора
, a.ArticleName Article_Name_parent --родительский СКЮ набора
, a_comp.Sku as SKU_comp-- компонентный СКЮ набора
, a_comp.ArticleName as Article_Name_comp --родительский СКЮ набора
, bom.*
, a.LoadDate
from dim.ArticleBomAggregated as bom
left join dim.ArticleSet as aset on aset.id = bom.ID_ArticleSet
left join report.ArticleGeneralData as a on a.id_article = bom.ID_Article_Main
left join report.ArticleGeneralData as a_comp on a_comp.ID_Article  =  bom.ID_Article_Component
) 
select SKU_parent
, Article_Name_parent
, LoadDate
, sum(Quantity_ComponentPerOneMainUnit) as Quantity_comp
from article
group by 
SKU_parent
, Article_Name_parent
, LoadDate