with org as
(select ID, upper(trim(replace(replace(name,'ООО',''),'новый',''))) as Organization from dwh_bi.dim.Organization)
select
ex.DateFrom
, ar.Sku
, pa.Partner_Planning_Code
, sum(ex.Value_RUB) as Value_RUB
from dwh_bi.bi.vw_OperationExpenses_w_target     ex
left join dwh_bi.dim.OperationExpenses        re on ex.Code_CostItem=re.CodeExpensesPL
left join dwh_bi.dim.Article                 ar on ex.ID_Article=ar.ID
left join dwh_bi.dim.ArticleBrand             br on ar.ID_ArticleBrand=br.ID and br.IsMarkedForDeletion=0
left join dwh_bi.bi.vw_PlanningPartner        pa on ex.ID_Partner=pa.ID_Partner_Planning
left join                                     org on ex.ID_Organization=org.ID
left join dwh_bi.dim.DistributionChannel     dc on pa.ID_DistributionChannel_Partner_Planning=dc.ID
left join dwh_bi.dim.CompanyDepartment        cd on ex.ID_CompanyDepartment=cd.id and cd.IsMarkedForDeletion=0
left join dwh_bi.dim.OperationExpensesType    ot on ex.ID_OperationExpensesType=ot.ID
where 1=1
and ot.Name = 'Факт'
and re.name IN ('Выручка Прочая', 'Выручка от оказания услуг доставки')
group by
ex.DateFrom
, ar.Sku
, pa.Partner_Planning_Code



