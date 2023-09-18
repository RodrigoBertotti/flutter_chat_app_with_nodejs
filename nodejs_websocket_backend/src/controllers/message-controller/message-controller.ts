import {MessagesService, MessagesServiceParams} from "../../domain/services/messages-service";
import {TextMessageEntity} from "../../domain/entity/text-message-entity";
import {MessageModel} from "../../data/models/message-model";
import {ReadMessagesRoute} from "./routes/read-messages-route";
import {TypingRoute} from "./routes/typing-route";
import {CreateMessageRoute} from "./routes/create-message-route";
import {UserTypedRoute} from "./routes/user-typed-route";
import {MessagesWereReadRoute} from "./routes/messages-were-read-route";
import {MessagesWereUpdatedRoute} from "./routes/messages-were-updated-route";
import {
    ConversationsWithUnreceivedMessagesRoute
} from "./routes/conversations-with-unreceived-messages-route";
import {Controller} from "../../domain/controllers-and-services";
import {ReadRouteInstance} from "askless/route/ReadRoute";
import {AsklessServer, AuthenticateUserContext} from "askless";


export class MessageController implements Controller {
    private readonly messagesService:MessagesService;

    private isTypingRouteInstance:ReadRouteInstance<"TYPING" | "NOT_TYPING", AuthenticateUserContext<number>>;
    private messagesWereUpdatedRouteInstance:ReadRouteInstance<TextMessageEntity[], AuthenticateUserContext<number>>;
    private newConversationsInstance:ReadRouteInstance<number[], AuthenticateUserContext<number>>;
    private readMessagesRouteInstance:ReadRouteInstance<TextMessageEntity[], AuthenticateUserContext<number>>;

    constructor(initMessagesService : (params:MessagesServiceParams) => MessagesService) {
        this.messagesService = initMessagesService({
            notifyReceiverOfNewMessage: this.notifyReceiverOfNewMessage,
            notifyClientIsTyping: this.notifyClientIsTyping,
            notifyMessagesWereUpdated: this.notifyMessagesWereUpdated,
            notifyNewConversationsStarted: this.notifyNewConversationsStarted,
        });
    }

    initializeRoutes (server: AsklessServer<number>) : void {
        /** [READ]   messages    */ this.readMessagesRouteInstance = new ReadMessagesRoute('messages').addReadRoute(server, this.messagesService);
        /** [READ]   is-typing   */ this.isTypingRouteInstance = new TypingRoute('is-typing').addReadRoute(server, this.messagesService);
        /** [CREATE] message     */ new CreateMessageRoute('message').addCreateRoute(server, this.messagesService);
        /** [CREATE] user-typed  */ new UserTypedRoute('user-typed').addCreateRoute(server, this.messagesService);
        /** [CREATE] messages-were-read      */ new MessagesWereReadRoute('messages-were-read').addCreateRoute(server, this.messagesService);
        /** [READ]   messages-were-updated   */ this.messagesWereUpdatedRouteInstance = new MessagesWereUpdatedRoute('messages-were-updated').addReadRoute(server, this.messagesService);
        /** [READ]   conversations-with-unreceived-messages */ this.newConversationsInstance = new ConversationsWithUnreceivedMessagesRoute('conversations-with-unreceived-messages').addReadRoute(server, this.messagesService);
    }

    readonly notifyReceiverOfNewMessage = (message:TextMessageEntity) => {
        console.log("notifyReceiverOfNewMessage has been called");
        this.readMessagesRouteInstance.notifyChanges({
            where: context => {
                return context.userId == message.receiverUserId
                    && context.params["userId"] == message.senderUserId;
            },
            handleReadOverride: (context) => context.successCallback([ message ]),
        })
    }

    readonly notifyClientIsTyping = (userIdWhoWillReceiveTheEvent:number, userIdWhoPerfomedTheAction:number) => {
        this.isTypingRouteInstance.notifyChanges({
            where: (context) => {
                /** Using where to prevent sending the message to the right person but different conversation */
                return (context.userId == userIdWhoWillReceiveTheEvent && context.params['typingUserId'] == userIdWhoPerfomedTheAction)
            },
            handleReadOverride: context => context.successCallback("TYPING")
        });
    }

    readonly notifyMessagesWereUpdated = (senderUserId:number, messages:TextMessageEntity[]) => {
        this.messagesWereUpdatedRouteInstance.notifyChanges({
            where: (context) => {
                return context.userId == senderUserId;
            },
            handleReadOverride: context => context.successCallback(messages),
        });
    }

    /** Only in case the user who will receive the message doesn't have a conversation started */
    readonly notifyNewConversationsStarted = (usersIds:number[], newConversationsUsersIds:number[]) => {
        this.newConversationsInstance.notifyChanges({
            where: (context) => usersIds.includes(context.userId),
            handleReadOverride: context => context.successCallback(newConversationsUsersIds)
        })
    }
}
