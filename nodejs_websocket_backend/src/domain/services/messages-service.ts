import {AppDataSource} from "../../data/data-source/db-datasouce";
import {TextMessageEntity} from "../entity/text-message-entity";
import {FindOptionsWhere, In, IsNull, LessThanOrEqual} from "typeorm";
import {QueryDeepPartialEntity} from "typeorm/query-builder/QueryPartialEntity";


const kTypingDurationMs:number = 800;

export type MessagesServiceParams = {
    notifyMessagesWereUpdated: (senderUserId: number, messages:TextMessageEntity[]) => void;
    notifyClientIsTyping: (userIdWhoWillReceiveTheEvent: number, userIdWhoPerfomedTheAction: number) => void;
    notifyNewConversationsStarted: (usersIds: number[], newConversationsUsersIds:number[]) => void;
    notifyReceiverOfNewMessage: (message: TextMessageEntity) => void
};

export class MessagesService {

    constructor(
        readonly params: MessagesServiceParams
    ) {}

    private readonly _messagesTypeormRepo = AppDataSource.getRepository(TextMessageEntity);

    /**
     *
     * `key`: `typingUserId` (preffix) and `userId2` (suffix) separed by underscore in the middle.
     *  For example: 100_101
     *
     * `value`: NodeJS.Timeout
     * */
    private readonly typing:Map<String,NodeJS.Timeout> = new Map();

    async conversationsWithUnreceivedMessages(loggedUserId:number,) : Promise<number[]> {
        const rows = await this._messagesTypeormRepo.createQueryBuilder("message")
            .select("senderUserId")
            .where(`${("receiverUserId" as keyof TextMessageEntity)} = :receiverUserId`, {receiverUserId: loggedUserId})
            .where(`${("receivedAt" as keyof TextMessageEntity)} is null`)
            .groupBy("senderUserId")
            .getRawMany();

        const res = (rows ?? []).map(row => row.senderUserId).filter((senderUserId) => senderUserId != loggedUserId);

        if (res.includes(loggedUserId)) { throw Error("LOGGED USER ID SHOULD NOT BE INCLUDED"); }
        if (res.length && typeof res[0] != "number") { throw Error("NOT INTEGER -> "+(typeof res[0])); }
        return res;
    }

    // fazer isso?
    // iniciar no login, fechar no logout?
    // flutter local notifications


    async getMessages(loggedUserId:number, senderUserId:number) : Promise<TextMessageEntity[]>  {
        return await AppDataSource.manager.find(TextMessageEntity, {
            where: [
                { receiverUserId: loggedUserId, senderUserId: senderUserId, receivedAt: IsNull() },
            ],
            order: { sentAt: "DESC" },
        });
    }

    async notifyMessagesWereRead(receiverUserId: number, senderUserId: number, lastMessageReadHasBeenReceived: Date) : Promise<Date> {
        const readAt = new Date();
        const options: FindOptionsWhere<TextMessageEntity> = {
            receiverUserId: receiverUserId,
            senderUserId: senderUserId,
            receivedAt: LessThanOrEqual(lastMessageReadHasBeenReceived),
            readAt: IsNull(),
        };
        const messages = await AppDataSource.manager.find(TextMessageEntity, { where: options });
        const update = { readAt };
        const res = await this._messagesTypeormRepo.update(options, update)
        this.params.notifyMessagesWereUpdated(senderUserId, messages.map(message => Object.assign(message, update)),);
        return readAt;
    }

    async createMessage(senderUserId: number, receiverUserId: number, message: TextMessageEntity) : Promise<TextMessageEntity> {
        message.sentAt = new Date();
        message = Object.assign(new TextMessageEntity(), message);
        message = await AppDataSource.manager.save(TextMessageEntity, message)

        this.params.notifyReceiverOfNewMessage(message);
        this.params.notifyMessagesWereUpdated(senderUserId, [message]);

        this.params.notifyNewConversationsStarted([receiverUserId], [senderUserId]);
        return message;
    }

    async handleMessagesUpdate (messages: TextMessageEntity[], update: QueryDeepPartialEntity<TextMessageEntity>) : Promise <void> {
        console.log("notifyMessagesWereUpdated: "+JSON.stringify(update));

        const messagesBySenderUserId:Map<number, TextMessageEntity[]> = new Map();
        for (let message of messages) {
            if (messagesBySenderUserId.get(message.senderUserId) == null) {
                messagesBySenderUserId.set(message.senderUserId, []);
            }
            messagesBySenderUserId.get(message.senderUserId).push(Object.assign(message, update));
        }
        for (let senderUserId of Array.from(messagesBySenderUserId.keys())) {
            for (let message of messagesBySenderUserId.get(senderUserId)){
                await this._messagesTypeormRepo.update(message.messageId, update);
            }
            this.params.notifyMessagesWereUpdated(senderUserId, messagesBySenderUserId.get(senderUserId),);
        }
    }

    notifyUserIsTyping(userIdWhoIsTyping: number, userIdWhoWillReceiveEvent: number) {
        if (userIdWhoIsTyping == null) { throw Error ("userIdWhoIsTyping is null"); }
        if (userIdWhoWillReceiveEvent == null) { throw Error ("userIdWhoWillReceiveEvent is null"); }

        if (this.typing[`${userIdWhoIsTyping}_${userIdWhoWillReceiveEvent}`]) {
            clearTimeout(this.typing[`${userIdWhoIsTyping}_${userIdWhoWillReceiveEvent}`]);
        }
        this.typing[`${userIdWhoIsTyping}_${userIdWhoWillReceiveEvent}`] = setTimeout(() => this.userIsNotTypingAnymoreCallback(userIdWhoIsTyping, userIdWhoWillReceiveEvent), kTypingDurationMs);

        this.params.notifyClientIsTyping(userIdWhoWillReceiveEvent, userIdWhoIsTyping);
    }

    private userIsNotTypingAnymoreCallback(mainUserId:number, userId2:number)  {
        delete this.typing[`${mainUserId}_${userId2}`];
    }

    isTyping(typingUserId: number, userId2: number) : boolean {
        return this.typing[`${typingUserId}_${userId2}`] ?? false;
    }

    async handleSenderReceivedMessagesUpdate(messagesIds: string[]) : Promise<void> {
        if (messagesIds?.length) {
            await this._messagesTypeormRepo.update(messagesIds, {
                senderHasOutdatedVersion: false
            });
        } else {
            console.log("senderReceivedMessagesUpdates is empty/null");
        }
    }

    getMessagesWhereSenderHasAnOutdatedVersion(senderUserId: number, receiverUserId: number) : Promise<TextMessageEntity[]> {
        return this._messagesTypeormRepo.findBy(
            [{
                senderUserId: senderUserId,
                receiverUserId: receiverUserId,
                senderHasOutdatedVersion: true
            }]
        );
    }

    async getMessagesByIds(messagesIds: number[]) {
        return this._messagesTypeormRepo.findBy({
            messageId: In(messagesIds)
        });
    }
}
