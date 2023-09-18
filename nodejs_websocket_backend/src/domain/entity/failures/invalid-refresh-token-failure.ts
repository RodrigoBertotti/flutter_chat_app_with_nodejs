import {Failure} from "./failure";
import {AsklessErrorParams} from "askless/client/response/AsklessError";


export class InvalidRefreshTokenFailure extends Failure {

    // override
    get errorParams () : AsklessErrorParams {
        return {
            code: 'INVALID_REFRESH_TOKEN',
            description: 'The refresh token is invalid'
        }
    }

}
