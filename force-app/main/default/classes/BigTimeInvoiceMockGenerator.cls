/**
 * @File Name          : BigTimeInvoiceMockGenerator.cls
 * @Description        : 
 * @Author             : sean.gray@atirestoration.com
 * @Group              : 
 * @Last Modified By   : Sean Gray
 * @Last Modified On   : 11/10/2019, 8:36:33 AM
 * @Modification Log   : 
 * Ver       Date            Author      		    Modification
 * 1.0    11/8/2019   sean.gray@atirestoration.com     Initial Version
**/
@isTest
global class BigTimeInvoiceMockGenerator implements HttpCalloutMock{
    global boolean Flag = false;
    global HTTPResponse respond(HTTPRequest req) {
        //System.assertEquals('https://iq.bigtime.net/BigTimeData/api/v2/session', req.getEndpoint());
        //System.assertEquals('POST', req.getMethod());

        HttpResponse res = new HttpResponse();
        res.setHeader('Content-Type', 'application/json');
        if(Flag == false){
        res.setBody('[{"Token":"123abc", "Firm":"abc123", "SID":"1234","ProjectSid":"123","StatusTxt":"Sent"},{"Token":"123abc", "Firm":"abc123", "SID":"1234","ProjectSid":"123","StatusTxt":"Posted"}]');
        Flag = true;
        }else{
        res.setBody('{"invoice":{"ARAcctSid":0,"BillingAddress":{"CoNm":"Liberty Mutual Insurance","Attn":"Nanette Prince","Address":"nanette.p@libertymutual.comPO Box 515097","City":"Los Angeles","state":"CA","PostalCode":"90051","Country":"","FullAddress":"nanette.p@libertymutual.comPO Box 515097Los Angeles, CA 90051"},"BillingContactId":2147480,"ClientSid":1239188,"Color":"","CurrencySid":0,"FirmAddress":{"CoNm":"American Technologies, Inc.","Website":"","Phone":"714-283-9990","Address":"3360 East La Palma Ave.","City":"Anaheim","state":"CA","PostalCode":"92806","Country":"","FullAddress":"3360 East La Palma Ave.nAnaheim, CA 92806"},"InvoiceDt":"2019-09-26","InvoiceDtDue":"2019-09-26","InvoiceDtEnd":"2019-09-18","InvoiceDtSt":"2019-08-19","InvoiceNbr":"","InvoicePeriod":201602,"Lines":[{"LineNbr":1,"LineType":2,"LineCategory":"Standard","Nm":"Travel Time","Nt":"","AcctSid":0,"BudgetPer":201602,"IsCredit":false,"IsNonTimeCharge":false,"IsTaxable":false,"IsUnpaid":false,"QBClassSid":0,"Quantity":3,"Rate":165,"Amt":495,"SalesTaxSid":0,"SubTotalSID":531510,"UpdatedLineNbr":0},{"LineNbr":2,"LineType":2,"LineCategory":"Standard","Nm":"Photo Analysis","Nt":"","AcctSid":0,"BudgetPer":201602,"IsCredit":false,"IsNonTimeCharge":false,"IsTaxable":false,"IsUnpaid":false,"QBClassSid":0,"Quantity":0.5,"Rate":165,"Amt":82.5,"SalesTaxSid":0,"SubTotalSID":513078,"UpdatedLineNbr":0},{"LineNbr":3,"LineType":2,"LineCategory":"Standard","Nm":"Inspection","Nt":"","AcctSid":0,"BudgetPer":201602,"IsCredit":false,"IsNonTimeCharge":false,"IsTaxable":false,"IsUnpaid":false,"QBClassSid":0,"Quantity":1.5,"Rate":165,"Amt":247.5,"SalesTaxSid":0,"SubTotalSID":513072,"UpdatedLineNbr":0},{"LineNbr":4,"LineType":2,"LineCategory":"Standard","Nm":"Correspondence","Nt":"","AcctSid":1,"BudgetPer":201602,"IsCredit":false,"IsNonTimeCharge":false,"IsTaxable":false,"IsUnpaid":false,"QBClassSid":0,"Quantity":0.25,"Rate":165,"Amt":41.25,"SalesTaxSid":0,"SubTotalSID":510556,"UpdatedLineNbr":0},{"LineNbr":5,"LineType":2,"LineCategory":"Standard","Nm":"Document Analysis","Nt":"","AcctSid":1,"BudgetPer":201602,"IsCredit":false,"IsNonTimeCharge":false,"IsTaxable":false,"IsUnpaid":false,"QBClassSid":0,"Quantity":1.5,"Rate":165,"Amt":247.5,"SalesTaxSid":0,"SubTotalSID":510557,"UpdatedLineNbr":0},{"LineNbr":6,"LineType":2,"LineCategory":"Standard","Nm":"File Review","Nt":"","AcctSid":1,"BudgetPer":201602,"IsCredit":false,"IsNonTimeCharge":false,"IsTaxable":false,"IsUnpaid":false,"QBClassSid":0,"Quantity":0.5,"Rate":165,"Amt":82.5,"SalesTaxSid":0,"SubTotalSID":510562,"UpdatedLineNbr":0},{"LineNbr":7,"LineType":50,"LineCategory":"Standard","Nm":"Travel:Mileage","Nt":"","AcctSid":0,"BudgetPer":201602,"IsCredit":false,"IsNonTimeCharge":true,"IsTaxable":false,"IsUnpaid":false,"QBClassSid":0,"Quantity":102,"Rate":0.58,"Amt":59.16,"SalesTaxSid":0,"SubTotalSID":125731,"UpdatedLineNbr":0}],"Note1":"Claim #038564279-01Koplin, Fred & Lynnen2050 La Fremontia StSouth Pasadena, CA 91030","Note2":"","PaidAmt":0,"PayMethod":"BTPayment","PONumber":"","ProjectSid":3787660,"QBPostType":0,"RptSid":2481,"SalesTaxSid":0,"Sid":4482870,"Status":3,"TermsSid":0,"AuditStatus":0,"Calculator":1,"CanEditInvoice":true,"ClientNm":"Liberty Mutual Insurance Co","Consolidated":false,"ConsoParentSid":0,"DName":"Liberty Mutual Insurance Co:K6:Koplin, Fred & Lynne","InvoiceAmt":1255.41,"PostedStatus":"none","SalesTaxAmt":0,"salesTaxList":[],"Subtotal":1255.41,"TotalAmt":1255.41,"TotalAmtDue":1255.41,"PayMethodId":0,"StatusId":3,"StatusTxt":"Sent","PostedStatusId":-1,"SentMessageId":"","ReviewStatus":"NotStarted","ReviewStatusTxt":"NotStarted","HasReceipts":false}, "parameters":{"PeriodId":201602,"AllHours":true,"ClearWip":false,"FilterExpenses":true,"IncludeTimeOrExp":"Both","ApprovedTimeOnly":true,"ApprovedExpenseOnly":true,"CopyNotes":false,"DisableSettings":{"Notes":false,"CopyNotes":false,"ApprovedExpenseOnly":false,"ApprovedTimeOnly":false,"SubtotalType":false},"SubtotalType":"ByLaborCodeRate","TotalExpensesByCat":false,"UseWipFees":false}}');
        }
        res.setStatusCode(200);
        return res;
    }
}