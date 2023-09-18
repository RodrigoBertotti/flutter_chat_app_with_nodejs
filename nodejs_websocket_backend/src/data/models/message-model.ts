import {TextMessageEntity} from "../../domain/entity/text-message-entity";
import {AsklessError} from "askless";

/** output field keys */
const kMessageId = "messageId";
const kSentAtMsSinceEpoch = "sentAtMsSinceEpoch";
const kReceivedAtMsSinceEpoch = "receivedAtMsSinceEpoch";
const kReadAtMsSinceEpoch = "readAtMsSinceEpoch";
const kSenderUserId = "senderUserId";
const kReceiverUserId = "receiverUserId";
const kText = "text";

export interface TextMessageOutput {
    [kMessageId]: string;
    [kSentAtMsSinceEpoch]: number;
    [kReceivedAtMsSinceEpoch]: number;
    [kSenderUserId]: number;
    [kReceiverUserId]: number;
    [kText]: string;
}

export interface TextMessageInput {
    [kMessageId]: string;
    [kReceiverUserId]: number;
    [kText]: string;
}

export class MessageModel extends TextMessageEntity {

    output() : TextMessageOutput {
        return Object.assign({}, {
            [kMessageId]: this.messageId,
            [kSentAtMsSinceEpoch]: this.sentAt.getTime(),
            [kReceivedAtMsSinceEpoch]: this.receivedAt?.getTime(),
            [kReadAtMsSinceEpoch]: this.readAt?.getTime(),
            [kSenderUserId]: this.senderUserId,
            [kReceiverUserId]: this.receiverUserId,
            [kText]: this.text,
        });
    }

    static fromEntity(entity: TextMessageEntity) : MessageModel {
        return Object.assign(new MessageModel(), entity);
    }

    static fromBody(data: TextMessageInput, senderUserId:number) : MessageModel {
        if(MessageModel.invalid(data)) {
            throw new AsklessError({code: "BAD_REQUEST", description: MessageModel.validationError(data)});
        }
        const res = new MessageModel();
        res.messageId = data.messageId;
        res.text = data.text;
        res.senderUserId = senderUserId;
        res.receiverUserId = data.receiverUserId;
        return res;
    }

    static fromEntityList(receivedMessages: TextMessageEntity[]) : MessageModel[] {
        return receivedMessages.map((msg) => MessageModel.fromEntity(msg));
    }

    private static validationError (data:TextMessageInput) {
        const separator = '; ';
        let errors = "";
        if (!data.messageId?.length) {
            errors += `Generate a random string of 28 characters for the "${kMessageId}" field${separator}`;
        }
        if (!data.text?.length) {
            errors += `"${kText}" is null or empty${separator}`;
        }
        if (!data.receiverUserId) {
            errors += `"${kReceiverUserId}" is null${separator}`;
        }
        const res = errors.substring(0, errors.length - separator.length);
        if (!res.length) {
            return null;
        }
        return res;
    }
    private static invalid(data: TextMessageInput) {
        return Boolean(this.validationError(data)?.length);
    }
}
