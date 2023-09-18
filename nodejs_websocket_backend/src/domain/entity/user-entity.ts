import {Entity, PrimaryGeneratedColumn, Column, OneToMany, ManyToOne, JoinColumn, CreateDateColumn} from "typeorm"
import {TextMessageEntity} from "./text-message-entity";

@Entity({name: "user"})
export class UserEntity {

    @PrimaryGeneratedColumn({unsigned: true})
    userId: number

    @CreateDateColumn()
    createdAt: Date

    @Column()
    firstName: string

    @Column()
    lastName: string

    @Column({unique: true})
    email: string

    @Column({name: "password_hash"})
    passwordHash: string

    @Column({name: "refresh_token_hash", nullable: true})
    refreshTokenHash?: string

    @OneToMany(type => TextMessageEntity, (message) => message.sender, {lazy: true})
    messagesSent:Promise<TextMessageEntity[]>

    @OneToMany(type => TextMessageEntity, (message) => message.receiver, {lazy: true})
    messagesReceived:Promise<UserEntity[]>

}
