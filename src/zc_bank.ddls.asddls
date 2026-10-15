@AccessControl.authorizationCheck: #NOT_REQUIRED
@EndUserText.label: 'Interface view for Bank Mapping Fields'
@Metadata.ignorePropagatedAnnotations: true
@Metadata.allowExtensions: true
define root view entity ZC_BANK as projection on  ZI_Bank
{
    key Transactionid as Transactionid,
    key  Utr as Utr,
    Virtualaccount as Virtualaccount,
    Remittername as Remittername,
    Fromaccountnumber as Fromaccountnumber,
    Frombankname as Frombankname,
   
    Remitterifsc as Remitterifsc,
    Chequeno as Chequeno,
    Narration as Narration,
    Valuedate as Valuedate,
  
    Waers as Waers,
     Amount,
     remarks,
     status,
    Creditdatetime as Creditdatetime,
    creditdatetime1,
    creationdate,
    creationtime
}
