import {Failure} from "./failure";
import {AsklessErrorParams} from "askless/client/response/AsklessError";


export class DuplicateEmailFailure extends Failure {

    constructor(public readonly email:string, ) {
        super(`The email ${email} is already registered`);
    }

    // override
    get errorParams(): AsklessErrorParams {
        return {
            code: "DUPLICATED_EMAIL",
            description: this.description!,
        };
    }
}
