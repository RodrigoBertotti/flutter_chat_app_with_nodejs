

/** TypingIndicatorEntity is not stored in the database  */
export class TypingIndicatorEntity {

    constructor(
       public readonly senderUserId:number,
       public readonly receiverUserId:number
    ) {}
}