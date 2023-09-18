import {AsklessErrorParams} from "askless/client/response/AsklessError";
import {AsklessError, AsklessErrorCode} from "askless";


export class Failure {

    constructor(public readonly description?:string) {}

    get errorParams() : AsklessErrorParams {
        return new AsklessError({
            code: AsklessErrorCode.INTERNAL_ERROR,
            description: this.description ?? "An internal error occurred"
        })
    };

}
