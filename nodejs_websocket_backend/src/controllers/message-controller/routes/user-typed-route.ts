import {MessagesService} from "../../../domain/services/messages-service";
import {AsklessServer} from "askless";


export class UserTypedRoute {

    constructor(private readonly route:string) {}

    addCreateRoute (server:AsklessServer<number>, messagesService:MessagesService) {
        server.addRoute.forAuthenticatedUsers.create({
            route: this.route,
            toOutput: (entity) => entity, // Always "OK"
            handleCreate: async (context) => {
                const loggedUserId:number = context.userId;
                const receiverUserId:number = context.body['receiverUserId'];

                messagesService.notifyUserIsTyping(loggedUserId, receiverUserId);

                context.successCallback('OK');
            }
        })
    }

}
