import {AuthService} from "../../domain/services/auth-service";
import {authService, Controller} from "../../domain/controllers-and-services";
import {TokensModel} from "../../data/models/tokens-model";
import {AsklessServer, Authenticate} from "askless";

export class AuthController implements Controller {

    constructor(private readonly authService:AuthService) {}

    initializeRoutes (server: AsklessServer<number>) : void {
        server.addRoute.forAuthenticatedUsers.create({
            route: "logout",
            handleCreate: async context => {
                await this.authService.logout(context.userId);
                context.successCallback('OK');
            },
            toOutput: entity => entity, // Always "OK"
        });

        server.addRoute.forAllUsers.create({
            route: "login",
            handleCreate: async context => {
                if (!context.body["email"]?.length || !context.body["password"]?.length) {
                    context.errorCallback({
                        code: "BAD_REQUEST",
                        description: "Missing \"email\" or \"password\""
                    });
                    return;
                }
                const loginResult = await authService().login(context.body["email"], context.body["password"]);
                if (loginResult.isLeft()) {
                    context.errorCallback(loginResult.error.errorParams);
                    return;
                }
                return context.successCallback(loginResult.value)
            },
            toOutput: (entity) => TokensModel.fromEntity(entity).output(),
        });

        server.addRoute.forAllUsers.create({
            route: "accessToken",
            handleCreate: async context => {
                if (!context.body["refreshToken"]?.length || context.body["userId"] == null) {
                    context.errorCallback({
                        code: "BAD_REQUEST",
                        description: "Missing \"refreshToken\" or \"userId\""
                    });
                    return;
                }
                const genResult = await authService().generateNewAccessToken(context.body["userId"], context.body["refreshToken"]);
                if (genResult.isLeft()) {
                    context.errorCallback(genResult.error.errorParams);
                    return;
                }
                return context.successCallback(genResult.value)
            },
            toOutput: (entity) => TokensModel.fromEntity(entity).output(),
            onReceived: () => { console.log("client received token successfully "); },
        });
    }
}
