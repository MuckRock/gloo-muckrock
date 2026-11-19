class ExactPaymentData {
    exactAmount float
    quote string
}

class EstimatePaymentData {
    estimateAmount float
    quote string
}

class ReceivedPaymentData {
    paymentNotReceived bool
    quote string
}
 
class PaymentValidationData2 {
    estimate string? @description("Only set if the payment refers to an estimate but not an exact guidance.  Future work is always an estimate.")
    exact float? @description("If the email is outlining exactly what the final payment due is.")
    notReceived string? @description("The exact quote in the email explicitly stating a previously requested payment has not been received yet.")
}

class PaymentValidationData3 {
    presentPayment float? @description("If the agency is asking for a payment to be made now to fulfill the current request - include estimates which must be paid before they will begin working on the request.")
    futurePayment float? @description("If the agency is giving an estimate or advanced notice for an amount which will be due in the future, and does not need to be made now.")
    notReceived bool @description("Is the agency stating they have not yet received payment which was previously asked for.  This should only be true for follow ups to previous requests for payment or invoices, and not for new payment requests.")
}

class PaymentValidationData {
    paymentAmount float? @description("The amount of money the agency is requesting, if they have given an amount")
    estimate bool @description("Is the amount of money being requested an estimate?  This is opposed to it being an exact amount.")
    required bool @description("Is the payment required now, before they will process the request, whether it is an estimate of the final cost or not, or is it just a notice that payment will be required in the future?")
    responseRequired bool @description("Is the agency requiring the requester to make a decision about the REQUEST SCOPE or MODIFICATIONS before the payment can be determined or accepted — for example, choosing between different versions of the request, narrowing the scope, or providing additional information that changes what is being requested? Set to false if the agency is simply asking for payment or for the requester to confirm they want to proceed with payment as-is.")
    notReceived bool @description("Is the agency stating they have not yet received payment which was previously asked for.  This should only be true for follow ups to previous requests for payment or invoices, and not for new payment requests.")
}

function PaymentValidation(request_text: string) -> PaymentValidationData {
  client GPT61SolClient
  prompt #"
    Given this email extract any payment related content.

    Key rules:
    - 'required' = true if the agency says payment must be made before they will fulfill the request (even if it is an estimate). False only if payment is a future/optional notice.
    - 'responseRequired' = false if the agency is simply asking for payment or asking the requester to confirm they want to proceed with payment as quoted. Also false if the agency is providing a fee breakdown or cost justification for a previously negotiated scope — even if prior exchanges narrowed the request. What matters is whether the CURRENT email asks the requester to make a new scope decision before any fee can be determined. True ONLY if the requester must currently choose between different scope options before the agency can determine what payment is owed.
    - Examples of responseRequired=false: "Please pay $X to receive your records", "Send payment and we will fulfill your request", "Here is your cost estimate of $X, please submit payment", "Here is the fee breakdown for the 636 pages we identified".
    - Examples of responseRequired=true: "Please let us know if you want the full request or a narrowed version before we can determine the cost".
    - 'notReceived' = true ONLY if the agency explicitly states they have not yet received a payment that the requester already submitted or sent. A repeated payment request (second or third reminder) is NOT notReceived — the agency is still asking for a payment that hasn't been made yet, which is required=true, notReceived=false.

    ###
    {{ request_text }}
    ###

    Before the output format, summarize all the payment related content.

    {{ ctx.output_format }}
  "#
}


