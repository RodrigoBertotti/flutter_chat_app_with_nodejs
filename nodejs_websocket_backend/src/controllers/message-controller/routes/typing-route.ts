import {MessagesService} from "../../../domain/services/messages-service";
import {AsklessServer} from "askless";


export class TypingRoute {

    constructor(private readonly route: string) {}

    addReadRoute (server:AsklessServer<number>, messagesService:MessagesService,) {
        return server.addRoute.forAuthenticatedUsers.read<"TYPING" | "NOT_TYPING">({
            route: this.route,
            handleRead: async (context) => {
                const loggedUserId:number = context.userId;
                const typingUserId:number = context.params['typingUserId'];

                console.log("READ TypingRoute "+loggedUserId+" STARTED LISTENING typingUserId = "+typingUserId);

                context.successCallback(messagesService.isTyping(typingUserId, loggedUserId) ? "TYPING" : "NOT_TYPING");
            },
            toOutput: (entity) => entity, // "TYPING" or "NOT_TYPING"
        })
    }
}
