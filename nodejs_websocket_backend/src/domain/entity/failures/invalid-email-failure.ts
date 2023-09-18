import {Failure} from "./failure";
import {AsklessErrorParams} from "askless/client/response/AsklessError";


export class InvalidEmailFailure extends Failure {

    get errorParams(): AsklessErrorParams {
        return { code: "INVALID_EMAIL" };
    }

}
