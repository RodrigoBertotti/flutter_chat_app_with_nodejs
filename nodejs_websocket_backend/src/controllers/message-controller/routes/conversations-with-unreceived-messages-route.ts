import {MessagesService} from "../../../domain/services/messages-service";
import {AsklessServer} from "askless";


export class ConversationsWithUnreceivedMessagesRoute {

    constructor(private readonly route:string) {}

    addReadRoute (server:AsklessServer<number>, messagesService:MessagesService) {
        return server.addRoute.forAuthenticatedUsers.read<number[]>({
            route: this.route,
            handleRead: async (context) => {
                console.log("[READ/LISTEN] conversations-with-unreceived-messages has been called by the client"); // <-- [READ/LISTEN] conversations-with-unreceived-messages has been called by the client
                const userId:number = parseInt(context.userId as any);
                const conversationsUsersIds = await messagesService.conversationsWithUnreceivedMessages(userId);
                console.log(userId+"\": conversations-with-unreceived-messages\" sending -> "+JSON.stringify(conversationsUsersIds));
                if (conversationsUsersIds.includes(userId)) {
                    throw Error("Ops, incorrect: "+userId);
                }
                context.successCallback(conversationsUsersIds);
            },
            toOutput: (entity) => entity, // conversationsUsersIds
        })
    }

}
