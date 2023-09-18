import {ChatContentEntity} from "../../domain/entity/chat-content-entity";
import {MessageModel, TextMessageOutput} from "./message-model";

export interface ChatContentOutputToClient {
    [ChatContentModel.kMessages]: TextMessageOutput[],
    [ChatContentModel.kIsTyping]: boolean,
}

export class ChatContentModel extends ChatContentEntity{
    static readonly kMessages = "messages";
    static readonly kIsTyping = "isTyping";

    output() : ChatContentOutputToClient {
        return {
            [ChatContentModel.kMessages]: this.messages.map((message) => MessageModel.fromEntity(message).output()),
            [ChatContentModel.kIsTyping]: this.isTyping
        }
    }

    static fromEntity(entity: ChatContentEntity) : ChatContentModel {
        return new ChatContentModel(entity.messages, entity.isTyping);
    }
}
