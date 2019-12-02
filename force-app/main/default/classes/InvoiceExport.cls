global with sharing class InvoiceExport {
    webService static InvoiceExport.Invoice[] getInvoice(Id[] invoiceIDs) {
        List<Invoice__c> qryInvoices = new List<Invoice__c>([   SELECT Name,Net_Due__c,Total_Costs_Per_Contract__c,Retainage_Held__c,Retainage_Held_percent__c,Retainage_Amount__c,Memo__c,Taxable_Amount__c,
Tax_Group__c,Total_Tax__c,Bill_to_Tax_Group__c,Bill_to_Tax_Group__r.Timberline_Id__c,
//Job__c,
ATI_Job__r.Job_Number__c,ATI_Job__r.Primary_Account__c,
Bill_To__r.Timberline_Customer_Number__c,LastModifiedDate,Due_Date__c,Total_Credits__c,        
Bill_to_Tax_Group__r.Tax1Name__c,Bill_to_Tax_Group__r.Tax1Rate__c,Bill_to_Tax_Group__r.Tax2Name__c,
Bill_to_Tax_Group__r.Tax2Rate__c,Bill_to_Tax_Group__r.Tax3Name__c,Bill_to_Tax_Group__r.Tax3Rate__c,
Bill_to_Tax_Group__r.Tax4Name__c,Bill_to_Tax_Group__r.Tax4Rate__c,Bill_to_Tax_Group__r.Tax5Name__c,Bill_to_Tax_Group__r.Tax5Rate__c,
Bill_to_Tax_Group__r.Tax6Name__c,Bill_to_Tax_Group__r.Tax6Rate__c,Bill_to_Tax_Group__r.Tax7Name__c,Bill_to_Tax_Group__r.Tax7Rate__c,
Bill_to_Tax_Group__r.Tax8Name__c,Bill_to_Tax_Group__r.Tax8Rate__c,Bill_to_Tax_Group__r.Tax9Name__c,Bill_to_Tax_Group__r.Tax9Rate__c
                                  , (SELECT Id, Amount__c, Description__c, Taxable__c, IsCredit__c, Note__c FROM Invoice_Line_Items__r)
                                FROM Invoice__c
                                WHERE
                                  (Id in :invoiceIDs)
                                FOR REFERENCE ]);
        
        List<InvoiceExport.Invoice> Invoices = new List<InvoiceExport.Invoice>();
        List<InvoiceExport.InvoiceLine> InvoiceLines = new List<InvoiceExport.InvoiceLine>();
        List<InvoiceExport.TaxLine> TaxLines = new List<InvoiceExport.TaxLine>();
        
        for (Invoice__c i : qryInvoices) {
            Decimal TotalAmount = i.Total_Costs_Per_Contract__c + i.Total_Tax__c; // - i.Total_Credits__c (DO NOT SEND CREDITS TO TIMBERLINE)
            TotalAmount = TotalAmount.setScale(2); // Round to two decimal places
            Decimal TxAmount = 0.0;
            
            Decimal RetainageAmount = (i.Retainage_Amount__c == null) ? 0.0 : i.Retainage_Amount__c;
            RetainageAmount = RetainageAmount.setScale(2);
            
            // Generate the row for this invoice
            InvoiceExport.Invoice invoice = new InvoiceExport.Invoice();
            
            invoice.customer = i.Bill_To__r.Timberline_Customer_Number__c;
            invoice.invoice = i.Name;
            invoice.invoice_date = i.Due_Date__c;
            invoice.amount = TotalAmount.toPlainString();
            invoice.retainage_held = RetainageAmount.toPlainString();
            invoice.description = ((i.Memo__c != null) ? i.Memo__c.substring(0, Math.min(30, i.Memo__c.length())) : '');
            invoice.due_date = i.Due_Date__c;
            
            // get the values
            Id TaxGroupId = i.Bill_to_Tax_Group__c;
            String TaxGroupName = i.Bill_to_Tax_Group__r.Timberline_Id__c;
            
            // Generate line items for each line item
            for (Invoice_Line_Item__c li : i.Invoice_Line_Items__r) {
                if (li.IsCredit__c) continue; // DO NOT SEND CREDITS TO TIMBERLINE
                if (li.Note__c) continue; // DO NOT SEND NOTES TO TIMBERLINE
                
                Decimal liAmount = li.Amount__c;
                liAmount = liAmount.setScale(2); // Round off!
                
                Decimal Retainage = (i.Retainage_Held_percent__c == null || li.Amount__c == null || li.IsCredit__c) ? 0 : (i.Retainage_Held_percent__c * 0.01) * li.Amount__c;
                Retainage = Retainage.setScale(2);
                
                TxAmount += liAmount;
                
                InvoiceExport.InvoiceLine lineItem = new InvoiceExport.InvoiceLine();
                
                lineItem.job = i.ATI_Job__r.Job_Number__c;
                lineItem.tax_group = TaxGroupName;
                lineItem.exempt_status = (li.Taxable__c?'Taxable':'Non-Taxable');
                lineItem.amount = liAmount.toPlainString();
                lineItem.retainage = Retainage.toPlainString();
                
                invoice.InvoiceLines.add(lineItem);
            }
            
            Decimal LastTax = null;
            InvoiceExport.TaxLine taxLine = null;
            
            if (TaxGroupName != null && i.Taxable_amount__c != null && TaxGroupName != '' && i.Taxable_amount__c > 0.0) {
                
                if (i.Bill_to_Tax_Group__r.Tax1Name__c != null && i.Bill_to_Tax_Group__r.Tax1Rate__c > 0) {
                    LastTax = i.Taxable_amount__c * (i.Bill_to_Tax_Group__r.Tax1Rate__c * 0.01);
                    LastTax = LastTax.setScale(2);
                    TxAmount += LastTax;
                    
                    taxLine = new InvoiceExport.TaxLine();
                    taxLine.job = i.ATI_Job__r.Job_Number__c;
                    taxLine.tax_id = i.Bill_to_Tax_Group__r.Tax1Name__c;
                    taxLine.exempt_status = 'Non-Taxable';
                    taxLine.amount = LastTax.toPlainString();
                    
                    invoice.TaxLines.add(taxLine);
                }
                if (i.Bill_to_Tax_Group__r.Tax2Name__c != null && i.Bill_to_Tax_Group__r.Tax2Rate__c > 0) {
                    LastTax = i.Taxable_amount__c * (i.Bill_to_Tax_Group__r.Tax2Rate__c * 0.01);
                    LastTax = LastTax.setScale(2);
                    TxAmount += LastTax;
                    
                    taxLine = new InvoiceExport.TaxLine();
                    taxLine.job = i.ATI_Job__r.Job_Number__c;
                    taxLine.tax_id = i.Bill_to_Tax_Group__r.Tax2Name__c;
                    taxLine.exempt_status = 'Non-Taxable';
                    taxLine.amount = LastTax.toPlainString();
                    
                    invoice.TaxLines.add(taxLine);
                }
                if (i.Bill_to_Tax_Group__r.Tax3Name__c != null && i.Bill_to_Tax_Group__r.Tax3Rate__c > 0) {
                    LastTax = i.Taxable_amount__c * (i.Bill_to_Tax_Group__r.Tax3Rate__c * 0.01);
                    LastTax = LastTax.setScale(2);
                    TxAmount += LastTax;
                    
                    taxLine = new InvoiceExport.TaxLine();
                    taxLine.job = i.ATI_Job__r.Job_Number__c;
                    taxLine.tax_id = i.Bill_to_Tax_Group__r.Tax3Name__c;
                    taxLine.exempt_status = 'Non-Taxable';
                    taxLine.amount = LastTax.toPlainString();
                    
                    invoice.TaxLines.add(taxLine);
                }
                if (i.Bill_to_Tax_Group__r.Tax4Name__c != null && i.Bill_to_Tax_Group__r.Tax4Rate__c > 0) {
                    LastTax = i.Taxable_amount__c * (i.Bill_to_Tax_Group__r.Tax4Rate__c * 0.01);
                    LastTax = LastTax.setScale(2);
                    TxAmount += LastTax;
                    
                    taxLine = new InvoiceExport.TaxLine();
                    taxLine.job = i.ATI_Job__r.Job_Number__c;
                    taxLine.tax_id = i.Bill_to_Tax_Group__r.Tax4Name__c;
                    taxLine.exempt_status = 'Non-Taxable';
                    taxLine.amount = LastTax.toPlainString();
                    
                    invoice.TaxLines.add(taxLine);
                }
                if (i.Bill_to_Tax_Group__r.Tax5Name__c != null && i.Bill_to_Tax_Group__r.Tax5Rate__c > 0) {
                    LastTax = i.Taxable_amount__c * (i.Bill_to_Tax_Group__r.Tax5Rate__c * 0.01);
                    LastTax = LastTax.setScale(2);
                    TxAmount += LastTax;
                    
                    taxLine = new InvoiceExport.TaxLine();
                    taxLine.job = i.ATI_Job__r.Job_Number__c;
                    taxLine.tax_id = i.Bill_to_Tax_Group__r.Tax5Name__c;
                    taxLine.exempt_status = 'Non-Taxable';
                    taxLine.amount = LastTax.toPlainString();
                    
                    invoice.TaxLines.add(taxLine);
                }
                if (i.Bill_to_Tax_Group__r.Tax6Name__c != null && i.Bill_to_Tax_Group__r.Tax6Rate__c > 0) {
                    LastTax = i.Taxable_amount__c * (i.Bill_to_Tax_Group__r.Tax6Rate__c * 0.01);
                    LastTax = LastTax.setScale(2);
                    TxAmount += LastTax;
                    
                    taxLine = new InvoiceExport.TaxLine();
                    taxLine.job = i.ATI_Job__r.Job_Number__c;
                    taxLine.tax_id = i.Bill_to_Tax_Group__r.Tax6Name__c;
                    taxLine.exempt_status = 'Non-Taxable';
                    taxLine.amount = LastTax.toPlainString();
                    
                    invoice.TaxLines.add(taxLine);
                }
                if (i.Bill_to_Tax_Group__r.Tax7Name__c != null && i.Bill_to_Tax_Group__r.Tax7Rate__c > 0) {
                    LastTax = i.Taxable_amount__c * (i.Bill_to_Tax_Group__r.Tax7Rate__c * 0.01);
                    LastTax = LastTax.setScale(2);
                    TxAmount += LastTax;
                    
                    taxLine = new InvoiceExport.TaxLine();
                    taxLine.job = i.ATI_Job__r.Job_Number__c;
                    taxLine.tax_id = i.Bill_to_Tax_Group__r.Tax7Name__c;
                    taxLine.exempt_status = 'Non-Taxable';
                    taxLine.amount = LastTax.toPlainString();
                    
                    invoice.TaxLines.add(taxLine);
                }
                if (i.Bill_to_Tax_Group__r.Tax8Name__c != null && i.Bill_to_Tax_Group__r.Tax8Rate__c > 0) {
                    LastTax = i.Taxable_amount__c * (i.Bill_to_Tax_Group__r.Tax8Rate__c * 0.01);
                    LastTax = LastTax.setScale(2);
                    TxAmount += LastTax;
                    
                    taxLine = new InvoiceExport.TaxLine();
                    taxLine.job = i.ATI_Job__r.Job_Number__c;
                    taxLine.tax_id = i.Bill_to_Tax_Group__r.Tax8Name__c;
                    taxLine.exempt_status = 'Non-Taxable';
                    taxLine.amount = LastTax.toPlainString();
                    
                    invoice.TaxLines.add(taxLine);
                }
                if (i.Bill_to_Tax_Group__r.Tax9Name__c != null && i.Bill_to_Tax_Group__r.Tax9Rate__c > 0) {
                    LastTax = i.Taxable_amount__c * (i.Bill_to_Tax_Group__r.Tax9Rate__c * 0.01);
                    LastTax = LastTax.setScale(2);
                    TxAmount += LastTax;
                    
                    taxLine = new InvoiceExport.TaxLine();
                    taxLine.job = i.ATI_Job__r.Job_Number__c;
                    taxLine.tax_id = i.Bill_to_Tax_Group__r.Tax9Name__c;
                    taxLine.exempt_status = 'Non-Taxable';
                    taxLine.amount = LastTax.toPlainString();
                    
                    invoice.TaxLines.add(taxLine);
                }
            }
            
            // Fix the rounding issues, if any
            Decimal difference = TotalAmount - TxAmount;
            if (LastTax != null && difference != 0 && taxLine != null) {
                LastTax += difference;
                TxAmount += difference;
                taxLine.amount = LastTax.toPlainString();
            }
            
            Invoices.add(invoice);
        }
        
        return Invoices;
    }
    
    global class Invoice {
        public Invoice () {
            InvoiceLines = new List<InvoiceLine>();
            TaxLines = new List<TaxLine>();
        }
    
        webservice String customer {get; set;}
        webservice String invoice {get; set;}
        webservice Date invoice_date {get; set;}
        webservice String amount {get; set;}
        webservice String retainage_held {get; set;}
        webservice String description {get; set;}
        webservice Date due_date {get; set;}
        
        webservice InvoiceLine[] InvoiceLines;
        webservice TaxLine[] TaxLines;
    }
    
    global class InvoiceLine {
        webservice String job {get; set;}
        webservice String tax_group {get; set;}
        webservice String exempt_status {get; set;}
        webservice String amount {get; set;}
        webservice String retainage {get; set;}
    }
    
    global class TaxLine {
        webservice String job {get; set;}
        webservice String tax_id {get; set;}
        webservice String exempt_status {get; set;}
        webservice String amount {get; set;}
    }
}