@RestResource(urlMapping='/loyalty/v1/transactions/*')
global with sharing class PosTransactionRestResource {
    private static final String CONTENT_TYPE_JSON = 'application/json; charset=UTF-8';

    @HttpPost
    global static void createTransaction() {
        RestContext.response.addHeader('Content-Type', CONTENT_TYPE_JSON);

        try {
            PosTransactionService.TransactionRequest requestBody = (PosTransactionService.TransactionRequest) JSON.deserializeStrict(
                RestContext.request.requestBody?.toString(),
                PosTransactionService.TransactionRequest.class
            );
            PosTransactionService.TransactionResult result = new PosTransactionService().createTransaction(requestBody);
            RestContext.response.statusCode = result.isReplay ? 200 : 201;
            RestContext.response.responseBody = Blob.valueOf(JSON.serialize(result));
        } catch (PosTransactionService.PosTransactionException ex) {
            writeError(ex.httpStatus, ex.errorCode, ex.getMessage());
        } catch (JSONException ex) {
            writeError(400, 'INVALID_JSON', 'The request body is not valid JSON.');
        } catch (Exception ex) {
            writeError(500, 'INTERNAL_ERROR', 'The transaction could not be processed.');
        }
    }

    private static void writeError(Integer statusCode, String errorCode, String message) {
        RestContext.response.statusCode = statusCode;
        RestContext.response.responseBody = Blob.valueOf(JSON.serialize(new ErrorResponse(errorCode, message)));
    }

    global class ErrorResponse {
        global String errorCode;
        global String message;

        global ErrorResponse(String errorCode, String message) {
            this.errorCode = errorCode;
            this.message = message;
        }
    }
}
