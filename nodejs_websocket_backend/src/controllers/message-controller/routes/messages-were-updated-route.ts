import {TextMessageEntity} from "../../../domain/entity/text-message-entity";
import {MessageModel, TextMessageOutput} from "../../../data/models/message-model";
import {MessagesService} from "../../../domain/services/messages-service";
import {AsklessServer} from "askless";


export class MessagesWereUpdatedRoute {

    constructor(private readonly route:string) {}

    addReadRoute (server: AsklessServer<number>, messagesService:MessagesService) {
        return server.addRoute.forAuthenticatedUsers.read<TextMessageEntity[]>({
            route: this.route,
            handleRead: async (context) => {
                console.log(`[READ] ${this.route} has been called`);
                const loggedUserId:number = context.userId;
                const userId:number = context.params['userId'];

                const receivedMessages:TextMessageEntity[] = await messagesService.getMessagesWhereSenderHasAnOutdatedVersion(loggedUserId, userId);

                const entity = MessageModel.fromEntityList(receivedMessages);
                console.log("read route:");
                console.log(entity);
                context.successCallback(entity);
            },
            onReceived: async (entity, context) => {
                console.log("onReceived messages callback: "+entity.toString() + " messages");
                await messagesService.handleSenderReceivedMessagesUpdate(entity.map(message => message.messageId));
            },
            toOutput: (entities) => MessageModel.fromEntityList(entities).map((model) => model.output()),
        })
    }

}

// TODO: verificar e remover todos os prints /logs
