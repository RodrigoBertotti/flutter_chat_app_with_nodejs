import {MessageModel, TextMessageOutput} from "../../../data/models/message-model";
import {MessagesService} from "../../../domain/services/messages-service";
import {TextMessageEntity} from "../../../domain/entity/text-message-entity";
import {AsklessServer} from "askless";


export class CreateMessageRoute {

    constructor(private readonly route:string) {}

    addCreateRoute (server:AsklessServer<number>, messagesService:MessagesService) {
        server.addRoute.forAuthenticatedUsers.create<TextMessageEntity>({
            route: this.route,
            handleCreate:  async (context) => {
                const senderUserId = context.userId;
                const message = MessageModel.fromBody(context.body, senderUserId);

                const entity = await messagesService.createMessage(senderUserId, message.receiverUserId, message);

                context.successCallback(entity);
            },
            toOutput: (entity) => MessageModel.fromEntity(entity).output(),
        })
    }
}
