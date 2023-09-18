import { AppDataSource } from "./data/data-source/db-datasouce";
import {authController, controllers, initializeControllers} from "./domain/controllers-and-services";
import {verifyJwtAccessToken} from "./utils/jwt-utils";
import {AsklessServer} from "askless";


AppDataSource.initialize().then(async () => {
    const server = new AsklessServer<number>();

    initializeControllers(server);

    // initializing all controllersAndServices
    for (let controller of controllers()) {
        controller.initializeRoutes(server);
    }

    server.init({
        wsOptions: { port: 3000, },
        debugLogs: false,
        sendInternalErrorsToClient: false,
        requestTimeoutInMs: 7 * 1000,
        authenticate: async (credential, accept, reject) : Promise<void> => {
            if (credential && credential["accessToken"]) {
                const result = verifyJwtAccessToken(credential["accessToken"]);
                if (!result.valid) {
                    reject({credentialErrorCode: "EXPIRED_ACCESS_TOKEN"});
                    return;
                }
                accept.asAuthenticatedUser({ userId: result.userId,  });
                return;
            }

            reject({credentialErrorCode: "MISSING_CREDENTIAL"});
        },
    });

    server.start();
    console.log("started on "+server.localUrl);

}).catch(databaseError => console.log(databaseError))
