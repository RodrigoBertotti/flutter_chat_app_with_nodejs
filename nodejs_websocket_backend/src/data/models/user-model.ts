import {UserEntity} from "../../domain/entity/user-entity";
import {hashEncryption} from "../../utils/encryption-utils";
import {AsklessError} from "askless";


const kUserId = "userId";
const kCreatedAtMsSinceEpoch = "createdAtMsSinceEpoch";
const kFirstName = "firstName";
const kLastName = "lastName";
const kEmail = "email";
const kPassword = "password";

export interface UserOutputToClient {
    [kUserId]: number,
    [kCreatedAtMsSinceEpoch]: number,
    [kFirstName]: string,
    [kLastName]: string,
}
export interface UserBodyFromClient {
    [kUserId]: number,
    [kFirstName]: string,
    [kLastName]: string,
    [kEmail]: string,
    [kPassword]: string,
}

export class UserModel extends UserEntity {

    output() : UserOutputToClient {
        return {
            [kUserId]: this.userId,
            [kFirstName]: this.firstName,
            [kLastName]: this.lastName,
            [kCreatedAtMsSinceEpoch]: this.createdAt.getTime(),
        }
    }

    static toClient(entity:UserEntity) : object {
        return Object.assign(new UserModel(), entity).output();
    }

    static async fromBody(data: UserBodyFromClient) : Promise<UserModel> {
        if(UserModel.invalid(data)) {
            throw new AsklessError({code: "BAD_REQUEST", description: UserModel.validationError(data)});
        }
        const res = new UserModel();
        res.userId = data.userId;
        res.firstName = data.firstName;
        res.lastName = data.lastName;
        res.email = data.email;
        res.passwordHash = await hashEncryption(data.password);
        return res;
    }

    private static invalid(data: UserBodyFromClient) : boolean {
        return Boolean(UserModel.validationError(data)?.length);
    }

    private static validationError(data:UserBodyFromClient) : string | null {
        const separator = '; ';
        let errors = "";
        if(!data.firstName?.length) {
            errors += `Missing '${kFirstName}'${separator}`;
        }
        if(!data.lastName?.length) {
            errors += `Missing '${kLastName}'${separator}`;
        }
        if(!data.email?.length) {
            errors += `Missing '${kEmail}'${separator}`;
        }
        if(!data.password?.length) {
            errors += `Missing '${kPassword}'${separator}`;
        }
        if(errors?.length){
            console.error(errors);
        }
        return errors.length ? errors.substring(0, errors.length - separator.length) : null;
    }

    static fromEntity(entity: UserEntity) : UserModel {
        return Object.assign(new UserModel(), entity);
    }

    static fromEntityList(users: UserEntity[]) {
        return users.map((u) => UserModel.fromEntity(u));
    }
}
