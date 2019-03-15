({
    getProductsInfoHelper: function(component, event) {
        // call apex method for fetch child records list.
        var action = component.get("c.getProductsDetails");
		action.setParams({"caseId": component.get("v.recordId")});
        action.setCallback(this, function(actionResult) {
            var state = actionResult.getState();
            if (state === 'SUCCESS') {
                //set response value in ChildRecordList attribute on component.
                component.set('v.ChildRecordList', actionResult.getReturnValue());
            }
        });
        $A.enqueueAction(action);
    },
})