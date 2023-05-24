public class CreateOrderItemCPTHandler {
    public static void OrderItemCPT(List<OrderItem> OIList)
    {
       // List<Order> Lstorder = new List<Order>();
        Set<Id> OrderItemIds = new Set<Id>();
        Set<Id> OrderIds = new Set<Id>();
        List<OrderItem> LstOI = new List<OrderItem>();
        Set<Id> lstproductIds = new Set<Id>();
        Set<ID> AccountIds = new Set<Id>();
        for(OrderItem objOI : OIList) {
           // LstOI.add(objOI);
            OrderIds.add(objOI.OrderId);
            lstproductIds.add(objOI.Product2Id);
            OrderItemIds.add(objOI.Id);
        }
        
        for(Order objOrd : [Select Id,AccountID,(Select Id,Product2Id,Customer_Product_Target__c,Product2.Parent_Product__c,
                                                OrderId,Order.AccountID from OrderItems Where Id =: OrderItemIds) from Order where ID =: OrderIds]){
          //  Lstorder.add(objOrd);
            AccountIds.add(objOrd.AccountId);
             for(OrderItem OI : objOrd.OrderItems) {
                 LstOI.add(OI);
             }                                      
        }
        
        String currentYear = '';
        Integer currentYearitg = System.Today().year();
        Integer currentMonth = System.Today().month();
        If(currentMonth>3){
            currentYear = string.valueOf(currentYearitg) + '-' + string.valueOf(currentYearitg + 1);
        }
        else{
            currentYear = string.valueOf(currentYearitg - 1) + '-' + string.valueOf(currentYearitg);
        }
        List<Customer_Product_Target__c> Lst = [Select Id,Name,Product_With_Grade__c From Customer_Product_Target__c 
                                                WHERE Account__c =: AccountIds
                                                AND Product_With_Grade__c =: lstproductIds
                                                AND Year__c =: currentYear];
        Map<Id,Id> targetProductmap = new Map<Id,Id>();
        for(Customer_Product_Target__c objTarget : LST){
            targetProductmap.put(objTarget.Product_With_Grade__c,objTarget.Id);
        }
        
        List<Customer_Product_Target__c> lstCPT = new List<Customer_Product_Target__c>();
        List<OrderItem> updateOI = new List<OrderItem>();
        For(OrderItem objOI : LstOI){
            Id proIds = targetProductmap.get(objOI.Product2Id);
            if(proIds == null){
                Customer_Product_Target__c objCPT = new Customer_Product_Target__c();
                objCPT.Product__c = objOI.Product2.Parent_Product__c;
                objCPT.Year__c = currentYear;
                objCPT.Product_With_Grade__c = objOI.Product2Id;
                objCPT.Account__c = objOI.Order.AccountId;
                lstCPT.add(objCPT);
            }
            else{
                objOI.Customer_Product_Target__c = proIds;
                updateOI.add(objOI);
            }
        }
        if(!lstCPT.isEmpty()){
            insert lstCPT;
        }
        Map<ID,ID> mapCPT = new Map<ID,ID>();
        for(Customer_Product_Target__c objCPT : lstCPT){
            mapCPT.put(objCPT.Product_With_Grade__c,objCPT.Id);  
        }
        for(OrderItem ObjectOI : LstOI){
            ID ProID = mapCPT.get(ObjectOI.Product2Id);
            if(mapCPT.containskey(ObjectOI.Product2Id)){
                ObjectOI.Customer_Product_Target__c = ProID; 
                updateOI.add(ObjectOI);
            }
        }
        if(updateOI.size()>0){
            update updateOI;
        }
    }
}