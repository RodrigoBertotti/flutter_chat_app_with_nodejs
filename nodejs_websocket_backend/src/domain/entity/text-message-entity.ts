import {
    Entity,
    PrimaryGeneratedColumn,
    Column,
    OneToMany,
    ManyToOne,
    JoinColumn,
    CreateDateColumn,
    PrimaryColumn
} from "typeorm"
import {UserEntity} from "./user-entity";

@Entity({name: 'text_message'})
export class TextMessageEntity {

    /**
     * `messageId` is a random string generated in the App side,
     *  the message will be saved offline in the App first, and
     *  will be sent to the server afterward
     * */
    @PrimaryColumn({length: 28})
    messageId: string

    @Column()
    sentAt: Date

    @Column({nullable: true})
    receivedAt?: Date

    @Column({nullable: false, default: false})
    senderHasOutdatedVersion?: boolean

    @Column({nullable: true})
    readAt?:Date;

    @Column()
    text: string

    @Column({unsigned: true})
    senderUserId: number

    @Column({unsigned: true})
    receiverUserId: number

    @ManyToOne(type => UserEntity, (user) => user.messagesSent, {lazy: true, nullable: false})
    sender:Promise<UserEntity>

    @ManyToOne(type => UserEntity, (user) => user.messagesReceived, {lazy: true,  nullable: false})
    receiver:Promise<UserEntity>

}
