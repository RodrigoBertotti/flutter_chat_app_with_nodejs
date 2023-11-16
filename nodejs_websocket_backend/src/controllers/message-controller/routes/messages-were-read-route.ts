import {TextMessageEntity} from "../../../domain/entity/text-message-entity";
import {MessagesService} from "../../../domain/services/messages-service";
import {AsklessServer} from "askless";
import {ErrorResponse} from "askless/route/ErrorResponse";


export class MessagesWereReadRoute {

    constructor(private readonly route:string) {}

    addCreateRoute (server:AsklessServer<number>, messagesService:MessagesService) {
        server.addRoute.forAuthenticatedUsers.create<{ /* entity --> */ readAt: Date }>({
            route: this.route,
            handleCreate: async (context) => {
                console.log("[CREATE}] \"/messages-were-read\" handler started");
                const loggedUserId:number = context.userId;
                const lastMessageReadHasBeenReceivedAtMsSinceEpoch:number = context.body['lastMessageReadHasBeenReceivedAtMsSinceEpoch'];
                console.log(`lastMessageReadHasBeenReceivedAtMsSinceEpoch: ${lastMessageReadHasBeenReceivedAtMsSinceEpoch}`);
                const senderUserId:number = parseInt(context.body['senderUserId'] as any);

                const differentDeviceTimeSpan = 15 * 1000;
                const readAt = await messagesService.notifyMessagesWereRead(loggedUserId, senderUserId, new Date(lastMessageReadHasBeenReceivedAtMsSinceEpoch + differentDeviceTimeSpan));

                context.successCallback({ readAt: readAt });
            },
            toOutput: (entity) => {
                return {
                    readAtMsSinceEpoch: entity.readAt.getTime(),
                }
            },
        })
    }

    async getMessagesByIdsAndCheckIfLoggedUserIsTheReceiver (loggedUserId: number, messagesIds:number[], messagesService:MessagesService) : Promise<Array<TextMessageEntity>> {
        const messages:Array<TextMessageEntity> = await messagesService.getMessagesByIds(messagesIds);
        if(messages.find((message) => message.receiverUserId != loggedUserId)) {
            throw new ErrorResponse({code: "PERMISSION_DENIED", description: "You are not allowed to perform to a message that is not yours"});
        }
        return messages;
    }
}
