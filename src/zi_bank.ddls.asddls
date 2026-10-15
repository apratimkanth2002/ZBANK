@AccessControl.authorizationCheck: #NOT_REQUIRED
@EndUserText.label: 'Interface view for Bank Mapping Fields'
@Metadata.ignorePropagatedAnnotations: true
define root view entity ZI_Bank as select from zdt_bank_intg
{
    key transactionid as Transactionid,
    key utr as Utr,
       virtualaccount as Virtualaccount,
    remittername as Remittername,
    fromaccountnumber as Fromaccountnumber,
    frombankname as Frombankname,
    remitterifsc as Remitterifsc,
    chequeno as Chequeno,
    narration as Narration,
    valuedate as Valuedate,
    waers as Waers,
    cast(amount as abap.dec(13,2))  as Amount,
    remarks,
    status,
    creditdatetime as Creditdatetime,
    creditdatetime1,
    creationdate,
    creationtime
    
                                                                            
   
    
}
