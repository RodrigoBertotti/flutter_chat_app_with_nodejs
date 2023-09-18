import {MessagesService} from "../../../domain/services/messages-service";
import {MessageModel} from "../../../data/models/message-model";
import {TextMessageEntity} from "../../../domain/entity/text-message-entity";
import {AsklessServer, AuthenticateUserContext} from "askless";
import {ReadRouteInstance} from "askless/route/ReadRoute";


export class ReadMessagesRoute {

    constructor(private readonly route:string,) {}

    addReadRoute (server:AsklessServer<number>, messagesService:MessagesService) : ReadRouteInstance<TextMessageEntity[], AuthenticateUserContext<number>, {messages: TextMessageEntity[]}>{
        return server.addRoute.forAuthenticatedUsers.read<TextMessageEntity[], { messages : TextMessageEntity[] }>({
            route: this.route,
            onReceived: async (entities, context) => {
                console.log("onReceived MESSAGES: ");
                await messagesService.handleMessagesUpdate(entities, { receivedAt: new Date(), senderHasOutdatedVersion: true, });
            },
            handleRead: async (context) => {
                console.log(`[READ] ${this.route} has been called by the client`);

                const mainUserId:number = parseInt(context.userId as any);
                const senderUserId:number = context.params['senderUserId'];

                const entities = await messagesService.getMessages(mainUserId, senderUserId);
                context.successCallback(entities);
            },
            toOutput: (entities) => MessageModel.fromEntityList(entities).map((model) => model.output()),
        })
    }

}
