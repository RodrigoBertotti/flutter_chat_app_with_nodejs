import {Failure} from "./failure";
import {AsklessErrorParams} from "askless/client/response/AsklessError";


export class InvalidPasswordFailure extends Failure {

    get errorParams(): AsklessErrorParams {
        return { code: "INVALID_PASSWORD" };
    }

}
