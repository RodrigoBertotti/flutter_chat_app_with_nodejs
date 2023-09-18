import {TextMessageEntity} from "./text-message-entity";


export class ChatContentEntity {

    constructor(
        public readonly messages: TextMessageEntity[],
        public readonly isTyping:boolean,
    ) {}

}
